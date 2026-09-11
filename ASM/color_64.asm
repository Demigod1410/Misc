default rel 
section .data
    fb_path  db '/dev/fb0', 0
section .bss
    fb_fd    resq 1
    pixel    resd 1
section .text
    global _start
_start:
    mov rax, 2
    mov rdi, fb_path
    mov rsi, 2
    syscall
    mov [fb_fd], rax
    mov rbx, 0
draw_loop:
    mov rax, rbx
    xor rdx, rdx
    mov rcx, 1920
    div rcx
    mov r8, rdx
    xor r8, rax
    shr r8, 4
    mov r9, r8
    shl r9, 8
    mov r9, r8
    shl r9, 8
    mov r9, r8
    mov [pixel], r9d
    mov rax, 1
    mov rdi, [fb_fd]
    mov rsi, pixel
    mov rdx, 4
    syscall
    inc rbx
    cmp rbx, 2073600
    jne draw_loop
close_and_exit:
    mov rax, 3
    mov rdi, [fb_fd]
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
