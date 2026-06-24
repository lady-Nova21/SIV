@echo off
setlocal

set NASM=C:\NASM\Bin\nasmw.exe
set GORC=C:\NASM\Bin\Gorc\GoRC.exe
set GOLINK=C:\Users\Admin\Desktop\Proyecto_TBN\GoLink\GoLink.exe

echo Compilando recursos...
%GORC% /r Recursos.Rc
if errorlevel 1 goto ERROR

echo Compilando Persistencia...
%NASM% -fwin64 -o Persistencia.obj Persistencia.Asm
if errorlevel 1 goto ERROR

echo Compilando VentanaPrincipal...
%NASM% -fwin64 -o VentanaPrincipal.obj VentanaPrincipal.Asm
if errorlevel 1 goto ERROR

echo Compilando VentanaVentas...
%NASM% -fwin64 -o VentanaVentas.obj VentanaVentas.Asm
if errorlevel 1 goto ERROR

echo Compilando VentanaInventario...
%NASM% -fwin64 -o VentanaInventario.obj VentanaInventario.Asm
if errorlevel 1 goto ERROR

echo Compilando VentanaReporte...
%NASM% -fwin64 -o VentanaReporte.obj VentanaReporte.Asm
if errorlevel 1 goto ERROR

echo Compilando VentanaProductos...
%NASM% -fwin64 -o VentanaProductos.obj VentanaProductos.Asm
if errorlevel 1 goto ERROR

echo Enlazando...
%GOLINK% /entry:Start /fo SIV.exe ^
    VentanaPrincipal.obj ^
    Persistencia.obj ^
    VentanaVentas.obj ^
    VentanaInventario.obj ^
    VentanaReporte.obj ^
    VentanaProductos.obj ^
    Recursos.res ^
    kernel32.dll user32.dll gdi32.dll

if errorlevel 1 goto ERROR

echo.
echo ============================================================
echo  Compilacion exitosa! Ejecuta SIV.exe
echo ============================================================
goto FIN

:ERROR
echo.
echo ERROR en la compilacion. Revisa los mensajes arriba.

:FIN
pause
