bits 64
global Start

extern MostrarVentanaVentas
extern MostrarVentanaInventario
extern MostrarVentanaReportes
extern MostrarVentanaProductos

extern CreateSolidBrush
extern DeleteObject
extern DialogBoxParamA
extern ExitProcess
extern EndDialog
extern GetModuleHandleA
extern SetBkMode
extern LoadIconA
extern SendMessageA

section .data
    hBrushFondo     dq 0
    colorCrema      dd 00F0FFFFh

section .bss
    hInstance       resq 1
    var_hwnd        resq 1
    var_msg         resd 1
    var_wparam      resq 1
    var_lparam      resq 1

section .text

Start:
    sub rsp, 28h

    xor ecx, ecx
    call GetModuleHandleA
    mov [rel hInstance], rax

    ; DialogBoxParamA es modal y maneja su propio loop de mensajes
    mov rcx, [rel hInstance]
    mov rdx, 1000               ; ID del dialogo
    xor r8, r8                  ; hwnd padre = NULL
    lea r9, [rel DlgProc]
    mov qword [rsp + 20h], 0
    call DialogBoxParamA

    xor ecx, ecx
    call ExitProcess

; ============================================================
; DlgProc  rcx=hwnd  rdx=uMsg  r8=wParam  r9=lParam
; ============================================================
DlgProc:
    mov [rel var_hwnd],   rcx
    mov [rel var_msg],    edx
    mov [rel var_wparam], r8
    mov [rel var_lparam], r9

    push rbp
    mov rbp, rsp
    sub rsp, 30h

    mov eax, [rel var_msg]

    cmp eax, 0110h              ; WM_INITDIALOG
    je  _OnInitDialog

    cmp eax, 0111h              ; WM_COMMAND
    je  _OnCommand

    cmp eax, 0136h              ; WM_CTLCOLORDLG
    je  _OnCtlColorDlg

    cmp eax, 0138h              ; WM_CTLCOLORSTATIC
    je  _OnCtlColorStatic

    cmp eax, 0010h              ; WM_CLOSE
    je  _OnClose

    xor rax, rax
    jmp _FinProc

; ============================================================
; WM_COMMAND
; ============================================================
_OnCommand:
    movzx eax, word [rel var_wparam]

    cmp eax, 1001
    je  _Btn_Productos

    cmp eax, 1002
    je  _Btn_Ventas

    cmp eax, 1003
    je  _Btn_Inventario

    cmp eax, 1005
    je  _Btn_Reportes

    xor rax, rax
    jmp _FinProc

_Btn_Ventas:
    add rsp, 30h
    pop rbp
    sub rsp, 28h
    mov rcx, [rel var_hwnd]
    call MostrarVentanaVentas
    add rsp, 28h
    xor rax, rax
    ret

_Btn_Productos:
    add rsp, 30h
    pop rbp
    sub rsp, 28h
    mov rcx, [rel var_hwnd]
    call MostrarVentanaProductos
    add rsp, 28h
    xor rax, rax
    ret

_Btn_Inventario:
    add rsp, 30h
    pop rbp
    sub rsp, 28h
    mov rcx, [rel var_hwnd]
    call MostrarVentanaInventario
    add rsp, 28h
    xor rax, rax
    ret

_Btn_Reportes:
    add rsp, 30h
    pop rbp
    sub rsp, 28h
    mov rcx, [rel var_hwnd]
    call MostrarVentanaReportes
    add rsp, 28h
    xor rax, rax
    ret

; ============================================================
; WM_INITDIALOG
; ============================================================
_OnInitDialog:
    mov rcx, [rel hInstance]
    mov rdx, 200
    call LoadIconA
    mov r15, rax

    mov rcx, [rel var_hwnd]
    mov edx, 0080h
    mov r8,  0
    mov r9,  r15
    call SendMessageA

    mov rcx, [rel var_hwnd]
    mov edx, 0080h
    mov r8,  1
    mov r9,  r15
    call SendMessageA

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
