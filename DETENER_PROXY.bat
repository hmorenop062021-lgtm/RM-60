@echo off
title Detener Proxy Balanza RM-60
echo ================================================================
echo         DETENIENDO DEMONIO PROXY BALANZA RM-60
echo ================================================================
echo.
taskkill /F /IM pythonw.exe >NUL 2>&1
taskkill /F /IM python.exe >NUL 2>&1
echo [OK] Proceso detenido con exito.
echo.
pause
