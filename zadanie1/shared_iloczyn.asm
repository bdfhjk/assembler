

%macro create_zero_2 0

    mov eax, 3		; We need three bytes for each

    ; Malloc call
    push ecx
    push edx
    
    push eax
    call malloc
    add esp, 4             ; Restore the stack 
    
    pop edx
    pop ecx
    
    
%endmacro

shift_left_bcd:
    prologue 0
    nop
    epilogue