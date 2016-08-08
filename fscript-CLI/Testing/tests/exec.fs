#!/usr/bin/fscript

myList := sys exec:'ls' args:{} input:nil.
out print:myList.

out newln; newln.

myCat := sys exec:'cat' args:{} input:'Test catted data'.
out print:myCat.

out newln.

"status := sys execNoOutput:'/bin/bash' args:{'$LS','/', '>/Users/sphercow/Desktop/fstest/lsout.out'}"
sys exec:'/bin/bash' args:nil input:'$LS / >lsout.out'.

