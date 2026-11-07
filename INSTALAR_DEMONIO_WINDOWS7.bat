@echo off
setlocal enabledelayedexpansion
title Instalador Demonio Proxy Balanza RM-60 - Windows 7
echo ================================================================
echo      INSTALADOR DEL DEMONIO PROXY BALANZA RM-60
echo      Autoinicio permanente en segundo plano (Windows 7)
echo ================================================================
echo.
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Debes ejecutar este instalador como ADMINISTRADOR.
    echo         Haz clic derecho sobre este archivo y elige:
    echo         "Ejecutar como administrador"
    echo.
    pause
    exit /b 1
)

set SCRIPT_DIR=%~dp0
set TARGET_DIR=C:\BalanzaProxy

echo [1/5] Deteniendo versiones anteriores si existen...
taskkill /F /IM pythonw.exe >nul 2>&1
taskkill /F /IM python.exe >nul 2>&1

echo [2/5] Creando carpeta permanente en el disco local: %TARGET_DIR%...
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

echo [3/5] Copiando archivos del sistema...
if exist "%SCRIPT_DIR%BalanzaProxy\balanza_proxy.py" (
    copy /Y "%SCRIPT_DIR%BalanzaProxy\balanza_proxy.py" "%TARGET_DIR%\" >nul
    copy /Y "%SCRIPT_DIR%BalanzaProxy\config.json" "%TARGET_DIR%\" >nul
    copy /Y "%SCRIPT_DIR%BalanzaProxy\INICIAR_SILENCIOSO.vbs" "%TARGET_DIR%\" >nul
    copy /Y "%SCRIPT_DIR%BalanzaProxy\INICIAR_PROXY_BALANZA.bat" "%TARGET_DIR%\" >nul
    copy /Y "%SCRIPT_DIR%BalanzaProxy\VER_ESTADO_PROXY.bat" "%TARGET_DIR%\" >nul
    copy /Y "%SCRIPT_DIR%BalanzaProxy\DETENER_PROXY.bat" "%TARGET_DIR%\" >nul
    if exist "%SCRIPT_DIR%BalanzaProxy\runtime" (
        xcopy /E /I /Y "%SCRIPT_DIR%BalanzaProxy\runtime" "%TARGET_DIR%\runtime" >nul
    )
) else (
    copy /Y "%SCRIPT_DIR%balanza_proxy.py" "%TARGET_DIR%\" >nul
    copy /Y "%SCRIPT_DIR%config.json" "%TARGET_DIR%\" >nul
    copy /Y "%SCRIPT_DIR%INICIAR_SILENCIOSO.vbs" "%TARGET_DIR%\" >nul
    copy /Y "%SCRIPT_DIR%INICIAR_PROXY_BALANZA.bat" "%TARGET_DIR%\" >nul
    copy /Y "%SCRIPT_DIR%VER_ESTADO_PROXY.bat" "%TARGET_DIR%\" >nul
    copy /Y "%SCRIPT_DIR%DETENER_PROXY.bat" "%TARGET_DIR%\" >nul
    if exist "%SCRIPT_DIR%runtime" (
        xcopy /E /I /Y "%SCRIPT_DIR%runtime" "%TARGET_DIR%\runtime" >nul
    )
)

echo [4/5] Creando accesos directos en el Escritorio...
set DESKTOP_DIR=%USERPROFILE%\Desktop
if exist "%DESKTOP_DIR%" (
    copy /Y "%TARGET_DIR%\VER_ESTADO_PROXY.bat" "%DESKTOP_DIR%\" >nul 2>&1
    copy /Y "%TARGET_DIR%\DETENER_PROXY.bat" "%DESKTOP_DIR%\" >nul 2>&1
)

echo [5/5] Registrando servicio/tarea de autoinicio permanente...
schtasks /Delete /TN "BalanzaProxyDaemon" /F >nul 2>&1
schtasks /Create /TN "BalanzaProxyDaemon" /TR "wscript.exe \"%TARGET_DIR%\INICIAR_SILENCIOSO.vbs\"" /SC ONLOGON /RL HIGHEST /F >nul

echo Iniciando el demonio ahora mismo...
schtasks /Run /TN "BalanzaProxyDaemon" >nul 2>&1

echo.
echo ================================================================
echo           INSTALACION COMPLETADA CON EXITO
echo ================================================================
echo.
echo - El demonio ya quedo instalado en: %TARGET_DIR%
echo - Se ejecutara automaticamente cada vez que enciendas Windows 7.
echo - Funciona 100% en segundo plano sin ventanas molestas.
echo - Ya puedes retirar el pendrive con seguridad; el sistema quedo
echo   grabado en el disco local de la PC.
echo.
echo Para verificar el estado o ver los escaneos en vivo, usa el acceso:
echo   'VER_ESTADO_PROXY.bat' en tu Escritorio.
echo.
pause
