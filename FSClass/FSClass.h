//
//  FSClass.h
//  FSClass
//
//  Created by Andrew Weinrich on 11/12/06.
//

#import <Cocoa/Cocoa.h>


// Definitions of ivar names that are included on every FSClass-derived object
extern const char* IVAR_FS_CLASS;
extern const char* IVAR_PROP_DICTIONARY;    // only used if fast ivars are not enabled
extern NSString* IVAR_FS_CLASS_STRING;
extern NSString* IVAR_PROP_DICTIONARY_STRING;


@interface FSClass : NSObject {
    NSMutableDictionary* methods;       // Blocks for each method this class handles, keyed on NSValue(selector)
    NSMutableDictionary* trampedMethods; // boolean NSNumber for each method: is this method implemented with a trampoline?
    
    NSMutableDictionary* classProperties;
    NSMutableDictionary* classMethods;
@public
    NSMutableDictionary* properties;    // Properties for this class, with default values
    
    BOOL anonymous;
    BOOL isObjectiveC;                   
    BOOL useFastIvars;              // are we putting data directly in the object or using a dictionary?
    BOOL hasIvarDictionary;         // whether this class has an ivar dictionary (possibly inherited from parent)
    BOOL baseMethodsInitialized;    // have dealloc, getClass, super:, etc been set up
    
    // inheritance hierarchy pointers - downstream is needed so that methods can
    // be propagated to subclasses
    NSString* className;
    BOOL objcParent;
    FSClass* parentClass;
    NSMutableArray* childClasses;
    
    IMP parentAllocImp; // pointer to NSObject's alloc method
    
    // Objective-C runtime class objects
    Class classObject;
    Class metaclassObject;
}


@property(readonly) NSMutableDictionary* properties;
@property(readonly) FSClass* parentFSClass;
@property(readonly) Class classObject;
@property(readonly) IMP parentAllocImp;
@property(readonly) BOOL hasIvarDictionary;


// Linking directly against the F-Script framework doesn't work, so we'll declare the
// Block name but not its capabilities
extern Class Block;





- (FSClass*) init:(NSString*)name;

- (FSClass*) initNewClass:(NSString*)name parent:(id)parent iVars:(NSArray*)iVars;
- (FSClass*) initFastIvarsClass:(NSString*)name parent:(id)parent properties:(NSDictionary*)properties;
- (FSClass*) initRegularIvarsClass:(NSString*)name parent:(id)parent;

- (FSClass*) initProxyClass:(Class)classObj;



/*
 *
 *  ADDING METHODS
 *
 */
#pragma mark -
#pragma mark Adding Methods
- (void) onMessage:(SEL)selector do:(id)block;
- (void) onMessageName:(NSString*)messageName do:(id)block;



/*
 *
 *  PROPERTY METHODS
 *
 */
#pragma mark -
#pragma mark Adding Properties
- (void) addProperty:(NSString*)propertyName;
- (void) addProperty:(NSString*)propertyName withDefault:(id)defaultValue;
- (void) addPropertiesWithDefaults:(NSArray*)propertiesWithDefaults;
- (void) addPropertiesFromDictionary:(NSDictionary*)propertyDictionary;
- (id) defaultValueForProperty:(NSString*)propertyName;
- (void) setDefaultValue:(id)defaultValue forProperty:(NSString*)propertyName;


#pragma mark -
#pragma mark Class Methods and Properties
- (void) onClassMessage:(SEL)selector do:(id)block;
- (void) addClassProperty:(NSString*)propName withValue:(id)value;
- (void) addClassProperty:(NSString*)propName;


#pragma mark -
#pragma mark Subclassing Methods
- (Class) subclass;
- (Class) subclass:(NSString*)subclassName;










/*
 *
 *  REFLECTION METHODS
 *
 */
#pragma mark -
#pragma mark Reflection Methods
- (NSArray*) methods;
- (NSArray*) allMethods;
- (NSArray*) methodNames;
- (NSArray*) allMethodNames;
- (NSArray*) propertyNames;
- (NSArray*) allPropertyNames;
- (Class) methodImplementor:(SEL)selector;
- (id) blockForSelector:(SEL)selector;


- (NSArray*) classMethods;
- (NSArray*) allClassMethods;
- (NSArray*) classMethodNames;
- (NSArray*) allClassMethodNames;
- (NSArray*) classPropertyNames;
- (NSArray*) allClassPropertyNames;
- (Class) classMethodImplementor:(SEL)selector;
- (id) blockForClassSelector:(SEL)selector;




/*
 *
 *  PRIVATE METHODS BELOW
 *
 */
#pragma mark -
#pragma mark Private Methods

// installs a method to an FSClass's Objective-C class
- (void) _installMethod:(IMP)method
       asInstanceMethod:(BOOL)isInstanceMethod
               argCount:(int)argCount
               selector:(SEL)selector
         usesTrampoline:(BOOL)usesTrampoline;


// returns whether a class has a property, native or inherited
- (BOOL) _hasProperty:(NSString*)name;
- (BOOL) _hasClassProperty:(NSString*)name;



- (id) _getClassProperty:(NSString*)propertyName;
- (void) _setClassProperty:(NSString*)propertyName toValue:(id)newValue;



@end




// declare these method signatures from the FScript Block so that the compiler recognizes them
@interface CompilerComplaints : NSObject { }
- (id) valueWithArguments:(NSArray*)arguments;
- (id) value;
- (id) value:(id)arg1;
- (id) value:(id)arg1 value:(id)arg2;
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3;
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4;
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5;
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5 value:(id)arg6;
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5 value:(id)arg6 value:(id)arg7;
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5 value:(id)arg6 value:(id)arg7 value:(id)arg8;
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5 value:(id)arg6 value:(id)arg7 value:(id)arg8 value:(id)arg9;
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5 value:(id)arg6 value:(id)arg7 value:(id)arg8 value:(id)arg9 value:(id)arg10;
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5 value:(id)arg6 value:(id)arg7 value:(id)arg8 value:(id)arg9 value:(id)arg10 value:(id)arg11;
- (id) value:(id)arg1 value:(id)arg2 value:(id)arg3 value:(id)arg4 value:(id)arg5 value:(id)arg6 value:(id)arg7 value:(id)arg8 value:(id)arg9 value:(id)arg10 value:(id)arg11 value:(id)arg12;
+ (id) blockWithSelector:(SEL)selector;
- (int) argumentCount;
- (id) replace:(id)pattern with:(id)replacement;
@end




