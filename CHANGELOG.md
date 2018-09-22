## v0.7.0

* Version now can be printed by supplying --version.
* The gem now uses [Optimist][ref-optimist], and as such should no longer give
  deprecation warnings for its previous name.
  [#21](https://github.com/vancluever/aws-runas/issues/21)
* Corrected an issue with session ID generation when the calculated new
  long-from session ID exceeded 64 characters. In this situation, the session
  name will fall back to the default generic timestamped ID.
  [#17](https://github.com/vancluever/aws-runas/issues/17)
* When calling from an assumed role, the session ID now takes on the name of the
  access key ID instead of the account ID and user name. This should help
  prevent length or session name nesting issues, while still making the session
  name useful. [#17](https://github.com/vancluever/aws-runas/issues/17)

## v0.6.0

### Session Duration Support

This update brings the `--duration` flag, which allows you to control the
session duration for both session tokens and assumed roles. Note that the
maximum depends on what kind of user you are using (IAM versus root account),
whether or not you are assuming a role or not, and the maximum duration set on
any role that you are assuming. `aws-runas` may silently truncate the maximum if
you request it too high, although your session will be rejected when assuming a
role. For more details, see [GetSesionToken][get-session-token] and
[AssumeRole][assume-role] for more details.

[get-session-token]: https://docs.aws.amazon.com/STS/latest/APIReference/API_GetSessionToken.html
[assume-role]: https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html

Thanks to the work done in
[#16](https://github.com/vancluever/aws-runas/pull/16) for this!

### Zsh `PROMPT` Support

Some issues were discovered where the zsh prompt support was not functioning
correctly when using shell functions. Colors were not rendering properly as
well. Thanks to the work in
[#14](https://github.com/vancluever/aws-runas/pull/14) for the fix on this!

### Better Session IDs

`aws-runas` will now expose the IAM user's identity information (account ID/user
name) and enter it in the session ID, when available. The new format is
`aws-runas-session_ACCTID_USERNAME_TIMESTAMP` when the user has access to
[`GetCallerIdentity`][get-caller-identity], and the old
`aws-runas-session_TIMESTAMP` format when they do not.

Thanks to the work done in
[#11](https://github.com/vancluever/aws-runas/pull/11) for this!

[get-caller-identity]: https://docs.aws.amazon.com/STS/latest/APIReference/API_GetCallerIdentity.html

## v0.5.0

### Zsh Support

`zsh` is now supported for the fancy prompt. When using the shell, your
existing profile data from `.zshrc` will be copied over into the temporary
configuration.

### Additional Functionality for Bash and Zsh

2 additional functions are available for `bash` and `zsh` as well:

 * `aws_session_expired`, which reads `AWS_SESSION_EXPIRATION_UNIX` (see below)
   and compares this with the current Unix timestamp supplied by `date`. It
   returns 0 on true and 1 on false, which can be used semantically in shell
   scripts.
 * `aws_session_status_color`, which works off of `aws_session_expired` to
   render an ANSI numeric color code - red when `aws_session_expired` is `true`,
   yellow otherwise.

The prompts for `bash` and `zsh` now work off of these functions to render the
right color. The prompt will go red when the session has expired.

### Skip Fancy Interactive Prompt

The default interactive prompt that you get when you run `aws-runas` with no
command supplied can now by skipped by adding `--skip-prompt` to the CLI
arguments. The profile functions mentioned above are still passed in. This
allows you to leverage their functionality inside your own scripts and custom
prompts if you want in other ways.

### Additional Variables

Several environment variables have been added for more quality-of-life when
working in the shell or aware tools:

 * `AWS_REGION` and `AWS_DEFAULT_REGION`, which pass through the region
   configured in the profile, if present
 * `AWS_SESSION_EXPIRATION` and `AWS_SESSION_EXPIRATION_UNIX` to supply the
   session expiration time, in both human and UNIX timestamps, respectively
   named.

## v0.4.2

The role that aws-runas assumed and the profile it used are now exposed as
`AWS_RUNAS_ASSUMED_ROLE_ARN` and `AWS_RUNAS_PROFILE`, respectively. These can be
used in scripts to track the profile being used or the role ARN used, in case
this data is needed later, or for troubleshooting purposes.

## v0.4.1

Fixed the escape sequence in the bash shell prompt indicator so that it has the
`\[` and `\]` enclosures - this fixes issues that the prompt was having with
line wrapping.

## v0.4.0

 * Dropping support for Ruby 2.1. You will need at least Ruby 2.2.6 to be using
   this gem now. If you have a version below this, please use a v0.3.x version.
 * MFA entry is no longer hidden from the terminal - you will see the digits you
   enter now.
 * Added a special indicator to `bash` prompts when running interactively. This
   prompt displays your running profile, like so: `(AWS:default)`. When running
   via --no-role, the indicator is just `(AWS)`. This should help to distinguish
   any AWS shells you may be running from regular ones.

## v0.3.1

This update sets `AWS_SDK_CONFIG_OPT_OUT` before the `aws-sdk` Ruby gem is
loaded to start assuming roles, to disable newer AWS Ruby SDK functionality that
allows the assumption of roles from `~/.aws/config` directly through the
toolchain. This conflicts with `aws-runas`'s own config file handling and breaks
in scenarios where one may want a default `~/.aws/config` file but no
credentials (ie: instance profiles).

## v0.3.0

Add session only features:

 * Add the `--no-role` command to load a profile and just get a
   session token, instead of assuming a role.
 * Changed default behaviour so that if `AWS_SESSION_TOKEN` exists, no MFA
   is loaded - this allows the assumption of multiple roles from within
   the same session.
 * `--no-role` will fail if a MFA serial is not present (it's pretty much
   useless - you will just be getting a session for the same access
   key/secret key with the same level of privilege that you did before).


## v0.2.0

 * `$SHELL` is now supported - if this environment variable exists, the shell
   in it will be launched.
 * Windows support:
  * `cmd.exe` is set as the default shell on non-Cygwin Windows systems.
  * Fixes to support mingw32 such as IO flushing and detection of a lack of
    `noecho` support.

## v0.1.3

 * Fixed #3 (better handling of invalid profile name).
 * Added guard for invalid file as well.

## v0.1.2

 * Fixed #1 and #2 (default credentials fallback bug and overzealous version
   restrictions).
