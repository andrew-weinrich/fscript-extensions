#!/usr/bin/fscript

props := NSDictionary dictionaryWithContentsOfFile:'testprefs.plist'.

"turn the dictionary into an actual class"
PropClass := FSClass newClass.
PropClass addProperty:'garrr' withDefault:10.
PropClass addPropertiesFromDictionary:props.

proper := PropClass alloc init.

out println:(proper prop1).

