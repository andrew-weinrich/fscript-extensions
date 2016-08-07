#!/usr/bin/fscript

myFile := FSFile open:'/Users/sphercow/Desktop/fstest/input.test'.
"myFile3 := FSFile open:'/Users/sphercow/Desktop/input_NONEXIST.test' mode:'<'."

"FSfile dothing."

"FSFile dothing."


"myThing := ForEach init alloc."
sys log:'Okay!'.

sys foreach:[ myFile readln ] do:[ :line |
    out println:line.
].

out print:'First argument: '.
out println:(args objectAtIndex:0).

myFile2 := FSFile open:(args objectAtIndex:0) mode:'<'.
"myFile2 := FSFile open:'/Users/sphercow/Desktop/fstest/input2.test'."

out println:(myFile2 readlnWithSeparator:':').
out println:(myFile2 readlnWithSeparator:':').
out println:(myFile2 readlnWithSeparator:':').


"
myLine := ' '.

[ (myLine length) > 0 ]
whileTrue:[
    myLine := myFile readln.
    out println:myLine.
]
"