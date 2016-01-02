

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
	

	