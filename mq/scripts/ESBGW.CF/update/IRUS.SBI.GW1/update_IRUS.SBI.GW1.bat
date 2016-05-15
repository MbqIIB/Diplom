@echo off
@echo --- update
pause
set QMGR=IRUS.SBI.GW1
runmqsc %QMGR% < update_IRUS.SBI.GW1.mqsc >> report.txt
call update_IRUS.SBI.GW1_auth.bat