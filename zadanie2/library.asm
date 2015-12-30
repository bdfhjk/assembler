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
PIEC		  dd   0x40A00000
TRZY_PIATE dd   0x3F19999A

section .text

%macro cmalloc 2
	mov r15, %2
	call malloc
	mov %1, r15
%endmacro

%macro movmm 2
	mov r15, %2
	mov %1, r15
%endmacro

%macro cmemcpy 3
	mov rdi, %1
	mov rsi, %2
	mov rdx, %3
	call memcpy
%endmacro

%macro stage_2_multipification 0
	movmm [T],		[rax]
	movmm [T+ 4],   	[rax + r12]
	movmm [T + 8],   	[rax + 2 * r12]
	movmm [T + 12], 	[rax + 3 * r12] 
	
	movups xmm0, [T]
	mulps xmm0, xmm1
	movups [T], xmm0
	
	movmm [rax], 		[T]
	movmm [rax + r12], 	[T+ 4]
	movmm [rax + 2 * r12], [T + 8]
	movmm [rax + 3 * r12], [T + 12]
%endmacro

start:
	enter 0,0
	push r12
	
	; Save local variables to global memory
	mov [W], rdi
	mov [H], rsi
	mov [MT], rdx
	
	; Convert float passed as double to float.
	cvtsd2ss xmm1, xmm0
	movss [E], xmm1
	
	mov rax, [W]
	add rax, 4		; for segv prevention
	mov rbx, [H]		
	add rbx, 4		; for segv prevention
	mul rbx
	
	mov rbx, 4
	mul rbx
	mov r12, rax
	
	cmalloc [M2], r12
	cmalloc [M1], r12
	cmalloc [T], 4
	cmemcpy [M1], [MT], r12
	cmemcpy [M2], [MT], r12
	
	mov [ME], [M1]
	add [ME], r12
	
	pop r12
	leave
	ret
	
step:
	enter 0,0
	mov r12, [H]
	
; Stage1 - multiply all by 5
stage_1_prep:
	movups xmm1, [PIEC]
	shufps xmm1, xmm1, 0x00
	mov rax, [M1]				;RAX store the relative write address for M1
	add rax, r12				;Add height. We need to start at the second row of transposed matrix 
	mov rbx, [M2]				;RBX store the relative read address for M2
	add rbx, r12				;as above

stage_1:
	movups xmm0, [rbx]
	mulps xmm0, xmm1
	movups [rax], xmm0
	
	add rax, 16
	add rbx, 16
	
	cmp rax, [ME]
	jl stage_1

; Stage2 - multiply left/right edge by 3/5. They should be multiplied by 3 not 5 as they have only 3 neighbors
stage_2_prep:
	movss xmm1, [TRZY_PIATE]
	shufps xmm1, xmm1, 0x00
	mov rax, [M1]				;RAX store the relative write address for M1
	add rax, r12				;Add height. We need to start at the second row of transposed matrix 

stage_2:	
	;left edge
	stage_2_multipification
	
	add rax, [H]
	dec rax
	
	;right edge
	stage_2_multipification

	; row by row
; Stage3 - add NW neighbors
stage_3:
	
	; Stage4 - add N neighbors
	; Stage5 - add NE neighbors
	
	; column by column
	; Stage6 - add E neighbors
	; Stage7 - add W neighbors

; Stage8 - multiply by weight
stage_8_prep:
	movups xmm1, [E]
	shufps xmm1, xmm1, 0x00
	mov rax, [M1]				;RAX store the relative write address for M1
	add rax, r12				;Add height. We need to start at the second row of transposed matrix 

stage_8:
	movups xmm0, [rax]
	mulps xmm0, xmm1
	movups [rax], xmm0
	
	add rax, 16
	add rbx, 16
	
	cmp rax, [ME]
	jl stage_8

stage_9_prep:
	mov rax, [M1]				;RAX store the relative write address for M1
	add rax, r12				;Add height. We need to start at the second row of transposed matrix 

; Stage9 - add base value
stage_9:
	movups xmm1, [rbx]
	movups xmm0, [rax]
	addps xmm0, xmm1
	movups [rax], xmm0
	add rax, 16
	add rbx, 16
	
	cmp rax, [ME]
	jl stage_9
	
; Stage 10 - swap pointers 
stage_10:
	mov rax, [M1]
	mov rbx, [M2]
	mov [M1], rbx
	mov [M2], rax
	
	leave
	ret
	

	