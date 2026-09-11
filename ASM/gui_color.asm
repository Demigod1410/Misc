default rel
section .data
    window_title db "Assembly Color Grid", 0
section .bss
    display      resq 1
    window       resq 1
    gc           resq 1
    event        resb 96
section .text
    global main
    extern XOpenDisplay
    extern XDefaultScreen
    extern XDefaultRootWindow
    extern XCreateSimpleWindow
    extern XStoreName
    extern XSelectInput
    extern XMapWindow
    extern XCreateGC
    extern XSetForeground
    extern XDrawPoint
    extern XNextEvent
    extern exit
main:
    sub rsp, 8                 
    xor rdi, rdi
    call XOpenDisplay
    test rax, rax
    jz exit_program
    mov [display], rax
    mov rdi, rax
    call XDefaultScreen
    mov rdi, [display]
    mov rsi, rax
    call XDefaultRootWindow
    mov rdi, [display]         
    mov rsi, rax               
    xor rdx, rdx               
    xor rcx, rcx               
    mov r8, 400                
    mov r9, 400                
    sub rsp, 32                
    mov qword [rsp], 1         
    mov qword [rsp + 8], 0xFFFFFF  
    mov qword [rsp + 16], 0x000000 
    call XCreateSimpleWindow
    add rsp, 32                
    mov [window], rax
    mov rdi, [display]
    mov rsi, [window]
    lea rdx, [window_title]
    call XStoreName
    mov rdi, [display]
    mov rsi, [window]
    mov rdx, 32768             
    call XSelectInput
    mov rdi, [display]
    mov rsi, [window]
    call XMapWindow
    mov rdi, [display]
    mov rsi, [window]
    xor rdx, rdx
    xor rcx, rcx
    call XCreateGC
    mov [gc], rax
event_loop:
    mov rdi, [display]
    lea rsi, [event]
    call XNextEvent
    mov eax, [event]
    cmp eax, 12                
    jne event_loop
    xor r12, r12               
row_loop:
    xor r13, r13               
col_loop:
    cmp r12, 200
    jl top_half
bottom_half:
    cmp r13, 200
    jl set_green
set_white:
    mov rdx, 0xFFFFFF
    jmp apply_color
set_green:
    mov rdx, 0x00FF00
    jmp apply_color
top_half:
    cmp r13, 200
    jl set_red
set_blue:
    mov rdx, 0x0000FF
    jmp apply_color
set_red:
    mov rdx, 0xFF0000
apply_color:
    mov rdi, [display]
    mov rsi, [gc]
    call XSetForeground
    mov rdi, [display]
    mov rsi, [window]
    mov rdx, [gc]
    mov rcx, r13               
    mov r8, r12                
    call XDrawPoint
    inc r13
    cmp r13, 400
    jl col_loop
    inc r12
    cmp r12, 400
    jl row_loop
    jmp event_loop
exit_program:
    add rsp, 8                 
    xor rdi, rdi
    call exit
