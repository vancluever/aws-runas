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
