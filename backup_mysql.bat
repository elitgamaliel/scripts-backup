@echo off
:: --- 1. CONFIGURACIÓN DE RUTA (VERIFICA ESTO) ---
set MYSQL_PATH="C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe"
set CONFIG_FILE="D:\SempoiTI\config.ini"
set BACKUP_DIR=D:\Respaldo
set DB_NAME=healthy

:: --- CAPTURAR FECHA Y HORA ---
set FECHA=%date:~-10,2%-%date:~-7,2%-%date:~-4,4%
set HORA=%time:~0,2%
if "%HORA:~0,1%"==" " set HORA=0%HORA:~1,1%
set MINUTO=%time:~3,2%
set TIEMPO=%HORA%_%MINUTO%

:: Crear carpeta si no existe
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

echo Realizando respaldo silencioso de: %DB_NAME%...

:: --- EJECUCIÓN ---
:: Importante: --defaults-extra-file DEBE ser el primer argumento
%MYSQL_PATH% "--defaults-extra-file=%CONFIG_FILE%" %DB_NAME% > "%BACKUP_DIR%\backup_%DB_NAME%_%FECHA%_%TIEMPO%.sql"

if %ERRORLEVEL% equ 0 (
    echo [OK] Respaldo completado sin advertencias.
) else (
    echo [ERROR] Revisa la ruta del archivo .ini o los permisos.
)

:: Limpieza de archivos de mas de 7 dias
forfiles /p "%BACKUP_DIR%" /s /m *.sql /d -7 /c "cmd /c del @path" 2>nul

:: pause