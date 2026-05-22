section .note.GNU-stack

section .text

global my_printf

default rel
extern putc
extern stdout

	; i used the following convention:
	; ir r13 != 5 after inc, r14 += 8
	; if r13 == 5 after inc, r14 = rbp + 16

update_counters:
	inc r12
	inc r13
	; check if it is over the register limit
	cmp r13, 5
	jne not_5

	; skip rbp and rip from stack
	; after exhausting register args
	lea r14, [rbp + 16]
	jmp parse_format

not_5:
	; get next argument
	add r14, 8
	jmp parse_format

; -- string printing

string:
	xor r15, r15
	mov rdx, [r14]

print_string:
	xor rdi, rdi
	mov dil, [rdx + r15]
	; check for \0
	cmp dil, 0
	je out_string
	mov rsi, [stdout]
	push rdx
	call putc
	pop rdx
	inc r15
	jmp print_string

out_string:
	jmp update_counters

; --

; -- long printing

u_long:
	mov r15, [r14]
	; get base 10 representation:
	xor rcx, rcx
	xor r8, r8
	; r8 - divide by 10
	mov r8b, 10

decomp_loop:
	mov rax, r15
	; rax = rdx:rax / r8, rdx - remainder
	xor rdx, rdx
	div r8
	mov r15, rax
	; continue if not nil
	cmp rax, 0
	jne not_0
	; if both are nil, we stop
	cmp rdx, 0
	je after_decomp
not_0:
	push rdx
	inc rcx
	jmp decomp_loop

after_decomp:
	mov r15, rcx

print_long:
	; print all of the numbers that we put on the stack
	cmp r15, 0
	je out_u_long
	pop rdi
	add rdi, '0'
	mov rsi, [stdout]
	call putc
	dec r15
	jmp print_long

out_u_long:
	jmp update_counters

; --

char:
	mov rdi, [r14]
	mov rsi, [stdout]
	call putc
	jmp update_counters

my_printf:
	push rbp
	mov rbp, rsp
	xor rax, rax
	push rbx
	push r12
	push r13
	push r14
	push r15

	; push the registers for easier access
	push r9
	push r8
	push rcx
	push rdx
	push rsi

	; rbx - format
	; r12 - index for format
	; r13 - counter for arguments
	; (how many have been used up)
	; r14 - pointer to the first argument 
	; initially (rsi)
	; r15 - temp

	mov r14, rsp

	mov rbx, rdi
	xor r12, r12
	xor r13, r13
parse_format:
	xor rax, rax
	mov al, [rbx + r12]
	; check for EOF
	cmp al, 0
	je end_print
	cmp al, '%'
	jne normal

	; check which specifier it is:
	inc r12
	mov al, [rbx + r12]

	cmp al, 'c'
	je char

	cmp al, 's'
	je string

	; it is lu
	inc r12
	jmp u_long

normal:
	mov rdi, rax
	mov rsi, [stdout]
	call putc
	inc r12
	jmp parse_format

end_print:

	pop rsi
	pop rdx
	pop rcx
	pop r8
	pop r9
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx

	leave
	ret
