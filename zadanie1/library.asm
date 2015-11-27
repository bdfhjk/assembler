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
    push ebx
    mov ebx, [ebp+8]

    mov eax, 0
get_length:
    cmp [ebx + eax] 0

get_length_end:


    pop ebx
    pop esi
    mov esp, ebp
    pop ebp
    ret
