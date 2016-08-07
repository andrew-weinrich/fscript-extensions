#!/Users/sphercow/fscript/build/Debug/fscript

sys out println:(sys scriptName).
sys out println:(sys args join:' ').

testString := 'This is a test string'.


(testString matches:'test') ifTrue:[
    sys out println:'Success!'.
]
ifFalse:[
    sys out println:'Failure!'.
].


replacedString := testString replace:'test' with:'mess'.
sys out println:replacedString.

stringTwo := 'Another test string' replace:'test ' with:'fessed'.
sys out println:stringTwo.


stringTwoA := 'Backreference test' replace:'t(\\w+)t' with:'(Captured "t(\\w+)t": \'$1\')'.
sys out println:stringTwoA.




stringThree := '12+13, 45+2, 10+200'.
sys out println:'Original string: ' ++ stringThree.

sys out println:'Replaced string: ' ++ (stringThree replace:'(\\d+)\\+(\\d+)'
    withBlock:[ :group :pat1 :pat2 |
        pat1 intValue + pat2 intValue
    ]).
