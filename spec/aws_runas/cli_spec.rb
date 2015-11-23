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
require 'aws_runas/cli'
require 'aws_runas/main'

describe AwsRunAs::Cli do
  describe '::load_opts' do
    it 'loads the path option' do
      opts = AwsRunAs::Cli.load_opts(args: ['--path', 'test-opts/aws_config'])
      expect(opts[:path]).to eq('test-opts/aws_config')
    end

    it 'loads the profile option' do
      opts = AwsRunAs::Cli.load_opts(args: ['--profile', 'test-profile'])
      expect(opts[:profile]).to eq('test-profile')
    end
  end

  describe '::start' do
    before(:example) do
      allow(AwsRunAs::Cli).to receive(:load_opts).and_return({})
      allow(AwsRunAs::Cli).to receive(:read_mfa_if_needed)
      allow(AwsRunAs::Main).to receive(:new).and_return double(
        'AwsRunAs::Main',
        assume_role: true,
        handoff: true
      )
    end

    it 'creates an AwsConfig::Main instance' do
      expect(AwsRunAs::Main).to receive(:new)
      AwsRunAs::Cli.start
    end
  end

  describe '::read_mfa_if_needed' do
    it 'reads the MFA code' do
      allow(STDIN).to receive(:gets).and_return('123456')
      mfa_code = AwsRunAs::Cli.read_mfa_if_needed(
        path: MOCK_AWS_CONFIGPATH,
        profile: 'test-profile'
      )
      expect(mfa_code).to eq('123456')
    end
  end
end
