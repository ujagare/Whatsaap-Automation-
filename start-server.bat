@echo off
REM Start the OpenWA WhatsApp API server (logs go to data\server.log)
cd /d "%~dp0"
echo Starting OpenWA server on http://localhost:2785 ...
echo Logs: data\server.log
node dist/main >> data\server.log 2>&1
