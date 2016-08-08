#!/usr/bin/fscript


selectors := { #+, #/, #*, #min:, #max: }.

numbersA := { 1, 2, 3, 4, 5, 6 }.
numbersB := { 4, 5, 6, 7, 8, 9 }.

"demonstrates how to use each binary operator with two array elements"
[ :selector |
    out print:selector.
    out print:': '.
    out print:(numbersA \ selector).
    out print:', '.
    out print:(numbersA @ performSelector:selector withObject: @ numbersB).
   
    out newln.
]
value: @ selectors.

"Demonstrates how to reduce an array (ie [1 2 3] \+ -> 1 + 2 + 3)"
out println:(([ :selector |
    selector description ++ ' : ' ++
    (numbersA \ selector) description ++ ', ' ++
    (numbersA @ performSelector:selector withObject: @ numbersB) description
]
value: @ selectors) join:'\n').
