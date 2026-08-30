@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ツールの準備をしています...
python merge_excel_pdf.py %*

if %errorlevel% neq 0 (
    echo.
    echo エラーが発生しました。キーを押すと終了します。
    pause
)
