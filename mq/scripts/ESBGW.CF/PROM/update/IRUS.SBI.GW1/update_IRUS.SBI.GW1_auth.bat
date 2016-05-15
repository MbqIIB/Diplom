@echo off
@echo --- Authority
pause
							
set QMGR=IRUS.SBI.GW1
set AUTHUSER=esbgwusr

setmqaut -m %QMGR% -p %AUTHUSER% -t qmgr -all +connect +inq +setall
setmqaut -m %QMGR% -p %AUTHUSER% -t q -n CZ.ESB.COM -get +put +browse +inq +setall +set
setmqaut -m %QMGR% -p %AUTHUSER% -t q -n SBI.CF.TO.DP +get +put +browse +inq +setall +set
				
set AUTHUSER=esb99usr

setmqaut -m %QMGR% -p %AUTHUSER% -t qmgr -all +connect +inq +setall
setmqaut -m %QMGR% -p %AUTHUSER% -t q -n CZ.ESB.COM -get +put +browse +inq +setall +set
setmqaut -m %QMGR% -p %AUTHUSER% -t q -n SBI.CF.TO.DP +get +put +browse +inq +setall +set
				
@echo ---------------------------------- Authority: ended