//
//  TRAMPOLINE.m
//  FSClass
//
//  Created by Andrew Weinrich on 3/24/07.
//  Copyright 2007 Andrew Weinrich. All rights reserved.
//

#import "Trampoline.h"
#import <objc/objc.h>
#import <objc/objc-runtime.h>
#include <sys/mman.h>
#include "Functions.h"


// Include only the appropriate trampolines for this architecture
#ifdef __ppc__
    #include "trampolines/ppc/trampoline-ppc.c"
#endif
#ifdef __ppc64__
    #include "trampolines/ppc64/trampoline-ppc64.c"
#endif
#ifdef __i386__
    #include "trampolines/x86/trampoline-x86.c"
#endif
#ifdef __x86_64__
    #include "trampolines/x86-64/trampoline-x86-64.c"
#endif







Trampoline createMethodTrampoline(unsigned int paramCount, id block) {
    char* code;
    unsigned int length;
    SEL selector;
	
    switch (paramCount) {
        case 0:
            code = method0; length = method0_len; selector = @selector(value:); break;
        case 1:
            code = method1; length = method1_len; selector = @selector(value:value:); break;
        case 2:
            code = method2; length = method2_len; selector = @selector(value:value:value:); break;
        case 3:
            code = method3; length = method3_len; selector = @selector(value:value:value:value:); break;
        case 4:
            code = method4; length = method4_len; selector = @selector(value:value:value:value:value:); break;
        case 5:
            code = method5; length = method5_len; selector = @selector(value:value:value:value:value:value:); break;
        default:
            return NULL;
    }
    
    Trampoline trampoline = ALLOC_TRAMPOLINE(length);
    COPY_TRAMPOLINE(trampoline,code,length);
    
    TRAMPOLINE_SET_TARGET(trampoline,block);
    TRAMPOLINE_SET_SELECTOR(trampoline,selector);
    TRAMPOLINE_SET_MSGSEND(trampoline,objc_msgSend);
	
    // on 64-bit, we have to manually enable execution permissions for the trampoline's page
#ifdef __LP64__
    unsigned long long memoryAddress = (unsigned long long)trampoline;
    unsigned long long pageSize = 1024*4;
    unsigned long long nearestPage = (memoryAddress / pageSize) * pageSize;
    
    // this trampoline is definitely smaller than one page, but it may cross a page boundary, so 
    // we'll add execute access to both the starting page and the subsequent page
    int result = mprotect((void*)nearestPage, 2*pageSize, PROT_READ | PROT_WRITE | PROT_EXEC);
    if (result==-1) {
        if (errno==EINVAL)
            ThrowException(@"FSClassException", @"Could not construct trampoline: mprotect returned EINVAL", nil);
        else if (errno==EACCES)
            ThrowException(@"FSClassException", @"Could not construct trampoline: mprotect returned EACCES", nil);
        else if (errno==ENOTSUP)
            ThrowException(@"FSClassException", @"Could not construct trampoline: mprotect returned ENOTSUP", nil);
        else
            ThrowException(@"FSClassException", @"Could not construct trampoline: mprotect failed, reason unknown", nil);
    }
#endif
    
    
    // for some reason, going directly to the class implementation doesn't work on 
    // PowerPC, so we'll take it out for the moment
    //Method dispatcher = class_getInstanceMethod(objc_getClass("Block"), selector);
    //TRAMPOLINE_SET_MSGSEND(trampoline,method_getImplementation(dispatcher));
    
    return trampoline;
}




