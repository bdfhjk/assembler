; Function parameters [EBP+8], [EBP+12], ...
; Local variables [EBP-4], [EBP-8], ...
; Caller-saved registers: EBX, EDI, ESI, ESP, EBP

section .data
    l1  DD  0   ; Size of the first BCD number
    l2  DD  0   ; Size of the second BCD number
    b   DD  0   ; Iteration variable used by division and multiplication
    c   DD  0   ; Iteration variable used by division and multiplication
    d   DD  0   ; 1 if compare switched registers, 0 otherwise

%macro prologue 1
    ; Saving base pointer and stack pointer
    push ebp
    mov ebp, esp

    ; Local variables allocation
    sub esp, %1

    ; Saving calle-save registers
    push esi
    push edi
    push ebx
%endmacro

%macro epilogue 0
    ; Restoring calle-save registers
    pop ebx
    pop edi
    pop esi

    ; Restoring base pointer and stack pointer
    mov esp, ebp
    pop ebp
%endmacro

; Save the length of BCD number at pointer %1 to memory at %2
%macro get_length_2_internal 2
    mov eax, 1

%%get_length_2_loop:
    cmp BYTE [ %1 + eax ], 240      ; 1111 0000
    je %%get_length_stage_2
    inc eax
    jmp %%get_length_2_loop

%%get_length_stage_2:
    dec eax                     ; Remove sign byte
    shl eax, 1                  ; Multiply by 2 (each byte store two digits)
    mov edx, [ %1 + 1 ]         ; Remove possible trailing zero from result
    and edx, 240                ; 1111 0000
    cmp edx, 0
    jne %%get_length_stage_3
    dec eax

%%get_length_stage_3:
    mov [ %2 ], eax
%endmacro 

%macro get_length_2 0
    get_length_2_internal ebx, l1
    get_length_2_internal ecx, l2
%endmacro

; Compare absolute values of BCD's at EBX and ECX, and move the smaller one to EBX, bigger to ECX
; Set l1 and l2 acordingly
%macro compare 0
    get_length_2               ; compare the length of numbers 
    mov BYTE [d], 0
    mov eax, [l1]
    cmp eax, [l2]
    jb %%compare_finish         ; the first number must be smaller
    ja %%compare_swap           ; the first number must be bigger
    mov eax, 1                  ; otherwise check byte by byte

%%compare_loop:
    cmp BYTE [ebx+eax], 240	    ;1111 0000
    je %%compare_finish
    mov dh, [ebx+eax]           ; compare bytes
    cmp dh, [ecx+eax]
    jb %%compare_finish
    ja %%compare_swap
    inc eax
    jmp %%compare_loop
    
%%compare_swap:
    mov BYTE [d], 1
    xchg ebx, ecx
    mov eax, [l1]
    mov edx, [l2]
    mov [l1], edx
    mov [l2], eax
    
%%compare_finish:
    nop
%endmacro

%macro call_malloc 2
    push ecx
    push edx
    
    push %1
    call malloc
    add esp, 4             ; Restore the stack 
    
    pop edx
    pop ecx
    mov %2, eax
%endmacro

%macro call_free 1
    push ecx
    push edx
    push eax
    
    push %1
    call free
    add esp, 4             ; Restore the stack 
    
    pop eax
    pop edx
    pop ecx
%endmacro
    
%macro to_bytes 2
    mov %1, %2
    inc %1
    shr %1, 1
%endmacro
    
    
    
    
    
    
    
    
    
    
    
    