org 0x7C00          ; BIOS loads bootloader here

section .text
start:
    ; Set up ES register to point directly to VGA Video Memory (0xA000)
    mov ax, 0xA000
    mov es, ax

reset_game:
    mov byte [p1_score], '0'
    mov byte [p2_score], '0'
    mov word [p1_y], 80
    mov word [p2_y], 80
    call reset_round

game_loop:
    ; 1. FRAME TIMING / DELAY (~60 FPS using BIOS wait)
    mov ah, 86h
    xor cx, cx       
    mov dx, 14000    
    int 15h

    ; 2. CHECK WIN STATE (Directly check if someone hit 7)
    cmp byte [p1_score], '7'
    je game_over_screen
    cmp byte [p2_score], '7'
    je game_over_screen

    ; 3. CLEAR SCREEN (Ultra-compact mode reset method)
    mov ax, 0x0013     
    int 10h         

    ; 4. DRAW ENTITIES
    ; Draw Player 1 (Left)
    mov cx, 5
    mov dx, [p1_y]
    mov bl, 10
    mov bh, 40
    call render_rect

    ; Draw Player 2 (Right)
    mov cx, 305
    mov dx, [p2_y]
    call render_rect

    ; Draw Ball
    mov cx, [ball_x]
    mov dx, [ball_y]
    mov bl, 5
    mov bh, 5
    call render_rect

    ; 5. PRINT SCORES (Using BIOS text Teletype mode)
    mov ah, 02h     ; Set cursor position
    xor bh, bh      ; Page 0
    mov dh, 1       ; Row 1
    mov dl, 12      ; Column 12
    int 10h
    mov al, [p1_score]
    mov ah, 0Eh     ; Print character
    int 10h

    mov ah, 02h     
    mov dl, 26      ; Column 26
    int 10h
    mov al, [p2_score]
    mov ah, 0Eh     
    int 10h

    ; 6. PROCESS INPUT (Non-blocking keyboard check)
    mov ah, 01h     
    int 16h
    jz move_ball    

    mov ah, 00h     
    int 16h         ; AH = Scan Code, AL = ASCII

    ; Player 1 Controls (W / S)
    cmp al, 'w'
    jne .check_s
    mov si, p1_y
    mov ax, -22     ; INCREASED PADDLE SPEED (from -8 to -22)
    call move_paddle
.check_s:
    cmp al, 's'
    jne .check_p2_up
    mov si, p1_y
    mov ax, 22      ; INCREASED PADDLE SPEED (from 8 to 22)
    call move_paddle

.check_p2_up:
    ; Player 2 Controls (Arrow Keys check AH Scan Code)
    cmp ah, 0x48    ; Arrow Up
    jne .check_p2_down
    mov si, p2_y
    mov ax, -22     ; INCREASED PADDLE SPEED (from -8 to -22)
    call move_paddle
.check_p2_down:
    cmp ah, 0x50    ; Arrow Down
    jne move_ball
    mov si, p2_y
    mov ax, 22      ; INCREASED PADDLE SPEED (from 8 to 22)
    call move_paddle

move_ball:
    ; 7. BALL PHYSICS
    mov ax, [ball_vx]
    add [ball_x], ax
    mov ax, [ball_vy]
    add [ball_y], ax

    ; Ceiling/Floor Collisions
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
    cmp [ball_y], ax
    jl check_scores             
    add ax, 40
    cmp [ball_y], ax
    jg check_scores             
    
    neg word [ball_vx]          
    mov word [ball_x], 16       ; Prevent ball getting stuck inside paddle
    call play_beep              
    jmp game_loop

check_p2_collision:
    cmp word [ball_x], 300      
    jle check_scores
    mov ax, [p2_y]
    cmp [ball_y], ax
    jl check_scores             
    add ax, 40
    cmp [ball_y], ax
    jg check_scores             

    neg word [ball_vx]          
    mov word [ball_x], 299      ; Prevent ball getting stuck inside paddle
    call play_beep              
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
    neg word [ball_vx]
    ret

; --- SHARED MOVEMENT SUBROUTINE ---
move_paddle:
    mov bx, [si]
    add bx, ax
    cmp bx, 5
    jl .done
    cmp bx, 155
    jg .done
    mov [si], bx
.done:
    ret

; --- GAME OVER SCREEN ---
game_over_screen:
    mov ax, 0x0003  ; Drop out to standard text mode for text writing
    int 10h

    mov ah, 02h     ; Position message
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
    int 10h         ; Prints '1' or '2' to show who won

    mov ah, 00h       
    int 16h         ; Wait for keypress to restart
    jmp reset_game    

; --- RECTANGLE RENDERING SUBROUTINE ---
render_rect:
    mov ax, 320
    mul dx          
    add ax, cx      
    mov di, ax      
    
    xor dx, dx
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

play_beep:
    mov al, 0xB6
    out 0x43, al          
    mov ax, 0x0633        
    out 0x42, al          
    mov al, ah
    out 0x42, al          
    in al, 0x61
    or al, 0x03           
    out 0x61, al
    
    mov cx, 0x5FFF        
.delay_beep:
    loop .delay_beep
    
    in al, 0x61
    and al, 0xFC          
    out 0x61, al
    ret

; --- VARIABLES ---
p1_y       dw 80
p2_y       dw 80
ball_x     dw 160
ball_y     dw 100
ball_vx    dw 3
ball_vy    dw 2
p1_score   db '0'
p2_score   db '0'

; --- BOOT SECTOR EMBED STRUCT ---
times 510-($-$$) db 0   
dw 0xAA55               
