//
//  Trampoline.h
//  FSClass
//
//  Created by Andrew Weinrich on 3/24/07.
//  Copyright 2007 Andrew Weinrich. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
 A trampoline is a short piece of code that performs redirection for function calls. In FSClass,
 trampolines are used as the IMP pointers when adding methods to classes, and for accessor/mutator
 methods in fast-ivar classes.
 
 FSClass trampolines consist of a 4-pointer header and a block of assembly code. The function is
 entered at the beginning of the assembly block, where it uses architecture-specific idioms to locate
 itself (the trampolines are dynamically allocated, and there is no way to hard-code the addresses.)
 PowerPC trampolines find their location by zeroing out a register, then performing a conditional
 branch-and-link to _main. This leaves the return address in the link register, from which the header 
 address can be calculated. x86 trampolines perform a relative call to the next instruction (offset 0),
 which leaves the return address on the top of the stack.

 Accessor trampolines pull the property offset from the header, use it to find the property value (id pointer)
 inside the object, and return. Method trampolines have to change the function's arguments from this:
    
    self, @selector(methodSelector:), arg1, arg2, arg3 ...
 
 to the proper ordering for invoking -[Block value:...]:
 
    block, @selector(value:), self, arg1, arg2, arg3 ...
 
 PPC trampolines accomplish this by shuffling the contents of the parameter registers (r3 - r9). x86 trampolines
 take advantage of the fact that Apple's ABI adds extra padding to keep the stack 16-byte aligned, and move the
 arguments into "lower" positions on the stack while keeping the top at the same location. This is necessary because
 all objc_msgSend calls are variadic, which on x86 means that the caller must clean up the stack frame. Thus, 
 increasing the size of the stack in the trampoline is not possible because the increased size cannot be communicated
 to the caller.
 
 So on PPC, we have before trampoline:
    
     r3: self
     r4: @selector(methodSelector:)
     r5: arg1
     r6: arg2
     r7: arg3
     r8: arg4
     r9: arg5
 
 and after:
 
     r3: block
     r4: @selector(value:)
     r5: self
     r6: arg1
     r7: arg2
     r8: arg3
     r9: arg4
     r10: arg5
 
 with no other registers modified. On x86, the stack before trampoline looks like this (higher addresses at top):
 
        --
        arg5
        arg4
  16b-> arg3
        arg2
        arg1
        @selector(method:selector:)
  16b-> self
  esp-> return address

 where esp indicates the stack pointer, and 16b indicates the beginning of a 16-byte aligned block. After trampoline:
 
        --
        arg5
        arg4
        arg3
  16b-> arg2
        arg1
        self
        @selector(value:)
  16b-> block
  esp-> return address

 After rearranging the stack/registers, the trampolines make jumps to objc_msgSend. These are immediate jumps, not function
 calls, so no additional strackframe is allocated, and the Block's execution method will return directly to the
 trampoline's caller. On x86, the instruction is a JMP with absolute address; on PowerPC it is a simple branch.
 
 The actual assembly code and binary files are located in the directory trampolines/, along with Perl
 scripts for compiling them on PPC and x86.
 
 
 Setter/mutator trampolines are currently not supported. Instead, single setter functions for fast and regular
 classes are in Callbacks.c.
 
 Getter trampolines are no longer used, due to the new opaque ivars structure in Leopard. Both 32-bit and 64-bit
 getter methods now use object_getInstanceVariable().
 */


typedef void* Trampoline;

typedef id(*dispatchType)(id,SEL,...);


// the most arguments (not counting receiver) that a trampoline can handle
#ifdef __x86_64__
    #define TRAMPOLINE_MAX_ARG_COUNT 3
#else
    #define TRAMPOLINE_MAX_ARG_COUNT 5
#endif



/*
 Method trampoline header fields:
    TARGET: pointer to implementation Block
    SELECTOR: selector for Block (value:, value:value:, etc)
    MSGSEND: address of objc_msgSend function
    EXTRA: reserved space
*/



#ifdef __LP64__
    // offsets for regular methods
    #define TRAMPOLINE_TARGET_OFFSET    0
    #define TRAMPOLINE_SELECTOR_OFFSET  8
    #define TRAMPOLINE_MSGSEND_OFFSET   16
    #define TRAMPOLINE_EXTRA_OFFSET     24

    // common code offset
    #define TRAMPOLINE_CODE_OFFSET      32
#else
    // offsets for regular methods
    #define TRAMPOLINE_TARGET_OFFSET    0
    #define TRAMPOLINE_SELECTOR_OFFSET  4
    #define TRAMPOLINE_MSGSEND_OFFSET   8
    #define TRAMPOLINE_EXTRA_OFFSET     12

    // common code offset
    #define TRAMPOLINE_CODE_OFFSET      16
#endif


/// header: receiver block, @sel(value:), objc_msgSend pointer, reserved
#define TRAMPOLINE_HEADER_SIZE (4 * sizeof(void*))


//#define TRAMPOLINE_HEADER_SIZE (sizeof(id) + sizeof(SEL) + sizeof(IMP))
#define ALLOC_TRAMPOLINE(code_size) (malloc(code_size + TRAMPOLINE_HEADER_SIZE))
#define COPY_TRAMPOLINE(trampoline,source,length) (memcpy(trampoline+TRAMPOLINE_CODE_OFFSET, source,length))



// macros to retrieve and set header fields
#define TRAMPOLINE_GET_SELECTOR(trampoline) (*((SEL*)(trampoline+TRAMPOLINE_SELECTOR_OFFSET)))
#define TRAMPOLINE_GET_TARGET(trampoline) (*((id*)(trampoline+TRAMPOLINE_TARGET_OFFSET)))
#define TRAMPOLINE_GET_MSGSEND(trampoline) (*((dispatchType*)(trampoline+TRAMPOLINE_MSGSEND_OFFSET)))

#define TRAMPOLINE_SET_SELECTOR(trampoline,selector) (*((SEL*)(trampoline+TRAMPOLINE_SELECTOR_OFFSET))) = selector
#define TRAMPOLINE_SET_TARGET(trampoline,target) (*((id*)(trampoline+TRAMPOLINE_TARGET_OFFSET))) = target
#define TRAMPOLINE_SET_MSGSEND(trampoline,dispatch) (*((dispatchType*)(trampoline+TRAMPOLINE_MSGSEND_OFFSET))) = dispatch


#define TRAMPOLINE_GET_CODE(trampoline) (IMP)(trampoline+TRAMPOLINE_CODE_OFFSET)


// convert a code address back into a Trampoline pointer
#define TRAMPOLINE_FROM_FUNC_POINTER(pointer) ((Trampoline)(pointer-TRAMPOLINE_CODE_OFFSET))




Trampoline createMethodTrampoline(unsigned int paramCount, id block);


