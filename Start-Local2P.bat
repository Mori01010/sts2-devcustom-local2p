@echo off
rem DEV_CUSTOM: start 2-4 game windows on this PC (one hosts, the others join).
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Local2P.ps1" -Mode Kit
pause
