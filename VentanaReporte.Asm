; ==========================================================
; Archivo: VentanaReporte.Asm
; Modulo:  Reportes de Ventas
; Funcion: MostrarVentanaReportes
; Lee:     ventas_* de Datos.Asm
; IDs RC:  6001=ListBox  7002=LabelTotalGeneral  9001=Cerrar
; ==========================================================
bits 64
global MostrarVentanaReportes

extern CreateSolidBrush
extern DeleteObject
extern DialogBoxParamA
extern GetModuleHandleA
extern SetBkMode
extern EndDialog
extern SendDlgItemMessageA
extern SetDlgItemTextA
extern wsprintfA

extern ventas_count
extern ventas_codigo
extern ventas_cantidad
extern ventas_total
extern GetTotalVentas

TAM_CODIGO  equ 32
LB_ADDSTRING    equ 0180h
LB_RESETCONTENT equ 0184h

section .data
    hBrushFondoR    dq 0
    colorCremaR     dd 00F0FFFFh
    fmtLinea        db "%-10s  x%-5d   Bs. %d.%02d", 0
    fmtTotal        db "Total General: Bs. %d.%02d", 0

section .bss
    hInstanceR      resq 1
    var_hwndRep     resq 1
    var_msgRep      resd 1
    var_wparamRep   resq 1
    var_lparamRep   resq 1
    bufLinea        resb 128
    bufTotal        resb 32

section .text

; ============================================================
MostrarVentanaReportes:
    push rbp
    mov  rbp, rsp
    sub  rsp, 30h

    xor  ecx, ecx
    call GetModuleHandleA
    mov  [rel hInstanceR], rax

    mov  rcx, [rel hInstanceR]
    mov  rdx, 2003
    xor  r8,  r8
    lea  r9,  [rel DlgProcReportes]
    mov  qword [rsp+20h], 0
    call DialogBoxParamA

    add  rsp, 30h
    pop  rbp
    ret

; ============================================================
DlgProcReportes:
    mov  [rel var_hwndRep],   rcx
    mov  [rel var_msgRep],    edx
    mov  [rel var_wparamRep], r8
    mov  [rel var_lparamRep], r9

    push rbp
    mov  rbp, rsp
    sub  rsp, 30h

    mov  eax, [rel var_msgRep]

    cmp  eax, 0110h
    je   _R_OnInitDialog
    cmp  eax, 0111h
    je   _R_OnCommand
    cmp  eax, 0136h
    je   _R_OnCtlColorDlg
    cmp  eax, 0010h
    je   _R_OnClose

    xor  rax, rax
    jmp  _R_Fin

; ============================================================
_R_OnCommand:
    movzx eax, word [rel var_wparamRep]
    cmp  eax, 9001
    je   _R_BtnCerrar
    xor  rax, rax
    jmp  _R_Fin

_R_BtnCerrar:
    mov  rcx, [rel hBrushFondoR]
    call DeleteObject
    mov  rcx, [rel var_hwndRep]
    xor  rdx, rdx
    call EndDialog
    mov  rax, 1
    jmp  _R_Fin

; ============================================================
; WM_INITDIALOG - cargar ventas en ListBox
; ============================================================
_R_OnInitDialog:
    mov  ecx, [rel colorCremaR]
    call CreateSolidBrush
    mov  [rel hBrushFondoR], rax

    ; limpiar listbox
    mov  rcx, [rel var_hwndRep]
    mov  rdx, 6001
    mov  r8,  LB_RESETCONTENT
    xor  r9,  r9
    mov  qword [rsp+20h], 0
    call SendDlgItemMessageA

    call _R_CargarVentas

    mov  rax, 1
    jmp  _R_Fin

; ============================================================
; _R_CargarVentas - llena ListBox con todas las ventas
; ============================================================
_R_CargarVentas:
    push rbp
    mov  rbp, rsp
    sub  rsp, 40h
    push rbx
    push r12
    push r13

    mov  r12, [rel var_hwndRep]
    mov  ebx, [rel ventas_count]
    test rbx, rbx
    jz   .sin_ventas

    xor  r13, r13               ; i = 0

.loop:
    cmp  r13, rbx
    jge  .fin_loop

    ; puntero al codigo de la venta i
    imul rax, r13, TAM_CODIGO
    lea  rcx, [rel ventas_codigo]
    add  rcx, rax               ; rcx = codigo

    ; cantidad
    lea  rdi, [rel ventas_cantidad]
    mov  r8d, [rdi + r13*4]     ; r8 = cantidad

    ; total de la venta i
    lea  rdi, [rel ventas_total]
    mov  rax, [rdi + r13*8]
    xor  rdx, rdx
    push rcx
    mov  rcx, 100
    div  rcx                    ; rax=entero rdx=centavos
    pop  rcx

    ; wsprintfA(bufLinea, fmtLinea, codigo, cantidad, total_ent, total_cen)
    push rdx                    ; centavos
    push rax                    ; entero
    push r8                     ; cantidad
    push rcx                    ; codigo
    lea  rcx, [rel bufLinea]
    lea  rdx, [rel fmtLinea]
    sub  rsp, 20h
    call wsprintfA
    add  rsp, 20h + 4*8

    ; agregar al ListBox
    mov  rcx, r12
    mov  rdx, 6001
    mov  r8,  LB_ADDSTRING
    xor  r9,  r9
    lea  rax, [rel bufLinea]
    mov  [rsp+20h], rax
    call SendDlgItemMessageA

    inc  r13
    jmp  .loop

.sin_ventas:
.fin_loop:
    ; ── actualizar label total general ──
    call GetTotalVentas         ; rax = total*100
    xor  rdx, rdx
    mov  rcx, 100
    div  rcx                    ; rax=entero rdx=centavos

    push rdx
    push rax
    lea  rcx, [rel bufTotal]
    lea  rdx, [rel fmtTotal]
    pop  r8
    pop  r9
    call wsprintfA

    mov  rcx, r12
    mov  rdx, 7002
    lea  r8,  [rel bufTotal]
    call SetDlgItemTextA

    pop  r13
    pop  r12
    pop  rbx
    add  rsp, 40h
    pop  rbp
    ret

; ============================================================
_R_OnCtlColorDlg:
    mov  rax, [rel hBrushFondoR]
    jmp  _R_Fin

_R_OnClose:
    mov  rcx, [rel hBrushFondoR]
    call DeleteObject
    mov  rcx, [rel var_hwndRep]
    xor  rdx, rdx
    call EndDialog
    mov  rax, 1
    jmp  _R_Fin

_R_Fin:
    add  rsp, 30h
    pop  rbp
    ret
