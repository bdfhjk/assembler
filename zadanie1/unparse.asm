section .text
extern malloc
global unparse
%include "shared.asm"


; char* unparse(bcd* liczba)


unparse: 
    prologue 0
    mov ebx, [ebp+8]    ; Move the first parameter to EBX
    mov eax, 0

; Calculating the length of input string
get_length:
    mov eax, 1      ; Setting the counter to start at second byte.
                    ; First byte is reserved for a number sign.

get_length_loop:
    cmp BYTE [ebx + eax], 240   ;1111 0000
    je get_length_stage_2
    inc eax
    jmp get_length_loop

get_length_stage_2:
    dec eax                     ; Decrease for sign value
    shl eax, 1                  ; We need twice more memory
    mov ch, [ebx + 1]           ; Check if the number have a leading 0
    shr ch, 4
    cmp ch, 0
    jne get_length_stage_3
    dec eax

get_length_stage_3:
    cmp BYTE [ebx], 208         ; Check if we need to increase size for '-' char
    jne get_length_stage_4
    inc eax

; Save the result in ESI
get_length_stage_4:
    mov esi, eax

allocate_memory:
    add eax, 1                  ; Add 1 to previously calculated size for NULL symbol at the end
    call_malloc eax, edi

save_number:
    cmp BYTE [ebx], 208
    je save_number_handle_minus

save_number_handle_plus:
    mov eax, 0
    jmp save_number_stage_2

save_number_handle_minus:
    cmp BYTE [ebx+1], 0                     ; 0 exception
    jne save_number_handle_minus_stage_2

save_number_double_check:
    cmp BYTE [ebx+2], 240
    je save_number_handle_plus

save_number_handle_minus_stage_2:
    mov BYTE [edi], 45                      ;'-'
    mov eax, 1

save_number_stage_2:
    mov cl, 0
    mov edx, 1
    mov ch, [ebx + 1]                       ; Check if the number have a leading 0
    shr ch, 4
    cmp ch, 0
    jne save_number_loop
    mov cl, 1
 
save_number_loop:
    cmp cl, 1
    je save_number_low_byte

save_number_high_byte:
    mov ch, [ebx + edx]
    cmp ch, 240                 ;1111 0000
    je save_number_finish
    and ch, 240                 ;1111 0000
    shr ch, 4
    add ch, 48                  ;'0'-0
    mov [edi + eax], ch
    mov cl, 1
    inc eax
    jmp save_number_loop

save_number_low_byte:
    mov ch, [ebx + edx]
    and ch, 15                  ;0000 1111
    add ch, 48                  ;'0'-0
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
