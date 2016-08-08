NSStringProxy := FSClass proxyForClass:NSString.

borkPairs := NSDictionary dictionaryWithFlatPairs:{
    'w', 'v',
    'o', 'u'
}.

NSStringProxy onMessage:#bork do:[ :self | |copy|
    copy := self replace:'W' with:'V'.
    copy := copy replace:'w' with:'v'.
    copy := copy replace:'o' with:'oo'.
    copy
].

out println:('Hello world!' bork).