@echo off
setlocal EnableDelayedExpansion
title BISHE AI Studio - Permanent Service Installer
color 0B

echo ======================================================================
echo    BISHE Car Wash and Auto Care Service - AI Studio Service Installer
echo    Location: Bishoftu (Debre Zeyit), Oromia, Ethiopia
echo ======================================================================
echo.

:: 1. Detect Python and pythonw.exe
set "PYTHON_EXE="
set "PYTHONW_EXE="

if exist "C:\Users\Tare\AppData\Local\Programs\Python\Python312\pythonw.exe" (
    set "PYTHONW_EXE=C:\Users\Tare\AppData\Local\Programs\Python\Python312\pythonw.exe"
    set "PYTHON_EXE=C:\Users\Tare\AppData\Local\Programs\Python\Python312\python.exe"
) else (
    for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python3*") do (
        if exist "%%D\pythonw.exe" (
            set "PYTHONW_EXE=%%D\pythonw.exe"
            set "PYTHON_EXE=%%D\python.exe"
        )
    )
)

if "%PYTHONW_EXE%"=="" (
    for /f "delims=" %%I in ('where pythonw.exe 2^>nul') do set "PYTHONW_EXE=%%I"
)
if "%PYTHON_EXE%"=="" (
    for /f "delims=" %%I in ('where python.exe 2^>nul') do set "PYTHON_EXE=%%I"
)

if "%PYTHONW_EXE%"=="" (
    echo [ERROR] pythonw.exe not found! Please ensure Python 3.10+ is installed.
    pause
    exit /b 1
)

echo [OK] Found Python Background Runner: %PYTHONW_EXE%
echo [OK] Workspace Directory: %~dp0

:: 2. Terminate any previous instance on port 5050
echo [*] Checking for active processes on port 5050...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :5050 ^| findstr LISTENING 2^>nul') do (
    echo [*] Stopping previous instance PID %%a
    taskkill /f /pid %%a >nul 2>&1
)

:: 3. Create Silent Windows Startup VBScript
set "STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "STARTUP_VBS=%STARTUP_DIR%\BisheAiStudio.vbs"
set "AGENT_SCRIPT=%~dp0agent\bishe_agent.py"

echo [*] Creating permanent Windows Startup background launcher...
(
    echo Set WshShell = CreateObject("WScript.Shell"^)
    echo WshShell.Run """%PYTHONW_EXE%"" ""%AGENT_SCRIPT%"" --web --no-browser --port 5050", 0, False
) > "%STARTUP_VBS%"

echo [OK] Registered in Windows Startup:
echo      %STARTUP_VBS%

:: 4. Create Desktop Shortcut for easy access
set "DESKTOP_URL=%USERPROFILE%\Desktop\Bishe AI Studio.url"
echo [*] Creating Desktop Shortcut...
(
    echo [InternetShortcut]
    echo URL=http://127.0.0.1:5050
    echo IconFile=C:\Windows\System32\shell32.dll
    echo IconIndex=14
) > "%DESKTOP_URL%"
echo [OK] Desktop shortcut created: %DESKTOP_URL%

:: 5. Launch the silent background service right now
echo [*] Launching BISHE AI Studio in the background...
wscript.exe "%STARTUP_VBS%"

:: Wait 2 seconds for server startup
ping 127.0.0.1 -n 3 >nul

:: 6. Open Studio in default browser
echo [*] Opening BISHE AI Studio in your browser...
start http://127.0.0.1:5050

echo.
echo ======================================================================
echo    [SUCCESS] BISHE AI STUDIO IS PERMANENTLY INSTALLED AND RUNNING!
echo ======================================================================
echo   * Status:            Running 24/7 silently in the background (Port 5050)
echo   * URL:               http://127.0.0.1:5050
echo   * Desktop Shortcut:  "Bishe AI Studio" icon on your Desktop
echo   * Windows Startup:   Starts automatically every time your laptop boots
echo   * Live Updates:      Simply refresh (F5) anytime to pull latest Supabase data
echo   * Zero Hassle:       No terminal windows, no double-clicking batch files!
echo ======================================================================
echo.
pause
