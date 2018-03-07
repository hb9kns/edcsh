#!/bin/sh
info='edc.sh // 2018-3-6 Y.Bonetti // https://github.com/hb9kns/edcsh'
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

edeprompt=::
ede () { echo $edeprompt "$*" >&2 ; }

if ! mkfifo $edcp
then ede cannot mkfifo $edcp
 exit 1
else ede opened edcpipe:
 ls -l $edcp
fi

if test -r "$conf"
then ede sourcing config file "$conf"
 . "$conf"
else ede default config due to unreadable config file "$conf"
fi

rm -f $edcp
