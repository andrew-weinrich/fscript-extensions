"proxyForClass returns a modifiable version of an Objective-C class"
NSStringProxy := FSClass proxyForClass:NSString.

"Add a new method to the (compiled, Objective-C) class"
NSStringProxy onMessage:#bork do:[ :self | |copy|
    copy := self replace:'W' with:'V'.
    copy := copy replace:'w' with:'v'.
    copy := copy replace:'o' with:'oo'.
    copy
].

"Prints 'Helloo voorld!'"
out println:('Hello world!' bork).