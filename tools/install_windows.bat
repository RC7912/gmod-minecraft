@echo off
rem Double-click to install Minecraft Blocks into Garry's Mod.
rem Runs install_windows.ps1 without changing your PowerShell settings.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_windows.ps1" %*
echo.
pause
