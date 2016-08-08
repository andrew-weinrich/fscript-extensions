#!/usr/bin/fscript

Rectangle := FSClass newClass:'Rectangle'.
Rectangle addProperty:'width'.
Rectangle addProperty:'height'.
Rectangle onMessage:#area do:[ :self |
    (self height) * (self width)
].

Rectangle onMessage:#perimeter do:[ :self |
    (self height * 2) + (self width * 2).
].

Square := FSClass newClass:'Square' withParent:Rectangle.
Square onMessage:#initWithSize: do:[ :self :size |
    self setWidth:size.
    self setHeight:size.
    self
].

Square onMessage:#area do:[ :self |
    self width raisedTo:2
].

Square onMessage:#perimeter do:[ :self |
    self width * 4
].

"If the user creates a rectangle with equal sides, secretly
return a Square instead"
Rectangle onMessage:#initWidth:height: do:[ :self :width :height |
    (width = height) ifTrue:[
        Square alloc initWithSize:width
    ]
    ifFalse:[
        self setWidth:width.
        self setHeight:height.
        self
    ]
].

"This line creates a Rectangle"
rect1 := Rectangle alloc initWidth:4 height:5.

"This line actually creates a Square"
rect2 := Rectangle alloc initWidth:4 height:4.

out println:rect1.
out println:rect2.