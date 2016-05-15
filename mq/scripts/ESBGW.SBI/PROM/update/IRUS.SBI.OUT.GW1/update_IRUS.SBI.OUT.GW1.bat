@echo off
@echo --- update
pause
set QMGR=IRUS.SBI.OUT.GW1
runmqsc %QMGR% < update_IRUS.SBI.OUT.GW1.mqsc >> report.txt
call update_IRUS.SBI.OUT.GW1_auth.bat