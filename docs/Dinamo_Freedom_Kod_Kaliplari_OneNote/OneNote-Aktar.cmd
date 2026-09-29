@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo OneNote masaustu acik olmali (UWP degil).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Import-To-Local-OneNote.ps1"
echo.
pause
