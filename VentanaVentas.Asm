; ==========================================================; Archivo: VentanaVentas.Asm; Modulo:  Realizar Venta; Funcion: MostrarVentanaVentas; Usa:     AgregarVenta, GetProductoIndexByCodigo de Datos.Asm; IDs RC:  3010=Codigo 3011=Cantidad 2001=Agregar 2002=Limpiar;          5010=ListBox 7001=LabelTotal 2003=ConfirmarVenta;          9001=Cerrar; ==========================================================bits 64global MostrarVentanaVentasextern CreateSolidBrushextern DeleteObjectextern DialogBoxParamAextern GetModuleHandleAextern SetBkModeextern EndDialogextern GetDlgItemTextAextern SetDlgItemTextAextern SendDlgItemMessageAextern MessageBoxAextern wsprintfAextern AgregarVentaextern GetProductoIndexByCodigoextern productos_codigoextern productos_nombreextern productos_precioextern productos_stockextern ventas_countextern ventas_codigoextern ventas_cantidadextern ventas_totalextern GetTotalVentasTAM_CODIGO  equ 32TAM_NOMBRE  equ 64LB_ADDSTRING    equ 0180hLB_RESETCONTENT equ 0184hsection .data    hBrushFondoV    dq 0    colorCremaV     dd 00F0FFFFh    msgSinStock     db "Stock insuficiente o codigo no existe.", 0    msgVentaOK      db "Venta registrada correctamente.", 0    msgCampos       db "Complete Codigo y Cantidad.", 0    msgVentaConf    db "Venta confirmada. Total registrado.", 0    tituloOK        db "SIV - Venta", 0    tituloErr       db "SIV - Error", 0    fmtItem         db "%-10s %-20s  x%d  Bs.%d.%02d", 0    fmtTotal        db "Total: Bs. %d.%02d", 0    szVacio         db "", 0    totalAcum       dq 0            ; total acumulado sesion actualsection .bss    hInstanceV      resq 1    var_hwndV       resq 1    var_msgV        resd 1    var_wparamV     resq 1    var_lparamV     resq 1    bufCodigo       resb 32    bufCantidad     resb 16    bufLinea        resb 128    bufTotalStr     resb 32section .text; ============================================================MostrarVentanaVentas:    push rbp    mov  rbp, rsp    sub  rsp, 30h    ; resetear total acumulado de esta sesion    mov  qword [rel totalAcum], 0    xor  ecx, ecx    call GetModuleHandleA    mov  [rel hInstanceV], rax    mov  rcx, [rel hInstanceV]    mov  rdx, 2001    xor  r8,  r8    lea  r9,  [rel DlgProcVentas]    mov  qword [rsp+20h], 0    call DialogBoxParamA    add  rsp, 30h    pop  rbp    ret; ============================================================DlgProcVentas:    mov  [rel var_hwndV],   rcx    mov  [rel var_msgV],    edx    mov  [relizar label total    call _V_ActualizarTotal    ; limpiar campos de entrada    mov  rcx, r14    mov  rdx, 3010    lea  r8,  [rxtA    mov  rcx, r14    mov  rdx; ================================================================
;   VENTANA "VENTA"  -  NASM x64 + GoLink + WinAPI  (para RadASM)
; ================================================================
;   Campos: "Codigo:" (editable), "Cantidad:" (editable)
;   Boton:  "Guardar" -> Muestra los datos Y LOS GUARDA EN UN TXT
; ================================================================

; ---------------- Constantes WinAPI ----------------
%define WS_OVERLAPPEDWINDOW   0x00CF0000
%define WS_VISIBLE            0x10000000
%define WS_CHILD              0x40000000
%define WS_BORDER             0x00800000
%define WS_TABSTOP            0x00010000
%define ES_AUTOHSCROLL        0x0080
%define CW_USEDEFAULT         0x80000000
%define SW_SHOWNORMAL         1
%define WM_CREATE             0x0001
%define WM_DESTROY            0x0002
%define WM_CLOSE              0x0010
%define WM_COMMAND            0x0111
%define WM_GETTEXT            0x000D
%define BN_CLICKED            0
%define IDI_APPLICATION       32512
%define IDC_ARROW             32512
%define WHITE_BRUSH           0

; Constantes para manejo de archivos
%define GENERIC_WRITE         0x40000000
%define FILE_SHARE_READ       1
%define OPEN_ALWAYS           4
%define FILE_ATTRIBUTE_NORMAL 0x80
%define FILE_END              2

%define ID_EDIT_CODIGO    1001
%define ID_EDIT_CANTIDAD  1002
%define ID_BTN_GUARDAR    1003

; ---------------- Estructuras ----------------
struc WNDCLASSEX
    .cbSize          resd 1
    .style           resd 1
    .lpfnWndProc     resq 1
    .cbClsExtra      resd 1
    .cbWndExtra      resd 1
    .hInstance       resq 1
    .hIcon           resq 1
    .hCursor         resq 1
    .hbrBackground   resq 1
    .lpszMenuName    resq 1
    .lpszClassName   resq 1
    .hIconSm         resq 1
endstruc

struc MSGSTRUCT
    .hwnd      resq 1
    .message   resd 1
    .pad1      resd 1
    .wParam    resq 1
    .lParam    resq 1
    .time      resd 1
    .ptX       resd 1
    .ptY       resd 1
    .pad2      resd 1
endstruc

; ---------------- Macro de creacion ----------------
%macro CREATEWND 10
    sub rsp, 0x60
    mov qword [rsp+0x40], %9      
    mov qword [rsp+0x48], %10     
    mov dword [rsp+0x20], %5      
    mov dword [rsp+0x28], %6      
    mov dword [rsp+0x30], %7      
    mov dword [rsp+0x38], %8      
    mov rax, [g_hInstance]
    mov qword [rsp+0x50], rax     
    mov qword [rsp+0x58], 0       
    mov ecx, %1                   
    lea rdx, [%2]                 
    %ifidn %3, 0
        xor r8, r8                
    %else
        lea r8, [%3]              
    %endif
    mov r9d, %4                   
    call CreateWindowExA
    add rsp, 0x60
%endmacro

; ================================================================
section .data
; ================================================================
    szClassName    db 'VentanaVenta',0
    szTitle        db 'Venta',0
    szClassButton  db 'BUTTON',0
    szClassEdit    db 'EDIT',0
    szClassStatic  db 'STATIC',0
    szLblCodigo    db 'Codigo:',0
    szLblCantidad  db 'Cantidad:',0
    szBtnGuardar   db 'Guardar',0
    szMsgTitulo    db 'Datos guardados',0
    
    ; Formatos para construir las cadenas
    szMsgFmt1      db 'Codigo: ',0
    szMsgFmt2      db 13,10,'Cantidad: ',0
    
    ; Formato limpio para escribir en la base de datos (Archivo TXT)
    szTxtFmt1      db 'Codigo: ',0
    szTxtFmt2      db ' | Cantidad: ',0
    szTxtNuevaLin  db 13,10,0 ; Salto de linea para el bloc de notas
    
    ; Nombre del archivo de base de datos
    szNombreArchivo db 'ventas.txt',0

; ================================================================
section .bss
; ================================================================
    g_hInstance        resq 1
    g_hwndMain         resq 1
    g_hwndEditCodigo   resq 1
    g_hwndEditCantidad resq 1

    g_curHwnd          resq 1
    g_curMsg           resq 1
    g_curWParam        resq 1
    g_curLParam        resq 1

    g_wc   resb 80          
    g_msg  resb 48          

    bufCodigo   resb 64
    bufCantidad resb 64
    bufMensaje  resb 200
    bufArchivo  resb 256  ; Buffer para armar la linea del archivo
    
    bytesEscritos resd 1   ; Variable necesaria para WriteFile

; ================================================================
section .text
; ================================================================

extern GetModuleHandleA
extern ExitProcess
extern RegisterClassExA
extern CreateWindowExA
extern ShowWindow
extern UpdateWindow
extern GetMessageA
extern TranslateMessage
extern DispatchMessageA
extern DefWindowProcA
extern PostQuitMessage
extern DestroyWindow
extern LoadCursorA
extern LoadIconA
extern GetStockObject
extern MessageBoxA
extern SendMessageA

; Funciones del sistema para manejo de archivos (Kernel32)
extern CreateFileA
extern SetFilePointer
extern WriteFile
extern CloseHandle

global start

start:
    and rsp, -16          
    sub rsp, 0x20          

    xor ecx, ecx
    call GetModuleHandleA
    mov [g_hInstance], rax

    ; -------- Registrar la clase --------
    mov dword [g_wc + WNDCLASSEX.cbSize], 80
    mov dword [g_wc + WNDCLASSEX.style], 0
    lea rax, [WndProc]
    mov [g_wc + WNDCLASSEX.lpfnWndProc], rax
    mov dword [g_wc + WNDCLASSEX.cbClsExtra], 0
    mov dword [g_wc + WNDCLASSEX.cbWndExtra], 0
    mov rax, [g_hInstance]
    mov [g_wc + WNDCLASSEX.hInstance], rax

    xor ecx, ecx
    mov edx, IDI_APPLICATION
    call LoadIconA
    mov [g_wc + WNDCLASSEX.hIcon], rax
    mov [g_wc + WNDCLASSEX.hIconSm], rax

    xor ecx, ecx
    mov edx, IDC_ARROW
    call LoadCursorA
    mov [g_wc + WNDCLASSEX.hCursor], rax

    mov ecx, WHITE_BRUSH
    call GetStockObject
    mov [g_wc + WNDCLASSEX.hbrBackground], rax

    mov qword [g_wc + WNDCLASSEX.lpszMenuName], 0
    lea rax, [szClassName]
    mov [g_wc + WNDCLASSEX.lpszClassName], rax

    lea rcx, [g_wc]
    call RegisterClassExA

    ; -------- Crear ventana principal --------
    CREATEWND 0, szClassName, szTitle, WS_OVERLAPPEDWINDOW|WS_VISIBLE, CW_USEDEFAULT, CW_USEDEFAULT, 320, 230, 0, 0
    mov [g_hwndMain], rax

    mov rcx, rax
    mov edx, SW_SHOWNORMAL
    call ShowWindow
    mov rcx, [g_hwndMain]
    call UpdateWindow

.msgloop:
    lea rcx, [g_msg]
    xor edx, edx
    xor r8, r8
    xor r9, r9
    call GetMessageA
    test eax, eax
    jz .fin
    lea rcx, [g_msg]
    call TranslateMessage
    lea rcx, [g_msg]
    call DispatchMessageA
    jmp .msgloop

.fin:
    mov ecx, dword [g_msg + MSGSTRUCT.wParam]
    call ExitProcess

; ----------------------------------------------------------------
; WndProc
; ----------------------------------------------------------------
WndProc:
    sub rsp, 0x28
    mov [g_curHwnd], rcx
    mov [g_curMsg], rdx
    mov [g_curWParam], r8
    mov [g_curLParam], r9

    mov eax, dword [g_curMsg]
    cmp eax, WM_CREATE
    je .onCreate
    cmp eax, WM_COMMAND
    je .onCommand
    cmp eax, WM_CLOSE
    je .onClose
    cmp eax, WM_DESTROY
    je .onDestroy
    jmp .default

.onCreate:
    CREATEWND 0, szClassStatic, szLblCodigo, WS_CHILD|WS_VISIBLE, 20,22,80,20, qword [g_curHwnd], 0
    CREATEWND 0, szClassEdit, 0, WS_CHILD|WS_VISIBLE|WS_BORDER|WS_TABSTOP|ES_AUTOHSCROLL, 110,20,150,22, qword [g_curHwnd], ID_EDIT_CODIGO
    mov [g_hwndEditCodigo], rax

    CREATEWND 0, szClassStatic, szLblCantidad, WS_CHILD|WS_VISIBLE, 20,62,80,20, qword [g_curHwnd], 0
    CREATEWND 0, szClassEdit, 0, WS_CHILD|WS_VISIBLE|WS_BORDER|WS_TABSTOP|ES_AUTOHSCROLL, 110,60,150,22, qword [g_curHwnd], ID_EDIT_CANTIDAD
    mov [g_hwndEditCantidad], rax

    CREATEWND 0, szClassButton, szBtnGuardar, WS_CHILD|WS_VISIBLE|WS_TABSTOP, 110,110,110,32, qword [g_curHwnd], ID_BTN_GUARDAR

    xor eax, eax
    jmp .salir

.onCommand:
    mov rax, [g_curWParam]
    movzx ecx, ax              
    cmp ecx, ID_BTN_GUARDAR
    jne .default
    mov rax, [g_curWParam]
    shr eax, 16                 
    cmp eax, BN_CLICKED
    jne .default
    call GuardarDatos
    xor eax, eax
    jmp .salir

.onClose:
    mov rcx, [g_curHwnd]
    call DestroyWindow
    xor eax, eax
    jmp .salir

.onDestroy:
    xor ecx, ecx
    call PostQuitMessage
    xor eax, eax
    jmp .salir

.default:
    mov rcx, [g_curHwnd]
    mov rdx, [g_curMsg]
    mov r8,  [g_curWParam]
    mov r9,  [g_curLParam]
    call DefWindowProcA
    jmp .salir

.salir:
    add rsp, 0x28
    ret

; ----------------------------------------------------------------
; GuardarDatos - LEE, MUESTRA MENSAJE Y ESCRIBE EN archivo .txt
; ----------------------------------------------------------------
GuardarDatos:
    sub rsp, 0x38             ; Espacio para sombra y variables locales

    ; 1. Leer texto de "Codigo"
    mov rcx, [g_hwndEditCodigo]
    mov edx, WM_GETTEXT
    mov r8, 64
    lea r9, [bufCodigo]
    call SendMessageA

    ; 2. Leer texto de "Cantidad"
    mov rcx, [g_hwndEditCantidad]
    mov edx, WM_GETTEXT
    mov r8, 64
    lea r9, [bufCantidad]
    call SendMessageA

    ; 3. Construir texto para el MessageBox (Pantalla)
    lea rdi, [bufMensaje]
    lea rsi, [szMsgFmt1]
    call CopiarCadena
    lea rsi, [bufCodigo]
    call CopiarCadena
    lea rsi, [szMsgFmt2]
    call CopiarCadena
    lea rsi, [bufCantidad]
    call CopiarCadena
    mov byte [rdi], 0

    ; 4. Construir linea de texto para el archivo TXT (Base de datos)
    lea rdi, [bufArchivo]
    lea rsi, [szTxtFmt1]
    call CopiarCadena
    lea rsi, [bufCodigo]
    call CopiarCadena
    lea rsi, [szTxtFmt2]
    call CopiarCadena
    lea rsi, [bufCantidad]
    call CopiarCadena
    lea rsi, [szTxtNuevaLin]
    call CopiarCadena
    mov byte [rdi], 0          ; Termina la cadena

    ; Calcular la longitud exacta de la cadena para el archivo
    lea rax, [bufArchivo]
    sub rdi, rax              ; RDI tiene la direccion actual del final, restamos el inicio
    mov r12, rdi              ; Guardamos la longitud en R12 (registro seguro)

    ; 5. PERSISTENCIA: Guardar en el Archivo usando WinAPI
    ; Abrir o crear el archivo "ventas.txt"
    lea rcx, [szNombreArchivo]
    mov edx, GENERIC_WRITE
    mov r8d, FILE_SHARE_READ
    xor r9, r9
    mov dword [rsp+0x20], OPEN_ALWAYS
    mov dword [rsp+0x28], FILE_ATTRIBUTE_NORMAL
    mov qword [rsp+0x30], 0
    call CreateFileA
    
    mov r13, rax              ; Guardamos el HANDLE del archivo en R13
    cmp rax, -1               ; INVALID_HANDLE_VALUE
    je .mostrar_box

    ; Mover el puntero del archivo al final (para hacer Append / no borrar lo viejo)
    mov rcx, r13
    xor edx, edx              ; 0 bytes de desplazamiento relativo
    xor r8, r8                ; No usar puntero de 64 bits alto
    mov r9d, FILE_END         ; Mover desde el final
    call SetFilePointer

    ; Escribir la linea en el archivo
    mov rcx, r13              ; Handle
    lea rdx, [bufArchivo]     ; Datos
    mov r8d, r12d             ; Longitud de la cadena
    lea r9, [bytesEscritos]   ; Variable receptora obligatoria
    mov qword [rsp+0x20], 0   ; lpOverlapped = NULL
    call WriteFile

    ; Cerrar el archivo
    mov rcx, r13
    call CloseHandle

.mostrar_box:
    ; 6. Mostrar el MessageBox clásico
    xor ecx, ecx
    lea rdx, [bufMensaje]
    lea r8, [szMsgTitulo]
    xor r9d, r9d
    call MessageBoxA

    add rsp, 0x38
    ret

; ----------------------------------------------------------------
; CopiarCadena
; ----------------------------------------------------------------
CopiarCadena:
    push rax
.bucle:
    mov al, [rsi]
    test al, al
    jz .fin
    mov [rdi], al
    inc rsi
    inc rdi
    jmp .bucle
.fin:
    pop rax
    ret; ================================================================
;   VENTANA "VENTA"  -  NASM x64 + GoLink + WinAPI  (para RadASM)
; ================================================================
;   Campos: "Codigo:" (editable), "Cantidad:" (editable)
;   Boton:  "Guardar" -> Muestra los datos Y LOS GUARDA EN UN TXT
; ================================================================

; ---------------- Constantes WinAPI ----------------
%define WS_OVERLAPPEDWINDOW   0x00CF0000
%define WS_VISIBLE            0x10000000
%define WS_CHILD              0x40000000
%define WS_BORDER             0x00800000
%define WS_TABSTOP            0x00010000
%define ES_AUTOHSCROLL        0x0080
%define CW_USEDEFAULT         0x80000000
%define SW_SHOWNORMAL         1
%define WM_CREATE             0x0001
%define WM_DESTROY            0x0002
%define WM_CLOSE              0x0010
%define WM_COMMAND            0x0111
%define WM_GETTEXT            0x000D
%define BN_CLICKED            0
%define IDI_APPLICATION       32512
%define IDC_ARROW             32512
%define WHITE_BRUSH           0

; Constantes para manejo de archivos
%define GENERIC_WRITE         0x40000000
%define FILE_SHARE_READ       1
%define OPEN_ALWAYS           4
%define FILE_ATTRIBUTE_NORMAL 0x80
%define FILE_END              2

%define ID_EDIT_CODIGO    1001
%define ID_EDIT_CANTIDAD  1002
%define ID_BTN_GUARDAR    1003

; ---------------- Estructuras ----------------
struc WNDCLASSEX
    .cbSize          resd 1
    .style           resd 1
    .lpfnWndProc     resq 1
    .cbClsExtra      resd 1
    .cbWndExtra      resd 1
    .hInstance       resq 1
    .hIcon           resq 1
    .hCursor         resq 1
    .hbrBackground   resq 1
    .lpszMenuName    resq 1
    .lpszClassName   resq 1
    .hIconSm         resq 1
endstruc

struc MSGSTRUCT
    .hwnd      resq 1
    .message   resd 1
    .pad1      resd 1
    .wParam    resq 1
    .lParam    resq 1
    .time      resd 1
    .ptX       resd 1
    .ptY       resd 1
    .pad2      resd 1
endstruc

; ---------------- Macro de creacion ----------------
%macro CREATEWND 10
    sub rsp, 0x60
    mov qword [rsp+0x40], %9      
    mov qword [rsp+0x48], %10     
    mov dword [rsp+0x20], %5      
    mov dword [rsp+0x28], %6      
    mov dword [rsp+0x30], %7      
    mov dword [rsp+0x38], %8      
    mov rax, [g_hInstance]
    mov qword [rsp+0x50], rax     
    mov qword [rsp+0x58], 0       
    mov ecx, %1                   
    lea rdx, [%2]                 
    %ifidn %3, 0
        xor r8, r8                
    %else
        lea r8, [%3]              
    %endif
    mov r9d, %4                   
    call CreateWindowExA
    add rsp, 0x60
%endmacro

; ================================================================
section .data
; ================================================================
    szClassName    db 'VentanaVenta',0
    szTitle        db 'Venta',0
    szClassButton  db 'BUTTON',0
    szClassEdit    db 'EDIT',0
    szClassStatic  db 'STATIC',0
    szLblCodigo    db 'Codigo:',0
    szLblCantidad  db 'Cantidad:',0
    szBtnGuardar   db 'Guardar',0
    szMsgTitulo    db 'Datos guardados',0
    
    ; Formatos para construir las cadenas
    szMsgFmt1      db 'Codigo: ',0
    szMsgFmt2      db 13,10,'Cantidad: ',0
    
    ; Formato limpio para escribir en la base de datos (Archivo TXT)
    szTxtFmt1      db 'Codigo: ',0
    szTxtFmt2      db ' | Cantidad: ',0
    szTxtNuevaLin  db 13,10,0 ; Salto de linea para el bloc de notas
    
    ; Nombre del archivo de base de datos
    szNombreArchivo db 'ventas.txt',0

; ================================================================
section .bss
; ================================================================
    g_hInstance        resq 1
    g_hwndMain         resq 1
    g_hwndEditCodigo   resq 1
    g_hwndEditCantidad resq 1

    g_curHwnd          resq 1
    g_curMsg           resq 1
    g_curWParam        resq 1
    g_curLParam        resq 1

    g_wc   resb 80          
    g_msg  resb 48          

    bufCodigo   resb 64
    bufCantidad resb 64
    bufMensaje  resb 200
    bufArchivo  resb 256  ; Buffer para armar la linea del archivo
    
    bytesEscritos resd 1   ; Variable necesaria para WriteFile

; ================================================================
section .text
; ================================================================

extern GetModuleHandleA
extern ExitProcess
extern RegisterClassExA
extern CreateWindowExA
extern ShowWindow
extern UpdateWindow
extern GetMessageA
extern TranslateMessage
extern DispatchMessageA
extern DefWindowProcA
extern PostQuitMessage
extern DestroyWindow
extern LoadCursorA
extern LoadIconA
extern GetStockObject
extern MessageBoxA
extern SendMessageA

; Funciones del sistema para manejo de archivos (Kernel32)
extern CreateFileA
extern SetFilePointer
extern WriteFile
extern CloseHandle

global start

start:
    and rsp, -16          
    sub rsp, 0x20          

    xor ecx, ecx
    call GetModuleHandleA
    mov [g_hInstance], rax

    ; -------- Registrar la clase --------
    mov dword [g_wc + WNDCLASSEX.cbSize], 80
    mov dword [g_wc + WNDCLASSEX.style], 0
    lea rax, [WndProc]
    mov [g_wc + WNDCLASSEX.lpfnWndProc], rax
    mov dword [g_wc + WNDCLASSEX.cbClsExtra], 0
    mov dword [g_wc + WNDCLASSEX.cbWndExtra], 0
    mov rax, [g_hInstance]
    mov [g_wc + WNDCLASSEX.hInstance], rax

    xor ecx, ecx
    mov edx, IDI_APPLICATION
    call LoadIconA
    mov [g_wc + WNDCLASSEX.hIcon], rax
    mov [g_wc + WNDCLASSEX.hIconSm], rax

    xor ecx, ecx
    mov edx, IDC_ARROW
    call LoadCursorA
    mov [g_wc + WNDCLASSEX.hCursor], rax

    mov ecx, WHITE_BRUSH
    call GetStockObject
    mov [g_wc + WNDCLASSEX.hbrBackground], rax

    mov qword [g_wc + WNDCLASSEX.lpszMenuName], 0
    lea rax, [szClassName]
    mov [g_wc + WNDCLASSEX.lpszClassName], rax

    lea rcx, [g_wc]
    call RegisterClassExA

    ; -------- Crear ventana principal --------
    CREATEWND 0, szClassName, szTitle, WS_OVERLAPPEDWINDOW|WS_VISIBLE, CW_USEDEFAULT, CW_USEDEFAULT, 320, 230, 0, 0
    mov [g_hwndMain], rax

    mov rcx, rax
    mov edx, SW_SHOWNORMAL
    call ShowWindow
    mov rcx, [g_hwndMain]
    call UpdateWindow

.msgloop:
    lea rcx, [g_msg]
    xor edx, edx
    xor r8, r8
    xor r9, r9
    call GetMessageA
    test eax, eax
    jz .fin
    lea rcx, [g_msg]
    call TranslateMessage
    lea rcx, [g_msg]
    call DispatchMessageA
    jmp .msgloop

.fin:
    mov ecx, dword [g_msg + MSGSTRUCT.wParam]
    call ExitProcess

; ----------------------------------------------------------------
; WndProc
; ----------------------------------------------------------------
WndProc:
    sub rsp, 0x28
    mov [g_curHwnd], rcx
    mov [g_curMsg], rdx
    mov [g_curWParam], r8
    mov [g_curLParam], r9

    mov eax, dword [g_curMsg]
    cmp eax, WM_CREATE
    je .onCreate
    cmp eax, WM_COMMAND
    je .onCommand
    cmp eax, WM_CLOSE
    je .onClose
    cmp eax, WM_DESTROY
    je .onDestroy
    jmp .default

.onCreate:
    CREATEWND 0, szClassStatic, szLblCodigo, WS_CHILD|WS_VISIBLE, 20,22,80,20, qword [g_curHwnd], 0
    CREATEWND 0, szClassEdit, 0, WS_CHILD|WS_VISIBLE|WS_BORDER|WS_TABSTOP|ES_AUTOHSCROLL, 110,20,150,22, qword [g_curHwnd], ID_EDIT_CODIGO
    mov [g_hwndEditCodigo], rax

    CREATEWND 0, szClassStatic, szLblCantidad, WS_CHILD|WS_VISIBLE, 20,62,80,20, qword [g_curHwnd], 0
    CREATEWND 0, szClassEdit, 0, WS_CHILD|WS_VISIBLE|WS_BORDER|WS_TABSTOP|ES_AUTOHSCROLL, 110,60,150,22, qword [g_curHwnd], ID_EDIT_CANTIDAD
    mov [g_hwndEditCantidad], rax

    CREATEWND 0, szClassButton, szBtnGuardar, WS_CHILD|WS_VISIBLE|WS_TABSTOP, 110,110,110,32, qword [g_curHwnd], ID_BTN_GUARDAR

    xor eax, eax
    jmp .salir

.onCommand:
    mov rax, [g_curWParam]
    movzx ecx, ax              
    cmp ecx, ID_BTN_GUARDAR
    jne .default
    mov rax, [g_curWParam]
    shr eax, 16                 
    cmp eax, BN_CLICKED
    jne .default
    call GuardarDatos
    xor eax, eax
    jmp .salir

.onClose:
    mov rcx, [g_curHwnd]
    call DestroyWindow
    xor eax, eax
    jmp .salir

.onDestroy:
    xor ecx, ecx
    call PostQuitMessage
    xor eax, eax
    jmp .salir

.default:
    mov rcx, [g_curHwnd]
    mov rdx, [g_curMsg]
    mov r8,  [g_curWParam]
    mov r9,  [g_curLParam]
    call DefWindowProcA
    jmp .salir

.salir:
    add rsp, 0x28
    ret

; ----------------------------------------------------------------
; GuardarDatos - LEE, MUESTRA MENSAJE Y ESCRIBE EN archivo .txt
; ----------------------------------------------------------------
GuardarDatos:
    sub rsp, 0x38             ; Espacio para sombra y variables locales

    ; 1. Leer texto de "Codigo"
    mov rcx, [g_hwndEditCodigo]
    mov edx, WM_GETTEXT
    mov r8, 64
    lea r9, [bufCodigo]
    call SendMessageA

    ; 2. Leer texto de "Cantidad"
    mov rcx, [g_hwndEditCantidad]
    mov edx, WM_GETTEXT
    mov r8, 64
    lea r9, [bufCantidad]
    call SendMessageA

    ; 3. Construir texto para el MessageBox (Pantalla)
    lea rdi, [bufMensaje]
    lea rsi, [szMsgFmt1]
    call CopiarCadena
    lea rsi, [bufCodigo]
    call CopiarCadena
    lea rsi, [szMsgFmt2]
    call CopiarCadena
    lea rsi, [bufCantidad]
    call CopiarCadena
    mov byte [rdi], 0

    ; 4. Construir linea de texto para el archivo TXT (Base de datos)
    lea rdi, [bufArchivo]
    lea rsi, [szTxtFmt1]
    call CopiarCadena
    lea rsi, [bufCodigo]
    call CopiarCadena
    lea rsi, [szTxtFmt2]
    call CopiarCadena
    lea rsi, [bufCantidad]
    call CopiarCadena
    lea rsi, [szTxtNuevaLin]
    call CopiarCadena
    mov byte [rdi], 0          ; Termina la cadena

    ; Calcular la longitud exacta de la cadena para el archivo
    lea rax, [bufArchivo]
    sub rdi, rax              ; RDI tiene la direccion actual del final, restamos el inicio
    mov r12, rdi              ; Guardamos la longitud en R12 (registro seguro)

    ; 5. PERSISTENCIA: Guardar en el Archivo usando WinAPI
    ; Abrir o crear el archivo "ventas.txt"
    lea rcx, [szNombreArchivo]
    mov edx, GENERIC_WRITE
    mov r8d, FILE_SHARE_READ
    xor r9, r9
    mov dword [rsp+0x20], OPEN_ALWAYS
    mov dword [rsp+0x28], FILE_ATTRIBUTE_NORMAL
    mov qword [rsp+0x30], 0
    call CreateFileA
    
    mov r13, rax              ; Guardamos el HANDLE del archivo en R13
    cmp rax, -1               ; INVALID_HANDLE_VALUE
    je .mostrar_box

    ; Mover el puntero del archivo al final (para hacer Append / no borrar lo viejo)
    mov rcx, r13
    xor edx, edx              ; 0 bytes de desplazamiento relativo
    xor r8, r8                ; No usar puntero de 64 bits alto
    mov r9d, FILE_END         ; Mover desde el final
    call SetFilePointer

    ; Escribir la linea en el archivo
    mov rcx, r13              ; Handle
    lea rdx, [bufArchivo]     ; Datos
    mov r8d, r12d             ; Longitud de la cadena
    lea r9, [bytesEscritos]   ; Variable receptora obligatoria
    mov qword [rsp+0x20], 0   ; lpOverlapped = NULL
    call WriteFile

    ; Cerrar el archivo
    mov rcx, r13
    call CloseHandle

.mostrar_box:
    ; 6. Mostrar el MessageBox clásico
    xor ecx, ecx
    lea rdx, [bufMensaje]
    lea r8, [szMsgTitulo]
    xor r9d, r9d
    call MessageBoxA

    add rsp, 0x38
    ret

; ----------------------------------------------------------------
; CopiarCadena
; ----------------------------------------------------------------
CopiarCadena:
    push rax
.bucle:
    mov al, [rsi]
    test al, al
    jz .fin
    mov [rdi], al
    inc rsi
    inc rdi
    jmp .bucle
.fin:
    pop rax
    ret; ================================================================
;   VENTANA "VENTA"  -  NASM x64 + GoLink + WinAPI  (para RadASM)
; ================================================================
;   Campos: "Codigo:" (editable), "Cantidad:" (editable)
;   Boton:  "Guardar" -> Muestra los datos Y LOS GUARDA EN UN TXT
; ================================================================

; ---------------- Constantes WinAPI ----------------
%define WS_OVERLAPPEDWINDOW   0x00CF0000
%define WS_VISIBLE            0x10000000
%define WS_CHILD              0x40000000
%define WS_BORDER             0x00800000
%define WS_TABSTOP            0x00010000
%define ES_AUTOHSCROLL        0x0080
%define CW_USEDEFAULT         0x80000000
%define SW_SHOWNORMAL         1
%define WM_CREATE             0x0001
%define WM_DESTROY            0x0002
%define WM_CLOSE              0x0010
%define WM_COMMAND            0x0111
%define WM_GETTEXT            0x000D
%define BN_CLICKED            0
%define IDI_APPLICATION       32512
%define IDC_ARROW             32512
%define WHITE_BRUSH           0

; Constantes para manejo de archivos
%define GENERIC_WRITE         0x40000000
%define FILE_SHARE_READ       1
%define OPEN_ALWAYS           4
%define FILE_ATTRIBUTE_NORMAL 0x80
%define FILE_END              2

%define ID_EDIT_CODIGO    1001
%define ID_EDIT_CANTIDAD  1002
%define ID_BTN_GUARDAR    1003

; ---------------- Estructuras ----------------
struc WNDCLASSEX
    .cbSize          resd 1
    .style           resd 1
    .lpfnWndProc     resq 1
    .cbClsExtra      resd 1
    .cbWndExtra      resd 1
    .hInstance       resq 1
    .hIcon           resq 1
    .hCursor         resq 1
    .hbrBackground   resq 1
    .lpszMenuName    resq 1
    .lpszClassName   resq 1
    .hIconSm         resq 1
endstruc

struc MSGSTRUCT
    .hwnd      resq 1
    .message   resd 1
    .pad1      resd 1
    .wParam    resq 1
    .lParam    resq 1
    .time      resd 1
    .ptX       resd 1
    .ptY       resd 1
    .pad2      resd 1
endstruc

; ---------------- Macro de creacion ----------------
%macro CREATEWND 10
    sub rsp, 0x60
    mov qword [rsp+0x40], %9      
    mov qword [rsp+0x48], %10     
    mov dword [rsp+0x20], %5      
    mov dword [rsp+0x28], %6      
    mov dword [rsp+0x30], %7      
    mov dword [rsp+0x38], %8      
    mov rax, [g_hInstance]
    mov qword [rsp+0x50], rax     
    mov qword [rsp+0x58], 0       
    mov ecx, %1                   
    lea rdx, [%2]                 
    %ifidn %3, 0
        xor r8, r8                
    %else
        lea r8, [%3]              
    %endif
    mov r9d, %4                   
    call CreateWindowExA
    add rsp, 0x60
%endmacro

; ================================================================
section .data
; ================================================================
    szClassName    db 'VentanaVenta',0
    szTitle        db 'Venta',0
    szClassButton  db 'BUTTON',0
    szClassEdit    db 'EDIT',0
    szClassStatic  db 'STATIC',0
    szLblCodigo    db 'Codigo:',0
    szLblCantidad  db 'Cantidad:',0
    szBtnGuardar   db 'Guardar',0
    szMsgTitulo    db 'Datos guardados',0
    
    ; Formatos para construir las cadenas
    szMsgFmt1      db 'Codigo: ',0
    szMsgFmt2      db 13,10,'Cantidad: ',0
    
    ; Formato limpio para escribir en la base de datos (Archivo TXT)
    szTxtFmt1      db 'Codigo: ',0
    szTxtFmt2      db ' | Cantidad: ',0
    szTxtNuevaLin  db 13,10,0 ; Salto de linea para el bloc de notas
    
    ; Nombre del archivo de base de datos
    szNombreArchivo db 'ventas.txt',0

; ================================================================
section .bss
; ================================================================
    g_hInstance        resq 1
    g_hwndMain         resq 1
    g_hwndEditCodigo   resq 1
    g_hwndEditCantidad resq 1

    g_curHwnd          resq 1
    g_curMsg           resq 1
    g_curWParam        resq 1
    g_curLParam        resq 1

    g_wc   resb 80          
    g_msg  resb 48          

    bufCodigo   resb 64
    bufCantidad resb 64
    bufMensaje  resb 200
    bufArchivo  resb 256  ; Buffer para armar la linea del archivo
    
    bytesEscritos resd 1   ; Variable necesaria para WriteFile

; ================================================================
section .text
; ================================================================

extern GetModuleHandleA
extern ExitProcess
extern RegisterClassExA
extern CreateWindowExA
extern ShowWindow
extern UpdateWindow
extern GetMessageA
extern TranslateMessage
extern DispatchMessageA
extern DefWindowProcA
extern PostQuitMessage
extern DestroyWindow
extern LoadCursorA
extern LoadIconA
extern GetStockObject
extern MessageBoxA
extern SendMessageA

; Funciones del sistema para manejo de archivos (Kernel32)
extern CreateFileA
extern SetFilePointer
extern WriteFile
extern CloseHandle

global start

start:
    and rsp, -16          
    sub rsp, 0x20          

    xor ecx, ecx
    call GetModuleHandleA
    mov [g_hInstance], rax

    ; -------- Registrar la clase --------
    mov dword [g_wc + WNDCLASSEX.cbSize], 80
    mov dword [g_wc + WNDCLASSEX.style], 0
    lea rax, [WndProc]
    mov [g_wc + WNDCLASSEX.lpfnWndProc], rax
    mov dword [g_wc + WNDCLASSEX.cbClsExtra], 0
    mov dword [g_wc + WNDCLASSEX.cbWndExtra], 0
    mov rax, [g_hInstance]
    mov [g_wc + WNDCLASSEX.hInstance], rax

    xor ecx, ecx
    mov edx, IDI_APPLICATION
    call LoadIconA
    mov [g_wc + WNDCLASSEX.hIcon], rax
    mov [g_wc + WNDCLASSEX.hIconSm], rax

    xor ecx, ecx
    mov edx, IDC_ARROW
    call LoadCursorA
    mov [g_wc + WNDCLASSEX.hCursor], rax

    mov ecx, WHITE_BRUSH
    call GetStockObject
    mov [g_wc + WNDCLASSEX.hbrBackground], rax

    mov qword [g_wc + WNDCLASSEX.lpszMenuName], 0
    lea rax, [szClassName]
    mov [g_wc + WNDCLASSEX.lpszClassName], rax

    lea rcx, [g_wc]
    call RegisterClassExA

    ; -------- Crear ventana principal --------
    CREATEWND 0, szClassName, szTitle, WS_OVERLAPPEDWINDOW|WS_VISIBLE, CW_USEDEFAULT, CW_USEDEFAULT, 320, 230, 0, 0
    mov [g_hwndMain], rax

    mov rcx, rax
    mov edx, SW_SHOWNORMAL
    call ShowWindow
    mov rcx, [g_hwndMain]
    call UpdateWindow

.msgloop:
    lea rcx, [g_msg]
    xor edx, edx
    xor r8, r8
    xor r9, r9
    call GetMessageA
    test eax, eax
    jz .fin
    lea rcx, [g_msg]
    call TranslateMessage
    lea rcx, [g_msg]
    call DispatchMessageA
    jmp .msgloop

.fin:
    mov ecx, dword [g_msg + MSGSTRUCT.wParam]
    call ExitProcess

; ----------------------------------------------------------------
; WndProc
; ----------------------------------------------------------------
WndProc:
    sub rsp, 0x28
    mov [g_curHwnd], rcx
    mov [g_curMsg], rdx
    mov [g_curWParam], r8
    mov [g_curLParam], r9

    mov eax, dword [g_curMsg]
    cmp eax, WM_CREATE
    je .onCreate
    cmp eax, WM_COMMAND
    je .onCommand
    cmp eax, WM_CLOSE
    je .onClose
    cmp eax, WM_DESTROY
    je .onDestroy
    jmp .default

.onCreate:
    CREATEWND 0, szClassStatic, szLblCodigo, WS_CHILD|WS_VISIBLE, 20,22,80,20, qword [g_curHwnd], 0
    CREATEWND 0, szClassEdit, 0, WS_CHILD|WS_VISIBLE|WS_BORDER|WS_TABSTOP|ES_AUTOHSCROLL, 110,20,150,22, qword [g_curHwnd], ID_EDIT_CODIGO
    mov [g_hwndEditCodigo], rax

    CREATEWND 0, szClassStatic, szLblCantidad, WS_CHILD|WS_VISIBLE, 20,62,80,20, qword [g_curHwnd], 0
    CREATEWND 0, szClassEdit, 0, WS_CHILD|WS_VISIBLE|WS_BORDER|WS_TABSTOP|ES_AUTOHSCROLL, 110,60,150,22, qword [g_curHwnd], ID_EDIT_CANTIDAD
    mov [g_hwndEditCantidad], rax

    CREATEWND 0, szClassButton, szBtnGuardar, WS_CHILD|WS_VISIBLE|WS_TABSTOP, 110,110,110,32, qword [g_curHwnd], ID_BTN_GUARDAR

    xor eax, eax
    jmp .salir

.onCommand:
    mov rax, [g_curWParam]
    movzx ecx, ax              
    cmp ecx, ID_BTN_GUARDAR
    jne .default
    mov rax, [g_curWParam]
    shr eax, 16                 
    cmp eax, BN_CLICKED
    jne .default
    call GuardarDatos
    xor eax, eax
    jmp .salir

.onClose:
    mov rcx, [g_curHwnd]
    call DestroyWindow
    xor eax, eax
    jmp .salir

.onDestroy:
    xor ecx, ecx
    call PostQuitMessage
    xor eax, eax
    jmp .salir

.default:
    mov rcx, [g_curHwnd]
    mov rdx, [g_curMsg]
    mov r8,  [g_curWParam]
    mov r9,  [g_curLParam]
    call DefWindowProcA
    jmp .salir

.salir:
    add rsp, 0x28
    ret

; ----------------------------------------------------------------
; GuardarDatos - LEE, MUESTRA MENSAJE Y ESCRIBE EN archivo .txt
; ----------------------------------------------------------------
GuardarDatos:
    sub rsp, 0x38             ; Espacio para sombra y variables locales

    ; 1. Leer texto de "Codigo"
    mov rcx, [g_hwndEditCodigo]
    mov edx, WM_GETTEXT
    mov r8, 64
    lea r9, [bufCodigo]
    call SendMessageA

    ; 2. Leer texto de "Cantidad"
    mov rcx, [g_hwndEditCantidad]
    mov edx, WM_GETTEXT
    mov r8, 64
    lea r9, [bufCantidad]
    call SendMessageA

    ; 3. Construir texto para el MessageBox (Pantalla)
    lea rdi, [bufMensaje]
    lea rsi, [szMsgFmt1]
    call CopiarCadena
    lea rsi, [bufCodigo]
    call CopiarCadena
    lea rsi, [szMsgFmt2]
    call CopiarCadena
    lea rsi, [bufCantidad]
    call CopiarCadena
    mov byte [rdi], 0

    ; 4. Construir linea de texto para el archivo TXT (Base de datos)
    lea rdi, [bufArchivo]
    lea rsi, [szTxtFmt1]
    call CopiarCadena
    lea rsi, [bufCodigo]
    call CopiarCadena
    lea rsi, [szTxtFmt2]
    call CopiarCadena
    lea rsi, [bufCantidad]
    call CopiarCadena
    lea rsi, [szTxtNuevaLin]
    call CopiarCadena
    mov byte [rdi], 0          ; Termina la cadena

    ; Calcular la longitud exacta de la cadena para el archivo
    lea rax, [bufArchivo]
    sub rdi, rax              ; RDI tiene la direccion actual del final, restamos el inicio
    mov r12, rdi              ; Guardamos la longitud en R12 (registro seguro)

    ; 5. PERSISTENCIA: Guardar en el Archivo usando WinAPI
    ; Abrir o crear el archivo "ventas.txt"
    lea rcx, [szNombreArchivo]
    mov edx, GENERIC_WRITE
    mov r8d, FILE_SHARE_READ
    xor r9, r9
    mov dword [rsp+0x20], OPEN_ALWAYS
    mov dword [rsp+0x28], FILE_ATTRIBUTE_NORMAL
    mov qword [rsp+0x30], 0
    call CreateFileA
    
    mov r13, rax              ; Guardamos el HANDLE del archivo en R13
    cmp rax, -1               ; INVALID_HANDLE_VALUE
    je .mostrar_box

    ; Mover el puntero del archivo al final (para hacer Append / no borrar lo viejo)
    mov rcx, r13
    xor edx, edx              ; 0 bytes de desplazamiento relativo
    xor r8, r8                ; No usar puntero de 64 bits alto
    mov r9d, FILE_END         ; Mover desde el final
    call SetFilePointer

    ; Escribir la linea en el archivo
    mov rcx, r13              ; Handle
    lea rdx, [bufArchivo]     ; Datos
    mov r8d, r12d             ; Longitud de la cadena
    lea r9, [bytesEscritos]   ; Variable receptora obligatoria
    mov qword [rsp+0x20], 0   ; lpOverlapped = NULL
    call WriteFile

    ; Cerrar el archivo
    mov rcx, r13
    call CloseHandle

.mostrar_box:
    ; 6. Mostrar el MessageBox clásico
    xor ecx, ecx
    lea rdx, [bufMensaje]
    lea r8, [szMsgTitulo]
    xor r9d, r9d
    call MessageBoxA

    add rsp, 0x38
    ret

; ----------------------------------------------------------------
; CopiarCadena
; ----------------------------------------------------------------
CopiarCadena:
    push rax
.bucle:
    mov al, [rsi]
    test al, al
    jz .fin
    mov [rdi], al
    inc rsi
    inc rdi
    jmp .bucle
.fin:
    pop rax
    ret; ================================================================
;   VENTANA "VENTA"  -  NASM x64 + GoLink + WinAPI  (para RadASM)
; ================================================================
;   Campos: "Codigo:" (editable), "Cantidad:" (editable)
;   Boton:  "Guardar" -> Muestra los datos Y LOS GUARDA EN UN TXT
; ================================================================

; ---------------- Constantes WinAPI ----------------
%define WS_OVERLAPPEDWINDOW   0x00CF0000
%define WS_VISIBLE            0x10000000
%define WS_CHILD              0x40000000
%define WS_BORDER             0x00800000
%define WS_TABSTOP            0x00010000
%define ES_AUTOHSCROLL        0x0080
%define CW_USEDEFAULT         0x80000000
%define SW_SHOWNORMAL         1
%define WM_CREATE             0x0001
%define WM_DESTROY            0x0002
%define WM_CLOSE              0x0010
%define WM_COMMAND            0x0111
%define WM_GETTEXT            0x000D
%define BN_CLICKED            0
%define IDI_APPLICATION       32512
%define IDC_ARROW             32512
%define WHITE_BRUSH           0

; Constantes para manejo de archivos
%define GENERIC_WRITE         0x40000000
%define FILE_SHARE_READ       1
%define OPEN_ALWAYS           4
%define FILE_ATTRIBUTE_NORMAL 0x80
%define FILE_END              2

%define ID_EDIT_CODIGO    1001
%define ID_EDIT_CANTIDAD  1002
%define ID_BTN_GUARDAR    1003

; ---------------- Estructuras ----------------
struc WNDCLASSEX
    .cbSize          resd 1
    .style           resd 1
    .lpfnWndProc     resq 1
    .cbClsExtra      resd 1
    .cbWndExtra      resd 1
    .hInstance       resq 1
    .hIcon           resq 1
    .hCursor         resq 1
    .hbrBackground   resq 1
    .lpszMenuName    resq 1
    .lpszClassName   resq 1
    .hIconSm         resq 1
endstruc

struc MSGSTRUCT
    .hwnd      resq 1
    .message   resd 1
    .pad1      resd 1
    .wParam    resq 1
    .lParam    resq 1
    .time      resd 1
    .ptX       resd 1
    .ptY       resd 1
    .pad2      resd 1
endstruc

; ---------------- Macro de creacion ----------------
%macro CREATEWND 10
    sub rsp, 0x60
    mov qword [rsp+0x40], %9      
    mov qword [rsp+0x48], %10     
    mov dword [rsp+0x20], %5      
    mov dword [rsp+0x28], %6      
    mov dword [rsp+0x30], %7      
    mov dword [rsp+0x38], %8      
    mov rax, [g_hInstance]
    mov qword [rsp+0x50], rax     
    mov qword [rsp+0x58], 0       
    mov ecx, %1                   
    lea rdx, [%2]                 
    %ifidn %3, 0
        xor r8, r8                
    %else
        lea r8, [%3]              
    %endif
    mov r9d, %4                   
    call CreateWindowExA
    add rsp, 0x60
%endmacro

; ================================================================
section .data
; ================================================================
    szClassName    db 'VentanaVenta',0
    szTitle        db 'Venta',0
    szClassButton  db 'BUTTON',0
    szClassEdit    db 'EDIT',0
    szClassStatic  db 'STATIC',0
    szLblCodigo    db 'Codigo:',0
    szLblCantidad  db 'Cantidad:',0
    szBtnGuardar   db 'Guardar',0
    szMsgTitulo    db 'Datos guardados',0
    
    ; Formatos para construir las cadenas
    szMsgFmt1      db 'Codigo: ',0
    szMsgFmt2      db 13,10,'Cantidad: ',0
    
    ; Formato limpio para escribir en la base de datos (Archivo TXT)
    szTxtFmt1      db 'Codigo: ',0
    szTxtFmt2      db ' | Cantidad: ',0
    szTxtNuevaLin  db 13,10,0 ; Salto de linea para el bloc de notas
    
    ; Nombre del archivo de base de datos
    szNombreArchivo db 'ventas.txt',0

; ================================================================
section .bss
; ================================================================
    g_hInstance        resq 1
    g_hwndMain         resq 1
    g_hwndEditCodigo   resq 1
    g_hwndEditCantidad resq 1

    g_curHwnd          resq 1
    g_curMsg           resq 1
    g_curWParam        resq 1
    g_curLParam        resq 1

    g_wc   resb 80          
    g_msg  resb 48          

    bufCodigo   resb 64
    bufCantidad resb 64
    bufMensaje  resb 200
    bufArchivo  resb 256  ; Buffer para armar la linea del archivo
    
    bytesEscritos resd 1   ; Variable necesaria para WriteFile

; ================================================================
section .text
; ================================================================

extern GetModuleHandleA
extern ExitProcess
extern RegisterClassExA
extern CreateWindowExA
extern ShowWindow
extern UpdateWindow
extern GetMessageA
extern TranslateMessage
extern DispatchMessageA
extern DefWindowProcA
extern PostQuitMessage
extern DestroyWindow
extern LoadCursorA
extern LoadIconA
extern GetStockObject
extern MessageBoxA
extern SendMessageA

; Funciones del sistema para manejo de archivos (Kernel32)
extern CreateFileA
extern SetFilePointer
extern WriteFile
extern CloseHandle

global start

start:
    and rsp, -16          
    sub rsp, 0x20          

    xor ecx, ecx
    call GetModuleHandleA
    mov [g_hInstance], rax

    ; -------- Registrar la clase --------
    mov dword [g_wc + WNDCLASSEX.cbSize], 80
    mov dword [g_wc + WNDCLASSEX.style], 0
    lea rax, [WndProc]
    mov [g_wc + WNDCLASSEX.lpfnWndProc], rax
    mov dword [g_wc + WNDCLASSEX.cbClsExtra], 0
    mov dword [g_wc + WNDCLASSEX.cbWndExtra], 0
    mov rax, [g_hInstance]
    mov [g_wc + WNDCLASSEX.hInstance], rax

    xor ecx, ecx
    mov edx, IDI_APPLICATION
    call LoadIconA
    mov [g_wc + WNDCLASSEX.hIcon], rax
    mov [g_wc + WNDCLASSEX.hIconSm], rax

    xor ecx, ecx
    mov edx, IDC_ARROW
    call LoadCursorA
    mov [g_wc + WNDCLASSEX.hCursor], rax

    mov ecx, WHITE_BRUSH
    call GetStockObject
    mov [g_wc + WNDCLASSEX.hbrBackground], rax

    mov qword [g_wc + WNDCLASSEX.lpszMenuName], 0
    lea rax, [szClassName]
    mov [g_wc + WNDCLASSEX.lpszClassName], rax

    lea rcx, [g_wc]
    call RegisterClassExA

    ; -------- Crear ventana principal --------
    CREATEWND 0, szClassName, szTitle, WS_OVERLAPPEDWINDOW|WS_VISIBLE, CW_USEDEFAULT, CW_USEDEFAULT, 320, 230, 0, 0
    mov [g_hwndMain], rax

    mov rcx, rax
    mov edx, SW_SHOWNORMAL
    call ShowWindow
    mov rcx, [g_hwndMain]
    call UpdateWindow

.msgloop:
    lea rcx, [g_msg]
    xor edx, edx
    xor r8, r8
    xor r9, r9
    call GetMessageA
    test eax, eax
    jz .fin
    lea rcx, [g_msg]
    call TranslateMessage
    lea rcx, [g_msg]
    call DispatchMessageA
    jmp .msgloop

.fin:
    mov ecx, dword [g_msg + MSGSTRUCT.wParam]
    call ExitProcess

; ----------------------------------------------------------------
; WndProc
; ----------------------------------------------------------------
WndProc:
    sub rsp, 0x28
    mov [g_curHwnd], rcx
    mov [g_curMsg], rdx
    mov [g_curWParam], r8
    mov [g_curLParam], r9

    mov eax, dword [g_curMsg]
    cmp eax, WM_CREATE
    je .onCreate
    cmp eax, WM_COMMAND
    je .onCommand
    cmp eax, WM_CLOSE
    je .onClose
    cmp eax, WM_DESTROY
    je .onDestroy
    jmp .default

.onCreate:
    CREATEWND 0, szClassStatic, szLblCodigo, WS_CHILD|WS_VISIBLE, 20,22,80,20, qword [g_curHwnd], 0
    CREATEWND 0, szClassEdit, 0, WS_CHILD|WS_VISIBLE|WS_BORDER|WS_TABSTOP|ES_AUTOHSCROLL, 110,20,150,22, qword [g_curHwnd], ID_EDIT_CODIGO
    mov [g_hwndEditCodigo], rax

    CREATEWND 0, szClassStatic, szLblCantidad, WS_CHILD|WS_VISIBLE, 20,62,80,20, qword [g_curHwnd], 0
    CREATEWND 0, szClassEdit, 0, WS_CHILD|WS_VISIBLE|WS_BORDER|WS_TABSTOP|ES_AUTOHSCROLL, 110,60,150,22, qword [g_curHwnd], ID_EDIT_CANTIDAD
    mov [g_hwndEditCantidad], rax

    CREATEWND 0, szClassButton, szBtnGuardar, WS_CHILD|WS_VISIBLE|WS_TABSTOP, 110,110,110,32, qword [g_curHwnd], ID_BTN_GUARDAR

    xor eax, eax
    jmp .salir

.onCommand:
    mov rax, [g_curWParam]
    movzx ecx, ax              
    cmp ecx, ID_BTN_GUARDAR
    jne .default
    mov rax, [g_curWParam]
    shr eax, 16                 
    cmp eax, BN_CLICKED
    jne .default
    call GuardarDatos
    xor eax, eax
    jmp .salir

.onClose:
    mov rcx, [g_curHwnd]
    call DestroyWindow
    xor eax, eax
    jmp .salir

.onDestroy:
    xor ecx, ecx
    call PostQuitMessage
    xor eax, eax
    jmp .salir

.default:
    mov rcx, [g_curHwnd]
    mov rdx, [g_curMsg]
    mov r8,  [g_curWParam]
    mov r9,  [g_curLParam]
    call DefWindowProcA
    jmp .salir

.salir:
    add rsp, 0x28
    ret

; ----------------------------------------------------------------
; GuardarDatos - LEE, MUESTRA MENSAJE Y ESCRIBE EN archivo .txt
; ----------------------------------------------------------------
GuardarDatos:
    sub rsp, 0x38             ; Espacio para sombra y variables locales

    ; 1. Leer texto de "Codigo"
    mov rcx, [g_hwndEditCodigo]
    mov edx, WM_GETTEXT
    mov r8, 64
    lea r9, [bufCodigo]
    call SendMessageA

    ; 2. Leer texto de "Cantidad"
    mov rcx, [g_hwndEditCantidad]
    mov edx, WM_GETTEXT
    mov r8, 64
    lea r9, [bufCantidad]
    call SendMessageA

    ; 3. Construir texto para el MessageBox (Pantalla)
    lea rdi, [bufMensaje]
    lea rsi, [szMsgFmt1]
    call CopiarCadena
    lea rsi, [bufCodigo]
    call CopiarCadena
    lea rsi, [szMsgFmt2]
    call CopiarCadena
    lea rsi, [bufCantidad]
    call CopiarCadena
    mov byte [rdi], 0

    ; 4. Construir linea de texto para el archivo TXT (Base de datos)
    lea rdi, [bufArchivo]
    lea rsi, [szTxtFmt1]
    call CopiarCadena
    lea rsi, [bufCodigo]
    call CopiarCadena
    lea rsi, [szTxtFmt2]
    call CopiarCadena
    lea rsi, [bufCantidad]
    call CopiarCadena
    lea rsi, [szTxtNuevaLin]
    call CopiarCadena
    mov byte [rdi], 0          ; Termina la cadena

    ; Calcular la longitud exacta de la cadena para el archivo
    lea rax, [bufArchivo]
    sub rdi, rax              ; RDI tiene la direccion actual del final, restamos el inicio
    mov r12, rdi              ; Guardamos la longitud en R12 (registro seguro)

    ; 5. PERSISTENCIA: Guardar en el Archivo usando WinAPI
    ; Abrir o crear el archivo "ventas.txt"
    lea rcx, [szNombreArchivo]
    mov edx, GENERIC_WRITE
    mov r8d, FILE_SHARE_READ
    xor r9, r9
    mov dword [rsp+0x20], OPEN_ALWAYS
    mov dword [rsp+0x28], FILE_ATTRIBUTE_NORMAL
    mov qword [rsp+0x30], 0
    call CreateFileA
    
    mov r13, rax              ; Guardamos el HANDLE del archivo en R13
    cmp rax, -1               ; INVALID_HANDLE_VALUE
    je .mostrar_box

    ; Mover el puntero del archivo al final (para hacer Append / no borrar lo viejo)
    mov rcx, r13
    xor edx, edx              ; 0 bytes de desplazamiento relativo
    xor r8, r8                ; No usar puntero de 64 bits alto
    mov r9d, FILE_END         ; Mover desde el final
    call SetFilePointer

    ; Escribir la linea en el archivo
    mov rcx, r13              ; Handle
    lea rdx, [bufArchivo]     ; Datos
    mov r8d, r12d             ; Longitud de la cadena
    lea r9, [bytesEscritos]   ; Variable receptora obligatoria
    mov qword [rsp+0x20], 0   ; lpOverlapped = NULL
    call WriteFile

    ; Cerrar el archivo
    mov rcx, r13
    call CloseHandle

.mostrar_box:
    ; 6. Mostrar el MessageBox clásico
    xor ecx, ecx
    lea rdx, [bufMensaje]
    lea r8, [szMsgTitulo]
    xor r9d, r9d
    call MessageBoxA

    add rsp, 0x38
    ret

; ----------------------------------------------------------------
; CopiarCadena
; ----------------------------------------------------------------
CopiarCadena:
    push rax
.bucle:
    mov al, [rsi]
    test al, al
    jz .fin
    mov [rdi], al
    inc rsi
    inc rdi
    jmp .bucle
.fin:
    pop rax
    ret
    ;, 3011    lea  r8,  [rel szVacio]    call SetDlgItemTextA    pop  r15    pop  r14    add  rsp, 50h    pop  rbp    xor  rax, rax    ret_V_ErrorCampos:    mov  rcx, r14    lea  rdx, [rel msgCampos]    lea  r8,  [rel tituloErr]    mov  r9,  0    call MessageBoxA    pop  r15    pop  r14    add  rsp, 50h    pop  rbp    xor  rax, rax    ret_V_ErrorStock:    mov  rcx, r14    lea  rdx, [rel msgSinStock]    lea  r8,  [rel tituloErr]    mov  r9,  0    call MessageBoxA    pop  r15    pop  r14    add  rsp, 50h    pop  rbp    xor  rax, rax    ret; ============================================================; Boton Limpiar - limpia la lista y resetea total sesion; ============================================================_V_BtnLimpiar:    add  rsp, 30h    pop  rbp    push rbp    mov  rbp, rsp    sub  rsp, 30h    mov  qword [rel totalAcum], 0    mov  rcx, [rel var_hwndV]    mov  rdx, 5010    mov  r8,  LB_RESETCONTENT    xor  r9,  r9    mov  qword [rsp+20h], 0    call SendDlgItemMessageA    call _V_ActualizarTotal    add  rsp, 30h    pop  rbp    xor  rax, rax    ret; ============================================================; Boton Confirmar Venta; ============================================================_V_BtnConfirmar:    add  rsp, 30h    pop  rbp    push rbp    mov  rbp, rsp    sub  rsp, 30h    mov  rcx, [rel var_hwndV]    lea  rdx, [rel msgVentaConf]    lea  r8,  [rel tituloOK]    mov  r9,  0    call MessageBoxA    ; limpiar lista y resetear total    mov  qword [rel totalAcum], 0    mov  rcx, [rel var_hwndV]    mov  rdx, 5010    mov  r8,  LB_RESETCONTENT    xor  r9,  r9    mov  qword [rsp+20h], 0    call SendDlgItemMessageA    call _V_ActualizarTotal    add  rsp, 30h    pop  rbp    xor  rax, rax    ret; ============================================================; _V_ActualizarTotal - actualiza el label 7001; ============================================================_V_ActualizarTotal:    push rbp    mov  rbp, rsp    sub  rsp, 30h    mov  rax, [rel totalAcum]    xor  rdx, rdx    mov  rcx, 100    div  rcx    lea  rcx, [rel bufTotalStr]    lea  rdx, [rel fmtTotal]    mov  r8,  rax    mov  r9,  rdx    call wsprintfA    mov  rcx, [rel var_hwndV]    mov  rdx, 7001    lea  r8,  [rel bufTotalStr]    call SetDlgItemTextA    add  rsp, 30h    pop  rbp    ret; ============================================================_V_BtnCerrar:    mov  rcx, [rel hBrushFondoV]    call DeleteObject    mov  rcx, [rel var_hwndV]    xor  rdx, rdx    call EndDialog    mov  rax, 1    jmp  _V_FinProc_V_OnInitDialog:    mov  ecx, [rel colorCremaV]    call CreateSolidBrush    mov  [rel hBrushFondoV], rax    mov  qword [rel totalAcum], 0    call _V_ActualizarTotal    mov  rax, 1    jmp  _V_FinProc_V_OnCtlColorDlg:    mov  rax, [rel hBrushFondoV]    jmp  _V_FinProc_V_OnCtlColorStatic:    mov  rcx, [rel var_wparamV]    mov  edx, 1    call SetBkMode    mov  rax, [rel hBrushFondoV]    jmp  _V_FinProc_V_OnClose:    mov  rcx, [rel hBrushFondoV]    call DeleteObject    mov  rcx, [rel var_hwndV]    xor  rdx, rdx    call EndDialog    mov  rax, 1    jmp  _V_FinProc_V_FinProc:    add  rsp, 30h    pop  rbp    ret; ============================================================; _AtoI  rcx=string  rax=entero; ============================================================_AtoI:    push rsi    mov  rsi, rcx    xor  rax, rax.loop:    movzx ecx, byte [rsi]    test  ecx, ecx    jz    .fin    sub   ecx, '0'    imul  rax, 10    add   rax, rcx    inc   rsi    jmp   .loop.fin:    pop  rsi    ret