#!/bin/sh
DEBUG=
info='edc.sh // 2018-3-8 Y.Bonetti // https://github.com/hb9kns/edcsh'
conf=${EDCRC:-$HOME/.edcrc}
edcp=${TMPDIR:-/tmp}/edcpipe$$
tmp0=${TMPDIR:-/tmp}/edctmp$$-0
tmp1=${TMPDIR:-/tmp}/edctmp$$-1
tmp2=${TMPDIR:-/tmp}/edctmp$$-2
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

runed () { tail -s 0.2 -f $edcp | $edbin $edopts "$@" ; }
edex () { echo "$@" > $edcp ; }

runed "$@" &
pided=$!
edd pided=$pided

if test -n "$DEBUG"
then
 edex H
 ps -p $pided | grep -F "$pided"
fi

while ps -p $pided >/dev/null
do
 edd `ps -p $pided|grep -F $pided`
 read cl
 case $cl in
 help) cat <<EOH
help for $0
 pi[q] cmd range : pipe range through cmd, eg 'pi fmt .,.+8'
  with q, don't display processed range
EOH
  ;;
 pi*) echo "$cl" | { read _ cmd rng
   if test -x $cmd
   then edex %w $tmp0
    edex $rng w $tmp1
    edex $rng d
    $cmd <$tmp1 >$tmp2
    cat $tmp2
    edex .-r $tmp2
   else ede cannot execute $cmd
   fi
   }
  ;;
 *) edd cl=$cl
  if ps -p $pided >/dev/null
  then edex "$cl"
  fi ;;
 esac
done

rm -f $edcp $tmp0 $tmp1 $tmp2
