//
//  FSNSDictionaryPairs.h
//  fscript
//
//  Created by Andrew Weinrich on 2/9/07.
//  Copyright 2007 Andrew Weinrich. All rights reserved.
//

#import <Foundation/Foundation.h>


/*!
@category NSDictionary(FSNSDictionaryPairs)
 @abstract The FSNSDictionaryPairs category adds class methods to NSDictionary that make it easier to create dictionaries from arrays.
 */
@interface NSDictionary (FSNSDictionaryPairs)


/*!
@method dictionaryWithPairs:
@discussion Creates a dictionary from <span class="parameter">pairs</span>, which must be an array of arrays, each second-level array containing exactly two elements (the key and value). For example, say that you need to read a configuration file that is in the format <code>keyName = value</code>. The following code will create a dictionary that holds the configuration:

<div class="longexample"><pre>@textblock
file := FSFile open:'....'.

lines := [ :line | line split:' += +' ] value: (file readlines).

config := NSDictionary dictionaryWithPairs:lines.
@/textblock</pre></div>
*/
+ (NSDictionary*) dictionaryWithPairs:(NSArray*)pairs;

/*!
@method dictionaryWithFlatPairs:
@discussion Like <span class="method">dictionaryWithPairs:</span>, but assumes that <span class="method">flatPairs</span> is a one-dimensional array that holds alternating keys and values. This makes it easy to initialize a dictionary from an array, in the manner of Perl::
 
<div class="longexample"><pre>@textblock
myDictionary := NSDictionary dictionaryFromPairs:{ 'key1', item1, 'key2', 'item2', 'key3', 3 }.
@/textblock</pre></div>

This method is similar to <span class="class">NSDictionary</span> <span class="method">dictionaryWithKeysAndObjects:</span>, except that this method uses an <span class="class">NSArray</span> rather than C variadic argument lists, which are not valid in F-Script.
*/
+ (NSDictionary*) dictionaryWithFlatPairs:(NSArray*)flatPairs;

@end
