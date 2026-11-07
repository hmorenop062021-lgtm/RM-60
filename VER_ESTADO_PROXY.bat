@echo off
title Estado del Proxy Balanza RM-60
cd /d "%~dp0"
echo ================================================================
echo        ESTADO DEL DEMONIO PROXY BALANZA RM-60
echo ================================================================
echo.
tasklist /FI "IMAGENAME eq pythonw.exe" 2>NUL | find /I "pythonw.exe" >NUL
if %errorlevel% equ 0 (
    echo [ESTADO] PROXY ACTIVO Y CORRIENDO EN SEGUNDO PLANO.
) else (
    echo [ESTADO] EL PROXY NO ESTA EN EJECUCION.
)
echo.
echo Ultimos registros de escaneo (proxy.log):
echo ----------------------------------------------------------------
if exist "%~dp0proxy.log" (
    powershell -Command "Get-Content '%~dp0proxy.log' -Tail 15" 2>NUL || type "%~dp0proxy.log"
) else (
    echo Aun no hay registros en proxy.log
)
echo ----------------------------------------------------------------
echo.
pause
