@echo off
echo ========================================================
echo   Stopping BISHE Car Wash + Umami Analytics Stack
echo ========================================================
cd /d "%~dp0"
docker compose down
echo.
echo All containers stopped.
pause
