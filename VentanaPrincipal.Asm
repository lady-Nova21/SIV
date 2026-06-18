bits 64
global Start
extern CreateSolidBrush, DeleteObject, CreateDialogParamA, GetMessageA
extern TranslateMessage, DispatchMessageA, ExitProcess, EndDialog
extern GetModuleHandleA, SetBkMode, LoadIconA, SendMessageA
extern RegistrarProducto ; <--- AÑADIDO

; ... (sección data y bss igual que antes) ...

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
    cmp eax, 0111h      ; <--- AÑADIDO: WM_COMMAND
    je _OnCommand
    cmp eax, 0136h
    je _OnCtlColorDlg
    ; ... resto de comparaciones ...
    xor rax, rax
    jmp _FinProc

_OnCommand:
    cmp r8d, 1004       ; <--- AÑADIDO: ¿Es el botón 1004?
    je .llamar_registro
    jmp _FinProc
.llamar_registro:
    mov rcx, [rel var_hwnd]
    call RegistrarProducto
    jmp _FinProc

; ... resto del archivo igual ...
