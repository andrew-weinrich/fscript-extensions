//
//  Functions.m
//  fscript
//
//  Created by Andrew Weinrich on 11/13/06.
//

#import "Functions.h"



NSDate* getFileModTime(NSString* fileLocation) {
    NSError* error = nil; // assume we already checked for the file's existence
    NSDate* fileModDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileLocation error:&error] objectForKey:NSFileCreationDate];
    if (error)
        [NSException raise:@"RegularExpressionUTF8Exception" format:@"Tried to get mod time of nonexistent file %@", fileLocation];
    return fileModDate;
}

NSNumber* getFileSize(NSString* fileLocation) {
    NSError* error = nil; // assume we already checked for the file's existence
    NSNumber* fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileLocation error:&error] objectForKey:NSFileSize];
    if (error)
        [NSException raise:@"RegularExpressionUTF8Exception" format:@"Tried to get size of nonexistent file %@", fileLocation];
    return fileSize;
}




// function that creates/returns a singleton global interpreter
FSInterpreter* _globalInterpreter;
FSInterpreter* getGlobalInterpreter() {
    if (!_globalInterpreter)
        _globalInterpreter = [[FSInterpreter alloc] init];
    return _globalInterpreter;
}

// this dictionary caches the modification dates of loaded .fs files, so that
// we won't reload
NSMutableDictionary* loadedFiles;



FSInterpreterResult* loadFile(NSString* fileLocation, BOOL asLibrary, BOOL verboseExceptions) {
    int errorLine = 0;  // line on which an error occurs
    
    // load the contents of the file into a string
    NSError* err = nil;
    NSString* scriptContents = [NSString stringWithContentsOfFile:fileLocation
                                                         encoding:NSUTF8StringEncoding
                                                            error:&err];
    if (err && [err code]!=0) {
        [[NSException exceptionWithName:@"FileError" reason:
            [NSString stringWithFormat:@"Couldn't read file '%@': %@",
                fileLocation,
                [[[err userInfo] objectForKey:NSUnderlyingErrorKey] localizedDescription]]
            userInfo:nil]
            raise];
        return nil;
    }
    
    // check to see if this file needs to be reloaded, return early if not
    if (!loadedFiles)
        loadedFiles = [[NSMutableDictionary alloc] init];
    NSDate* modTime = [loadedFiles objectForKey:fileLocation];
    NSDate* fileModTime = getFileModTime(fileLocation);
    if (modTime && [fileModTime compare:modTime] != 1) {
        return nil;
    }
    
    
    // if this file was launched from the command line, check for a shebang
    // on the first line and chop it off if it was present
    if (!asLibrary && [scriptContents hasPrefix:@"#!"]) {
        NSRange range = [scriptContents rangeOfString:@"\n"];
        NSString* newScriptContents = [scriptContents substringFromIndex:range.location+1];
        scriptContents = newScriptContents;
        errorLine++;  // remember this extra line in case there was an error
    }
    
    // run the script contents
    FSInterpreterResult* result;
    result = [getGlobalInterpreter() execute:scriptContents];
    
    // if there was an error, figure out which line/char it was on
    if (![result isOK]) {
        NSRange errorRange = [result errorRange];
        int stringLen = [scriptContents length];
        int errorLocation = errorRange.location;
        int currentLoc = -1;    // will be incremented to 0 in first run of loop below
        int errorChar = 0;
        
        // count up the lines until we find the location of the error
        while (currentLoc<errorLocation) {
            errorRange = [scriptContents rangeOfString:@"\n"
                                               options:0
                                                 range:NSMakeRange(currentLoc+1,stringLen-currentLoc-1)];
            errorChar = errorLocation - currentLoc;
            currentLoc = errorRange.location;
            errorLine++;
        }

        // throw an error - if not caught by exception handlers in a script, will be caught in main()
        NSString* reason = [NSString stringWithFormat:@"Error in file %@, line %d, character %d: %@",
            fileLocation,
            errorLine, errorChar,
            [[result errorMessage] description]];

        [[NSException exceptionWithName:@"FSInterpreterException" reason:reason userInfo:nil] raise];
    }
    // if everything was fine, return the result
    return result;
}

