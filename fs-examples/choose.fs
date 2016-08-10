args := sys args.

"
(args = 'asdf') - returns an array of booleans
\#| - reduces the array of booleans with the OR operator
"
((args = 'asdf') \#|) ifTrue:[
    sys out println:'Found asdf in args'.
]
ifFalse:[
    sys out println:'Didnt find asdf in args'.
].