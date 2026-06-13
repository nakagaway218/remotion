@echo off
cd /d "%~dp0"
echo Opening Learner HTML directly...
start "" "%~dp0C_Learner_Index.html"
echo.
echo If the browser opens, you can use copy/paste features.
echo Server-only features may not work in direct HTML mode.
timeout /t 5 /nobreak >nul
