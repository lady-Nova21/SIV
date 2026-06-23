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
    ; Configuración de Stack Frame
    push rbp
    mov rbp, rsp
    sub rsp, 40h         ; Reservar espacio (Shadow space requerido por Win64)
    push r14             ; Guardamos r14 para preservarlo

    ; Al entrar aquí, RCX contiene el HWND de la ventana
    mov r14, rcx         ; Guardamos el HWND en r14 para usarlo más adelante

    ; Extraer texto: Nombre del Producto (ID 3001)
    mov rcx, r14         ; HWND
    mov rdx, 3001        ; ID
    lea r8, [rel nombreProd]
    mov r9, 256
    call GetDlgItemTextA

    ; Extraer texto: Precio (ID 3002)
    mov rcx, r14
    mov rdx, 3002
    lea r8, [rel precioProd]
    mov r9, 32
    call GetDlgItemTextA

    ; Extraer texto: Cantidad (ID 3003)
    mov rcx, r14
    mov rdx, 3003
    lea r8, [rel cantProd]
    mov r9, 32
    call GetDlgItemTextA

    ; Mostrar mensaje de éxito
    mov rcx, r14         ; HWND como dueño del MessageBox
    lea rdx, [rel msgExito]
    lea r8, [rel tituloMsg]
    mov r9, 0            ; MB_OK
    call MessageBoxA

    ; Restaurar y salir
    pop r14              ; Recuperamos r14
    add rsp, 40h
    pop rbp
    ret
