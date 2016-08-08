

(FSClass proxyForClass:NSDictionary) onMessage:#operator_hyphen_greater: do:[ :self :key |
    self objectForKey:key
].

(FSClass proxyForClass:NSMutableDictionary) onMessage:#set: do:[ :self :pair |
    self setObject:(pair first) forKey:(pair second).
].




dict := NSMutableDictionary dictionary.
dict set:('asdf'=>'5').

out println:('asdf: ' ++ (dict->'asdf')).
out println:('qwer: ' ++ (dict->'qwer')).


