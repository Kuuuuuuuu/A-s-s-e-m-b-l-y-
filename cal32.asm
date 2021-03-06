section .data
	FEW_ARGS: db "Error: Arguments", 0xA
	INVALID_OPERAND: db "Error: Invalid", 0XA
	BYTE_BUFFER: times 10 db 0

section .text

	global start

start:
	pop rdx
	cmp rdx, 4
	jne args
	add rsp, 8
	pop rsi
	cmp byte[rsi], 0x2A
	je multiplication
	cmp byte[rsi], 0x78
	je multiplication
	cmp byte[rsi], 0x2B
	je addition
	cmp byte[rsi], 0x2D
	je subtraction
	cmp byte[rsi], 0x2F
	je division
	cmp byte[rsi], 0x25
	je modulo
	jmp invalid

addition:
	pop rsi
	call charint
	mov r10, rax
	pop rsi
	call charint
	add rax, r10
	jmp result

subtraction:
	pop rsi
	call charint
	mov r10, rax
	pop rsi
	call charint
	sub r10, rax
	mov rax, r10
	jmp result

multiplication:
	pop rsi
	call charint
	mov r10, rax
	pop rsi
	call charint
	mul r10
	jmp result

division:
	pop rsi
	call charint
	mov r10, rax
	pop rsi
	call charint
	mov r11, rax
	mov rax, r10
	mov rdx, 0
	div r11
	jmp result

modulo:
    pop rsi
    call charint
    mov r10, rax
    pop rsi
    call charint
    mov r11, rax
    mov rax, r10
    mov rdx, 0
    div r11
    mov rax, rdx
    jmp result


result:
   call intchar
   mov rax, 1
   mov rdi, 1
   mov rsi, r9
   mov rdx, r11
   syscall
   jmp exit

args:
   mov rdi, FEW_ARGS
   call print_error

invalid:
   mov rdi, INVALID_OPERAND
   call print_error

print_error:
	push rdi
	call strlen
	mov rdi, 2
	pop rsi
	mov rdx, rax
	mov rax, 1
	syscall
	call error_exit
	ret

strlen:
	xor rax, rax
.strlen_l:
	cmp BYTE [rdi + rax], 0xA
	je .strlen_b
	inc rax
	jmp .strlen_l
.strlen_b:
	inc rax
	ret

charint:
	xor ax, ax
	xor cx, cx
	mov bx, 10

.loop_block:
	mov cl, [rsi]
	cmp cl, byte 0
	je .rblock
	cmp cl, 0x30
	jl invalid
	cmp cl, 0x39
	jg invalid
	sub cl, 48
  mul bx
	add ax, cx
	inc rsi
	jmp .lblock

.return_block:
	ret

intchar:
	mov rbx, 10
	mov r9, BYTE_BUFFER+10
	mov [r9], byte 0
	dec r9 
	mov [r9], byte 0XA 
	dec r9
	mov r11, 2

.lblock:
	mov rdx, 0
	div rbx
	cmp rax, 0
	je .rblock
	add dl, 48
	mov [r9], dl
	dec r9
	inc r11
	jmp .lblock

.rblock: 
	add dl, 48
	mov [r9], dl
	dec r9
	inc r11
	ret

error_exit:
	mov rax, 60
	mov rdi, 1
	syscall

exit:
	mov rax, 60
	mov rdi, 0
	syscall
