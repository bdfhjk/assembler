%include "shared.asm"
%include "shared_iloczyn.asm"
global shift_left_bcd
extern malloc
extern free

; bcd* shift_left_bcd(bcd* a, long long b)


; Shift BCD number a by b digits to the left (multiply by b)
shift_left_bcd:
    prologue 0
    mov ebx, [ebp+8]                    ; Move the first parameter to EBX
    mov ecx, [ebp+12]                   ; Move the second parameter to ECX
    cmp WORD [ebx], 192               ; 1101 0000 0000 0000
    je return_zero
    cmp WORD [ebx], 208               ; 1100 0000 0000 0000
    je return_zero

    get_length_2_internal ebx, l1
    mov eax, [l1]
    add eax, ecx
    to_bytes eax, eax
    add eax, 2
    call_malloc eax, esi
    mov ah, [ebx]
    mov [esi], ah

shift_left_bcd_init:
    mov dl, 1
    mov dh, 1
    mov eax, [l1]
    to_bytes [c], eax
    mov eax, [l1]
    add eax, ecx
    to_bytes [b], eax
    mov eax, [b]
    inc eax                         ; move the end marker
    mov BYTE [esi + eax], 240            ; 1111 0000

shift_left_bcd_loop_zero:
    cmp ecx, 0
    je shift_left_bcd_loop_a
    push ecx
    write_bcd esi, [b], dl, 0
    pop ecx
    dec ecx
    jmp shift_left_bcd_loop_zero

shift_left_bcd_loop_a:
    cmp DWORD [b], 0
    je shift_left_bcd_finish
    read_bcd ebx, [c], dh, ah
    push ecx
    write_bcd esi, [b], dl, ah
    pop ecx
    jmp shift_left_bcd_loop_a

shift_left_bcd_finish:
    call_free ebx
    mov eax, esi
    epilogue
    ret

return_zero:
    create_zero_bcd eax
    epilogue
    ret