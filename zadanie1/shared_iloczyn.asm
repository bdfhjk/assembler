%ifndef MACROS_ILOCZYN
%define MACROS_ILOCZYN

%macro create_zero_bcd 1
    call_malloc 3, %1
    mov BYTE [ %1 ], 192
    mov BYTE [ %1 + 1], 0
    mov BYTE [ %1 + 2], 240
%endmacro

%endif