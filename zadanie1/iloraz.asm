section .text
extern suma
extern roznica
global iloraz
%include "shared.asm"


;bcd *iloraz(bcd *a, bcd *b)


iloraz:
    nop
;    prologue 0
;    mov ebx, [ebp+8]        ; Move the first parameter to EBX
;    mov ecx, [ebp+12]       ; Move the second parameter to ECX
;    cmp BYTE [ebx+1], 0     ; First parameter is 0
;    ;je iloraz_return_2
;    cmp BYTE [ecx+1], 0     ; Second parameter is 0
;    ;je iloraz_return_1
;    compare
;    create_zero_bcd esi
;    create_zero_bcd edi

;division_loop_init:
;    mov [b], 1
;    mov dh, ???
;    mov eax, [l2]
;    mov [c], eax

;accumulation_init:
;    call_free esi
;    create_zero_bcd esi
;    put_fragment esi ecx [c]