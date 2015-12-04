section .text
extern malloc
extern free
extern suma
global iloczyn
%include "shared.asm"


;bcd *iloczyn(bcd *a, bcd *b)


iloczyn:
    nop