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

          If COMMAND is omitted, the default shell (/bin/sh) will
          launch.

          [options] are:
        EOS

        opt :path, 'Path to the AWS config file', type: String
        opt :profile, 'The AWS profile to load', type: String, default: 'default'
        stop_on_unknown
      end
    end

    # Start the CLI. Load options (profile, specific config path), and run
    # main.
    def start
      opts = load_opts
      mfa_code = read_mfa_if_needed(path: opts[:path], profile: opts[:profile])
      @main = AwsRunAs::Main.new(path: opts[:path], profile: opts[:profile], mfa_code: mfa_code)
      @main.assume_role
      command = ARGV.shift
      @main.handoff(command: command, argv: ARGV)
    end

    # Reads the MFA code from standard input.
    def read_mfa_if_needed(path: nil, profile: 'default')
      @cfg = AwsRunAs::Config.new(path: path, profile: profile)
      return nil unless @cfg.mfa_required?
      puts 'Enter MFA code:'
      STDIN.noecho(&:gets).chomp
    end
  end
end
