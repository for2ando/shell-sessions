## A session command library for Bourne shells
## usage:
##   source session.sh && login_session  # in .bash_profile etc.
##   logout_session  # in .bash_logout etc.
##   # You have to write scripts: ~/.attach_session, ~/.detach_session,
##   #   ~/.attach_session.d/* and .detach_session.d/* for your shell.
## Each element of SESSIONNAMES (which is a session name) must not includes any space characters.

## initialize this library
##

SESSION_D="$HOME/.sessions.d"
export SESSION_D
SESSIONNAMES="`seq 1 16`"
export SESSIONNAMES

test -d "$SESSION_D" || mkdir -p "$SESSION_D"

## private functions (Don't call it directly)
##

session_attached() {
  name="$1"
  test -f "$SESSION_D/$name"
}

attach_session() {
  name="$1"
  TTYN=$name
  export TTYN
  tty >"$SESSION_D/$name"
  test -f "$HOME/.attach_session" && test -r "$HOME/.attach_session" && . "$HOME/.attach_session"
  for script in "$HOME/.attach_session.d"/*
  do
    test -f "$script" && test -r "$script" && . "$script"
  done
}

detach_session() {
  name="$1"
  for script in "$HOME/.detach_session.d"/*
  do
    test -f "$script" && test -r "$script" && . "$script"
  done
  test -f "$HOME/.detach_session" && test -r "$HOME/.detach_session" && . "$HOME/.detach_session"
  rm -f "$SESSION_D/$name"
  unset TTYN
}

search_attached_session() {
  curtty=$(tty)
  for session in "$SESSION_D"/*
  do
    test $(cat "$session") = "$curtty" && echo $(basename "$session") && return 0
  done
  return 1
}

search_unattached_session() {
  name=1
  while session_attached $name
  do
    name=$(expr $name + 1)
  done
  echo -n $name
  return 0
}

## public functions
##

login_session() {
  name=$(search_attached_session) || name=$(search_unattached_session) || return 1
  attach_session $name
}

logout_session() {
  detach_session $TTYN
}

