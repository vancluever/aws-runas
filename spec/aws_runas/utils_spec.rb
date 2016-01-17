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
end
