@echo off
chcp 65001 >nul
setlocal

echo Outlookへの反映が完了したPDFだけを確認済みにします。
set /p ANSWER=未確認一覧を確認済みにしますか？ (Y/N):
if /I not "%ANSWER%"=="Y" (
  echo キャンセルしました。
  pause
  exit /b 0
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Check-New-Schedule-PDFs.ps1" -ConfirmPending
if errorlevel 1 (
  echo.
  echo 確認済みの記録中にエラーが発生しました。
  pause
  exit /b 1
)

echo.
echo 確認済みとして記録しました。
pause
exit /b 0
