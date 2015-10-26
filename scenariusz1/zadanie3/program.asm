; fasm demonstration of writing 64-bit ELF executable
; note that linux from kernel 2.6.??? needs last segment to be writeable
; else segmentation fault is generated
; compiled with fasm 1.66

; syscall numbers: /usr/src/linux/include/asm-x86_64/unistd.h
; kernel parameters:
; r9	; 6th param
; r8	; 5th param
; r10	; 4th param
; rdx	; 3rd param
; rsi	; 2nd param
; rdi	; 1st param
; eax	; syscall_number
; syscall
;
; return register:
; rax	; 1st
; rdx	; 2nd
;
; preserved accross function call: RBX RBP ESP R12 R13 R14 R15
;
; function parameter (when linked with external libraries):
; r9	; 6th param
; r8	; 5th param
; rcx	; 4th param
; rdx	; 3rd param
; rsi	; 2nd param
; rdi	; 1st param
; call library

global mx3
section .text

mx3:  
    mov eax, edi    ;Zapis do wyniku pierwszej liczby (edi)
    cmp eax, esi    ;Porównanie wyniku z drugą liczbą
    cmovl eax, esi  ;Warunkowo przeniesienie drugiej liczby do wyniku
    
    cmp eax, edx    ;Porównanie wyniku z trzecią liczbą
    cmovl eax, edx  ;Warunkowo przeniesienie trzeciej liczby do wyniku

    ret             ;Powrót. W eax (wynik) znajduje się szukane max z 3 liczb.
