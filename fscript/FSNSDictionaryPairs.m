//
//  FSNSDictionaryPairs.m
//  fscript
//
//  Created by Andrew Weinrich on 2/9/07.
//  Copyright 2007 Andrew Weinrich. All rights reserved.
//

#import "FSNSDictionaryPairs.h"
#import <FScript/Fscript.h>

@implementation NSDictionary (FSNSDictionaryPairs)


+ (NSDictionary*) dictionaryWithPairs:(NSArray*)pairs {
    unsigned int count = [pairs count];
    
    id* keys = malloc(sizeof(id)*count);
    id* values = malloc(sizeof(id)*count);
    
    for (int i=0; i<count; i++) {
        NSArray* pair = [pairs objectAtIndex:i];
        keys[i]   = [pair objectAtIndex:0];
        values[i] = [pair objectAtIndex:1];
    }
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjects:values forKeys:keys count:count];
    
    free(keys);
    free(values);
    
    return dict;
}

+ (NSDictionary*) dictionaryWithFlatPairs:(NSArray*)flatPairs {
    unsigned int itemCount = [flatPairs count];
    // throw an exception if there aren't an even number of items
    if (itemCount % 2 != 0) {
        FSExecError(@"Odd number of items in flat array passed to +dictionaryWithFlatPairs");
    }
    
    unsigned int pairCount = itemCount / 2;

    id* keys = malloc(sizeof(id)*pairCount);
    id* values = malloc(sizeof(id)*pairCount);
    
    for (int i=0; i<pairCount; i++) {
        keys[i]   = [flatPairs objectAtIndex:2*i];
        values[i] = [flatPairs objectAtIndex:2*i+1];
    }
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjects:values forKeys:keys count:pairCount];

    free(keys);
    free(values);
    
    return dict;
}

@end
