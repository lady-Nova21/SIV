; ==========================================================
; Archivo: VentanaProductos.Asm
; Modulo: Gestion de Productos
; Funcion exportada: MostrarVentanaProductos
; ==========================================================
bits 64
global MostrarVentanaProductos

extern CreateSolidBrush
extern DeleteObject
extern DialogBoxParamA
extern GetModuleHandleA
extern SetBkMode
extern EndDialog
extern GetDlgItemTextA
extern MessageBoxA
extern GuardarProductoTxt          ; de Persistencia.Asm

section .data
    hBrushFondoP    dq 0
    colorCremaP     dd 00F0FFFFh
    msgExito        db "Producto guardado con exito.", 0
    tituloMsg       db "SIV - Confirmacion", 0

section .bss
    hInstanceP      resq 1
    var_hwndP       resq 1
    var_msgP        resd 1
    var_wparamP     resq 1
    var_lparamP     resq 1
    codigoProd      resb 32
    nombreProd      resb 256
    precioProd      resb 32
    cantProd        resb 32

section .text

; ============================================================
; MostrarVentanaProductos
; Abre el dialogo de Gestion de Productos (ID 2004)
; rcx = hwnd padre
; ============================================================
MostrarVentanaProductos:
    push rbp
    mov rbp, rsp
    sub rsp, 30h

    xor ecx, ecx
    call GetModuleHandleA
    mov [rel hInstanceP], rax

    mov rcx, [rel hInstanceP]
    mov rdx, 2004               ; ID dialogo Productos en Recursos.Rc
    xor r8, r8
    lea r9, [rel DlgProcProductos]
    mov qword [rsp + 20h], 0
    call DialogBoxParamA

    add rsp, 30h
    pop rbp
    ret

; ============================================================
; DlgProcProductos
; rcx=hwnd  rdx=uMsg  r8=wParam  r9=lParam
; ============================================================
DlgProcProductos:
    mov [rel var_hwndP],   rcx
    mov [rel var_msgP],    edx
    mov [rel var_wparamP], r8
    mov [rel var_lparamP], r9

    push rbp
    mov rbp, rsp
    sub rsp, 30h

    mov eax, [rel var_msgP]

    cmp eax, 0110h              ; WM_INITDIALOG
    je  _P_OnInitDialog

    cmp eax, 0111h              ; WM_COMMAND
    je  _P_OnCommand

    cmp eax, 0136h              ; WM_CTLCOLORDLG
    je  _P_OnCtlColorDlg

    cmp eax, 0138h              ; WM_CTLCOLORSTATIC
    je  _P_OnCtlColorStatic

    cmp eax, 0010h              ; WM_CLOSE
    je  _P_OnClose

    xor rax, rax
    jmp _P_Fin

; ============================================================
; WM_COMMAND - detectar boton presionado
; ============================================================
_P_OnCommand:
    movzx eax, word [rel var_wparamP]

    cmp eax, 4001               ; Boton "Guardar"
    je  _P_BtnGuardar

    cmp eax, 9001               ; Boton "Cerrar"
    je  _P_BtnCerrar

    xor rax, rax
    jmp _P_Fin

; ============================================================
; Boton Guardar - extrae los 4 campos y llama a GuardarProductoTxt
; ============================================================
_P_BtnGuardar:
    add rsp, 30h
    pop rbp
    push rbp
    mov rbp, rsp
    sub rsp, 40h
    push r14

    mov r14, [rel var_hwndP]    ; HWND de la ventana

    ; Extraer Codigo (ID 3004)
    mov rcx, r14
    mov rdx, 3004
    lea r8, [rel codigoProd]
    mov r9, 32
    call GetDlgItemTextA

    ; Extraer Nombre (ID 3001)
    mov rcx, r14
    mov rdx, 3001
    lea r8, [rel nombreProd]
    mov r9, 256
    call GetDlgItemTextA

    ; Extraer Precio (ID 3002)
    mov rcx, r14
    mov rdx, 3002
    lea r8, [rel precioProd]
    mov r9, 32
    call GetDlgItemTextA

    ; Extraer Cantidad (ID 3003)
    mov rcx, r14
    mov rdx, 3003
    lea r8, [rel cantProd]
    mov r9, 32
    call GetDlgItemTextA

    ; ---- Guardar usando el modulo compartido Persistencia.Asm ----
    lea rcx, [rel codigoProd]
    lea rdx, [rel nombreProd]
    lea r8,  [rel precioProd]
    lea r9,  [rel cantProd]
    call GuardarProductoTxt

    ; Mostrar mensaje de exito
    mov rcx, r14
    lea rdx, [rel msgExito]
    lea r8,  [rel tituloMsg]
    mov r9,  0                  ; MB_OK
    call MessageBoxA

    pop r14
    add rsp, 40h
    pop rbp
    xor rax, rax
    ret

_P_BtnCerrar:
    mov rcx, [rel hBrushFondoP]
    call DeleteObject
    mov rcx, [rel var_hwndP]
    xor rdx, rdx
    call EndDialog
    mov rax, 1
    jmp _P_Fin

; ============================================================
; WM_INITDIALOG - crear pincel de fondo
; ============================================================
_P_OnInitDialog:
    mov ecx, [rel colorCremaP]
    call CreateSolidBrush
    mov [rel hBrushFondoP], rax
    mov rax, 1
    jmp _P_Fin

_P_OnCtlColorDlg:
    mov rax, [rel hBrushFondoP]
    jmp _P_Fin

_P_OnCtlColorStatic:
    mov rcx, [rel var_wparamP]
    mov edx, 1
    call SetBkMode
    mov rax, [rel hBrushFondoP]
    jmp _P_Fin

_P_OnClose:
    mov rcx, [rel hBrushFondoP]
    call DeleteObject
    mov rcx, [rel var_hwndP]
    xor rdx, rdx
    call EndDialog
    mov rax, 1
    jmp _P_Fin

_P_Fin:
    add rsp, 30h
    pop rbp
    ret
