section .note.GNU-stack

section .text

global check_langford
global generate_langford_sequences

extern calloc
extern free

; -- check

bad:
	xor rax, rax
	jmp out_check_langford

check_langford:
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

	; rbx - frequency vector (char *)
	; r12 - sequence (int *)
	; r13 - len

	mov r12, rdi
	mov r13, rsi
	; in reality, the vector only needs to
	; be of size r13 / 2, but we allocate
	; more so i can just start indexing
	; at 1, removing the need to add 1 every time
	mov rdi, r13
	; we can just use 1 byte since we will stop
	; anyways if we have more than 2 apparitions
	xor rsi, rsi
	inc rsi
	call calloc
	mov rbx, rax

	xor rcx, rcx
	xor rax, rax

check_sequence:
	cmp rcx, r13
	je after_check_sequence
	; * 4 for int
	mov eax, [r12 + rcx * 4]
	mov dl, [rbx + rax]
	; check if we already have 2 apparitions
	cmp dl, 2
	jl under_2

	; check failed
	jmp bad

under_2:
	; if we haven't seen it yet, verify
	cmp dl, 0
	; skip if already verified
	jne after_checks

	xor r8, r8
	; is seq[i + x + 1] in bounds?
	; aka rcx + rax + 1 < len?
	xor r9, r9
	mov r9, rax
	inc r9
	add r9, rcx
	cmp r9, r13
	jge bad
	; * 4 for int
	mov r8d, [r12 + r9 * 4]
	cmp eax, r8d
	jne bad

after_checks:
	inc dl
	mov [rbx + rax], dl
	inc rcx
	jmp check_sequence

after_check_sequence:
	xor rcx, rcx
	inc rcx
	; now, only check numbers 1-n
	shr r13, 1
has_every_number:
	cmp rcx, r13
	jg good
	mov dl, [rbx + rcx]
	; no apparition
	cmp dl, 0
	je bad
	inc rcx
	jmp has_every_number

good:
	; if we got here it's valid
	xor rax, rax
	inc rax

out_check_langford:
	mov r12, rax
	mov rdi, rbx
	call free
	mov rax, r12
	; stack align
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	leave
	ret

; -- generate

generate_langford_sequences:
	push rbp
	mov rbp, rsp
	xor rax, rax
	; TODO - write the generate_langford_sequences function
	leave
	ret
