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

module AwsRunAs
  # Utility functions that aren't specifically tied to a class.
  module Utils
    # load the shell for a specific operating system.
    # if $SHELL exists, then load that, if not, default to /bin/sh.
    # will expand in the future to allow for some windows stuff.
    def self.shell
      path = if ENV.include?('SHELL')
               ENV['SHELL']
             else
               '/bin/sh'
             end
      # Detect windows.
      path += '.exe' if File.exist?("#{path}.exe") &&
                        RbConfig::CONFIG['host_os'] =~ /mswin|windows|cygwin/i
      path
    end
  end
end
