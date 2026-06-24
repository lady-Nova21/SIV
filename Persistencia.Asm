; ==========================================================
; Archivo: Persistencia.Asm
; Modulo:  Persistencia en archivos .txt
; Exporta: GuardarProductoTxt, GuardarVentaTxt
; APIs:    CreateFileA, WriteFile, CloseHandle
; ==========================================================
bits 64
global GuardarProductoTxt
global GuardarVentaTxt

extern CreateFileA
extern WriteFile
extern CloseHandle
extern wsprintfA

; Constantes Win32
GENERIC_WRITE       equ 40000000h
OPEN_ALWAYS         equ 4
FILE_ATTRIBUTE_NORMAL equ 80h
FILE_SHARE_READ     equ 1

section .data
    archivoProductos    db "productos.txt", 0
    archivoVentas       db "ventas.txt", 0
    fmtProducto         db "Codigo: %s | Nombre: %s | Precio: %s | Stock: %s", 13, 10, 0
    fmtVenta            db "Codigo: %s | Cantidad: %s | Total: %s", 13, 10, 0

section .bss
    hArchivo            resq 1
    bytesEscritos       resd 1
    bufLinea            resb 256

section .text

; ============================================================
; GuardarProductoTxt
; rcx = pCodigo  rdx = pNombre  r8 = pPrecio  r9 = pStock
; ============================================================
GuardarProductoTxt:
    push rbp
    mov  rbp, rsp
    sub  rsp, 50h
    push r14
    push r15
    push rsi
    push rdi

    ; guardar parametros
    mov  r14, rcx       ; codigo
    mov  r15, rdx       ; nombre
    mov  rsi, r8        ; precio
    mov  rdi, r9        ; stock

    ; formatear linea
    push rdi            ; stock
    push rsi            ; precio
    push r15            ; nombre
    push r14            ; codigo
    lea  rcx, [rel bufLinea]
    lea  rdx, [rel fmtProducto]
    sub  rsp, 20h
    call wsprintfA
    add  rsp, 20h + 4*8
    mov  r15, rax       ; bytes a escribir

    ; abrir/crear archivo productos.txt (OPEN_ALWAYS = crea si no existe, abre si existe)
    lea  rcx, [rel archivoProductos]
    mov  edx, GENERIC_WRITE
    mov  r8d, FILE_SHARE_READ
    xor  r9,  r9
    mov  qword [rsp+20h], OPEN_ALWAYS
    mov  qword [rsp+28h], FILE_ATTRIBUTE_NORMAL
    mov  qword [rsp+30h], 0
    call CreateFileA
    mov  [rel hArchivo], rax

    ; mover al final del archivo para agregar
    mov  rcx, rax
    xor  rdx, rdx
    xor  r8,  r8
    mov  r9d, 2         ; FILE_END
    mov  qword [rsp+20h], 0
    ; SetFilePointer no disponible directo, usamos WriteFile al final
    ; (OPEN_ALWAYS + escribir siempre agrega al final si no movemos puntero)

    ; escribir linea
    mov  rcx, [rel hArchivo]
    lea  rdx, [rel bufLinea]
    mov  r8d, r15d
    lea  r9,  [rel bytesEscritos]
    mov  qword [rsp+20h], 0
    call WriteFile

    ; cerrar archivo
    mov  rcx, [rel hArchivo]
    call CloseHandle

    pop  rdi
    pop  rsi
    pop  r15
    pop  r14
    add  rsp, 50h
    pop  rbp
    ret

; ============================================================
; GuardarVentaTxt
; rcx = pCodigo  rdx = pCantidad  r8 = pTotal
; ============================================================
GuardarVentaTxt:
    push rbp
    mov  rbp, rsp
    sub  rsp, 50h
    push r14
    push r15
    push rsi

    mov  r14, rcx       ; codigo
    mov  r15, rdx       ; cantidad
    mov  rsi, r8        ; total

    ; formatear linea
    push rsi            ; total
    push r15            ; cantidad
    push r14            ; codigo
    lea  rcx, [rel bufLinea]
    lea  rdx, [rel fmtVenta]
    sub  rsp, 20h
    call wsprintfA
    add  rsp, 20h + 3*8
    mov  r15, rax       ; bytes

    ; abrir/crear archivo ventas.txt
    lea  rcx, [rel archivoVentas]
    mov  edx, GENERIC_WRITE
    mov  r8d, FILE_SHARE_READ
    xor  r9,  r9
    mov  qword [rsp+20h], OPEN_ALWAYS
    mov  qword [rsp+28h], FILE_ATTRIBUTE_NORMAL
    mov  qword [rsp+30h], 0
    call CreateFileA
    mov  [rel hArchivo], rax

    ; escribir
    mov  rcx, [rel hArchivo]
    lea  rdx, [rel bufLinea]
    mov  r8d, r15d
    lea  r9,  [rel bytesEscritos]
    mov  qword [rsp+20h], 0
    call WriteFile

    ; cerrar
    mov  rcx, [rel hArchivo]
    call CloseHandle

    pop  rsi
    pop  r15
    pop  r14
    add  rsp, 50h
    pop  rbp
    ret
