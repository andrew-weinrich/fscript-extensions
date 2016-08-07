//
//  FSNSMutableDictionary.m
//  fscript
//
//  Created by Andrew Weinrich on 1/12/07.
//

#import "FSAWNSMutableDictionary.h"
#import <FScript/FScript.h>


@implementation NSMutableDictionary (FSAWNSMutableDictionary)


+ (NSMutableDictionary*) dictionaryWithPairs:(NSArray*)pairs {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    unsigned int count = [pairs count];
    for (int i=0; i < count; i++) {
        NSArray* pair = [pairs objectAtIndex:i];
        [dict setObject:[pair objectAtIndex:1]
                 forKey:[pair objectAtIndex:0]];
    }
    
    return [dict autorelease];
}

+ (NSMutableDictionary*) dictionaryWithFlatPairs:(NSArray*)flatPairs {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    unsigned int count = [flatPairs count];
    // throw an exception if there aren't an even number of items
    if (count % 2 != 0) {
        FSExecError(@"Odd number of items in flat array passed to +dictionaryWithFlatPairs");
    }
        
    for (int i=0; i < count; i+=2) {
        [dict setObject:[flatPairs objectAtIndex:i+1]
                 forKey:[flatPairs objectAtIndex:i]];
    }
    
    return [dict autorelease];
}


@end
