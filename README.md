[![Build Status](https://img.shields.io/travis/vancluever/aws-runas.svg)](https://travis-ci.org/vancluever/aws-runas)
[![Gem Version](https://img.shields.io/gem/v/aws_runas.svg)](https://rubygems.org/gems/aws_runas)
[![Codecov](https://img.shields.io/codecov/c/github/vancluever/aws-runas.svg)](https://codecov.io/github/vancluever/aws-runas)

aws-runas
==========

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

Usage
------

Install the gem (`gem install aws-runas`), and the command can be run via
`aws-runas` via your regular `$PATH`.

```
aws-runas: Run commands under AWS IAM roles

Usage:
  aws-runas [options] COMMAND ARGS

If COMMAND is omitted, the default shell ($SHELL, /bin/sh, or cmd.exe,
depending on your system) will launch.

[options] are:
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
lightly on Cygwin and MinGW32, and if I needed to recommend one over the other,
I would recommend Cygwin.

If you want to use the gem on Windows without Cygwin, the following below may
be necessary:

### OpenSSL Cert Bundle for Windows

OpenSSL does not come pre-bundled on with a CA certificate bundle on non-Cygwin
Windows installations. To get this working with that, you will need to get
the certificate bundle from somewhere like [here](http://curl.haxx.se/docs/caextract.html)
and set your SSL_CERT_FILE environment variable to go to the file.


Author
-------

Chris Marchesi <chrism@vancluevertech.com>

License
--------

```
Copyright 2015 Chris Marchesi

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
