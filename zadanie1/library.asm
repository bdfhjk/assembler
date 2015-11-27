section .text
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

get_length_stage_2:
    cmp BYTE [ebx], 45
    jne get_length_stage_3
    dec eax

get_length_stage_3:    
    mov esi, eax

    pop ebx
    pop edi
    pop esi
    mov esp, ebp
    pop ebp
    ret
