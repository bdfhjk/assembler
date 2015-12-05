%include "shared.asm"

%macro create_zero_2 0
    call_malloc 3, edi
    call_malloc 3, esi
%endmacro

shift_left_bcd:
    prologue 0
    nop
    epilogue