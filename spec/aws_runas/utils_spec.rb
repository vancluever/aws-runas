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

describe AwsRunAs::Utils do
  describe '::bash_with_prompt' do
    context 'with RC file' do
      before(:example) do
        allow(IO).to receive(:read).with("#{ENV['HOME']}/.bashrc").and_return(BASHRC_FILE_CONTENTS)
      end
      it 'runs bash with a properly combined RC file' do
        expect(AwsRunAs::Utils).to receive(:system).with(EXPECTED_ENV, '/bin/bash', '--rcfile', anything)
        expect_any_instance_of(Tempfile).to receive(:write).with("#{BASHRC_FILE_CONTENTS}\n")
        expect_any_instance_of(Tempfile).to receive(:write).with(BASHRC_EXPECTED_PROMPT)
        AwsRunAs::Utils.bash_with_prompt(env: EXPECTED_ENV, path: '/bin/bash', message: 'AWS:rspec')
      end
    end

    context 'without RC file' do
      before(:example) do
        allow(File).to receive(:exist?).with("#{ENV['HOME']}/.bashrc").and_return(false)
      end
      it 'runs bash (no RC file found)' do
        expect(AwsRunAs::Utils).to receive(:system).with(EXPECTED_ENV, '/bin/bash', '--rcfile', anything)
        expect_any_instance_of(Tempfile).to receive(:write).with(BASHRC_EXPECTED_PROMPT)
        AwsRunAs::Utils.bash_with_prompt(env: EXPECTED_ENV, path: '/bin/bash', message: 'AWS:rspec')
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
        expect(AwsRunAs::Utils).to receive(:bash_with_prompt).with(env: EXPECTED_ENV, path: '/bin/bash', message: 'AWS:rspec')
        AwsRunAs::Utils.handoff_to_shell(env: EXPECTED_ENV, profile: 'rspec')
      end
    end

    context 'with non-prompt supported shell' do
      before(:example) do
        allow(AwsRunAs::Utils).to receive(:shell).and_return('/bin/sh')
        allow(AwsRunAs::Utils).to receive(:exit)
      end

      it 'starts a default shell without any args' do
        expect(AwsRunAs::Utils).to receive(:system).with(EXPECTED_ENV, '/bin/sh')
        AwsRunAs::Utils.handoff_to_shell(env: EXPECTED_ENV, profile: nil)
      end
    end
  end
end
