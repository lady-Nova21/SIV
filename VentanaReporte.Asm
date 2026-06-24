bits 64
global MostrarVentanaReportes

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
    hBrushFondoR     dq 0
    colorCremaR      dd 00F0FFFFh
    archivoVentasR   db "ventas.txt", 0
    msgVacioR        db "(Sin ventas guardadas)", 0

section .bss
    hInstanceR       resq 1
    hWndRep          resq 1
    var_hwndRep      resq 1
    var_msgRep       resd 1
    var_wparamRep    resq 1
    var_lparamRep    resq 1
    msgR             resb 48
    hArchivoR        resq 1
    bufArchivoR      resb 4096
    bytesLeidosR     resd 1
    bufLineaR        resb 256

section .text

MostrarVentanaReportes:
    push rbp
    mov  rbp, rsp
    sub  rsp, 40h

    xor  ecx, ecx
    call GetModuleHandleA
    mov  [rel hInstanceR], rax

    mov  rcx, [rel hInstanceR]
    mov  rdx, 2003
    xor  r8,  r8
    lea  r9,  [rel DlgProcReportes]
    mov  qword [rsp+20h], 0
    call CreateDialogParamA
    mov  [rel hWndRep], rax

    mov  rcx, [rel hWndRep]
    mov  rdx, SW_SHOW
    call ShowWindow

_LoopRep:
    lea  rcx, [rel msgR]
    xor  rdx, rdx
    xor  r8,  r8
    xor  r9,  r9
    call GetMessageA
    test rax, rax
    jz   _SalirRep

    mov  rcx, [rel hWndRep]
    lea  rdx, [rel msgR]
    call IsDialogMessageA
    test rax, rax
    jnz  _LoopRep

    lea  rcx, [rel msgR]
    call TranslateMessage
    lea  rcx, [rel msgR]
    call DispatchMessageA
    jmp  _LoopRep

_SalirRep:
    add  rsp, 40h
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
    sub  rsp, 40h

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

_R_OnInitDialog:
    mov  ecx, [rel colorCremaR]
    call CreateSolidBrush
    mov  [rel hBrushFondoR], rax

    mov  rcx, [rel var_hwndRep]
    mov  rdx, 6002
    mov  r8,  LB_RESETCONTENT
    xor  r9,  r9
    mov  qword [rsp+20h], 0
    call SendDlgItemMessageA

    lea  rcx, [rel archivoVentasR]
    mov  edx, GENERIC_READ
    mov  r8d, FILE_SHARE_READ
    xor  r9,  r9
    mov  qword [rsp+20h], OPEN_EXISTING
    mov  qword [rsp+28h], FILE_ATTRIBUTE_NORMAL
    mov  qword [rsp+30h], 0
    call CreateFileA
    mov  [rel hArchivoR], rax

    cmp  rax, INVALID_HANDLE
    je   _R_ArchivoVacio

    mov  rcx, [rel hArchivoR]
    lea  rdx, [rel bufArchivoR]
    mov  r8d, 4090
    lea  r9,  [rel bytesLeidosR]
    mov  qword [rsp+20h], 0
    call ReadFile

    mov  rcx, [rel hArchivoR]
    call CloseHandle

    lea  rsi, [rel bufArchivoR]
    lea  rdi, [rel bufLineaR]
    xor  rcx, rcx

_R_ParseLoop:
    movzx eax, byte [rsi]
    test  al, al
    jz    _R_FlushLinea
    cmp   al, 10
    je    _R_FlushLinea
    cmp   al, 13
    je    _R_SkipChar
    mov   [rdi + rcx], al
    inc   rcx
    inc   rsi
    jmp   _R_ParseLoop

_R_FlushLinea:
    test  rcx, rcx
    jz    _R_SkipChar
    mov   byte [rdi + rcx], 0
    push  rsi
    push  rdi
    push  rcx
    mov   rcx, [rel var_hwndRep]
    mov   rdx, 6002
    mov   r8,  LB_ADDSTRING
    xor   r9,  r9
    lea   rax, [rel bufLineaR]
    mov   [rsp+20h+18h], rax
    call  SendDlgItemMessageA
    pop   rcx
    pop   rdi
    pop   rsi
    xor   rcx, rcx
    lea   rdi, [rel bufLineaR]

_R_SkipChar:
    inc   rsi
    movzx eax, byte [rsi]
    test  al, al
    jnz   _R_ParseLoop
    jmp   _R_Fin_Init

_R_ArchivoVacio:
    mov  rcx, [rel var_hwndRep]
    mov  rdx, 6002
    mov  r8,  LB_ADDSTRING
    xor  r9,  r9
    lea  rax, [rel msgVacioR]
    mov  [rsp+20h], rax
    call SendDlgItemMessageA

_R_Fin_Init:
    mov  rax, 1
    jmp  _R_Fin

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
    add  rsp, 40h
    pop  rbp
    ret
