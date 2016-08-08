; some preamble to make the assembler happy
section     .text                        ; start of the code indicator
global  _start                             ; make the main function externally visible
  
section .data                             ; beginning of our data section

  msg  db    "Hello, World!",0xa    ; string with a carriage-return

_start:                      ; entry point for linker


;;; Property accessor
get_property:
    call next_line  ; (5) actual function pointer start
next_line:
    pop ecx     ; put address of current line into ebx
    sub ecx, 21 ; [header length (16) + offset to line 'pop ebx' (5)]
    mov edx, [ecx] ; load offset of property to ecx
    add edx, [esp+4] ; calculate actual address of property into ecx
    mov eax, [edx]
    ret
;;; end Property accessor




;;; Zero-argument trampoline
trampoline0:
    call next_line0  ; (5) actual function pointer start
next_line0:
    pop ecx     ; put address of current line into ecx
    sub ecx, 21 ; [header length (16) + offset to line 'pop ecx' (5)]
    
    ;add esp, 16     ; stack pointer has to be aligned on a 4-byte boundary
    
    mov edx, [esp+4]  ; move receiver back over selector
    mov [esp+12], edx
    
    mov edx, [ecx]      ; load impl block to first stack argument
    mov [esp+4], edx
    mov edx, [ecx+4]     ; load value: selector to second stack argument
    mov [esp+8], edx
    
    mov edx, [ecx+8]     ; load address of objc_msgSend and jump
    jmp edx
;;; end Zero-argument trampoline


;;; One-argument trampoline
trampoline1:
    call next_line1  ; (5) actual function pointer start
next_line1:
    pop ecx     ; put address of current line into ecx
    sub ecx, 21 ; [header length (16) + offset to line 'pop ecx' (5)]
    
    ;add esp, 16     ; stack pointer has to be aligned on a 4-byte boundary
    
    mov edx, [esp+12]  ; move first argument back
    mov [esp+16], edx

    mov edx, [esp+4]  ; move receiver back over selector
    mov [esp+12], edx
    
    mov edx, [ecx]      ; load impl block to first stack argument
    mov [esp+4], edx
    mov edx, [ecx+4]     ; load value: selector to second stack argument
    mov [esp+8], edx
    
    mov edx, [ecx+8]     ; load address of objc_msgSend and jump
    jmp edx
;;; end One-argument trampoline



;;; Two-argument trampoline
trampoline2:
    call next_line2  ; (5) actual function pointer start
next_line2:
    pop ecx     ; put address of current line into ecx
    sub ecx, 21 ; [header length (16) + offset to line 'pop ecx' (5)]
    
    ;add esp, 16     ; stack pointer has to be aligned on a 4-byte boundary
    
    mov edx, [esp+16]  ; move second argument back
    mov [esp+20], edx
    mov edx, [esp+12]  ; move first argument back
    mov [esp+16], edx

    mov edx, [esp+4]  ; move receiver back over selector
    mov [esp+12], edx
    
    mov edx, [ecx]      ; load impl block to first stack argument
    mov [esp+4], edx
    mov edx, [ecx+4]     ; load value: selector to second stack argument
    mov [esp+8], edx
    
    mov edx, [ecx+8]     ; load address of objc_msgSend and jump
    jmp edx
;;; end Two-argument trampoline




;;; Three-argument trampoline
trampoline3:
    call next_line3  ; (5) actual function pointer start
next_line3:
    pop ecx     ; put address of current line into ecx
    sub ecx, 21 ; [header length (16) + offset to line 'pop ecx' (5)]
    
    ;add esp, 16     ; stack pointer has to be aligned on a 4-byte boundary
    
    mov edx, [esp+20]  ; move third argument back
    mov [esp+24], edx
    mov edx, [esp+16]  ; move second argument back
    mov [esp+20], edx
    mov edx, [esp+12]  ; move first argument back
    mov [esp+16], edx

    mov edx, [esp+4]  ; move receiver back over selector
    mov [esp+12], edx
    
    mov edx, [ecx]      ; load impl block to first stack argument
    mov [esp+4], edx
    mov edx, [ecx+4]     ; load value: selector to second stack argument
    mov [esp+8], edx
    
    mov edx, [ecx+8]     ; load address of objc_msgSend and jump
    jmp edx
;;; end Three-argument trampoline


;;; Four-argument trampoline
trampoline4:
    call next_line4  ; (5) actual function pointer start
next_line4:
    pop ecx     ; put address of current line into ecx
    sub ecx, 21 ; [header length (16) + offset to line 'pop ecx' (5)]
    
    ;add esp, 16     ; stack pointer has to be aligned on a 4-byte boundary
    
    mov edx, [esp+24]  ; move fourth argument back
    mov [esp+28], edx
    mov edx, [esp+20]  ; move third argument back
    mov [esp+24], edx
    mov edx, [esp+16]  ; move second argument back
    mov [esp+20], edx
    mov edx, [esp+12]  ; move first argument back
    mov [esp+16], edx

    mov edx, [esp+4]  ; move receiver back over selector
    mov [esp+12], edx
    
    mov edx, [ecx]      ; load impl block to first stack argument
    mov [esp+4], edx
    mov edx, [ecx+4]     ; load value: selector to second stack argument
    mov [esp+8], edx
    
    mov edx, [ecx+8]     ; load address of objc_msgSend and jump
    jmp edx
;;; end Four-argument trampoline


;;; Five-argument trampoline
trampoline5:
    call next_line5  ; (5) actual function pointer start
next_line5:
    pop ecx     ; put address of current line into ecx
    sub ecx, 21 ; [header length (16) + offset to line 'pop ecx' (5)]
    
    ;add esp, 16     ; stack pointer has to be aligned on a 4-byte boundary
    
    mov edx, [esp+28]  ; move fifth argument back
    mov [esp+32], edx
    mov edx, [esp+24]  ; move fourth argument back
    mov [esp+28], edx
    mov edx, [esp+20]  ; move third argument back
    mov [esp+24], edx
    mov edx, [esp+16]  ; move second argument back
    mov [esp+20], edx
    mov edx, [esp+12]  ; move first argument back
    mov [esp+16], edx

    mov edx, [esp+4]  ; move receiver back over selector
    mov [esp+12], edx
    
    mov edx, [ecx]      ; load impl block to first stack argument
    mov [esp+4], edx
    mov edx, [ecx+4]     ; load value: selector to second stack argument
    mov [esp+8], edx
    
    mov edx, [ecx+8]     ; load address of objc_msgSend and jump
    jmp edx
;;; end Five-argument trampoline

