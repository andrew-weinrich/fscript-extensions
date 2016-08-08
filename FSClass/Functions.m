//
//  Functions.m
//  FSClass
//
//  Created by Andrew Weinrich on 6/24/07.
//  Copyright 2007 Andrew Weinrich. All rights reserved.
//

#import <objc/objc.h>
#import <objc/objc-runtime.h>
#import <string.h>
#import "Functions.h"
#import "FSClassStringUtil.h"
#import "Trampoline.h"
#import "Callbacks.h"

#import "FSClass.h"
#import "FSClassCreation.h"



// returns the number of parameters for a selector
unsigned int getSelectorParameterCount(SEL selector) {
    // count the colons to see how many arguments we have
    const char *ch = sel_getName(selector);
    unsigned int paramCount = 0;
    while (*(ch++))
        if (*ch==':') paramCount++;
    return paramCount;
}


// default signatures for common method arities
static const char* signatures[] = { "@@:", "@@:@", "@@:@@", "@@:@@@", "@@:@@@@", "@@:@@@@@", "@@:@@@@@@" };


void createMethodSignature(unsigned int argCount, char** signature, BOOL* freeSignature) {
    if (argCount < 6) {
        *freeSignature = NO;
        *signature = (char*)(signatures[argCount]);
    }
    else {
        // number of arguments = number of colons in the code
        char* customSignature = malloc(argCount + 3 + 1);
        customSignature[0] = '@'; // return type
        customSignature[1] = '@'; // receiver 
        customSignature[2] = ':'; // selector
        for (unsigned int i=0; i<argCount; i++)
            customSignature[i+3] = '@';
        customSignature[argCount+3] = '\0';
        *freeSignature = YES;
        *signature = customSignature;
    }
}    







// used to verify strings representing selectors
BOOL isLegitSelector(NSString* string) {
    // first check that it is a valid ASCII string
    const char* c = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (!c)
        return NO;
    
    // make sure it starts with an alphabetical character
    if (!(*c=='_' || (*c>='a'&&*c<='z') || (*c>='A'&&*c<='Z'))) {
        return NO;
    }
    
    int argCount = 0;
    while (*(++c)) {
        const char* cn = c+1;
        BOOL isAlpha = (*c>='a'&&*c<='z') || (*c>='A'&&*c<='Z');
        BOOL isNumeric = (*c>='0'&&*c<='9');
        BOOL isColon = *c==':';
        
        // count up how many arguments are in the selector
        if (isColon) argCount++;
        
        // return YES if the last character is a colon
        if (isColon && *cn=='\0')
            return YES;
        
        // NO if there is a colon followed by a non-alpha
        if (isColon && !(*cn=='_' || (*cn>='a'&&*cn<='z') || (*cn>='A'&&*cn<='Z')))
            return NO;
        
        // NO if it's another illegal character
        if (!(isColon || *c=='_' || isAlpha || isNumeric))
            return NO;
        
        // NO if it's a non-unary message that doesn't end with a colon
        if (!isColon && argCount>0 && *cn=='\0')
            return NO;
    }
    
    return YES;
}



// this method verifies that a string can be used as the name of a property
BOOL _isLegitPropertyName(NSString* name, NSDictionary* properties, NSString** reason) {
    // It is extremely inefficient to keep recreating these character sets, but I was
    // having very weird problems with creating them as static module-level variables - they
    // kept getting corrupted and overwritten with weird strings like 'English.lproj'
    NSCharacterSet* alphaCharacters = nil;
    NSCharacterSet* alphaNumericCharacters = nil;
    NSCharacterSet* illegalCharacters = nil;
    
    
    NSString* alphaString = @"abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSString* alphaNumericString = @"0123456789abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    alphaCharacters = [NSCharacterSet characterSetWithCharactersInString:alphaString];
    alphaNumericCharacters = [NSCharacterSet characterSetWithCharactersInString:alphaNumericString];
    illegalCharacters = [alphaNumericCharacters invertedSet];
    
    
    
    if (![name isKindOfClass:[NSString class]]) {
        *reason = @"Attempt to use non-string as property key: %@";
        return NO;
    }
    
    // check to make sure we don't have this property already
    if ([properties valueForKey:name]) {
        *reason = @"Attempt to add already existing property: %@";
        return NO;
    }
    
    // make sure this is a valid property name - ASCII only, alphanumerics only
    if (!([name length] > 0) || ![alphaCharacters characterIsMember:[name characterAtIndex:0]]) {
        *reason = @"Property name '%@' does not start with an alphabetic character";
        return NO;
    }
    NSRange illegalCharacterLocation = [name rangeOfCharacterFromSet:illegalCharacters];
    if (illegalCharacterLocation.location != NSNotFound) {
        *reason = @"Property name '%@' contains illegal characters";
        return NO;
    }
    
    // make sure there isn't an existing property with the same first character in a different case
    if ([properties valueForKey:[name lowercaseFirst]]) {
        *reason = @"Property name '%@' conflicts with existing property";
        return NO;
    }
    if ([properties valueForKey:[name uppercaseFirst]]) {
        *reason = @"Property name '%@' conflicts with existing property";
        return NO;
    }
    
    // make sure it doesn't conflict with one of the reserved property names
    if ([name isEqualToString:IVAR_FS_CLASS_STRING] || [name isEqualToString:IVAR_PROP_DICTIONARY_STRING]) {
        *reason = @"Property name '%@' conflicts with existing property";
        return NO;
    }
    
    return YES;
}



char* makePropertyNameFromSetSelector(SEL selector) {
    // "setMyVar:" -> "myVar", so reduce length by 4 and add 1 for padding null byte
    int selectorLength = strlen(sel_getName(selector));
    int propNameLength = selectorLength - 4;
    char* propertyString = malloc(sizeof(char) * (selectorLength+1));
    strncpy(propertyString,sel_getName(selector)+3,selectorLength);
    
    // lowercase first letter and set last char in buffer to null
    propertyString[0] = (char)tolower(propertyString[0]);
    propertyString[propNameLength] = '\0';
    
    return propertyString;
}




NSString* FSClassException = @"FSClassException";


void ThrowException(NSString* name, NSString* reason, NSDictionary* info) {
    [[NSException exceptionWithName:name reason:reason userInfo:info] raise];
}




Class class_getMetaclass(Class c) {
    return objc_getMetaClass(class_getName(c));
}


