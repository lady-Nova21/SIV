bits 64
global RegistrarProducto
extern GetDlgItemTextA, MessageBoxA

section .data
    msgExito   db "Producto guardado con éxito.", 0
    tituloMsg  db "SIV - Confirmación", 0

section .bss
    nombreProd resb 256
    precioProd resb 32
    cantProd   resb 32

section .text
RegistrarProducto:
    push rbp
    mov rbp, rsp
    sub rsp, 40h

    ; Extraer textos de los cuadros (IDs 3001, 3002, 3003)
    mov rcx, [rbp + 16] ; Recibe el hwnd pasado por el call
    mov rdx, 3001
    lea r8, [rel nombreProd]
    mov r9, 256
    call GetDlgItemTextA

    mov rcx, [rbp + 16]
    mov rdx, 3002
    lea r8, [rel precioProd]
    mov r9, 32
    call GetDlgItemTextA

    mov rcx, [rbp + 16]
    mov rdx, 3003
    lea r8, [rel cantProd]
    mov r9, 32
    call GetDlgItemTextA

    ; Mostrar mensaje
    mov rcx, [rbp + 16]
    lea rdx, [rel msgExito]
    lea r8, [rel tituloMsg]
    mov r9, 0
    call MessageBoxA

    add rsp, 40h
    pop rbp
    ret
