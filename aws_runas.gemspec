# Copyright 2015 Chris Marchesi
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws_runas/version'

Gem::Specification.new do |spec|
  spec.name = 'aws_runas'
  spec.version = AwsRunAs::VERSION
  spec.authors = ['Chris Marchesi']
  spec.email = %w(chrism@vancluevertech.com)
  spec.description = 'Run a command or shell under an assumed AWS IAM role'
  spec.summary = spec.description
  spec.homepage = 'https://github.com/vancluever/aws-runas'
  spec.license = 'Apache-2.0'

  spec.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.bindir = 'exe'
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.cert_chain  = ['certs/vancluever.pem']
  spec.signing_key = File.expand_path('~/.ssh/gem-private_key.pem') if $PROGRAM_NAME =~ /gem\z/

  spec.required_ruby_version = ['>= 2.2.6']

  spec.add_dependency 'aws-sdk', '~> 2.11'
  spec.add_dependency 'inifile', '~> 3.0'
  spec.add_dependency 'optimist', '~> 3.0'

  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'simplecov', '~> 0.10'
  spec.add_development_dependency 'codecov', '~> 0.1'
end
