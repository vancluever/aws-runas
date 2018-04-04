# Copyright 2015 Chris Marchesi
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'trollop'
require 'aws_runas/config'
require 'aws_runas/main'
require 'io/console'

module AwsRunAs
  module Cli
    module_function

    # loads the command-line options.
    def load_opts(args: ARGV)
      Trollop.options(args) do
        banner <<-EOS.gsub(/^ {10}/, '')
          aws-runas: Run commands under AWS IAM roles

          Usage:
            aws-runas [options] COMMAND ARGS

          If COMMAND is omitted, the default shell ($SHELL, /bin/sh, or cmd.exe,
          depending on your system) will launch.

          [options] are:
        EOS

        opt :no_role, 'Get a session token only, do not assume a role', type: TrueClass, default: nil
        opt :skip_prompt, 'Do not launch interactive sessions with the fancy prompt', type: TrueClass, default: nil
        opt :path, 'Path to the AWS config file', type: String
        opt :profile, 'The AWS profile to load', type: String, default: 'default'
        opt :duration, 'The duration in seconds for temporary credentials', type: Integer, default: 3600
        stop_on_unknown
      end
    end

    # Start the CLI. Load options (profile, specific config path), and run
    # main.
    def start
      opts = load_opts
      mfa_code = read_mfa_if_needed(path: opts[:path], profile: opts[:profile])
      @main = AwsRunAs::Main.new(path: opts[:path], profile: opts[:profile], mfa_code: mfa_code, no_role: opts[:no_role], duration_seconds: opts[:duration])
      @main.assume_role
      command = ARGV.shift
      @main.handoff(command: command, argv: ARGV, skip_prompt: opts[:skip_prompt])
    end

    # Reads the MFA code from standard input.
    def read_mfa_if_needed(path: nil, profile: 'default')
      @cfg = AwsRunAs::Config.new(path: path, profile: profile)
      return nil unless @cfg.mfa_required?
      STDOUT.print 'Enter MFA code: '
      STDOUT.flush
      STDIN.gets.chomp
    end
  end
end
