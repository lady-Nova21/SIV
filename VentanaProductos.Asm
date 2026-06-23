; ==========================================================
; Archivo: VentanaProductos.Asm
; Modulo:  Gestion de Productos
; Funcion: MostrarVentanaProductos
; Usa:     AgregarProducto de Datos.Asm
; IDs RC:  3001=Codigo 3002=Nombre 3003=Precio 3004=Stock
;          4001=Guardar 9001=Cerrar
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
extern SetDlgItemTextA
extern MessageBoxA

extern AgregarProducto          ; de Datos.Asm

section .data
    hBrushFondoP    dq 0
    colorCremaP     dd 00F0FFFFh

    msgExito        db "Producto guardado correctamente.", 0
    msgError        db "Error: complete todos los campos.", 0
    msgTablaLlena   db "Error: tabla de productos llena.", 0
    tituloOK        db "SIV - Guardado", 0
    tituloErr       db "SIV - Error", 0

    szVacio         db "", 0

section .bss
    hInstanceP      resq 1
    var_hwndP       resq 1
    var_msgP        resd 1
    var_wparamP     resq 1
    var_lparamP     resq 1

    bufCodigo       resb 32
    bufNombre       resb 64
    bufPrecio       resb 16
    bufStock        resb 16

section .text

; ============================================================
MostrarVentanaProductos:
    push rbp
    mov  rbp, rsp
    sub  rsp, 30h

    xor  ecx, ecx
    call GetModuleHandleA
    mov  [rel hInstanceP], rax

    mov  rcx, [rel hInstanceP]
    mov  rdx, 2004
    xor  r8,  r8
    lea  r9,  [rel DlgProcProductos]
    mov  qword [rsp+20h], 0
    call DialogBoxParamA

    add  rsp, 30h
    pop  rbp
    ret

; ============================================================
; DlgProcProductos
; ============================================================
DlgProcProductos:
    mov  [rel var_hwndP],   rcx
    mov  [rel var_msgP],    edx
    mov  [rel var_wparamP], r8
    mov  [rel var_lparamP], r9

    push rbp
    mov  rbp, rsp
    sub  rsp, 30h

    mov  eax, [rel var_msgP]

    cmp  eax, 0110h             ; WM_INITDIALOG
    je   _P_OnInitDialog
    cmp  eax, 0111h             ; WM_COMMAND
    je   _P_OnCommand
    cmp  eax, 0136h             ; WM_CTLCOLORDLG
    je   _P_OnCtlColorDlg
    cmp  eax, 0138h             ; WM_CTLCOLORSTATIC
    je   _P_OnCtlColorStatic
    cmp  eax, 0010h             ; WM_CLOSE
    je   _P_OnClose

    xor  rax, rax
    jmp  _P_Fin

; ============================================================
_P_OnCommand:
    movzx eax, word [rel var_wparamP]
    cmp  eax, 4001
    je   _P_BtnGuardar
    cmp  eax, 9001
    je   _P_BtnCerrar
    xor  rax, rax
    jmp  _P_Fin

; ============================================================
; Boton Guardar
; ============================================================
_P_BtnGuardar:
    add  rsp, 30h
    pop  rbp
    push rbp
    mov  rbp, rsp
    sub  rsp, 50h
    push r14
    push r15

    mov  r14, [rel var_hwndP]

    ; ── leer Codigo (ID 3001) ──
    mov  rcx, r14
    mov  rdx, 3001
    lea  r8,  [rel bufCodigo]
    mov  r9,  32
    call GetDlgItemTextA
    test rax, rax
    jz   _P_ErrorCampos

    ; ── leer Nombre (ID 3002) ──
    mov  rcx, r14
    mov  rdx, 3002
    lea  r8,  [rel bufNombre]
    mov  r9,  64
    call GetDlgItemTextA
    test rax, rax
    jz   _P_ErrorCampos

    ; ── leer Precio (ID 3003) ──
    mov  rcx, r14
    mov  rdx, 3003
    lea  r8,  [rel bufPrecio]
    mov  r9,  16
    call GetDlgItemTextA
    test rax, rax
    jz   _P_ErrorCampos

    ; ── leer Stock (ID 3004) ──
    mov  rcx, r14
    mov  rdx, 3004
    lea  r8,  [rel bufStock]
    mov  r9,  16
    call GetDlgItemTextA
    test rax, rax
    jz   _P_ErrorCampos

    ; ── convertir precio a entero*100 ──
    lea  rcx, [rel bufPrecio]
    call _PrecioToInt       ; rax = precio*100

    mov  r15, rax           ; guardar precio convertido

    ; ── convertir stock a entero ──
    lea  rcx, [rel bufStock]
    call _AtoI              ; rax = stock

    ; ── llamar AgregarProducto ──
    lea  rcx, [rel bufCodigo]
    lea  rdx, [rel bufNombre]
    mov  r8,  r15
    mov  r9d, eax
    call AgregarProducto

    cmp  rax, -1
    je   _P_ErrorTabla

    ; ── mostrar exito y limpiar campos ──
    mov  rcx, r14
    lea  rdx, [rel msgExito]
    lea  r8,  [rel tituloOK]
    mov  r9,  0
    call MessageBoxA

    ; limpiar los 4 campos
    mov  rcx, r14
    mov  rdx, 3001
    lea  r8,  [rel szVacio]
    call SetDlgItemTextA
    mov  rcx, r14
    mov  rdx, 3002
    lea  r8,  [rel szVacio]
    call SetDlgItemTextA
    mov  rcx, r14
    mov  rdx, 3003
    lea  r8,  [rel szVacio]
    call SetDlgItemTextA
    mov  rcx, r14
    mov  rdx, 3004
    lea  r8,  [rel szVacio]
    call SetDlgItemTextA

    pop  r15
    pop  r14
    add  rsp, 50h
    pop  rbp
    xor  rax, rax
    ret

_P_ErrorCampos:
    mov  rcx, r14
    lea  rdx, [rel msgError]
    lea  r8,  [rel tituloErr]
    mov  r9,  0
    call MessageBoxA
    pop  r15
    pop  r14
    add  rsp, 50h
    pop  rbp
    xor  rax, rax
    ret

_P_ErrorTabla:
    mov  rcx, r14
    lea  rdx, [rel msgTablaLlena]
    lea  r8,  [rel tituloErr]
    mov  r9,  0
    call MessageBoxA
    pop  r15
    pop  r14
    add  rsp, 50h
    pop  rbp
    xor  rax, rax
    ret

; ============================================================
_P_BtnCerrar:
    mov  rcx, [rel hBrushFondoP]
    call DeleteObject
    mov  rcx, [rel var_hwndP]
    xor  rdx, rdx
    call EndDialog
    mov  rax, 1
    jmp  _P_Fin

_P_OnInitDialog:
    mov  ecx, [rel colorCremaP]
    call CreateSolidBrush
    mov  [rel hBrushFondoP], rax
    mov  rax, 1
    jmp  _P_Fin

_P_OnCtlColorDlg:
    mov  rax, [rel hBrushFondoP]
    jmp  _P_Fin

_P_OnCtlColorStatic:
    mov  rcx, [rel var_wparamP]
    mov  edx, 1
    call SetBkMode
    mov  rax, [rel hBrushFondoP]
    jmp  _P_Fin

_P_OnClose:
    mov  rcx, [rel hBrushFondoP]
    call DeleteObject
    mov  rcx, [rel var_hwndP]
    xor  rdx, rdx
    call EndDialog
    mov  rax, 1
    jmp  _P_Fin

_P_Fin:
    add  rsp, 30h
    pop  rbp
    ret

; ============================================================
; _PrecioToInt  rcx=string "20.50"  rax=2050
; Convierte string de precio con punto decimal a entero*100
; ============================================================
_PrecioToInt:
    push rbx
    push rsi
    mov  rsi, rcx
    xor  rax, rax
    xor  rbx, rbx       ; decimales contados

.parte_entera:
    movzx ecx, byte [rsi]
    test  ecx, ecx
    jz    .rellenar
    cmp   ecx, '.'
    je    .parte_decimal
    sub   ecx, '0'
    imul  rax, 10
    add   rax, rcx
    inc   rsi
    jmp   .parte_entera

.parte_decimal:
    inc   rsi           ; saltar el punto
.dec_loop:
    cmp   rbx, 2
    jge   .fin_precio
    movzx ecx, byte [rsi]
    test  ecx, ecx
    jz    .rellenar
    sub   ecx, '0'
    imul  rax, 10
    add   rax, rcx
    inc   rsi
    inc   rbx
    jmp   .dec_loop

.rellenar:
    ; si solo habia 1 decimal, multiplicar x10; si 0 decimales x100
    cmp   rbx, 0
    je    .mul100
    cmp   rbx, 1
    je    .mul10
    jmp   .fin_precio
.mul100:
    imul  rax, 100
    jmp   .fin_precio
.mul10:
    imul  rax, 10

.fin_precio:
    pop   rsi
    pop   rbx
    ret

; ============================================================
; _AtoI  rcx=string  rax=entero
; ============================================================
_AtoI:
    push rsi
    mov  rsi, rcx
    xor  rax, rax
.atoi_loop:
    movzx ecx, byte [rsi]
    test  ecx, ecx
    jz    .atoi_fin
    sub   ecx, '0'
    imul  rax, 10
    add   rax, rcx
    inc   rsi
    jmp   .atoi_loop
.atoi_fin:
    pop  rsi
    ret
