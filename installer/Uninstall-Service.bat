@echo off
echo Removing TelDrive 24/7 service...
schtasks /End /TN "TelDrive" >nul 2>&1
schtasks /Delete /TN "TelDrive" /F >nul 2>&1
taskkill /F /IM teldrive.exe >nul 2>&1
echo Done. The TelDrive program is still installed - use "Add or Remove Programs" to fully uninstall.
pause
