@echo off
echo 200 ICON "mi_icono.ico" > Recursos.Rc
echo. >> Recursos.Rc
echo 1000 DIALOG 0, 0, 280, 190 >> Recursos.Rc
echo CAPTION "SIV - Sistema de Inventario y Ventas" >> Recursos.Rc
echo FONT 9, "Courier New" >> Recursos.Rc
echo BEGIN >> Recursos.Rc
echo     LTEXT "Bienvenido a SIV :)", -1, 120, 10, 150, 10 >> Recursos.Rc
echo     PUSHBUTTON "</Gestion Productos>", 1001, 10, 30, 95, 32 >> Recursos.Rc
echo     PUSHBUTTON "</Realizar Venta>", 1002, 10, 72, 95, 32 >> Recursos.Rc
echo     PUSHBUTTON "</Consultar Inventario>", 1003, 10, 114, 95, 32 >> Recursos.Rc
echo     PUSHBUTTON "</Reportes>", 1005, 10, 156, 95, 32 >> Recursos.Rc
echo END >> Recursos.Rc
echo. >> Recursos.Rc
echo 2004 DIALOG 0, 0, 240, 120 >> Recursos.Rc
echo CAPTION "Gestion de Productos" >> Recursos.Rc
echo FONT 9, "Courier New" >> Recursos.Rc
echo BEGIN >> Recursos.Rc
echo     LTEXT "Codigo:", -1, 15, 12, 45, 10 >> Recursos.Rc
echo     EDITTEXT 3001, 70, 10, 140, 12 >> Recursos.Rc
echo     LTEXT "Nombre:", -1, 15, 30, 45, 10 >> Recursos.Rc
echo     EDITTEXT 3002, 70, 28, 140, 12 >> Recursos.Rc
echo     LTEXT "Precio:", -1, 15, 48, 45, 10 >> Recursos.Rc
echo     EDITTEXT 3003, 70, 46, 60, 12 >> Recursos.Rc
echo     LTEXT "Stock:", -1, 15, 66, 45, 10 >> Recursos.Rc
echo     EDITTEXT 3004, 70, 64, 60, 12 >> Recursos.Rc
echo     PUSHBUTTON "Guardar Producto", 4001, 40, 90, 85, 16 >> Recursos.Rc
echo     PUSHBUTTON "Cerrar", 9001, 155, 90, 55, 16 >> Recursos.Rc
echo END >> Recursos.Rc
echo. >> Recursos.Rc
echo 2001 DIALOG 0, 0, 260, 200 >> Recursos.Rc
echo CAPTION "Realizar Venta" >> Recursos.Rc
echo FONT 9, "Courier New" >> Recursos.Rc
echo BEGIN >> Recursos.Rc
echo     LTEXT "Codigo:", -1, 15, 12, 45, 10 >> Recursos.Rc
echo     EDITTEXT 3010, 70, 10, 100, 12 >> Recursos.Rc
echo     LTEXT "Cantidad:", -1, 15, 30, 45, 10 >> Recursos.Rc
echo     EDITTEXT 3011, 70, 28, 60, 12 >> Recursos.Rc
echo     PUSHBUTTON "Agregar", 2001, 180, 10, 55, 14 >> Recursos.Rc
echo     PUSHBUTTON "Limpiar", 2002, 180, 28, 55, 14 >> Recursos.Rc
echo     LISTBOX 5010, 10, 50, 240, 100, LBS_NOTIFY >> Recursos.Rc
echo     LTEXT "Total: Bs. 0.00", 7001, 10, 158, 140, 10 >> Recursos.Rc
echo     PUSHBUTTON "Confirmar Venta", 2003, 10, 175, 90, 16 >> Recursos.Rc
echo     PUSHBUTTON "Cerrar", 9001, 190, 175, 55, 16 >> Recursos.Rc
echo END >> Recursos.Rc
echo. >> Recursos.Rc
echo 2002 DIALOG 0, 0, 260, 160 >> Recursos.Rc
echo CAPTION "Consultar Inventario" >> Recursos.Rc
echo FONT 9, "Courier New" >> Recursos.Rc
echo BEGIN >> Recursos.Rc
echo     LTEXT "Nombre                Precio    Stock", -1, 10, 8, 240, 10 >> Recursos.Rc
echo     LISTBOX 5001, 10, 20, 240, 110, LBS_NOTIFY >> Recursos.Rc
echo     PUSHBUTTON "Cerrar", 9001, 100, 138, 55, 16 >> Recursos.Rc
echo END >> Recursos.Rc
echo. >> Recursos.Rc
echo 2003 DIALOG 0, 0, 260, 160 >> Recursos.Rc
echo CAPTION "Reportes de Ventas" >> Recursos.Rc
echo FONT 9, "Courier New" >> Recursos.Rc
echo BEGIN >> Recursos.Rc
echo     LTEXT "Nombre             Cantidad   Total", -1, 10, 8, 240, 10 >> Recursos.Rc
echo     LISTBOX 6001, 10, 20, 240, 100, LBS_NOTIFY >> Recursos.Rc
echo     LTEXT "Total General: Bs. 0.00", 7002, 10, 128, 180, 10 >> Recursos.Rc
echo     PUSHBUTTON "Cerrar", 9001, 100, 138, 55, 16 >> Recursos.Rc
echo END >> Recursos.Rc
echo.
echo Recursos.Rc creado correctamente.
pause