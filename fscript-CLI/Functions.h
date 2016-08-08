//
//  Functions.h
//  FSInterpreter
//
//  Created by Andrew Weinrich on 11/13/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FScript/FScript.h>

/* 
 * These functions are used by main() and sys import: to load scripts
 */
NSDate* getFileModTime(NSString* fileLocation);
NSNumber* getFileSize(NSString* fileLocation);

FSInterpreter* getGlobalInterpreter();
FSInterpreterResult* loadFile(NSString* fileLocation, BOOL asLibrary, BOOL verboseExceptions);
