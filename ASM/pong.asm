org 0x7C00          ; BIOS loads bootloader here

section .text
start:
    xor ax, ax          ; DS = 0 so variables/BDA access is reliable
    mov ds, ax
    push 0xA000         ; ES -> VGA video memory
    pop es

reset_game:
    mov byte [p1_score], '0'
    mov byte [p2_score], '0'
    mov word [p1_y], 80
    mov word [p2_y], 80
    call reset_round

game_loop:
    ; 1. FRAME TIMING / DELAY
    mov ah, 86h
    xor cx, cx
    mov dx, 14000
    int 15h

    ; 2. CHECK WIN STATE
    cmp byte [p1_score], '7'
    je game_over_screen
    cmp byte [p2_score], '7'
    je game_over_screen

    ; 3. CLEAR SCREEN (mode reset)
    mov ax, 0x0013
    int 10h

    ; 4. DRAW ENTITIES
    mov cx, 5
    mov dx, [p1_y]
    mov bl, 10
    mov bh, 40
    call render_rect

    mov cx, 305
    mov dx, [p2_y]
    call render_rect

    mov cx, [ball_x]
    mov dx, [ball_y]
    mov bl, 5
    mov bh, 5
    call render_rect

    ; 5. PRINT SCORES
    mov ah, 02h
    xor bh, bh
    mov dh, 1
    mov dl, 12
    int 10h
    mov al, [p1_score]
    mov ah, 0Eh
    int 10h

    mov ah, 02h
    mov dl, 26
    int 10h
    mov al, [p2_score]
    mov ah, 0Eh
    int 10h

    ; 6. PROCESS INPUT (non-blocking)
    mov ah, 01h
    int 16h
    jz move_ball

    mov ah, 00h
    int 16h             ; AH = scan code, AL = ASCII

    cmp al, 'w'
    je p1_u
    cmp al, 's'
    je p1_d

    cmp ah, 0x48        ; Arrow Up
    je p2_u
    cmp ah, 0x50        ; Arrow Down
    je p2_d
    jmp move_ball

p1_u:
    mov si, p1_y
    mov ax, -22
    jmp move_p
p1_d:
    mov si, p1_y
    mov ax, 22
    jmp move_p
p2_u:
    mov si, p2_y
    mov ax, -22
    jmp move_p
p2_d:
    mov si, p2_y
    mov ax, 22

move_p:
    call move_paddle

move_ball:
    ; 7. BALL PHYSICS
    mov ax, [ball_vx]
    add [ball_x], ax
    mov ax, [ball_vy]
    add [ball_y], ax

    mov ax, [ball_y]
    cmp ax, 2
    jle bounce_y
    cmp ax, 194
    jge bounce_y
    jmp check_p1_collision

bounce_y:
    neg word [ball_vy]

check_p1_collision:
    cmp word [ball_x], 15
    jge check_p2_collision
    mov ax, [p1_y]
    sub ax, 4                   ; ball is 5px tall: overlap starts 4px above paddle
    cmp [ball_y], ax
    jl check_scores
    add ax, 44                  ; paddle bottom edge (p1_y + 40)
    cmp [ball_y], ax
    jg check_scores

    neg word [ball_vx]
    mov word [ball_x], 16
    call randomize_angle
    jmp game_loop

check_p2_collision:
    cmp word [ball_x], 300
    jle check_scores
    mov ax, [p2_y]
    sub ax, 4                   ; ball is 5px tall: overlap starts 4px above paddle
    cmp [ball_y], ax
    jl check_scores
    add ax, 44                  ; paddle bottom edge (p2_y + 40)
    cmp [ball_y], ax
    jg check_scores

    neg word [ball_vx]
    mov word [ball_x], 299
    call randomize_angle
    jmp game_loop

check_scores:
    mov ax, [ball_x]
    cmp ax, 2
    jg check_right_miss
    inc byte [p2_score]
    call reset_round
    jmp game_loop

check_right_miss:
    cmp ax, 315
    jl game_loop
    inc byte [p1_score]
    call reset_round
    jmp game_loop

reset_round:
    mov word [ball_x], 160
    mov word [ball_y], 100
    mov word [ball_vy], 0       ; serve sideways

    mov ax, [0x046C]            ; BIOS clock ticks (DS is already 0)
    and ax, 1
    jz .serve_left
    mov word [ball_vx], 3
    ret
.serve_left:
    mov word [ball_vx], -3
    ret

randomize_angle:
    mov ax, [0x046C]            ; BIOS clock ticks
    and ax, 3
    shl ax, 1
    sub ax, 3                   ; -3, -1, 1 or 3
    mov [ball_vy], ax
    ret

; --- SHARED MOVEMENT SUBROUTINE ---
move_paddle:
    mov bx, [si]
    add bx, ax
    jns .not_neg
    xor bx, bx                  ; clamp to top edge (y = 0)
.not_neg:
    cmp bx, 160
    jle .store
    mov bx, 160                 ; clamp to bottom edge (y + 40 = 200)
.store:
    mov [si], bx
    ret

; --- GAME OVER SCREEN ---
game_over_screen:
    mov ax, 0x0003
    int 10h

    mov ah, 02h
    xor bh, bh
    mov dh, 10
    mov dl, 35
    int 10h

    mov al, [p1_score]
    cmp al, '7'
    je .p1_text
    mov al, '2'
    jmp .print_winner
.p1_text:
    mov al, '1'
.print_winner:
    mov ah, 0Eh
    int 10h

    mov ah, 00h
    int 16h                     ; wait for key, then restart
    jmp reset_game

; --- RECTANGLE RENDERING SUBROUTINE ---
render_rect:
    mov ax, 320
    mul dx
    add ax, cx
    mov di, ax

    mov dl, bh
.loop_y:
    push di
    xor cx, cx
    mov cl, bl
    mov al, 0x0F
.draw_pixels:
    mov [es:di], al
    inc di
    loop .draw_pixels
    pop di
    add di, 320
    dec dl
    jnz .loop_y
    ret

; --- BOOT SECTOR PADDING + SIGNATURE ---
times 510-($-$$) db 0
dw 0xAA55

; --- VARIABLES (uninitialized RAM right after the boot sector) ---
absolute 0x7E00
p1_y       resw 1
p2_y       resw 1
ball_x     resw 1
ball_y     resw 1
ball_vx    resw 1
ball_vy    resw 1
p1_score   resb 1
p2_score   resb 1