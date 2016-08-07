//
//  FSFile.m
//  FSInterpreter
//
//  Created by Andrew Weinrich on 11/15/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//

#import "FSFile.h"
#import "Functions.h"
#import "StringSprintf.h"


@implementation FSFile

// data object that contains a single newline - used for println: and newln
static NSData* newlineData;


+ (void)initialize 
{ 
    static BOOL initialized = NO; 
    if (!initialized) { 
        newlineData = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
        initialized = YES; 
    } 
} 





+ (FSFile*) fromNSFileHandle:(NSFileHandle*)handle {
    return [[[FSFile alloc] initWithFileHandle:handle atLocation:@""] autorelease];
}

+ (FSFile*) open:(NSString*)path {
    // create the file if it does not exist
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path])
        [fileManager createFileAtPath:path contents:nil attributes:nil];
    
    FSFile* file = [[FSFile alloc] initWithFileHandle:[NSFileHandle fileHandleForUpdatingAtPath:path]
                                           atLocation:path];
    
    return [file autorelease];
}





/* supported file modes, based on Perl:
    >   Writing, will create if necessary, will truncate existing
    <   Reading, will not create
    >>  Appending, will create if necessary
    <+  Default reading, can update
    >+  Default writing, can update
    >>+ Default appending, can update
*/
/*
typedef struct { NSString* modeString;  BOOL append;  BOOL create;  BOOL clobber;  SEL selector; } modeStruct;
 modeStruct modes[] = {  { @"<",  NO, NO, NO, @selector(fileHandleForReadingAtPath:) },
                        { @">",  NO, YES,YES,@selector(fileHandleForWritingAtPath:) },
                        { @">>", YES,YES,NO, @selector(fileHandleForWritingAtPath:) },
                        { @"<+", NO, NO, NO, @selector(fileHandleForUpdatingAtPath:) },
                        { @">+", NO, YES,YES,@selector(fileHandleForUpdatingAtPath:) },
                        { @">>+",YES,YES,NO, @selector(fileHandleForUpdatingAtPath:) },
                        { nil, NO,NO,NO,@selector(description) }
                      };
*/
+ (FSFile*) open:(NSString*)path mode:(NSString*)mode {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSFileHandle* fileHandle;
    /*
    int index = -1;
    int i = -1;
    while (modes[++i].modeString!=nil) {
        NSLog(modes[i].modeString);
        if ([modes[i].modeString isEqualToString:mode]) {
            index = i;
            break;
        }
    }
    if (index==-1)
        FSExecError([@"Invalid file mode: " stringByAppendingString:mode]);
     
     if (modes[i].create && ![fileManager fileExistsAtPath:path])
     [fileManager createFileAtPath:path contents:nil attributes:nil];
     else
     FSExecError([@"Attempt to open nonexistent file: " stringByAppendingString:path]);
     fileHandle = [NSFileHandle performSelector:modes[i].selector withObject:path];
     if (fileHandle==nil)
     FSExecError([@"Error while opening file: " stringByAppendingString:path]);
     if (modes[i].clobber)
     [fileHandle truncateFileAtOffset:0];
     if (modes[i].append) 
     [fileHandle seekToEndOfFile];
     
     */
    
    BOOL append = NO;
    BOOL create = NO;
    BOOL clobber = NO;
    SEL selector = @selector(fileHandleForWriting:);
    
    if ([mode isEqual:@"<"]) {
        selector = @selector(fileHandleForReadingAtPath:);
        append = NO;
        create = NO;
        clobber = NO;
    }
    else if ([mode isEqual:@">"]) {
        selector = @selector(fileHandleForWritingAtPath:);
        append = NO;
        create = YES;
        clobber = YES;
    }
    else if ([mode isEqual:@">>"]) {
        selector = @selector(fileHandleForWritingAtPath:);
        append = YES;
        create = YES;
        clobber = NO;
    }
    else if ([mode isEqual:@"<+"]) {
        selector = @selector(fileHandleForUpdatingAtPath:);
        append = NO;
        create = NO;
        clobber = NO;
    }
    else if ([mode isEqual:@">+"]) {
        selector = @selector(fileHandleForUpdatingAtPath:);
        append = NO;
        create = YES;
        clobber = YES;
    }
    else if ([mode isEqual:@">>+"]) {
        selector = @selector(fileHandleForUpdatingAtPath:);
        append = YES;
        create = YES;
        clobber = NO;
    }
    else {
        FSExecError([@"Invalid file mode: " stringByAppendingString:mode]);
    }
    
    // create the file if is missing and the create-if-missing flag is set
    if (create) {
        if (![fileManager fileExistsAtPath:path])
            [fileManager createFileAtPath:path contents:nil attributes:nil];
        else    // we expected the file to be present but it wasn't
            FSExecError([@"Attempt to open nonexistent file: " stringByAppendingString:path]);
    }
    
    fileHandle = [NSFileHandle performSelector:selector withObject:path];
    if (fileHandle==nil)    // could we not get a valid filehandle?
        FSExecError([@"Error while opening file: " stringByAppendingString:path]);
    
    [fileHandle retain];

    if (clobber)    // should we erase existing data?
        [fileHandle truncateFileAtOffset:0];
    if (append)     // should we start by appending?
        [fileHandle seekToEndOfFile];
    
    return [[[FSFile alloc] initWithFileHandle:fileHandle atLocation:path] autorelease];
}



- (id) initWithFileHandle:(NSFileHandle*)handle atLocation:(NSString*)fileLocation {
    fileHandle = handle;
    [fileHandle retain];
    
    location = fileLocation;
    [location retain];
    
    sustainBuffer = [[NSMutableString alloc] init];
    
    return self;
}


// this method
- (id) init {
    return [super init];
}

- (void) dealloc {
    [sustainBuffer release];
    [location release];
    [fileHandle release];
    [super dealloc];
}




- (void) print:(NSObject*)object {
    [fileHandle writeData:[[object description] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) println:(NSObject*)object {
    [fileHandle writeData:[[object description] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle writeData:newlineData];     // cached NSData object holding a single newline
}

- (void) println {
    [fileHandle writeData:newlineData];     // cached NSData object holding a single newline
}

- (void) newln {
    [fileHandle writeData:newlineData];
}



/*
- (void) printp:(NSString*)string {
    FSInterpreter* fsint = getGlobalInterpreter();
    
    const char* cString = [string cString];
    
    int length = strlen(cString);
    
    char* ch = (char*)cString;
    
    int maxBufferSize = 100;
    char* buffer = malloc(sizeof(char)*maxBufferSize+1);
    int currBufferSize = 0;
    
    while (ch<cString+length) {
        if ((*ch)!='$') {
            buffer[currBufferSize++] = *(ch++);
            if (currBufferSize==maxBufferSize) {
                buffer = realloc(buffer, (sizeof(char)*(maxBufferSize*=2))+1);
            }
        }
        else {
            ch++;   // move past the initial $
            BOOL bracedName = NO;
            if (*ch=='{') {ch++; bracedName=YES; }
            const char* nameStart = ch;
            const char* nameEnd = ch;
            while (*ch && (*ch=='_' || isalpha(*ch))) {
                nameEnd = ++ch;
            }
            if (bracedName && (*ch!='}')) {
                FSExecError([@"Interpolated variable with opening brace and no closing brace in string: "
                                                                               stringByAppendingString:string]);
                free(buffer);
                return;
            }
            else if (bracedName) {
                ch++;   // skip closing brace
            }
            BOOL foundVar = NO;
            NSString* varName = [NSString stringWithCString:nameStart
                                                     length:(int)(nameEnd-nameStart)];
            id var = [fsint objectForIdentifier:varName found:&foundVar];
            if (!foundVar) {
                FSExecError([NSString stringWithFormat:@"Couldn't find var '%@' in string '%@'",
                    varName,string]);
                free(buffer);
                return;
            }
            const char* varString = [[var description] cString];
            int varSize = strlen(varString);
            if (currBufferSize+varSize>=maxBufferSize) {
                buffer = realloc(buffer, (sizeof(char)*(maxBufferSize*=2))+1);
            }
            strncpy(buffer+currBufferSize,varString,varSize);
            currBufferSize+=varSize;
        }
    }
    
    [fileHandle writeData:[NSData dataWithBytesNoCopy:buffer length:currBufferSize]];
    //fflush(stdout);
    //free(buffer);
}
*/




// The following code is adapted from the source for the Halime NNTP newsreader,
// licensed under the GPL. See COPYING

//
//  ISOSocketLineReader.m
//  Halime
//
//  Created by iso on Mon May 21 2001.
//  Copyright (c) 2001 Imdat Solak. All rights reserved.
//
/*
Halime status 1.0rc2b

This is the source code of Halime 1.0rc2b. The source code is delivered to
you under the GPL - GNU General Public License (s. COPYING).

You may NOT use it to create any product called "Halime" or which name 
resembles "Halime" in any way.

Otherwise, you are permitted to do with the code whatever you want.

Imdat Solak
November 4th, 2003
-------------------------------------------------------------------------------
*/
#define DEFAULT_READ_BUFFER 100
- (NSString*)readlnWithSeparator:(NSString*)separator {
	NSString*       aString;
    char*           buffer;
	char*           buffer2;
	char*           buffer3;
    int             len;
	BOOL            finished = NO;
    NSRange         aRange;
	int             rBufSize;
    NSString*       returnString;
    const char*     separatorCString = [separator cStringUsingEncoding:NSUTF8StringEncoding];
    
    
    [fileHandle synchronizeFile];
    
    
    int separatorLen = [separator length];
	
	aRange = [sustainBuffer rangeOfString:separator];
	if (aRange.length == separatorLen) {
		aRange.length = aRange.location;
		aRange.location = 0;
        returnString = [sustainBuffer substringWithRange:aRange];
        
        // delete the line, including separator, from the buffer
		aRange.length += separatorLen;
		[sustainBuffer deleteCharactersInRange:aRange];
		return returnString;
	}
    else {
		rBufSize = DEFAULT_READ_BUFFER;
		buffer = malloc(rBufSize+1);
		//memset(buffer, 0, rBufSize+1);  // unncessary? duplicated below...
		buffer2 = malloc((rBufSize+1)*2);
		memset(buffer2, 0, (rBufSize+1)*2);
		buffer3 = NULL;
        
		do {
			memset(buffer, 0, rBufSize+1);
            //NSData* data = [fileHandle availableData];
            NSData* data = [fileHandle readDataOfLength:rBufSize-1];
            len = [data length];
			if (len > 0) {
                [data getBytes:buffer length:rBufSize];
				buffer[len] = '\0';
                char* separatorLoc = strstr(buffer, separatorCString);
				if (separatorLoc) {
					finished = YES;
					strcpy(buffer2, buffer);
					strstr(buffer2, separatorCString)[0] = '\0';
					strcpy(buffer, separatorLoc+separatorLen);
                    // at this point, buffer2 has everything up to the separator,
                    // buffer has everything after the separator - the separator itself is discarded
                    
                    // copy the rest of buffer2 and sustainBuffer into buffer3, then set
                    // that as the new systainBuffer
                    int sustainBufferLen = [sustainBuffer lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
                    int buffer3Size = sustainBufferLen + strlen(buffer2)+128;
					buffer3 = malloc(buffer3Size);
					memset(buffer3, 0, buffer3Size);
					const char* tempBuffer = [sustainBuffer cStringUsingEncoding:NSUTF8StringEncoding];
                    memcpy(buffer3,tempBuffer,sustainBufferLen);
					strcat(buffer3, buffer2);
					returnString = [NSString stringWithCString:buffer3 encoding:NSUTF8StringEncoding];
					free(buffer3);
                    
                    
                    
					[sustainBuffer setString:@""];
				}							
				aString = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
				if ([aString length]) {
					[sustainBuffer appendString:aString];
				}
				aString = nil;
			}
            //[data release];   // having this here causes a segfault when the app exits...
		} while ((len > 0) && (!finished));
		free(buffer2);
		free(buffer);
		if (finished) {
			return returnString;
		}
        else if ([sustainBuffer length]) {
            // we've reached the end of the file, which doesn't have a trailing newline
            NSString* temp = [NSString stringWithString:sustainBuffer];
            [sustainBuffer setString:@""];
			return temp;
		}
        else {
            // nothing more to read in the file, return nil
            return nil;
        }
	}
}


- (NSString*) readln {
    return [self readlnWithSeparator:@"\n"];
}



- (NSArray*) readlinesWithSeparator:(NSString*)separator {
    NSMutableArray* allLines = [[NSMutableArray alloc] init];
    NSString* line;
    while ((line = [self readlnWithSeparator:separator])) {
        [allLines addObject:line];
    }
    return allLines;
}

- (NSArray*) readlines {
    return [self readlinesWithSeparator:@"\n"];
}




- (void) printf:(NSString*)format withValues:(NSArray*)values {
    [self print:[format sprintf:values]];
}





- (void) reset {
    [self truncateSustainBuffer];
    [fileHandle seekToFileOffset:0];
}






- (void) truncateSustainBuffer {
    [sustainBuffer setString:@""];
}



/*
 *
 *  The following methods are wrappers for NSFileHandle
 *  They are necessary not only because FScript doesn't let regular forwarding
 *  work, but also to perform the primitive-object conversions
 *
 */



- (NSNumber*)fileDescriptor {
    return [NSNumber numberWithInt:[fileHandle fileDescriptor]];
}
- (NSData*)availableData {
    [self truncateSustainBuffer];
    return [fileHandle availableData];
}

- (NSData*)readDataToEndOfFile {
    [self truncateSustainBuffer];
    return [fileHandle readDataToEndOfFile];
}
- (NSData*)readDataOfLength:(NSNumber*)length {
    [self truncateSustainBuffer];
    return [fileHandle readDataOfLength:[length unsignedLongLongValue]];
}

- (void)writeData:(NSData *)data {
    [self truncateSustainBuffer];
    [fileHandle writeData:data];
}

- (NSNumber*)offsetInFile {
    return [NSNumber numberWithLongLong:[fileHandle offsetInFile]];
}
- (NSNumber*)seekToEndOfFile {
    [self truncateSustainBuffer];
    return [NSNumber numberWithLongLong:[fileHandle seekToEndOfFile]];
}
- (void)seekToFileOffset:(NSNumber*)offset {
    [self truncateSustainBuffer];
    return [fileHandle seekToFileOffset:[offset unsignedLongLongValue]];
}

- (void)truncateFileAtOffset:(NSNumber*)offset {
    [self truncateSustainBuffer];
    [fileHandle truncateFileAtOffset:[offset unsignedLongLongValue]];
}

- (void)synchronizeFile {
    [self truncateSustainBuffer];
    [fileHandle synchronizeFile];
}

- (void)closeFile {
    [self truncateSustainBuffer];
    [fileHandle closeFile];
}

- (void)readInBackgroundAndNotifyForModes:(NSArray *)modes {
    [self truncateSustainBuffer];
    [fileHandle readInBackgroundAndNotifyForModes:modes];
}
- (void)readInBackgroundAndNotify {
    [self truncateSustainBuffer];
    [fileHandle readInBackgroundAndNotify];
}

- (void)readToEndOfFileInBackgroundAndNotifyForModes:(NSArray *)modes {
    [self truncateSustainBuffer];
    [fileHandle readToEndOfFileInBackgroundAndNotifyForModes:modes];
}
- (void)readToEndOfFileInBackgroundAndNotify {
    [self truncateSustainBuffer];
    [fileHandle readToEndOfFileInBackgroundAndNotify];
}

- (void)acceptConnectionInBackgroundAndNotifyForModes:(NSArray *)modes {
    [self truncateSustainBuffer];
    [fileHandle acceptConnectionInBackgroundAndNotifyForModes:modes];
}
- (void)acceptConnectionInBackgroundAndNotify {
    [self truncateSustainBuffer];
    [fileHandle acceptConnectionInBackgroundAndNotify];
}

- (void)waitForDataInBackgroundAndNotifyForModes:(NSArray *)modes {
    [self truncateSustainBuffer];
    [fileHandle waitForDataInBackgroundAndNotifyForModes:modes];
}
- (void)waitForDataInBackgroundAndNotify {
    [self truncateSustainBuffer];
    [fileHandle waitForDataInBackgroundAndNotify];
}


@end
