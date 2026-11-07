@echo off
setlocal enabledelayedexpansion

title Instalador Proxy Balanza RM-60

echo ========================================
echo   INSTALANDO PROXY BALANZA RM-60
echo   Destino: D:\BalanzaProxy
echo ========================================
echo.

:: Verificar administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Ejecuta como ADMINISTRADOR (clic derecho -> Ejecutar como administrador)
    pause
    exit /b 1
)

:: Verificar unidad D:
if not exist D:\ (
    echo [AVISO] No se detecto unidad D:. Se instalara en C:\BalanzaProxy
    set INSTALL_DIR=C:\BalanzaProxy
) else (
    set INSTALL_DIR=D:\BalanzaProxy
)

set SCRIPT_DIR=%~dp0

echo [1/5] Creando carpeta en %INSTALL_DIR%...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo [2/5] Copiando archivos del demonio...
if exist "%SCRIPT_DIR%ProxyBalanzaRM60.exe" (
    copy /Y "%SCRIPT_DIR%ProxyBalanzaRM60.exe" "%INSTALL_DIR%\" >nul
    echo   -> Copiado: ProxyBalanzaRM60.exe
) else if exist "%SCRIPT_DIR%dist\ProxyBalanzaRM60.exe" (
    copy /Y "%SCRIPT_DIR%dist\ProxyBalanzaRM60.exe" "%INSTALL_DIR%\" >nul
    echo   -> Copiado desde dist: ProxyBalanzaRM60.exe
)

if exist "%SCRIPT_DIR%balanza_proxy.py" (
    copy /Y "%SCRIPT_DIR%balanza_proxy.py" "%INSTALL_DIR%\" >nul
    echo   -> Copiado: balanza_proxy.py
)

if exist "%SCRIPT_DIR%config.json" (
    copy /Y "%SCRIPT_DIR%config.json" "%INSTALL_DIR%\" >nul
    echo   -> Copiado: config.json
)

echo [3/5] Creando script de arranque y acceso directo...
echo @echo off> "%INSTALL_DIR%\INICIAR_PROXY_BALANZA.bat"
echo title Proxy Balanza RM-60 - Eleventa>> "%INSTALL_DIR%\INICIAR_PROXY_BALANZA.bat"
echo cd /d "%INSTALL_DIR%">> "%INSTALL_DIR%\INICIAR_PROXY_BALANZA.bat"
if exist "%INSTALL_DIR%\ProxyBalanzaRM60.exe" (
    echo ProxyBalanzaRM60.exe>> "%INSTALL_DIR%\INICIAR_PROXY_BALANZA.bat"
) else (
    echo python balanza_proxy.py>> "%INSTALL_DIR%\INICIAR_PROXY_BALANZA.bat"
)

:: Crear acceso directo en el Escritorio
set DESKTOP_DIR=%USERPROFILE%\Desktop
if exist "%DESKTOP_DIR%" (
    copy /Y "%INSTALL_DIR%\INICIAR_PROXY_BALANZA.bat" "%DESKTOP_DIR%\" >nul 2>&1
)

echo [4/5] Verificando dependencias Python (si se usa modo script)...
if not exist "%INSTALL_DIR%\ProxyBalanzaRM60.exe" (
    python -m pip install pywin32 keyboard --quiet >nul 2>&1
)

echo [5/5] Creando tarea programada para autoinicio...
schtasks /Delete /TN "ProxyBalanzaRM60" /F >nul 2>&1

set XMLFILE=%TEMP%\ProxyBalanza.xml
echo ^<?xml version="1.0" encoding="UTF-16"?^> > "%XMLFILE%"
echo ^<Task version="1.1" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^> >> "%XMLFILE%"
echo   ^<RegistrationInfo^> >> "%XMLFILE%"
echo     ^<Date^>2026-11-07T00:00:00^</Date^> >> "%XMLFILE%"
echo     ^<Author^>BalanzaProxy^</Author^> >> "%XMLFILE%"
echo   ^</RegistrationInfo^> >> "%XMLFILE%"
echo   ^<Triggers^> >> "%XMLFILE%"
echo     ^<LogonTrigger^> >> "%XMLFILE%"
echo       ^<Enabled^>true^</Enabled^> >> "%XMLFILE%"
echo     ^</LogonTrigger^> >> "%XMLFILE%"
echo   ^</Triggers^> >> "%XMLFILE%"
echo   ^<Principals^> >> "%XMLFILE%"
echo     ^<Principal id="Author"^> >> "%XMLFILE%"
echo       ^<LogonType^>InteractiveToken^</LogonType^> >> "%XMLFILE%"
echo       ^<RunLevel^>HighestAvailable^</RunLevel^> >> "%XMLFILE%"
echo     ^</Principal^> >> "%XMLFILE%"
echo   ^</Principals^> >> "%XMLFILE%"
echo   ^<Settings^> >> "%XMLFILE%"
echo     ^<MultipleInstancesPolicy^>IgnoreNew^</MultipleInstancesPolicy^> >> "%XMLFILE%"
echo     ^<DisallowStartIfOnBatteries^>false^</DisallowStartIfOnBatteries^> >> "%XMLFILE%"
echo     ^<StopIfGoingOnBatteries^>false^</StopIfGoingOnBatteries^> >> "%XMLFILE%"
echo     ^<AllowHardTerminate^>true^</AllowHardTerminate^> >> "%XMLFILE%"
echo     ^<Enabled^>true^</Enabled^> >> "%XMLFILE%"
echo     ^<Hidden^>false^</Hidden^> >> "%XMLFILE%"
echo     ^<ExecutionTimeLimit^>PT0S^</ExecutionTimeLimit^> >> "%XMLFILE%"
echo   ^</Settings^> >> "%XMLFILE%"
echo   ^<Actions Context="Author"^> >> "%XMLFILE%"
echo     ^<Exec^> >> "%XMLFILE%"
echo       ^<Command^>"%INSTALL_DIR%\INICIAR_PROXY_BALANZA.bat"^</Command^> >> "%XMLFILE%"
echo       ^<WorkingDirectory^>"%INSTALL_DIR%"^</WorkingDirectory^> >> "%XMLFILE%"
echo     ^</Exec^> >> "%XMLFILE%"
echo   ^</Actions^> >> "%XMLFILE%"
echo ^</Task^> >> "%XMLFILE%"

schtasks /Create /TN "ProxyBalanzaRM60" /XML "%XMLFILE%" /F >nul 2>&1
del "%XMLFILE%" >nul 2>&1

echo.
echo ========================================
echo   INSTALACION COMPLETADA CON EXITO
echo ========================================
echo.
echo Destino: %INSTALL_DIR%
echo Tarea programada registrada: ProxyBalanzaRM60
echo.
echo Para probar el demonio ahora mismo, ejecuta:
echo   "%INSTALL_DIR%\INICIAR_PROXY_BALANZA.bat"
echo.
pause
