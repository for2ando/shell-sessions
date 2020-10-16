## A session command library for Bourne shells
## usage:
##   source session.sh && login_session  # in .bash_profile etc.
##   logout_session  # in .bash_logout etc.
##   # You have to write scripts: ~/.attach_session, ~/.detach_session,
##   #   ~/.attach_session.d/* and .detach_session.d/* for your shell.
## Each element of SESSIONNAMES (which is a session name) must not includes any space characters.

## initialize this library
##

SESSION_D="$HOME/sessions.d"
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
  touch "$SESSION_D/$name"
  test -r "$HOME/.attach_session" && . "$HOME/.attach_session"
  for script in "$HOME/.attach_session.d"/*
  do
    test -r "$script" && . "$script"
  done
}

detach_session() {
  name="$1"
  for script in "$HOME/.detach_session.d"/*
  do
    test -r "$script" && . "$script"
  done
  test -r "$HOME/.detach_session" && . "$HOME/.detach_session"
  rm -f "$SESSION_D/$name"
  unset TTYN
}

search_unattached_session() {
  for name in $SESSIONNAMES
  do
    session_attached $name || {
      echo -n $name
      return 0
    }
  done
  return 1
}

## public functions
##

login_session() {
  test -z "$TTYN" && {
    name=`search_unattached_session` || return 1
  }
  attach_session $name
}

logout_session() {
  detach_session $TTYN
}

