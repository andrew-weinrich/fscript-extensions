//
//  FSClassCreation.m
//  FSClassCreation
//
//  Created by Andrew Weinrich on 11/12/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//


#import "FSClassCreation.h"

#import <objc/runtime.h>
#import <objc/message.h>

#import <string.h>

#import <Foundation/NSObject.h>


#import "FSClass.h"

#import "Callbacks.h"
#import "MethodImplementations.h"


#import "FSClassStringUtil.h"
#import "Trampoline.h"
#import "Functions.h"

const char* IVAR_FS_CLASS = "__fsclass_class";
const char* IVAR_PROP_DICTIONARY = "__fsclass_properties";    // only used if fast ivars are not enabled
NSString* IVAR_FS_CLASS_STRING = @"__fsclass_class";
NSString* IVAR_PROP_DICTIONARY_STRING = @"__fsclass_properties";



Class Block = nil;




@implementation FSClass (FSClassCreation)

/*
 * These variables are "static" class data used for internal recordkeeping
 */
static int classCounter = 0;   // counter to create unique names for our classes
static NSMutableDictionary* classDefinitions = nil;     // maps class names to FSClass objects
static NSMutableDictionary* classNamesByPointer = nil;
static BOOL initialized = NO;



// class initialization method
+ (void) initialize {
    if (!initialized) {
        classDefinitions    = [[NSMutableDictionary alloc] init];
        classNamesByPointer = [[NSMutableDictionary alloc] init];
        
        Block = NSClassFromString(@"Block");
        
        initialized = YES;
        
        // add top-level methods to NSObject
        Class nsObjectMetaclass = class_getMetaclass([NSObject class]);
        
        class_addMethod(nsObjectMetaclass, @selector(subclass), (IMP)_subclass, "@@:");
        class_addMethod(nsObjectMetaclass, @selector(subclass:), (IMP)_subclassWithName, "@@:@");
        
        // property addition
        class_addMethod(nsObjectMetaclass, @selector(addClassProperty:), (IMP)_addClassProperty, "v@:@");
        class_addMethod(nsObjectMetaclass, @selector(addClassProperty:withValue:), (IMP)_addClassPropertyWithValue, "v@:@@");
        class_addMethod(nsObjectMetaclass, @selector(addProperty:), (IMP)_addProperty, "v@:@");
        class_addMethod(nsObjectMetaclass, @selector(addProperty:withDefault:), (IMP)_addPropertyWithDefault, "v@:@@");
        class_addMethod(nsObjectMetaclass, @selector(addPropertiesFromDictionary:), (IMP)_addPropertiesFromDictionary, "v@:@");
        class_addMethod(nsObjectMetaclass, @selector(addPropertiesWithDefaults:), (IMP)_addPropertiesWithDefaults, "v@:@");
        class_addMethod(nsObjectMetaclass, @selector(setDefaultValue:forProperty:), (IMP)_setDefaultValueForProperty, "v@:@@");
        class_addMethod(nsObjectMetaclass, @selector(defaultValueForProperty:), (IMP)_defaultValueForProperty, "@@:@");
        
        // instance property / method introspection
        class_addMethod(nsObjectMetaclass, @selector(methods), (IMP)_methods, "@@:");
        class_addMethod(nsObjectMetaclass, @selector(allMethods), (IMP)_allMethods, "@@:");
        class_addMethod(nsObjectMetaclass, @selector(methodNames), (IMP)_methodNames, "@@:");
        class_addMethod(nsObjectMetaclass, @selector(allMethodNames), (IMP)_allMethodNames, "@@:");
        class_addMethod(nsObjectMetaclass, @selector(propertyNames), (IMP)_propertyNames, "@@:");
        class_addMethod(nsObjectMetaclass, @selector(allPropertyNames), (IMP)_allPropertyNames, "@@:");
        class_addMethod(nsObjectMetaclass, @selector(propertyNames), (IMP)_classPropertyNames, "@@:");
        class_addMethod(nsObjectMetaclass, @selector(blockForSelector:), (IMP)_blockForSelector, "@@::");
        class_addMethod(nsObjectMetaclass, @selector(methodImplementor:), (IMP)_methodImplementor, "@@::");
        
        // class property / method introspection
        class_addMethod(nsObjectMetaclass, @selector(classMethods), (IMP)_classMethods, "@@:");
        class_addMethod(nsObjectMetaclass, @selector(allClassMethods), (IMP)_allClassMethods, "@@:");
        class_addMethod(nsObjectMetaclass, @selector(classMethodNames), (IMP)_classMethodNames, "@@:");
        class_addMethod(nsObjectMetaclass, @selector(allClassMethodNames), (IMP)_allClassMethodNames, "@@:");
        class_addMethod(nsObjectMetaclass, @selector(blockForClassSelector:), (IMP)_blockForClassSelector, "@@::");
        class_addMethod(nsObjectMetaclass, @selector(classMethodImplementor:), (IMP)_classMethodImplementor, "@@::");
        
        // method addition methods
        class_addMethod(nsObjectMetaclass, @selector(onMessage:do:), (IMP)_onMessageDo, "v@::@");
        class_addMethod(nsObjectMetaclass, @selector(onMessageName:do:), (IMP)_onMessageNameDo, "v@:@@");
        class_addMethod(nsObjectMetaclass, @selector(onClassMessage:do:), (IMP)_onClassMessageDo, "v@::@");
    }
}

+ (NSString*) _getAnonymousClassName {
    return [NSString stringWithFormat:@"FSClass%i",++classCounter];
}


+ (void) registerClass:(FSClass*)class forName:(NSString*)name {
    [classDefinitions setObject:class forKey:name];
    [classNamesByPointer setObject:name forKey:[NSValue valueWithPointer:class.classObject]];
}




/*
 *  Constructor factory methods
 *  These methods all actually return an instance of an FSConcreteClass
 */
#pragma mark -
#pragma mark Class Creation Methods


// regular class creation methods
+ (Class) newClass {
    return [FSClass newClassWithParent:[NSObject class]];
}

+ (Class) newClass:(NSString*)name {
    return [FSClass newClass:name parent:[NSObject class]];
}

+ (Class) newClassWithParent:(id)parentClass {
    return [FSClass newClass:[self _getAnonymousClassName] parent:parentClass];
}

+ (Class) newClass:(NSString*)name parent:(id)parentClass {
    return [[[self alloc] initRegularIvarsClass:name parent:parentClass] classObject];
}




// fast-ivars creation methods
+ (Class) newClass:(NSString*)name properties:(NSArray*)iVars {
    return [FSClass newClass:name parent:[NSObject class] properties:iVars];
}

+ (Class) newClass:(NSString*)name parent:(id)parent properties:(NSArray*)iVars {
    if (![iVars isKindOfClass:[NSArray class]])
        ThrowException(NSInvalidArgumentException,@"Invalid collection passed for properties", nil);
    
    NSMutableDictionary* properties = [NSMutableDictionary dictionary];
    for (id key in iVars)
        [properties setObject:[NSNull null] forKey:key];
    
    return [FSClass newClass:name parent:parent propertiesWithDefaults:properties];
}

+ (Class) newClass:(NSString*)name propertiesWithDefaults:(NSDictionary*)iVars {
    return [FSClass newClass:name parent:[NSObject class] propertiesWithDefaults:iVars];
}

+ (Class) newClass:(NSString*)name parent:(id)parentClass propertiesWithDefaults:(NSDictionary*)iVars {
    return [[[self alloc] initFastIvarsClass:name parent:parentClass properties:iVars] classObject];
}









#pragma mark -
#pragma mark Private Methods
/*
 *
 *  PRIVATE METHODS BELOW
 *
 */
+ (FSClass*) _definitionForClass:(NSString*)className {
    return [classDefinitions objectForKey:className];
}



// get the FSClass for a named class, or return a proxy for the Objective-C class, or return nil
+ (FSClass*) classForName:(NSString*)name {
    FSClass* fsClass = [classDefinitions objectForKey:name];
    if (fsClass)
        return fsClass;
    
    Class objcClass = objc_getClass([name cStringUsingEncoding:NSASCIIStringEncoding]);
    if (objcClass)
        return [[self alloc] initProxyClass:objcClass];
    
    return nil;
}

// looks up an FSClass shadow by the Class pointer
+ (FSClass*) classForPointer:(Class)objcClass {
    NSString* className = [classNamesByPointer objectForKey:[NSValue valueWithPointer:objcClass]];
    if (className)
        return [classDefinitions objectForKey:className];
    else
        return nil;
}


// returns a shadow for the specified class. If a shadow does not exist, will create it
+ (FSClass*) shadowForClass:(Class)objcClass {
    NSString* className = [classNamesByPointer objectForKey:[NSValue valueWithPointer:objcClass]];
    if (className)
        return [classDefinitions objectForKey:className];
    else
        return [[self alloc] initProxyClass:objcClass];
}






#pragma mark -
#pragma mark CLASS CREATION FUNCTIONS




// All other newClass-type methods ultimately turn into calls to this method
Class createNewClass(NSString* name, Class parent, BOOL objcParent, NSArray* instanceVars) {
    BOOL anonymous = NO;
    NSString* className = name;
    
    if (!className) {
        anonymous = YES;
        className = [FSClass _getAnonymousClassName];
    }
    
    // add a slot for a reference back to this new class object if we are inheriting from an ObjC class
    const char* classNameString  = [className cStringUsingEncoding:NSASCIIStringEncoding];
    
    // Ensure that the superclass exists and that someone 
    // hasn't already implemented a class with the same name 
    if (objc_lookUpClass(classNameString) != nil)
        ThrowException(FSClassException,[NSString stringWithFormat:@"A class with name '%@' already exists",className], nil);
    
    Class newClass = objc_allocateClassPair(parent, classNameString, 0);
    
    // add ivars with accessor / mutators methods
    int alignment = log2(sizeof(id));
    if (instanceVars) {
        for (NSString* ivarName in instanceVars) {
            class_addIvar(newClass, [ivarName cStringUsingEncoding:NSASCIIStringEncoding], sizeof(id), alignment, "@");
            class_addMethod(newClass, NSSelectorFromString(ivarName), (IMP)getInstancePropertyFast, "@@:");
            class_addMethod(newClass, 
                            NSSelectorFromString([NSString stringWithFormat:@"set%@:",[ivarName uppercaseFirst]]),
                            (IMP)setInstancePropertyFast,
                            "@@:@");
        }
    }
    
    // Finally, register the class with the runtime. 
    objc_registerClassPair(newClass);
    Class metaclass = objc_getMetaClass(classNameString);
    
    // add super: dispatching methods - only needed at top level; base methods will not be initialized
    // if we inherit from a proxy class
    if (objcParent) {
        // special allocator - fills in variable defaults
        class_addMethod(metaclass,@selector(alloc),(IMP)allocator,"@@:");
        
        // instance supermethod workaround
        class_addMethod(newClass,@selector(doSuperMethod:currentClass:),(IMP)superMethod0,"@@:@@");
        class_addMethod(newClass,@selector(doSuperMethod:currentClass:with:),(IMP)superMethod1,"@@:@@@");
        class_addMethod(newClass,@selector(doSuperMethod:currentClass:with:with:),(IMP)superMethod2,"@@:@@@@");
        class_addMethod(newClass,@selector(doSuperMethod:currentClass:with:with:with:),(IMP)superMethod3,"@@:@@@@@");
        class_addMethod(newClass,@selector(doSuperMethod:currentClass:with:with:with:with:),(IMP)superMethod4,"@@:@@@@@@");
        class_addMethod(newClass,@selector(doSuperMethod:currentClass:with:with:with:with:with:),(IMP)superMethod5,"@@:@@@@@@@");
        class_addMethod(newClass,@selector(doSuperMethod:currentClass:withArguments:),(IMP)superMethodMulti,"@@:@@@");
        
        // class supermethod workaround
        class_addMethod(metaclass,@selector(doSuperMethod:currentClass:),(IMP)classSuperMethod0,"@@:@@");
        class_addMethod(metaclass,@selector(doSuperMethod:currentClass:with:),(IMP)classSuperMethod1,"@@:@@@");
        class_addMethod(metaclass,@selector(doSuperMethod:currentClass:with:with:),(IMP)classSuperMethod2,"@@:@@@@");
        class_addMethod(metaclass,@selector(doSuperMethod:currentClass:with:with:with:),(IMP)classSuperMethod3,"@@:@@@@@");
        class_addMethod(metaclass,@selector(doSuperMethod:currentClass:with:with:with:with:),(IMP)classSuperMethod4,"@@:@@@@@@");
        class_addMethod(metaclass,@selector(doSuperMethod:currentClass:with:with:with:with:with:),(IMP)classSuperMethod5,"@@:@@@@@@@");
        class_addMethod(metaclass,@selector(doSuperMethod:currentClass:withArguments:),(IMP)classSuperMethodMulti,"@@:@@@");
        
    }
    
    return newClass;
}







#pragma mark -
#pragma mark UTILITY METHODS
// two utility methods to expose Objective-C functionality
+ (NSString*) stringFromSelector:(SEL)selector {
    return NSStringFromSelector(selector);
}

+ (SEL) selectorFromString:(NSString*)string {
    if (!isLegitSelector(string))
        ThrowException(NSInvalidArgumentException,[NSString stringWithFormat:@"Invalid message name passed to selectorFromString: %@",string], nil);
    
    return NSSelectorFromString(string);
}

// retrieves a previously created class by name - or, create a proxy for an ObjC class and return it
+ (Class) getClass:(NSString*)className {
    return NSClassFromString(className);
}




@end
