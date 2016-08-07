//
//  FSFile.h
//  fscript
//
//  Created by Andrew Weinrich on 11/15/06.
//

#import <Foundation/Foundation.h>


/*! 
@class FSFile
@abstract Extension of NSFileHandle with methods convenient for text-file handling
@discussion FSFile is a subclass of NSFileHandle that provides text-file handling methods similar to other scripting languages. To open a file, use FSFile's <span class="method">open:</span> method, which uses the same mode specifiers as Perl's <code>open</code> function. You can then use <span class="method">readln</span>, <span class="method">print:</span>, <span class="method">println:</span>, and <span class="method">printf:withValues:</span> to perform input and output.

<style>code { border-width:1px; background-color:lightgrey }</style>

FSFile is a subclass of NSFileHandle, so the more fine-grained methods of that class for non-text files are also available, such as seeking through the file and calculating offsets. It is important to note that FSFile keeps its own buffer for <span class="method">readln</span> and related methods, so mixing calls to <span class="method">readln</span> and other NSFileHandle methods like <span class="method">seekToFileOffset:</span> or <span class="method">readDataOfLength:</span> will produce unpredictable results and will probably result in data being skipped. If you wish to switch between line- and offset-oriented modes, use the FSFile method <span class="method">reset</span>. This method will clear all buffers and set the file pointer back to 0.

*/
@interface FSFile : NSFileHandle {
    NSFileHandle* fileHandle;
    NSString* location;             // file-system location
	NSMutableString	*sustainBuffer; // buffer that holds extra data from readline
}


/*!
@method fromNSFileHandle:
 Creates an FSFile object that wraps an existing NSFileHandle. Use this method if you have created a non-file NSFileHandle - such as one end of a pipe - you can use this method to create an FSFile that supports <span class="method">print</span> and <span class="method">readln</span>.
 */
+ (FSFile*) fromNSFileHandle:(NSFileHandle*)handle;


/*!
@method open:
 Equivalent to <code>open:path mode:&#64;""</code>
 Creates an FSFile object that wraps an existing NSFileHandle. Use this method if you have created a non-file NSFileHandle - such as one end of a pipe - you can use this method to create an FSFile that supports <span class="method">print</span> and <span class="method">readln</span>.
 */
+ (FSFile*) open:(NSString*)path;


/*!
@method open:mode:
 Opens a file for use. <span class="parameter">mode</span> should be one of the following Perl-style mode strings:
 
<table>
  <th>
    <tr>
      <td>Mode</td><td>Read</td><td>Write</td><td>Append to existing data</td><td>Create file if not existing</td><td>Throw error if file does not exist</td>
    </tr>
  </th>
  <tbody>
    <tr><td class="mode">&lt;</td>      <td>Yes</td> <td>No</td>  <td></td>    <td>No</td>  <td>Yes</td> </tr>
    <tr><td class="mode">&gt;</td>      <td>No</td>  <td>Yes</td> <td>No</td>  <td>Yes</td> <td>No</td>  </tr>
    <tr><td class="mode">&gt;&gt;</td>  <td>No</td>  <td>Yes</td> <td>Yes</td> <td>Yes</td> <td>No</td>  </tr>
    <tr><td class="mode">&lt;+</td>     <td>Yes</td> <td>Yes</td> <td></td>    <td>No</td>  <td>Yes</td> </tr>
    <tr><td class="mode">&gt;+</td>     <td>Yes</td> <td>Yes</td> <td>No</td>  <td>Yes</td> <td>No</td>  </tr>
    <tr><td class="mode">&lt;&lt;+</td> <td>Yes</td> <td>Yes</td> <td>Yes</td> <td>Yes</td> <td>No</td>  </tr>
 </tbody>
</table>
 
 If <code>mode</code> is not one of the above strings, the method will throw an exception.
 
 */
+ (FSFile*) open:(NSString*)path mode:(NSString*)mode;





/*
 *
 *  Methods for printing strings, lines, and formatted output
 *
 */
/*!
@method print:
 Prints an object (typically a string) to a file. If the object is not an NSString, the <span class="method">description</span> will be used to obtain a string representation. Using this method on a read-only file (such as standard input) will throw an error.
 */
- (void) print:(NSObject*)string;

/*!
@method println:
@param string The object to print. If the object is not an NSString, it will be sent a -description message to produce a printable string.
@discussion Equivalent to <span class="method">print:</span>, but also prints a newline character after printing the string (similar to Java's <span class="method">PrintStream.println</span> method).
 */
- (void) println:(NSObject*)string;


/*!
 @method println:
 @discussion Prints a blank line.
 */
- (void) println;


/*!
@method newln
 Prints a single newline (ASCII 13) character to the file.
 */
- (void) newln;

/*!
@method printf:withValues:
 Equivalent to <code>print:(format sprintf:values)</code>.
 */
- (void) printf:(NSString*)format withValues:(NSArray*)values;



/*
 *
 *  Methods for reading individual lines
 *
 */
/*!
@method readln
 Equivalent to <code>readlnWithSeparator:'\n'</code>.
 */
- (NSString*) readln;

/*!
@method readlnWithSeparator:
Reads in data until either the specified separator (which can be a single character or a string) is encountered, chops off the separator, and returns the read data as a string. Plain <span class="method">readln</span> uses a newline character as a separator; if you need to specify a custom line break (such as when reading DOS/Windows-formatted text files) use <span class="method">readlnWithSeparator</span>.
 
<span class="method">readlnWithSeparator:</span> will return <code>nil</code> if there is no more data left in the file, so you can use it in loops like these:
 
<div class="longexample"><pre>@textblock
file := NSFile open:'.....'.
line := nil.
[ line := file readln. line == nil ] whileTrue:[
    obj doSomethingWith:line.
]

 
file2 := FSFile open:'....'.
sys foreach:[ file readln ] do:[ :line |
    out println:line.
].
@/textblock</pre></div>
 */
- (NSString*) readlnWithSeparator:(NSString*) separator;

/*!
@method readlinesWithSeparator:
Reads in all the lines of the file and returns them in an array. The returned array may be quite large, depending on the size of the file, so use this method with caution.
 
The F-Script code <code>lines := file readLines.</code> is equivalent to the Perl code <code>&#64;lines = split "\n", &lt;FILE&gt;;</code>.
*/
- (NSArray*) readlinesWithSeparator:(NSString*)separator;

/*!
@method readlines
Equivalent to <code>readlinesWithSeparator:'\n'</code>.
 */
- (NSArray*) readlines;



/*
 *
 *  Other methods
 *
 */
/*!
@method reset
 Clears all line-oriented buffers and resets the file pointer back to zero. If, for some reason, you want to stop using the line-oriented methods of FSFile like <span class="method">readln</span>, use this method before starting to use the NSFileHandle byte-oriented methods.
 
 This method will throw an exception if the filehandle does not support seeking.
 */
- (void) reset;






/*
 *
 *  The following methods are wrappers for NSFileHandle's method
 *
 */
- (NSData *)availableData;

- (NSData *)readDataToEndOfFile;
- (NSData *)readDataOfLength:(NSNumber*)length;

- (void)writeData:(NSData *)data;

- (NSNumber*)fileDescriptor;

- (NSNumber*)offsetInFile;
- (NSNumber*)seekToEndOfFile;
- (void)seekToFileOffset:(NSNumber*)offset;

- (void)truncateFileAtOffset:(NSNumber*)offset;
- (void)synchronizeFile;
- (void)closeFile;

- (void)readInBackgroundAndNotifyForModes:(NSArray *)modes;
- (void)readInBackgroundAndNotify;

- (void)readToEndOfFileInBackgroundAndNotifyForModes:(NSArray *)modes;
- (void)readToEndOfFileInBackgroundAndNotify;

- (void)acceptConnectionInBackgroundAndNotifyForModes:(NSArray *)modes;
- (void)acceptConnectionInBackgroundAndNotify;

- (void)waitForDataInBackgroundAndNotifyForModes:(NSArray *)modes;
- (void)waitForDataInBackgroundAndNotify;





/*
 *
 *  Private methods
 *
 */

+ (void) initialize;

// this method is called by sub-classes like FSFileStdin
- (id) init;

// called by +fromNSFileHandle:, +open:, and +open:mode:
- (id) initWithFileHandle:(NSFileHandle*)handle atLocation:(NSString*)fileLocation;

// closes the file when the object is freed
- (void) dealloc;

// clear out any data thats held in the buffer used for readln
- (void) truncateSustainBuffer;




@end















