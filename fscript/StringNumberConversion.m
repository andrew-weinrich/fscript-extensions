//
//  StringNumberConversion.m
//  fscript
//
//  Created by Andrew Weinrich on 12/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "StringNumberConversion.h"


@implementation NSString (StringNumberConversion)


- (NSNumber*) operator_plus:(id)operand {
    return [NSNumber numberWithDouble:([self doubleValue] + [operand doubleValue])];
}
- (NSNumber*) operator_hyphen:(id)operand {
    return [NSNumber numberWithDouble:([self doubleValue] - [operand doubleValue])];
}
- (NSNumber*) operator_asterisk:(id)operand {
    return [NSNumber numberWithDouble:([self doubleValue] * [operand doubleValue])];
}
- (NSNumber*) operator_slash:(id)operand {
    return [NSNumber numberWithDouble:([self doubleValue] / [operand doubleValue])];
}
- (NSNumber*) operator_mod:(id)operand {
    return [NSNumber numberWithDouble:([self intValue] % [operand intValue])];
}

@end
