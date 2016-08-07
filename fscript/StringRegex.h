//
//  StringRegex.h
//  FSInterpreter
//
//  Created by Andrew Weinrich on 11/21/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FSRegex.h>
#import <FScript/Block_fscript.h>
#import <FScript/FSBoolean.h>
#import <Foundation/NSString.h>


/*! 
@category NSString(StringRegex)
@abstract Addition of regular expressions operations to the <span class="class">NSString</span> class
@discussion This category adds regular expressions to strings, similar to the functionality built into languages like Perl and Python. It uses version 7.4 of the <a href="http://www.pcre.org/">Perl-Compatible Regular Expressions library</a> as the engine, and an adapted version of the <a href="http://sourceforge.net/projects/agkit/">AGRegex framework</a> as an Objective-C wrapper.
*/
@interface NSString (StringRegex)

/*!
@method split:
 Like the <code>split</code> function in Perl, this method separates a string into components, using a regular expression to identify the separators (instead of a plain string, as the <span class="class">NSString</span> method <span class="method">componentsSeparatedByString:</span> does). Returns an array containing the components.
 */
- (NSArray*) split:(NSString*)pattern;



/*!
@method matches:
Returns true if the receiver matches the supplied regular expression. The Perl code

<div class="longexample"><pre>@textblock
$string = ".....";
if ($string =~ /pattern/) {
    ....
}
@/textblock</pre></div>

can be expressed in F-Script as:

<div class="longexample"><pre>@textblock
string := '.....'.
(string matches:'pattern') ifTrue:[
    ....
].
@/textblock</pre></div>
 */
- (FSBoolean*) matches:(NSString*)pattern;







/*!
@method replace:with:
Replaces all occurrences of <span class="parameter">pattern</span> in the receiver with <span class="parameter">replacementString</span>. Subpatterns captured with parentheses are available using the notation <code>$1</code>, <code>$2</code>, etc. (<span class="literal">$0</span> refers to the entire match). Python-style named captures are also available. For more information, see the <a href="http://www.pcre.org">PCRE documentation</a>.

The Perl code <code>string =~ s/pa(tt)ern/replacement$1/g;</code> can be expressed in F-Script as: <code>string := string replace:'pa(tt)ern' with:'replacement$1'.</code>. The assignment is necessary because the original string is not directly modified, as it is in Perl.
*/
- (NSString*) replace:(NSString*)pattern with:(NSString*)replacementString;


/*!
@method replace:withBlock:
Similar to the <code>s///x</code> replacement operator in Perl, this method executes an F-Script block for every match of the pattern in the receiver, supplying the match and subpatterns to the block as arguments. The first argument is the entire match, and subpatterns are passed as the subsequent arguments. If the block does not accept the same number of arguments as there are subpatterns in the regular expression, the F-Script intepreter will throw an exception.

The entire match is the original string is then replaced with the return value of the block. The return value does not have to be an <span class="class">NSString</span>; if another object (such as an <span class="class">NSNumber</span>) is returned, the <span class="method">description</span> method will be used to obtain a string value to use as a replacement.

The following code will replace all pairs of integers separated with a plus sign in a string with their sums:

<div class="longexample"><pre>@textblock
string := '12+13, 45+2, 10 + 200'.

string := string replace:'(\\d+)\\s*\\+\\s*(\\d+)' withBlock:[ :group :pat1 :pat2 |
    pat1 intValue + pat2 intValue
].

"string is now '25, 47, 210'"
 @/textblock</pre></div>
 */
- (NSString*) replace:(NSString*)pattern withBlock:(Block*)block;






/*!
@method captures:
Returns an array of subpattern matches from the first match of the pattern in the string. The entire matched portion will be the first element in the array. Using this method, the following Perl code:

<div class="longexample"><pre>@textblock
$string =~ /(\d+) +(\w+)/);
my $word = $1;
my $number = $2;
@/textblock</pre></div>

can be reproduced in F-Script as the following:

<div class="longexample"><pre>@textblock
subpatterns := string captures:'(\\d+) +(\\w+)'.
word := subpatterns at:1.
number := subpatterns at:2.
@/textblock</pre></div>

Any subpatterns that were not captured (such as groupings made optional with the <code>?</code> modifier) will be returned as empty strings in the array. If the string did not match the pattern at all, this method will return <span class="literal">nil</span>.

If you want to find all the matches of the pattern in the string, or need to access named subpatterns, use the <span class="method">allMatches:</span> method instead.
*/
- (NSArray*) captures:(NSString*)pattern;



/*!
@method allCaptures:
Returns all the captures of the specified pattern in the string. Each element of the array is an FSRegexMatch object; these objects can be queried for specific captured subpatterns. If you know that the pattern will only match once, and you are not using named subpatterns, the method <span class="method">captures:</span> will be more convenient
*/
- (NSArray*) allCaptures:(NSString*)pattern;




@end
