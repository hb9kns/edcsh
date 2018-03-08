#!/bin/sh
DEBUG=
info='edc.sh // 2018-3-8 Y.Bonetti // https://github.com/hb9kns/edcsh'
conf=${EDCRC:-$HOME/.edcrc}
edcp=${TMPDIR:-/tmp}/edcpipe$$
if test "$1" = ""
then cat <<EOH
usage: $0 file

opens file for editing with ed, processing additional wrapper commands
also for ec -- for more help, enter 'help' at the prompt!

_( $info )_
EOH
 exit 0
fi

edbin=/bin/ed
edprompt=:
edopts=-p$edprompt
edeprompt=::
ede () { echo $edeprompt "$*" >&2 ; }
edd () { if test -n "$DEBUG" ; then echo $edeprompt DEBUG "$*" >&2 ; fi ; }

if ! mkfifo -m 600 $edcp
then ede cannot mkfifo $edcp
 exit 1
else edd opened edcpipe:
 edd `ls -l $edcp`
fi

if test -r "$conf"
then ede sourcing config file "$conf"
 . "$conf"
else ede using defaults due to unreadable file "$conf"
fi

doed () { tail -s 0.2 -f $edcp | $edbin $edopts "$@" ; }

doed "$@" &
pided=$!
edd pided=$pided

if test -n "$DEBUG"
then
 echo H > $edcp
 ps -p $pided | grep -F "$pided"
fi

while ps -p $pided >/dev/null
do
 edd `ps -p $pided|grep -F $pided`
 read cl
 case $cl in
 help) cat <<EOH
help for $0
EOH
  ;;
 *) edd cl=$cl
  if ps -p $pided >/dev/null
  then echo "$cl" > $edcp
  fi ;;
 esac
done

rm -f $edcp
