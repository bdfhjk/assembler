section .text
extern malloc
extern free
extern roznica
global suma
%include "shared.asm"
%include "shared_suma.asm"


; bcd* suma(bcd* liczba1 bcd* liczba2)


suma: 
    prologue 0

    mov ebx, [ebp+8]        ; Move the first parameter to EBX
    mov ecx, [ebp+12]       ; Move the second parameter to ECX
    
    cmp BYTE [ebx+1], 0     ; First parameter is 0
    je suma_return_2
    
    cmp BYTE [ecx+1], 0     ; Second parameter is 0
    je suma_return_1
    
    mov ah, [ebx]           ; If signs are different, we should use roznica function
    mov al, [ecx]
    cmp ah, al
    jne go_roznica
    
    compare
    addition_init
    
    to_bytes esi, [l1]
    to_bytes ecx, [l2]
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
    cmp BYTE [ebx + esi], 192            ;1100 0000
    je addition_loop_finish
    cmp BYTE [ebx + esi], 208            ;1101 0000
    je addition_loop_finish
    clc
    jmp addition_loop

addition_loop_carry:
    cmp BYTE [ebx + esi], 192            ;1100 0000
    je addition_loop_finish_carry_init
    cmp BYTE [ebx + esi], 208            ;1101 0000
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

go_roznica:
    cmp al, ah
    ja roznica_swap
   
    ; EBX - ujemna, ECX - dodatnia
    xchg ebx, ecx
    copy_bcd ecx
    mov BYTE [eax], 192                    ;1100 0000
    mov ecx, eax

    push ecx
    push ebx
    call roznica
    add esp, 8                             ; Restore the stack
    epilogue
    ret

roznica_swap:
    ; EBX - dodatnia, ECX -  ujemna
    copy_bcd ecx
    mov BYTE [eax], 192                    ;1100 0000
    mov ecx, eax
    push ecx
    push ebx
    call roznica
    add esp, 8                             ;Restore the stack
    epilogue
    ret

suma_return_1:
    copy_bcd ebx
    epilogue
    ret

suma_return_2:
    copy_bcd ecx
    epilogue
    ret
