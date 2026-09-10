bits 64
default rel

extern GetModuleHandleA
extern RegisterClassExA
extern CreateWindowExA
extern ShowWindow
extern UpdateWindow
extern GetMessageA
extern TranslateMessage
extern DispatchMessageA
extern ExitProcess
extern DefWindowProcA
extern PostQuitMessage
extern LoadCursorA

CS_HREDRAW        equ 2
CS_VREDRAW        equ 1
IDC_ARROW         equ 32512
COLOR_WINDOW      equ 5
WS_OVERLAPPEDWINDOW equ 0x00CF0000
CW_USEDEFAULT     equ 0x80000000
SW_SHOW           equ 5
WM_DESTROY        equ 0x0002

WNDCLASSEX_size   equ 80

section .data
    className   db "AsmWindowClass", 0
    windowTitle db "Blank Screen Daksh", 0

section .bss
    msg         resb 48       
    wndClass    resb 80       

section .text
global main
main:
    push rbp
    mov rbp, rsp
    sub rsp, 112

    xor rcx, rcx
    call GetModuleHandleA
    mov r12, rax              

    mov dword [wndClass + 0], WNDCLASSEX_size
    mov dword [wndClass + 4], CS_HREDRAW | CS_VREDRAW
    lea rax, [WindowProc]
    mov qword [wndClass + 8], rax       
    mov dword [wndClass + 16], 0        
    mov dword [wndClass + 20], 0        
    mov qword [wndClass + 24], r12      
    mov qword [wndClass + 32], 0        
    
    xor rcx, rcx
    mov rdx, IDC_ARROW
    call LoadCursorA
    mov qword [wndClass + 40], rax        
    
    mov qword [wndClass + 48], COLOR_WINDOW 
    mov qword [wndClass + 56], 0        
    lea rax, [className]
    mov qword [wndClass + 64], rax      
    mov qword [wndClass + 72], 0        

    lea rcx, [wndClass]
    call RegisterClassExA
    test ax, ax
    jz exit_program

    mov qword [rsp + 88], 0             
    mov qword [rsp + 80], r12           
    mov qword [rsp + 72], 0             
    mov qword [rsp + 64], 0             
    mov dword [rsp + 56], CW_USEDEFAULT 
    mov dword [rsp + 48], CW_USEDEFAULT 
    mov dword [rsp + 40], CW_USEDEFAULT 
    mov dword [rsp + 32], CW_USEDEFAULT 

    xor ecx, ecx                          
    lea rdx, [className]                
    lea r8,  [windowTitle]              
    mov r9d, WS_OVERLAPPEDWINDOW        
    call CreateWindowExA
    
    test rax, rax
    jz exit_program
    mov r13, rax                        

    mov rcx, r13
    mov edx, SW_SHOW
    call ShowWindow

    mov rcx, r13
    call UpdateWindow

message_loop:
    lea rcx, [msg]
    xor rdx, rdx
    xor r8, r8
    xor r9, r9
    call GetMessageA
    cmp rax, 0
    jle exit_program                    

    lea rcx, [msg]
    call TranslateMessage

    lea rcx, [msg]
    call DispatchMessageA
    jmp message_loop

exit_program:
    xor rcx, rcx
    call ExitProcess


WindowProc:
    push rbp
    mov rbp, rsp
    sub rsp, 32                         
    
    cmp edx, WM_DESTROY
    je .on_destroy

    call DefWindowProcA
    leave
    ret

.on_destroy:
    xor rcx, rcx
    call PostQuitMessage
    xor rax, rax                        
    leave
    ret
