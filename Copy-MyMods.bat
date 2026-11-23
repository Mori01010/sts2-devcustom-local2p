@echo off
rem Copy the mods your usual Slay the Spire 2 has enabled into this kit's mods folder.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\Local2P.ps1" -Mode CopyMods
pause
