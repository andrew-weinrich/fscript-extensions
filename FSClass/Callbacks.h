//
//  Callbacks.h
//  FSClass
//
//  Created by Andrew Weinrich on 11/14/06.
//


/*
 This file contains callbacks that are used as IMP pointers when adding methods to classes.
 General-purpose methods callbacks are created from trampolines (see Trampoline.h)
 */


#import <Foundation/Foundation.h>
#import <stdarg.h>
#import "FSClass.h"


// initializer that sets all properties to default values
id allocator(id thisClass, SEL selector);


// property get/set handlers for regular classes - registered as IMP pointers when properties are added
id getInstanceProperty(id thisId, SEL selector);
id setInstanceProperty(id thisId, SEL selector, id newValue);


// Property setter for fast-ivar classes
id getInstancePropertyFast(id thisId, SEL selector);
id setInstancePropertyFast(id thisId, SEL selector, id newValue);


// Class property access callbacks
id getClassProperty(id thisClass, SEL selector);
id setClassProperty(id thisClass, SEL selector, id newValue);


// general-purpose instance and class method handlers, used for more than six arguments
id runInstanceMethodArgsX(id this, SEL selector, ...);
id runClassMethodArgsX(id this, SEL selector, ...);





// slow-dispatch instance methods
id runInstanceMethodArgs0(id this, SEL selector);
id runInstanceMethodArgs1(id this, SEL selector, id arg1);
id runInstanceMethodArgs2(id this, SEL selector, id arg1, id arg2);
id runInstanceMethodArgs3(id this, SEL selector, id arg1, id arg2, id arg3);
id runInstanceMethodArgs4(id this, SEL selector, id arg1, id arg2, id arg3, id arg4);
id runInstanceMethodArgs5(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5);
id runInstanceMethodArgs6(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6);
id runInstanceMethodArgs7(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7);
id runInstanceMethodArgs8(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8);
id runInstanceMethodArgs9(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9);
id runInstanceMethodArgs10(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9, id arg10);
id runInstanceMethodArgs11(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9, id arg10, id arg11);


// slow-dispatch instance methods
id runClassMethodArgs0(id this, SEL selector);
id runClassMethodArgs1(id this, SEL selector, id arg1);
id runClassMethodArgs2(id this, SEL selector, id arg1, id arg2);
id runClassMethodArgs3(id this, SEL selector, id arg1, id arg2, id arg3);
id runClassMethodArgs4(id this, SEL selector, id arg1, id arg2, id arg3, id arg4);
id runClassMethodArgs5(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5);
id runClassMethodArgs6(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6);
id runClassMethodArgs7(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7);
id runClassMethodArgs8(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8);
id runClassMethodArgs9(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9);
id runClassMethodArgs10(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9, id arg10);
id runClassMethodArgs11(id this, SEL selector, id arg1, id arg2, id arg3, id arg4, id arg5, id arg6, id arg7, id arg8, id arg9, id arg10, id arg11);






// super: dispatch methods. Use objc_superMsgSend
id superMethod0(id receiver, SEL dummySelector, id compactBlock, Class currentClass);
id superMethod1(id receiver, SEL dummySelector, id compactBlock, Class currentClass, id arg1);
id superMethod2(id receiver, SEL dummySelector, id compactBlock, Class currentClass, id arg1, id arg2);
id superMethod3(id receiver, SEL dummySelector, id compactBlock, Class currentClass, id arg1, id arg2, id arg3);
id superMethod4(id receiver, SEL dummySelector, id compactBlock, Class currentClass, id arg1, id arg2, id arg3, id arg4);
id superMethod5(id receiver, SEL dummySelector, id compactBlock, Class currentClass, id arg1, id arg2, id arg3, id arg4, id arg5);
id superMethodMulti(id receiver, SEL dummySelector, id compactBlock, Class currentClass, NSArray* arguments);

id classSuperMethod0(id receiver, SEL dummySelector, id compactBlock, Class currentClass);
id classSuperMethod1(id receiver, SEL dummySelector, id compactBlock, Class currentClass, id arg1);
id classSuperMethod2(id receiver, SEL dummySelector, id compactBlock, Class currentClass, id arg1, id arg2);
id classSuperMethod3(id receiver, SEL dummySelector, id compactBlock, Class currentClass, id arg1, id arg2, id arg3);
id classSuperMethod4(id receiver, SEL dummySelector, id compactBlock, Class currentClass, id arg1, id arg2, id arg3, id arg4);
id classSuperMethod5(id receiver, SEL dummySelector, id compactBlock, Class currentClass, id arg1, id arg2, id arg3, id arg4, id arg5);
id classSuperMethodMulti(id receiver, SEL dummySelector, id compactBlock, Class currentClass, NSArray* arguments);

