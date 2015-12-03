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

; Save the length of BCD number at pointer %1 to memory at %2
%macro get_length_2_internal 2
    mov eax, 1

%%get_length_2_loop:
    cmp BYTE [ %1 + eax ], 240	; 1111 0000
    je %%get_length_stage_2
    inc eax
    jmp %%get_length_2_loop

%%get_length_stage_2:
    dec eax					; Remove sign byte
    shl eax, 1					; Multiply by 2 (each byte store two digits)
    mov edx, [ %1 + 1 ] 			; Remove possible trailing zero from result
    and edx, 240				; 1111 0000
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
    get_length_2 		            ; compare the length of numbers 
    mov eax, [l1]
    cmp eax, [l2]
    jb %%compare_finish       ; the first number must be smaller
    ja %%compare_swap        ; the first number must be bigger
    mov eax, 1		                ; otherwise check byte by byte

%%compare_loop:
    cmp BYTE [ebx+eax], 240		;1111 0000
    je %%compare_finish
    mov edx, [ebx+eax]              ; compare bytes
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

; Addition or substraction initialization
%macro addition_init 0
%%allocate_memory:
    ; Malloc call - allocating memory for BCD number of size l2 + 1
    ; (l2+1)/2 - number of bytes to store l2 bcd characters with possible leading zero
    ; 3 - one additional byte for l2 + 1 character, one for sign and one for end marker
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
    
; Copying the lager number into allocated memory
%%copy_first_set_sign:
    mov ah, [ecx]
    mov [edi], ah
    
%%copy_first_init:
    mov eax, 1
    mov BYTE [edi + 1], 0   ; First byte should be set to 0, it's l2+1'th, additional byte

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

; Remove possible trailinig zeros from BCD number at EDI, set it as return variable and exit function. 
%macro adjust_and_exit 0
    get_length_2_internal edi, l2   ; Used to store actual size of variable
    mov eax, [l2]
    mov [l1], eax                         ; Used to store previous size of variable
    mov eax, 1
    
%%adjust_and_exit_examine_loop:
    cmp BYTE [edi + eax], 0
    jne %%adjust_and_exit_allocate_memory
    dec DWORD [l2]
    inc eax
    jmp %%adjust_and_exit_examine_loop

%%adjust_and_exit_allocate_memory:

    mov eax, [l2] 
    inc eax
    shr eax, 1
    add eax, 2

    ; Malloc call
    push ecx
    push edx
    
    push eax
    call malloc
    add esp, 4             ; Restore the stack 
    
    pop edx
    pop ecx

    mov edx, [edi]      ; Copy the sign of the number
    mov [eax], edx
    
    mov esi, [l1]          ; ESI is the offset at EDX where the non-zero bytes start
    sub esi, [l2]
    inc esi
    mov ecx, 1
    
%%adjust_and_exit_loop:
    mov dh, [edi + esi]
    mov [eax + ecx], dh
    cmp dh, 240                             ;1111 0000
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
%endmacro
    

    
    
    
    
    
    
    
    
    
    
    
    