bits 64

global Start

extern CreateSolidBrush
extern DeleteObject
extern CreateDialogParamA
extern GetMessageA
extern TranslateMessage
extern DispatchMessageA
extern ExitProcess
extern EndDialog
extern GetModuleHandleA
extern SetBkMode  
extern LoadIconA       ; Sirve para buscar un icono en la memoria 
extern SendMessageA    ; Envia la orden a la ventana de manera inmediata

section .data
    hBrushFondo   dq 0          
    colorCrema    dd 00F0FFFFh  ; Color Crema (#FFFFF0) en BGR

section .bss
    hInstance     resq 1
    hWndDlg       resq 1
    msg           resb 48       
    
    var_hwnd      resq 1
    var_msg       resd 1
    var_wparam    resq 1
    var_lparam    resq 1

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
    cmp eax, 0136h              ; WM_CTLCOLORDLG
    je _OnCtlColorDlg
    cmp eax, 0138h              ; WM_CTLCOLORSTATIC
    je _OnCtlColorStatic
    cmp eax, 0010h              ; WM_CLOSE
    je _OnClose
    
    xor rax, rax                
    jmp _FinProc

_OnInitDialog:
    ; 1. CARGAR EL ICONO DEL RECURSO (ID 200)
    mov rcx, [rel hInstance]
    mov rdx, 200                
    call LoadIconA
    mov r15, rax                ; Guardamos temporalmente el puntero del icono en r15

    ; 2. ASIGNAR ICONO PEQUEÑO (Para la barra de título de la ventana)
    mov rcx, [rel var_hwnd]     
    mov edx, 0080h              ; WM_SETICON
    mov r8, 0                   ; ICON_SMALL (0)
    mov r9, r15                 
    call SendMessageA

    ; 3. ASIGNAR ICONO GRANDE (Para la barra de tareas / Alt+Tab)
    mov rcx, [rel var_hwnd]     
    mov edx, 0080h              ; WM_SETICON
    mov r8, 1                   ; ICON_BIG (1)
    mov r9, r15                 
    call SendMessageA

    ; 4. CONFIGURAR EL FONDO CREMA
    mov ecx, [rel colorCrema]        
    call CreateSolidBrush
    mov [rel hBrushFondo], rax  
    mov rax, 1                  
    jmp _FinProc

_OnCtlColorDlg:
    mov rax, [rel hBrushFondo]   
    jmp _FinProc

_OnCtlColorStatic:
    mov rcx, [rel var_wparam]                 
    mov edx, 1                  ; BKMODE_TRANSPARENT
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