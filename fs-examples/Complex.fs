ComplexNumber := FSClass getClass:'ComplexNumber'.
(ComplexNumber == nil) ifTrue:[
    ComplexNumber := FSClass newClass:'ComplexNumber'.

    ComplexNumber addProperty:'_real' withDefault:0.0.
    ComplexNumber addProperty:'_imaginary' withDefault:0.0.
].



ComplexNumber onClassMessage:#complexNumberWithReal:imaginary: do:[ :class :real :imaginary || instance |
    instance := ComplexNumber create.
    instance set_real:real; set_imaginary:imaginary.
    instance
].

ComplexNumber onMessage:#real do:[ :self  |
    self _real
].


ComplexNumber onMessage:#imaginary do:[ :self  |
    self _imaginary
].



"Accessor methods for polar coordinates"
ComplexNumber onMessage:#theta do:[ :self |
    (self real / self imaginary) arcTan
].

ComplexNumber onMessage:#radius do:[ :self |
    ((self imaginary raisedTo:2) + (self real raisedTo:2)) sqrt
].

"Complex conjugate"
ComplexNumber onMessage:#conjugate do:[ :self |
    ComplexNumber complexNumberWithReal:(self real) imaginary:(self imaginary negated)
].



ComplexNumber onMessage:#operator_plus: do:[ :self :rhs |
    (rhs isKindOfClass:(NSNumber class)) ifTrue:[
        ComplexNumber complexNumberWithReal:(self real + rhs)
            imaginary:(self imaginary)
    ]
    ifFalse:[
        (rhs isKindOfClass:(ComplexNumber class)) ifTrue:[
            ComplexNumber complexNumberWithReal:(self real + rhs real)
                imaginary:(self imaginary + rhs imaginary)
        ]
        ifFalse:[
            'Second argument supplied to ComplexNumber operator_plus: is not an NSNumber or ComplexNumber' throw
        ]
    ]
].


ComplexNumber onMessage:#operator_hyphen: do:[ :self :rhs |
    (rhs class == self class) ifFalse:[
        'Second argument supplied to ComplexNumber operator_plus: is not a ComplexNumber' throw
    ]
    ifTrue:[
        ComplexNumber complexNumberWithReal:(self real - rhs real)
            imaginary:(self imaginary - rhs imaginary)
    ]
].


ComplexNumber onMessage:#operator_asterisk: do:[ :self :rhs |
    (rhs class == self class) ifFalse:[
        'Second argument supplied to ComplexNumber operator_asterisk: is not a ComplexNumber' throw
    ]
    ifTrue:[
        "Formula: (a+bi)*(c+di) = (ac-bd)+i(ad+bc)"
        ComplexNumber complexNumberWithReal:((self real * rhs real) - (self imaginary * rhs imaginary))
            imaginary:((self real * rhs imaginary) + (self imaginary * rhs real))
    ]
].


ComplexNumber onMessage:#operator_slash: do:[ :self :rhs |
    (rhs isKindOfClass:(NSNumber class)) ifTrue:[
        ComplexNumber complexNumberWithReal:(self real / rhs)
            imaginary:(self imaginary / rhs)
    ]
    ifFalse:[
        (rhs isKindOfClass:(ComplexNumber class)) ifTrue:[ | denominator |
            "Formula: (a+bi)/(c+di) = ((ac+bd)+i(bc-ad))/(c^2 + d^2)"
            denominator := (rhs real raisedTo:2) + (rhs imaginary raisedTo:2).

            ComplexNumber complexNumberWithReal:(((self real * rhs real) + (self imaginary * rhs imaginary)) / denominator)
                imaginary:(((self imaginary * rhs real) - (self real * rhs imaginary)) / denominator)
        ]
        ifFalse:[
            'Second argument supplied to ComplexNumber operator_slash: is not an NSNumber or ComplexNumber' throw
        ]
    ]
].



"Equality comparison operator. Throws an error if the second argument is
not a complex number"
ComplexNumber onMessage:#operator_equal: do:[ :self :rhs |
    (rhs fsClass == ComplexNumber) ifFalse:[
        'Second argument supplied to ComplexNumber operator_equal: is not a ComplexNumber' throw
    ]
    ifTrue:[
        (self real = rhs real) & (self imaginary = rhs imaginary)
    ]
].



"Description method"
ComplexNumber onMessage:#description do:[ :self |
    (self imaginary >= 0.0) ifTrue:[
        '(' ++ self real description ++ '+' ++ self imaginary description ++ 'i)'
    ]
    ifFalse:[
        '(' ++ self real description ++ self imaginary description ++ 'i)'
    ]
].



nil