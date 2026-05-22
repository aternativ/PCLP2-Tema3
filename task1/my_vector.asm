section .note.GNU-stack

section .data
	len_error: db "Error: len <= %d", 10, 0
	print_first: db "v -> {(", 0
	character: db "%c", 0
	number_brackets: db "[%d]", 0
	empty_brackets: db "[]", 0
	print_last: db "), %d, %d}", 10, 0
	empty_vector: db "The vector is empty", 10, 0
section .text

global new_vector
global set_element
global get_element
global push_element
global pop_element
global print_vector
global free_vector

;	struct vector {
;		int *arr;
;		int len;
;		int cap;
;	}

extern malloc
extern realloc
extern printf
extern free

struc vector 
	arr: resq 1
	len: resd 1
	cap: resd 1
endstruc

new_vector:
	push rbp
	mov rbp, rsp
	xor rax, rax
	push rbx
	push r12
	push r13
	push r14
	push r15
	; allign stack
	sub rsp, 8

	; rbx - cap
	; r12 - struct *

	mov rbx, rdi
	mov rdi, vector_size
	call malloc
	; rax now contains the struct, move to r12
	mov r12, rax
	mov rdi, rbx
	; * 4 for int
	imul rdi, 4
	call malloc
	; rax is int *
	mov [r12 + arr], rax
	xor rax, rax
	mov [r12 + len], eax
	mov [r12 + cap], ebx
	mov rax, r12

	;
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	leave
	ret

; set_element()

set_element:
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

	; rbx - struct *
	; r12 - int val
	; r13 - int pos
	; r14 - int *

	mov rbx, rdi
	mov r12, rsi
	mov r13, rdx
	mov r14, [rbx + arr]

	mov ecx, [rbx + len]
	cmp ecx, r13d
	jle set_error

	; * 4 for int
	mov [r14 + r13 * 4], esi
	mov rax, r13

	jmp set_out

set_error:
	mov rdi, len_error
	xor rsi, rsi
	mov esi, r13d
	call printf
	; -1 error
	mov rax, -1

set_out:
	; stack align
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	leave
	ret

; get_element()

get_element:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	; stack align
	sub rsp, 8
	xor rax, rax

	; rbx - struct *
	; r12 - pos
	; r13 - int *

	mov rbx, rdi
	mov r12, rsi
	mov r13, [rbx + arr]
	xor rcx, rcx
	mov ecx, [rbx + len]
	cmp ecx, r12d
	jle get_error

	; * 4 for int
	mov eax, [r13 + r12 * 4]
	jmp get_out

get_error:
	mov rdi, len_error
	mov rsi, r12
	call printf
	; -1 error
	mov rax, -1

get_out:
	; stack align
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	leave
	ret

; push_element()

push_element:
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

	; rbx - struct *
	; r12 - int val
	; r13 - int *
	; r14 - length

	mov rbx, rdi
	mov r12, rsi
	mov r13, [rbx + arr]
	xor r14, r14
	mov r14d, [rbx + len]
	inc r14
	xor rcx, rcx
	mov ecx, [rbx + cap]
	mov [rbx + len], r14d
	cmp r14d, ecx
	jg expand

set_push_value:
	dec r14

	; * 4 for int
	mov [r13 + r14 * 4], r12d
	mov rax, r14

	jmp push_out

expand:
	; realloc(ptr, 2 * cap)
	mov rdi, r13
	mov rsi, rcx
	; * 2 for cap
	shl rsi, 1
	mov [rbx + cap], esi
	; * 4 for int
	shl rsi, 2
	call realloc
	mov [rbx + arr], rax
	mov r13, rax

	jmp set_push_value

push_out:
	; stack align
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	leave
	ret

; pop_element()

pop_element:
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

	; rbx - struct *
	; r12 - int *
	; r13 - length
	; r14 - new cap
	; r15 - popped int

	mov rbx, rdi
	mov r12, [rbx + arr]
	xor r13, r13
	; rsi - initial len
	mov r13d, [rbx + len]
	; len != 0?
	cmp r13d, 0
	jne has_elements
	; error
	mov r15, -1
	mov rdi, empty_vector
	call printf
	jmp out_pop

has_elements:
	dec r13
	; r15 - popped int
	xor r15, r15
	; * 4 for int
	mov r15d, [r12 + r13 * 4]
	mov [rbx + len], r13d
	mov eax, [rbx + cap]
	; cap = 1? don't shrink
	cmp eax, 1
	je out_pop
	; cap / 2 >= len?
	; eax - low part
	; edx - high part = 0
	xor rdx, rdx
	xor rax, rax
	mov eax, [rbx + cap]
	xor rcx, rcx
	; divide by 2
	mov cl, 2
	div ecx
	; eax is now cap / 2
	; dec eax
	xor r14, r14
	mov r14d, eax
	cmp eax, r13d
	jge shrink_array
	jmp out_pop

shrink_array:
	mov rdi, r12
	mov [rbx + cap], r14d
	mov rsi, r14
	; * 4 for int
	imul rsi, 4
	call realloc
	mov [rbx + arr], rax

out_pop:
	mov rax, r15
	; stack align
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	leave
	ret

; print_vector()

print_vector:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	; stack align
	sub rsp, 8
	xor rax, rax

	; rbx - struct *
	; r12 - counter
	; r13 - check
	; r14 - arr
	; r15 - len

	mov rbx, rdi
	mov rdi, print_first
	call printf

	xor r12, r12
	xor r13, r13
	mov r13d, [rbx + len]
	mov r14, [rbx + arr]

print_numbers:
	cmp r12d, r13d
	jge after_print_numbers
	; [num]
	mov rdi, number_brackets
	xor rsi, rsi
	; * 4 for int
	mov esi, [r14 + r12 * 4]
	call printf
	inc r12
	jmp print_numbers

after_print_numbers:
	xor r13, r13
	mov r13d, [rbx + cap]

print_empty:
	cmp r12d, r13d
	jge print_rest
	mov rdi, empty_brackets
	call printf
	inc r12
	jmp print_empty

print_rest:
	mov rdi, print_last
	xor rsi, rsi
	mov esi, [rbx + len]
	xor rdx, rdx
	mov edx, [rbx + cap]
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

; free_vector()

free_vector:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	xor rax, rax

	; rbx - vec **
	; r12 - vec *

	mov rbx, rdi
	mov r12, [rbx]
	mov rdi, [r12 + arr]
	call free
	mov rdi, r12
	call free
	xor rax, rax
	mov [rbx], rax

	pop r12
	pop rbx
	leave
	ret
