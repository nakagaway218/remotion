@echo off
setlocal
set "ROOT=%~dp0..\.."
start "Scenariowriting server" /D "%ROOT%" /MIN cmd /K node server.mjs
timeout /t 2 /nobreak >nul
start "" "http://localhost:4174/Mytools/SeriesArticleScenarioWriting/"
endlocal
