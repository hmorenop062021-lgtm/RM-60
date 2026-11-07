@echo off
setlocal enabledelayedexpansion

title Generando EXE - Proxy Balanza RM-60

echo ========================================
echo   CREANDO .EXE AUTOINSTALABLE
echo ========================================
echo.

:: Verificar Python
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Python no esta instalado o no esta en el PATH.
    echo         Instala Python 3.8 o superior.
    pause
    exit /b 1
)

:: Instalar PyInstaller si no esta presente
echo [1/3] Verificando PyInstaller...
python -m pip show pyinstaller >nul 2>&1
if %errorLevel% neq 0 (
    echo Instalando PyInstaller...
    python -m pip install pyinstaller
    if %errorLevel% neq 0 (
        echo [ERROR] No se pudo instalar PyInstaller.
        pause
        exit /b 1
    )
)

:: Generar el .exe usando la configuracion proxy.spec
echo [2/3] Generando ProxyBalanzaRM60.exe...
pyinstaller --clean proxy.spec

if %errorLevel% neq 0 (
    echo [ERROR] PyInstaller fallo al compilar.
    pause
    exit /b 1
)

echo [3/3] Verificando resultado...
if exist "dist\ProxyBalanzaRM60.exe" (
    echo [OK] Ejecutable creado con exito: dist\ProxyBalanzaRM60.exe
) else (
    echo [ERROR] No se encontro el exe generado.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   LISTO
echo ========================================
echo.
echo El archivo dist\ProxyBalanzaRM60.exe es tu ejecutable standalone.
echo.
pause
