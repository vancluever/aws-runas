# Copyright 2016 Chris Marchesi
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

require 'rbconfig'
require 'tempfile'
require 'tmpdir'
require 'fileutils'
require 'English'

module AwsRunAs
  # Utility functions that aren't specifically tied to a class.
  module Utils
    module_function

    # Return the path to the shell_profiles directory vendored with the gem.
    def shell_profiles_dir
      File.expand_path('../../../shell_profiles', __FILE__)
    end

    # Run an interactive bash session with a special streamed RC file.  The RC
    # merges a local .bashrc if it exists, with a prompt that includes the
    # computed message from handoff_to_shell.
    def handoff_bash(env:, path:, message:, skip_prompt:)
      rc_data = IO.read("#{ENV['HOME']}/.bashrc") if File.exist?("#{ENV['HOME']}/.bashrc")
      rc_file = Tempfile.new('aws_runas_bashrc')
      rc_file.write("#{rc_data}\n") unless rc_data.nil?
      rc_file.write(IO.read("#{shell_profiles_dir}/sh.profile"))
      unless skip_prompt
        rc_file.write("PS1=\"\\[\\e[\\$(aws_session_status_color \"bash\")m\\](#{message})\\[\\e[0m\\] $PS1\"\n")
      end
      rc_file.close
      system(env, path, '--rcfile', rc_file.path)
    ensure
      rc_file.unlink
    end

    # Run an interactive zsh session with a special streamed RC file.  The RC
    # merges a local .zshrc if it exists, with a prompt that includes the
    # computed message from handoff_to_shell.
    def handoff_zsh(env:, path:, message:, skip_prompt:)
      rc_data = IO.read("#{ENV['HOME']}/.zshrc") if File.exist?("#{ENV['HOME']}/.zshrc")
      rc_dir = Dir.mktmpdir('aws_runas_zsh')
      rc_file = File.new("#{rc_dir}/.zshrc", 'w')
      rc_file.write("#{rc_data}\n") unless rc_data.nil?
      rc_file.write(IO.read("#{shell_profiles_dir}/sh.profile"))
      unless skip_prompt
        rc_file.write("setopt PROMPT_SUBST\n")
        rc_file.write("OLDPROMPT=\"$PROMPT\"\n")
        rc_file.write("PROMPT=\"%F{$(aws_session_status_color \"zsh\")}(#{message})%f $OLDPROMPT\"\n")
      end
      rc_file.close
      env.store('ZDOTDIR', rc_dir)
      system(env, path)
    ensure
      FileUtils.rmtree(rc_dir)
    end

    # load the shell for a specific operating system.
    # if $SHELL exists, load that.
    def shell
      if RbConfig::CONFIG['host_os'] =~ /mswin|windows|mingw32/i
        'cmd.exe'
      elsif ENV.include?('SHELL')
        ENV['SHELL']
      else
        '/bin/sh'
      end
    end

    # Compute the message given to the prompt based off supplied profile.
    def compute_message(profile:)
      if profile.nil?
        'AWS'
      else
        "AWS:#{profile}"
      end
    end

    # "Handoff" to a supported interactive shell. More technically, this runs
    # an interactive shell with the shell prompt customized to the current
    # running AWS profile. If the shell is not something we can handle
    # specifically, just run the shell.
    def handoff_to_shell(env:, profile: nil, skip_prompt:)
      path = shell
      if path.end_with?('/bash')
        handoff_bash(env: env, path: path, message: compute_message(profile: profile), skip_prompt: skip_prompt)
      elsif path.end_with?('/zsh')
        handoff_zsh(env: env, path: path, message: compute_message(profile: profile), skip_prompt: skip_prompt)
      else
        system(env, path)
      end
      exit $CHILD_STATUS.exitstatus
    end
  end
end
