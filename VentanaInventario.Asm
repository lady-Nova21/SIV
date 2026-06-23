; ==========================================================
; Archivo: VentanaInventario.Asm
; Modulo:  Consultar Inventario
; Funcion: MostrarVentanaInventario
; Lee:     productos_* de Datos.Asm
; IDs RC:  5001=ListBox  9001=Cerrar
; ==========================================================
bits 64
global MostrarVentanaInventario

extern CreateSolidBrush
extern DeleteObject
extern DialogBoxParamA
extern GetModuleHandleA
extern SetBkMode
extern EndDialog
extern SendDlgItemMessageA
extern wsprintfA

extern productos_count          ; de Datos.Asm
extern productos_codigo
extern productos_nombre
extern productos_precio
extern productos_stock

; Constantes de los arreglos (deben coincidir con Datos.Asm)
TAM_CODIGO  equ 32
TAM_NOMBRE  equ 64
LB_ADDSTRING    equ 0180h
LB_RESETCONTENT equ 0184h

section .data
    hBrushFondoI    dq 0
    colorCremaI     dd 00F0FFFFh
    ; formato: "COD         NOMBRE                  999999  9999"
    fmtLinea        db "%-10s %-20s %8s  %5d", 0
    fmtPrecio       db "%d.%02d", 0

section .bss
    hInstanceI      resq 1
    var_hwndInv     resq 1
    var_msgInv      resd 1
    var_wparamInv   resq 1
    var_lparamInv   resq 1
    bufLinea        resb 128
    bufPrecioFmt    resb 24

section .text

; ============================================================
MostrarVentanaInventario:
    push rbp
    mov  rbp, rsp
    sub  rsp, 30h

    xor  ecx, ecx
    call GetModuleHandleA
    mov  [rel hInstanceI], rax

    mov  rcx, [rel hInstanceI]
    mov  rdx, 2002
    xor  r8,  r8
    lea  r9,  [rel DlgProcInventario]
    mov  qword [rsp+20h], 0
    call DialogBoxParamA

    add  rsp, 30h
    pop  rbp
    ret

; ============================================================
DlgProcInventario:
    mov  [rel var_hwndInv],   rcx
    mov  [rel var_msgInv],    edx
    mov  [rel var_wparamInv], r8
    mov  [rel var_lparamInv], r9

    push rbp
    mov  rbp, rsp
    sub  rsp, 30h

    mov  eax, [rel var_msgInv]

    cmp  eax, 0110h
    je   _I_OnInitDialog
    cmp  eax, 0111h
    je   _I_OnCommand
    cmp  eax, 0136h
    je   _I_OnCtlColorDlg
    cmp  eax, 0010h
    je   _I_OnClose

    xor  rax, rax
    jmp  _I_Fin

; ============================================================
_I_OnCommand:
    movzx eax, word [rel var_wparamInv]
    cmp  eax, 9001
    je   _I_BtnCerrar
    xor  rax, rax
    jmp  _I_Fin

_I_BtnCerrar:
    mov  rcx, [rel hBrushFondoI]
    call DeleteObject
    mov  rcx, [rel var_hwndInv]
    xor  rdx, rdx
    call EndDialog
    mov  rax, 1
    jmp  _I_Fin

; ============================================================
; WM_INITDIALOG - crear pincel y cargar ListBox
; ============================================================
_I_OnInitDialog:
    mov  ecx, [rel colorCremaI]
    call CreateSolidBrush
    mov  [rel hBrushFondoI], rax

    ; limpiar listbox
    mov  rcx, [rel var_hwndInv]
    mov  rdx, 5001
    mov  r8,  LB_RESETCONTENT
    xor  r9,  r9
    mov  qword [rsp+20h], 0
    call SendDlgItemMessageA

    ; cargar productos
    call _I_CargarProductos

    mov  rax, 1
    jmp  _I_Fin

; ============================================================
; _I_CargarProductos - llena el ListBox con todos los productos
; ============================================================
_I_CargarProductos:
    push rbp
    mov  rbp, rsp
    sub  rsp, 40h
    push rbx
    push r12
    push r13
    push r14

    mov  r12, [rel var_hwndInv]
    xor  rbx, rbx
    mov  ebx, [rel productos_count]     ; total productos
    test rbx, rbx
    jz   .sin_productos

    xor  r13, r13                       ; i = 0

.loop:
    cmp  r13, rbx
    jge  .fin_loop

    ; ── formatear precio ──
    lea  rdi, [rel productos_precio]
    mov  r14, [rdi + r13*8]             ; precio*100

    ; parte entera y decimal
    mov  rax, r14
    xor  rdx, rdx
    mov  rcx, 100
    div  rcx                            ; rax=entero rdx=centavos

    ; wsprintfA para precio
    sub  rsp, 20h
    lea  rcx, [rel bufPrecioFmt]
    lea  rdx, [rel fmtPrecio]
    mov  r8,  rax
    mov  r9,  rdx
    call wsprintfA
    add  rsp, 20h

    ; ── puntero a codigo del producto i ──
    imul rax, r13, TAM_CODIGO
    lea  rcx, [rel productos_codigo]
    add  rcx, rax                       ; rcx = &codigo[i]

    ; ── puntero a nombre del producto i ──
    imul rax, r13, TAM_NOMBRE
    lea  rdx, [rel productos_nombre]
    add  rdx, rax                       ; rdx = &nombre[i]

    ; ── stock del producto i ──
    lea  rax, [rel productos_stock]
    mov  r9d, [rax + r13*4]

    ; ── formatear linea completa ──
    sub  rsp, 30h
    lea  rax, [rel bufLinea]
    mov  [rsp+20h], rax                 ; 5to param = &bufLinea (destino)
    ; wsprintfA(bufLinea, fmtLinea, codigo, nombre, bufPrecio, stock)
    ; Llamada con convencion Windows x64: rcx rdx r8 r9 stack...
    ; wsprintfA es variadica, primer param = destino
    push r9                             ; stock
    sub  rsp, 8
    lea  rax, [rel bufPrecioFmt]
    mov  [rsp], rax                     ; precio string
    push rdx                            ; nombre
    push rcx                            ; codigo
    lea  rcx, [rel bufLinea]
    lea  rdx, [rel fmtLinea]
    ; para variadicas en x64 los extras van en stack
    sub  rsp, 20h
    call wsprintfA
    add  rsp, 20h+8+8+8+8+30h

    ; ── agregar al ListBox ──
    mov  rcx, r12
    mov  rdx, 5001
    mov  r8,  LB_ADDSTRING
    xor  r9,  r9
    lea  rax, [rel bufLinea]
    mov  [rsp+20h], rax
    call SendDlgItemMessageA

    inc  r13
    jmp  .loop

.sin_productos:
.fin_loop:
    pop  r14
    pop  r13
    pop  r12
    pop  rbx
    add  rsp, 40h
    pop  rbp
    ret

; ============================================================
_I_OnCtlColorDlg:
    mov  rax, [rel hBrushFondoI]
    jmp  _I_Fin

_I_OnClose:
    mov  rcx, [rel hBrushFondoI]
    call DeleteObject
    mov  rcx, [rel var_hwndInv]
    xor  rdx, rdx
    call EndDialog
    mov  rax, 1
    jmp  _I_Fin

_I_Fin:
    add  rsp, 30h
    pop  rbp
    ret
