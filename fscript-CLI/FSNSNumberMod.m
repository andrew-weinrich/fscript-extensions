//
//  FSNSNumberMod.m
//  FSInterpreter
//
//  Created by Andrew Weinrich on 11/18/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//

#import "FSNSNumberMod.h"


@implementation NSNumber (FSNSNumberMod)



- (NSNumber*) operator_percent:(NSNumber*)operand {
    return [NSNumber numberWithInt:([self intValue] % [operand intValue])];
}


/*
- (NSString*) operator_plus_plus:(NSString*)operand {
    return [[self description] stringByAppendingString:operand];
}
*/

@end
