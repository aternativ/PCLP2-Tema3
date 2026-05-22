section .note.GNU-stack

section .text

global check_langford
global generate_langford_sequences

check_langford:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the check_langford function
	leave
	ret

generate_langford_sequences:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the generate_langford_sequences function
	leave
	ret
