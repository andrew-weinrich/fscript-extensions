//
//  FSToolHelp.m
//  fscript
//
//  Created by Andrew Weinrich on 8/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "FSToolHelp.h"
#import "interpreter.h"

#include "pcre-7.8/config.h"

#ifdef __ppc__
    NSString* architecture = @"PowerPC 32bit";
#endif
#ifdef __ppc64__
    NSString* architecture = @"PowerPC 64bit";
#endif
#ifdef __i386__
    NSString* architecture = @"x86 32bit";
#endif
#ifdef __x86_64__
    NSString* architecture = @"x86 64bit";
#endif







@implementation FSToolHelp

- (NSString*) description {
    return @"Available help topics:\n  help version\n  help quit\n  help import\n  help frameworks\n";
}


- (NSString*) version {
    return [NSString stringWithFormat:@"Architecture:       %@\n"
                                      @"F-Script Framework: %@\n"
                                      @"fscript CLI:        %@\n"
                                      @"Regex Library:      %s",
        architecture,
        [[NSBundle bundleWithIdentifier:@"org.fscript.fscriptframework"] objectForInfoDictionaryKey:@"CFBundleVersion"],
        interpreterVersion,
        PACKAGE_STRING];
        
}


- (NSString*) import {
    return @"To import libraries or scripts, type 'sys import:filename'.\nTo see current library directories, type 'sys libraries.'\n";
}



- (NSString*) quit {
    return @"To exit, type 'sys exit' and hit return, or type Control-D.";
}



- (NSString*) frameworks {
    NSMutableString* bundleVersions = [NSMutableString stringWithString:@"Frameworks:\n"];
    
    NSArray* frameworks = [[NSBundle allFrameworks] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"bundleIdentifier" ascending:YES]]];
    for (NSBundle* framework in frameworks)
        if (framework && [framework bundleIdentifier])   // keep out /usr/lib
            [bundleVersions appendString:[NSString stringWithFormat:@"  %-35s%@\n",
                                          [[framework bundleIdentifier] cStringUsingEncoding:NSASCIIStringEncoding],
                                          [framework objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
    
    [bundleVersions appendString:@"\nBundles:\n"];
    NSArray* bundles = [[NSBundle allBundles] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"bundleIdentifier" ascending:YES]]];
    for (NSBundle* bundle in bundles)
        if (bundle && [bundle bundleIdentifier])   // keep out /usr/bin
            [bundleVersions appendString:[NSString stringWithFormat:@"  %-35s%@\n",
                                          [[bundle bundleIdentifier] cStringUsingEncoding:NSASCIIStringEncoding],
                                          [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
    
    return bundleVersions;
}




/*
 Support for invalid help commands
 */

// returns the number of parameters for a selector
unsigned int getSelectorParameterCount(SEL selector) {
    // count the colons to see how many arguments we have
    const char *ch = sel_getName(selector);
    unsigned int paramCount = 0;
    while (*(ch++))
        if (*ch==':') paramCount++;
    return paramCount;
}


// we "respond" to all invalid parameter-less "help foo" commands
- (BOOL)respondsToSelector:(SEL)aSelector {
    return YES;
}


- (NSMethodSignature*) methodSignatureForSelector:(SEL)selector {
    unsigned int paramCount = getSelectorParameterCount(selector);
    
    switch (paramCount) {
        case 0: return [NSMethodSignature signatureWithObjCTypes:"@@:"];
        case 1: return [NSMethodSignature signatureWithObjCTypes:"@@:@"];
        case 2: return [NSMethodSignature signatureWithObjCTypes:"@@:@@"];
        case 3: return [NSMethodSignature signatureWithObjCTypes:"@@:@@@"];
        case 4: return [NSMethodSignature signatureWithObjCTypes:"@@:@@@@"];
        case 5: return [NSMethodSignature signatureWithObjCTypes:"@@:@@@@@"];
        case 6: return [NSMethodSignature signatureWithObjCTypes:"@@:@@@@@@"];
        case 7: return [NSMethodSignature signatureWithObjCTypes:"@@:@@@@@@@"];
        case 8: return [NSMethodSignature signatureWithObjCTypes:"@@:@@@@@@@@"];
        default: return [super methodSignatureForSelector:selector];
    }
}


// handles invalid help messages
- (void) forwardInvocation:(NSInvocation*)anInvocation {
    SEL selector = [anInvocation selector];
    if (getSelectorParameterCount(selector)==0) {
        NSString* returnString = [NSString stringWithFormat:@"There is no help avavilable for '%s'", sel_getName(selector)];
        [anInvocation setReturnValue:&returnString];
    }
    else {
        NSString* returnString = @"Usage: 'help foo'";
        [anInvocation setReturnValue:&returnString];
    }
} 


@end
