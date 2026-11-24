@echo off
echo ========================================================
echo   Starting BISHE Car Wash + Umami Analytics Stack
echo ========================================================
cd /d "%~dp0"
docker compose up -d --build
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo   All Services are Live!
    echo   - BISHE Car Wash App: http://localhost:8080
    echo   - Umami Analytics:    http://localhost:3000
    echo   - Umami DB:           localhost:5432
    echo ========================================================
    echo.
    echo Opening BISHE Car Wash App in default browser...
    start http://localhost:8080
) else (
    echo.
    echo [ERROR] Failed to start Docker stack.
    echo Please make sure Docker Desktop is running.
)
pause
