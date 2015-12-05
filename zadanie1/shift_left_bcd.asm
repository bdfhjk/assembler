%include "shared.asm"
global shift_left_bcd


; bcd* shift_left_bcd(bcd* a, long long b)


; Shift BCD number a by b digits to the left (multiply by b)
shift_left_bcd:
    prologue 0
    epilogue
;    mov ebx, [ebp+8]        ; Move the first parameter to EBX
;    mov ecx, [ebp+12]       ; Move the second parameter to ECX
;    get_length_2_internal ebx, l1
;    mov eax, [l1]
;    add eax, ecx
;    to_bytes eax, eax
;    add eax, 2
;    call_malloc eax, esi

;shift_left_bcd_init:
;    mov dl, 1
;    mov dh, 1
;    mov eax, [l1]
;    to_bytes [c], eax
;    inc DWORD [c]
;    mov eax, [l1]
;    add eax, ecx
;    to_bytes [b], eax
;    inc DWORD [b]

;shift_left_bcd_loop_zero:
;    cmp ecx, 0
;    je shift_left_bcd_loop_a
;    write_bcd esi, [b], dl, 0
;    dec ecx
;    jmp shift_left_bcd_loop_zero

;shift_left_bcd_loop_a:
;    cmp [c], 0
;    je shift_left_bcd_finish
;    read_bcd ebx, [c], dh, ah
;    write_bcd esi, [b], dl, ah
;    dec [c]

;shift_left_bcd_finish:
;    mov [esi], [ebx]
;    call_free ebx
;    mov eax, esi
;    epilogue
