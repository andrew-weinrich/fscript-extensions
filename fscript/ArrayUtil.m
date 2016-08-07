//
//  ArrayUtil.m
//  FSInterpreter
//
//  Created by Andrew Weinrich on 11/25/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//

#import "ArrayUtil.h"


@implementation NSArray (ArrayUtil)


- (NSString*) join:(NSString*)str {
    return [self componentsJoinedByString:str];
}



@end
