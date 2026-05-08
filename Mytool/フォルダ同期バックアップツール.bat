@echo off
chcp 65001 >nul
cd /d "%~dp0"
python "folder_backup_sync.py" %*
