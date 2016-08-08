//
//  FSClass.m
//  FSClass
//
//  Created by Andrew Weinrich on 11/12/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//

#import <objc/objc.h>
#import <objc/objc-runtime.h>

#import <string.h>

#import <Foundation/NSObject.h>


#import "FSClass.h"
#import "FSClassCreation.h"

#import "Callbacks.h"
#import "FSClassStringUtil.h"
#import "Trampoline.h"
#import "Functions.h"

@implementation FSClass



@synthesize classObject;
@synthesize hasIvarDictionary;
@synthesize parentAllocImp;
@synthesize parentFSClass=parentClass;
@synthesize properties;


/*
 *
 *  Initializers
 *
 */
#pragma mark -
#pragma mark Initializers



- (FSClass*) init:(NSString*)name {
    self = [super init];
    
    // set up our internal data
    properties              = [[NSMutableDictionary alloc] init];
    methods                 = [[NSMutableDictionary alloc] init];
    trampedMethods          = [[NSMutableDictionary alloc] init];
    classProperties         = [[NSMutableDictionary alloc] init];
    classMethods            = [[NSMutableDictionary alloc] init];
    childClasses            = [[NSMutableArray alloc] init];
    
    className = name;
    
    return self;
}    




- (FSClass*) initNewClass:(NSString*)name parent:(id)parent iVars:(NSArray*)iVars {
    self = [self init:name];
    
    FSClass* fsClassParent = [FSClass classForPointer:parent];
    objcParent = fsClassParent==nil;
    if (!objcParent && parent!=[parent class])
        ThrowException(NSInvalidArgumentException,@"Attempt to use non-FSClass, non Objective-C class as parent", nil);
    
    if (![name isKindOfClass:[NSString class]])
        ThrowException(NSInvalidArgumentException,[NSString stringWithFormat:@"Non-name object %@ submitted as class name", name], nil);
    
    if (![name canBeConvertedToEncoding:NSASCIIStringEncoding])
        ThrowException(NSInvalidArgumentException,@"Supplied class name contains non-ASCII characters", nil);
    
    if (name) {
        anonymous = NO;
        className = name;
    }
    else {
        anonymous = YES;
        className = nil;
    }
    
    classObject = createNewClass(name, [parent class], objcParent, iVars);
    metaclassObject = class_getMetaclass(classObject);
    
    // save parent class reference, or pointer to original alloc implementation
    if (!objcParent) {
        parentClass = fsClassParent;
        parentAllocImp = [parentClass parentAllocImp];
    }
    else {
        parentClass = nil;
        parentAllocImp = method_getImplementation(class_getClassMethod(class_getMetaclass(parent), @selector(alloc)));
    }

    /// keep an instance of this proxy for future reference
    [FSClass registerClass:self forName:name];
    
    return self;
}





- (FSClass*) initFastIvarsClass:(NSString*)name parent:(id)parent properties:(NSDictionary*)iVars {
    if (parent!=[parent class])
        ThrowException(NSInvalidArgumentException,@"Attempt to use non-FSClass, non Objective-C class as parent", nil);
    
    if (![iVars isKindOfClass:[NSDictionary class]])
        ThrowException(NSInvalidArgumentException,@"Invalid collection passed for properties", nil);
    
    
    FSClass* parentFSClass = [FSClass classForPointer:parent];
    objcParent = parentFSClass==nil;
    
    // make sure that the property names are all valid
    NSArray* keys = nil;
    if (iVars) {
        keys = [iVars allKeys];
        NSString* reason;
        for (NSString* s in keys) {
            if (!_isLegitPropertyName(s,nil,&reason))
                ThrowException(FSClassException,[NSString stringWithFormat:reason, s], nil);
            // make sure the parent doesn't already use the property
            if (!objcParent && [parentFSClass _hasProperty:s]) 
                ThrowException(FSClassException,[NSString stringWithFormat:@"Property name '%@' is already is use", s], nil);
        }
    }
    
    
    self = [self initNewClass:name parent:parent iVars:keys];
    
    
    // record instance variables with nil defaults
    if (iVars) {
        NSEnumerator* en = [keys objectEnumerator];
        id propName;
        while (propName = [en nextObject])
            [properties setValue:[iVars objectForKey:propName] forKey:propName];
    }
    
    
    isObjectiveC = NO;
    useFastIvars = YES;
    hasIvarDictionary = parentFSClass ? [parentFSClass hasIvarDictionary] : NO;
    
    return self;
}


- (FSClass*) initRegularIvarsClass:(NSString*)name parent:(id)parent {
    // if this class has an FSClass parent that already has an ivars dictionary, don't add one
    FSClass* parentFSClass = [FSClass classForPointer:parent];
    NSArray* iVars = (parentFSClass && [parentFSClass hasIvarDictionary]) 
                        ? [NSArray array] : [NSArray arrayWithObject:IVAR_PROP_DICTIONARY_STRING];
    
    self = [self initNewClass:name parent:parent iVars:iVars];
    
    isObjectiveC = NO;
    useFastIvars = NO;
    hasIvarDictionary = YES;
    
    return self;
}

- (FSClass*) initProxyClass:(Class)classObj {
    // make sure this is really an Objective-C class
    if (classObj != [classObj class])
        ThrowException(FSClassException,[NSString stringWithFormat:@"Attempt to create proxy from non-ObjectiveC class: %@", classObj], nil);
    
    // if we accidentally try to create a proxy for an existing class, will just return that class
    // can't use [FSClass shadowForClass:] because that would try to create the object again
    FSClass* existingProxy = [FSClass classForPointer:classObj];
    if (existingProxy)
        return existingProxy;
    
    NSString* objcClassName = NSStringFromClass(classObj);
    self = [self init:objcClassName];
    classObject = classObj;
    metaclassObject = class_getMetaclass(classObj);
    
    /// keep an instance of this proxy for future reference
    [FSClass registerClass:self forName:objcClassName];
    
    
    isObjectiveC = YES;
    useFastIvars = NO;
    hasIvarDictionary = NO;
    parentClass = nil;
    
    return self;
}








#pragma mark -
#pragma mark CLASS PROPERTY ACCESSOR / MUTATOR METHODS

// methods to properly retrieve and set properties - used to get around the inheritance problems
- (id) _getClassProperty:(NSString*)propertyName {
    id propValue = [classProperties objectForKey:propertyName];
    if (propValue) {
        if (propValue==[NSNull null])
            return nil;
        else 
            return propValue;
    }
    else if (parentClass) {
        return [parentClass _getClassProperty:propertyName];
    }
    else {
        ThrowException(@"FSClassException",
                       [NSString stringWithFormat:@"Attempt to get non-existent class property: '%@'", propertyName],
                       nil);
        return nil;
    }
}

- (void) _setClassProperty:(NSString*)propertyName toValue:(id)newValue {
    id propValue = [classProperties objectForKey:propertyName];
    if (propValue) {
        if (newValue==nil)
            [classProperties setObject:[NSNull null] forKey:propertyName];
        else 
            [classProperties setObject:newValue forKey:propertyName];
    }
    else if (parentClass) {
        [parentClass _setClassProperty:propertyName toValue:newValue];
    }
    else {
        ThrowException(@"FSClassException",
                       [NSString stringWithFormat:@"Attempt to set non-existent class property: '%@'", propertyName],
                       nil);
    }
}







/*
 *  Instance methods to create subclasses
 */
#pragma mark -
#pragma mark Subclassing Methods
- (Class) subclass {
    return [FSClass newClass:nil parent:self];
}

- (Class) subclass:(NSString*) name {
    return [FSClass newClass:name parent:self];
}









/*
 *
 *  PROPERTY PROTOTYPING - mostly implemented in FSRegularClass
 *
 */
#pragma mark -
#pragma mark Property Methods
- (void) addClassProperty:(NSString*)name {
    [self addClassProperty:name withValue:nil];
}

- (void) addClassProperty:(NSString*)name withValue:(id)value {
    // verify that the name is valid, throw an error if not
    NSString* reason;
    if (!_isLegitPropertyName(name,classProperties,&reason)) {
        ThrowException(FSClassException, [NSString stringWithFormat:@"Attempt to add existing class property: '%@'", name], nil);
    }
    
    // make sure the parent doesn't already use the property
    if ([self _hasClassProperty:name]) 
        ThrowException(NSInvalidArgumentException,[NSString stringWithFormat:@"Class property name '%@' is already is use", name],nil);
    
    
    // turn nil defaults into NSNull
    value = value ? value : [NSNull null];
    
    [classProperties setObject:value forKey:name];
    
    // add callbacks for the set/get methods
    [self _installMethod:(IMP)getClassProperty
        asInstanceMethod:NO
                argCount:0
                selector:NSSelectorFromString(name)
          usesTrampoline:NO];
    
    [self _installMethod:(IMP)setClassProperty
        asInstanceMethod:NO
                argCount:1
                selector:NSSelectorFromString([NSString stringWithFormat:@"set%@:",[name uppercaseFirst]])
          usesTrampoline:NO];
}





- (void) addProperty:(NSString*)name {
    [self addProperty:name withDefault:nil];
}

- (void) addProperty:(NSString*)name withDefault:(id)defaultValue {
    // check for proxies and fast-ivar classes first
    if (isObjectiveC)
        ThrowException(FSClassException, @"Cannot add property to an existing Objective-C class", nil);
    if (useFastIvars)
        ThrowException(FSClassException, @"Cannot add property to a fast-ivars F-Script class", nil);
    
    // verify that the name is valid, throw an error if not
    NSString* reason;
    if (!_isLegitPropertyName(name,properties,&reason)) {
        ThrowException(FSClassException, [NSString stringWithFormat:reason, name], nil);
    }
    
    
    // make sure the parent doesn't already use the property
    if ([self _hasProperty:name]) 
        ThrowException(NSInvalidArgumentException,[NSString stringWithFormat:@"Property name '%@' is already is use", name],nil);
    
    
    // turn nil defaults into NSNull
    defaultValue = defaultValue ? defaultValue : [NSNull null];
    
    
    [properties setObject:defaultValue forKey:name];
    
    // add callbacks for the set/get methods
    [self _installMethod:(IMP)getInstanceProperty
        asInstanceMethod:YES
                argCount:0
                selector:NSSelectorFromString(name)
          usesTrampoline:NO];
    
    [self _installMethod:(IMP)setInstanceProperty
        asInstanceMethod:YES
                argCount:1
                selector:NSSelectorFromString([NSString stringWithFormat:@"set%@:",[name uppercaseFirst]])
          usesTrampoline:NO];
}

- (void) addPropertiesWithDefaults:(NSArray*)propertiesWithDefaults {
    int propCount = [propertiesWithDefaults count];
    for (int i=0; i<propCount; i+=2)
        [self addProperty:[propertiesWithDefaults objectAtIndex:i] withDefault:[propertiesWithDefaults objectAtIndex:i+1]];
}

- (void) addPropertiesFromDictionary:(NSDictionary*)propertyDictionary {
    for (NSString* key in [propertyDictionary allKeys])
        [self addProperty:key withDefault:[propertyDictionary objectForKey:key]];
}

- (id) defaultValueForProperty:(NSString*)property {
    id defaultValue = [properties objectForKey:property];
    
    if (defaultValue)
        return defaultValue==[NSNull null] ? nil : defaultValue;
    else if (parentClass)
        return [parentClass defaultValueForProperty:property];
    else
        ThrowException(FSClassException,
                       [NSString stringWithFormat:@"Attempt to get default value for non-existent property %@", property], 
                       nil);
    
    return nil;
}

- (void) setDefaultValue:(id)newDefault forProperty:(NSString*)property {
    id currentDefault = [properties objectForKey:property];
    
    if (!currentDefault)
        ThrowException(FSClassException,
                       [NSString stringWithFormat:@"Attempt to set default value for non-existent property %@", property], 
                       nil);
    [properties setObject:(newDefault ? newDefault : [NSNull null]) forKey:property];
}



/*
 *
 *  METHOD PROTOTYPING - mostly implemented in FSRegularClass
 *
 */
#pragma mark -
#pragma mark METHODS METHODS

- (void) _onMessage:(SEL)selector do:(id)block instanceMethod:(BOOL)instanceMethod {
    // check to make sure this is a non-nil block
    if (![block isMemberOfClass:[Block class]])
        ThrowException(NSInvalidArgumentException,@"Non-block supplied to onMessage:do:",nil);
    
    NSMutableDictionary* methodsDictionary = instanceMethod ? methods : classMethods;
    
    
    // check that argument counts match
    unsigned int blockArgCount = [block argumentCount];
    unsigned int selectorArgCount = getSelectorParameterCount(selector);
    if (selectorArgCount+1 != blockArgCount)
        ThrowException(NSInvalidArgumentException,[NSString stringWithFormat:@"Wrong number of parameters for method %@ (needed %i, got %i)",
                                                   NSStringFromSelector(selector),blockArgCount,selectorArgCount], nil);
    
    // set this block as the implementation for this class and all child classes
    NSValue* selectorValue = [NSValue valueWithPointer:selector];
    
    // create a trampoline if necessary for the block, and install to the ObjC class
    IMP impFunction;
    Trampoline trampoline;
    BOOL usesTrampoline;
    
    if (selectorArgCount <= TRAMPOLINE_MAX_ARG_COUNT) {
        trampoline = createMethodTrampoline(selectorArgCount, block);
        impFunction = TRAMPOLINE_GET_CODE(trampoline);
        usesTrampoline = YES;
    }
    else {
        usesTrampoline = NO;
        switch (selectorArgCount) {
            case 0: impFunction = instanceMethod ? (IMP)runInstanceMethodArgs0 : (IMP)runClassMethodArgs0; break;
            case 1: impFunction = instanceMethod ? (IMP)runInstanceMethodArgs1 : (IMP)runClassMethodArgs1; break;
            case 2: impFunction = instanceMethod ? (IMP)runInstanceMethodArgs2 : (IMP)runClassMethodArgs2; break;
            case 3: impFunction = instanceMethod ? (IMP)runInstanceMethodArgs3 : (IMP)runClassMethodArgs3; break;
            case 4: impFunction = instanceMethod ? (IMP)runInstanceMethodArgs4 : (IMP)runClassMethodArgs4; break;
            case 5: impFunction = instanceMethod ? (IMP)runInstanceMethodArgs5 : (IMP)runClassMethodArgs5; break;
            case 6: impFunction = instanceMethod ? (IMP)runInstanceMethodArgs6 : (IMP)runClassMethodArgs6; break;
            case 7: impFunction = instanceMethod ? (IMP)runInstanceMethodArgs7 : (IMP)runClassMethodArgs7; break;
            case 8: impFunction = instanceMethod ? (IMP)runInstanceMethodArgs8 : (IMP)runClassMethodArgs8; break;
            case 9: impFunction = instanceMethod ? (IMP)runInstanceMethodArgs9 : (IMP)runClassMethodArgs9; break;
            case 10: impFunction = instanceMethod ? (IMP)runInstanceMethodArgs10 : (IMP)runClassMethodArgs10; break;
            case 11: impFunction = instanceMethod ? (IMP)runInstanceMethodArgs11 : (IMP)runClassMethodArgs11; break;
            default: ThrowException(@"FSClassException", [NSString stringWithFormat:@"Attempt to add a method with too many arguments (max 11, given %i)",selectorArgCount], nil); break;
        }
        
        //impFunction = instanceMethod ? runInstanceMethodArgsX : runClassMethodArgsX;
    }
    
    [self _installMethod:impFunction
        asInstanceMethod:instanceMethod
                argCount:selectorArgCount
                selector:selector
          usesTrampoline:usesTrampoline];

    [methodsDictionary setObject:block forKey:selectorValue];
}



- (void) onMessage:(SEL)message do:(id)block {
    [self _onMessage:message do:block instanceMethod:YES];
}


- (void) onMessageName:(NSString*)messageName do:(id)block {
    // make sure the selector only contains valid characters
    if (!isLegitSelector(messageName))
        ThrowException(NSInvalidArgumentException, 
                       [NSString stringWithFormat:@"Message name with illegal characters passed to onMessageName:do: '%@'",messageName], 
                       nil);
    
    [self onMessage:NSSelectorFromString(messageName) do:block];
}

- (void) onClassMessage:(SEL)message do:(id)block {
    [self _onMessage:message do:block instanceMethod:NO];
}










/*
 *
 *  REFLECTION METHODS
 *
 */
#pragma mark -
#pragma mark INSTANCE INTROSPECTION METHODS
- (NSArray*) methods {
    NSMutableArray* methodArray = [NSMutableArray array];
    
    for (NSValue* selectorValue in [methods allKeys])
        [methodArray addObject:[Block blockWithSelector:((SEL)[selectorValue pointerValue])]];
    
    return methodArray;
}


- (NSArray*) allMethods {
    NSMutableArray* methodArray = [NSMutableArray array];
    
    for (NSValue* selectorValue in [methods allKeys])
        [methodArray addObject:[Block blockWithSelector:((SEL)[selectorValue pointerValue])]];
    
    // add parent class's methods
    if (parentClass)
        [methodArray addObjectsFromArray:[parentClass allMethods]];
    
    return methodArray;
}


- (NSArray*) methodNames {
    NSMutableArray* methodArray = [NSMutableArray array];
    
    for (NSValue* selectorValue in [methods allKeys])
        [methodArray addObject:NSStringFromSelector((SEL)[selectorValue pointerValue])];
    
    return methodArray;
}


- (NSArray*) allMethodNames {
    NSMutableArray* methodArray = [NSMutableArray array];
    
    for (NSValue* selectorValue in [methods allKeys])
        [methodArray addObject:NSStringFromSelector((SEL)[selectorValue pointerValue])];
    
    // add parent class's methods
    if (parentClass)
        [methodArray addObjectsFromArray:[parentClass allMethodNames]];
    
    return methodArray;
}

- (NSArray*) propertyNames {
    return [properties allKeys];
}

- (NSArray*) allPropertyNames {
    NSMutableArray* names = [NSMutableArray arrayWithArray:[properties allKeys]];
    // add parent class's properties
    if (parentClass)
        [names addObjectsFromArray:[parentClass allPropertyNames]];
    return names;
}


- (id) blockForSelector:(SEL)selector {
    id block = [methods objectForKey:[NSValue valueWithPointer:selector]];
    
    if (block)
        return block;
    else if (parentClass)
        return [parentClass blockForSelector:selector];
    else
        return nil;
}

- (id) blockForClassSelector:(SEL)selector {
    return [classMethods objectForKey:[NSValue valueWithPointer:selector]];
}


- (Class) methodImplementor:(SEL)selector {
    id block = [methods objectForKey:[NSValue valueWithPointer:selector]];
    
    if (block==nil && parentClass==nil)
        return nil;
    else if (block!=nil)
        return classObject;
    else
        return [parentClass methodImplementor:selector];
}









#pragma mark -
#pragma mark CLASS INTROSPECTION METHODS
- (NSArray*) classMethodNames {
    NSMutableArray* methodArray = [NSMutableArray array];
    
    for (NSValue* selectorValue in [methods allKeys])
        [methodArray addObject:NSStringFromSelector((SEL)[selectorValue pointerValue])];
    
    return methodArray;
}

- (NSArray*) allClassMethodNames {
    NSMutableArray* methodArray = [NSMutableArray array];
    
    for (NSValue* selectorValue in [methods allKeys])
        [methodArray addObject:NSStringFromSelector((SEL)[selectorValue pointerValue])];
    
    // add parent class's methods
    if (parentClass)
        [methodArray addObjectsFromArray:[parentClass allClassMethodNames]];
    
    return methodArray;
}




- (NSArray*) classMethods {
    NSArray* keys = [classMethods allKeys];
    unsigned int keysCount = [keys count];
    NSMutableArray* methodArray = [NSMutableArray array];
    
    for (unsigned int i = 0; i<keysCount; i++) {
        NSValue* selectorValue = [keys objectAtIndex:i];
        [methodArray addObject:[Block blockWithSelector:((SEL)[selectorValue pointerValue])]];
    }
    
    return methodArray;
}


- (NSArray*) allClassMethods {
    NSMutableArray* methodArray = [NSMutableArray array];
    
    for (NSValue* selectorValue in [methods allKeys])
        [methodArray addObject:NSStringFromSelector((SEL)[selectorValue pointerValue])];
    
    // add parent class's methods
    if (parentClass)
        [methodArray addObjectsFromArray:[parentClass allClassMethods]];
    
    return methodArray;
}


- (NSArray*) classPropertyNames {
    return [classProperties allKeys];
}

- (NSArray*) allClassPropertyNames {
    NSMutableArray* names = [NSMutableArray arrayWithArray:[classProperties allKeys]];
    // add parent class's properties
    if (parentClass)
        [names addObjectsFromArray:[parentClass allClassPropertyNames]];
    return names;
}


- (id) blockClassForSelector:(SEL)selector {
    id block = [classMethods objectForKey:[NSValue valueWithPointer:selector]];
    
    if (block)
        return block;
    else if (parentClass)
        return [parentClass blockClassForSelector:selector];
    else
        return nil;
}

- (Class) classMethodImplementor:(SEL)selector {
    id block = [self blockForClassSelector:selector];
    
    if (block)
        return classObject;
    else if (parentClass)
        return [parentClass classMethodImplementor:selector];
    else
        return nil;
}






#pragma mark -
#pragma mark Miscellaneous Methods
/*
 *
 *  MISCELLANEOUS PUBLIC METHODS
 *
 */
- (NSString*) description {
    return anonymous ? @"<anonymous FSClass>" : className;
}



- (NSArray*) childClasses {
    return childClasses;
}














// Deallocator - no longer needed with garbage collection
/*
 - (void) dealloc {
     [properties release];
     [methods release];
     [trampedMethods release];
     [classProperties release];
     [classMethods release];
     [classMethodSignatures release];
     [classAccessorSignatures release];
     [classMutatorSignatures release];
     [childClasses release];
     
     [className release];
     [parentClass release];
     
     [super dealloc];
}
*/



typedef Method (*getMethodFunc)(Class,SEL);


- (void) _installMethod:(IMP)method
      asInstanceMethod:(BOOL)isInstanceMethod
              argCount:(int)argCount
              selector:(SEL)selector
        usesTrampoline:(BOOL)usesTrampoline
{
    NSValue* selectorValue = [NSValue valueWithPointer:selector];
    Class classObj                  = isInstanceMethod ? classObject : metaclassObject;
    NSDictionary* methodsDictionary = isInstanceMethod ? methods : classMethods;
    
    // Not having the free below causes memory leaks, but leaving it in causes an odd illegal instruction
    // trap somewhere in the Foundation invocation code, possibly something that's being called from the
    // F-Script runtime.
    /*
    // if this method has already been installed (i.e. we are replacing it with a new block), remove first
    if ([methodsDictionary objectForKey:[NSValue valueWithPointer:selector]]) {
        Method oldMethod = isInstanceMethod ? class_getInstanceMethod(classObject,selector)
                                            : class_getClassMethod(classObject,selector);
        IMP oldMethodImp = method_getImplementation(oldMethod);
        // if this was a trampolined method, remove the trampedMethods first
        if ([[trampedMethods objectForKey:selectorValue] boolValue]) {
            //free(TRAMPOLINE_FROM_FUNC_POINTER(oldMethodImp));
        }
    }
     */
    
    // create a type signature - return type (@), this (@), selector (:), number of arguments
	char* signature;
    BOOL dummy;
    createMethodSignature(argCount,&signature,&dummy);
    
    
    // try to add to the class first. If the class already has this method, replace the selector
    if (![methodsDictionary objectForKey:selectorValue]) {
        class_addMethod(classObj,selector,method,signature);
    }
    else {
        Method oldMethod = isInstanceMethod ? class_getInstanceMethod(classObject,selector)
                                            : class_getClassMethod(classObject,selector);
        method_setImplementation(oldMethod, method);
    }
    
    // record whether this method uses a trampedMethods
    [trampedMethods setObject:[NSNumber numberWithBool:usesTrampoline] forKey:selectorValue];
}






- (BOOL) _hasProperty:(NSString*)name {
    if ([properties objectForKey:name])
        return YES;
    else if (parentClass)
        return [parentClass _hasProperty:name];
    else
        return NO;
}

- (BOOL) _hasClassProperty:(NSString*)name {
    if ([classProperties objectForKey:name])
        return YES;
    else if (parentClass)
        return [parentClass _hasClassProperty:name];
    else
        return NO;
}







@end


/*
 This category contains implementations for some of the methods from the Block class. These serve only
 to prevent compiler warnings that a signature for these selectors cannot be found
 */
@implementation CompilerComplaints
- (id) valueWithArguments:(NSArray*)arguments {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}
+ (id) blockWithSelector:(SEL)selector {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}
- (int) argumentCount {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return 0;
}
- (id) replace:(id)pattern with:(id)replacement {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}

- (id) value {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}
- (id) value:(id)arg1 {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}
- (id) value:(id)arg1 value:(id)arg2 {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5 {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5 value:(id)arg6 {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5 value:(id)arg6 value:(id)arg7 {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5 value:(id)arg6 value:(id)arg7 value:(id)arg8 {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5 value:(id)arg6 value:(id)arg7 value:(id)arg8 value:(id)arg9 {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5 value:(id)arg6 value:(id)arg7 value:(id)arg8 value:(id)arg9 value:(id)arg10 {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5 value:(id)arg6 value:(id)arg7 value:(id)arg8 value:(id)arg9 value:(id)arg10 value:(id)arg11 {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5 value:(id)arg6 value:(id)arg7 value:(id)arg8 value:(id)arg9 value:(id)arg10 value:(id)arg11 value:(id)arg12 {
    ThrowException(FSClassException, @"Attempt to call invalid method",nil);
    return nil;
}

@end










