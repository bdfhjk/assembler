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
    dec eax					; Remove end-of-number marker
    shl eax, 2					; Multiply by 2 (each byte store two digits)
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