section .text
extern malloc
extern free
extern suma
extern shift_left_bcd
global iloczyn
%include "shared.asm"
%include "shared_iloczyn.asm"


;bcd *iloczyn(bcd *a, bcd *b)


iloczyn:
    nop
    prologue 0
    mov ebx, [ebp+8]        ; Move the first parameter to EBX
    mov ecx, [ebp+12]       ; Move the second parameter to ECX
    cmp BYTE [ebx+1], 0     ; First parameter is 0
    je iloczyn_return_zero
    cmp BYTE [ecx+1], 0     ; Second parameter is 0
    je iloczyn_return_zero
    compare
    create_zero_bcd esi
    create_zero_bcd edi

multiply_loop_init:
    mov eax, [l1]
    to_bytes [b], eax
    mov dh, 1
    mov BYTE [c], 0

multiply_loop:
    mov eax, ebx
    add eax, [b]
    cmp BYTE [eax], 192              ;1100 0000
    je multiply_finish
    cmp BYTE [eax], 208              ;1101 0000
    je multiply_finish
    push edi
    read_bcd ebx, [b], dh, dl
    pop edi
    call_free esi
    create_zero_bcd esi

accumulation_loop:
    cmp dl, 0
    je accumulation_loop_finish
    call_suma ecx, esi
    call_free esi
    mov esi, eax
    dec dl
    jmp accumulation_loop

accumulation_loop_finish:
    mov eax, [c]
    call_shift_left_bcd esi, eax
    call_suma esi, edi 
    call_free esi
    call_free edi
    mov edi, eax
    inc DWORD [c]
    jmp multiply_loop

multiply_finish:
    multiply_shared_finish

iloczyn_return_zero:
    create_zero_bcd eax
    epilogue
    ret