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
require 'aws_runas/config'

describe AwsRunAs::Config do
  describe '::find_config_file' do
    before(:example) do
      allow(File).to receive(:expand_path).with('aws_config').and_return('./aws_config')
      allow(File).to receive(:expand_path).with('~/.aws/config').and_return('./.aws/config')
      allow(File).to receive(:exist?).with('./.aws/config').and_return true
    end

    it 'finds a file at ./aws_config' do
      allow(File).to receive(:exist?).with('./aws_config').and_return true
      expect(AwsRunAs::Config.find_config_file).to eq('./aws_config')
    end
    it 'finds a file at ~/.aws/config' do
      allow(File).to receive(:exist?).with('./aws_config').and_return false
      expect(AwsRunAs::Config.find_config_file).to eq('./.aws/config')
    end
  end

  context 'with profile set to default' do
    before(:context) do
      @cfg = AwsRunAs::Config.new(path: MOCK_AWS_CONFIGPATH, profile: 'default')
    end

    describe '#load_config_value' do
      it 'loads a value from the default profile' do
        expect(@cfg.load_config_value(key: 'region')).to eq('us-east-1')
      end
    end

    describe '#load_source_profile' do
      it 'returns the default profile when no source profile is present' do
        expect(@cfg.load_source_profile).to eq('default')
      end
    end
  end

  context 'with profile set to test-profile' do
    before(:context) do
      @cfg = AwsRunAs::Config.new(path: MOCK_AWS_CONFIGPATH, profile: 'test-profile')
    end

    describe '#initialize' do
      it 'sets the profile correctly' do
        expect(@cfg.instance_variable_get('@profile')).to eq('test-profile')
      end
    end

    describe '#load_config_value' do
      it 'loads a value from the non-default profile' do
        expect(@cfg.load_config_value(key: 'mfa_serial')).to eq('arn:aws:iam::123456789012:mfa/test')
      end
    end

    describe '#mfa_required' do
      it 'confirms MFA is required the non-default profile' do
        expect(@cfg.instance_variable_get('@profile')).to eq('test-profile')
        expect(@cfg.mfa_required?).to be true
      end
    end

    describe '#load_source_profile' do
      it 'loads the source credentials profile for the the non-default profile' do
        expect(@cfg.load_source_profile).to eq('test-credentials')
      end
    end
  end
end
