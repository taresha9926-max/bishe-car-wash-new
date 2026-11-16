@echo off
title BISHE AI Studio - Service Uninstaller
color 0C

echo ======================================================================
echo    BISHE Car Wash and Auto Care Service - AI Studio Service Uninstaller
echo ======================================================================
echo.

:: 1. Terminate any active process on port 5050
echo [*] Stopping running background processes on port 5050...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :5050 ^| findstr LISTENING 2^>nul') do (
    echo [*] Terminated PID %%a
    taskkill /f /pid %%a >nul 2>&1
)

:: 2. Remove Windows Startup VBScript
set "STARTUP_VBS=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\BisheAiStudio.vbs"
if exist "%STARTUP_VBS%" (
    del /f /q "%STARTUP_VBS%"
    echo [OK] Removed from Windows Startup: %STARTUP_VBS%
) else (
    echo [*] No Windows Startup file found.
)

:: 3. Remove Desktop Shortcut
set "DESKTOP_URL=%USERPROFILE%\Desktop\Bishe AI Studio.url"
if exist "%DESKTOP_URL%" (
    del /f /q "%DESKTOP_URL%"
    echo [OK] Removed Desktop Shortcut: %DESKTOP_URL%
)

echo.
echo ======================================================================
echo    [SUCCESS] BISHE AI Studio service has been completely uninstalled.
echo ======================================================================
echo.
pause
