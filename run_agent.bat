@echo off
title BISHE AI Executive Studio
color 0B
cd /d "%~dp0"
set "PATH=C:\Users\Tare\AppData\Local\Programs\Python\Python312;C:\Users\Tare\AppData\Local\Programs\Python\Python312\Scripts;%PATH%"

echo ====================================================================
echo    BISHE CAR WASH -- EXECUTIVE AI OPERATIONS STUDIO (APP VIEW)
echo    Bishoftu (Debre Zeyit), Oromia * Live Database Connected
echo ====================================================================
echo Starting local application server...
echo Your web dashboard will open in your browser at http://127.0.0.1:5050
echo (Keep this window open while using the Studio)
echo.

python -u agent\bishe_agent.py --web
pause
