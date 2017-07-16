# vim:filetype=sh
#
# aws_session_expired checks to see if the current session has expired, based
# off of the value stored in AWS_SESSION_EXPIRATION_UNIX. This functionality
# relies on date being in $PATH.
aws_session_expired() {
  if [[ "${AWS_SESSION_EXPIRATION_UNIX}" -lt "$(date +%s)" ]]; then
    return 0
  fi
  return 1
}

# aws_session_status_color returns an ANSI color number for the specific status
# of the session. Note that if session_expired is not correctly functioning,
# this will always be yellow. Red is shown when it's verified that the session
# has expired.
aws_session_status_color() {
  if aws_session_expired; then
    echo "31"
  else
    echo "33"
  fi
}
