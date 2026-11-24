@echo off
echo ========================================================
echo   Starting Umami Analytics Container for BISHE Station
echo ========================================================
cd /d "%~dp0"
docker compose up -d
if %ERRORLEVEL% EQU 0 (
    echo.
    echo Umami Analytics is running!
    echo Dashboard: http://localhost:3000
    echo Default Login Credentials:
    echo   Username: admin
    echo   Password: umami
    echo.
    echo Opening dashboard in default browser...
    start http://localhost:3000
) else (
    echo.
    echo [ERROR] Failed to start Docker container.
    echo Please make sure Docker Desktop is open and running.
)
pause
