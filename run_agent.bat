@echo off
title BISHE AI Executive Studio
color 0B
set "PATH=C:\Users\Tare\AppData\Local\Programs\Python\Python312;C:\Users\Tare\AppData\Local\Programs\Python\Python312\Scripts;%PATH%"
echo ====================================================================
echo    BISHE CAR WASH — EXECUTIVE AI OPERATIONS STUDIO (APP VIEW)
echo    Bishoftu (Debre Zeyit), Oromia • Live Database Connected
echo ====================================================================
echo Starting local application server...
echo Your web dashboard will open in your browser at http://localhost:5050
python agent\bishe_agent.py --web
pause
