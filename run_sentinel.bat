@echo off
title BISHE SUPER AI SENTINEL -- DEVELOPER MASTER COCKPIT
color 0B
cd /d "%~dp0"
set "PATH=C:\Users\Tare\AppData\Local\Programs\Python\Python312;C:\Users\Tare\AppData\Local\Programs\Python\Python312\Scripts;%PATH%"

echo ====================================================================
echo    BISHE CAR WASH -- SUPER AI SENTINEL DEVELOPER COCKPIT
echo    Bishoftu (Debre Zeyit), Oromia * Ground Truth Forensic Daemon
echo ====================================================================
echo Starting Sentinel Daemon & Local Web Studio on http://127.0.0.1:8088
echo Opening browser and Master Developer Terminal...
echo.

python -u sentinel\sentinel_daemon.py --cli
pause
