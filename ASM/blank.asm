extern GetStdHandle
extern GetConsoleScreenBufferInfo
extern FillConsoleOutputCharacterA
extern FillConsoleOutputAttribute
extern SetConsoleCursorPosition
extern ExitProcess

section .data
    stdout_handle dq 0
    chars_written dd 0
    cells_written dd 0
    cursor_pos    dd 0
        
section .bss
    buffer_info   resb 22  

section .text
    global main

main:
    sub rsp, 40                 
 
    mov rcx, -11               
    call GetStdHandle WRT ..plt
    lea rdx, [rel stdout_handle]
    mov [rdx], rax    
  
    lea rdx, [rel stdout_handle]
    mov rcx, [rdx]    
    lea rdx, [rel buffer_info]        
    call GetConsoleScreenBufferInfo WRT ..plt

    lea rdx, [rel buffer_info]
    movzx eax, word [rdx + 0]  
    movzx ecx, word [rdx + 2]  
    imul eax, ecx                      
    mov ebx, eax                       
   
    lea rax, [rel stdout_handle]
    mov rcx, [rax]    
    mov rdx, 32                 
    mov r8, rbx                 
    lea rax, [rel cursor_pos]
    mov r9, [rax]        
    
    lea rax, [rel chars_written]    
    mov [rsp + 32], rax         
    call FillConsoleOutputCharacterA WRT ..plt

    lea rax, [rel stdout_handle]
    mov rcx, [rax]    
    mov rdx, 0x0007             
    mov r8, rbx                 
    lea rax, [rel cursor_pos]
    mov r9, [rax]        
    
    lea rax, [rel cells_written]    
    mov [rsp + 32], rax        
    call FillConsoleOutputAttribute WRT ..plt

    lea rax, [rel stdout_handle]
    mov rcx, [rax]    
    lea rdx, [rel cursor_pos]
    mov rdx, [rdx]       
    call SetConsoleCursorPosition WRT ..plt

    xor ecx, ecx                
    call ExitProcess WRT ..plt

section .note.GNU-stack noalloc noexec alloc exec
