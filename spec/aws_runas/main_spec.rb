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

require 'spec_helper'
require 'aws_runas/main'

describe AwsRunAs::Main do
  before(:context) do
    @main = AwsRunAs::Main.new(
      path: MOCK_AWS_CONFIGPATH,
      profile: 'test-profile',
      mfa_code: '123456'
    )
  end

  describe '#sts_client' do
    it 'returns a proper Aws::STS::Client object' do
      expect(@main.sts_client.class.name).to eq('Aws::STS::Client')
    end
  end

  describe '#assume_role' do
    it 'calls out to Aws::AssumeRoleCredentials.new' do
      expect(Aws::AssumeRoleCredentials).to receive(:new).and_call_original
      @main.assume_role
    end
  end

  describe '#credentials_env' do
    before(:context) do
      @env = @main.credentials_env
    end

    it 'returns AWS_ACCESS_KEY_ID set in env' do
      expect(@env['AWS_ACCESS_KEY_ID']).to eq('accessKeyIdType')
    end

    it 'returns AWS_SECRET_ACCESS_KEY set in env' do
      expect(@env['AWS_SECRET_ACCESS_KEY']).to eq('accessKeySecretType')
    end

    it 'returns AWS_SESSION_TOKEN set in env' do
      expect(@env['AWS_SESSION_TOKEN']).to eq('tokenType')
    end
  end

  describe '#handoff' do
    before(:context) do
      @env = @main.credentials_env
    end

    it 'calls exec with the environment properly set' do
      expect(@main).to receive(:exec).with(@env, any_args)
      @main.handoff
    end

    it 'starts a shell if no command is specified' do
      expect(@main).to receive(:exec).with(@env, '/bin/sh', *nil)
      @main.handoff
    end

    it 'execs a command when a command is specified' do
      expect(@main).to receive(:exec).with(anything, '/usr/bin/foo', *['--bar', 'baz'])
      @main.handoff(command: '/usr/bin/foo', argv: ['--bar', 'baz'])
    end
  end
end
