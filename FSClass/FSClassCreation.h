//
//  MethodImplementations.h
//  FSClass
//
//  Created by Andrew Weinrich on 12/26/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern Class Block;

#import "FSClass.h"

@interface FSClass (FSClassCreation)

// regular class creation
+ (Class) newClass;
+ (Class) newClass:(NSString*)name;
+ (Class) newClassWithParent:(id)parentClass;
+ (Class) newClass:(NSString*)name parent:(id)parentClass;

// fast-ivars class creation
+ (Class) newClass:(NSString*)name properties:(NSArray*)iVars;
+ (Class) newClass:(NSString*)name parent:(id)parentClass properties:(NSArray*)iVars;
+ (Class) newClass:(NSString*)name propertiesWithDefaults:(NSDictionary*)iVars;
+ (Class) newClass:(NSString*)name parent:(id)parentClass propertiesWithDefaults:(NSDictionary*)iVars;


// Utility Methods
+ (NSString*) stringFromSelector:(SEL)selector;
+ (SEL) selectorFromString:(NSString*)selector;
+ (Class) getClass:(NSString*)className;



// private methods
+ (void) registerClass:(FSClass*)classDef forName:(NSString*)className;
+ (FSClass*) _definitionForClass:(NSString*)className;
+ (FSClass*) shadowForClass:(Class)classPointer;
+ (FSClass*) classForName:(NSString*)name;
+ (FSClass*) classForPointer:(Class)classPointer;


+ (void) initialize;


// creates new, anonymous class names
+ (NSString*) _getAnonymousClassName;


// creates and returns a new Objective-C class with the specified parent (can be either
// and FSClass or a Class) and an optional list of instance variables)
Class createNewClass(NSString* name, Class parent, BOOL objcParent, NSArray* instanceVars);


@end