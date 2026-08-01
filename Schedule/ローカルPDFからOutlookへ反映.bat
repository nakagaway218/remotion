@echo off
setlocal
cd /d "%~dp0"
if not exist "%~dp0private" mkdir "%~dp0private"
set "LAUNCH_LOG=%~dp0private\local-schedule-launcher.log"
echo [%date% %time%] START>>"%LAUNCH_LOG%"

"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0Local-Schedule-To-Outlook.ps1" >>"%LAUNCH_LOG%" 2>&1
set "EXIT_CODE=%ERRORLEVEL%"
echo [%date% %time%] EXIT %EXIT_CODE%>>"%LAUNCH_LOG%"

if not "%EXIT_CODE%"=="0" (
  echo.
  echo An error occurred. See private\local-schedule-launcher.log.
  pause
)

exit /b %EXIT_CODE%
