"Create a class that directly represents a range of numbers"
Range := FSClass newClass:'Range' properties:{'start', 'end'}.
Range onClassMessage:#from:to: do:[ :self :from :to | |newRange|
    newRange := self alloc init autorelease.
    newRange setStart:from; setEnd:to.
    newRange.
].
Range onMessage:#asNSValue do:[ :self |
    NSValue rangeWithLocation:(self start) length:(self end - self start)
].


(FSClass proxyForClass:NSNumber) onMessage:#operator_less_hyphen_greater: do:[ :self :rhs |
    Range from:self to:rhs
].

(FSClass proxyForClass:Number) onMessage:#operator_less_hyphen_greater: do:[ :self :rhs |
    Range from:self to:rhs
].


nil