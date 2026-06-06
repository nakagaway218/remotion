@echo off
setlocal
start "Scenariowriting server" /D "%~dp0" /MIN cmd /K node server.mjs
timeout /t 2 /nobreak >nul
start "" "http://localhost:4174"
endlocal
