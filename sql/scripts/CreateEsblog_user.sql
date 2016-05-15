--Cкрипт создания схемы пользователя для хранения журнала КСШ
  
DEF 1 = ESBLOG
DEF 2 = qwe123

DECLARE 
vquery VARCHAR2(2000);
CURSOR ctsname IS select sid ||','|| serial# AS vsid from v$session where username ='&1' ;
BEGIN
    FOR vtsname IN ctsname
    LOOP
        vquery := 'alter system kill session '''|| vtsname.vsid || '''';
        EXECUTE IMMEDIATE vquery;
    END LOOP;
END;
/
 
DROP USER &1 CASCADE;
CREATE USER &1 IDENTIFIED BY &2 DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP;
GRANT INSERT ANY TABLE, CONNECT, RESOURCE, CREATE SESSION, ALTER SESSION, EXECUTE ANY PROCEDURE TO &1;
GRANT CREATE ANY VIEW TO &1;
GRANT SCHEDULER_ADMIN TO &1;
GRANT SELECT ON DBA_SCHEDULER_JOB_RUN_DETAILS TO &1;









