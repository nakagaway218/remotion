@echo off
chcp 65001 >nul
cd /d "%~dp0"
python "multi_pdf_merger.py" %*
