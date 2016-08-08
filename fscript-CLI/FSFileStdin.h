//
//  FSFileStdin.h
//  FSInterpreter
//
//  Created by Andrew Weinrich on 12/6/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FSFile.h"

/*
 FSFileStdin is a subclass of FSFile that has a customized implementation of 
 readlnWithSeparator: The regular version in FSFile will block on stdin if it
 cannot read the normal 80-byte block because the user has not typed in that many
 characters
*/
@interface FSFileStdin : FSFile {
    NSString* buffer;
}

+ (id) getStdin;


- (id) init;

- (NSString*) readlnWithSeparator:(NSString*) separator;



@end
