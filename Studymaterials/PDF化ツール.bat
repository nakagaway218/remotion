@echo off
setlocal

cd /d "%~dp0"

if "%~1"=="" (
  powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\Convert-ExcelToPdf.ps1"
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\Convert-ExcelToPdf.ps1" -WorkbookPath "%~1"
)

echo.
pause
