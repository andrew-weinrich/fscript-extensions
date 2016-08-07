
[ out print:'Enter some text: '.
  "myLine := in readlnWithSeparator:':'."
  myLine := in readln.
  (myLine isEqualToString:'xyzzy') ifTrue:[
      true
  ]
  ifFalse:[
      out println:myLine.
      false
  ]
] whileFalse.

out println:'Enter text, Control-D to stop'.
sys foreach:[ in readln ] do:[ :line |
    out println:line.
].

