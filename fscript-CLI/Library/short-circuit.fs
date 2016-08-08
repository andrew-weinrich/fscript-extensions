"
    This file adds boolean operators to the Block class, making it possible
    to write short-circuiting if statements
"

BlockProxy := FSClass proxyForClass:Block.

"short-circuiting & operator"
BlockProxy onMessage:#operator_ampersand: do:[ :self :rhs |
    (self value) ifFalse:[
        false
    ]
    ifTrue:[
        rhs value
    ]
].

"short-circuiting & operator"
BlockProxy onMessage:#operator_bar: do:[ :self :rhs |
    (self value) ifTrue:[
        true
    ]
    ifFalse:[
        rhs value
    ]
].


"
    The non-shortcircuiting code
    
        (x isKindOfClass:(NSNumber class)) & ((x > 0) & (x < 10))
    
    will crash if x is not a number. We can rewrite it like this:
    
        [x isKindOfClass:(NSNumber class)] & [(x > 0) & (x < 10)]
    
    and the second condition will never be executed if the first fails.
"
