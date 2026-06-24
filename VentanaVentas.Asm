; ==========================================================
; Archivo: VentanaVentas.Asm
; Modulo:  Realizar Venta
; Funcion: MostrarVentanaVentas
; Persistencia: GuardarVentaTxt -> ventas.txt
; IDs RC:  3010=Codigo 3011=Cantidad 3012=Total
;          2001=Guardar 9001=Cerrar
; ==========================================================
bits 64
global MostrarVentanaVentas

extern CreateSolidBrush
extern DeleteObject
extern DialogBoxParamA
extern GetModuleHandleA
extern SetBkMode
extern EndDialog
extern GetDlgItemTextA
extern SetDlgItemTextA
extern MessageBoxA
extern GuardarVentaTxt          ; de Persistencia.Asm

section .data
    hBrushFondoV    dq 0
    colorCremaV     dd 00F0FFFFh
    msgExitoV        db "Venta guardada en ventas.txt", 0
    msgErrorV        db "Error: complete todos los campos.", 0
    tituloOKV        db "SIV - Venta", 0
    tituloErrV       db "SIV - Error", 0
    szVacioV         db "", 0

section .bss
    hInstanceV      resq 1
    var_hwndV       resq 1
    var_msgV        resd 1
    var_wparamV     resq 1
    var_lparamV     resq 1
    bufCodigoV       resb 32
    bufCantidad     resb 16
    bufTotal        resb 16

section .text

MostrarVentanaVentas:
    push rbp
    mov  rbp, rsp
    sub  rsp, 30h

    xor  ecx, ecx
    call GetModuleHandleA
    mov  [rel hInstanceV], rax

    mov  rcx, [rel hInstanceV]
    mov  rdx, 2001              ; ID dialogo Ventas en Recursos.Rc
    xor  r8,  r8
    lea  r9,  [rel DlgProcVentas]
    mov  qword [rsp+20h], 0
    call DialogBoxParamA

    add  rsp, 30h
    pop  rbp
    ret

; ============================================================
; DlgProcVentas
; ============================================================
DlgProcVentas:
    mov  [rel var_hwndV],   rcx
    mov  [rel var_msgV],    edx
    mov  [rel var_wparamV], r8
    mov  [rel var_lparamV], r9

    push rbp
    mov  rbp, rsp
    sub  rsp, 30h

    mov  eax, [rel var_msgV]

    cmp  eax, 0110h             ; WM_INITDIALOG
    je   _V_OnInitDialog
    cmp  eax, 0111h             ; WM_COMMAND
    je   _V_OnCommand
    cmp  eax, 0136h             ; WM_CTLCOLORDLG
    je   _V_OnCtlColorDlg
    cmp  eax, 0138h             ; WM_CTLCOLORSTATIC
    je   _V_OnCtlColorStatic
    cmp  eax, 0010h             ; WM_CLOSE
    je   _V_OnClose

    xor  rax, rax
    jmp  _V_FinProc

_V_OnCommand:
    movzx eax, word [rel var_wparamV]
    cmp  eax, 2001              ; Boton Guardar Venta
    je   _V_BtnGuardar
    cmp  eax, 9001              ; Boton Cerrar
    je   _V_BtnCerrar
    xor  rax, rax
    jmp  _V_FinProc

; ============================================================
; Boton Guardar - lee campos y llama GuardarVentaTxt
; ============================================================
_V_BtnGuardar:
    add  rsp, 30h
    pop  rbp
    push rbp
    mov  rbp, rsp
    sub  rsp, 50h
    push r14

    mov  r14, [rel var_hwndV]

    ; leer Codigo (ID 3010)
    mov  rcx, r14
    mov  rdx, 3010
    lea  r8,  [rel bufCodigoV]
    mov  r9,  32
    call GetDlgItemTextA
    test rax, rax
    jz   _V_ErrorCampos

    ; leer Cantidad (ID 3011)
    mov  rcx, r14
    mov  rdx, 3011
    lea  r8,  [rel bufCantidad]
    mov  r9,  16
    call GetDlgItemTextA
    test rax, rax
    jz   _V_ErrorCampos

    ; leer Total (ID 3012)
    mov  rcx, r14
    mov  rdx, 3012
    lea  r8,  [rel bufTotal]
    mov  r9,  16
    call GetDlgItemTextA
    test rax, rax
    jz   _V_ErrorCampos

    ; guardar en ventas.txt
    lea  rcx, [rel bufCodigoV]
    lea  rdx, [rel bufCantidad]
    lea  r8,  [rel bufTotal]
    call GuardarVentaTxt

    ; mostrar exito
    mov  rcx, r14
    lea  rdx, [rel msgExitoV]
    lea  r8,  [rel tituloOKV]
    mov  r9,  0
    call MessageBoxA

    ; limpiar campos
    mov  rcx, r14
    mov  rdx, 3010
    lea  r8,  [rel szVacioV]
    call SetDlgItemTextA
    mov  rcx, r14
    mov  rdx, 3011
    lea  r8,  [rel szVacioV]
    call SetDlgItemTextA
    mov  rcx, r14
    mov  rdx, 3012
    lea  r8,  [rel szVacioV]
    call SetDlgItemTextA

    pop  r14
    add  rsp, 50h
    pop  rbp
    xor  rax, rax
    ret

_V_ErrorCampos:
    mov  rcx, r14
    lea  rdx, [rel msgErrorV]
    lea  r8,  [rel tituloErrV]
    mov  r9,  0
    call MessageBoxA
    pop  r14
    add  rsp, 50h
    pop  rbp
    xor  rax, rax
    ret

_V_BtnCerrar:
    mov  rcx, [rel hBrushFondoV]
    call DeleteObject
    mov  rcx, [rel var_hwndV]
    xor  rdx, rdx
    call EndDialog
    mov  rax, 1
    jmp  _V_FinProc

_V_OnInitDialog:
    mov  ecx, [rel colorCremaV]
    call CreateSolidBrush
    mov  [rel hBrushFondoV], rax
    mov  rax, 1
    jmp  _V_FinProc

_V_OnCtlColorDlg:
    mov  rax, [rel hBrushFondoV]
    jmp  _V_FinProc

_V_OnCtlColorStatic:
    mov  rcx, [rel var_wparamV]
    mov  edx, 1
    call SetBkMode
    mov  rax, [rel hBrushFondoV]
    jmp  _V_FinProc

_V_OnClose:
    mov  rcx, [rel hBrushFondoV]
    call DeleteObject
    mov  rcx, [rel var_hwndV]
    xor  rdx, rdx
    call EndDialog
    mov  rax, 1
    jmp  _V_FinProc

_V_FinProc:
    add  rsp, 30h
    pop  rbp
    ret
