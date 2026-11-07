@echo off
setlocal enabledelayedexpansion

title Desinstalador Proxy Balanza RM-60

echo ========================================
echo   DESINSTALANDO PROXY BALANZA RM-60
echo ========================================
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Ejecuta como ADMINISTRADOR.
    pause
    exit /b 1
)

echo [1/3] Eliminando tarea programada ProxyBalanzaRM60...
schtasks /Delete /TN "ProxyBalanzaRM60" /F >nul 2>&1

echo [2/3] Deteniendo procesos del proxy en ejecucion...
taskkill /F /IM ProxyBalanzaRM60.exe >nul 2>&1

echo [3/3] Eliminando carpetas instaladas...
if exist "D:\BalanzaProxy" rd /s /q "D:\BalanzaProxy"
if exist "C:\BalanzaProxy" rd /s /q "C:\BalanzaProxy"

echo.
echo ========================================
echo   DESINSTALACION COMPLETADA
echo ========================================
echo.
pause
