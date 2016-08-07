//
//  StringSprintf.h
//  fscript
//
//  Created by Andrew Weinrich on 12/29/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//

#import <Foundation/Foundation.h>


/*! 
@category NSString(StringSprintf)
@abstract Implementation of <code>sprintf</code> for NSString
@discussion This category adds a single method, <span class="method">sprintf:</span>, that implements formatted strings in the manner of C's standard library function.
*/
@interface NSString (StringSprintf)

/*!
@method sprintf:
Implements the standard C function <code>sprintf</code>, using the receiver as the format string, and the elements of <span class="parameter">values</span> as values to format. Returns a new string containing the output. <span class="method">sprintf:</span> will throw an exception if too many or not enough values are supplied in the values argument.

The standard flags - <span class="literal">-</span>, <span class="literal">+</span>, <span class="literal">(space)</span>, and <span class="literal">#</span> are supported, as are the width and precision modifiers (including using <span class="literal">*</span> to indicate that the width should be taken from the next value in the array).

<span class="method">sprintf:</span> implements the following argument formats:

<dl class="list">
  <dt>s</dt>
    <dd>Interprets the value as a string, and sends it the message <span class="method">cStringUsingEncoding:</span><span class="literal">NSUTF8Encoding</span> to produce a character string. Note: unlike the standard C printf, width and precision modifiers for strings count the number of characters, not the number of bytes.</dd>
  <dt>&#64;</dt>
    <dd>Similar to the use of <span class="literal">%&#64;</span> in the NSString class method <span class="method">stringWithFormat:</span>. Sends the value a <span class="method">description</span> message and inserts that string into the output.</dd>
  <dt>e</dt>
  <dt>E</dt>
    <dd>Prints the result of <span class="method">doubleValue</span> in scientific notation. Uses the stdlib sprintf function.</dd>
  <dt>f</dt>
    <dd>Prints the result of <span class="method">doubleValue</span> as a floating-point number. Uses the stdlib sprintf function.</dd>
  <dt>i</dt>
  <dt>d</dt>
    <dd>Prints the result of sending <span class="method">intValue</span> to the receiver as a decimal integer.</dd>
  <dt>o</dt>
    <dd>Prints the result of sending <span class="method">intValue</span> to the receiver as an unsigned octal integer.</dd>
  <dt>x</dt>
  <dt>X</dt>
    <dd>Prints the result of sending <span class="method">intValue</span> to the receiver as an unsigned hexadecimal integer.</dd>
  <dt>c</dt>
    <dd>Interprets the value as an integer (using <span class="method">intValue</span) that represents a Unicode codepoint, and prints the corresponding character. This method uses F-Script's <span class="method">-[NSNumber unicharToString]</span> method.</dd>
  <dt>p</dt>
    <dd>Prints the pointer address of the value as an unsigned hexadecimal integer.</dd>
</dl>
The following standard formats are not supported:
<ul>
  <li><span class="method">g</span> - shortest of exponential or floating</li>
  <li><span class="method">u</span> - unsigned decimal integer</li>
  <li><span class="method">n</span> - return number of written characters</li>
</ul>
Additionally, the <span class="literal">h</span>, <span class="literal">l</span>, and <span class="literal">L</span> modifiers (used to indicate C's <code>short</code>, <code>long</code>, and <code>long double</code> data types) are not supported.
 */
- (NSString*) sprintf:(NSArray*)values;

@end
