unsigned int getter_len = 22;
char* getter =
"\xE8\x00\x00\x00\x00"         // call next_line  ; (5) actual function pointer start
"\x59"                         // pop ecx     ; put address of current line into ebx
"\x81\xE9\x15\x00\x00\x00"     // sub ecx, 21 ; [header length (16) + offset to line 'pop ebx' (5)]
"\x8B\x11"                     // mov edx, [ecx] ; load offset of property to ecx
"\x03\x54\x24\x04"             // add edx, [esp+4] ; calculate actual address of property into ecx
"\x8B\x02"                     // mov eax, [edx]
"\xC3"                         // ret
"\x00"
;
unsigned int method0_len = 40;
char* method0 = 
"\xE8\x00\x00\x00\x00"         // call next_line0  ; (5) actual function pointer start
"\x59"                         // pop ecx     ; put address of current line into ecx
"\x81\xE9\x15\x00\x00\x00"     // sub ecx, 21 ; [header length (16) + offset to line 'pop ecx' (5)]
"\x8B\x54\x24\x04"             // mov edx, [esp+4]  ; move receiver back over selector
"\x89\x54\x24\x0C"             // mov [esp+12], edx
"\x8B\x11"                     // mov edx, [ecx]      ; load impl block to first stack argument
"\x89\x54\x24\x04"             // mov [esp+4], edx
"\x8B\x51\x04"                 // mov edx, [ecx+4]     ; load value: selector to second stack argument
"\x89\x54\x24\x08"             // mov [esp+8], edx
"\x8B\x51\x08"                 // mov edx, [ecx+8]     ; load address of objc_msgSend and jump
"\xFF\xE2"                     // jmp edx
"\x00\x00"
;
unsigned int method1_len = 48;
char* method1 = 
"\xE8\x00\x00\x00\x00"         // call next_line1  ; (5) actual function pointer start
"\x59"                         // pop ecx     ; put address of current line into ecx
"\x81\xE9\x15\x00\x00\x00"     // sub ecx, 21 ; [header length (16) + offset to line 'pop ecx' (5)]
"\x8B\x54\x24\x0C"             // mov edx, [esp+12]  ; move first argument back
"\x89\x54\x24\x10"             // mov [esp+16], edx
"\x8B\x54\x24\x04"             // mov edx, [esp+4]  ; move receiver back over selector
"\x89\x54\x24\x0C"             // mov [esp+12], edx
"\x8B\x11"                     // mov edx, [ecx]      ; load impl block to first stack argument
"\x89\x54\x24\x04"             // mov [esp+4], edx
"\x8B\x51\x04"                 // mov edx, [ecx+4]     ; load value: selector to second stack argument
"\x89\x54\x24\x08"             // mov [esp+8], edx
"\x8B\x51\x08"                 // mov edx, [ecx+8]     ; load address of objc_msgSend and jump
"\xFF\xE2"                     // jmp edx
"\x00\x00"
;
unsigned int method2_len = 56;
char* method2 = 
"\xE8\x00\x00\x00\x00"         // call next_line2  ; (5) actual function pointer start
"\x59"                         // pop ecx     ; put address of current line into ecx
"\x81\xE9\x15\x00\x00\x00"     // sub ecx, 21 ; [header length (16) + offset to line 'pop ecx' (5)]
"\x8B\x54\x24\x10"             // mov edx, [esp+16]  ; move second argument back
"\x89\x54\x24\x14"             // mov [esp+20], edx
"\x8B\x54\x24\x0C"             // mov edx, [esp+12]  ; move first argument back
"\x89\x54\x24\x10"             // mov [esp+16], edx
"\x8B\x54\x24\x04"             // mov edx, [esp+4]  ; move receiver back over selector
"\x89\x54\x24\x0C"             // mov [esp+12], edx
"\x8B\x11"                     // mov edx, [ecx]      ; load impl block to first stack argument
"\x89\x54\x24\x04"             // mov [esp+4], edx
"\x8B\x51\x04"                 // mov edx, [ecx+4]     ; load value: selector to second stack argument
"\x89\x54\x24\x08"             // mov [esp+8], edx
"\x8B\x51\x08"                 // mov edx, [ecx+8]     ; load address of objc_msgSend and jump
"\xFF\xE2"                     // jmp edx
"\x00\x00"
;
unsigned int method3_len = 64;
char* method3 = 
"\xE8\x00\x00\x00\x00"         // call next_line3  ; (5) actual function pointer start
"\x59"                         // pop ecx     ; put address of current line into ecx
"\x81\xE9\x15\x00\x00\x00"     // sub ecx, 21 ; [header length (16) + offset to line 'pop ecx' (5)]
"\x8B\x54\x24\x14"             // mov edx, [esp+20]  ; move third argument back
"\x89\x54\x24\x18"             // mov [esp+24], edx
"\x8B\x54\x24\x10"             // mov edx, [esp+16]  ; move second argument back
"\x89\x54\x24\x14"             // mov [esp+20], edx
"\x8B\x54\x24\x0C"             // mov edx, [esp+12]  ; move first argument back
"\x89\x54\x24\x10"             // mov [esp+16], edx
"\x8B\x54\x24\x04"             // mov edx, [esp+4]  ; move receiver back over selector
"\x89\x54\x24\x0C"             // mov [esp+12], edx
"\x8B\x11"                     // mov edx, [ecx]      ; load impl block to first stack argument
"\x89\x54\x24\x04"             // mov [esp+4], edx
"\x8B\x51\x04"                 // mov edx, [ecx+4]     ; load value: selector to second stack argument
"\x89\x54\x24\x08"             // mov [esp+8], edx
"\x8B\x51\x08"                 // mov edx, [ecx+8]     ; load address of objc_msgSend and jump
"\xFF\xE2"                     // jmp edx
"\x00\x00"
;
unsigned int method4_len = 72;
char* method4 = 
"\xE8\x00\x00\x00\x00"         // call next_line4  ; (5) actual function pointer start
"\x59"                         // pop ecx     ; put address of current line into ecx
"\x81\xE9\x15\x00\x00\x00"     // sub ecx, 21 ; [header length (16) + offset to line 'pop ecx' (5)]
"\x8B\x54\x24\x18"             // mov edx, [esp+24]  ; move fourth argument back
"\x89\x54\x24\x1C"             // mov [esp+28], edx
"\x8B\x54\x24\x14"             // mov edx, [esp+20]  ; move third argument back
"\x89\x54\x24\x18"             // mov [esp+24], edx
"\x8B\x54\x24\x10"             // mov edx, [esp+16]  ; move second argument back
"\x89\x54\x24\x14"             // mov [esp+20], edx
"\x8B\x54\x24\x0C"             // mov edx, [esp+12]  ; move first argument back
"\x89\x54\x24\x10"             // mov [esp+16], edx
"\x8B\x54\x24\x04"             // mov edx, [esp+4]  ; move receiver back over selector
"\x89\x54\x24\x0C"             // mov [esp+12], edx
"\x8B\x11"                     // mov edx, [ecx]      ; load impl block to first stack argument
"\x89\x54\x24\x04"             // mov [esp+4], edx
"\x8B\x51\x04"                 // mov edx, [ecx+4]     ; load value: selector to second stack argument
"\x89\x54\x24\x08"             // mov [esp+8], edx
"\x8B\x51\x08"                 // mov edx, [ecx+8]     ; load address of objc_msgSend and jump
"\xFF\xE2"                     // jmp edx
"\x00\x00"
;
unsigned int method5_len = 80;
char* method5 = 
"\xE8\x00\x00\x00\x00"         // call next_line5  ; (5) actual function pointer start
"\x59"                         // pop ecx     ; put address of current line into ecx
"\x81\xE9\x15\x00\x00\x00"     // sub ecx, 21 ; [header length (16) + offset to line 'pop ecx' (5)]
"\x8B\x54\x24\x1C"             // mov edx, [esp+28]  ; move fifth argument back
"\x89\x54\x24\x20"             // mov [esp+32], edx
"\x8B\x54\x24\x18"             // mov edx, [esp+24]  ; move fourth argument back
"\x89\x54\x24\x1C"             // mov [esp+28], edx
"\x8B\x54\x24\x14"             // mov edx, [esp+20]  ; move third argument back
"\x89\x54\x24\x18"             // mov [esp+24], edx
"\x8B\x54\x24\x10"             // mov edx, [esp+16]  ; move second argument back
"\x89\x54\x24\x14"             // mov [esp+20], edx
"\x8B\x54\x24\x0C"             // mov edx, [esp+12]  ; move first argument back
"\x89\x54\x24\x10"             // mov [esp+16], edx
"\x8B\x54\x24\x04"             // mov edx, [esp+4]  ; move receiver back over selector
"\x89\x54\x24\x0C"             // mov [esp+12], edx
"\x8B\x11"                     // mov edx, [ecx]      ; load impl block to first stack argument
"\x89\x54\x24\x04"             // mov [esp+4], edx
"\x8B\x51\x04"                 // mov edx, [ecx+4]     ; load value: selector to second stack argument
"\x89\x54\x24\x08"             // mov [esp+8], edx
"\x8B\x51\x08"                 // mov edx, [ecx+8]     ; load address of objc_msgSend and jump
"\xFF\xE2"                     // jmp edx
"\x00\x00"
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
