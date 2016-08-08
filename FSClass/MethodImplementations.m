//
//  MethodImplementations.m
//  FSClass
//
//  Created by Andrew Weinrich on 12/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "MethodImplementations.h"
#import "FSClassCreation.h"

/*
 *  Instance methods to create subclasses
 */
Class _subclass(id thisClass, SEL selector) {
    return [[FSClass shadowForClass:thisClass] subclass];
}

Class _subclassWithName(id thisClass, SEL selector, NSString* name) {
    return [[FSClass shadowForClass:thisClass] subclass:name];
}






/*
 *
 *  PROPERTY PROTOTYPING - mostly implemented in FSRegularClass
 *
 */
#pragma mark -
#pragma mark Property Methods
void _addClassProperty(id thisClass, SEL selector, NSString* name) {
    [[FSClass shadowForClass:thisClass] addClassProperty:name];
}

void _addClassPropertyWithValue(id thisClass, SEL selector, NSString* name, id value) {
    [[FSClass shadowForClass:thisClass] addClassProperty:name withValue:value];
}

void _addProperty(id thisClass, SEL selector, NSString* name) {
    [[FSClass shadowForClass:thisClass] addProperty:name];
}

void _addPropertyWithDefault(id thisClass, SEL selector, NSString* name, id defaultValue) {
    [[FSClass shadowForClass:thisClass] addProperty:name withDefault:defaultValue];
}

void _addPropertiesWithDefaults(id thisClass, SEL selector, NSArray* propertiesWithDefaults) {
    [[FSClass shadowForClass:thisClass] addPropertiesWithDefaults:propertiesWithDefaults];
}

void _addPropertiesFromDictionary(id thisClass, SEL selector, NSDictionary* propertyDictionary) {
    [[FSClass shadowForClass:thisClass] addPropertiesFromDictionary:propertyDictionary];
}

id _defaultValueForProperty(id thisClass, SEL selector, NSString* property) {
    return [[FSClass shadowForClass:thisClass] defaultValueForProperty:property];
}

void _setDefaultValueForProperty(id thisClass, SEL selector, id newDefault, NSString* property) {
    [[FSClass shadowForClass:thisClass] setDefaultValue:newDefault forProperty:property];
}



/*
 *
 *  METHOD PROTOTYPING - mostly implemented in FSRegularClass
 *
 */
#pragma mark -
#pragma mark Method Methods
void _onMessageDo(id thisClass, SEL selector, SEL message, id block) {
    [[FSClass shadowForClass:thisClass] onMessage:message do:block];
}

void _onMessageNameDo(id thisClass, SEL selector, NSString* messageName, id block) {
    [[FSClass shadowForClass:thisClass] onMessageName:messageName do:block];
}

void _onClassMessageDo(id thisClass, SEL selector, SEL message, id block) {
    [[FSClass shadowForClass:thisClass] onClassMessage:message do:block];
}







/*
 *
 *  REFLECTION METHODS
 *
 */
#pragma mark -
#pragma mark Reflection Method Implementations

// Instance reflection
NSArray* _methods(id thisClass, SEL selector) {
    return [[FSClass shadowForClass:thisClass] methods];
}

NSArray* _allMethods(id thisClass, SEL selector) {
    return [[FSClass shadowForClass:thisClass] allMethods];
}

NSArray* _methodNames(id thisClass, SEL selector) {
    return [[FSClass shadowForClass:thisClass] methodNames];
}

NSArray* _allMethodNames(id thisClass, SEL selector) {
    return [[FSClass shadowForClass:thisClass] allMethodNames];
}

NSArray* _propertyNames(id thisClass, SEL selector) {
    return [[FSClass shadowForClass:thisClass] propertyNames];
}

NSArray* _allPropertyNames(id thisClass, SEL selector) {
    return [[FSClass shadowForClass:thisClass] allPropertyNames];
}

id _blockForSelector(id thisClass, SEL selector, SEL message) {
    return [[FSClass shadowForClass:thisClass] blockForSelector:message];
}

Class _methodImplementor(id thisClass, SEL selector, SEL message) {
    return [[FSClass shadowForClass:thisClass] methodImplementor:message];
}


// Class reflection
NSArray* _classMethods(id thisClass, SEL selector) {
    return [[FSClass shadowForClass:thisClass] classMethods];
}

NSArray* _classMethodNames(id thisClass, SEL selector) {
    return [[FSClass shadowForClass:thisClass] classMethodNames];
}

NSArray* _allClassMethods(id thisClass, SEL selector) {
    return [[FSClass shadowForClass:thisClass] allClassMethods];
}

NSArray* _allClassMethodNames(id thisClass, SEL selector) {
    return [[FSClass shadowForClass:thisClass] allClassMethodNames];
}

NSArray* _classPropertyNames(id thisClass, SEL selector) {
    return [[FSClass shadowForClass:thisClass] classPropertyNames];
}

NSArray* _allClassPropertyNames(id thisClass, SEL selector) {
    return [[FSClass shadowForClass:thisClass] allClassPropertyNames];
}

id _blockForClassSelector(id thisClass, SEL selector, SEL message) {
    return [[FSClass shadowForClass:thisClass] blockForClassSelector:message];
}


Class _classMethodImplementor(id thisClass, SEL selector, SEL message) {
    return [[FSClass shadowForClass:thisClass] classMethodImplementor:message];
}





