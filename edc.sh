#!/bin/sh
DEBUG=
info='edc.sh // 2018-3-9 Y.Bonetti // https://github.com/hb9kns/edcsh'

# configuration file
conf=${EDCRC:-$HOME/.edcrc}
# pipe for controlling ed
edcp=${TMPDIR:-/tmp}/edcpipe$$

# temporary files/buffers
tmp0=${TMPDIR:-/tmp}/edctmp$$-0
: > $tmp0
tmp1=${TMPDIR:-/tmp}/edctmp$$-1
: > $tmp1
tmp2=${TMPDIR:-/tmp}/edctmp$$-2
: > $tmp2

if test "$1" = ""
then cat <<EOH
usage: $0 file

opens file for editing with ed, processing additional wrapper commands
also for ec -- for more help, enter 'help' at the prompt!

(After issuing the 'q' command to ed, you may have to hit ENTER once more
for the script to finish.)

_( $info )_
EOH
 exit 0
fi

# following settings can be overridden by config file
edbin=/bin/ed
edprompt=:
edopts=-p$edprompt
edeprompt=::
chunks=yes
echo=no

# normal and debugging prompt
ede () { echo $edeprompt "$*" >&2 ; }
edd () { if test -n "$DEBUG" ; then echo $edeprompt DEBUG "$*" >&2 ; fi ; }

# install fifo/pipe for controlling ed
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

# function to start fifo-controlled ed
runed () { tail -s 0.2 -f $edcp | $edbin $edopts "$@" ; }

# function to send commands to ed
edex () {
 if test $echo = yes
 then ede ed command: "$@"
 fi
 echo "$@" > $edcp ;
}

# start ed with the arguments from edc.sh
runed "$@" &
# and keep PID
pided=$!
edd pided=$pided

# set ed to verbose mode if debugging
if test -n "$DEBUG"
then
 edex H
 ps -p $pided | grep -F "$pided"
fi

# loop while fifo/pipe still alive
while ps -p $pided >/dev/null
do
 edd `ps -p $pided|grep -F $pided`
 read cl
 case $cl in
 help) cat <<EOH >&2
 help : this text
 pi[pe] cmd range : pipe range through cmd, eg 'pi fmt .,.+8'
 undo : revert to text before most recent pi[pe] command
  (is its own inverse, causes harmless Invalid Address error for empty buffer)
EOH
 if test $chunks = yes
 then cat <<EOH >&2
 following commands will display big chunks of (modified) text:
  pi[pe]
EOH
 ede
 fi
 ;;
 pi*) echo "$cl" | { read _ cmd rng
  edex %w $tmp0
  edex $rng w $tmp1
  edex $rng d
  edex "!$cmd" "<$tmp1" ">$tmp2"
  if test $chunks = yes
  then sync
   cat $tmp2 >&2
   ede end of processed range
  fi
  edex .-r $tmp2
  }
 ;;
 undo)
  edex %w $tmp1
  edex %d
  edex 0r $tmp0
  cat $tmp1 >$tmp2
  cat $tmp0 >$tmp1
  cat $tmp2 >$tmp0
 ;;
 *) edd cl=$cl
  if ps -p $pided >/dev/null
  then edex "$cl"
  fi
 ;;
 esac
done

rm -f $edcp $tmp0 $tmp1 $tmp2
