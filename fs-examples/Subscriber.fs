"
This class implements messages for saving and restoring encrypted data stores.
"


sys import:'Dictionary'.

Subscriber := FSClass newClass:'Subscriber' properties:{'name', '_subscriptions', 'key', 'active'}.


Subscriber onMessage:#initWithName:key: do:[ :self :name :key |
    self init.
    self setName:name; setKey:key; setActive:false; set_subscriptions:(NSMutableSet set).
    self.
].

Subscriber onMessage:#initWithName: do:[ :self :name |
    self initWithName:name key:nil.
].


Subscriber onMessage:#initWithNewKeyAndName: do:[ :self :name |
    self initWithName:name key:(RSAKeyPair alloc initWithNewKeyOfDefaultSize).
].



"Subscription management"
Subscriber onMessage:#addSubscription: do:[ :self :subName |
    self _subscriptions addObject:subName.
].

Subscriber onMessage:#isSubscribedToFeed: do:[ :self :subName |
    self _subscriptions containsObject:subName.
].

Subscriber onMessage:#removeSubscription: do:[ :self :subName |
    self _subscriptions removeObject:subName.
].

Subscriber onMessage:#subscriptions: do:[ :self :subName |
    self _subscriptions allObjects.
].



"Encoding / decoding methods"
Subscriber onMessage:#encodeWithCoder: do:[ :self :encoder |
    encoder encodeObject:(self key) forKey:'key'.
    encoder encodeObject:(self _subscriptions) forKey:'subscriptions'.
    encoder encodeObject:(self active) forKey:'active'.
    encoder encodeObject:(self name) forKey:'name'.
].

Subscriber onMessage:#initWithCoder: do:[ :self :coder |
    self setName:(coder decodeObjectForKey:'name').
    self setActive:(coder decodeObjectForKey:'active').
    self setKey:(coder decodeObjectForKey:'key').
    self set_subscriptions:(coder decodeObjectForKey:'subscriptions').
    
    self
].


Subscriber onMessage:#description do:[ :self |
    'Subscriber:{\n'++
    '    Name: '++self name++'\n'++
    '    Subscriptions: '++self _subscriptions description++'\n'++
    '    Key: '++self key description++'\n'++
    '}'
].

