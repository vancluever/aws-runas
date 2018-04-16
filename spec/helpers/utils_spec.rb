require 'spec_helper'
require 'tmpdir'

MOCK_BASHRC_PATH = File.expand_path('../files/bashrc', __FILE__)

BASHRC_FILE_CONTENTS = <<EOS.freeze
foobar
EOS

ZSHRC_FILE_CONTENTS = <<EOS.freeze
bazqux
EOS

BASHRC_EXPECTED_PROMPT   = "PS1=\"\\[\\e[\\$(aws_session_status_color \"bash\")m\\](AWS:rspec)\\[\\e[0m\\] $PS1\"\n".freeze
ZSHRC_EXPECTED_PROMPT    = "PROMPT=\"%F{$(aws_session_status_color \"zsh\")}(AWS:rspec)%f $OLDPROMPT\"\n".freeze
ZSHRC_EXPECTED_SETSUBST  = "setopt PROMPT_SUBST\n".freeze
ZSHRC_EXPECTED_OLDPROMPT = "OLDPROMPT=\"$PROMPT\"\n".freeze
ZSH_MOCK_TMPDIR          = "#{Dir.tmpdir}/aws_runas_zsh_rspec".freeze

EXPECTED_ENV = {
  'AWS_ACCESS_KEY_ID' => 'AccessKeyId',
  'AWS_SECRET_ACCESS_KEY' => 'SecretAccessKey',
  'AWS_SESSION_TOKEN' => 'Token'
}.freeze

EXPECTED_ENV_ZSH = {
  'AWS_ACCESS_KEY_ID' => 'AccessKeyId',
  'AWS_SECRET_ACCESS_KEY' => 'SecretAccessKey',
  'AWS_SESSION_TOKEN' => 'Token',
  'ZDOTDIR' => ZSH_MOCK_TMPDIR
}.freeze

def test_mktmpdir
  Dir.mkdir(ZSH_MOCK_TMPDIR)
  ZSH_MOCK_TMPDIR
end
