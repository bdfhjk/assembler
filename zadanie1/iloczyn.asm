section .text
extern malloc
extern free
extern suma
global iloczyn
%include "shared.asm"
%include "shared_iloczyn.asm"


;bcd *iloczyn(bcd *a, bcd *b)


iloczyn:
    nop
;    prologue 0
;    mov ebx, [ebp+8]        ; Move the first parameter to EBX
;    mov ecx, [ebp+12]       ; Move the second parameter to ECX
;    cmp BYTE [ebx+1], 0     ; First parameter is 0
;    ;je iloczyn_return_2
;    cmp BYTE [ecx+1], 0     ; Second parameter is 0
;    ;je iloczyn_return_1
;    compare
;    create_zero_bcd esi
;    create_zero_bcd edi

;multiply_loop_init:
;    mov eax, [l1]
;    inc eax
;    mov [b], eax
;    mov dh, 1
;    mov [c], 0

;multiply_loop:
;    mov eax, ebx
;    add eax, [b]
;    cmp [eax], 192              ;1100 0000
;    je multiply_finish
;    cmp [eax], 208              ;1101 0000
;    je multiply_finish
;    read_bcd ebx, [b], dh, dl
;    call_free esi
;    create_zero_bcd esi

;accumulation_loop:
;    cmp dl, 0
;    je accumulation_loop_finish
;    call_suma ecx, esi
;    call_free esi
;    mov esi, eax
;    dec dl
;    jmp accumulation_loop

;accumulation_loop_finish:
;    call_shift_left_bcd esi, [c]
;    call_suma esi, edi 
;    call_free esi
;    call_free edi
;    mov edi, eax
;    inc [c]
;    jmp multiply_loop

;multiply_finish:
;    multiply_shared_finish