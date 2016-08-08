(NSBundle bundleWithPath:'/Users/sphercow/FSClass/build/debug/FSClass.bundle') load.


Counter := FSClass newClass:'Counter'.
out print:'Coounter: '.
out println:Counter.
Counter addProperty:'counterVal'.
Counter onMessage:'init' do:
    [ :self | self setCounterVal:1 ].
Counter onMessage:'current' do:
    [ :self | self counterVal ].
Counter onMessage:'inc' do:
    [ :self | self setCounterVal:((self counterVal)+1). self ].




counter1 := Counter new.
counter2 := Counter alloc init.
out print:'counter1: '.
counter1 == nil ifTrue:[
    out println:'counter1 is nil'.
].
out println:counter1.

counter1 inc.
counter2 inc.
counter1 inc.


out println:counter1.

out println:('counter1: ' ++ ((counter1 current) description)).
out println:('counter2: ' ++ (counter2 current)).

