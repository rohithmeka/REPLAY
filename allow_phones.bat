@echo off
REM Lets phones on your Wi-Fi reach RELAY on port 8000.
REM Right-click this file and choose "Run as administrator".
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo.
  echo  Please right-click allow_phones.bat and choose "Run as administrator".
  echo.
  pause
  exit /b 1
)
netsh advfirewall firewall delete rule name="RELAY (port 8000)" >nul 2>&1
netsh advfirewall firewall add rule name="RELAY (port 8000)" dir=in action=allow protocol=TCP localport=8000 profile=private,public
echo.
echo  Done. Phones on the same Wi-Fi can now open RELAY on port 8000.
echo  Your network addresses:
ipconfig | findstr /i "IPv4"
echo.
pause
