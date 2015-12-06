section .text
extern malloc
extern free
extern suma
global roznica
%include "shared.asm"
%include "shared_suma.asm"


; bcd *roznica(bcd *a, bcd *b);


roznica: 
    prologue 0

    mov ebx, [ebp+8]        ; Move the first parameter to EBX
    mov ecx, [ebp+12]       ; Move the second parameter to ECX
        
    cmp BYTE [ecx+1], 0     ; Second parameter represent 0
    je roznica_return_1

    cmp BYTE [ebx+1], 0     ; First parameter represent 0
    je roznica_return_2
    
    mov ah, [ebx]           ; If signs are different, we should use suma function
    mov al, [ecx]
    cmp ah, al
    jne go_suma
    
    compare
    addition_init
    
    to_bytes esi, [l1]
    to_bytes ecx, [l2]
    inc ecx                 ; Adding one for leading 0
    clc

subtraction_loop:
    mov al, [edi + ecx]
    sbb al, [ebx + esi]
    das
    mov [edi + ecx], al
    dec esi
    dec ecx
    jc subtraction_loop_carry

subtraction_loop_no_carry:
    cmp BYTE [ebx + esi], 192              ;1100 0000
    je subtraction_loop_finish
    cmp BYTE [ebx + esi], 208              ;1101 0000
    je subtraction_loop_finish
    clc
    jmp subtraction_loop

subtraction_loop_carry:
    cmp BYTE [ebx + esi], 192               ;1100 0000
    je subtraction_loop_finish_carry_init
    cmp BYTE [ebx + esi], 208               ;1101 0000
    je subtraction_loop_finish_carry_init
    stc
    jmp subtraction_loop
    
subtraction_loop_finish:
    jmp adjust_sign
    
subtraction_loop_finish_carry_init:
    stc

subtraction_loop_finish_carry:
    mov al, [edi + ecx]
    sbb al, 0
    das
    mov [edi + ecx], al
    dec ecx
    jc subtraction_loop_finish_carry

adjust_sign:
    cmp BYTE [d], 1                 ; Check if we made a swap
    je adjust_sign_exit
    cmp BYTE [edi], 192	
    je adjust_sign_make_negative

adjust_sign_make_positive:
    mov BYTE [edi], 192
    jmp adjust_sign_exit

adjust_sign_make_negative:
    mov BYTE [edi], 208

adjust_sign_exit:
    adjust_and_exit

go_suma:
    cmp al, ah
    ja suma_swap
   
    ; EBX - negative, ECX - positive
    mov BYTE [ecx], 208                    ;1101 0000
    push ecx
    push ebx
    call suma
    add esp, 8      ; Restore the stack
    
    epilogue
    ret

suma_swap:
    ; EBX - positive, ECX -  negative
    mov BYTE [ecx], 192                    ;1100 0000
    push ecx
    push ebx
    call suma
    add esp, 8      ; Restore the stack
    
    epilogue
    ret

roznica_return_1:
    copy_bcd ebx
    epilogue
    ret

roznica_return_2:
    copy_bcd ecx
    cmp BYTE [eax], 208
    je roznica_return_2_2
    mov BYTE [eax], 208                    ;1101 0000
    epilogue
    ret

roznica_return_2_2:
    mov BYTE [eax], 192
    epilogue
    ret
