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
	mov r15d, %2
	mov %1, r15d
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

%macro move_vertically 3
	mov r9d, 	      %3
	mov r10d,	      [T]
	movmm4 	 %1, %2
	mov rax, 0

%%move_vertically_step:
	add r9d,	r12d
	add r10d, 4
	movmm4 	 %1, %2
	inc rax
	cmp rax, 3
	jle %%move_vertically_step	
%endmacro 

%macro multiply_column 0
	move_vertically [r10d], [r9d], r13d		; move from 4 collumn bytes starting at r13d into T
	mov r9d, [T]
	movups xmm0, [r9d]
	mulps xmm0, xmm1
	movups [r9d], xmm0
	move_vertically [r9d], [r10d], r13d  	; move to 4 collumn bytes starting at r13d from T
%endmacro

%macro add_column 0
	move_vertically [r10d], [r9d], r14d 
	mov r9d, [T]
	movups xmm0, [r9d]
	move_vertically [r10d], [r9d], r13d
	mov r9d, [T]
	movups xmm1, [r9d]
	addps xmm0, xmm1
	movups [r9d], xmm0
	move_vertically [r9d], [r10d], r13d
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
	mov r13d, [M1]			
	add r13d, r12d		; Set r13d to point a second line in M1
	mov r14d, [M2]		; Set r14d to point a first line in M2
	add r13d, %1			; Shift them by %1 / %2
	add r14d, %2
	mov esi, r13d			; Store the initial values for current line.
	mov edi, r14d
	
%%add_line_N_loop:
	; Addition using SSE
	movups xmm0, [r13d]
	movups xmm1, [r14d]
	addps xmm0, xmm1
	movups [r13d], xmm0
	
	; Moving to next 4 floats
	add r13d, 16
	add r14d, 16
	
	; Checking if we are by the end of line
	mov r10d, esi
	add r10d, r12d
	sub r10d, 16		; Removing 16 = margin size
	sub r10d, %1		; And removing shift
	
	cmp r13d, r10d
	jb %%add_line_N_loop
	
	mov dword [r10d], 0		;make margin equal to zero
	
	add esi, r12d
	add edi, r12d
	mov r13d, esi
	mov r14d, edi
	
	mov r10d, [M1]
	add r10d, [ME]
	
	cmp r13d, r10d
	jb %%add_line_N_loop
%endmacro

%macro add_column_vertically 2
	mov r13d, [M1]			
	add r13d, r12d
	add r13d, %1
	mov r14d, [M2]
	add r14d, r12d
	add r14d, %2
	mov esi, r13d			; Store the begin address for a current column
	mov edi, r14d			; To by used in calculations when changing collumns
	
%%add_column_vertically_loop:
	; Add 4 column cells starting at r14d to r13d
	add_column
	
	; Move 4 rows down
	add r13d, r12d
	add r13d, r12d
	add r13d, r12d
	add r13d, r12d	

	; Check if we are finished row
	mov r10d, [M1]
	add r10d, [ME]
	cmp r13d, r10d
	jb %%add_column_vertically_loop

	; Move to the next pair of collumns
	add esi, 4
	add edi, 4
	mov r13d, esi
	mov r14d, edi
	
	; Check if we are finished all collumns (there are W columns each sizeof(float) width)
	mov eax, [W]
	mov ebx, 4
	mul ebx
	mov r10d, eax
	add r10d, [M1]
	add r10d, r12d
	cmp r13d, r10d
	jb %%add_column_vertically_loop
	
%endmacro

%macro multiply_all 2
	movss xmm1, %1
	shufps xmm1, xmm1, 0x00
	mov r13d, [M1]			
	add r13d, r12d
	mov r14d, %2
	add r14d, r12d

%%multiply_all_loop:
	movups xmm0, [r14d]
	mulps xmm0, xmm1
	movups [r13d], xmm0
	
	add r13d, 16
	add r14d, 16
	
	mov r10d, [M1]
	add r10d, [ME]
	
	cmp r13d, r10d
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
	add rax, 4
	mov rbx, 4		; Size of float is equal to 4
	mul rbx
	mov r11, rax
	mov [TE], r11	
	
	; Calculate size with overflow protection = [(W+5) * (H+5)] * sizeof(float)
	mov rax, [W]
	add rax, 5		; Adding 5 for SSE parallel instruction overhead
	mov rbx, [H]		
	add rbx, 5		; Adding 5 for SSE parallel instruction overhead
	mul rbx
	mov rbx, 4		; Size of float is equal to 4
	mul rbx
	mov r12, rax
	
	; Calculate real size of matrix M1 = (W*(H+4)) * sizeof(float)
	mov rax, [W]
	mov rbx, [H]
	add rbx, 4
	mul rbx
	mov rbx, 4		; Size of float is equal to 4
	mul rbx
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

step:
	prologue
	mov r12d, [TE]

; Stage_0 - copy new initial values column
	mov rax, [H]
	mov rbx, 4
	mul rbx
	cmemcpy [M1], rsi, rax

; Stage1 - multiply all by 5
	multiply_all [PIEC], [M2]

; Stage2 - multiply left/right edge by 3/5. They should be multiplied by 3 not 5 as they have only 3 neighbors
stage_2_prep:
	movss xmm1, [TRZY_PIATE]
	shufps xmm1, xmm1, 0x00
	mov r13d, [M1]			
	add r13d, r12d	

stage_2:	
	;left edge
	multiply_column
	
	add r13d, r12d
	sub r13d, 20

	;right edge
	multiply_column
		
	add r13d, r12d
	add r13d, r12d
	add r13d, r12d
	add r13d, r12d	
	
	mov r10d, [M1]
	add r10d, [ME]
	
	cmp r13d, r10d
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
	mov r13d, [M1]			
	add r13d, r12d
	mov r14d, [M2]
	add r14d, r12d

stage_9:
	movups xmm0, [r14d]
	movups xmm1, [r13d]
	addps xmm0, xmm1
	movups [r13d], xmm0
	
	add r13d, 16
	add r14d, 16
	
	mov r10d, [M1]
	add r10d, [ME]
	
	cmp r13d, r10d
	jb stage_9

; Stage 10 - swap pointers 
stage_10:
	mov eax, [M1]
	mov ebx, [M2]
	mov [M1], ebx
	mov [M2], eax

	epilogue