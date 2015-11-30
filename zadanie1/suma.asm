section .text
extern malloc
global suma
%include "shared.asm"


; bcd* suma(bcd* liczba1 bcd* liczba2)


suma: 
    prologue 0			; 0 local variables on the stack

    mov ebx, [ebp+8]	; Move the first parameter to EBX
    mov ecx, [ebp+12]	; Move the second parameter to ECX
    
    compare
    
    mov eax, ebx

    epilogue
    ret