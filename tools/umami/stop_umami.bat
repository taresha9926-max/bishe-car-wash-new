@echo off
echo ========================================================
echo   Stopping Umami Analytics Container for BISHE Station
echo ========================================================
cd /d "%~dp0"
docker compose down
echo.
echo Umami containers stopped.
pause
