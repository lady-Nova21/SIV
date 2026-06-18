bits 64
global Start

extern CreateSolidBrush, DeleteObject, CreateDialogParamA, GetMessageA
extern TranslateMessage, DispatchMessageA, ExitProcess, EndDialog
extern GetModuleHandleA, SetBkMode, LoadIconA, SendMessageA, RegistrarProducto

section .data
    hBrushFondo    dq 0            
    colorCrema     dd 00F0FFFFh  

section .bss
    hInstance      resq 1
    hWndDlg        resq 1
    msg            resb 48       
    var_hwnd       resq 1
    var_msg        resd 1
    var_wparam     resq 1
    var_lparam     resq 1

section .text
Start:
    sub rsp, 28h
    xor ecx, ecx
    call GetModuleHandleA
    mov [rel hInstance], rax
    mov rcx, [rel hInstance]    
    mov rdx, 1000               
    xor r8, r8                  
    lea r9, [rel DlgProc]       
    mov qword [rsp + 20h], 0    
    call CreateDialogParamA
    mov [rel hWndDlg], rax

_LoopMensajes:
    lea rcx, [rel msg]
    xor rdx, rdx
    xor r8, r8
    xor r9, r9
    call GetMessageA
    test rax, rax
    jz _Salir
    lea rcx, [rel msg]
    call TranslateMessage
    lea rcx, [rel msg]
    call DispatchMessageA
    jmp _LoopMensajes

_Salir:
    xor ecx, ecx
    call ExitProcess

DlgProc:
    mov [rel var_hwnd], rcx
    mov [rel var_msg], edx
    mov [rel var_wparam], r8
    mov [rel var_lparam], r9

    push rbp
    mov rbp, rsp
    sub rsp, 30h                

    mov eax, [rel var_msg]
    cmp eax, 0110h              ; WM_INITDIALOG
    je _OnInitDialog
    cmp eax, 0111h              ; WM_COMMAND
    je _OnCommand
    cmp eax, 0136h              ; WM_CTLCOLORDLG
    je _OnCtlColorDlg
    cmp eax, 0138h              ; WM_CTLCOLORSTATIC
    je _OnCtlColorStatic
    cmp eax, 0010h              ; WM_CLOSE
    je _OnClose
    
    xor rax, rax                
    jmp _FinProc

_OnInitDialog:
    mov rcx, [rel hInstance]
    mov rdx, 200                
    call LoadIconA
    mov r15, rax
    mov rcx, [rel var_hwnd]     
    mov edx, 0080h              
    mov r8, 0                   
    mov r9, r15                 
    call SendMessageA
    mov rcx, [rel var_hwnd]     
    mov edx, 0080h              
    mov r8, 1                   
    mov r9, r15                 
    call SendMessageA
    mov ecx, [rel colorCrema]         
    call CreateSolidBrush
    mov [rel hBrushFondo], rax  
    mov rax, 1                  
    jmp _FinProc

_OnCommand:
    cmp r8d, 1004               ; ID del botón Guardar
    je .llamar_registro
    jmp _FinProc
.llamar_registro:
    mov rcx, [rel var_hwnd]
    call RegistrarProducto
    jmp _FinProc

_OnCtlColorDlg:
    mov rax, [rel hBrushFondo]   
    jmp _FinProc

_OnCtlColorStatic:
    mov rcx, [rel var_wparam]              
    mov edx, 1                  
    call SetBkMode              
    mov rax, [rel hBrushFondo]  
    jmp _FinProc

_OnClose:
    mov rcx, [rel hBrushFondo]
    call DeleteObject
    mov rcx, [rel var_hwnd]
    xor rdx, rdx
    call EndDialog
    xor ecx, ecx
    call ExitProcess

_FinProc:
    add rsp, 30h
    pop rbp
    ret
