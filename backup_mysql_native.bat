@echo off
:: MySQL Backup Script - Native Windows (No Python required)
:: Improved version with .env support and better error handling

setlocal enabledelayedexpansion

:: Default configuration (can be overridden by .env file)
set DB_HOST=localhost
set DB_PORT=3306
set DB_USER=root
set DB_PASSWORD=
set DB_NAME=
set BACKUP_DIR=.\backups
set RETENTION_DAYS=7
set COMPRESSION=false
set MYSQL_PATH_WIN=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe
set LOG_FILE=backup.log

:: Load .env file if exists
if exist ".env" (
    echo Loading configuration from .env file...
    for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
        set "line=%%a"
        if not "!line:~0,1!"=="#" if not "!line!"=="" (
            set "%%a=%%b"
        )
    )
) else (
    echo Warning: .env file not found, using default configuration
)

:: Validate required configuration
if "%DB_PASSWORD%"=="" (
    echo [ERROR] DB_PASSWORD is required
    echo Please set DB_PASSWORD in .env file
    pause
    exit /b 1
)

if "%DB_NAME%"=="" (
    echo [ERROR] DB_NAME is required
    echo Please set DB_NAME in .env file
    pause
    exit /b 1
)

:: Check if MySQL dump exists
if not exist "%MYSQL_PATH_WIN%" (
    echo [ERROR] MySQL dump not found at: %MYSQL_PATH_WIN%
    echo Please verify MYSQL_PATH_WIN in .env file
    pause
    exit /b 1
)

:: Create backup directory if it doesn't exist
if not exist "%BACKUP_DIR%" (
    mkdir "%BACKUP_DIR%"
    if !ERRORLEVEL! neq 0 (
        echo [ERROR] Cannot create backup directory: %BACKUP_DIR%
        pause
        exit /b 1
    )
)

:: Generate timestamp (compatible method)
powershell -command "Get-Date -Format 'yyyy-MM-dd_HH-mm'" > temp_timestamp.txt 2>nul
if exist temp_timestamp.txt (
    set /p timestamp=<temp_timestamp.txt
    del temp_timestamp.txt
) else (
    :: Fallback to simple date/time if PowerShell fails
    set "timestamp=%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%-%time:~3,2%"
    set "timestamp=%timestamp: =0%"
)

:: Generate backup filename
set "backup_file=%BACKUP_DIR%\backup_%DB_NAME%_%timestamp%.sql"

:: Log function
set "log_msg=echo [%date% %time%]"

:: Start backup process
%log_msg% Starting backup of database: %DB_NAME% >> "%LOG_FILE%"
echo Starting backup of database: %DB_NAME%

:: Build and execute mysqldump command
set "dump_cmd="%MYSQL_PATH_WIN%" --host=%DB_HOST% --port=%DB_PORT% --user=%DB_USER% --password=%DB_PASSWORD% --single-transaction --routines --triggers %DB_NAME%"

%dump_cmd% > "%backup_file%" 2>backup_error.tmp

if %ERRORLEVEL% equ 0 (
    %log_msg% Backup completed successfully: %backup_file% >> "%LOG_FILE%"
    echo [SUCCESS] Backup completed: %backup_file%
    
    :: Compress if enabled
    if /i "%COMPRESSION%"=="true" (
        echo Compressing backup...
        powershell -command "Compress-Archive -Path '%backup_file%' -DestinationPath '%backup_file%.zip'" 2>nul
        if !ERRORLEVEL! equ 0 (
            del "%backup_file%"
            set "backup_file=%backup_file%.zip"
            %log_msg% Backup compressed: !backup_file! >> "%LOG_FILE%"
            echo [SUCCESS] Backup compressed
        ) else (
            echo [WARN] Compression failed, keeping uncompressed backup
        )
    )
) else (
    %log_msg% Backup failed for %DB_NAME% >> "%LOG_FILE%"
    echo [ERROR] Backup failed. Error details:
    type backup_error.tmp
    type backup_error.tmp >> "%LOG_FILE%"
    del backup_error.tmp 2>nul
    pause
    exit /b 1
)

:: Cleanup old backups
echo Cleaning up old backups (older than %RETENTION_DAYS% days)...
%log_msg% Starting cleanup of backups older than %RETENTION_DAYS% days >> "%LOG_FILE%"

forfiles /p "%BACKUP_DIR%" /s /m backup_*.sql* /d -%RETENTION_DAYS% /c "cmd /c echo Deleting @path && del @path" 2>nul
if %ERRORLEVEL% equ 0 (
    %log_msg% Cleanup completed >> "%LOG_FILE%"
    echo [SUCCESS] Old backups cleaned up
) else (
    %log_msg% No old backups to clean up >> "%LOG_FILE%"
    echo [INFO] No old backups found to clean up
)

:: Cleanup temporary files
del backup_error.tmp 2>nul

%log_msg% Backup process completed >> "%LOG_FILE%"
echo [SUCCESS] Backup process completed successfully

:: Uncomment to pause after execution
:: pause