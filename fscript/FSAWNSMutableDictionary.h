//
//  FSNSMutableDictionary.h
//  fscript
//
//  Created by Andrew Weinrich on 1/12/07.
//

#import <Foundation/Foundation.h>


/*!
@category NSMutableDictionary(FSNSMutableDictionary)
@abstract The FSNSMutableDictionary category adds class methods to NSMutableDictionary that make it easier to create dictionaries from arrays
*/
@interface NSMutableDictionary (FSAWNSMutableDictionary)


/*!
@method dictionaryWithPairs:
@discussion Creates a dictionary from <span class="parameter">pairs</span>, which must be an array of arrays, each second-level array containing exactly two elements (the key and value). For example, say that you need to read a configuration file that is in the format <code>keyName = value</code>. The following code will create a dictionary that holds the configuration:

<div class="longexample"><pre>@textblock
file := FSFile open:'....'.

lines := [ :line | line split:' += +' ] value: (file readlines).

config := NSMutableDictionary dictionaryWithPairs:lines.
@/textblock</pre></div>
*/
+ (NSMutableDictionary*) dictionaryWithPairs:(NSArray*)pairs;

/*!
@method dictionaryWithFlatPairs:
@discussion Like <span class="method">dictionaryWithPairs:</span>, but assumes that <span class="method">flatPairs</span> is a one-dimensional array that holds alternating keys and values. The following (contrived) code is equivalent to the example for <span class="method">dictionaryWithPairs:</span>:
 
<div class="longexample"><pre>@textblock
configDataString := '.......'

"Split configuration apart on either newline or delimiter "
keysAndValues := configDataString split:' += +|\n'. 

config := NSMutableDictionary dictionaryWithFlatPairs:keysAndValues.
@/textblock</pre></div>

This method is similar to <span class="class">NSDictionary</span> <span class="method">dictionaryWithKeysAndObjects:</span>, except that that method uses C variadic argument lists rather than an <span class="class">NSArray</span>.
*/
+ (NSMutableDictionary*) dictionaryWithFlatPairs:(NSArray*)flatPairs;


@end
