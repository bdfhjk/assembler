; Function parameters [EBP+8], [EBP+12], ...
; Local variables [EBP-4], [EBP-8], ...
; Caller-saved registers: EBX, ECX, EDX, EDI, ESI, EBP

section .data
    l1	DD	0	; Size of the first BCD number
    l2	DD	0	; Size of the second BCD number
    b	DD	0	; Iteration variable used by division and multiplication
    c	DD	0	; Iteration variable used by division and multiplication

%macro prologue 1
    ; Saving base pointer and stack pointer
    push ebp
    mov ebp, esp

    ; Local variables allocation
    sub esp, %1      

    ; Saving caller-save registers
    push esi
    push edi
    push ebx
    push ecx
    push edx
%endmacro

%macro epilogue 0
    ; Restoring caller-save registers
    pop edx
    pop ecx
    pop ebx
    pop edi
    pop esi

    ; Restoring base pointer and stack pointer
    mov esp, ebp
    pop ebp
%endmacro

%macro get_length_2_internal 2
    mov eax, 1

%%get_length_2_loop:
    cmp BYTE [ %1 + eax ], 240	;1111 0000
    je %%get_length_stage_2
    inc eax
    jmp %%get_length_2_loop

%%get_length_stage_2:
    dec eax					; Remove sign byte
    shl eax, 1					; Multiply by 2 (each byte store two digits)
    mov edx, [ %1 + 1 ] 			; Remove possible trailing zero from result
    and edx, 240				;1111 0000
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

%macro compare 0
    get_length_2
    mov eax, [l1]
    cmp eax, [l2]
    jb %%compare_finish  ; the first number must be lower.
    ja %%compare_swap   ; the first number must be bigger
    mov eax, 1

%%compare_loop:
    cmp BYTE [ebx+eax], 240		;1111 0000
    je %%compare_finish
    mov edx, [ebx+eax]
    cmp edx, [ecx+eax]
    jb %%compare_finish
    ja %%compare_swap
    inc eax
    jmp %%compare_loop
    
%%compare_swap:
    xchg ebx, ecx
    mov eax, [l1]
    mov edx, [l2]
    mov [l1], edx
    mov [l2], eax
    
%%compare_finish:
    nop
%endmacro

%macro addition_init 0
%%allocate_memory:
    ; Malloc call
    mov eax, [l2]
    inc eax
    shr eax, 1
    add eax, 3
    push ecx
    push edx
    
    push eax
    call malloc
    add esp, 4      ; Restore the stack 
    
    pop edx
    pop ecx
    ; Save created pointer in EDI
    mov edi, eax
    
    ; Check if numbers are positive or negative
%%copy_first_set_sign:
    mov ah, [ecx]
    mov [edi], ah
    
%%copy_first_init:
    mov eax, 1
    mov BYTE [edi + 1], 0
%%copy_first_loop:
    mov dh, [ecx + eax]
    inc eax
    mov [edi + eax], dh
    cmp dh, 240	;1111 0000
    je %%copy_first_finish
    jmp %%copy_first_loop
%%copy_first_finish:
    nop
%endmacro
    
%macro adjust_and_exit 0
    cmp BYTE [edi + 1], 0
    jne %%adjust_and_exit_preserve
        
    ; Malloc call
    mov eax, [l2] 
    inc eax
    shr eax, 1
    add eax, 2    
    push ecx
    push edx
    
    push eax
    call malloc
    add esp, 4      ; Restore the stack 
    
    pop edx
    pop ecx
    mov edx, [edi]
    mov [eax], edx
    mov esi, 2
    mov ecx, 1
    
%%adjust_and_exit_loop:
    mov dh, [edi + esi]
    mov [eax + ecx], dh
    cmp dh, 240        ;1111 0000
    je %%adjust_and_exit_free
    inc esi
    inc ecx
    jmp %%adjust_and_exit_loop

%%adjust_and_exit_free:
    push ecx
    push edx
    push eax
    
    push edi
    call free
    add esp, 4      ;restore stack
    
    pop eax
    pop edx
    pop ecx
    epilogue
    ret

%%adjust_and_exit_preserve:
    mov eax, edi
    epilogue
    ret
%endmacro
    
    
    
    
    
    
    
    
    
    
    
    
    
    