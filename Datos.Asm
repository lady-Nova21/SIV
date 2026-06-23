; ==========================================================
; Archivo: Datos.Asm
; Modulo:  Almacenamiento compartido de productos y ventas
; Exporta: todas las variables globales del sistema
; ==========================================================
bits 64

global productos_count
global productos_codigo
global productos_nombre
global productos_precio
global productos_stock

global ventas_count
global ventas_codigo
global ventas_cantidad
global ventas_total

global GetProductoIndexByCodigo
global AgregarProducto
global AgregarVenta
global GetTotalVentas

; ── Constantes ──────────────────────────────────────────────
MAX_PRODUCTOS   equ 50
MAX_VENTAS      equ 200
TAM_CODIGO      equ 32
TAM_NOMBRE      equ 64
TAM_PRECIO      equ 16

; ============================================================
; SECCION DE DATOS COMPARTIDOS
; ============================================================
section .bss

    ; ── Productos ───────────────────────────────────────────
    productos_count     resd 1                          ; cuantos productos hay
    productos_codigo    resb TAM_CODIGO * MAX_PRODUCTOS ; codigo alfanumerico
    productos_nombre    resb TAM_NOMBRE * MAX_PRODUCTOS ; nombre del producto
    productos_precio    resq MAX_PRODUCTOS              ; precio * 100 (entero)
    productos_stock     resd MAX_PRODUCTOS              ; unidades en stock

    ; ── Ventas ──────────────────────────────────────────────
    ventas_count        resd 1
    ventas_codigo       resb TAM_CODIGO * MAX_VENTAS    ; codigo del producto vendido
    ventas_cantidad     resd MAX_VENTAS                 ; cantidad vendida
    ventas_total        resq MAX_VENTAS                 ; total = precio * cantidad

section .text

; ============================================================
; GetProductoIndexByCodigo
;   rcx = puntero a string codigo (ASCIIZ)
;   rax = indice (0-based) si encontrado, -1 si no existe
; ============================================================
GetProductoIndexByCodigo:
    push rbp
    mov  rbp, rsp
    sub  rsp, 30h
    push rbx
    push rsi
    push rdi
    push r12
    push r13

    mov  r12, rcx                       ; guarda puntero al codigo buscado
    mov  r13d, [rel productos_count]    ; total de productos
    xor  rbx, rbx                       ; i = 0

.loop:
    cmp  rbx, r13
    jge  .not_found

    ; puntero al codigo del producto i
    imul rsi, rbx, TAM_CODIGO
    lea  rdi, [rel productos_codigo]
    add  rdi, rsi

    ; comparar strings
    mov  rcx, r12
    mov  rdx, rdi
    call _strcmp
    test rax, rax
    jz   .found

    inc  rbx
    jmp  .loop

.found:
    mov  rax, rbx
    jmp  .fin

.not_found:
    mov  rax, -1

.fin:
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    add rsp, 30h
    pop rbp
    ret

; ============================================================
; AgregarProducto
;   rcx = puntero a codigo  (ASCIIZ, max 31 chars)
;   rdx = puntero a nombre  (ASCIIZ, max 63 chars)
;   r8  = precio * 100      (qword, ej: 2050 = 20.50)
;   r9  = stock             (dword)
;   rax = indice donde se guardo, -1 si tabla llena
; ============================================================
AgregarProducto:
    push rbp
    mov  rbp, rsp
    sub  rsp, 30h
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15

    mov  r12, rcx       ; codigo
    mov  r13, rdx       ; nombre
    mov  r14, r8        ; precio
    mov  r15d, r9d      ; stock

    ; verificar si ya existe (actualizar si es el caso)
    mov  rcx, r12
    call GetProductoIndexByCodigo
    cmp  rax, -1
    jne  .actualizar

    ; verificar espacio
    mov  ebx, [rel productos_count]
    cmp  ebx, MAX_PRODUCTOS
    jge  .tabla_llena

    ; guardar en posicion ebx
    jmp  .guardar

.actualizar:
    mov  ebx, eax       ; indice existente

.guardar:
    ; ── copiar codigo ──
    imul rsi, rbx, TAM_CODIGO
    lea  rdi, [rel productos_codigo]
    add  rdi, rsi
    mov  rcx, r12
    mov  rdx, rdi
    mov  r8,  TAM_CODIGO
    call _strncpy

    ; ── copiar nombre ──
    imul rsi, rbx, TAM_NOMBRE
    lea  rdi, [rel productos_nombre]
    add  rdi, rsi
    mov  rcx, r13
    mov  rdx, rdi
    mov  r8,  TAM_NOMBRE
    call _strncpy

    ; ── guardar precio ──
    lea  rdi, [rel productos_precio]
    mov  [rdi + rbx*8], r14

    ; ── guardar stock ──
    lea  rdi, [rel productos_stock]
    mov  [rdi + rbx*4], r15d

    ; ── incrementar count solo si es nuevo ──
    mov  eax, [rel productos_count]
    cmp  ebx, eax
    jl   .no_incrementar
    inc  dword [rel productos_count]

.no_incrementar:
    mov  rax, rbx
    jmp  .fin

.tabla_llena:
    mov  rax, -1

.fin:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    add rsp, 30h
    pop rbp
    ret

; ============================================================
; AgregarVenta
;   rcx = puntero a codigo (ASCIIZ)
;   rdx = cantidad (dword)
;   rax = indice de venta, -1 si tabla llena o producto no existe
;         tambien descuenta stock automaticamente
; ============================================================
AgregarVenta:
    push rbp
    mov  rbp, rsp
    sub  rsp, 30h
    push rbx
    push rsi
    push rdi
    push r12
    push r13

    mov  r12, rcx       ; codigo
    mov  r13d, edx      ; cantidad

    ; buscar producto
    mov  rcx, r12
    call GetProductoIndexByCodigo
    cmp  rax, -1
    je   .no_existe

    mov  rbx, rax       ; indice del producto

    ; verificar stock suficiente
    lea  rdi, [rel productos_stock]
    mov  eax, [rdi + rbx*4]
    cmp  eax, r13d
    jl   .sin_stock

    ; verificar espacio en ventas
    mov  eax, [rel ventas_count]
    cmp  eax, MAX_VENTAS
    jge  .tabla_llena

    mov  rsi, rax       ; indice nueva venta

    ; ── copiar codigo en ventas ──
    imul rdi, rsi, TAM_CODIGO
    lea  rax, [rel ventas_codigo]
    add  rax, rdi
    mov  rcx, r12
    mov  rdx, rax
    mov  r8,  TAM_CODIGO
    call _strncpy

    ; ── guardar cantidad ──
    lea  rdi, [rel ventas_cantidad]
    mov  [rdi + rsi*4], r13d

    ; ── calcular total = precio * cantidad ──
    lea  rdi, [rel productos_precio]
    mov  rax, [rdi + rbx*8]
    imul rax, r13
    lea  rdi, [rel ventas_total]
    mov  [rdi + rsi*8], rax

    ; ── descontar stock ──
    lea  rdi, [rel productos_stock]
    sub  dword [rdi + rbx*4], r13d

    ; ── incrementar count ventas ──
    inc  dword [rel ventas_count]

    mov  rax, rsi
    jmp  .fin

.no_existe:
.sin_stock:
.tabla_llena:
    mov  rax, -1

.fin:
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    add rsp, 30h
    pop rbp
    ret

; ============================================================
; GetTotalVentas
;   rax = suma de todos los ventas_total (precio*100)
; ============================================================
GetTotalVentas:
    push rbx
    xor  rax, rax
    xor  rbx, rbx
    mov  ecx, [rel ventas_count]

.loop:
    cmp  rbx, rcx
    jge  .fin
    lea  rdx, [rel ventas_total]
    add  rax, [rdx + rbx*8]
    inc  rbx
    jmp  .loop

.fin:
    pop rbx
    ret

; ============================================================
; _strcmp  rcx=str1  rdx=str2  rax=0 si iguales
; ============================================================
_strcmp:
    push rsi
    push rdi
    mov  rsi, rcx
    mov  rdi, rdx
.cmp_loop:
    mov  al, [rsi]
    mov  bl, [rdi]
    cmp  al, bl
    jne  .diff
    test al, al
    jz   .equal
    inc  rsi
    inc  rdi
    jmp  .cmp_loop
.equal:
    xor  rax, rax
    jmp  .cmp_fin
.diff:
    mov  rax, 1
.cmp_fin:
    pop  rdi
    pop  rsi
    ret

; ============================================================
; _strncpy  rcx=src  rdx=dst  r8=maxlen
; ============================================================
_strncpy:
    push rsi
    push rdi
    push rcx
    mov  rsi, rcx
    mov  rdi, rdx
    mov  rcx, r8
.copy_loop:
    test rcx, rcx
    jz   .copy_fin
    mov  al, [rsi]
    mov  [rdi], al
    test al, al
    jz   .copy_fin
    inc  rsi
    inc  rdi
    dec  rcx
    jmp  .copy_loop
.copy_fin:
    ; asegurar null terminator
    mov  byte [rdi], 0
    pop  rcx
    pop  rdi
    pop  rsi
    ret
