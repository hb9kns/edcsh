#!/bin/sh
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

DEBUG=
edbin=/bin/ed
edprompt=:
edopts=-p$edprompt
edeprompt=::
edcprompt=edc:
ede () { echo $edeprompt "$*" >&2 ; }
edd () { if test -n "$DEBUG" ; then echo $edeprompt DEBUG "$*" >&2 ; fi ; }

if ! mkfifo -m 600 $edcp
then ede cannot mkfifo $edcp
 exit 1
else ede opened edcpipe:
 ede `ls -l $edcp`
fi

if test -r "$conf"
then ede sourcing config file "$conf"
 . "$conf"
else ede using defaults due to unreadable file "$conf"
fi

tail -s 0.2 -f $edcp | $edbin $edopts "$@" &
pided=$!
edd pided=$pided

if test -n "$DEBUG"
then
 echo H > $edcp
 ps -p $pided | grep -F "$pided"
fi

while ps -p $pided >/dev/null 2>&1
do
if test -n "$DEBUG"
then
 ps -p $pided | grep -F "$pided"
 printf '%s' "$?-$edcprompt"
fi
 read c1 cr
 case $c1 in
 Quit) echo 'q!' > $edcp
  kill -9 $pided
  ;;
 *) edd "c1=$c1 cr=$cr"
  echo $c1 $cr > $edcp ;;
 esac
done

rm -f $edcp
