//
//  MethodImplementations.h
//  FSClass
//
//  Created by Andrew Weinrich on 12/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FSClass.h"

/*
 The functions declared in MethodImplementations are used as callbacks for the
 Objective-C classes. These functions are attached to NSObject in the [FSClass initialize]
 method. The function bodies use the [FSClass shadowForClass:] method, which will create
 a shadow FSClass instance on demand, or look up a previously created one. This avoids
 creating shadows for Objective-C classes until necessary.
*/





/*
 *  Methods to create subclasses
 */
Class _subclass(id thisClass, SEL selector);
Class _subclassWithName(id thisClass, SEL selector, NSString* name);






/*
 *
 *  PROPERTY PROTOTYPING - mostly implemented in FSRegularClass
 *
 */
#pragma mark -
#pragma mark Property Methods
void _addClassProperty(id thisClass, SEL selector, NSString* name);
void _addClassPropertyWithValue(id thisClass, SEL selector, NSString* name, id value);
void _addProperty(id thisClass, SEL selector, NSString* name);
void _addPropertyWithDefault(id thisClass, SEL selector, NSString* name, id defaultValue);
void _addPropertiesWithDefaults(id thisClass, SEL selector, NSArray* propertiesWithDefaults);
void _addPropertiesFromDictionary(id thisClass, SEL selector, NSDictionary* propertyDictionary);
id _defaultValueForProperty(id thisClass, SEL selector, NSString* property);
void _setDefaultValueForProperty(id thisClass, SEL selector, id newDefault, NSString* property);



/*
 *
 *  METHOD PROTOTYPING - mostly implemented in FSRegularClass
 *
 */
#pragma mark -
#pragma mark Method Methods
void _onMessageDo(id thisClass, SEL selector, SEL message, id block);
void _onMessageNameDo(id thisClass, SEL selector, NSString* messageName, id block);
void _onClassMessageDo(id thisClass, SEL selector, SEL message, id block);







/*
 *
 *  REFLECTION METHODS
 *
 */
#pragma mark -
#pragma mark Reflection Method Implementations

// Instance reflection
NSArray* _methods(id thisClass, SEL selector);
NSArray* _allMethods(id thisClass, SEL selector);
NSArray* _methodNames(id thisClass, SEL selector);
NSArray* _allMethodNames(id thisClass, SEL selector);
NSArray* _propertyNames(id thisClass, SEL selector);
NSArray* _allPropertyNames(id thisClass, SEL selector);
id _blockForSelector(id thisClass, SEL selector, SEL message);
_Bool _respondsToSelector(id thisClass, SEL selector, SEL message);
Class _methodImplementor(id thisClass, SEL selector, SEL message);


// Class reflection
NSArray* _classMethods(id thisClass, SEL selector);
NSArray* _classMethodNames(id thisClass, SEL selector);
NSArray* _allClassMethods(id thisClass, SEL selector);
NSArray* _allClassMethodNames(id thisClass, SEL selector);
NSArray* _classPropertyNames(id thisClass, SEL selector);
NSArray* _allClassPropertyNames(id thisClass, SEL selector);
id _blockForClassSelector(id thisClass, SEL selector, SEL message);
_Bool _respondsToClassSelector(id thisClass, SEL selector, SEL message);
Class _classMethodImplementor(id thisClass, SEL selector, SEL message);



