@echo off
chcp 65001 >nul
setlocal

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Check-New-Schedule-PDFs.ps1"
if errorlevel 1 (
  echo.
  echo PDFの確認中にエラーが発生しました。
  pause
  exit /b 1
)

start "" notepad.exe "%~dp0Pending-Schedule-PDFs.txt"
exit /b 0
