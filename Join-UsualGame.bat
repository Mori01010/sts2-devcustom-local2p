@echo off
rem Start extra windows that join your usual Slay the Spire 2 (launch option --fastmp) as host.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Local2P.ps1" -Mode Usual
pause
