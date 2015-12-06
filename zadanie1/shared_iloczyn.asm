%ifndef MACROS_ILOCZYN
%define MACROS_ILOCZYN

%macro create_zero_bcd 1
    call_malloc 3, %1
    mov BYTE [ %1 ], 192
    mov BYTE [ %1 + 1], 0
    mov BYTE [ %1 + 2], 240
%endmacro

%macro multiply_shared_finish 0
    ;call_free esi
    mov ah, [ebx]
    cmp ah, [ecx]
    je %%multiply_finish_positive

%%multiply_finish_negative:
    mov BYTE [edi], 208
    mov eax, edi
    epilogue
    ret

%%multiply_finish_positive:
    mov BYTE [edi], 192
    mov eax, edi
    epilogue
    ret
%endmacro

%endif