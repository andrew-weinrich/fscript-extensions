unsigned int getter_len = 40;
char* getter =
"\x7e\x48\x02\xa6"  // mflr r18    ; save return address
"\x7e\x10\x82\x79"  // xor.    r16, r16, r16   ;1. r5 = NULL 
"\x40\x82\xff\xf9"  // bnel    _main           ;2. branch to _main if not equal 
"\x7e\x08\x02\xa6"  // mflr    r16             ;3. r16 = main + 12
"\x3a\x10\xff\xe4"  // subi    r16, r16, 28    ;4. r16 = main + 12 + -12 - 16 = beginning of thunkoline
"\x7e\x48\x03\xa6"  // mtlr    r18     ; restore link register
"\x82\x50\x00\x00"  // lwz r18, 0(r16)     ; bring offset up from thunkoline header
"\x7e\x63\x92\x14"  // add r19, r3,r18     ; add offset to receiver (first function parameter)
"\x80\x73\x00\x00"  // lwz r3, 0(r19)       ; load value of property into r1 (return address)
"\x4e\x80\x00\x20"  // blr
;

unsigned int method0_len = 52;
char* method0 =
"\x7c\x08\x02\xa6"  // mflr r0
"\x7e\x10\x82\x79"  // xor.    r16, r16, r16   ;1. r5 = NULL 
"\x40\x82\xff\xf9"  // bnel    _main           ;2. branch to _main if not equal 
"\x7e\x08\x02\xa6"  // mflr    r16             ;3. r16 = main + 12
"\x3a\x10\xff\xe4"  // subi    r16, r16, 28    ;4. r16 = (main + 12) - 12 - 16 = beginning of thunkoline
"\x7c\x65\x1b\x78"  // mr r5, r3   ; receiver
"\x80\x70\x00\x00"  // lwz     r3, 0(r16)  ; load target Block into r3
"\x80\x90\x00\x04"  // lwz     r4, 4(r16)  ; load selector to r4
"\x7c\x08\x03\xa6"  // mtlr    r0          ; return address
"\x81\xf0\x00\x08"  // lwz     r15, 8(r16)  ; load objc_msgSend to r15
"\x7e\x10\x82\x79"  // xor.     r16,r16,r16
"\x7d\xe9\x03\xa6"  // mtctr   r15         ; copy objc_msgSend to count register
"\x4e\x80\x04\x20"  // bctr                ; jump to objc_msgSend, do not update link register (return to caller)
;

unsigned int method1_len = 56;
char* method1 =
"\x7c\x08\x02\xa6"  // mflr r0
"\x7e\x10\x82\x79"  // xor.    r16, r16, r16   ;1. r5 = NULL 
"\x40\x82\xff\xf9"  // bnel    _main           ;2. branch to _main if not equal 
"\x7e\x08\x02\xa6"  // mflr    r16             ;3. r16 = main + 12
"\x3a\x10\xff\xe4"  // subi    r16, r16, 28    ;4. r16 = (main + 12) - 12 - 16 = beginning of thunkoline
"\x7c\xa6\x2b\x78"  // mr r6, r5   ; first param
"\x7c\x65\x1b\x78"  // mr r5, r3   ; receiver
"\x80\x70\x00\x00"  // lwz     r3, 0(r16)  ; load target Block into r3
"\x80\x90\x00\x04"  // lwz     r4, 4(r16)  ; load selector to r4
"\x7c\x08\x03\xa6"  // mtlr    r0          ; return address
"\x81\xf0\x00\x08"  // lwz     r15, 8(r16)  ; load objc_msgSend to r15
"\x7e\x10\x82\x79"  // xor.     r16,r16,r16
"\x7d\xe9\x03\xa6"  // mtctr   r15         ; copy objc_msgSend to count register
"\x4e\x80\x04\x20"  // bctr                ; jump to objc_msgSend, do not update link register (return to caller)
;

unsigned int method2_len = 60;
char* method2 =
"\x7c\x08\x02\xa6"  // mflr r0
"\x7e\x10\x82\x79"  // xor.    r16, r16, r16   ;1. r5 = NULL 
"\x40\x82\xff\xf9"  // bnel    _main           ;2. branch to _main if not equal 
"\x7e\x08\x02\xa6"  // mflr    r16             ;3. r16 = main + 12
"\x3a\x10\xff\xe4"  // subi    r16, r16, 28    ;4. r16 = (main + 12) - 12 - 16 = beginning of thunkoline
"\x7c\xc7\x33\x78"  // mr r7, r6   ; second param
"\x7c\xa6\x2b\x78"  // mr r6, r5   ; first param
"\x7c\x65\x1b\x78"  // mr r5, r3   ; receiver
"\x80\x70\x00\x00"  // lwz     r3, 0(r16)  ; load target Block into r3
"\x80\x90\x00\x04"  // lwz     r4, 4(r16)  ; load selector to r4
"\x7c\x08\x03\xa6"  // mtlr    r0          ; return address
"\x81\xf0\x00\x08"  // lwz     r15, 8(r16)  ; load objc_msgSend to r15
"\x7e\x10\x82\x79"  // xor.     r16,r16,r16
"\x7d\xe9\x03\xa6"  // mtctr   r15         ; copy objc_msgSend to count register
"\x4e\x80\x04\x20"  // bctr                ; jump to objc_msgSend, do not update link register (return to caller)
;

unsigned int method3_len = 64;
char* method3 =
"\x7c\x08\x02\xa6"  // mflr r0
"\x7e\x10\x82\x79"  // xor.    r16, r16, r16   ;1. r5 = NULL 
"\x40\x82\xff\xf9"  // bnel    _main           ;2. branch to _main if not equal 
"\x7e\x08\x02\xa6"  // mflr    r16             ;3. r16 = main + 12
"\x3a\x10\xff\xe4"  // subi    r16, r16, 28    ;4. r16 = (main + 12) - 12 - 16 = beginning of thunkoline
"\x7c\xe8\x3b\x78"  // mr r8, r7   ; third param
"\x7c\xc7\x33\x78"  // mr r7, r6   ; second param
"\x7c\xa6\x2b\x78"  // mr r6, r5   ; first param
"\x7c\x65\x1b\x78"  // mr r5, r3   ; receiver
"\x80\x70\x00\x00"  // lwz     r3, 0(r16)  ; load target Block into r3
"\x80\x90\x00\x04"  // lwz     r4, 4(r16)  ; load selector to r4
"\x7c\x08\x03\xa6"  // mtlr    r0          ; return address
"\x81\xf0\x00\x08"  // lwz     r15, 8(r16)  ; load objc_msgSend to r15
"\x7e\x10\x82\x79"  // xor.     r16,r16,r16
"\x7d\xe9\x03\xa6"  // mtctr   r15         ; copy objc_msgSend to count register
"\x4e\x80\x04\x20"  // bctr                ; jump to objc_msgSend, do not update link register (return to caller)
;

unsigned int method4_len = 68;
char* method4 =
"\x7c\x08\x02\xa6"  // mflr r0
"\x7e\x10\x82\x79"  // xor.    r16, r16, r16   ;1. r5 = NULL 
"\x40\x82\xff\xf9"  // bnel    _main           ;2. branch to _main if not equal 
"\x7e\x08\x02\xa6"  // mflr    r16             ;3. r16 = main + 12
"\x3a\x10\xff\xe4"  // subi    r16, r16, 28    ;4. r16 = (main + 12) - 12 - 16 = beginning of thunkoline
"\x7d\x09\x43\x78"  // mr r9, r8   ; fourth param
"\x7c\xe8\x3b\x78"  // mr r8, r7   ; third param
"\x7c\xc7\x33\x78"  // mr r7, r6   ; second param
"\x7c\xa6\x2b\x78"  // mr r6, r5   ; first param
"\x7c\x65\x1b\x78"  // mr r5, r3   ; receiver
"\x80\x70\x00\x00"  // lwz     r3, 0(r16)  ; load target Block into r3
"\x80\x90\x00\x04"  // lwz     r4, 4(r16)  ; load selector to r4
"\x7c\x08\x03\xa6"  // mtlr    r0          ; return address
"\x81\xf0\x00\x08"  // lwz     r15, 8(r16)  ; load objc_msgSend to r15
"\x7e\x10\x82\x79"  // xor.     r16,r16,r16
"\x7d\xe9\x03\xa6"  // mtctr   r15         ; copy objc_msgSend to count register
"\x4e\x80\x04\x20"  // bctr                ; jump to objc_msgSend, do not update link register (return to caller)
;

unsigned int method5_len = 72;
char* method5 =
"\x7c\x08\x02\xa6"  // mflr r0 ; save return address
"\x7e\x10\x82\x79"  // xor.    r16, r16, r16   ; r16 now is zero'd
"\x40\x82\xff\xf9"  // bnel    _main           ; branch to _main if not equal 
"\x7e\x08\x02\xa6"  // mflr    r16             ; r16 = main + 12
"\x3a\x10\xff\xe4"  // subi    r16, r16, 28    ; r16 = (main + 12) - 12 - 16 = beginning of trampoline
"\x7d\x2a\x4b\x78"  // mr r10, r9  ; fifth param
"\x7d\x09\x43\x78"  // mr r9, r8   ; fourth param
"\x7c\xe8\x3b\x78"  // mr r8, r7   ; third param
"\x7c\xc7\x33\x78"  // mr r7, r6   ; second param
"\x7c\xa6\x2b\x78"  // mr r6, r5   ; first param
"\x7c\x65\x1b\x78"  // mr r5, r3   ; receiver
"\x80\x70\x00\x00"  // lwz     r3, 0(r16)  ; load target Block into r3
"\x80\x90\x00\x04"  // lwz     r4, 4(r16)  ; load selector to r4
"\x7c\x08\x03\xa6"  // mtlr    r0          ; return address
"\x81\xf0\x00\x08"  // lwz     r15, 8(r16)  ; load objc_msgSend to r15
"\x7e\x10\x82\x79"  // xor.    r16,r16,r16 ; clear out r16
"\x7d\xe9\x03\xa6"  // mtctr   r15         ; copy objc_msgSend to count register
"\x4e\x80\x04\x20"  // bctr                ; jump to objc_msgSend, do not update link register (return to caller)
;


#define INIT_TRAMPOLINES 0
