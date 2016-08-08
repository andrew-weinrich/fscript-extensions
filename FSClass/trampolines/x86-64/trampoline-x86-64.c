unsigned int method0_len = 34;
char* method0 = 
"\xE8\x00\x00\x00\x00"         // call next_line0 ; (5) actual function pointer start 
"\x41\x5A"                     // pop r10 ; put address of current line into r10 
"\x49\x81\xEA\x25\x00\x00\x00"   // sub r10, 37 ; [header length (16) + offset to line ’pop ecx’ (5)] 
"\x48\x89\xFA"                 // mov rdx, rdi ; mov receiver 
"\x49\x8B\x3A"                 // mov rdi, [r10] ; load impl block to stack argument 
"\x49\x8B\x72\x08"             // mov rsi, [r10+8] ; load value: selector to stack argument 
"\x4D\x8B\x5A\x10"             // mov r11, [r10+16] ; load address of objc_msgSend and jump 
"\x49\xFF\xE3"                 // jmp r11
"\x00\x00\x00"
;
unsigned int method1_len = 36;
char* method1 = 
"\xE8\x00\x00\x00\x00"         // call next_line1 ; (5) actual function pointer start 
"\x41\x5A"                     // pop r10 ; put address of current line into r10 
"\x49\x81\xEA\x25\x00\x00\x00"   // sub r10, 37 ; [header length (16) + offset to line ’pop ecx’ (5)] 
"\x48\x89\xD1"                 // mov rcx, rdx ; move parameter 1 
"\x48\x89\xFA"                 // mov rdx, rdi ; mov receiver 
"\x49\x8B\x3A"                 // mov rdi, [r10] ; load impl block to stack argument 
"\x49\x8B\x72\x08"             // mov rsi, [r10+8] ; load value: selector to stack argument 
"\x4D\x8B\x5A\x10"             // mov r11, [r10+16] ; load address of objc_msgSend and jump 
"\x49\xFF\xE3"                 // jmp r11
"\x00\x00"
;
unsigned int method2_len = 38;
char* method2 = 
"\xE8\x00\x00\x00\x00"         // call next_line2 ; (5) actual function pointer start 
"\x41\x5A"                     // pop r10 ; put address of current line into r10 
"\x49\x81\xEA\x25\x00\x00\x00"   // sub r10, 37 ; [header length (16) + offset to line ’pop ecx’ (5)] 
"\x49\x89\xC8"                 // mov r8, rcx ; move parameter 2 
"\x48\x89\xD1"                 // mov rcx, rdx ; move parameter 1 
"\x48\x89\xFA"                 // mov rdx, rdi ; mov receiver 
"\x49\x8B\x3A"                 // mov rdi, [r10] ; load impl block to stack argument 
"\x49\x8B\x72\x08"             // mov rsi, [r10+8] ; load value: selector to stack argument 
"\x4D\x8B\x5A\x10"             // mov r11, [r10+16] ; load address of objc_msgSend and jump 
"\x49\xFF\xE3"                 // jmp r11
"\x00"
;
unsigned int method3_len = 40;
char* method3 = 
"\xE8\x00\x00\x00\x00"         // call next_line3 ; (5) actual function pointer start 
"\x41\x5A"                     // pop r10 ; put address of current line into r10 
"\x49\x81\xEA\x25\x00\x00\x00"   // sub r10, 37 ; [header length (16) + offset to line ’pop ecx’ (5)] 
"\x4D\x89\xC1"                 // mov r9, r8 ; move parameter 3 
"\x49\x89\xC8"                 // mov r8, rcx ; move parameter 2 
"\x48\x89\xD1"                 // mov rcx, rdx ; move parameter 1 
"\x48\x89\xFA"                 // mov rdx, rdi ; mov receiver 
"\x49\x8B\x3A"                 // mov rdi, [r10] ; load impl block to stack argument 
"\x49\x8B\x72\x08"             // mov rsi, [r10+8] ; load value: selector to stack argument 
"\x4D\x8B\x5A\x10"             // mov r11, [r10+16] ; load address of objc_msgSend and jump 
"\x49\xFF\xE3"                 // jmp r11

;
unsigned int method4_len = 0;
char* method4 = 
""
;
unsigned int method5_len = 0;
char* method5 = 
""
;
/*
unsigned int method2_len = 0;
char* method2 = "";

unsigned int method3_len = 0;
char* method3 = "";

unsigned int method4_len = 0;
char* method4 = "";

unsigned int method5_len = 0;
char* method5 = "";
*/
/*
#define INIT_TRAMPOLINES {\
method2_len = method0_len;\
method2 = method0;\
method3_len = method0_len;\
method3 = method0;\
method4_len = method0_len;\
method4 = method0;\
method5_len = method0_len;\
method5 = method0;\
}
*/
#define INIT_TRAMPOLINES 0
