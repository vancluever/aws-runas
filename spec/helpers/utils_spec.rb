require 'spec_helper'

MOCK_BASHRC_PATH = File.expand_path('../files/bashrc', __FILE__)

BASHRC_FILE_CONTENTS = <<EOS.freeze
foobar
EOS

BASHRC_EXPECTED_PROMPT = "PS1=\"\\[\\e[33m\\](AWS:rspec)\\[\\e[0m\\] $PS1\"\n".freeze

EXPECTED_ENV = {
  'AWS_ACCESS_KEY_ID' => 'AccessKeyId',
  'AWS_SECRET_ACCESS_KEY' => 'SecretAccessKey',
  'AWS_SESSION_TOKEN' => 'Token'
}.freeze
