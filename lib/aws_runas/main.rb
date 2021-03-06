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
require 'aws_runas/utils'

# AWS_SDK_CONFIG_OPT_OUT must be set here so that we use the pre-2.4 SDK
# behaviour, which ensures that ~/.aws/config is not re-read when assuming
# roles.
ENV.store('AWS_SDK_CONFIG_OPT_OUT', '1')
require 'aws-sdk'

module AwsRunAs
  # Main program logic for aws-runas - sets up sts asession and assumed role,
  # and hands off environment to called process.
  class Main
    # Instantiate the object and set up the path, profile, and populate MFA.
    #
    # Session timestamp is also registered here to prevent races.
    def initialize(path: nil, profile: default, mfa_code: nil, no_role: nil, duration_seconds: 3600)
      cfg_path = if path
                   path
                 else
                   AwsRunAs::Config.find_config_file
                 end
      @cfg = AwsRunAs::Config.new(path: cfg_path, profile: profile)
      @mfa_code = mfa_code
      @no_role = no_role
      @duration_seconds = duration_seconds
      @session_timestamp = Time.now.to_i
    end

    def sts_client
      region = @cfg.load_config_value(key: 'region')
      region = 'us-east-1' unless region
      Aws::STS::Client.new(
        profile: @cfg.load_source_profile,
        region: region
      )
    end

    def render_classic_session
      "aws-runas-session_#{@session_timestamp}"
    end

    def render_account_user_session(caller_identity)
      "aws-runas-session_#{caller_identity.account}_#{caller_identity.arn.split('/')[-1]}_#{@session_timestamp}"
    end

    def render_access_key_session(caller_identity)
      "aws-runas-session_#{caller_identity.user_id.split(':')[0]}_#{@session_timestamp}"
    end

    def use_access_key_id?(caller_identity)
      caller_identity.arn =~ %r{^arn:aws:sts::\d+:assumed-role\/} ||
        render_account_user_session(caller_identity).length > 64
    end

    # Returns a session name based on the following criteria:
    #  * If the user ARN matches that of an assumed role, return the access key ID
    #  * Otherwise, return the account ID and the user (last part of the ARN).
    def render_modern_session(caller_identity)
      return render_access_key_session(caller_identity) if use_access_key_id?(caller_identity)
      render_account_user_session(caller_identity)
    end

    def session_id
      caller_identity = sts_client.get_caller_identity
      return render_classic_session if render_modern_session(caller_identity).length > 64
      render_modern_session(caller_identity)
    rescue Aws::STS::Errors::AccessDeniedException
      render_classic_session
    end

    def assume_role
      @role_session_name = session_id
      role_arn = @cfg.load_config_value(key: 'role_arn')
      mfa_serial = @cfg.load_config_value(key: 'mfa_serial') unless ENV.include?('AWS_SESSION_TOKEN')
      if @no_role
        raise 'No mfa_serial in selected profile, session will be useless' if mfa_serial.nil?
        @session = sts_client.get_session_token(
          serial_number: mfa_serial,
          token_code: @mfa_code,
          duration_seconds: @duration_seconds
        )
      else
        @session = Aws::AssumeRoleCredentials.new(
          client: sts_client,
          role_arn: role_arn,
          serial_number: mfa_serial,
          token_code: @mfa_code,
          role_session_name: @role_session_name,
          duration_seconds: @duration_seconds
        )
      end
    end

    def session_credentials
      @session.credentials
    end

    def credentials_env
      env = {}
      env['AWS_ACCESS_KEY_ID'] = session_credentials.access_key_id
      env['AWS_SECRET_ACCESS_KEY'] = session_credentials.secret_access_key
      env['AWS_SESSION_TOKEN'] = session_credentials.session_token
      env['AWS_RUNAS_PROFILE'] = @cfg.profile
      unless @cfg.load_config_value(key: 'region').nil?
        env['AWS_REGION'] = @cfg.load_config_value(key: 'region')
        env['AWS_DEFAULT_REGION'] = @cfg.load_config_value(key: 'region')
      end
      if @no_role
        env['AWS_SESSION_EXPIRATION'] = session_credentials.expiration.to_s
        env['AWS_SESSION_EXPIRATION_UNIX'] = DateTime.parse(session_credentials.expiration.to_s).strftime('%s')
      else
        env['AWS_SESSION_EXPIRATION'] = @session.expiration.to_s
        env['AWS_SESSION_EXPIRATION_UNIX'] = DateTime.parse(@session.expiration.to_s).strftime('%s')
        env['AWS_RUNAS_ASSUMED_ROLE_ARN'] = @cfg.load_config_value(key: 'role_arn')
        env['AWS_ROLE_SESSION_NAME'] = @role_session_name
      end
      env
    end

    def handoff(command: nil, argv: nil, skip_prompt:)
      env = credentials_env
      unless command
        AwsRunAs::Utils.handoff_to_shell(env: env, profile: @no_role ? nil : @cfg.profile, skip_prompt: skip_prompt)
      end
      exec(env, command, *argv)
    end
  end
end
