unsigned int method0_len = 52;
char* method0 =
"\x7c\x08\x02\xa6"  // mflr r0
"\x7e\x10\x82\x79"  // xor.    r16, r16, r16   ;1. r5 = NULL 
"\x40\x82\xff\xf9"  // bnel    _main           ;2. branch to _main if not equal 
"\x7e\x08\x02\xa6"  // mflr    r16             ;3. r16 = main + 12
"\x3a\x10\xff\xd4"  // subi    r16, r16, 44    ;4. r16 = (main + 12) - 12 - 16 = beginning of thunkoline
"\x7c\x65\x1b\x78"  // mr r5, r3   ; receiver
"\xe8\x70\x00\x00"  // ld r3, 0(r16)  ; load target Block into r3
"\xe8\x90\x00\x08"  // ld r4, 8(r16)  ; load selector to r4
"\x7c\x08\x03\xa6"  // mtlr    r0          ; return address
"\xe9\xf0\x00\x10"  // ld     r15, 16(r16)  ; load objc_msgSend to r15
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
"\x3a\x10\xff\xd4"  // subi    r16, r16, 44    ;4. r16 = (main + 12) - 12 - 16 = beginning of thunkoline
"\x7c\xa6\x2b\x78"  // mr r6, r5   ; first param
"\x7c\x65\x1b\x78"  // mr r5, r3   ; receiver
"\xe8\x70\x00\x00"  // ld     r3, 0(r16)  ; load target Block into r3
"\xe8\x90\x00\x08"  // ld     r4, 8(r16)  ; load selector to r4
"\x7c\x08\x03\xa6"  // mtlr    r0          ; return address
"\xe9\xf0\x00\x10"  // ld     r15, 16(r16)  ; load objc_msgSend to r15
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
"\x3a\x10\xff\xd4"  // subi    r16, r16, 44    ;4. r16 = (main + 12) - 12 - 16 = beginning of thunkoline
"\x7c\xc7\x33\x78"  // mr r7, r6   ; second param
"\x7c\xa6\x2b\x78"  // mr r6, r5   ; first param
"\x7c\x65\x1b\x78"  // mr r5, r3   ; receiver
"\xe8\x70\x00\x00"  // ld     r3, 0(r16)  ; load target Block into r3
"\xe8\x90\x00\x08"  // ld     r4, 8(r16)  ; load selector to r4
"\x7c\x08\x03\xa6"  // mtlr    r0          ; return address
"\xe9\xf0\x00\x10"  // ld     r15, 16(r16)  ; load objc_msgSend to r15
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
"\x3a\x10\xff\xd4"  // subi    r16, r16, 44    ;4. r16 = (main + 12) - 12 - 32 = beginning of thunkoline
"\x7c\xe8\x3b\x78"  // mr r8, r7   ; third param
"\x7c\xc7\x33\x78"  // mr r7, r6   ; second param
"\x7c\xa6\x2b\x78"  // mr r6, r5   ; first param
"\x7c\x65\x1b\x78"  // mr r5, r3   ; receiver
"\xe8\x70\x00\x00"  // ld     r3, 0(r16)  ; load target Block into r3
"\xe8\x90\x00\x08"  // ld     r4, 8(r16)  ; load selector to r4
"\x7c\x08\x03\xa6"  // mtlr    r0          ; return address
"\xe9\xf0\x00\x10"  // ld     r15, 16(r16)  ; load objc_msgSend to r15
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
"\x3a\x10\xff\xd4"  // subi    r16, r16, 44    ;4. r16 = (main + 12) - 12 - 16 = beginning of thunkoline
"\x7d\x09\x43\x78"  // mr r9, r8   ; fourth param
"\x7c\xe8\x3b\x78"  // mr r8, r7   ; third param
"\x7c\xc7\x33\x78"  // mr r7, r6   ; second param
"\x7c\xa6\x2b\x78"  // mr r6, r5   ; first param
"\x7c\x65\x1b\x78"  // mr r5, r3   ; receiver
"\xe8\x70\x00\x00"  // ld     r3, 0(r16)  ; load target Block into r3
"\xe8\x90\x00\x08"  // ld     r4, 8(r16)  ; load selector to r4
"\x7c\x08\x03\xa6"  // mtlr    r0          ; return address
"\xe9\xf0\x00\x10"  // ld     r15, 16(r16)  ; load objc_msgSend to r15
"\x7e\x10\x82\x79"  // xor.     r16,r16,r16
"\x7d\xe9\x03\xa6"  // mtctr   r15         ; copy objc_msgSend to count register
"\x4e\x80\x04\x20"  // bctr                ; jump to objc_msgSend, do not update link register (return to caller)
;

unsigned int method5_len = 72;
char* method5 =
"\x7c\x08\x02\xa6"  // mflr r0
"\x7e\x10\x82\x79"  // xor.    r16, r16, r16   ; r16 now is zero'd
"\x40\x82\xff\xf9"  // bnel    _main           ; branch to _main if not equal 
"\x7e\x08\x02\xa6"  // mflr    r16             ; r16 = main + 12
"\x3a\x10\xff\xd4"  // subi    r16, r16, 44    ; r16 = (main + 12) - 12 - 16 = beginning of trampoline
"\x7d\x2a\x4b\x78"  // mr r10, r9  ; fifth param
"\x7d\x09\x43\x78"  // mr r9, r8   ; fourth param
"\x7c\xe8\x3b\x78"  // mr r8, r7   ; third param
"\x7c\xc7\x33\x78"  // mr r7, r6   ; second param
"\x7c\xa6\x2b\x78"  // mr r6, r5   ; first param
"\x7c\x65\x1b\x78"  // mr r5, r3   ; receiver
"\xe8\x70\x00\x00"  // ld     r3, 0(r16)  ; load target Block into r3
"\xe8\x90\x00\x08"  // ld     r4, 8(r16)  ; load selector to r4
"\x7c\x08\x03\xa6"  // mtlr    r0          ; return address
"\xe9\xf0\x00\x10"  // ld     r15, 16(r16)  ; load objc_msgSend to r15
"\x7e\x10\x82\x79"  // xor.    r16,r16,r16 ; clear out r16
"\x7d\xe9\x03\xa6"  // mtctr   r15         ; copy objc_msgSend to count register
"\x4e\x80\x04\x20"  // bctr                ; jump to objc_msgSend, do not update link register (return to caller)
;


#define INIT_TRAMPOLINES 0
