%include "shared.asm"
global shift_right_bcd


; bcd* shift_right_bcd(bcd* a, long long b)


; Shift BCD number a by b digits to the left (divide by 10^b)
shift_right_bcd:
    prologue 0
    epilogue
