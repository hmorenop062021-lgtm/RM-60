@echo off
title Desinstalador Demonio Proxy Balanza RM-60
echo ================================================================
echo       DESINSTALANDO DEMONIO PROXY BALANZA RM-60
echo ================================================================
echo.
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Debes ejecutar como ADMINISTRADOR.
    pause
    exit /b 1
)

echo [1/3] Deteniendo procesos del demonio...
taskkill /F /IM pythonw.exe >nul 2>&1
taskkill /F /IM python.exe >nul 2>&1

echo [2/3] Eliminando autoinicio de Windows...
schtasks /Delete /TN "BalanzaProxyDaemon" /F >nul 2>&1

echo [3/3] Eliminando archivos de C:\BalanzaProxy...
if exist "C:\BalanzaProxy" rd /s /q "C:\BalanzaProxy"
set DESKTOP_DIR=%USERPROFILE%\Desktop
if exist "%DESKTOP_DIR%\VER_ESTADO_PROXY.bat" del /f /q "%DESKTOP_DIR%\VER_ESTADO_PROXY.bat"
if exist "%DESKTOP_DIR%\DETENER_PROXY.bat" del /f /q "%DESKTOP_DIR%\DETENER_PROXY.bat"

echo.
echo ================================================================
echo              DESINSTALACION COMPLETADA
echo ================================================================
echo.
pause
