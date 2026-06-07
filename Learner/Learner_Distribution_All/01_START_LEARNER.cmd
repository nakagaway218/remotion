@echo off
cd /d "%~dp0"
echo learner start clicked > learner_start_log.txt
echo ========================================
echo Learner start
echo ========================================
echo.
echo Keep this window open while using Learner.
echo.
echo Current folder:
cd
echo.
echo Checking node:
where node
if errorlevel 1 (
  echo.
  echo Node was not found.
  echo Install Node.js or add node to PATH.
  pause
  exit /b 1
)
echo.
echo Starting server...
echo Open this URL if the browser does not open automatically:
echo http://localhost:8787/C_Learner_Index.html
echo.
node "%~dp0C_Learner_Server.cjs"
echo.
echo Server stopped.
pause
