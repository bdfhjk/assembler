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
    
    cmp BYTE [l2], 1
    je %%adjust_and_exit_one_byte

    cmp BYTE [l2], 2
    je %%adjust_and_exit_one_byte

    mov eax, [l2]
    mov [l1], eax                         ; Used to store previous size of variable
    mov eax, 1
    
%%adjust_and_exit_examine_loop:
    cmp BYTE [edi + eax], 0
    jne %%adjust_and_exit_allocate_memory
    dec DWORD [l2]
    dec DWORD [l2]
    cmp BYTE [l2], 3
    jl %%adjust_and_exit_allocate_memory
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
    
    mov esi, [l1]
    inc esi
    shr esi, 1		   ; ESI point to the number of bytes encoding digits
    inc esi			   ; Now ESI point to the byte with the last digit of ESI (added 1 for sign)
    
    mov ecx, [l2]
    inc ecx
    shr ecx, 1
    inc ecx

%%adjust_and_exit_loop:
    mov dh, [edi + esi]
    mov [eax + ecx], dh
    
    dec esi
    dec ecx
    cmp ecx, 0
    je %%adjust_and_exit_free
    
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
    
%%adjust_and_exit_one_byte:
    cmp BYTE [edi + 1], 0
    je %%adjust_and_exit_one_byte_negative_zero
    mov eax, edi
    epilogue
    
%%adjust_and_exit_one_byte_negative_zero:
    mov BYTE [edi], 192
    mov eax, edi
    epilogue
%endmacro
