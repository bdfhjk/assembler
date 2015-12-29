global W
global H
global E
global M1
global M2
global n
global N

extern posix_memalign
extern memcpy

global start

section .bss

W		resq	1
H		resq	1
E		resq	1
M1		resq	1
M2		resq 1
n		resq 1
N		resq 1
MT		resq 1


section .text

start:
	enter 0,0
	push r12
	mov [W], rdi
	mov [H], rsi
	mov [MT], rdx
	cvtsd2ss xmm1, xmm0
	movss [E], xmm1
	
	mov rax, [W]
	mov rbx, [H]
	mul rbx
	
	mov rbx, 4
	mul rbx
	mov r12, rax
	
	mov rdi, M2
	mov rsi, 16
	mov rdx, r12
	call posix_memalign
	
	mov rdi, M1
	mov rsi, 16
	mov rdx, r12
	call posix_memalign
	
	mov rdi, [M1]
	mov rsi, [MT]
	mov rdx, r12
	call memcpy
	
	mov rdi, [M2]
	mov rsi, [MT]
	mov rdx, r12
	call memcpy
	
	pop r12
	leave
	ret
	