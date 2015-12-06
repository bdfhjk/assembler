section .text
extern suma
extern roznica
extern malloc
extern free
extern shift_left_bcd
extern shift_right_bcd
global iloraz
%include "shared.asm"
%include "shared_iloczyn.asm"


;bcd *iloraz(bcd *a, bcd *b)


iloraz:
    nop
    prologue 0
    mov ebx, [ebp+8]        ; Move the first parameter to EBX
    mov ecx, [ebp+12]       ; Move the second parameter to ECX
    copy_bcd ebx
    mov ebx, eax
    copy_bcd ecx
    mov ecx, eax
    cmp BYTE [ebx+1], 0     ; First parameter is 0
    je iloraz_return_zero
    cmp BYTE [ecx+1], 0     ; Second parameter is 0
    je iloraz_return_zero
    create_zero_bcd edi
    mov BYTE [ebx], 192
    mov BYTE [ecx], 192
    get_length_2

division_loop_init:
    mov eax, [l1]
    sub eax, [l2]
    cmp eax, 0
    jl division_finish
    mov [c], eax

division_loop:
    ; [ecx] > [ebx] ? exit : continue
    call_roznica ebx, ecx
    cmp BYTE [eax + 1], 0
    je division_loop_skip
    cmp BYTE [eax], 208                     ;1101 0000
    je division_finish
division_loop_skip:
    ;call_free eax
    mov esi, [c]
    ;copy_bcd ecx
    call_shift_right_bcd ebx, esi
    mov esi, eax
    mov dl, 0

accumulation_loop:
    ; [ecx] > [esi] ? exit : continue
    call_roznica esi, ecx
    cmp BYTE [eax + 1], 0
    je accumulation_loop_skip
    cmp BYTE [eax], 208                      ;1101 0000
    je accumulation_loop_finish
accumulation_loop_skip:
    ;call_free eax
    mov esi, eax
    mov eax, [c]
    push esi
    call_shift_left_bcd ecx, eax
    call_roznica ebx, eax
    ;call_free ebx
    pop esi
    mov ebx, eax
    inc dl
    jmp accumulation_loop

accumulation_loop_finish:
    create_zero_bcd eax
    mov [eax + 1], dl
    mov esi, [c]
    call_shift_left_bcd eax, esi
    call_suma edi, eax
    ; call_free edi
    mov edi, eax
    dec DWORD [c]
    jmp division_loop

division_finish:
    multiply_shared_finish

iloraz_return_zero:
    create_zero_bcd eax
    epilogue
    ret