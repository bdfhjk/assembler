global W
global H
global E
global M1
global M2
global n
global N

extern malloc
extern memcpy
extern memset

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
MT		resq 1	; initial matrix passed to start function
ME		resq 1	; real size of matrix M1 and M2
TE		resq 1	; real size of matrix T

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
	mov r15, %2
	mov %1, r15
%endmacro

%macro cmemcpy 3
	mov rdi, %1
	mov rsi, %2
	mov rdx, %3
	call memcpy
%endmacro

%macro cmemset 3
	mov rdi, %1
	mov rsi, %2
	mov rdx, %3
	call memset
%endmacro


; r9 - address of temporary table T
; r10 - address of read/write to row
%macro move_vertically 3
	mov r9, 	      %3
	mov r10,	      [T]
	movmm4 	 %1, %2
	mov rax, 0

%%move_vertically_step:
	add r9,	r12
	add r10, 4
	movmm4 	 %1, %2
	inc rax
	cmp rax, 3
	jle %%move_vertically_step	
%endmacro 

%macro multiply_column 0
	move_vertically [r10], [r9], r13		; move from 4 collumn bytes starting at r13 into T
	mov r9, [T]
	movups xmm0, [r9]
	mulps xmm0, xmm1
	movups [r9], xmm0
	move_vertically [r9], [r10], r13  	; move to 4 collumn bytes starting at r13 from T
%endmacro

%macro add_column 0
	move_vertically [r10], [r9], r14 
	mov r9, [T]
	movups xmm0, [r9]
	move_vertically [r10], [r9], r13
	mov r9, [T]
	movups xmm1, [r9]
	addps xmm0, xmm1
	movups [r9], xmm0
	move_vertically [r9], [r10], r13
%endmacro

%macro prologue 0
	enter 0,0
	push r12
	push r13
	push r14
	push r15
	push rbx
%endmacro

%macro epilogue 0
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	leave
	ret
%endmacro

%macro add_line_N 2
; Stage4 - add NW neighbors
	mov r13, [M1]			
	add r13, r12		; Set r13 to point a second line in M1
	mov r14, [M2]		; Set r14 to point a first line in M2
	add r13, %1			; Shift them by %1 / %2
	add r14, %2
	mov rsi, r13			; Store the initial values for current line.
	mov rdi, r14
	
%%add_line_N_loop:
	; Addition using SSE
	movups xmm0, [r13]
	movups xmm1, [r14]
	addps xmm0, xmm1
	movups [r13], xmm0
	
	; Moving to next 4 floats
	add r13, 16
	add r14, 16
	
	; Checking if we are by the end of line
	mov r10, rsi
	add r10, r12
	sub r10, 16		; Removing 16 = margin size
	sub r10, %1		; And removing shift
	
	cmp r13, r10
	jb %%add_line_N_loop
	
	mov dword [r10], 0		;make margin equal to zero
	
	add rsi, r12
	add rdi, r12
	mov r13, rsi
	mov r14, rdi
	
	mov r10, [M1]
	add r10, [ME]
	
	cmp r13, r10
	jb %%add_line_N_loop
%endmacro

%macro add_column_vertically 2
	mov r13, [M1]			
	add r13, r12
	add r13, %1
	mov r14, [M2]
	add r14, r12
	add r14, %2
	mov rsi, r13			; Store the begin address for a current column
	mov rdi, r14			; To by used in calculations when changing collumns
	
%%add_column_vertically_loop:
	; Add 4 column cells starting at r14 to r13
	add_column
	
	; Move 4 rows down
	add r13, r12
	add r13, r12
	add r13, r12
	add r13, r12	

	; Check if we are finished row
	mov r10, [M1]
	add r10, [ME]
	cmp r13, r10
	jb %%add_column_vertically_loop

	; Move to the next pair of collumns
	add rsi, 4
	add rdi, 4
	mov r13, rsi
	mov r14, rdi
	
	; Check if we are finished all collumns (there are W columns each sizeof(float) width)
	mov rax, [W]
	shl rax, 2
	mov r10, rax
	add r10, [M1]
	add r10, r12
	cmp r13, r10
	jb %%add_column_vertically_loop
	
%endmacro

%macro multiply_all 2
	movss xmm1, %1
	shufps xmm1, xmm1, 0x00
	mov r13, [M1]			
	add r13, r12
	mov r14, %2
	add r14, r12

%%multiply_all_loop:
	movups xmm0, [r14]
	mulps xmm0, xmm1
	movups [r13], xmm0
	
	add r13, 16
	add r14, 16
	
	mov r10, [M1]
	add r10, [ME]
	
	cmp r13, r10
	jb %%multiply_all_loop
%endmacro

start:
	prologue

	; Save local variables to global memory
	mov [W], rdi
	mov [H], rsi
	mov [MT], rdx
	
	; Convert float passed as double by calling convention back to float.
	cvtsd2ss xmm1, xmm0
	movss [E], xmm1
	
	; Calculat size of step table T = (H+4) * sizeof(float)
	mov rax, [H]
	lea r11, [rax*4 + 16]		; Size of float is equal to 4
	mov [TE], r11	
	
	; Calculate size with overflow protection = [(W+5) * (H+5)] * sizeof(float)
	mov rax, [W]
	add rax, 5		; Adding 5 for SSE parallel instruction overhead
	mov rbx, [H]		
	add rbx, 5		; Adding 5 for SSE parallel instruction overhead
	mul rbx
	shl rax, 2		; Size of float is equal to 4
	mov r12, rax
	
	; Calculate real size of matrix M1 = (W*(H+4)) * sizeof(float)
	mov rax, [W]
	mov rbx, [H]
	add rbx, 4
	mul rbx
	shl rax, 2		; Size of float is equal to 4
	mov r13, rax
	mov [ME], r13
		
	; Execute memory allocations
	cmalloc [T], r11
	cmalloc [M2], r12
	cmalloc [M1], r12
	
	; Initial zeroing
	cmemset [M1], 0, r12
	cmemset [M2], 0, r12

	; Copy the initial matrix to allocated space
	cmemcpy [M1], [MT], r13
	cmemcpy [M2], [MT], r13	
	
	epilogue


; r12 - store real size of a row
; r13 - current address of M1 (write) 
; r14 - current address of M2 (read)
; r10 - temporary
step:
	prologue
	mov r12, [TE]

; Stage_0 - copy new initial values column
	mov rax, [H]
	shl rax, 2
	cmemcpy [M1], rsi, rax

; Stage1 - multiply all by 5
	multiply_all [PIEC], [M2]

; Stage2 - multiply left/right edge by 3/5. They should be multiplied by 3 not 5 as they have only 3 neighbors
stage_2_prep:
	movss xmm1, [TRZY_PIATE]
	shufps xmm1, xmm1, 0x00
	mov r13, [M1]			
	add r13, r12	

stage_2:	
	;left edge
	multiply_column
	
	add r13, r12
	sub r13, 20

	;right edge
	multiply_column
		
	add r13, r12
	add r13, r12
	add r13, r12
	add r13, r12	
	
	mov r10, [M1]
	add r10, [ME]
	
	cmp r13, r10
	jb stage_2
	
; Stage 3,4,5 - add N, NW, NE neighbor to each cell
	add_line_N 0, 0
	add_line_N 4, 0
	add_line_N 0, 4

; Stage 6,7 - add E, W neighbor to each cell
	add_column_vertically 4, 0
	add_column_vertically 0, 4

; Stage 8 - multiply by the weight
	multiply_all [E], [M1]
	
; Stage 9 - add base value
stage_9_prep:
	mov r13, [M1]			
	add r13, r12
	mov r14, [M2]
	add r14, r12

stage_9:
	movups xmm0, [r14]
	movups xmm1, [r13]
	addps xmm0, xmm1
	movups [r13], xmm0
	
	add r13, 16
	add r14, 16
	
	mov r10, [M1]
	add r10, [ME]
	
	cmp r13, r10
	jb stage_9

; Stage 10 - swap pointers 
stage_10:
	mov rax, [M1]
	mov rbx, [M2]
	mov [M1], rbx
	mov [M2], rax

	epilogue
