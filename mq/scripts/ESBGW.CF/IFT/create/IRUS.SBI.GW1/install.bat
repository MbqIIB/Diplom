@echo off
set QMGR=IRUS.SBI.GW1

echo ************ %QMGR% **********
@echo --- install
pause

set LOG_FILE_SIZE=16384
set LOG_PRIMARY_FILES=8
set LOG_SECONDARY_FILES=4

set DEADQ=Q.DEAD
set MAXCHANNELS=10000
set CLIENTIDLE=3600
set KeepAlive=YES

crtmqm -lf %LOG_FILE_SIZE% -lp %LOG_PRIMARY_FILES% -ls %LOG_SECONDARY_FILES% -u %DEADQ% %QMGR%

amqmdain auto %QMGR%
amqmdain reg %QMGR% -c add -s Channels -v MaxChannels=%MAXCHANNELS%
amqmdain reg %QMGR% -c add -s SSL -v OCSPAuthentication=OPTIONAL
amqmdain reg %QMGR% -c add -s TCP -v KeepAlive=%KeepAlive%

amqmdain start %QMGR%