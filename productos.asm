bits 64

global RegistrarProducto

extern GetDlgItemTextA
extern MessageBoxA

section .data
    msgExito   db "El producto ha sido capturado correctamente.", 0
    tituloMsg  db "SIV - Registro de Producto", 0

section .bss
    ; Reservamos memoria para guardar los datos ingresados
    nombreProd resb 256
    precioProd resb 32
    cantProd   resb 32
    
    hwndGlobal resq 1

section .text

; Función que será llamada cuando se presione el botón "Guardar Producto" (ID 1004)
; Recibe en RCX el Handle de la ventana (hWndDlg)
RegistrarProducto:
    push rbp
    mov rbp, rsp
    sub rsp, 40h                ; Shadow space para la API de Windows + alineación

    mov [rel hwndGlobal], rcx   ; Guardamos el handle de la ventana

    ; 1. Extraer el Nombre del Producto (Aylin le puso el ID 3001)
    mov rcx, [rel hwndGlobal]
    mov rdx, 3001
    lea r8, [rel nombreProd]
    mov r9, 256
    call GetDlgItemTextA

    ; 2. Extraer el Precio (ID 3002)
    mov rcx, [rel hwndGlobal]
    mov rdx, 3002
    lea r8, [rel precioProd]
    mov r9, 32
    call GetDlgItemTextA

    ; 3. Extraer la Cantidad (ID 3003)
    mov rcx, [rel hwndGlobal]
    mov rdx, 3003
    lea r8, [rel cantProd]
    mov r9, 32
    call GetDlgItemTextA

    ; -> AQUÍ LUEGO AGREGAREMOS LA LÓGICA PARA GUARDAR EN UN ARCHIVO (archivos.asm) <-
    ; -> O CONVERTIR LOS TEXTOS A NÚMEROS (fpu.asm) <-

    ; Por ahora, lanzamos una ventana emergente para comprobar que tu módulo funciona
    mov rcx, [rel hwndGlobal]
    lea rdx, [rel msgExito]
    lea r8, [rel tituloMsg]
    mov r9, 0                   ; MB_OK (0)
    call MessageBoxA

    add rsp, 40h
    pop rbp
    ret
