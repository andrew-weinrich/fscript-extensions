//
//  StringRegex.m
//  FSInterpreter
//
//  Created by Andrew Weinrich on 11/21/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//

#import "StringRegex.h"


// cache of compiled regular expression
static NSMutableDictionary* compiledRegexes;

// get a precompiled pattern, or compile the pattern and cache it
FSRegex* getRegex(NSString* pattern) {
    if (!compiledRegexes)
        compiledRegexes = [[NSMutableDictionary alloc] init];
    
    // if this pattern has not been compiled before, compile and
    // cache it
    FSRegex* regex = [compiledRegexes objectForKey:pattern];
    if (!regex) {
        regex = [[FSRegex alloc] initWithPattern:pattern];
        [compiledRegexes setObject:regex forKey:pattern];
    }
    
    return regex;
}







@implementation NSString (StringRegex)


- (NSArray*) split:(NSString*)pattern {
    return [getRegex(pattern) splitString:self];
}


// simple yes-or-no test to see if a string matches a pattern
- (FSBoolean*) matches:(NSString*)pattern {
    return [FSBoolean booleanWithBool:([[getRegex(pattern) findInString:self] count] > 0)];
}

- (NSString*) replace:(NSString*)pattern with:(NSString*)replacementString {
    return [getRegex(pattern) replaceWithString:replacementString inString:self];
}


// implements Perl's s///gx modifier - takes an FScript block that it evaluates
// for each match in the string
- (NSString*) replace:(NSString*)pattern withBlock:(Block*)block {
    // this copy of self will use replaceCharactersInRange: to do the replacements
    NSMutableString* result = [NSMutableString stringWithString:self];
    
    NSArray* allMatches = [getRegex(pattern) findAllInString:self];
    int matchCount = [allMatches count];
    
    // Because replacing the substrings will change the length of the string, we
    // need to keep track of how to change the beginnings of substring ranges
    int offset = 0;
       
    for (int i = 0; i < matchCount; i++) {
        FSRegexMatch* match = [allMatches objectAtIndex:i];
        int matchGroupCount = [match count];
        
        // create an array out of the match substrings
        NSMutableArray* matchGroups = [[NSMutableArray alloc] initWithCapacity:matchGroupCount];
        for (int j = 0; j < matchGroupCount; j++)
            [matchGroups addObject:[match groupAtIndex:j]];
        
        // compute the replacement string
        NSString* replacement = [[block valueWithArguments:matchGroups] description];
        int replacementLength = [replacement length]; 
        
        // replace it in the original string, taking the offset into account
        NSRange matchRange = [match rangeAtIndex:0];
        matchRange.location += offset;
        [result replaceCharactersInRange:matchRange withString:replacement];
        
        // add this substring's change in length (possibly negative) to the offset
        offset += (replacementLength - matchRange.length);
    }
    return result;
}






- (NSArray*) captures:(NSString*)pattern {
    FSRegexMatch* firstMatch = [getRegex(pattern) findInString:self];
    if (!firstMatch)
        return nil;
    
    NSMutableArray* captures = [[NSMutableArray alloc] init];
    int captureCount = [firstMatch count];
    for (int i=0; i<captureCount; i++) {
        id capture = [firstMatch groupAtIndex:i];
        if (capture==nil) {
            [captures addObject:@""];
        }
        else {
            [captures addObject:capture];
        }
    }
    return captures;
}


- (NSArray*) allCaptures:(NSString*)pattern {
    return [getRegex(pattern) findAllInString:self];
}




@end
