# edc[.]sh

*ed and dc shell wrapper project*

I wanted to extend ed, but without rewriting it, and start with commands
to format paragraphs (like `!}fmt` in vi); in addition, the script should
contain a dc wrapper comparable to my [wrapdc][1] script.

However, not all ed's are made equal, and so this script currently does
not work on systems where ed is requiring a tty to work.  Therefore this
project is stalled, until I have a better idea how to interface the
wrapper script and ed.

---

[1]: git://dome.circumlunar.space/~hb9kns/wrapdc.git or github.com/hb9kns/wrapdc

*(2019-2-17 // Yargo/HB9KNS)*
