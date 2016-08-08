//
//  Callbacks.m
//  FSClass
//
//  Created by Andrew Weinrich on 11/14/06.
//  Copyright 2006 Andrew Weinrich. All rights reserved.
//

#import "Callbacks.h"
#import <objc/objc.h>
#import <objc/objc-runtime.h>

#import "Functions.h"
#import "FSClass.h"
#import "FSClassCreation.h"
#import "FSClassStringUtil.h"
#import "Trampoline.h"
#import <string.h>




#pragma mark -
#pragma mark alloc:
id allocator(id thisClass, SEL selector) {
    FSClass* fsClass = [FSClass classForPointer:thisClass];
    
    // call [NSObject alloc] first
    IMP allocImp = [fsClass parentAllocImp];
    id newObject = allocImp(thisClass, @selector(alloc));
    
    // create a dictionary if we need one
    if ([fsClass hasIvarDictionary]) {
        NSMutableDictionary* props = [[NSMutableDictionary alloc] init];
        object_setInstanceVariable(newObject,IVAR_PROP_DICTIONARY,props);
    }

    // copy all the default values, including parent classes
    FSClass* currentClass = fsClass;
    while (currentClass) {
        NSDictionary* properties = fsClass.properties;
        NSEnumerator* en = [properties keyEnumerator];
        id key;
        while (key = [en nextObject]) {
            id value = [properties objectForKey:key];
            if (value != [NSNull null]) {  // skip nil properties
                [newObject setValue:value forKey:key];  // use key-value coding for convenience
            }
        }
        
        currentClass = currentClass.parentFSClass;
    }
    
    return newObject;
}





#pragma mark -
#pragma mark PROPERTY ACCESSORS

// gets the property that has the same name as the selector
id getInstanceProperty(id thisId, SEL selector) {
    NSMutableDictionary* properties;
    object_getInstanceVariable(thisId, IVAR_PROP_DICTIONARY, (void**)(&properties));
    
    NSString* propName = NSStringFromSelector(selector);
    
    id object = [properties objectForKey:propName];
    
    // if this object doesn't exist in the properties dictionary, get the class's default value
    if (object==nil) {
        FSClass* currentClass = [FSClass classForPointer:[thisId class]];
        id defaultObject = [currentClass defaultValueForProperty:propName];
        
        // set the default value and return it
        [properties setObject:(defaultObject==nil ? [NSNull null] : defaultObject) forKey:propName];
        
        return defaultObject;
    }
    else if (object == [NSNull null]) {
        return nil; // substitute out an NSNull for an actual nil
    }
    else {
        return object;
    }
}




// gets the property that has the same name as the selector
id getInstancePropertyFast(id thisId, SEL selector) {
    id property;
    const char* selectorName = sel_getName(selector);
    Ivar var = object_getInstanceVariable(thisId, selectorName, (void**)(&property));
    
    // this should never happen, but put in a check to make sure that the
    // instance variable actually exists
    if (!var)
        ThrowException(@"FSInvalidProperty", [NSString stringWithFormat:@"Attempt to access non-existent property %s", selectorName], nil);
    
    return property;
}



#pragma mark -
#pragma mark PROPERTY MUTATORS

// gets the property name from the selector and look it up in the object's dictionary
// chops off the first three characters - 'set' - from the selector name and lowercases the first letter
id setInstanceProperty(id thisId, SEL selector, id newValue) {
    NSMutableDictionary* properties;
    object_getInstanceVariable(thisId, IVAR_PROP_DICTIONARY, (void**)(&properties));
    NSString* selectorString = NSStringFromSelector(selector);
    
    [properties setObject:(newValue ? newValue : [NSNull null])
                   forKey:[[selectorString substringWithRange:NSMakeRange(3,[selectorString length]-4)] lowercaseFirst]];
    return nil;
}




// gets the property name from the selector and look it up in the object's dictionary
// chops off the first three characters - 'set' - from the selector name
id setInstancePropertyFast(id thisId, SEL selector, id newValue) {
    char* propertyName = makePropertyNameFromSetSelector(selector);
    
    // retain / release are now no-ops, so don't bother freeing the old value - just overwrite
    object_setInstanceVariable(thisId,propertyName,newValue);
    
    free(propertyName);
    
    return nil;
}






#pragma mark -
#pragma mark CLASS PROPERTIES

// gets the property that has the same name as the selector
id getClassProperty(id thisClass, SEL selector) {
    return [[FSClass classForPointer:thisClass] _getClassProperty:NSStringFromSelector(selector)];
}

// gets the property name from the selector and look it up in the object's dictionary
// chops off the first three characters - 'set' - from the selector name and lowercases the first letter
id setClassProperty(id thisClass, SEL selector, id newValue) {
    char* propertyName = makePropertyNameFromSetSelector(selector);
    [[FSClass classForPointer:thisClass] _setClassProperty:[NSString stringWithCString:propertyName encoding:NSASCIIStringEncoding] toValue:newValue];
    free(propertyName);
    return nil;
}







#pragma mark -
#pragma mark METHOD IMPLEMENTATION CALLBACKS

id runInstanceMethodArgs0(id this, SEL selector) {
    return [[[FSClass shadowForClass:[this class]] blockForSelector:selector] value:this];
}

id runInstanceMethodArgs1(id this, SEL selector, id arg1) {
    return [[[FSClass shadowForClass:[this class]] blockForSelector:selector] value:this value:arg1];
}

id runInstanceMethodArgs2(id this, SEL selector, id arg1, id arg2) {
    return [[[FSClass shadowForClass:[this class]] blockForSelector:selector] value:this value:arg1 value:arg2];
}

id runInstanceMethodArgs3(id this, SEL selector, id arg1, id arg2, id arg3) {
    return [[[FSClass shadowForClass:[this class]] blockForSelector:selector] value:this value:arg1 value:arg2 value:arg3];
}

id runInstanceMethodArgs4(id this, SEL selector, id arg1, id arg2, id arg3, id arg4) {
    return [[[FSClass shadowForClass:[this class]] blockForSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4];
}

id runInstanceMethodArgs5(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5) {
    return [[[FSClass shadowForClass:[this class]] blockForSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4 value:arg5];
}

id runInstanceMethodArgs6(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6) {
    return [[[FSClass shadowForClass:[this class]] blockForSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4 value:arg5 value:arg6];
}

id runInstanceMethodArgs7(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7) {
    return [[[FSClass shadowForClass:[this class]] blockForSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4 value:arg5 value:arg6 value:arg7];
}

id runInstanceMethodArgs8(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8) {
    return [[[FSClass shadowForClass:[this class]] blockForSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4 value:arg5 value:arg6 value:arg7 value:arg8];
}

id runInstanceMethodArgs9(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9) {
    return [[[FSClass shadowForClass:[this class]] blockForSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4 value:arg5 value:arg6 value:arg7 value:arg8 value:arg9];
}

id runInstanceMethodArgs10(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9, id arg10) {
    return [[[FSClass shadowForClass:[this class]] blockForSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4 value:arg5 value:arg6 value:arg7 value:arg8 value:arg9 value:arg10];
}

id runInstanceMethodArgs11(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9, id arg10, id arg11) {
    return [[[FSClass shadowForClass:[this class]] blockForSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4 value:arg5 value:arg6 value:arg7 value:arg8 value:arg9 value:arg10 value:arg11];
}






id runClassMethodArgs0(id this, SEL selector) {
    return [[[FSClass shadowForClass:[this class]] blockForClassSelector:selector] value:this];
}

id runClassMethodArgs1(id this, SEL selector, id arg1) {
    return [[[FSClass shadowForClass:[this class]] blockForClassSelector:selector] value:this value:arg1];
}

id runClassMethodArgs2(id this, SEL selector, id arg1, id arg2) {
    return [[[FSClass shadowForClass:[this class]] blockForClassSelector:selector] value:this value:arg1 value:arg2];
}

id runClassMethodArgs3(id this, SEL selector, id arg1, id arg2, id arg3) {
    return [[[FSClass shadowForClass:[this class]] blockForClassSelector:selector] value:this value:arg1 value:arg2 value:arg3];
}

id runClassMethodArgs4(id this, SEL selector, id arg1, id arg2, id arg3, id arg4) {
    return [[[FSClass shadowForClass:[this class]] blockForClassSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4];
}

id runClassMethodArgs5(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5) {
    return [[[FSClass shadowForClass:[this class]] blockForClassSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4 value:arg5];
}

id runClassMethodArgs6(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6) {
    return [[[FSClass shadowForClass:[this class]] blockForClassSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4 value:arg5 value:arg6];
}

id runClassMethodArgs7(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7) {
    return [[[FSClass shadowForClass:[this class]] blockForClassSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4 value:arg5 value:arg6 value:arg7];
}

id runClassMethodArgs8(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8) {
    return [[[FSClass shadowForClass:[this class]] blockForClassSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4 value:arg5 value:arg6 value:arg7 value:arg8];
}

id runClassMethodArgs9(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9) {
    return [[[FSClass shadowForClass:[this class]] blockForClassSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4 value:arg5 value:arg6 value:arg7 value:arg8 value:arg9];
}

id runClassMethodArgs10(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9, id arg10) {
    return [[[FSClass shadowForClass:[this class]] blockForClassSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4 value:arg5 value:arg6 value:arg7 value:arg8 value:arg9 value:arg10];
}

id runClassMethodArgs11(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9, id arg10, id arg11) {
    return [[[FSClass shadowForClass:[this class]] blockForClassSelector:selector] value:this value:arg1 value:arg2 value:arg3 value:arg4 value:arg5 value:arg6 value:arg7 value:arg8 value:arg9 value:arg10 value:arg11];
}







id _runImplementationBlock(id receiver, SEL selector, id implementation, va_list args) {
    unsigned int argCount = getSelectorParameterCount(selector);
    
    id* argIds = (id*)malloc(sizeof(id)*(argCount+1));
    argIds[0] = receiver; // put the "self" object in the first slot
    memcpy(argIds+1,(id)args,(sizeof(id))*argCount);
    
    NSArray* argArray = [[NSArray alloc] initWithObjects:argIds count:argCount+1];
    
    id returnValue = [implementation valueWithArguments:argArray];
    
    [argArray release];
    free(argIds);
    
    return returnValue;
}





// used when a method takes more than five parameters (i.e. does not use a trampoline)
// a good bit less efficient, but more flexible
id runInstanceMethodArgsX(id this, SEL selector, ...) {
    va_list argumentList;
    va_start(argumentList,selector);
    
    // look through the inheritance hierarchy to find the first implementation of this method
    FSClass* currentClass = [FSClass shadowForClass:[this class]];
    id implementation = [currentClass blockForSelector:selector];
    
    return _runImplementationBlock(this, selector, implementation, argumentList);
}


// used when a method takes more than five parameters (i.e. does not use a trampoline)
// a good bit less efficient, but more flexible
id runClassMethodArgsX(id thisClass, SEL selector, ...) {
    va_list argumentList;
    va_start(argumentList,selector);
    
    // look through the inheritance hierarchy to find the first implementation of this method
    FSClass* currentClass = [FSClass shadowForClass:thisClass];
    id implementation = [currentClass blockForClassSelector:selector];
    
    return _runImplementationBlock(thisClass, selector, implementation, argumentList);
}




#pragma mark -
#pragma mark SUPER CALLBACKS

#ifdef __LP64__
// verifies that super: has been called with the proper number of arguments
#define CHECK_SUPER_ARGS(paramCount) {\
    unsigned int neededArgs=getSelectorParameterCount(selector);\
    if (paramCount!=neededArgs)\
        ThrowException(NSInvalidArgumentException, [NSString stringWithFormat:@"super:#%@ called with incorrect number of arguments (needed %d, supplied %d)",\
            NSStringFromSelector(selector),neededArgs,paramCount], nil);\
}


// creates a objc_super structure from the the target object
#define CREATE_SUPER_STRUCT \
SEL selector = [compactBlock selector];\
struct objc_super superStruct;\
superStruct.receiver = receiver;\
superStruct.super_class = class_getSuperclass(startingClass);\


// creates a objc_super structure from the the target object
#define CREATE_SUPER_STRUCT_CLASS \
SEL selector = [compactBlock selector];\
struct objc_super superStruct;\
superStruct.receiver = receiver;\
superStruct.super_class = objc_getMetaClass(class_getName(class_getSuperclass(startingClass)));\

#else


// verifies that super: has been called with the proper number of arguments
#define CHECK_SUPER_ARGS(paramCount) {\
unsigned int neededArgs=getSelectorParameterCount(selector);\
if (paramCount!=neededArgs)\
ThrowException(NSInvalidArgumentException, [NSString stringWithFormat:@"super:#%@ called with incorrect number of arguments (needed %d, supplied %d)",\
NSStringFromSelector(selector),neededArgs,paramCount], nil);\
}


// creates a objc_super structure from the the target object
#define CREATE_SUPER_STRUCT \
SEL selector = [compactBlock selector];\
struct objc_super superStruct;\
superStruct.receiver = receiver;\
superStruct.class = class_getSuperclass(startingClass);\


// creates a objc_super structure from the the target object
#define CREATE_SUPER_STRUCT_CLASS \
SEL selector = [compactBlock selector];\
struct objc_super superStruct;\
superStruct.receiver = receiver;\
superStruct.class = objc_getMetaClass(class_getName(class_getSuperclass(startingClass)));\

#endif


id superMethod0(id receiver, SEL dummySelector, id compactBlock, Class startingClass) {
    CREATE_SUPER_STRUCT;
    CHECK_SUPER_ARGS(0);
    
    return objc_msgSendSuper(&superStruct,selector);
}
    
id superMethod1(id receiver, SEL dummySelector, id compactBlock, Class startingClass, id arg1) {
    CREATE_SUPER_STRUCT;
    CHECK_SUPER_ARGS(1);
    return objc_msgSendSuper(&superStruct,selector,arg1);
}
id superMethod2(id receiver, SEL dummySelector, id compactBlock, Class startingClass, id arg1, id arg2) {
    CREATE_SUPER_STRUCT;
    CHECK_SUPER_ARGS(2);
    return objc_msgSendSuper(&superStruct,selector,arg1,arg2);
}

id superMethod3(id receiver, SEL dummySelector, id compactBlock, Class startingClass, id arg1, id arg2, id arg3) {
    CREATE_SUPER_STRUCT;
    CHECK_SUPER_ARGS(3);
    return objc_msgSendSuper(&superStruct,selector,arg1,arg2,arg3);
}

id superMethod4(id receiver, SEL dummySelector, id compactBlock, Class startingClass, id arg1, id arg2, id arg3, id arg4) {
    CREATE_SUPER_STRUCT;
    CHECK_SUPER_ARGS(4);
    return objc_msgSendSuper(&superStruct,selector,arg1,arg2,arg3,arg4);
}

id superMethod5(id receiver, SEL dummySelector, id compactBlock, Class startingClass, id arg1, id arg2, id arg3, id arg4, id arg5) {
    CREATE_SUPER_STRUCT;
    CHECK_SUPER_ARGS(5);
    return objc_msgSendSuper(&superStruct,selector,arg1,arg2,arg3,arg4);
}

id superMethodMulti(id receiver, SEL dummySelector, id compactBlock, Class startingClass, NSArray* arguments) {
    CREATE_SUPER_STRUCT;
    
    unsigned int argCount = [arguments count];
    if (argCount > 12)
        ThrowException(NSInvalidArgumentException, [NSString stringWithFormat:@"Attempt to call super:withArgs: with %i arguments (max is 12)", argCount], nil);
    
    unsigned int neededArgs=getSelectorParameterCount(selector);
    if ([arguments count] != neededArgs)
        ThrowException(NSInvalidArgumentException, [NSString stringWithFormat:@"super:#%@ withArguments: called with incorrect number of arguments (needed %d, supplied %d)",
            NSStringFromSelector(selector),neededArgs,argCount], nil);
    
    FSClass* receiverClass = [FSClass classForPointer:[receiver class]];
    
    // if there are fewer than 5 arguments, or the class has an ObjC parent,
    // we can directly use the ObjC message-sending system and let it find the correct block/method
    if (argCount<=TRAMPOLINE_MAX_ARG_COUNT || !([receiverClass parentFSClass])) {
        id* args = malloc(sizeof(id) * argCount);
        [arguments getObjects:args];
        id returnValue;
        
        switch (argCount) {
            case 0: returnValue = objc_msgSendSuper(&superStruct,selector); break;
            case 1: returnValue = objc_msgSendSuper(&superStruct,selector,args[0]); break;
            case 2: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1]); break;
            case 3: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2]); break;
            case 4: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3]); break;
            case 5: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4]); break;
            case 6: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4],args[5]); break;
            case 7: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4],args[5],args[6]); break;
            case 8: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]); break;
            case 9: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8]); break;
            case 10: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9]); break;
            case 11: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10]); break;
            case 12: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10],args[11]); break;
        }
        free(args);
        return returnValue;
    }
    else {
        // otherwise, a superclass that uses runInstanceMethodArgsX for this method will find the class's
        // appropriate block, so we have to find the parent's block directly
        // this may not be completely correct.....
        FSClass* parentClass = receiverClass->parentClass;
        NSMutableArray* blockArgs = [NSMutableArray array];
        [blockArgs addObject:receiver];
        [blockArgs addObjectsFromArray:arguments];
        
        id implementation = [parentClass blockForSelector:selector];
        return [implementation valueWithArguments:blockArgs];
    }
}






/*
 *  Implementations for super: on class methods
 */
id classSuperMethod0(id receiver, SEL dummySelector, id compactBlock, Class startingClass) {
    CREATE_SUPER_STRUCT_CLASS;
    CHECK_SUPER_ARGS(0);
    return objc_msgSendSuper(&superStruct,selector);
}

id classSuperMethod1(id receiver, SEL dummySelector, id compactBlock, Class startingClass, id arg1) {
    CREATE_SUPER_STRUCT_CLASS;
    CHECK_SUPER_ARGS(1);
    return objc_msgSendSuper(&superStruct,selector,arg1);
}
id classSuperMethod2(id receiver, SEL dummySelector, id compactBlock, Class startingClass, id arg1, id arg2) {
    CREATE_SUPER_STRUCT_CLASS;
    CHECK_SUPER_ARGS(2);
    return objc_msgSendSuper(&superStruct,selector,arg1,arg2);
}

id classSuperMethod3(id receiver, SEL dummySelector, id compactBlock, Class startingClass, id arg1, id arg2, id arg3) {
    CREATE_SUPER_STRUCT_CLASS;
    CHECK_SUPER_ARGS(3);
    return objc_msgSendSuper(&superStruct,selector,arg1,arg2,arg3);
}

id classSuperMethod4(id receiver, SEL dummySelector, id compactBlock, Class startingClass, id arg1, id arg2, id arg3, id arg4) {
    CREATE_SUPER_STRUCT_CLASS;
    CHECK_SUPER_ARGS(4);
    return objc_msgSendSuper(&superStruct,selector,arg1,arg2,arg3,arg4);
}

id classSuperMethod5(id receiver, SEL dummySelector, id compactBlock, Class startingClass, id arg1, id arg2, id arg3, id arg4, id arg5) {
    CREATE_SUPER_STRUCT_CLASS;
    CHECK_SUPER_ARGS(5);
    return objc_msgSendSuper(&superStruct,selector,arg1,arg2,arg3,arg4);
}

id classSuperMethodMulti(id receiver, SEL dummySelector, id compactBlock, Class startingClass, NSArray* arguments) {
    CREATE_SUPER_STRUCT_CLASS;
    
    unsigned int argCount = [arguments count];
    if (argCount > 12)
        ThrowException(NSInvalidArgumentException, [NSString stringWithFormat:@"Attempt to call super:withArgs: with %i arguments (max is 12)", argCount], nil);
    
    unsigned int neededArgs=getSelectorParameterCount(selector);
    if ([arguments count] != neededArgs)
        ThrowException(NSInvalidArgumentException, [NSString stringWithFormat:@"super:#%@ withArguments: called with incorrect number of arguments (needed %d, supplied %d)",
                                                    NSStringFromSelector(selector),neededArgs,argCount], nil);
    
    FSClass* receiverClass = [FSClass classForPointer:receiver];
    
    // if there are fewer than 5 arguments, or the class has an ObjC parent,
    // we can directly use the ObjC message-sending system and let it find the correct block/method
    if (argCount<=TRAMPOLINE_MAX_ARG_COUNT || ![receiverClass parentFSClass]) {
        id* args = malloc(sizeof(id) * argCount);
        [arguments getObjects:args];
        id returnValue;
        
        switch (argCount) {
            case 0: returnValue = objc_msgSendSuper(&superStruct,selector); break;
            case 1: returnValue = objc_msgSendSuper(&superStruct,selector,args[0]); break;
            case 2: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1]); break;
            case 3: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2]); break;
            case 4: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3]); break;
            case 5: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4]); break;
            case 6: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4],args[5]); break;
            case 7: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4],args[5],args[6]); break;
            case 8: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]); break;
            case 9: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8]); break;
            case 10: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9]); break;
            case 11: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10]); break;
            case 12: returnValue = objc_msgSendSuper(&superStruct,selector,args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10],args[11]); break;
        }
        free(args);
        return returnValue;
    }
    else {
        // otherwise, a superclass that uses runInstanceMethodArgsX for this method will find the class's
        // appropriate block, so we have to find the parent's block directly
        // this may not be completely correct.....
        FSClass* parentClass = [receiverClass parentFSClass];
        NSMutableArray* blockArgs = [NSMutableArray array];
        [blockArgs addObject:receiver];
        [blockArgs addObjectsFromArray:arguments];
        
        id implementation = [parentClass blockForClassSelector:selector];
        return [implementation valueWithArguments:blockArgs];
    }
}








