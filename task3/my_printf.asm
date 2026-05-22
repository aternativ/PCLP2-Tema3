section .note.GNU-stack

section .text

global my_printf

my_printf:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the my_printf function
	leave
	ret
