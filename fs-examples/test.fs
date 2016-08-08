args := sys args. 
(args count > 0) ifTrue: [ [:arg | sys out println:arg] value: @ args]    ] ifFalse: [ sys out println: 'No args' ].