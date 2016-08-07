//
//  FSUtility.m
//  FSInterpreter
//
//  Created by Andrew Weinrich on 11/13/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//

#import "FSSystemUtility.h"
#import "Functions.h"
#import "FSFileStdin.h"




@implementation FSSystem (FSSystemUtility)

// private array of library paths
static NSMutableArray* libraryLocations;
static NSMutableArray* frameworkLocations;

static NSMutableDictionary* fileModTimes;


- (void) initLibraries {
    if (!libraryLocations) {
        {
            // add the standard libraries
            libraryLocations = [[NSMutableArray alloc] init];
            [libraryLocations addObject:@"/System/Library/FScript"];
            [libraryLocations addObject:@"/Network/Library/FScript"];
            [libraryLocations addObject:@"/Library/FScript"];
            
            // get envvar/user info
            NSDictionary* envVars = [[NSProcessInfo processInfo] environment];
            NSString* username = [envVars objectForKey:@"USER"];
            
            // add the user's personal library
            if (username) {
                [libraryLocations addObject:[NSString stringWithFormat:@"/Users/%@/Library/FScript",username]];
                
                // this directory is used by F-Script for loading Objective-C frameworks
                [libraryLocations addObject:[NSString stringWithFormat:@"/Users/%@/Application Support/F-Script",username]];
            }
            
            // add any additional libraries
            NSString* userLibs = [envVars objectForKey:@"FSCRIPT_LIB"];
            if (userLibs)
                [libraryLocations addObjectsFromArray:[userLibs componentsSeparatedByString:@":"]];
            
            // add the current working directory
            [libraryLocations addObject:@"./"];
        }
        
        // add the standard framework locations
        {
            frameworkLocations = [[NSMutableArray alloc] initWithObjects:@"/System/Library/Frameworks",
                @"/Library/Frameworks", @"/Network/Frameworks", [@"~/Frameworks" stringByExpandingTildeInPath], nil];
        }
    } 
}


- (void) addLibrary:(NSString*)libraryLocation {
    [libraryLocations addObject:libraryLocation];
}




- (NSArray*) libraries {
    return libraryLocations;
}



- (void) import:(NSString*)fileName force:(BOOL)force {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSString* realFileName = nil;
    if (![fileName hasSuffix:@".fs"])    // add the .fs suffix if it is missing
        fileName = [fileName stringByAppendingString:@".fs"];
    
    // if the file is specified as an absolute path, load it directly
    // otherwise, search through the library paths
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileName hasPrefix:@"/"]) {
        int libCount = [libraryLocations count];
        for (int i=0; i<libCount; i++) {
            NSString* testFileName = [NSString stringWithFormat:@"%@/%@",[libraryLocations objectAtIndex:i],fileName];
            if ([fileManager fileExistsAtPath:testFileName]) {
                realFileName = [NSString stringWithString:testFileName];
                break;
            }
        }
    }
    
    if (!realFileName) {
        FSExecError([NSString stringWithFormat:@"Could not find library file '%@'",fileName]);
    }
    
    
    // check to see if the file has been modified
    if (!fileModTimes)
        fileModTimes = [[NSMutableDictionary alloc] init];
    NSDate* previousFileModTime = [fileModTimes objectForKey:realFileName];
    NSDate* fileModTime = getFileModTime(realFileName);
    
    // only load the file if it hasn't been loaded or has changed
    if (!previousFileModTime || [previousFileModTime compare:fileModTime]==NSOrderedAscending || force) {
        [fileModTimes setObject:fileModTime forKey:realFileName];
        
        // load the file - should return nil
        //id result = [loadFile(realFileName,YES,YES) result];
        [loadFile(realFileName,YES,YES) result];
    }
    
    [pool release];
}


- (void) import:(NSString*)fileName {
    [self import:fileName force:NO];
}


// finds a command's absolute location in our path
NSString* findCommand(NSString* command) {
    NSString* commandPath = nil;
    if ([command hasPrefix:@"/"]) {
        commandPath = command;
    }
    else {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSArray* paths = [[[[NSProcessInfo processInfo] environment] objectForKey:@"PATH"] componentsSeparatedByString:@":"];
        unsigned int i = 0;
        unsigned int lastPathIndex = [paths count];
        while (!commandPath && i < lastPathIndex) {
            NSString* possiblePath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:i], command];
            if ([fileManager fileExistsAtPath:possiblePath])
                commandPath = possiblePath;
            i++;
        }
    }
    
    // throw an exception if we couldn't find the program
    if (!commandPath) {
        FSExecError([NSString stringWithFormat:@"Could not find program: '%@'",command]);
    }
    
    return commandPath;
}






- (NSString*) exec:(NSString*)command args:(NSArray*)args input:(NSString*)input{
    // create and init task with commandpath, args (if any) and output pipe
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:findCommand(command)];
    if (args)
        [task setArguments:args];
    
    NSPipe* pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    NSFileHandle* taskOutput = [pipe fileHandleForReading];
    
    // if input data was supplied, create a filehandle to use for writing
    NSFileHandle* taskInput;
    if (input) {
        NSPipe* writePipe = [NSPipe pipe];
        taskInput = [writePipe fileHandleForWriting];
        [task setStandardInput:writePipe];
    }
    
    [task launch];
    
    // write data if it was supplied
    if (input) {
        [taskInput writeData:[input dataUsingEncoding:NSUTF8StringEncoding]];
        [taskInput closeFile];
    }
    
    // read output data
    NSData* data = [taskOutput readDataToEndOfFile];
    NSString* outputString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    [task terminate];
    
    //int status = [task terminationStatus];
    
    [task release];
    
    return [outputString autorelease];
}


- (NSString*) exec:(NSString*)command args:(NSArray*)args {
    return [self exec:command args:args input:nil];
}

// execs a command, discards output, returns status
- (int) execNoOutput:(NSString*)command args:(NSArray*)args {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    // create and init task with commandpath, args (if any) and output pipe
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:findCommand(command)];
    if (args)
        [task setArguments:args];
    
    [task launch];
    [task waitUntilExit];
    
    int terminationStatus = [task terminationStatus];
    
    [task release];
    [pool release];
    
    return terminationStatus;
}



// execs a command, discards output, returns status
NSString* shellName = nil;
- (NSString*) execShell:(NSString*)command {
    
    if (!shellName)
        shellName = [[[NSProcessInfo processInfo] environment] objectForKey:@"SHELL"];
    
    return [self exec:shellName
                 args:nil
                input:command];
}


static FSFile* stdOut = NULL;
- (FSFile*) out {
    if (!stdOut) {
        stdOut = [FSFile fromNSFileHandle:[NSFileHandle fileHandleWithStandardOutput]];
    }
    return stdOut;
}

static FSFile* stdIn = NULL;
- (FSFile*) in {
    if (!stdIn) {
        stdIn = [FSFileStdin getStdin];
    }
    return stdIn;
}

static FSFile* stdErr = NULL;
- (FSFile*) err {
    if (!stdErr) {
        stdErr = [FSFile fromNSFileHandle:[NSFileHandle fileHandleWithStandardError]];
    }
    return stdErr;
}


static FSToolHelp* helpObject = NULL;
- (FSToolHelp*) help {
    if (!helpObject)
        helpObject = [[FSToolHelp alloc] init];
    return helpObject;
}



NSString* scriptName = NULL;
- (NSString*) scriptName {
    return scriptName;
}

NSArray* scriptArgs = NULL;
- (NSArray*) args {
    return scriptArgs;
}




- (void) exit {
    exit(0);
}


- (void) exitWithStatus:(NSNumber*)status {
    exit([status intValue]);
}





@end
