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

require 'inifile'

module AwsRunAs
  # Manages the configuartion file, including loading and retrieving values.
  class Config
    # Finds the configuration file (used if no file is specified).
    # paths searched: ./aws_config, and ~/.aws/config.
    def self.find_config_file
      local_config = File.expand_path('aws_config')
      user_config = File.expand_path('~/.aws/config')
      return local_config if File.exist?(local_config)
      user_config if File.exist?(user_config)
    end

    def initialize(path:, profile:)
      @path = path
      @path = self.class.find_config_file unless @path
      @profile = profile
    end

    # Loads the config section for a specific profile.
    def load_config_value(key:)
      section = @profile
      section = "profile #{@profile}" unless @profile == 'default'
      aws_config = IniFile.load(@path) if File.exist?(@path)
      nil unless aws_config
      aws_config[section][key]
    end

    # Checks to see if MFA is required for a specific profile.
    def mfa_required?
      return true if load_config_value(key: 'mfa_serial')
      false
    end

    # loads the soruce credentials profile based on the supplied profile.
    def load_source_profile
      source_profile = load_config_value(key: 'source_profile')
      return source_profile if source_profile
      profile
    end
  end
end
