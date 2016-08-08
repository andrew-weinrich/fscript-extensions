BITS 64
; some preamble to make the assembler happy
section     .text                        ; start of the code indicator
global  _start                             ; make the main function externally visible
  
section .data                             ; beginning of our data section

  msg  db    "Hello, World!",0xa    ; string with a carriage-return

_start:                      ; entry point for linker




;;; Zero-argument trampoline
trampoline0: 
    call next_line0 ; (5) actual function pointer start 
next_line0: 
    pop r10 ; put address of current line into r10 
    sub r10, 37 ; [header length (16) + offset to line ’pop ecx’ (5)] 
    mov rdx, rdi ; mov receiver 
    mov rdi, [r10] ; load impl block to stack argument 
    mov rsi, [r10+8] ; load value: selector to stack argument 
    mov r11, [r10+16] ; load address of objc_msgSend and jump 
    jmp r11
;;; end Zero-argument trampoline



;;; One-argument trampoline
trampoline1: 
    call next_line1 ; (5) actual function pointer start 
next_line1: 
    pop r10 ; put address of current line into r10 
    sub r10, 37 ; [header length (16) + offset to line ’pop ecx’ (5)] 
    mov rcx, rdx ; move parameter 1 
    mov rdx, rdi ; mov receiver 
    mov rdi, [r10] ; load impl block to stack argument 
    mov rsi, [r10+8] ; load value: selector to stack argument 
    mov r11, [r10+16] ; load address of objc_msgSend and jump 
    jmp r11
;;; end One-argument trampoline



;;; Two-argument trampoline
trampoline2: 
    call next_line2 ; (5) actual function pointer start 
next_line2: 
    pop r10 ; put address of current line into r10 
    sub r10, 37 ; [header length (16) + offset to line ’pop ecx’ (5)] 
    mov r8, rcx ; move parameter 2 
    mov rcx, rdx ; move parameter 1 
    mov rdx, rdi ; mov receiver 
    mov rdi, [r10] ; load impl block to stack argument 
    mov rsi, [r10+8] ; load value: selector to stack argument 
    mov r11, [r10+16] ; load address of objc_msgSend and jump 
    jmp r11
;;; end Two-argument trampoline


;;; Three-argument trampoline
trampoline3: 
    call next_line3 ; (5) actual function pointer start 
next_line3: 
    pop r10 ; put address of current line into r10 
    sub r10, 37 ; [header length (16) + offset to line ’pop ecx’ (5)] 
    mov r9, r8 ; move parameter 3 
    mov r8, rcx ; move parameter 2 
    mov rcx, rdx ; move parameter 1 
    mov rdx, rdi ; mov receiver 
    mov rdi, [r10] ; load impl block to stack argument 
    mov rsi, [r10+8] ; load value: selector to stack argument 
    mov r11, [r10+16] ; load address of objc_msgSend and jump 
    jmp r11
;;; end Three-argument trampoline


