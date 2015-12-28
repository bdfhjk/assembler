section .text
global trzy

ARG		equ	4

trzy:
	push rbp
	mov rbp, rsp
	mov ebx, 1
	mov ecx, ARG

l1:
	cmp ecx, 1
	jle koniec
	imul ebx, ecx
	dec ecx
	jmp l1

koniec:
	mov eax, ebx
	pop rbp
	ret
	