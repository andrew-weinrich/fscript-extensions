//
//  TestBaseClass.h
//  FSClass
//
//  Created by Andrew Weinrich on 7/31/07.
//  Copyright 2007 Andrew Weinrich. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
 This class is used as a base class for testing inheritance and super-method dispatch
 */

@interface TestBaseClass : NSObject {
    NSString* str;
    int integer;
}


- (id) initWithStr:(NSString*)newStr integer:(NSNumber*)newInteger;



- (int) integer;
- (void) setInteger:(int)newInt;

- (NSString*) str;
- (void) setStr:(NSString*)newString;

- (NSString*) borkedString;

- (int) intPlus:(int)moreInt;



- (NSString*) replace:(NSString*)pattern with:(NSString*)replacement;


@end
