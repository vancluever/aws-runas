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

require 'aws_runas/config'
require 'aws-sdk'

module AwsRunAs
  # Main program logic for aws-runas - sets up sts asession and assumed role,
  # and hands off environment to called process.
  class Main
    # Instantiate the object and set up the path, profile, and
    def initialize(path: nil, profile: default, mfa_code: nil)
      if path
        cfg_path = path
      else
        cfg_path = AwsRunAs::Config.find_config_file
      end
      @cfg = AwsRunAs::Config.new(path: cfg_path, profile: profile)
      @mfa_code = mfa_code
    end

    def sts_client
      region = @cfg.load_config_value(key: 'region')
      region = 'us-east-1' unless region
      Aws::STS::Client.new(
        profile: @cfg.load_source_profile,
        region: region
      )
    end

    def assume_role
      session_id = "aws-runas-session_#{Time.now.to_i}"
      role_arn = @cfg.load_config_value(key: 'role_arn')
      mfa_serial = @cfg.load_config_value(key: 'mfa_serial')
      @role_credentials = Aws::AssumeRoleCredentials.new(
        client: sts_client,
        role_arn: role_arn,
        serial_number: mfa_serial,
        token_code: @mfa_code,
        role_session_name: session_id
      ).credentials
    end

    def credentials_env
      env = {}
      env['AWS_ACCESS_KEY_ID'] = @role_credentials.access_key_id
      env['AWS_SECRET_ACCESS_KEY'] = @role_credentials.secret_access_key
      env['AWS_SESSION_TOKEN'] = @role_credentials.session_token
      env
    end

    def handoff(command: nil, argv: nil)
      env = credentials_env
      command = '/bin/sh' unless command
      exec(env, command, *argv)
    end
  end
end
