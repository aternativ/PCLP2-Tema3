section .note.GNU-stack

section .data
	output: db "%d", 10, 0

section .text

global reverse_polish_notation

extern getchar
extern printf

; can't call it add because of the instruction
addition:
	call getchar
	pop rbx
	pop rax
	add rax, rbx
	push rax

	jmp read_strings

subtract:
	call getchar
	pop rbx
	pop rax
	sub rax, rbx
	push rax

	jmp read_strings

multiply:
	call getchar
	pop rbx
	pop rax
	imul rax, rbx
	push rax

	jmp read_strings

divide:
	call getchar
	; rax = rdx:rax / rbx
	xor rdx, rdx
	pop rbx
	pop rax
	div rbx
	push rax

	jmp read_strings

reverse_polish_notation:
	push rbp
	mov rbp, rsp
	xor rax, rax
	push rbx
	push r12
	push r13
	push r14
	push r15
	; stack align
	sub rsp, 8

	; rax - temp register for each character
	; rbx - register to form the read number in
	; r12 - power of two to multiply by
	; r13 - counts the number of chars in a num

read_strings:
	call getchar
	; check for EOF
	cmp eax, -1
	je print_value

	; now, check for operators, and get rid of the \n:

	; check for addition:
	cmp rax, '+'
	je addition

	;check for subtraction
	cmp rax, '-'
	je subtract

	; check for multiplication
	cmp rax, '*'
	je multiply

	; check for division
	cmp rax, '/'
	je divide

	; we have a number, convert it to 64-bit
	; to do this, we read and push each char, count them
	; and then pop them one by one, multiplying
	; them by the corresponding power of ten (in r12)

	; convert to corresponding int
	sub rax, '0'
	push rax
	xor r13, r13
	inc r13

read_rest_of_num:
	call getchar
	cmp rax, `\n`
	je after_read_num
	; convert to corresponding int
	sub rax, '0'
	push rax
	inc r13
	jmp read_rest_of_num

after_read_num:
	xor rbx, rbx
	; initial multiplication is by 10^0
	xor r12, r12
	inc r12

conversion_loop:
	; if there are no more chars to evaluate
	cmp r13, 0
	je push_new_value
	pop rax
	imul rax, r12
	add rbx, rax
	; r12 *= 10
	imul r12, 10
	dec r13
	jmp conversion_loop

push_new_value:
	push rbx
	jmp read_strings

print_value:
	mov rdi, output
	pop rsi
	call printf

	; stack align
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	leave
	ret
