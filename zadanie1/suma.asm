section .text
extern malloc
extern free
global suma
%include "shared.asm"


; bcd* suma(bcd* liczba1 bcd* liczba2)


suma: 
    prologue 0			; 0 local variables on the stack

    mov ebx, [ebp+8]	; Move the first parameter to EBX
    mov ecx, [ebp+12]	; Move the second parameter to ECX
    
    cmp BYTE [ebx+1], 0		; First parameter represent 0
    je suma_return_2
    
    cmp BYTE [ecx+1], 0		; Second parameter represent 0
    je suma_return_1
    
    compare
    addition_init

    mov ah, [ebx]
    mov al, [ecx]
    cmp ah, al
    jne call_roznica
    
    mov esi, [l1]
    inc esi
    shr esi, 1
    mov ecx, [l2]
    inc ecx
    shr ecx, 1
    inc ecx                 ; Adding one for leading 0
    clc
    
addition_loop:
    mov al, [edi + ecx]
    adc al, [ebx + esi]
    daa
    mov [edi + ecx], al
    dec esi
    dec ecx
    jc addition_loop_carry

addition_loop_no_carry:
    cmp BYTE [ebx + esi], 192        ;1100 0000
    je addition_loop_finish
    cmp BYTE [ebx + esi], 208        ;1101 0000
    je addition_loop_finish
    clc
    jmp addition_loop

addition_loop_carry:
    cmp BYTE [ebx + esi], 192        ;1100 0000
    je addition_loop_finish_carry_init
    cmp BYTE [ebx + esi], 208        ;1101 0000
    je addition_loop_finish_carry_init
    stc
    jmp addition_loop
    
addition_loop_finish:
    adjust_and_exit

addition_loop_finish_carry_init:
    stc

addition_loop_finish_carry:
    mov al, [edi + ecx]
    adc al, 0
    daa
    mov [edi + ecx], al
    dec ecx
    jc addition_loop_finish_carry
    adjust_and_exit

call_roznica:
    cmp ah, al
    ja roznica_swap                     ; EBX - ujemna, ECX - dodatnia
    ;TODO psuje pocz. liczbe
    ;mov [ecx], 192                    ;1100 0000
    ;push ebx
    ;push ecx
    ;call roznica
    epilogue
    ret
    
    roznica_swap:
    ;TODO psuje pocz. liczbe
    ;mov [ebx], 192                    ;1100 0000
    ;push ecx
    ;push ebx
    ;call roznica
    epilogue
    ret
    
suma_return_1:
    mov eax, ebx
    epilogue
    ret

suma_return_2:
    mov eax, ecx
    epilogue
    ret
