@echo off
echo Stopping TelDrive...
schtasks /End /TN "TelDrive" >nul 2>&1
taskkill /F /IM teldrive.exe >nul 2>&1
echo Stopped. Run "Open TelDrive" from Start menu to start it again.
timeout /t 3 >nul
