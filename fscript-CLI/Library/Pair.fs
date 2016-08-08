"
    This file shows how we can add behavior to the entire universe of
    Cocoa objects, using an F-Script category on NSObject
"


"Create a simple Pair class"
Pair := FSClass newClass:'FSPair' properties:{'first', 'second'}.
Pair onClassMessage:#pair:with: do:[ :self :first :second | |newPair|
    newPair := self alloc init autorelease.
    newPair setFirst:first; setSecond:second.
    newPair
].

"Simple description: (obj1, objc2)"
Pair onMessage:#description do:[ :self |
    '(' ++ self first description ++ ', ' ++ self second description ++ ')'
].

"Add a pairing operator to NSObject, and thus to every other class"
NSObjectProxy := FSClass proxyForClass:NSObject.
NSObjectProxy onMessage:#operator_equal_greater: do:[ :self :second |
    Pair pair:self with:second.
].


"Now we can pair any two objects together"
myPair := 1 => 5.

"Prints '(1, 5)'"
description := myPair description.

"Like Foundation collection objects, Pairs are heterogeneous"
myMixedPair := 'hello!' => 5.

nil.