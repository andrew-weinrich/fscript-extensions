//
//  TestBaseClass.m
//  FSClass
//
//  Created by Andrew Weinrich on 7/31/07.
//  Copyright 2007 Andrew Weinrich. All rights reserved.
//

#import "TestBaseClass.h"


@implementation TestBaseClass


- (id) initWithStr:(NSString*)newStr integer:(NSNumber*)newInteger {
    [super init];
    
    [newStr retain];
    str = newStr;
    
    integer = [newInteger intValue];
    
    return self;
}



- (int) integer {
    return integer;
}

- (void) setInteger:(int)newInt {
    integer = newInt;
}

- (NSString*) str {
    return str;
}
- (void) setStr:(NSString*)newString {
    [newString retain];
    [str release];
    str = newString;
}

- (NSString*) borkedString {
    id myStr = str;
    return [myStr replace:@"o" with:@"oo"];
}

- (int) intPlus:(int)moreInt {
    return integer + moreInt;
}


// needed to prevent a compiler error; replace:with: is in an NSString category
// in the fscript command-line tool
- (NSString*) replace:(NSString*)pattern with:(NSString*)replacement {
    return @"";
}



@end
