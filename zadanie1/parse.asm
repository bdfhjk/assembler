section .text
extern malloc
global parse
%include "shared.asm"


; bcd* parse(char* napis)


parse: 
    prologue 0		; 0 local variables on the stack
    mov ebx, [ebp+8]
    mov eax, 0

; Calculating the length of input string
get_length:
    mov eax, 0

get_length_loop:
    cmp BYTE [ebx + eax], 0
    je get_length_stage_2
    inc eax
    jmp get_length_loop

; Decreasing result if the first character is -
get_length_stage_2:
    cmp BYTE [ebx], 45
    jne get_length_stage_3
    dec eax

; Saving result in ESI
get_length_stage_3:    
    mov esi, eax

allocate_memory:
    ; Divide by 2 and add 2 to previously calculated size
    shr eax, 1
    add eax, 2
    push eax
    call malloc
    add esp, 4      ; Restore the stack 
    mov edi, eax    ; Save created pointer in EDI

save_number:
    cmp BYTE [ebx], 45
    je save_number_handle_minus

save_number_handle_plus:
    mov BYTE [edi], 192     ;1100 0000
    mov eax, 0
    jmp save_number_stage_2

save_number_handle_minus:
    mov BYTE [edi], 208     ;1101 0000
    mov eax, 1

save_number_stage_2:
    mov cl, 1
    mov edx, 0

save_number_loop:
    cmp cl, 1
    je save_number_low_byte

save_number_high_byte:
    cmp BYTE [ebx + eax], 0
    je save_number_finish
    mov BYTE [edi + edx], 0
    mov ch, [ebx + eax]
    add [edi + edx], ch
    sub BYTE [edi + edx], 48
    shl BYTE [edi + edx], 4
    mov cl, 1
    inc eax
    jmp save_number_loop

save_number_low_byte:
    cmp BYTE [ebx + eax], 0
    je save_number_finish
    mov ch, [ebx + eax]
    add [edi + edx], ch
    sub BYTE [edi + edx], 48 
    mov cl, 0
    inc edx
    inc eax
    jmp save_number_loop

save_number_finish:
    cmp cl, 1
    je save_number_finish_low

save_number_finish_high:
    mov BYTE [edi + edx], 240    ;1111 0000
    jmp finish

save_number_finish_low:
    add BYTE [edi + edx], 15

finish:
    mov eax, edi
    epilogue
    ret
