%include "shared.asm"
%include "shared_iloczyn.asm"
global shift_right_bcd
extern malloc
extern free


; bcd* shift_right_bcd(bcd* a, long long b)


; Shift BCD number a by b digits to the right (divide by 10^b)
shift_right_bcd:
    prologue 0
    mov ebx, [ebp+8]                    ; Move the first parameter to EBX
    mov ecx, [ebp+12]                   ; Move the second parameter to ECX
    cmp WORD [ebx], 192                 ; 1101 0000 0000 0000
    je return_zero
    cmp WORD [ebx], 208                 ; 1100 0000 0000 0000
    je return_zero

    get_length_2_internal ebx, l1
    mov eax, [l1]
    sub eax, ecx
    
    cmp eax, 1
    jl return_zero
    
    to_bytes eax, eax
    add eax, 2
    call_malloc eax, esi
    mov ah, [ebx]
    mov [esi], ah

shift_right_bcd_init:
    mov dl, 1
    mov eax, [l1]
    sub eax, ecx
    to_bytes [c], eax
    mov eax, ecx
    and eax, 1
    cmp eax, 1
    je shift_right_bcd_no_alter

shift_right_bcd_alter:
    mov dh, 1
    jmp shift_right_bcd_stage_2

shift_right_bcd_no_alter:
    mov dh, 0
    mov eax, [l1]
    and eax, 1
    add [c], eax

shift_right_bcd_stage_2:
    mov eax, [l1]
    sub eax, ecx
    to_bytes [b], eax
    mov eax, [b]
    inc eax                              ; move to the end marker
    mov BYTE [esi + eax], 240            ; 1111 0000
    mov eax, [l1]
    sub eax, ecx
    mov [t1], eax

shift_left_bcd_loop_a:
    cmp DWORD [t1], 0
    je shift_left_bcd_finish
    read_bcd ebx, [c], dh, ah
    push ecx
    write_bcd esi, [b], dl, ah
    pop ecx
    dec DWORD [t1]
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