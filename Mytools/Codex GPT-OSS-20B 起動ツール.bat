@echo off
setlocal

title Codex GPT-OSS-20B Launcher

set "TOOLS_DIR=%~dp0"
set "PROJECT_DIR=%TOOLS_DIR%.."

pushd "%PROJECT_DIR%" >nul 2>nul
if errorlevel 1 (
    echo Could not open the project folder.
    echo %PROJECT_DIR%
    pause
    exit /b 1
)

set "LAUNCHER=%CD%\AiLaunchers\Start-Codex-GPT-OSS-20B.cmd"

if not exist "%LAUNCHER%" (
    echo Codex launcher was not found.
    echo %LAUNCHER%
    popd
    pause
    exit /b 1
)

call "%LAUNCHER%" %*
set "EXIT_CODE=%ERRORLEVEL%"
popd

exit /b %EXIT_CODE%
