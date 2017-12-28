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

require 'spec_helper'
require 'tmpdir'

describe AwsRunAs::Utils do
  describe '::get_user' do
    it 'returns a string' do
      expect(AwsRunAs::Utils.get_user).is_a? String
    end

    it 'is not null' do
      expect(AwsRunAs::Utils.get_user).not_to be_empty
    end
  end

  describe '::shell_profiles_dir' do
    it 'returns an existent path' do
      expect(File.directory?(AwsRunAs::Utils.shell_profiles_dir)).to be true
    end
    it 'returns a path correctly relative to spec file' do
      expect(AwsRunAs::Utils.shell_profiles_dir).to eq(File.expand_path('../../../shell_profiles', __FILE__))
    end
  end

  describe '::handoff_bash' do
    context 'with RC file' do
      before(:example) do
        allow(IO).to receive(:read).with("#{ENV['HOME']}/.bashrc").and_return(BASHRC_FILE_CONTENTS)
        allow(IO).to receive(:read).with("#{AwsRunAs::Utils.shell_profiles_dir}/sh.profile").and_call_original
      end
      it 'runs bash with a properly combined RC file' do
        expect(AwsRunAs::Utils).to receive(:system).with(EXPECTED_ENV, '/bin/bash', '--rcfile', anything)
        expect_any_instance_of(Tempfile).to receive(:write).with("#{BASHRC_FILE_CONTENTS}\n")
        expect_any_instance_of(Tempfile).to receive(:write).with(IO.read("#{AwsRunAs::Utils.shell_profiles_dir}/sh.profile"))
        expect_any_instance_of(Tempfile).to receive(:write).with(BASHRC_EXPECTED_PROMPT)
        AwsRunAs::Utils.handoff_bash(env: EXPECTED_ENV, path: '/bin/bash', message: 'AWS:rspec', skip_prompt: false)
      end
    end

    context 'without RC file' do
      before(:example) do
        allow(File).to receive(:exist?).with("#{ENV['HOME']}/.bashrc").and_return(false)
        allow(IO).to receive(:read).with("#{AwsRunAs::Utils.shell_profiles_dir}/sh.profile").and_call_original
      end
      it 'runs bash (no RC file found)' do
        expect(AwsRunAs::Utils).to receive(:system).with(EXPECTED_ENV, '/bin/bash', '--rcfile', anything)
        expect_any_instance_of(Tempfile).to receive(:write).with(IO.read("#{AwsRunAs::Utils.shell_profiles_dir}/sh.profile"))
        expect_any_instance_of(Tempfile).to receive(:write).with(BASHRC_EXPECTED_PROMPT)
        AwsRunAs::Utils.handoff_bash(env: EXPECTED_ENV, path: '/bin/bash', message: 'AWS:rspec', skip_prompt: false)
      end
    end

    context 'with skip_prompt enabled' do
      before(:example) do
        allow(IO).to receive(:read).with("#{ENV['HOME']}/.bashrc").and_return(BASHRC_FILE_CONTENTS)
        allow(IO).to receive(:read).with("#{AwsRunAs::Utils.shell_profiles_dir}/sh.profile").and_call_original
      end
      it 'runs bash with a properly combined RC file, but no prompt modification' do
        expect(AwsRunAs::Utils).to receive(:system).with(EXPECTED_ENV, '/bin/bash', '--rcfile', anything)
        expect_any_instance_of(Tempfile).to receive(:write).with("#{BASHRC_FILE_CONTENTS}\n")
        expect_any_instance_of(Tempfile).to receive(:write).with(IO.read("#{AwsRunAs::Utils.shell_profiles_dir}/sh.profile"))
        AwsRunAs::Utils.handoff_bash(env: EXPECTED_ENV, path: '/bin/bash', message: 'AWS:rspec', skip_prompt: true)
      end
    end
  end

  describe '::handoff_zsh' do
    context 'with RC file' do
      before(:example) do
        allow(IO).to receive(:read).with("#{ENV['HOME']}/.zshrc").and_return(ZSHRC_FILE_CONTENTS)
        allow(IO).to receive(:read).with("#{AwsRunAs::Utils.shell_profiles_dir}/sh.profile").and_call_original
      end
      it 'runs zsh with a properly combined RC file, in special tmp dir' do
        expect(AwsRunAs::Utils).to receive(:system).with(EXPECTED_ENV_ZSH, '/usr/bin/zsh')
        expect(Dir).to receive(:mktmpdir).with('aws_runas_zsh') { test_mktmpdir }
        expect_any_instance_of(File).to receive(:write).with("#{ZSHRC_FILE_CONTENTS}\n")
        expect_any_instance_of(File).to receive(:write).with(IO.read("#{AwsRunAs::Utils.shell_profiles_dir}/sh.profile"))
        expect_any_instance_of(File).to receive(:write).with(ZSHRC_EXPECTED_SETSUBST)
        expect_any_instance_of(File).to receive(:write).with(ZSHRC_EXPECTED_OLDPROMPT)
        expect_any_instance_of(File).to receive(:write).with(ZSHRC_EXPECTED_PROMPT)
        env = EXPECTED_ENV.dup
        AwsRunAs::Utils.handoff_zsh(env: env, path: '/usr/bin/zsh', message: 'AWS:rspec', skip_prompt: false)
      end
    end

    context 'without RC file' do
      before(:example) do
        allow(File).to receive(:exist?).with("#{ENV['HOME']}/.zshrc").and_return(false)
        allow(IO).to receive(:read).with("#{AwsRunAs::Utils.shell_profiles_dir}/sh.profile").and_call_original
      end
      it 'runs zsh (no RC file found)' do
        expect(AwsRunAs::Utils).to receive(:system).with(EXPECTED_ENV_ZSH, '/usr/bin/zsh')
        expect(Dir).to receive(:mktmpdir).with('aws_runas_zsh') { test_mktmpdir }
        expect_any_instance_of(File).to receive(:write).with(IO.read("#{AwsRunAs::Utils.shell_profiles_dir}/sh.profile"))
        expect_any_instance_of(File).to receive(:write).with(ZSHRC_EXPECTED_SETSUBST)
        expect_any_instance_of(File).to receive(:write).with(ZSHRC_EXPECTED_OLDPROMPT)
        expect_any_instance_of(File).to receive(:write).with(ZSHRC_EXPECTED_PROMPT)
        env = EXPECTED_ENV.dup
        AwsRunAs::Utils.handoff_zsh(env: env, path: '/usr/bin/zsh', message: 'AWS:rspec', skip_prompt: false)
      end
    end

    context 'with skip_prompt enabled' do
      before(:example) do
        allow(IO).to receive(:read).with("#{ENV['HOME']}/.zshrc").and_return(ZSHRC_FILE_CONTENTS)
        allow(IO).to receive(:read).with("#{AwsRunAs::Utils.shell_profiles_dir}/sh.profile").and_call_original
      end
      it 'runs zsh with a properly combined RC file, in special tmp dir' do
        expect(AwsRunAs::Utils).to receive(:system).with(EXPECTED_ENV_ZSH, '/usr/bin/zsh')
        expect(Dir).to receive(:mktmpdir).with('aws_runas_zsh') { test_mktmpdir }
        expect_any_instance_of(File).to receive(:write).with("#{ZSHRC_FILE_CONTENTS}\n")
        expect_any_instance_of(File).to receive(:write).with(IO.read("#{AwsRunAs::Utils.shell_profiles_dir}/sh.profile"))
        env = EXPECTED_ENV.dup
        AwsRunAs::Utils.handoff_zsh(env: env, path: '/usr/bin/zsh', message: 'AWS:rspec', skip_prompt: true)
      end
    end

  end

  describe '::shell' do
    context 'Non-Windows OS' do
      context 'No $SHELL set' do
        before(:context) do
          ENV.delete('SHELL')
        end

        it 'returns /bin/sh as the shell' do
          expect(AwsRunAs::Utils.shell).to eq '/bin/sh'
        end
      end

      context 'With $SHELL set as /bin/bash' do
        before(:context) do
          ENV.store('SHELL', '/bin/bash')
        end

        it 'returns /bin/bash as the shell' do
          expect(AwsRunAs::Utils.shell).to eq '/bin/bash'
        end
      end
    end

    context 'Windows OS' do
      before(:context) do
        ENV.delete('SHELL')
        RbConfig::CONFIG.store('host_os', 'windows')
      end

      it 'returns cmd.exe as the shell' do
        expect(AwsRunAs::Utils.shell).to eq 'cmd.exe'
      end
    end
  end

  describe '::compute_message' do
    context 'no profile specified' do
      it 'returns "AWS" with no profile' do
        expect(AwsRunAs::Utils.compute_message(profile: nil)).to eq 'AWS'
      end
    end

    context 'with profile as "rspec"' do
      it 'returns "AWS:rspec", indicating that is the profile' do
        expect(AwsRunAs::Utils.compute_message(profile: 'rspec')).to eq 'AWS:rspec'
      end
    end
  end

  describe '::handoff_to_shell' do
    context 'with shell as bash' do
      before(:example) do
        allow(AwsRunAs::Utils).to receive(:shell).and_return('/bin/bash')
        allow(AwsRunAs::Utils).to receive(:exit)
      end

      it 'Loads bash with the rspec profile prompt' do
        expect(AwsRunAs::Utils).to receive(:handoff_bash).with(env: EXPECTED_ENV, path: '/bin/bash', message: 'AWS:rspec', skip_prompt: false)
        AwsRunAs::Utils.handoff_to_shell(env: EXPECTED_ENV, profile: 'rspec', skip_prompt: false)
      end
    end

    context 'with non-prompt supported shell' do
      before(:example) do
        allow(AwsRunAs::Utils).to receive(:shell).and_return('/bin/sh')
        allow(AwsRunAs::Utils).to receive(:exit)
      end

      it 'starts a default shell without any args' do
        expect(AwsRunAs::Utils).to receive(:system).with(EXPECTED_ENV, '/bin/sh')
        AwsRunAs::Utils.handoff_to_shell(env: EXPECTED_ENV, profile: nil, skip_prompt: false)
      end
    end
  end
end
