@echo off
@echo --- update
pause
set QMGR=IRUS.SBI.IN.GW1
runmqsc %QMGR% < update_IRUS.SBI.IN.GW1.mqsc >> report.txt
call update_IRUS.SBI.IN.GW1_auth.bat
