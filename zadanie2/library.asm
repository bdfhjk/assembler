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
PIEC		  dd   5.0
;PIEC		  dd   0x40A00000
TRZY_PIATE dd   0x3F19999A

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
	movmm4[T],		[rax]
	movmm4 [T+ 4],   	[rax + r12]
	movmm4 [T + 8],   	[rax + 2 * r12]
	movmm4 [T + 12], 	[rax + 3 * r12] 
	
	movups xmm0, [T]
	mulps xmm0, xmm1
	movups [T], xmm0
	
	movmm4 [rax], 		[T]
	movmm4 [rax + r12], 	[T+ 4]
	movmm4 [rax + 2 * r12], [T + 8]
	movmm4 [rax + 3 * r12], [T + 12]
%endmacro

start:
	enter 0,0
	push r12
	push r13
	
	; Save local variables to global memory
	mov [W], rdi
	mov [H], rsi
	mov [MT], rdx
	
	; Convert float passed as double to float.
	cvtsd2ss xmm1, xmm0
	movss [E], xmm1
	
	; Calculate size with overflow protection = [(W+4) * (H+4)] * sizeof(float)
	mov rax, [W]
	add rax, 4		; for segv prevention
	mov rbx, [H]		
	add rbx, 4		; for segv prevention
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
	
	cmalloc [M2], r12
	cmalloc [M1], r12
	cmalloc [T], 4
	cmemcpy [M1], [MT], r13
	cmemcpy [M2], [MT], r13
	
	movmm4 [ME], [M1]
	add [ME], r13
	
	pop r13
	pop r12
	leave
	ret
	
step:
	enter 0,0
	push r12
	mov r12, [H]
		
	
; Stage1 - multiply all by 5
stage_1_prep:
	xorps xmm1, xmm1
	movss xmm1, [PIEC]
	shufps xmm1, xmm1, 0x00
	mov rax, [M1]				;RAX store the relative write address for M1
	add rax, r12				;Add height. We need to start at the second row of transposed matrix 
	mov rbx, [M2]				;RBX store the relative read address for M2
	add rbx, r12				;as above

stage_1:
	;movups xmm0, [rbx]
	;mulps xmm0, xmm1
	;movups [rax], xmm0
	movss [rax], xmm1
;	
;	add rax, 16
;	add rbx, 16
;	
;	cmp rax, [ME]
;	jl stage_1

; Stage 10 - swap pointers 
stage_10:
	mov eax, [M1]
	mov ebx, [M2]
	mov [M1], ebx
	mov [M2], eax
	
	pop r12
	leave
	ret



	