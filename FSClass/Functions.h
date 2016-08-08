//
//  Functions.h
//  FSClass
//
//  Created by Andrew Weinrich on 6/24/07.
//  Copyright 2007 Andrew Weinrich. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// creates a new class, allocates space for its member variables, and registers
// it with the Cocoa runtime
Class createClass(NSString* className, Class parent, NSArray* variables);


// creates a C string signature for a method, to be used with class_addMethod
void createMethodSignature(unsigned int argCount, char** signature, BOOL* freeSignature);


// verifies whether a string is a legitimate selector name
BOOL isLegitSelector(NSString* string);

// verifies that a property name is legitimate and not already in use
BOOL _isLegitPropertyName(NSString* name, NSDictionary* properties, NSString** reason);

// counts the number of parameters (colons) in a selector
unsigned int getSelectorParameterCount(SEL selector);



extern NSString* FSClassException;

// This function constructs and raises an NSException
void ThrowException(NSString* reason, NSString* string, NSDictionary* info);

// turns a setFoo: property name into just 'foo'. Caller must free string.
char* makePropertyNameFromSetSelector(SEL selector);


// returns the metaclass for a class
Class class_getMetaclass(Class c);
