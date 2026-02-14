@echo off
echo ========================================
echo Experiment with Tc
echo ========================================
echo Starting NTP Server and Clients...

REM Запуск сервера в новом окне
start "NTP Server" cmd /k "cd /d %~dp0 && NTP-server.exe"

REM Задержка 3 секунды для запуска сервера
echo Waiting for server to start...
timeout /t 3 /nobreak > nul

REM Запуск двух клиентов одновременно
echo Starting Client 1...
start "NTP Client 1" cmd /k "cd /d %~dp0 && NTP-client.exe"

echo Starting Client 2...
start "NTP Client 2" cmd /k "cd /d %~dp0 && NTP-client.exe"

echo ========================================
echo All processes started!
echo Server and 2 clients are running...
echo ========================================
pause