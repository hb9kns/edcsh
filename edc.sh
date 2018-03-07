#!/bin/sh
info='edc.sh // 2018-3-7 Y.Bonetti // https://github.com/hb9kns/edcsh'
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
edcprompt=edc:
ede () { echo $edeprompt "$*" >&2 ; }

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

doed () {
 $edbin $edopts "$@" <$edcp
}

doed "$filen" &
pided=$!
ps -p $pided | grep -F "$pided"

while ( ps -p $pided | grep -F "$pided" >/dev/null 2>&1 )
do read -p "$edcprompt" c1 cr
 case $c1 in
 Quit) echo 'q!' >>$edcp ;;
 *) echo "$c1 $cr" >>$edcp ;;
 esac
done

rm -f $edcp
