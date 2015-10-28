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

global szukaj

section .data
    ile equ 'a'-'A'

section .text

szukaj:
    mov rax, 0  ;pozycja
l1:
    cmp byte [rsi + rax], 0
    je koniec
    cmp byte [rsi + rax], dl
    je koniec2
    inc rax
    jmp l1
koniec:
    mov rax, -1
    ret
koniec2:
    ret
    
