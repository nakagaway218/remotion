@echo off
setlocal
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Local-Schedule-To-Outlook.ps1"
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
  echo.
  echo エラーが発生しました。上の内容を確認してください。
  pause
)

exit /b %EXIT_CODE%
