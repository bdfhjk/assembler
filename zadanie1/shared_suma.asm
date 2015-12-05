; Addition or substraction initialization
%macro addition_init 0
%%allocate_memory:
    ; Malloc call - allocating memory for BCD number of size l2 + 1
    ; 3 - one additional byte for l2 + 1 character, one for sign and one for end marker
    to_bytes eax, [l2]
    add eax, 3
    call_malloc eax, edi

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
    cmp dh, 240             ;1111 0000
    je %%copy_first_finish
    jmp %%copy_first_loop

%%copy_first_finish:
    nop
%endmacro

; Remove possible trailinig zeros from BCD number at EDI, set it as return variable and exit function. 
%macro adjust_and_exit 0
    get_length_2_internal edi, l2          ; Used to store actual size of variable
    cmp BYTE [l2], 1
    je %%adjust_and_exit_one_byte
    cmp BYTE [l2], 2
    je %%adjust_and_exit_one_byte
    mov eax, [l2]
    mov [l1], eax                           ; Used to store previous size of variable
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
    to_bytes eax, [l2]
    add eax, 2
    call_malloc eax, eax
    mov edx, [edi]      ; Copy the sign of the number
    mov [eax], edx
    to_bytes esi, [l1]  ; ESI point to the number of bytes encoding digits
    inc esi             ; ESI point to the byte with the last digit of ESI (added 1 for sign)
    to_bytes ecx, [l2]
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
    call_free edi
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
