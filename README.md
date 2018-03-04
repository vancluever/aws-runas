[![Build Status](https://img.shields.io/travis/vancluever/aws-runas.svg)](https://travis-ci.org/vancluever/aws-runas)
[![Gem Version](https://img.shields.io/gem/v/aws_runas.svg)](https://rubygems.org/gems/aws_runas)
[![Codecov](https://img.shields.io/codecov/c/github/vancluever/aws-runas.svg)](https://codecov.io/github/vancluever/aws-runas)

aws-runas
==========

[![asciicast](https://asciinema.org/a/107502.png)](https://asciinema.org/a/107502)

**The problem:** You manage AWS across several different roles and need to use
tools outside of the regular `aws-cli` toolchain.

**The solution:** Use `aws-runas` :)

Features
---------

There are a few other tools and shell scripts out there that do the same
thing, but there are some differentiators in this gem:

 * Support for your roles already laid out in `~/.aws/config`.
  * These roles can also be copied to a local `aws_config` file and pushed
    to source control to ensure your deployment targets live with source.
 * Support for single-run commands (supplied on the command line) or
   interactive shell sessions (by supplying no commands).
 * MFA will be auto-detected and only prompted for if necessary (allowing one
   to assume a role that does not have a MFA serial supplied).
 * Session tokens can be acquired without assuming a role by adding the
   appropriate `mfa_serial` into the `[default]` profile and running `aws-runas`
   with `--no-role`. Subsequent uses of `aws-runas` after this will not prompt
   you for MFA (useful for tooling that needs to assume multiple roles off the
   same session token).

How it Works
-------------

Roles are assumed, or session tokens are simply acquired (if `--no-role` is
specified) via the `AssumeRole` or the `GetSessionToken` AWS STS API calls.
After this, your command or shell is launched with the standard AWS credential
chain environment variables set:

 * `AWS_ACCESS_KEY_ID`
 * `AWS_SECRET_ACCESS_KEY`
 * `AWS_SESSION_TOKEN`

### Additional Variables

In addition to the above, two toolchain-local environment variables are set to
help you determine what credentials are in use locally:

 * `AWS_RUNAS_ASSUMED_ROLE_ARN` - set when a role is assumed (not set if
   `--no-role` is used)
 * `AWS_RUNAS_PROFILE` - set with the profile used when `aws-runas` was run
 * `AWS_REGION` and `AWS_DEFAULT_REGION` - set with the region name defined in
   the profile being used
 * `AWS_SESSION_EXPIRATION` - set with the expiry timestamp in UTC
 * `AWS_SESSION_EXPIRATION_UNIX` - set with the expiry timestamp in Unix time,
   useful for scripting

### Fancy Bash/Zsh Prompt

If you use `aws-runas` without any options and your default shell is Bash or
Zsh, a colorized prompt will appear with the profile that is in use if a role is
assumed, or a simple `(AWS)` indicator added to the prompt if a session token is
only obtained. See the video at the start of the doc for a demo!

#### Shell Integration Functions

2 functions currently get exported when you run under one of the two supported
shells:

 * `aws_session_expired`, which reads `AWS_SESSION_EXPIRATION_UNIX` (see above)
   and compares this with the current Unix timestamp supplied by `date`. It
   returns 0 on true and 1 on false, which can be used semantically in shell
   scripts.
 * `aws_session_status_color`, which works off of `aws_session_expired` to
   render either an ANSI color number (for bash)
   or a human readable color name (for zsh)
   - (red or 31) when `aws_session_expired` is `true`, (yellow or 33) otherwise.

#### Skipping the Fancy Prompt

If you are doing your own prompt customization based on aws-runas data and don't
want the prompt modified, you can supply `--skip-prompt` to skip the prompt
modification. The aforementioned integration functions will still be available
to you however, which you can use in your own scripts.

Usage
------

Install the gem (`gem install aws_runas`), and the command can be run via
`aws-runas` via your regular `$PATH`.

```
aws-runas: Run commands under AWS IAM roles

Usage:
  aws-runas [options] COMMAND ARGS

If COMMAND is omitted, the default shell ($SHELL, /bin/sh, or cmd.exe,
depending on your system) will launch.

[options] are:
  -n, --no-role        Get a session token only, do not assume a role
  -s, --skip-prompt    Do not launch interactive sessions with the fancy prompt
  -p, --path=<s>       Path to the AWS config file
  -r, --profile=<s>    The AWS profile to load (default: default)
  -h, --help           Show this message
```

`--path` is optional, and if omitted will default to the files in the
following order:

 * `aws_config`, in the current working directory
 * `~/.aws/config`, in your user directory.


Usage on Windows
-----------------

`aws_runas` works on Windows platforms, but YMMV. The gem has been tested
lightly on Cygwin and MSYS. Cygwin works great if you use the self-contained
Ruby ecosystem. Operating on MSYS or bare Windows will probably work as well as
any other Ruby gem. Running on WSL has not been tested, but as long as you can
get the minimum required Ruby version on it (currently >= 2.2.6), it should
generally work.

### OpenSSL Cert Bundle for Windows

Running `aws-runas` on native Windows may require the installation of a CA
certificate bundle. To do this, you will need to get the certificate bundle from
somewhere like [here](http://curl.haxx.se/docs/caextract.html) and set your
`SSL_CERT_FILE` environment variable to go to the file.


Author
-------

Chris Marchesi <chrism@vancluevertech.com>

License
--------

```
Copyright 2015-2017 Chris Marchesi

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
