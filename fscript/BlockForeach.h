//
//  BlockForeach.h
//  fscript
//
//  Created by Andrew Weinrich on 1/12/07.
//  Copyright 2007 Andrew Weinrich. All rights reserved.
//

#import <FScript/Block_fscript.h>

/*!
@category Block(BlockForeach)
 @abstract The BlockForeach category adds an iterative method to Blocks that repeatedly runs the block as long as it produces non-<code>nil</code> output, then runs another block with that output.
 */
@interface Block (BlockForeach)


/*!
@method foreach:
@discussion Repeatedly runs the receiver block (using the <span class="method">value</span> method), each time executing the <span class="parameter">iterator</span> block with the receiver's output. The output of <span class="parameter">iterator</span> is discarded. The receiver block will be executed until it returns <span class="literal">nil</span>, at which point <span class="method">foreach:</span> will finish, without executing <span class="parameter">iterator</span> a final time.

This method can be used to produce loops that repeatedly call a function that produces data, such as the <span class="class">FSFile</span> <span class="method">readln</span> method, and returns <span class="literal">nil</span> when it is done. The following block of Perl code is a common idiom for iterating over all the lines in a file; it takes advantage of the fact that Perl's angle-bracket operator returns <span class="literal">undef</span> when there is no data left in a file:

<div class="longexample"><pre>@textblock
open FILE, '<', "......";
while (<FILE>) {
    chomp;
    doSomething($_);
}
@/textblock</pre></div>

In F-Script, the <span class="method">readln</span> method of <span class="class">FSFile</span> returns <span class="literal">nil</span> when the file has been completely read, so we can create a very similar loop:

<div class="longexample"><pre>@textblock
file2 := FSFile open:'....'.
[ file readln ] foreach:[ :line |
    "No 'chomp' necessary - readln cuts off the newline for us"
    obj doSomething:line.
].
@/textblock</pre></div>

A more F-Script-like alternative approach would be to use the <span class="method">readlines</span> method, then run the block over the entire array:

<div class="longexample"><pre>@textblock
file2 := FSFile open:'....'.

[ :line | obj doSomething:line. ] value: @ (file2 readlines).
@/textblock</pre></div>

However, with this code, <span class="method">readlines</span> will read in the entire file at once, which may be very inefficient if the file is large. The iterative method using <span class="method">foreach</span>, on the other hand, only reads and stores a single line at a time.
 */
- (void) foreach:(Block*)iterator;

@end
