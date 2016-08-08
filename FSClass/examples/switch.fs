"
    This file shows how to create sophisticated, flexible language constructs
    using basic F-Script operators and FSClass categories. We will create 
"

"Note: this file requires the Pair class found in Pair.fs"
sys import:'Pair'.
sys import:'Range'.



"Our switch statement will compare the switch subject to the case values using the"
"matchForSwitch: method, which we'll add to the NSString, NSNumber, and Range classes"
(FSClass proxyForClass:NSString) onMessage:#matchForSwitch: do:[ :self :switchValue |
    self = switchValue
].

(FSClass proxyForClass:NSNumber) onMessage:#matchForSwitch: do:[ :self :switchValue |
    self = switchValue
].

(FSClass proxyForClass:Number) onMessage:#matchForSwitch: do:[ :self :switchValue |
    self = switchValue
].

Range onMessage:#matchForSwitch: do:[ :self :switchValue |
    (self start <= switchValue) & (switchValue <= self end)
].



"For more complicated switch conditions, we can add a matchForSwitch: statement to "
"the Block class. A Block can perform any computation it needs to, then return true or false"
(FSClass proxyForClass:Block) onMessage:#matchForSwitch: do:[ :self :switchValue |
    self value:switchValue.
].



"Make a special default label - the exact value does not matter, so"
" we can use an anonymous class to make sure there is only one instance of default"
"default will match against any and every value"
default := [ |DefaultClass|
    DefaultClass := FSClass newClass.
    DefaultClass onMessage:#matchForSwitch: do:[ :self :switchValue | true ].
    DefaultClass alloc init autorelease.
] value.




"We will create a single Block that implements the switch: method, then attach"
"it to the NSString and NSNumber classes, since those are the only data types for which"
"a switch: makes sense"


"switchBlock is a method on an object (self) that takes an array of pairs"
switchBlock := [ :self :cases | |testResults firstMatch|
    "Test against all cases - testResults gets an array of booleans"
    testResults := (cases first) at:((cases second) matchForSwitch:self).
    
    "If we didn't match anything, return nil"
    [ testResults length > 0 ] ifFalse:[
        nil
    ]
    "Otherwise, use the first match - we don't try to prevent multiple"
    "cases from matching"
    ifTrue:[ |firstMatch|
        firstMatch := testResults at:0.
        "if the block takes an argument, provide the switch value"
        [ firstMatch argumentCount = 0 ] ifTrue:[
            firstMatch value:self
        ]
        ifFalse:[
            "Otherwise, simply execute the block and return the value"
            firstMatch value.
        ]
    ]
].

(FSClass proxyForClass:NSNumber) onMessage:#switch: do:switchBlock.
(FSClass proxyForClass:Number) onMessage:#switch: do:switchBlock.
(FSClass proxyForClass:NSString) onMessage:#switch: do:switchBlock.



"--------------------------"




switchCases := {
    5           => [ '5 is right out' ],
    "If the block takes a single argument, the switch value will passed t it"
    6<->10      => [ :value | 'between 6 and 10: ' ++ value description ],
    11<->20     => [ 'between 6 and 10: '],
    42          => [ 'magic number!' ], 
    "We can use a block to perform more complicated comparisons"
    [ :switchValue | (switchValue mod:2) == 0 ] =>
        [ 'unknown even number' ],
    default     => [ 'none of the above' ]
}.


"Try the same cases on multiple values"
"
{1, 5, 7, 29, 42} foreach:[ :elem |
    out println:(elem switch:switchCases).
].
"
"
out println:('hello' switch:{
    'good morning'  => [ 'Ohaiyo gozaimasu!' ],
    'hello'         => [ 'Konichiwa!' ],
    'goodbye'       => [ 'Sayanora!' ],
    'default'       => [ 'Nani?' ]
}).
"
"out println:([ :value | switch given:value on:otherCases ] value:@{'good morning', 'goodbye', 'see you later'})."
"out println:result."





testValue := 17.

out println:([
    out println:'Hi'.
    testValue switch:{
        6       => [ 'value is 6' ],
        7<->10  => [ 'value is between 7 and 10: ' ++ testValue description ],
        42      => [ 'magic number!' ],
        default => [ 'matched nothing' ]
    }
] value).





nil.