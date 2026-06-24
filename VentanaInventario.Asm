bits 64
global MostrarVentanaInventario

extern CreateSolidBrush
extern DeleteObject
extern CreateDialogParamA
extern ShowWindow
extern GetMessageA
extern IsDialogMessageA
extern TranslateMessage
extern DispatchMessageA
extern GetModuleHandleA
extern SetBkMode
extern EndDialog
extern CreateFileA
extern ReadFile
extern CloseHandle
extern SendDlgItemMessageA

GENERIC_READ        equ 80000000h
OPEN_EXISTING       equ 3
FILE_SHARE_READ     equ 1
FILE_ATTRIBUTE_NORMAL equ 80h
LB_ADDSTRING        equ 0180h
LB_RESETCONTENT     equ 0184h
INVALID_HANDLE      equ -1
SW_SHOW             equ 5

section .data
    hBrushFondoI     dq 0
    colorCremaI      dd 00F0FFFFh
    archivoProdI     db "productos.txt", 0
    msgVacioI        db "(Sin productos guardados)", 0

section .bss
    hInstanceI       resq 1
    hWndInv          resq 1
    var_hwndInv      resq 1
    var_msgInv       resd 1
    var_wparamInv    resq 1
    var_lparamInv    resq 1
    msgI             resb 48
    hArchivoI        resq 1
    bufArchivoI      resb 4096
    bytesLeidosI     resd 1
    bufLineaI        resb 256

section .text

MostrarVentanaInventario:
    push rbp
    mov  rbp, rsp
    sub  rsp, 40h

    xor  ecx, ecx
    call GetModuleHandleA
    mov  [rel hInstanceI], rax

    ; Crear dialogo no modal
    mov  rcx, [rel hInstanceI]
    mov  rdx, 2002
    xor  r8,  r8
    lea  r9,  [rel DlgProcInventario]
    mov  qword [rsp+20h], 0
    call CreateDialogParamA
    mov  [rel hWndInv], rax

    ; Mostrar ventana
    mov  rcx, [rel hWndInv]
    mov  rdx, SW_SHOW
    call ShowWindow

    ; Loop de mensajes propio
_LoopInv:
    lea  rcx, [rel msgI]
    xor  rdx, rdx
    xor  r8,  r8
    xor  r9,  r9
    call GetMessageA
    test rax, rax
    jz   _SalirInv

    mov  rcx, [rel hWndInv]
    lea  rdx, [rel msgI]
    call IsDialogMessageA
    test rax, rax
    jnz  _LoopInv

    lea  rcx, [rel msgI]
    call TranslateMessage
    lea  rcx, [rel msgI]
    call DispatchMessageA
    jmp  _LoopInv

_SalirInv:
    add  rsp, 40h
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
    sub  rsp, 40h

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

_I_OnInitDialog:
    mov  ecx, [rel colorCremaI]
    call CreateSolidBrush
    mov  [rel hBrushFondoI], rax

    ; limpiar ListBox
    mov  rcx, [rel var_hwndInv]
    mov  rdx, 6001
    mov  r8,  LB_RESETCONTENT
    xor  r9,  r9
    mov  qword [rsp+20h], 0
    call SendDlgItemMessageA

    ; abrir productos.txt
    lea  rcx, [rel archivoProdI]
    mov  edx, GENERIC_READ
    mov  r8d, FILE_SHARE_READ
    xor  r9,  r9
    mov  qword [rsp+20h], OPEN_EXISTING
    mov  qword [rsp+28h], FILE_ATTRIBUTE_NORMAL
    mov  qword [rsp+30h], 0
    call CreateFileA
    mov  [rel hArchivoI], rax

    cmp  rax, INVALID_HANDLE
    je   _I_ArchivoVacio

    mov  rcx, [rel hArchivoI]
    lea  rdx, [rel bufArchivoI]
    mov  r8d, 4090
    lea  r9,  [rel bytesLeidosI]
    mov  qword [rsp+20h], 0
    call ReadFile

    mov  rcx, [rel hArchivoI]
    call CloseHandle

    ; parsear lineas
    lea  rsi, [rel bufArchivoI]
    lea  rdi, [rel bufLineaI]
    xor  rcx, rcx

_I_ParseLoop:
    movzx eax, byte [rsi]
    test  al, al
    jz    _I_FlushLinea
    cmp   al, 10
    je    _I_FlushLinea
    cmp   al, 13
    je    _I_SkipChar
    mov   [rdi + rcx], al
    inc   rcx
    inc   rsi
    jmp   _I_ParseLoop

_I_FlushLinea:
    test  rcx, rcx
    jz    _I_SkipChar
    mov   byte [rdi + rcx], 0
    push  rsi
    push  rdi
    push  rcx
    mov   rcx, [rel var_hwndInv]
    mov   rdx, 6001
    mov   r8,  LB_ADDSTRING
    xor   r9,  r9
    lea   rax, [rel bufLineaI]
    mov   [rsp+20h+18h], rax
    call  SendDlgItemMessageA
    pop   rcx
    pop   rdi
    pop   rsi
    xor   rcx, rcx
    lea   rdi, [rel bufLineaI]

_I_SkipChar:
    inc   rsi
    movzx eax, byte [rsi]
    test  al, al
    jnz   _I_ParseLoop
    jmp   _I_Fin_Init

_I_ArchivoVacio:
    mov  rcx, [rel var_hwndInv]
    mov  rdx, 6001
    mov  r8,  LB_ADDSTRING
    xor  r9,  r9
    lea  rax, [rel msgVacioI]
    mov  [rsp+20h], rax
    call SendDlgItemMessageA

_I_Fin_Init:
    mov  rax, 1
    jmp  _I_Fin

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
    add  rsp, 40h
    pop  rbp
    ret
