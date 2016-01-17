aws_runas CHANGELOG
====================

0.2.0 (Sat Jan 16 23:44:56 PST 2016)
-------------------------------------

 * `$SHELL` is now supported - if this environment variable exists, the shell
   in it will be launched.
 * Windows support:
  * `cmd.exe` is set as the default shell on non-Cygwin Windows systems.
  * Fixes to support mingw32 such as IO flushing and detection of a lack of
    `noecho` support.

0.1.3 (Fri 27 Nov 2015 08:05:45 PST)
-------------------------------------

 * Fixed #3 (better handling of invalid profile name).
 * Added guard for invalid file as well.

0.1.2 (Wed 25 Nov 2015 09:09:09 PST)
-------------------------------------

 * Fixed #1 and #2 (default credentials fallback bug and overzealous version
   restrictions).
