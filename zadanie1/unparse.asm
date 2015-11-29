section .text
extern malloc
global unparse
%include "shared.asm"


; char* unparse(bcd* liczba)


unparse: 
    prologue 0		; 0 local variables on the stack
    mov ebx, [ebp+8]
    mov eax, 0

; Calculating the length of input string
get_length:
    mov eax, 0

get_length_loop:
    ;Checking the high nibble
    mov ch, [ebx + eax]
    shr ch, 4
    cmp ch, 15          ;0000 1111
    je get_length_stage_2
    inc eax
    ;Checking the low nibble
    mov ch, [ebx + eax]
    and ch, 15          ;0000 1111
    cmp ch, 15          ;0000 1111
    je get_length_stage_2
    inc eax
    jmp get_length_loop

; Increasing result if the first character is -
get_length_stage_2:
    mov ch, [ebx]
    shr ch, 4
    cmp ch, 13          ;0000 1101
    jne get_length_stage_3
    inc eax

; Saving result in ESI
get_length_stage_3:    
    mov esi, eax

allocate_memory:
    ; Add 1 to previously calculated size for NULL symbol at the end
    add eax, 1
    push eax
    call malloc
    add esp, 4      ; Restore the stack 
    mov edi, eax    ; Save created pointer in EDI

save_number:
    mov ch, [ebx]
    shr ch, 4
    cmp ch, 13          ;0000 1101
    je save_number_handle_minus

save_number_handle_plus:
    mov eax, 0
    jmp save_number_stage_2

save_number_handle_minus:
    mov BYTE [edi], 45     ;'-'
    mov eax, 1

save_number_stage_2:
    mov cl, 1
    mov edx, 0

save_number_loop:
    cmp cl, 1
    je save_number_low_byte

save_number_high_byte:
    mov ch, [ebx + edx]
    and ch, 240     ;1111 0000
    shr ch, 4
    cmp ch, 15      ;0000 1111
    je save_number_finish
    add ch, 48      ;'0'-0
    mov [edi + eax], ch
    mov cl, 1
    inc eax
    jmp save_number_loop

save_number_low_byte:
    mov ch, [ebx + edx]
    and ch, 15      ;0000 1111
    cmp ch, 15      ;0000 1111
    je save_number_finish
    add ch, 48      ;'0'-0
    mov [edi + eax], ch
    mov cl, 0
    inc edx
    inc eax
    jmp save_number_loop

save_number_finish:
    mov BYTE [edi + eax], 0

finish:
    mov eax, edi
    epilogue
    ret
