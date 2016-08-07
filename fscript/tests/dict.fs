file := FSFile open:(sys args objectAtIndex:0).

lines := [ :line | line split:' *= *' ] value: (file readlines).

config := NSMutableDictionary dictionaryWithPairs:lines.

out println:(config description).
out newln.

file reset.
keysAndValues := (file readlines join:'\n') split:' *= *|\n'. 

out println:(keysAndValues description).

config2 := NSMutableDictionary dictionaryWithFlatPairs:keysAndValues.
out println:(config2 description).
