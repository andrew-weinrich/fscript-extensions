.globl _main 
.text 
_main: 
        ; save return address
        mflr r0
        
        ; find out where this block of code is executing so that
        ; we can extract values from the thunkoline in front of us
        xor.    r16, r16, r16   ;1. r5 = NULL 
        bnel    _main           ;2. branch to _main if not equal 
        mflr    r16             ;3. r16 = main + 12
        subi    r16, r16, 28    ;4. r16 = (main + 12) - 12 - 16 = beginning of thunkoline
        
        ; move parameters back one space
        mr r8, r7   ; third param
        mr r7, r6   ; second param
        mr r6, r5   ; first param
        mr r5, r3   ; receiver
        
        lwz     r3, 0(r16)  ; load target Block into r3
        lwz     r4, 4(r16)  ; load selector to r4
        
        ; extract objc_msgSend from thunkoline and call it
        mtlr    r0          ; return address
        lwz     r15, 8(r16)  ; load objc_msgSend to r15
        xor.     r16,r16,r16
        mtctr   r15         ; copy objc_msgSend to count register
        bctr                ; jump to objc_msgSend, do not update link register (return to caller)
