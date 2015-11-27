section .text
extern malloc
global parse

; http://www.cs.dartmouth.edu/~sergey/cs108/tiny-guide-to-x86-assembly.pdf

; Function parameters [EBP+8], [EBP+12], ...
; Local variables [EBP-4], [EBP-8], ...
; Caller-saved registers: EBX, ECX, EDX, EDI, ESI, EBP


; bcd* parse(char* napis)
; [EBP-4] - the size of number
parse: 
    push ebp
    mov ebp, esp
    sub esp, 4      ; Local variables allocation
    push esi
    push edi
    push ebx
    push ecx
    push edx
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
    mov eax, 1
    jmp save_number_stage_2

save_number_handle_minus:
    mov BYTE [edi], 208     ;1101 0000
    mov eax, 0

save_number_stage_2:
    mov ecx, 1
    mov edx, 1

save_number_loop:
    cmp ecx, 1
    je save_number_low_byte

save_number_low_byte:
    add BYTE [edi + edx], [ebx + eax]
    sub BYTE [edi + edx], 48 
    mov ecx, 0
    inc edx
    inc eax
    cmp eax, esi    ; ???
    je save_number_finish
    jmp save_number_loop

save_number_high_byte:
save_number_finish:

    pop edx
    pop ecx
    pop ebx
    pop edi
    pop esi
    mov esp, ebp
    pop ebp
    ret
