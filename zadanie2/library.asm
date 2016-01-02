global W
global H
global E
global M1
global M2
global n
global N

extern malloc
extern memcpy

global start
global step

section .bss

W		resq	1	; width
H		resq	1	; height
E		resq	1	; weight
M1		resq	1	; base matrix pointer
M2		resq 1	; result matrix pointer
T		resq 1	; temporary space for constants
n		resq 1	; number of steps
N		resq 1	; steps matrix
MT		resq 1	; initial matrix passed to start pointer
ME		resq 1	; pointer for next to the last element of M2

section .data
PIEC		  	dd   5.0
TRZY_PIATE 	dd   0.6

section .text

%macro cmalloc 2
	mov rdi, %2
	call malloc
	mov %1, rax
%endmacro

%macro movmm4 2
	mov r15d, %2
	mov %1, r15d
%endmacro

%macro cmemcpy 3
	mov rdi, %1
	mov rsi, %2
	mov rdx, %3
	call memcpy
%endmacro

%macro stage_2_multipification 0
	mov r9d, 	      r13d
	mov r10d,	      [T]
	movmm4 	 [r10d],  [r9d]
	
	add r9d,	r12d
	add r10d, 4
	movmm4 	 [r10d],  [r9d]
	
	add r9d,	r12d
	add r10d, 4
	movmm4 	 [r10d],  [r9d]
	
	add r9d,	r12d
	add r10d, 4
	movmm4 	 [r10d],  [r9d]
		
	mov r9d, [T]
	movups xmm0, [r9d]
	mulps xmm0, xmm1
	movups [r9d], xmm0

	mov r9d, 	      r13d
	mov r10d,	      [T]
	movmm4 	[r9d], [r10d]

	add r9d,	r12d
	add r10d, 4
	movmm4 	 [r9d],  [r10d]
	
	add r9d,	r12d
	add r10d, 4
	movmm4 	 [r9d],  [r10d]
	
	add r9d,	r12d
	add r10d, 4
	movmm4 	 [r9d],  [r10d]

%endmacro

start:
	enter 0,0
	push r12
	push r13
	push rbx
	
	; Save local variables to global memory
	mov [W], rdi
	mov [H], rsi
	mov [MT], rdx
	
	; Convert float passed as double to float.
	cvtsd2ss xmm1, xmm0
	movss [E], xmm1
	
	; Calculate size with overflow protection = [(W+4) * (H+4)] * sizeof(float)
	mov rax, [W]
	add rax, 5		; for segv prevention
	mov rbx, [H]		
	add rbx, 5		; for segv prevention
	mul rbx
	mov rbx, 4
	mul rbx
	mov r12, rax
	
	; Calculate real size (W*H) * sizeof(float)
	mov rax, [W]
	mov rbx, [H]		
	mul rbx
	mov rbx, 4
	mul rbx
	mov r13, rax
	
	mov rax, [H]
	mov rbx, 4
	mul rbx
	mov r11, rax
	
	cmalloc [M2], r12
	cmalloc [M1], r12
	cmalloc [T], r11 
	cmemcpy [M1], [MT], r13
	cmemcpy [M2], [MT], r13	
	mov [ME], r13
	
	pop rbx
	pop r13
	pop r12
	leave
	ret
	
step:
	enter 0,0
	push r12
	push r13
	push r14
	push r15
	push rbx
	mov eax, 4
	mov ebx, [H]
	mul ebx
	mov r12d, eax

; Stage_0 - copy new initial values column
	
; Stage1 - multiply all by 5
stage_1_prep:
	movss xmm1, [PIEC]
	shufps xmm1, xmm1, 0x00
	mov r13d, [M1]			;r14d store the relative write address for M1
	add r13d, r12d
	mov r14d, [M2]
	add r14d, r12d

stage_1:
	movups xmm0, [r14d]
	mulps xmm0, xmm1
	movups [r13d], xmm0
	
	add r13d, 16
	add r14d, 16
	
	mov r10d, [M1]
	add r10d, [ME]
	
	cmp r13d, r10d
	jb stage_1
	
; Stage2 - multiply left/right edge by 3/5. They should be multiplied by 3 not 5 as they have only 3 neighbors
stage_2_prep:
	movss xmm1, [TRZY_PIATE]
	shufps xmm1, xmm1, 0x00
	mov r13d, [M1]			;r14d store the relative write address for M1
	add r13d, r12d	

stage_2:	
	;left edge
	stage_2_multipification
	
	add r13d, r12d
	sub r13d, 4

	;right edge
	stage_2_multipification
	
	add r13d, r12d
	add r13d, r12d
	add r13d, r12d
	add r13d, r12d	
	
	mov r10d, [M1]
	add r10d, [ME]
	
	cmp r13d, r10d
	jb stage_1	

; Stage 10 - swap pointers 
stage_10:
	mov eax, [M1]
	mov ebx, [M2]
	mov [M1], ebx
	mov [M2], eax

	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	leave
	ret



	