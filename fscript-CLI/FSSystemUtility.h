//
//  FSUtility.h
//  fscript
//
//  Created by Andrew Weinrich on 11/13/06.
//

#import <FScript/FSSystem.h>
#import "FSFile.h"
#import "FSToolHelp.h"

/*!
 @category FSSystem(FSSystemUtility)
 @abstract The FSSystemUtility category adds methods to F-Script's builtin <code>sys</code> object that are useful for command-line scripts.
 @discussion The FSSystemUtility category adds methods to F-Script's <span class="class">System</span> class, making them effectively global functions, as there is only one single <code>sys</code> object. Most of the methods deal with importing other files as libraries.
*/
@interface FSSystem(FSSystemUtility)

//  this method is called in main() to initialize the default library list
- (void) initLibraries;


/*!
@method import:
@discussion Loads and runs another F-Script file. This method is intended to be used with files that implement classes with <span class="class">FSClass</span>, or for large programs that can be logically separated into multiple files. The main script can load all the appropriate libraries, pull in the supporting files, and then start the program's processing.

<span class="parameter">fileName</span> can omit the trailing ".fs", and <span class="method">import:</span> will add it; <code>sys import:'MyClass'.</code> is thus equivalent to <code>sys import:'MyClass.fs'.</code>. <span class="method">import:</span> will search the following directories, in order, for the specified file:
<ol>
<li><span class="directory">/System/Library/FScript</span></li>
<li><span class="directory">/Network/Library/FScript</span></li>
<li><span class="directory">/Library/FScript</span></li>
<li><span class="directory">~/Library/FScript</span></li>
<li><span class="directory">~/Application Support/F-Script</span> (the F-Script framework directory)</li>
<li>If the environment variable <code>FSCRIPT_LIB</code> exists, it is considered to be a colon-separated list of additional directories, in the manner of <code>PATH</code>-type variables</li>
<li>The current working directory</li>
<li>Any additional libraries added with the <span class="method">addLibrary:</span> method</li>
</ol>
If the file cannot be found or contains syntax errors, <span class="method">import:</span> will throw an exception.

<span class="method">import:</span> expects that the final value of the file will be <code>nil</code>. If the library encounters any problems during initialization, it should return a suitable error message instead, which <span class="method">import:</span> will throw as an exception. For example, if a library file expects a particular environment variable to be set and it is not, it should return the string "<span class="literal">Environment variable FOO not set</span>".

The file will be executed in the same interpreter as the original program, so any variable declarations will go into the global namespace, possibly clobbering any existing objects there. Care should be taken to only declare objects and classes that are documented for the user. Internal library variables (e.g. class data) should be prefixed with "<span class="literal">_</span>" or another suitable indicator.

<span class="method">import:</span> caches the modification times of loaded files, so a second invocation to load the same file will only reparse it if it has changed since it was first loaded. This makes the importation of library files effectively idempotent. However, if you are working on a script and have an interpreter prompt open, you can repeatedly call <code>sys import:filename.</code> to reload the file as you tweak your code.
 
*/
- (void) import:(NSString*)fileName;

- (void) import:(NSString*)fileName force:(BOOL)force;


/*!
@method libraries
Returns the list of library directories used by <span class="method">import:</span>.
*/
- (NSArray*) libraries;

/*!
@method addLibrary:
Add another library to the end of the list of directories searched by <span class="method">import:</span>.
 */
- (void) addLibrary:(NSString*)libraryLocation;



/*!
 @method out
 Returns an instance of FSFile representing standard output, like <code>System.out</code> in Java.
 */
- (FSFile*) out;


/*!
 @method in
 Returns an instance of FSFile representing standard input, like <code>System.in</code> in Java.
 */
- (FSFile*) in;


/*!
 @method err
 Returns an instance of FSFile representing standard error, like <code>System.err</code> in Java.
 */
- (FSFile*) err;


/*!
 @method help
 Returns a singleton instance of FSToolHelp, which contains information about the current environment. The help object has methods <code>version</code>, <code>frameworks</code>, <code>import</code>, and <code>quit</code>.
 */
- (FSToolHelp*) help;


/*!
 @method scriptName
 Returns the name of the currently executing script, or <code>nil</code> if the interpreter is running in interactive mode.
 */
- (NSString*) scriptName;
extern NSString* scriptName;


/*!
 @method args
 Returns an array of command-line arguments to the script, or <code>nil</code> if the interpreter is running in interactive mode.
 */
- (NSArray*) args;

extern NSArray* scriptArgs;

/*
@method loadFramework:
Searches for a framework in the standard locations (in order, <span class="dir">/System/Library/Frameworks</span>, <span class="dir">/Network/Library/Frameworks</span>, <span class="dir">/Library/Frameworks</span>, and <span class="dir">~/Library/Frameworks</span>), and loads it (using the NSBundle class). For example, here is how you would implement the first search example from Apple's documentation for the Address Book framework:

<div class="longexample"><pre>@textblock
sys loadFramework:'AddressBook'.
ab := ABAddressBook sharedAddressBook.
nameIsSmith := ABPerson searchElementForProperty:kABLastNameProperty label:nil key:nil value:'Smith' comparison: kABEqualCaseInsensitive.
peopleFound := ab recordsMatchingSearchElement:nameIsSmith.
@/textblock</pre></div>

Note that the constants, as well as class names, from the bundle are immediately available.
*/
//- (void) loadFramework:(NSString*)frameworkName;



/*!
@method exec:args:input:
@param command The name of the command. If the name is not an absolute path, <span class="method">exec:</span> will search for the program in the <code>PATH</code> environment variable, e.g. <span class="literal">ls</span> will be translated to <span class="literal">/bin/ls</span>. If the program cannot be found in your <code>PATH</code>, the method will throw an exception.
@param args An optional array of arguments to pass to the program
@param input Data to pass to the program's standard input pipe. If <span class="parameter"> is <span class="literal">nil</span>, no data will be written to the program
 @discussion Runs a program and returns its output as a string, similar to Perl's backtick operator. The following Perl code:

<div class="longexample"><pre>@textblock
$output = `myProgram arg1 arg2 arg3`;
@/textblock</pre></div>

can be implemented in F-Script as:

<div class="longexample"><pre>@textblock
output := sys exec:'myProgram' args:{'arg1', 'arg2', 'arg3'} input:nil.
@/textblock</pre></div>

<span class="method">exec:args:input:</span> will search your <code>PATH</code> environment variable to find the program if you do not specify an absolute path. If you specify an absolute program that does not exist, or a relative path that cannot be found, the method will throw an exception.

Unlike the backticks operator, <span class="method">exec:args:input:</span> does not perform shell interpolation or redirection. If you want to use the shell to interpret variables or redirect streams, use the method <span class="method">execAsShell:args:input:</span>.

<span class="method">exec:args:input:</span> does not return the program's exit status. If you want the exit status instead of the output, use <span class="method">execNoOutput:args:input:</span>. If you want both, use the Foundation class <span class="class">NSTask</span>, which <span class="method">exec:args:input:</span> is built on.
 
<strong>IMIPORTANT NOTE:</strong> as of fscript 1.5 and Mac OS X 10.4.10, there is a bug in the <span class="class">NSTask</span> class of Apple's Foundation Kit, on which the <span class="method">exec:</span> methods rely. If you call more <code>exec:</code> many times during the execution of a script (over 200 or so), the method will throw an exception relating to an NSDictionary null-key violation. This is a bug in Apple's code; they have been notified, and hopefully it will be fixed in the future. For the moment, try to limit the number of <code>exec:</code> calls you make in a single script.
*/
- (NSString*) exec:(NSString*)command args:(NSArray*)args input:(NSString*)input;


/*!
@method exec:args:
@discussion Equivalent to <code>sys exec:'commandName' args:{ ... } input:nil.</code>.
*/
- (NSString*) exec:(NSString*)command args:(NSArray*)args;



/*!
@method execNoOutput:args:
@discussion Similar to <span class="method">exec:args:input:</span>, runs a program and returns its exit status, rather than its output.
*/
- (int) execNoOutput:(NSString*)command args:(NSArray*)args;


    
/*!
@method execShell:
@discussion This method is an exact duplicate for Perl's backticks operator. The command will be passed to your current shell (as defined by the <code>SHELL</code> environment variable) for processing, and the output (if any) will be returned. The shell will handle command location, variable interpolation, and I/O redirection, with all the flexibility and danger that implies.
*/
- (NSString*) execShell:(NSString*)command;


/*!
@method exit
@discussion Immediately exits the program with status 0.
*/
- (void) exit;


/*!
@method exitWithStatus:
@discussion Immediately exits the program with the given status indicator. Typically, non-zero exit statuses are used to indicate error conditions to parent processes such as shell scripts.
*/
- (void) exitWithStatus:(NSNumber*)status;

    


@end
