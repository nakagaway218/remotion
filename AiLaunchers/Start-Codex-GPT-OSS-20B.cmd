@echo off
setlocal

title Codex - openai/gpt-oss-20b

set "SCRIPT_DIR=%~dp0"
set "HELPER=%SCRIPT_DIR%Prepare-LMStudio-GPT-OSS-20B.ps1"
set "MEMORY_HOOK=%SCRIPT_DIR%Prepare-CodexMemory-Hook.ps1"
set "PROJECT_DIR=C:\Users\nakag\Desktop\GitHub\Myownproject"
set "MODEL_ID=openai/gpt-oss-20b"

echo [1/4] Preparing LM Studio and %MODEL_ID%...

if not exist "%HELPER%" (
  echo Helper script was not found:
  echo %HELPER%
  pause
  exit /b 1
)

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%HELPER%"
if errorlevel 1 (
  echo.
  echo LM Studio setup failed. Please check the messages above.
  pause
  exit /b 1
)

echo.
echo [2/4] Checking codex.cmd...
where codex.cmd >nul 2>nul
if errorlevel 1 (
  echo codex.cmd was not found in PATH.
  echo.
  echo This launcher intentionally uses codex.cmd to avoid PowerShell ExecutionPolicy issues.
  echo Please install or expose the Codex CLI command that provides codex.cmd, then run this file again.
  echo.
  echo Current project folder:
  echo %PROJECT_DIR%
  pause
  exit /b 1
)

if not exist "%PROJECT_DIR%\" (
  echo Project folder was not found:
  echo %PROJECT_DIR%
  pause
  exit /b 1
)

cd /d "%PROJECT_DIR%"
if errorlevel 1 (
  echo Could not move to project folder:
  echo %PROJECT_DIR%
  pause
  exit /b 1
)

echo.
echo [3/4] Preparing Codex reference material...
if exist "%MEMORY_HOOK%" (
  powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%MEMORY_HOOK%"
  if errorlevel 1 (
    echo.
    echo CodexMemory hook failed. Please check the messages above.
    pause
    exit /b 1
  )
) else (
  echo CodexMemory hook was not found:
  echo %MEMORY_HOOK%
)

codex.cmd --no-alt-screen --oss -m "%MODEL_ID%"
set "CODEX_EXIT=%ERRORLEVEL%"

echo.
echo Codex exited with code %CODEX_EXIT%.
pause
exit /b %CODEX_EXIT%
