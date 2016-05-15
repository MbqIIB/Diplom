@echo off
@echo --- createusers
pause

net user esbgwusr /random /add /expires:never /fullname:"esbgwusr" /comment:"esbgwusr" /passwordchg:no
WMIC USERACCOUNT WHERE "Name='esbgwusr'" SET PasswordExpires=FALSE
echo user esbgwusr created

net user esbgwusr /random /add /expires:never /fullname:"esbgwusr" /comment:"esbgwusr" /passwordchg:no
WMIC USERACCOUNT WHERE "Name='esb99usr'" SET PasswordExpires=FALSE
echo user esbgwusr created

@echo --- Authority
pause
				
set QMGR=IRUS.SBI.OUT.GW1
set AUTHUSER=esbgwusr

setmqaut -m %QMGR% -p %AUTHUSER% -t qmgr -all +connect +inq +setall
setmqaut -m %QMGR% -p %AUTHUSER% -t q -n Q.DEAD +get +put +browse +inq +setall +set
setmqaut -m %QMGR% -p %AUTHUSER% -t chl -n "ESBGW.SVRCONN"  +chg +dlt +dsp +ctrl +ctrlx
				
set QMGR=IRUS.SBI.OUT.GW1
set AUTHUSER=esb99usr

setmqaut -m %QMGR% -p %AUTHUSER% -t qmgr -all +connect +inq +setall
setmqaut -m %QMGR% -p %AUTHUSER% -t q -n Q.DEAD -get +put +browse +inq +setall +set
				
@echo ---------------------------------- Authority: ended