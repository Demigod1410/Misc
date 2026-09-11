[org 0x7c00]
init:
    mov ax, 0x0013
    int 0x10
    mov ax, 0xA000
    mov es, ax
    xor di, di
draw_grid:
    mov ax, di
    mov bx, 320
    xor dx, dx
    div bx
    mov al, dl
    xor al, bl
    mov [es:di], al
    inc di
    cmp di, 64000
    jne draw_grid
halt:
    jmp halt
times 510-($-$$) db 0
dw 0xAA55
