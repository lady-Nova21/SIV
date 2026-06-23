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

; --- DLGPROC PRINCIPAL ---
DlgProc:
    mov [rel var_hwnd], rcx
    mov [rel var_msg], edx
    mov [rel var_wparam], r8
    mov [rel var_lparam], r9

    push rbp
    mov rbp, rsp
    sub rsp, 30h                

    mov eax, [rel var_msg]
    cmp eax, 0110h
    je _OnInitDialog
    cmp eax, 0111h
    je _OnCommand
    cmp eax, 0136h
    je _OnCtlColorDlg
    cmp eax, 0010h
    je _OnClose
    
    xor rax, rax                
    jmp _FinProc

_OnCommand:
    mov rax, [rel var_wparam]
    cmp ax, 1001
    je .abrir_registro
    jmp _FinProc
.abrir_registro:
    mov rcx, [rel hInstance]
    mov rdx, 2000
    mov r8, [rel var_hwnd]
    lea r9, [rel DlgProcRegistro]
    call CreateDialogParamA
    jmp _FinProc

; --- DLGPROC REGISTRO (Corregido: Usa el RCX local) ---
DlgProcRegistro:
    push rbp
    mov rbp, rsp
    sub rsp, 30h
    
    cmp edx, 0111h      ; WM_COMMAND
    je .comando_registro
    cmp edx, 0010h      ; WM_CLOSE
    je .cerrar_registro
    
    xor rax, rax
    jmp .fin_ret
.comando_registro:
    cmp r8w, 1004
    je .llamar_guardar
    jmp .fin_ret
.llamar_guardar:
    ; RCX ya contiene el HWND de esta ventana secundaria
    call RegistrarProducto
    mov rax, 1
    jmp .fin_ret
.cerrar_registro:
    ; RCX ya contiene el HWND de esta ventana secundaria
    call EndDialog
    mov rax, 1
.fin_ret:
    add rsp, 30h
    pop rbp
    ret

_OnInitDialog:
    mov rax, 1
    jmp _FinProc

_OnCtlColorDlg:
    mov rax, [rel hBrushFondo]   
    jmp _FinProc

_OnClose:
    mov rcx, [rel var_hwnd]
    call EndDialog
    xor ecx, ecx
    call ExitProcess

_FinProc:
    add rsp, 30h
    pop rbp
    ret
