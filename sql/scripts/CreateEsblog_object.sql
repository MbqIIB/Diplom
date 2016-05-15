--Cкрипт создания схемы пользователя для хранения журнала КСШ
  
DEF 1 = ESBLOG
DEF 2 = qwe123

-- Таблица для хранения параметров ведения журнала КСШ
CREATE TABLE &1..LOGPARAM (
    PARAM_ID NUMBER NOT NULL,
    NAME VARCHAR2(32) NOT NULL,
	PARAM_VALUE NUMBER NOT NULL,
    DESCRIPTION VARCHAR2(256))
	TABLESPACE ESBDATA;
	
INSERT INTO &1..LOGPARAM (PARAM_ID, NAME, PARAM_VALUE, DESCRIPTION) VALUES (1, 'PARTCOUNT', 7, 'Число дней, за которые хранятся логи в таблице &1..EVENT');
COMMIT;

-- Таблица для хранения журнала Шлюза платежей
CREATE TABLE &1..EVENT (
    EVENT_ID NUMBER NOT NULL,
    RQ_UID VARCHAR2(32) NOT NULL,
    EVENT_DATE TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    PROC_STATUS_ID NUMBER NOT NULL,
    ERROR_TEXT CLOB,
    EVENT_SOURCE_ID NUMBER NOT NULL,
    EVENT_RECIEVER_ID NUMBER NOT NULL,
    OPERATION_ID NUMBER NOT NULL,
    SOURCE_QUEUE_ID NUMBER,
    SOURCE_QM_ID NUMBER,
    TARGET_QUEUE_ID NUMBER,
    TARGET_QM_ID NUMBER,
    REPLY_QUEUE_ID NUMBER,
    REPLY_QM_ID NUMBER,
    EVENT_MSG CLOB NOT NULL,
    PART_DATE DATE NOT NULL,
	ARC_STATUS NUMBER,
	OPERATION_NAME_ID NUMBER,
	VERSION VARCHAR2(20)
commit
  )
PARTITION BY RANGE
 (PART_DATE)
    (
        PARTITION P20000101 VALUES LESS THAN (TO_DATE('20001001','yyyymmdd'))
     );

alter table &1..EVENT modify event_msg null;

DECLARE
  vpartdate     VARCHAR2(32);
  vnextpartdate VARCHAR2(32);
  vquery        VARCHAR2(2000);
  vinterval     NUMBER;
  vlogdayscount NUMBER;
  i             NUMBER;
  j             NUMBER;
BEGIN
  SELECT PARAM_VALUE
    INTO vlogdayscount
    FROM &1..LOGPARAM
   WHERE PARAM_ID = 1;

  vpartdate     := TO_CHAR(trunc(sysdate) - vlogdayscount, 'YYYYMMDDHH24');
  vnextpartdate := vpartdate;

  -- Запас 2 дня по логам
  FOR i IN 1 .. vlogdayscount + 2 LOOP
  
    FOR j IN 1 .. 24 LOOP
    
      vnextpartdate := TO_CHAR(TO_DATE(vnextpartdate, 'YYYYMMDDHH24') +
                               1 / 24,
                               'YYYYMMDDHH24');
      vquery        := 'ALTER TABLE &1..EVENT ADD PARTITION P' ||
                       vpartdate || ' VALUES LESS THAN (TO_DATE(''' ||
                       vnextpartdate ||
                       ''',''YYYYMMDDHH24'')) 
    TABLESPACE ESBLOGDATA PCTFREE 0 INITRANS 1 MAXTRANS 255 STORAGE( INITIAL 1M PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED )
    LOB (ERROR_TEXT, EVENT_MSG) STORE AS (
        TABLESPACE ESBLOGDATALOB CHUNK 4096 NOCACHE PCTVERSION 0 ENABLE STORAGE IN ROW STORAGE(INITIAL 1M PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED))';
      EXECUTE IMMEDIATE vquery;
      vpartdate := vnextpartdate;
    
    END LOOP;
  END LOOP;
  EXECUTE IMMEDIATE 'ALTER TABLE &1..EVENT DROP PARTITION P20000101';
END;
/


CREATE TABLE &1..CDSTATUSTP (
    PROC_STATUS_ID NUMBER NOT NULL,
    NAME VARCHAR2(10) NOT NULL,
    DESCRIPTION VARCHAR2(100),
    LAST_UPDATE_DT TIMESTAMP(6) WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    LAST_UPDATE_USER VARCHAR2(12)
  )
  TABLESPACE ESBDATA;

CREATE TABLE &1..CDCOMPONENTTP (
    COMPONENT_ID NUMBER NOT NULL,
    NAME VARCHAR2(256) NOT NULL,
    DESCRIPTION VARCHAR2(100),
    LAST_UPDATE_DT TIMESTAMP(6) WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    LAST_UPDATE_USER VARCHAR2(12)
  )
  TABLESPACE ESBDATA;

CREATE TABLE &1..CDQUEUETP (
    QUEUE_ID NUMBER NOT NULL,
    NAME VARCHAR2(100) NOT NULL,
    DESCRIPTION VARCHAR2(100),
    LAST_UPDATE_DT TIMESTAMP(6) WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    LAST_UPDATE_USER VARCHAR2(12)
  )
  TABLESPACE ESBDATA;

CREATE TABLE &1..CDQMTP (
    QM_ID NUMBER NOT NULL,
    NAME VARCHAR2(100) NOT NULL,
    DESCRIPTION VARCHAR2(100),
    LAST_UPDATE_DT TIMESTAMP(6) WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    LAST_UPDATE_USER VARCHAR2(12)
  )
  TABLESPACE ESBDATA;

CREATE TABLE &1..CDOPERATIONTP (
    OPERATION_ID NUMBER NOT NULL,
    NAME VARCHAR2(200) NOT NULL,
    DESCRIPTION VARCHAR2(100),
    LAST_UPDATE_DT TIMESTAMP(6) WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    LAST_UPDATE_USER VARCHAR2(12)
  )
  TABLESPACE ESBDATA;

CREATE TABLE &1..CDOPERATIONNAMETP (
    OPERATION_NAME_ID NUMBER NOT NULL,
    NAME VARCHAR2(200) NOT NULL,
    DESCRIPTION VARCHAR2(100),
    LAST_UPDATE_DT TIMESTAMP(6) WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    LAST_UPDATE_USER VARCHAR2(12)
  )
  TABLESPACE ESBDATA;
  
CREATE TABLE &1..CDBANKTP (
    BANK_ID VARCHAR2(8) NOT NULL,
    NAME    VARCHAR2(128) NOT NULL,
	QM_NAME VARCHAR2(32) NOT NULL
  )
TABLESPACE ESBDATA;

CREATE TABLE &1..TRANSACTIONDP (
    RQ_UID VARCHAR2(32) NOT NULL,
    TRANSACTIONID    VARCHAR2(128) NOT NULL
  )
TABLESPACE ESBDATA;

INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('99', 'Центральный аппарат', 'M99.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('02', 'Алтайский банк', 'M02.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('13', 'Центрально-Черноземный банк', 'M13.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('16', 'Уральский банк', 'M16.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('18', 'Байкальский банк', 'M18.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('31', 'Восточно-Сибирский банк', 'M31.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('36', 'Северо-Восточный банк', 'M36.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('40', 'Среднерусский банк', 'M40.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('42', 'Волго-Вятский банк', 'M42.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('44', 'Сибирский банк', 'M44.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('49', 'Западно-Уральский банк', 'M49.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('52', 'Юго-Западный банк', 'M52.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('54', 'Поволжский банк', 'M54.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('55', 'Северо-Западный банк', 'M55.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('60', 'Северо-Кавказский банк', 'M60.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('67', 'Западно-Сибирский банк', 'M67.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('70', 'Дальневосточный банк', 'M70.ESB.DI1');
INSERT INTO &1..CDBANKTP (BANK_ID, NAME, QM_NAME) VALUES ('77', 'Северный банк', 'M77.ESB.DI1');
COMMIT;

CREATE INDEX &1..I1_EVENT ON &1..EVENT(EVENT_ID) LOCAL; 
CREATE INDEX &1..I2_EVENT ON &1..EVENT(RQ_UID) LOCAL; 
CREATE INDEX &1..I3_EVENT ON &1..EVENT(PART_DATE) LOCAL; 
CREATE INDEX &1..I4_EVENT ON &1..EVENT(ARC_STATUS) LOCAL; 


ALTER TABLE &1..CDSTATUSTP ADD CONSTRAINT P_CDSTATUSTP PRIMARY KEY (PROC_STATUS_ID) USING INDEX TABLESPACE ESBINDEX; 
ALTER TABLE &1..CDCOMPONENTTP ADD CONSTRAINT P_CDCOMPONENTTP PRIMARY KEY (COMPONENT_ID) USING INDEX  TABLESPACE ESBINDEX;
ALTER TABLE &1..CDQUEUETP ADD CONSTRAINT P_CDQUEUETP PRIMARY KEY (QUEUE_ID) USING INDEX  TABLESPACE ESBINDEX;
ALTER TABLE &1..CDQMTP ADD CONSTRAINT P_CDQMTP PRIMARY KEY (QM_ID) USING INDEX  TABLESPACE ESBINDEX;
ALTER TABLE &1..CDOPERATIONTP ADD CONSTRAINT P_CDOPERATIONTP PRIMARY KEY (OPERATION_ID) USING INDEX  TABLESPACE ESBINDEX;
ALTER TABLE &1..CDOPERATIONNAMETP ADD CONSTRAINT P_CDOPERATIONNAMETP PRIMARY KEY (OPERATION_NAME_ID) USING INDEX  TABLESPACE ESBINDEX;
ALTER TABLE &1..CDBANKTP ADD CONSTRAINT P_BANK_ID PRIMARY KEY (BANK_ID) USING INDEX  TABLESPACE ESBINDEX;

ALTER TABLE &1..CDSTATUSTP ADD CONSTRAINT U1_CDSTATUSTP UNIQUE (NAME) USING INDEX TABLESPACE ESBINDEX; 
ALTER TABLE &1..CDCOMPONENTTP ADD CONSTRAINT U1_CDCOMPONENTTP UNIQUE (NAME) USING INDEX TABLESPACE ESBINDEX; 
ALTER TABLE &1..CDQUEUETP ADD CONSTRAINT U1_CDQUEUETP UNIQUE (NAME) USING INDEX TABLESPACE ESBINDEX; 
ALTER TABLE &1..CDQMTP ADD CONSTRAINT U1_CDQMTP UNIQUE (NAME) USING INDEX TABLESPACE ESBINDEX; 
ALTER TABLE &1..CDOPERATIONTP ADD CONSTRAINT U1_CDOPERATIONTP UNIQUE (NAME) USING INDEX TABLESPACE ESBINDEX; 
ALTER TABLE &1..CDOPERATIONNAMETP ADD CONSTRAINT U1_CDOPERATIONNAMETP UNIQUE (NAME) USING INDEX TABLESPACE ESBINDEX; 
ALTER TABLE &1..CDBANKTP ADD CONSTRAINT U1_CDBANKTP UNIQUE (NAME) USING INDEX TABLESPACE ESBINDEX; 


ALTER TABLE &1..EVENT ADD CONSTRAINT EVENT_CDSTATUSTP_FK FOREIGN KEY (PROC_STATUS_ID)
  REFERENCES &1..CDSTATUSTP (PROC_STATUS_ID)
  ON DELETE CASCADE;

ALTER TABLE &1..EVENT ADD CONSTRAINT EVENT_CDCOMPONENTTP_FK FOREIGN KEY (EVENT_SOURCE_ID)
  REFERENCES &1..CDCOMPONENTTP (COMPONENT_ID)
  ON DELETE CASCADE;

ALTER TABLE &1..EVENT ADD CONSTRAINT EVENT_CDOPERATIONTP_FK FOREIGN KEY (OPERATION_ID)
  REFERENCES &1..CDOPERATIONTP (OPERATION_ID)
  ON DELETE CASCADE;

ALTER TABLE &1..EVENT ADD CONSTRAINT EVENT_CDQUEUETP_FK FOREIGN KEY (SOURCE_QUEUE_ID)
  REFERENCES &1..CDQUEUETP (QUEUE_ID)
  ON DELETE CASCADE;

ALTER TABLE &1..EVENT ADD CONSTRAINT EVENT_CDQMTP_FK FOREIGN KEY (SOURCE_QM_ID)
  REFERENCES &1..CDQMTP (QM_ID)
  ON DELETE CASCADE;

ALTER TABLE &1..EVENT ADD CONSTRAINT EVENT_CDQUEUETP_FK1 FOREIGN KEY (TARGET_QUEUE_ID)
  REFERENCES &1..CDQUEUETP (QUEUE_ID)
  ON DELETE CASCADE;

ALTER TABLE &1..EVENT ADD CONSTRAINT EVENT_CDQUEUETP_FK2 FOREIGN KEY (REPLY_QUEUE_ID)
  REFERENCES &1..CDQUEUETP (QUEUE_ID)
  ON DELETE CASCADE;

ALTER TABLE &1..EVENT ADD CONSTRAINT EVENT_CDQMTP_FK1 FOREIGN KEY (TARGET_QM_ID)
  REFERENCES &1..CDQMTP (QM_ID)
  ON DELETE CASCADE;

ALTER TABLE &1..EVENT ADD CONSTRAINT EVENT_CDQMTP_FK2 FOREIGN KEY (REPLY_QM_ID)
  REFERENCES &1..CDQMTP (QM_ID)
  ON DELETE CASCADE;

ALTER TABLE &1..EVENT ADD CONSTRAINT EVENT_CDCOMPONENTTP_FK1 FOREIGN KEY (EVENT_RECIEVER_ID)
  REFERENCES &1..CDCOMPONENTTP (COMPONENT_ID)
  ON DELETE CASCADE;

ALTER TABLE &1..EVENT ADD CONSTRAINT EVENT_CDOPERATIONNAMETP_FK FOREIGN KEY (OPERATION_NAME_ID)
  REFERENCES &1..CDOPERATIONNAMETP (OPERATION_NAME_ID)
  ON DELETE CASCADE;

CREATE SEQUENCE &1..SEQ_CDCOMPONENTTP
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;


CREATE SEQUENCE &1..SEQ_CDOPERATIONTP
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;


CREATE SEQUENCE &1..SEQ_CDQMTP
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;


CREATE SEQUENCE &1..SEQ_CDQUEUETP
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;


CREATE SEQUENCE &1..SEQ_CDSTATUSTP
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;


CREATE SEQUENCE &1..SEQ_EVENT
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;


CREATE SEQUENCE &1..SEQ_CDOPERATIONNAMETP
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;


CREATE OR REPLACE TRIGGER &1..TR_CDCOMPONENTTP_I
BEFORE INSERT ON &1..CDCOMPONENTTP
    FOR EACH ROW

BEGIN
    SELECT &1..SEQ_CDCOMPONENTTP.NEXTVAL INTO :NEW.COMPONENT_ID FROM DUAL;
END;
/


CREATE OR REPLACE TRIGGER &1..TR_CDOPERATIONTP_I
BEFORE INSERT ON &1..CDOPERATIONTP
    FOR EACH ROW

BEGIN
    SELECT &1..SEQ_CDOPERATIONTP.NEXTVAL INTO :NEW.OPERATION_ID FROM DUAL;
END;
/


CREATE OR REPLACE TRIGGER &1..TR_CDQMTP_I
BEFORE INSERT ON &1..CDQMTP
    FOR EACH ROW

BEGIN
    SELECT &1..SEQ_CDQMTP.NEXTVAL INTO :NEW.QM_ID FROM DUAL;
END;
/


CREATE OR REPLACE TRIGGER &1..TR_CDQUEUETP_I
BEFORE INSERT ON &1..CDQUEUETP
    FOR EACH ROW

BEGIN
    SELECT &1..SEQ_CDQUEUETP.NEXTVAL INTO :NEW.QUEUE_ID FROM DUAL;
END;
/


CREATE OR REPLACE TRIGGER &1..TR_CDSTATUSTP_I
BEFORE INSERT ON &1..CDSTATUSTP
    FOR EACH ROW

BEGIN
    SELECT &1..SEQ_CDSTATUSTP.NEXTVAL INTO :NEW.PROC_STATUS_ID FROM DUAL;
END;
/


CREATE OR REPLACE TRIGGER &1..TR_EVENT_I
BEFORE INSERT ON &1..EVENT
    FOR EACH ROW

BEGIN
    SELECT &1..SEQ_EVENT.NEXTVAL INTO :NEW.EVENT_ID FROM DUAL;
END;
/


CREATE OR REPLACE TRIGGER &1..TR_CDOPERATIONNAMETP_I
BEFORE INSERT ON &1..CDOPERATIONNAMETP
    FOR EACH ROW

BEGIN
    SELECT &1..SEQ_CDOPERATIONNAMETP.NEXTVAL INTO :NEW.OPERATION_NAME_ID FROM DUAL;
END;
/


CREATE OR REPLACE FUNCTION &1..CONVERT_PARTDATE_TO_DATE(ptablename     IN VARCHAR2,
                                                    ppartitionname IN VARCHAR2)
  RETURN DATE AS
  vhighvalue LONG;
  vdate      DATE;
BEGIN
  FOR c IN (SELECT high_value
              FROM user_tab_partitions
             WHERE TABLE_NAME = ptablename
               AND PARTITION_NAME = ppartitionname) LOOP
    vhighvalue := c.high_value;
    vdate      := TO_DATE(SUBSTR(vhighvalue, 11, 19),
                          'SYYYY-MM-DD HH24:MI:SS');
  END LOOP;
  RETURN vdate;
END;
/

CREATE OR REPLACE VIEW &1..PARTSTATUS AS
-- Смещение  trunc(sysdate +1 - 1/24) указано для того, чтобы учитывать запуск джоба в 1 ночи. Те удаление будт завтра относительно текущего дня (это 1), а чтобы смещение было правильным в период с 0 до 1 вычитается 1/24
SELECT TABLE_NAME,
       PARTITION_NAME,
       NUM_ROWS,
       &1..CONVERT_PARTDATE_TO_DATE(TABLE_NAME, PARTITION_NAME) AS PART_DATE,
       CASE
         WHEN &1..CONVERT_PARTDATE_TO_DATE(TABLE_NAME, PARTITION_NAME) =
              TO_DATE(TO_CHAR(sysdate, 'YYYYMMDDHH24'), 'YYYYMMDDHH24') then
          'В партицию производится запись данных'
         WHEN &1..CONVERT_PARTDATE_TO_DATE(TABLE_NAME, PARTITION_NAME) >
              TO_DATE(TO_CHAR(sysdate, 'YYYYMMDDHH24'), 'YYYYMMDDHH24') then
          'Незаполненная партиция для хранения данных'
         WHEN &1..CONVERT_PARTDATE_TO_DATE(TABLE_NAME, PARTITION_NAME) <=
              trunc(sysdate + 2 - 1/24 ) -
              (SELECT PARAM_VALUE FROM &1..LOGPARAM WHERE PARAM_ID = 1) AND
              &1..CONVERT_PARTDATE_TO_DATE(TABLE_NAME, PARTITION_NAME) >
              trunc(sysdate +1 - 1/24)  -
              (SELECT PARAM_VALUE FROM &1..LOGPARAM WHERE PARAM_ID = 1) then
          'Партиция для хранения данных, которая будет удалена автоматически'
         WHEN &1..CONVERT_PARTDATE_TO_DATE(TABLE_NAME, PARTITION_NAME) <=
              trunc(sysdate +1 - 1/24) -
              (SELECT PARAM_VALUE FROM &1..LOGPARAM WHERE PARAM_ID = 1) then
          'Партиция для хранения данных, которую нужно удалить администратору КСШ'
         ELSE
          'Партиция для хранения данных'
       END AS PART_INFO
  FROM all_tab_partitions
 WHERE TABLE_OWNER = 'ESBLOG'
   AND table_name = 'EVENT'
 ORDER BY partition_name;

 


CREATE VIEW &1..EVENTLOG AS
SELECT e.EVENT_ID   "EVENT_ID",
       e.EVENT_DATE "EVENT_DATE",
       e.RQ_UID     "RQ_UID",
       e.EVENT_MSG  "EVENT_MSG",
       cs.NAME      "PROC_STATUS",
       e.ERROR_TEXT "ERROR_TEXT",
       cces.NAME    "EVENT_SOURCE",
       ccer.NAME    "EVENT_RECIEVER",
       co.NAME      "OPERATION",
	   con.NAME     "OPERATION_NAME",
       csq.NAME     "SOURCE_QUEUE",
       csqm.NAME    "SOURCE_QM",
       ctq.NAME     "TARGET_QUEUE",
       ctqm.NAME    "TARGET_QM",
       crq.NAME     "REPLY_QUEUE",
       crqm.NAME    "REPLY_QM",
       e.PART_DATE  "PART_DATE"
  FROM &1..EVENT e,
       &1..CDSTATUSTP cs,
       &1..CDCOMPONENTTP cces,
       &1..CDCOMPONENTTP ccer,
       &1..CDOPERATIONTP co,
	   &1..CDOPERATIONNAMETP con,
       &1..CDQUEUETP csq,
       &1..CDQMTP csqm,
       &1..CDQUEUETP ctq,
       &1..CDQMTP ctqm,
       &1..CDQUEUETP crq,
       &1..CDQMTP crqm
 WHERE e.PROC_STATUS_ID = cs.PROC_STATUS_ID
   AND e.EVENT_SOURCE_ID = cces.COMPONENT_ID
   AND e.EVENT_RECIEVER_ID = ccer.COMPONENT_ID
   AND e.OPERATION_ID = co.OPERATION_ID
   AND e.OPERATION_NAME_ID = con.OPERATION_NAME_ID(+)
   AND e.SOURCE_QUEUE_ID = csq.QUEUE_ID(+)
   AND e.SOURCE_QM_ID = csqm.QM_ID(+)
   AND e.TARGET_QUEUE_ID = ctq.QUEUE_ID(+)
   AND e.TARGET_QM_ID = ctqm.QM_ID(+)
   AND e.REPLY_QUEUE_ID = crq.QUEUE_ID(+)
   AND e.REPLY_QM_ID = crqm.QM_ID(+);


CREATE OR REPLACE PROCEDURE &1..REPLACE_EVENT_PARTITION IS
  vdroppartdate       VARCHAR2(32);
  vcreatepartdate     VARCHAR2(32);
  vcreatenextpartdate VARCHAR2(32);
  vquery              VARCHAR2(2000);
  vlogdayscount       NUMBER;
  i                   NUMBER;

  partition_does_not_exist EXCEPTION;
  PRAGMA EXCEPTION_INIT(partition_does_not_exist, -2149);
BEGIN
  SELECT PARAM_VALUE
    INTO vlogdayscount
    FROM &1..LOGPARAM
   WHERE PARAM_ID = 1;

  vdroppartdate       := TO_CHAR(trunc(sysdate) - vlogdayscount,
                                 'YYYYMMDDHH24');
  vcreatepartdate     := TO_CHAR(trunc(sysdate) + 2, 'YYYYMMDDHH24');
  vcreatenextpartdate := vcreatepartdate;

  BEGIN
  
    FOR i IN 1 .. 24 LOOP
      vquery := 'ALTER TABLE &1..EVENT DROP PARTITION P' ||
                vdroppartdate;
      EXECUTE IMMEDIATE vquery;
      vdroppartdate := TO_CHAR(TO_DATE(vdroppartdate, 'YYYYMMDDHH24') +
                               1 / 24,
                               'YYYYMMDDHH24');
    END LOOP;
  EXCEPTION
    WHEN partition_does_not_exist THEN
      NULL;
  END;
 
  FOR i IN 1 .. 24 LOOP
  
    vcreatenextpartdate := TO_CHAR(TO_DATE(vcreatenextpartdate, 'YYYYMMDDHH24') +
                                   1 / 24,
                                   'YYYYMMDDHH24');
    vquery              := 'ALTER TABLE &1..EVENT ADD PARTITION P' ||
                           vcreatepartdate ||
                           ' VALUES LESS THAN (TO_DATE(''' ||
                           vcreatenextpartdate ||
                           ''',''YYYYMMDDHH24'')) 
    TABLESPACE ESBLOGDATA PCTFREE 0 INITRANS 1 MAXTRANS 255 STORAGE( INITIAL 1M PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED )
    LOB (ERROR_TEXT, EVENT_MSG) STORE AS (
        TABLESPACE ESBLOGDATALOB CHUNK 4096 NOCACHE PCTVERSION 0 ENABLE STORAGE IN ROW STORAGE(INITIAL 1M PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED))';
    EXECUTE IMMEDIATE vquery;
    vcreatepartdate := vcreatenextpartdate;
  
  END LOOP;

  COMMIT;
END;
/


CREATE OR REPLACE PROCEDURE &1..CONVERT_CLOB_TO_BLOB(peventdataclob IN OUT NOCOPY CLOB,
                                                        peventdatablob IN OUT NOCOPY BLOB) IS
  vsrcoffset  NUMBER DEFAULT 1;
  vsrcamount  NUMBER DEFAULT 4096;
  vdestoffset NUMBER DEFAULT 1;
  vdestamount NUMBER;
  vdeststr    VARCHAR2(4096 char);
BEGIN
  BEGIN
    vdestoffset := 1;
    vsrcoffset  := 1;
    LOOP
      DBMS_LOB.READ(peventdataclob, vsrcamount, vsrcoffset, vdeststr);
      vdestamount := UTL_RAW.LENGTH(UTL_RAW.CAST_TO_RAW(vdeststr));
      DBMS_LOB.WRITE(peventdatablob,
                     vdestamount,
                     vdestoffset,
                     UTL_RAW.CAST_TO_RAW(vdeststr));
      vdestoffset := vdestoffset + vdestamount;
      vsrcoffset  := vsrcoffset + vsrcamount;
    END LOOP;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;
END;
/

-- Web интерфейс и данную функцию необходимо доработать для передачи OPERATION_NAME_ID.
CREATE OR REPLACE FUNCTION &1..GET_EVENT_BY_RQ_UID(prquid          IN VARCHAR2,
                                                      peventdatestart IN TIMESTAMP,
                                                      peventdateend   IN TIMESTAMP)
  RETURN BLOB IS

  veventdataclob CLOB;
  veventdatablob BLOB;
  vprocstatus    VARCHAR2(10);
  veventsource   VARCHAR2(256);
  veventreciever VARCHAR2(256);
  voperation     VARCHAR2(200);
  vsourcequeue   VARCHAR2(100);
  vtargetqueue   VARCHAR2(100);
  vreplyqueue    VARCHAR2(100);
  vsourceqm      VARCHAR2(100);
  vtargetqm      VARCHAR2(100);
  vreplyqm       VARCHAR2(100);
  veventrow      &1..EVENT%rowtype;

  CURSOR cevent IS
    SELECT *
      FROM &1..EVENT
     WHERE rq_uid = prquid
       AND part_date BETWEEN peventdatestart AND peventdateend;

BEGIN

  DBMS_LOB.CREATETEMPORARY(veventdataclob, true);
  DBMS_LOB.OPEN(veventdataclob, DBMS_LOB.LOB_READWRITE);
  DBMS_LOB.CREATETEMPORARY(veventdatablob, true);
  DBMS_LOB.OPEN(veventdatablob, DBMS_LOB.LOB_READWRITE);
  DBMS_LOB.APPEND(veventdataclob,
                  to_clob('<?xml version="1.0" encoding="UTF-8"?><EventList><Events rquid="' || prquid || '">'));

  OPEN cevent;
  FETCH cevent
    INTO veventrow;

  WHILE cevent%FOUND LOOP

    SELECT NAME
      INTO vprocstatus
      FROM &1..CDSTATUSTP
     WHERE PROC_STATUS_ID = veventrow.PROC_STATUS_ID;

    DBMS_LOB.APPEND(veventdataclob,
                    to_clob('<Event id="'|| veventrow.EVENT_ID ||'"><EventDate>'||TO_CHAR(veventrow.EVENT_DATE,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')||'</EventDate><PartDate>'||TO_CHAR(veventrow.PART_DATE,'YYYY-MM-DD"T"HH24:MI:SS')||'</PartDate><ProcStatus>'|| vprocstatus ||'</ProcStatus>'));
      DBMS_LOB.APPEND(veventdataclob, to_clob('<ErrorText><![CDATA['));
    IF veventrow.ERROR_TEXT IS NOT NULL THEN
      DBMS_LOB.APPEND(veventdataclob, veventrow.ERROR_TEXT);
    END IF;
          DBMS_LOB.APPEND(veventdataclob, to_clob(']]></ErrorText>'));

    SELECT NAME
      INTO veventsource
      FROM &1..CDCOMPONENTTP
     WHERE COMPONENT_ID = veventrow.EVENT_SOURCE_ID;
    SELECT NAME
      INTO veventreciever
      FROM &1..CDCOMPONENTTP
     WHERE COMPONENT_ID = veventrow.EVENT_RECIEVER_ID;
    SELECT NAME
      INTO voperation
      FROM &1..CDOPERATIONTP
     WHERE OPERATION_ID = veventrow.OPERATION_ID;

    DBMS_LOB.APPEND(veventdataclob,
                    to_clob('<EventSource>' || veventsource ||'</EventSource><EventReciever>' || veventreciever ||'</EventReciever><Operation>' || voperation ||'</Operation>'));

    IF veventrow.SOURCE_QUEUE_ID IS NOT NULL THEN
      SELECT NAME
        INTO vsourcequeue
        FROM &1..CDQUEUETP
       WHERE QUEUE_ID = veventrow.SOURCE_QUEUE_ID;
      DBMS_LOB.APPEND(veventdataclob,
                      to_clob('<SourceQueue>' || vsourcequeue ||'</SourceQueue>'));
    END IF;

    IF veventrow.SOURCE_QM_ID IS NOT NULL THEN
      SELECT NAME
        INTO vsourceqm
        FROM &1..CDQMTP
       WHERE QM_ID = veventrow.SOURCE_QM_ID;
      DBMS_LOB.APPEND(veventdataclob,
                      to_clob('<SourceQM>' || vsourceqm ||'</SourceQM>'));
    END IF;

    IF veventrow.TARGET_QUEUE_ID IS NOT NULL THEN
      SELECT NAME
        INTO vtargetqueue
        FROM &1..CDQUEUETP
       WHERE QUEUE_ID = veventrow.TARGET_QUEUE_ID;
      DBMS_LOB.APPEND(veventdataclob,
                      to_clob('<TargetQueue>' || vtargetqueue ||'</TargetQueue>'));
    END IF;

    IF veventrow.TARGET_QM_ID IS NOT NULL THEN
      SELECT NAME
        INTO vtargetqm
        FROM &1..CDQMTP
       WHERE QM_ID = veventrow.TARGET_QM_ID;
      DBMS_LOB.APPEND(veventdataclob,
                      to_clob('<TargetQM>' || vtargetqm ||'</TargetQM>'));
    END IF;

    IF veventrow.REPLY_QUEUE_ID IS NOT NULL THEN
      SELECT NAME
        INTO vreplyqueue
        FROM &1..CDQUEUETP
       WHERE QUEUE_ID = veventrow.REPLY_QUEUE_ID;
      DBMS_LOB.APPEND(veventdataclob,
                      to_clob('<ReplyQueue>' || vreplyqueue ||'</ReplyQueue>'));
    END IF;

    IF veventrow.REPLY_QM_ID IS NOT NULL THEN
      SELECT NAME
        INTO vreplyqm
        FROM &1..CDQMTP
       WHERE QM_ID = veventrow.REPLY_QM_ID;
      DBMS_LOB.APPEND(veventdataclob,
                      to_clob('<ReplyQM>' || vreplyqm ||'</ReplyQM>'));
    END IF;

    DBMS_LOB.APPEND(veventdataclob, to_clob('<EventMsg><![CDATA['));
     IF veventrow.EVENT_MSG IS NOT NULL AND LENGTH(veventrow.EVENT_MSG) > 10 THEN
        DBMS_LOB.APPEND(veventdataclob, to_clob(veventrow.EVENT_MSG));
    END IF;

    DBMS_LOB.APPEND(veventdataclob, to_clob(']]></EventMsg></Event>'));

    FETCH cevent
      INTO veventrow;
  END LOOP;
  CLOSE cevent;
  DBMS_LOB.APPEND(veventdataclob, '</Events></EventList>');
  
  &1..CONVERT_CLOB_TO_BLOB(veventdataclob, veventdatablob);
  
  RETURN veventdatablob;
  DBMS_LOB.CLOSE(veventdataclob);
  DBMS_LOB.FREETEMPORARY(veventdataclob);
   DBMS_LOB.CLOSE(veventdatablob);
  DBMS_LOB.FREETEMPORARY(veventdatablob);
END;
/
CREATE OR REPLACE PROCEDURE &1..WRITE_EVENT_DP(pdate          IN VARCHAR2,
                                               prquid         IN VARCHAR2,
                                               pprocstatus    IN VARCHAR2,
                                               perrortext     IN CLOB,
                                               peventsrc      IN VARCHAR2,
                                               peventrcv      IN VARCHAR2,
                                               poperation     IN VARCHAR2,
                                               poperationname IN VARCHAR2,
                                               psourcequeue   IN VARCHAR2,
                                               psourceqm      IN VARCHAR2,
                                               ptargetqueue   IN VARCHAR2,
                                               ptargetqm      IN VARCHAR2,
                                               preplyqueue    IN VARCHAR2,
                                               preplyqm       IN VARCHAR2,
                                               peventmsg      IN CLOB,
                                               ptransactionid         IN VARCHAR2)
 IS
BEGIN
  INSERT INTO &1..TRANSACTIONDP(RQ_UID,TRANSACTIONID)VALUES(prquid,ptransactionid);
  &1..WRITE_EVENT(pdate, prquid, pprocstatus, perrortext, peventsrc, peventrcv, poperation, poperationname, psourcequeue, psourceqm, ptargetqueue, ptargetqm, preplyqueue, preplyqm, peventmsg);
END WRITE_EVENT_DP;
/

CREATE OR REPLACE PROCEDURE &1..WRITE_EVENT(pdate          IN VARCHAR2,
                                               prquid         IN VARCHAR2,
                                               pprocstatus    IN VARCHAR2,
                                               perrortext     IN CLOB,
                                               peventsrc      IN VARCHAR2,
                                               peventrcv      IN VARCHAR2,
                                               poperation     IN VARCHAR2,
                                               poperationname IN VARCHAR2,
                                               psourcequeue   IN VARCHAR2,
                                               psourceqm      IN VARCHAR2,
                                               ptargetqueue   IN VARCHAR2,
                                               ptargetqm      IN VARCHAR2,
                                               preplyqueue    IN VARCHAR2,
                                               preplyqm       IN VARCHAR2,
                                               peventmsg      IN CLOB)

 IS
  veventdate       TIMESTAMP
    WITH TIME ZONE;
  vpartdate        DATE;
  vprocstatusid    NUMBER;
  veventsrc        NUMBER;
  veventrcv        NUMBER;
  voperationid     NUMBER;
  voperationnameid NUMBER;
  vsourcequeueid   NUMBER;
  vsourceqmid      NUMBER;
  vtargetqueueid   NUMBER;
  vtargetqmid      NUMBER;
  vreplyqueueid    NUMBER;
  vreplyqmid       NUMBER;
  vlocaltimezone   VARCHAR2(128);
  veventmsg        CLOB;

BEGIN
  select DBTIMEZONE into vlocaltimezone from dual;
  veventdate := TO_TIMESTAMP_TZ(pdate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM');
  vpartdate  := CAST((veventdate AT TIME ZONE TZ_OFFSET(vlocaltimezone)) AS DATE);

  BEGIN
    SELECT PROC_STATUS_ID
      INTO vprocstatusid
      FROM &1..CDSTATUSTP
     WHERE NAME = pprocstatus;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      INSERT INTO &1..CDSTATUSTP (NAME) VALUES (pprocstatus);
      COMMIT;
  END;
  IF vprocstatusid IS NULL THEN
    SELECT PROC_STATUS_ID
      INTO vprocstatusid
      FROM &1..CDSTATUSTP
     WHERE NAME = pprocstatus;
  END IF;

  BEGIN
    SELECT COMPONENT_ID
      INTO veventsrc
      FROM &1..CDCOMPONENTTP
     WHERE NAME = peventsrc;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      INSERT INTO &1..CDCOMPONENTTP (NAME) VALUES (peventsrc);
      COMMIT;
  END;
  IF veventsrc IS NULL THEN
    SELECT COMPONENT_ID
      INTO veventsrc
      FROM &1..CDCOMPONENTTP
     WHERE NAME = peventsrc;
  END IF;

  BEGIN
    SELECT COMPONENT_ID
      INTO veventrcv
      FROM &1..CDCOMPONENTTP
     WHERE NAME = peventrcv;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      INSERT INTO &1..CDCOMPONENTTP (NAME) VALUES (peventrcv);
      COMMIT;
  END;
  IF veventrcv IS NULL THEN
    SELECT COMPONENT_ID
      INTO veventrcv
      FROM &1..CDCOMPONENTTP
     WHERE NAME = peventrcv;
  END IF;

  BEGIN
    SELECT OPERATION_ID
      INTO voperationid
      FROM &1..CDOPERATIONTP
     WHERE NAME = poperation;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      INSERT INTO &1..CDOPERATIONTP (NAME) VALUES (poperation);
      COMMIT;
  END;
  IF voperationid IS NULL THEN
    SELECT OPERATION_ID
      INTO voperationid
      FROM &1..CDOPERATIONTP
     WHERE NAME = poperation;
  END IF;

  IF poperationname IS NOT NULL THEN
    BEGIN
      SELECT OPERATION_NAME_ID
        INTO voperationnameid
        FROM &1..CDOPERATIONNAMETP
       WHERE NAME = poperationname;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO &1..CDOPERATIONNAMETP
          (NAME)
        VALUES
          (poperationname);
        COMMIT;
    END;
    IF voperationnameid IS NULL THEN
      SELECT OPERATION_NAME_ID
        INTO voperationnameid
        FROM &1..CDOPERATIONNAMETP
       WHERE NAME = poperationname;
    END IF;
  ELSE
    voperationnameid := NULL;
  END IF;

  IF psourcequeue IS NOT NULL THEN
    BEGIN
      SELECT QUEUE_ID
        INTO vsourcequeueid
        FROM &1..CDQUEUETP
       WHERE NAME = psourcequeue;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO &1..CDQUEUETP (NAME) VALUES (psourcequeue);
        COMMIT;
    END;
    IF vsourcequeueid IS NULL THEN
      SELECT QUEUE_ID
        INTO vsourcequeueid
        FROM &1..CDQUEUETP
       WHERE NAME = psourcequeue;
    END IF;
  ELSE
    vsourcequeueid := NULL;
  END IF;

  IF psourceqm IS NOT NULL THEN
    BEGIN
      SELECT QM_ID
        INTO vsourceqmid
        FROM &1..CDQMTP
       WHERE NAME = psourceqm;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO &1..CDQMTP (NAME) VALUES (psourceqm);
        COMMIT;
    END;
    IF vsourceqmid IS NULL THEN
      SELECT QM_ID
        INTO vsourceqmid
        FROM &1..CDQMTP
       WHERE NAME = psourceqm;
    END IF;
  ELSE
    vsourceqmid := NULL;
  END IF;

  IF ptargetqueue IS NOT NULL THEN
    BEGIN
      SELECT QUEUE_ID
        INTO vtargetqueueid
        FROM &1..CDQUEUETP
       WHERE NAME = ptargetqueue;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO &1..CDQUEUETP (NAME) VALUES (ptargetqueue);
        COMMIT;
    END;
    IF vtargetqueueid IS NULL THEN
      SELECT QUEUE_ID
        INTO vtargetqueueid
        FROM &1..CDQUEUETP
       WHERE NAME = ptargetqueue;
    END IF;
  ELSE
    vtargetqueueid := NULL;
  END IF;

  IF ptargetqm IS NOT NULL THEN
    BEGIN
      SELECT QM_ID
        INTO vtargetqmid
        FROM &1..CDQMTP
       WHERE NAME = ptargetqm;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO &1..CDQMTP (NAME) VALUES (ptargetqm);
        COMMIT;
    END;
    IF vtargetqmid IS NULL THEN
      SELECT QM_ID
        INTO vtargetqmid
        FROM &1..CDQMTP
       WHERE NAME = ptargetqm;
    END IF;
  ELSE
    vtargetqmid := NULL;
  END IF;

  IF preplyqueue IS NOT NULL THEN
    BEGIN
      SELECT QUEUE_ID
        INTO vreplyqueueid
        FROM &1..CDQUEUETP
       WHERE NAME = preplyqueue;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO &1..CDQUEUETP (NAME) VALUES (preplyqueue);
        COMMIT;
    END;
    IF vreplyqueueid IS NULL THEN
      SELECT QUEUE_ID
        INTO vreplyqueueid
        FROM &1..CDQUEUETP
       WHERE NAME = preplyqueue;
    END IF;
  ELSE
    vreplyqueueid := NULL;
  END IF;

  IF preplyqm IS NOT NULL THEN
    BEGIN
      SELECT QM_ID
        INTO vreplyqmid
        FROM &1..CDQMTP
       WHERE NAME = preplyqm;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO &1..CDQMTP (NAME) VALUES (preplyqm);
        COMMIT;
    END;
    IF vreplyqmid IS NULL THEN
      SELECT QM_ID
        INTO vreplyqmid
        FROM &1..CDQMTP
       WHERE NAME = preplyqm;
    END IF;
  ELSE
    vreplyqmid := NULL;
  END IF;

  DBMS_LOB.CREATETEMPORARY(veventmsg, true);
  DBMS_LOB.OPEN(veventmsg, DBMS_LOB.LOB_READWRITE);
  IF peventmsg IS NOT NULL THEN
    veventmsg := peventmsg;
  END IF;

  INSERT INTO &1..EVENT
    (RQ_UID,
     EVENT_DATE,
     PROC_STATUS_ID,
     ERROR_TEXT,
     EVENT_SOURCE_ID,
     EVENT_RECIEVER_ID,
     OPERATION_ID,
     OPERATION_NAME_ID,
     SOURCE_QUEUE_ID,
     SOURCE_QM_ID,
     TARGET_QUEUE_ID,
     TARGET_QM_ID,
     REPLY_QUEUE_ID,
     REPLY_QM_ID,
     EVENT_MSG,
     PART_DATE,
     ARC_STATUS)
  VALUES
    (prquid,
     veventdate,
     vprocstatusid,
     perrortext,
     veventsrc,
     veventrcv,
     voperationid,
     voperationnameid,
     vsourcequeueid,
     vsourceqmid,
     vtargetqueueid,
     vtargetqmid,
     vreplyqueueid,
     vreplyqmid,
     veventmsg,
     vpartdate,
     0);

  DBMS_LOB.FREETEMPORARY(veventmsg);
  --COMMIT;
END WRITE_EVENT;
/


CREATE OR REPLACE PROCEDURE &1..GET_PARTITION_INFO(
ppartname IN VARCHAR2,
prowcount OUT NUMBER,
pmineventid OUT NUMBER,
pmaxeventid OUT NUMBER,
pmineventdate OUT DATE,
pmaxeventdate OUT DATE
)  IS
  vquery         VARCHAR2(2000);
BEGIN
    -- Определяем общее число записей в партиции:
  vquery := 'SELECT count(*) FROM &1..EVENT PARTITION(' || ppartname || ')';
  EXECUTE IMMEDIATE vquery
    INTO prowcount;
    -- Определяем Минимальный EVENT_ID:
  vquery := 'SELECT min(EVENT_ID) FROM &1..EVENT PARTITION(' || ppartname || ')';
  EXECUTE IMMEDIATE vquery
    INTO pmineventid;
    -- Определяем Максимальный EVENT_ID:
  vquery := 'SELECT max(EVENT_ID) FROM &1..EVENT PARTITION(' || ppartname || ')';
  EXECUTE IMMEDIATE vquery
    INTO pmaxeventid;
    -- Определяем Минимальный PART_DATE:
  vquery := 'SELECT min(PART_DATE) FROM &1..EVENT PARTITION(' || ppartname || ')';
  EXECUTE IMMEDIATE vquery
    INTO pmineventdate;
    -- Определяем Максимальный PART_DATE:
  vquery := 'SELECT max(PART_DATE) FROM &1..EVENT PARTITION(' || ppartname || ')';
  EXECUTE IMMEDIATE vquery
    INTO pmaxeventdate;
END;
/

BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => '&1..REPLACE_EVENT_PARTITION_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN &1..REPLACE_EVENT_PARTITION; END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'freq=daily;byhour=1;byminute=0;bysecond=0',
    end_date        => NULL,
    enabled         => TRUE,
    comments        => 'Job for replace partitions (table: EVENT).');
END;
/


BEGIN
  DBMS_SCHEDULER.run_job (job_name            => '&1..REPLACE_EVENT_PARTITION_JOB',
                          use_current_session => FALSE);
END;
/














--Расширенное логирование

INSERT INTO &1..LOGPARAM (PARAM_ID, NAME, PARAM_VALUE, DESCRIPTION) VALUES (2, 'PARTCOUNT', 7, 'Число дней, за которые хранятся логи в таблице &1..TRANSACTION');
COMMIT;

-- Таблица для хранения журнала транзакций КСШ, который содержит данные расширенного логирования
CREATE TABLE &1..TRANSACTION (
    TRANSACTION_ID NUMBER NOT NULL,
    RQ_UID VARCHAR2(32) NOT NULL,
    TRANSACTION_DATE TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    TRANSACTION_DURATION NUMBER,
    SOURCE_SYSTEM_ID NUMBER,
    TARGET_SYSTEM_ID NUMBER,
    CLIENT_BANK_ID NUMBER,
    OPERATION_NAME_ID NUMBER,
    OPERATION_STATUS_ID NUMBER,
    REPLY_CODE_ID NUMBER,
	ERROR_MSG VARCHAR2(1024),
	PART_DATE DATE NOT NULL
  )
PARTITION BY RANGE
 (PART_DATE)
    (
        PARTITION P20000101 VALUES LESS THAN (TO_DATE('20001001','yyyymmdd'))
     );

DECLARE
  vpartdate     VARCHAR2(32);
  vnextpartdate VARCHAR2(32);
  vquery        VARCHAR2(2000);
  vinterval     NUMBER;
  vlogdayscount NUMBER;
  i             NUMBER;
  j             NUMBER;
BEGIN
  SELECT PARAM_VALUE
    INTO vlogdayscount
    FROM &1..LOGPARAM
   WHERE PARAM_ID = 2;

  vpartdate     := TO_CHAR(trunc(sysdate) - vlogdayscount, 'YYYYMMDDHH24');
  vnextpartdate := vpartdate;

  -- Запас 2 дня по логам
  FOR i IN 1 .. vlogdayscount + 2 LOOP
  
    FOR j IN 1 .. 24 LOOP
    
      vnextpartdate := TO_CHAR(TO_DATE(vnextpartdate, 'YYYYMMDDHH24') +
                               1 / 24,
                               'YYYYMMDDHH24');
      vquery        := 'ALTER TABLE &1..TRANSACTION ADD PARTITION P' ||
                       vpartdate || ' VALUES LESS THAN (TO_DATE(''' ||
                       vnextpartdate ||
                       ''',''YYYYMMDDHH24'')) 
    TABLESPACE ESBEXTLOGDATA PCTFREE 0 INITRANS 1 MAXTRANS 255 STORAGE( INITIAL 1M PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED )
    ';
      EXECUTE IMMEDIATE vquery;
      vpartdate := vnextpartdate;
    
    END LOOP;
  END LOOP;
  EXECUTE IMMEDIATE 'ALTER TABLE &1..TRANSACTION DROP PARTITION P20000101';
END;
/



CREATE TABLE &1..CDSYSTEMTP (
    SYSTEM_ID NUMBER NOT NULL,
    NAME VARCHAR2(200) NOT NULL,
    DESCRIPTION VARCHAR2(100),
    LAST_UPDATE_DT TIMESTAMP(6) WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    LAST_UPDATE_USER VARCHAR2(12)
  )
  TABLESPACE ESBDATA;

CREATE TABLE &1..CDREPLYCODETP (
    REPLY_CODE_ID NUMBER NOT NULL,
    NAME VARCHAR2(200) NOT NULL,
    DESCRIPTION VARCHAR2(100),
    LAST_UPDATE_DT TIMESTAMP(6) WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    LAST_UPDATE_USER VARCHAR2(12)
  )
  TABLESPACE ESBDATA;
  
 
  
  
  
/*
CREATE TABLE &1..CDOPERATIONNAMETP (
    OPERATION_NAME_ID NUMBER NOT NULL,
    NAME VARCHAR2(200) NOT NULL,
    DESCRIPTION VARCHAR2(100),
    LAST_UPDATE_DT TIMESTAMP(6) WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    LAST_UPDATE_USER VARCHAR2(12)
  )
  TABLESPACE ESBDATA;

CREATE TABLE &1..CDSTATUSTP (
    PROC_STATUS_ID NUMBER NOT NULL,
    NAME VARCHAR2(10) NOT NULL,
    DESCRIPTION VARCHAR2(100),
    LAST_UPDATE_DT TIMESTAMP(6) WITH TIME ZONE DEFAULT SYSTIMESTAMP NOT NULL,
    LAST_UPDATE_USER VARCHAR2(12)
  )
  TABLESPACE ESBDATA;
*/  


CREATE INDEX &1..I1_TRANSACTION ON &1..TRANSACTION(TRANSACTION_ID) LOCAL; 
CREATE UNIQUE INDEX &1..I2_TRANSACTION ON &1..TRANSACTION(RQ_UID, PART_DATE) LOCAL; 


 

ALTER TABLE &1..CDSYSTEMTP ADD CONSTRAINT P_CDSYSTEMTP PRIMARY KEY (SYSTEM_ID) USING INDEX TABLESPACE ESBINDEX; 
ALTER TABLE &1..CDREPLYCODETP ADD CONSTRAINT P_CDREPLYCODETP PRIMARY KEY (REPLY_CODE_ID) USING INDEX  TABLESPACE ESBINDEX;

ALTER TABLE &1..CDSYSTEMTP ADD CONSTRAINT U1_CDSYSTEMTP UNIQUE (NAME) USING INDEX TABLESPACE ESBINDEX; 
ALTER TABLE &1..CDREPLYCODETP ADD CONSTRAINT U1_CDREPLYCODETP UNIQUE (NAME) USING INDEX TABLESPACE ESBINDEX; 


	

ALTER TABLE &1..TRANSACTION ADD CONSTRAINT EVENT_CDSYSTEMTP_FK1 FOREIGN KEY (SOURCE_SYSTEM_ID)
  REFERENCES &1..CDSYSTEMTP (SYSTEM_ID)
  ON DELETE CASCADE;

ALTER TABLE &1..TRANSACTION ADD CONSTRAINT EVENT_CDSYSTEMTP_FK2 FOREIGN KEY (TARGET_SYSTEM_ID)
  REFERENCES &1..CDSYSTEMTP (SYSTEM_ID)
  ON DELETE CASCADE;

ALTER TABLE &1..TRANSACTION ADD CONSTRAINT EVENT_CDOPERATIONNAMETP_FK2 FOREIGN KEY (OPERATION_NAME_ID)
  REFERENCES &1..CDOPERATIONNAMETP (OPERATION_NAME_ID)
  ON DELETE CASCADE;

ALTER TABLE &1..TRANSACTION ADD CONSTRAINT EVENT_CDSTATUSTP_FK2 FOREIGN KEY (OPERATION_STATUS_ID)
  REFERENCES &1..CDSTATUSTP (PROC_STATUS_ID)
  ON DELETE CASCADE;

ALTER TABLE &1..TRANSACTION ADD CONSTRAINT EVENT_CDREPLYCODETP_FK FOREIGN KEY (REPLY_CODE_ID)
  REFERENCES &1..CDREPLYCODETP (REPLY_CODE_ID)
  ON DELETE CASCADE;




  
CREATE SEQUENCE &1..SEQ_CDSYSTEMTP
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;


CREATE SEQUENCE &1..SEQ_CDREPLYCODETP
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;



CREATE SEQUENCE &1..SEQ_TRANSACTION
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;



CREATE OR REPLACE TRIGGER &1..TR_CDSYSTEMTP_I
BEFORE INSERT ON &1..CDSYSTEMTP
    FOR EACH ROW

BEGIN
    SELECT &1..SEQ_CDSYSTEMTP.NEXTVAL INTO :NEW.SYSTEM_ID FROM DUAL;
END;
/


CREATE OR REPLACE TRIGGER &1..TR_CDREPLYCODETP_I
BEFORE INSERT ON &1..CDREPLYCODETP
    FOR EACH ROW

BEGIN
    SELECT &1..SEQ_CDREPLYCODETP.NEXTVAL INTO :NEW.REPLY_CODE_ID FROM DUAL;
END;
/


CREATE OR REPLACE TRIGGER &1..TR_TRANSACTION_I
BEFORE INSERT ON &1..TRANSACTION
    FOR EACH ROW

BEGIN
    SELECT &1..SEQ_TRANSACTION.NEXTVAL INTO :NEW.TRANSACTION_ID FROM DUAL;
END;
/


CREATE OR REPLACE PROCEDURE &1..WRITE_TRANSACTION_LOG(prquid           IN VARCHAR2,
                                                         prqtm            IN VARCHAR2,
                                                         prstm            IN VARCHAR2,
                                                         psourcesystem    IN VARCHAR2,
                                                         ptargetsystem    IN VARCHAR2,
                                                         pclienttbid      IN VARCHAR2,
                                                         poperationname   IN VARCHAR2,
                                                         poperationstatus IN VARCHAR2,
                                                         preplycode       IN VARCHAR2,
                                                         perrormsg        IN VARCHAR2)

 IS
  vrqtm                TIMESTAMP
    WITH TIME ZONE;
  vrstm                TIMESTAMP
    WITH TIME ZONE;
  vpartdate            DATE;
  vsourcesystemid      NUMBER;
  vtargetsystemid      NUMBER;
  voperationnameid     NUMBER;
  voperationstatusid   NUMBER;
  vreplycodeid         NUMBER;
  vlocaltimezone       VARCHAR2(128);
  vtransactionduration NUMBER;
  vclienttb            NUMBER;

  vrqtmold                TIMESTAMP
    WITH TIME ZONE;
  vtransactiondurationold NUMBER;
  vsourcesystemidold      NUMBER;
  vtargetsystemidold      NUMBER;
  vclienttbidold          NUMBER;
  voperationnameidold     NUMBER;
  voperationstatusidold   NUMBER;
  vreplycodeidold         NUMBER;
  verrormsgold            VARCHAR2(1024);

BEGIN
  select DBTIMEZONE into vlocaltimezone from dual;
  vrqtm := TO_TIMESTAMP_TZ(prqtm, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM');
  vrstm := TO_TIMESTAMP_TZ(prstm, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM');

  SELECT (extract(DAY FROM vrstm - vrqtm) * 24 * 60 * 60 * 1000) +
         (extract(HOUR FROM vrstm - vrqtm) * 60 * 60 * 1000) +
         (extract(MINUTE FROM vrstm - vrqtm) * 60 * 1000) +
         (extract(SECOND FROM vrstm - vrqtm) * 1000)
    into vtransactionduration
    FROM dual;

  vpartdate := TRUNC(CAST((vrqtm AT TIME ZONE TZ_OFFSET(vlocaltimezone)) AS DATE),
                     'HH24');
  vclienttb := to_number(pclienttbid);

  IF psourcesystem IS NOT NULL THEN
    BEGIN
      SELECT SYSTEM_ID
        INTO vsourcesystemid
        FROM &1..CDSYSTEMTP
       WHERE NAME = psourcesystem;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO &1..CDSYSTEMTP (NAME) VALUES (psourcesystem);
        COMMIT;
    END;
    IF vsourcesystemid IS NULL THEN
      SELECT SYSTEM_ID
        INTO vsourcesystemid
        FROM &1..CDSYSTEMTP
       WHERE NAME = psourcesystem;
    END IF;
  ELSE
    vsourcesystemid := NULL;
  END IF;

  IF ptargetsystem IS NOT NULL THEN
    BEGIN
      SELECT SYSTEM_ID
        INTO vtargetsystemid
        FROM &1..CDSYSTEMTP
       WHERE NAME = ptargetsystem;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO &1..CDSYSTEMTP (NAME) VALUES (ptargetsystem);
        COMMIT;
    END;
    IF vtargetsystemid IS NULL THEN
      SELECT SYSTEM_ID
        INTO vtargetsystemid
        FROM &1..CDSYSTEMTP
       WHERE NAME = ptargetsystem;
    END IF;
  ELSE
    vtargetsystemid := NULL;
  END IF;

  IF poperationname IS NOT NULL THEN
    BEGIN
      SELECT OPERATION_NAME_ID
        INTO voperationnameid
        FROM &1..CDOPERATIONNAMETP
       WHERE NAME = poperationname;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO &1..CDOPERATIONNAMETP
          (NAME)
        VALUES
          (poperationname);
        COMMIT;
    END;
    IF voperationnameid IS NULL THEN
      SELECT OPERATION_NAME_ID
        INTO voperationnameid
        FROM &1..CDOPERATIONNAMETP
       WHERE NAME = poperationname;
    END IF;
  ELSE
    voperationnameid := NULL;
  END IF;

  IF poperationstatus IS NOT NULL THEN
    BEGIN
      SELECT PROC_STATUS_ID
        INTO voperationstatusid
        FROM &1..CDSTATUSTP
       WHERE NAME = poperationstatus;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO &1..CDSTATUSTP (NAME) VALUES (poperationstatus);
        COMMIT;
    END;
    IF voperationstatusid IS NULL THEN
      SELECT PROC_STATUS_ID
        INTO voperationstatusid
        FROM &1..CDSTATUSTP
       WHERE NAME = poperationstatus;
    END IF;
  
  ELSE
    voperationstatusid := NULL;
  END IF;

  IF preplycode IS NOT NULL THEN
    BEGIN
      SELECT REPLY_CODE_ID
        INTO vreplycodeid
        FROM &1..CDREPLYCODETP
       WHERE NAME = preplycode;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO &1..CDREPLYCODETP (NAME) VALUES (preplycode);
        COMMIT;
    END;
    IF vreplycodeid IS NULL THEN
      SELECT REPLY_CODE_ID
        INTO vreplycodeid
        FROM &1..CDREPLYCODETP
       WHERE NAME = preplycode;
    END IF;
  ELSE
    vreplycodeid := NULL;
  END IF;

  BEGIN
    INSERT INTO &1..TRANSACTION
      (RQ_UID,
       TRANSACTION_DATE,
       TRANSACTION_DURATION,
       SOURCE_SYSTEM_ID,
       TARGET_SYSTEM_ID,
       CLIENT_BANK_ID,
       OPERATION_NAME_ID,
       OPERATION_STATUS_ID,
       REPLY_CODE_ID,
       ERROR_MSG,
       PART_DATE)
    VALUES
      (prquid,
       vrqtm,
       vtransactionduration,
       vsourcesystemid,
       vtargetsystemid,
       vclienttb,
       voperationnameid,
       voperationstatusid,
       vreplycodeid,
       perrormsg,
       vpartdate);
  
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
    
      select TRANSACTION_DATE,
             TRANSACTION_DURATION,
             SOURCE_SYSTEM_ID,
             TARGET_SYSTEM_ID,
             CLIENT_BANK_ID,
             OPERATION_NAME_ID,
             OPERATION_STATUS_ID,
             REPLY_CODE_ID,
             ERROR_MSG
        INTO vrqtmold,
             vtransactiondurationold,
             vsourcesystemidold,
             vtargetsystemidold,
             vclienttbidold,
             voperationnameidold,
             voperationstatusidold,
             vreplycodeidold,
             verrormsgold
        FROM &1..TRANSACTION
       WHERE RQ_UID = prquid
         and PART_DATE = vpartdate;
    
      UPDATE &1..TRANSACTION
         SET TRANSACTION_DATE     = NVL(vrqtmold, vrqtm),
             TRANSACTION_DURATION = NVL(vtransactiondurationold,
                                        vtransactionduration),
             SOURCE_SYSTEM_ID     = NVL(vsourcesystemidold, vsourcesystemid),
             TARGET_SYSTEM_ID     = NVL(vtargetsystemidold, vtargetsystemid),
             CLIENT_BANK_ID       = NVL(vclienttbidold, pclienttbid),
             OPERATION_NAME_ID    = NVL(voperationnameidold,
                                        voperationnameid),
             OPERATION_STATUS_ID  = NVL(voperationstatusidold,
                                        voperationstatusid),
             REPLY_CODE_ID        = NVL(vreplycodeidold, vreplycodeid),
             ERROR_MSG            = NVL(verrormsgold, perrormsg)
       WHERE RQ_UID = prquid
         and PART_DATE = vpartdate;
    
  END;

END WRITE_TRANSACTION_LOG;
/

--запуск:
/*
begin
  &1..WRITE_TRANSACTION_LOG(prquid           => '10000000000000000000039992239942',
                       prqtm            => '2012-03-05T17:00:00.000+04:00',
                       prstm            => '2012-03-05T17:00:05.000+04:00',
                       psourcesystem    => 'BP_ES',
                       ptargetsystem    => 'urn:sbrfsystems:99-cod',
                       pclienttbid      => 99,
                       poperationname   => 'CustInqRq',
                       poperationstatus => 'SUCCESS',
                       preplycode       => '100',
                       perrormsg        => null);
  commit;
end;

*/


CREATE OR REPLACE VIEW &1..TRANSACTIONLOG AS
SELECT e.TRANSACTION_ID       "TRANSACTION_ID",
       e.RQ_UID               "RQ_UID",
       e.TRANSACTION_DATE     "TRANSACTION_DATE",
       e.TRANSACTION_DURATION "TRANSACTION_DURATION",
       css.NAME               "SOURCE_SYSTEM",
       cst.NAME               "TARGET_SYSTEM",
       e.CLIENT_BANK_ID       "CLIENT_BANK",
       con.NAME               "OPERATION_NAME",
       cs.NAME                "OPERATION_STATUS",
       cr.NAME                "REPLY_CODE",
       e.ERROR_MSG            "ERROR_MSG",
       e.PART_DATE            "PART_DATE"
  FROM &1..TRANSACTION       e,
       &1..CDSYSTEMTP        css,
       &1..CDSYSTEMTP        cst,
       &1..CDOPERATIONNAMETP con,
       &1..CDSTATUSTP        cs,
       &1..CDREPLYCODETP     cr
 WHERE e.SOURCE_SYSTEM_ID = css.SYSTEM_ID(+)
   AND e.TARGET_SYSTEM_ID = cst.SYSTEM_ID(+)
   AND e.OPERATION_NAME_ID = con.OPERATION_NAME_ID(+)
   AND e.OPERATION_STATUS_ID = cs.PROC_STATUS_ID(+)
   AND e.REPLY_CODE_ID = cr.REPLY_CODE_ID(+);



CREATE OR REPLACE VIEW &1..PARTSTATUS_TRANSACTION AS
-- Смещение  trunc(sysdate +1 - 1/24) указано для того, чтобы учитывать запуск джоба в 1 ночи. Те удаление будт завтра относительно текущего дня (это 1), а чтобы смещение было правильным в период с 0 до 1 вычитается 1/24
SELECT TABLE_NAME,
       PARTITION_NAME,
       NUM_ROWS,
       &1..CONVERT_PARTDATE_TO_DATE(TABLE_NAME, PARTITION_NAME) AS PART_DATE,
       CASE
         WHEN &1..CONVERT_PARTDATE_TO_DATE(TABLE_NAME, PARTITION_NAME) =
              TO_DATE(TO_CHAR(sysdate, 'YYYYMMDDHH24'), 'YYYYMMDDHH24') then
          'В партицию производится запись данных'
         WHEN &1..CONVERT_PARTDATE_TO_DATE(TABLE_NAME, PARTITION_NAME) >
              TO_DATE(TO_CHAR(sysdate, 'YYYYMMDDHH24'), 'YYYYMMDDHH24') then
          'Незаполненная партиция для хранения данных'
         WHEN &1..CONVERT_PARTDATE_TO_DATE(TABLE_NAME, PARTITION_NAME) <=
              trunc(sysdate + 2 - 1/24 ) -
              (SELECT PARAM_VALUE FROM &1..LOGPARAM WHERE PARAM_ID = 2) AND
              &1..CONVERT_PARTDATE_TO_DATE(TABLE_NAME, PARTITION_NAME) >
              trunc(sysdate +1 - 1/24)  -
              (SELECT PARAM_VALUE FROM &1..LOGPARAM WHERE PARAM_ID = 2) then
          'Партиция для хранения данных, которая будет удалена автоматически'
         WHEN &1..CONVERT_PARTDATE_TO_DATE(TABLE_NAME, PARTITION_NAME) <=
              trunc(sysdate +1 - 1/24) -
              (SELECT PARAM_VALUE FROM &1..LOGPARAM WHERE PARAM_ID = 2) then
          'Партиция для хранения данных, которую нужно удалить администратору КСШ'
         ELSE
          'Партиция для хранения данных'
       END AS PART_INFO
  FROM all_tab_partitions
 WHERE TABLE_OWNER = 'ESBLOG'
   AND table_name = 'TRANSACTION'
 ORDER BY partition_name;




CREATE OR REPLACE PROCEDURE &1..REPLACE_TRANSACTION_PARTITION IS
  vdroppartdate       VARCHAR2(32);
  vcreatepartdate     VARCHAR2(32);
  vcreatenextpartdate VARCHAR2(32);
  vquery              VARCHAR2(2000);
  vlogdayscount       NUMBER;
  i                   NUMBER;

  partition_does_not_exist EXCEPTION;
  PRAGMA EXCEPTION_INIT(partition_does_not_exist, -2149);
BEGIN
  SELECT PARAM_VALUE
    INTO vlogdayscount
    FROM &1..LOGPARAM
   WHERE PARAM_ID = 2;

  vdroppartdate       := TO_CHAR(trunc(sysdate) - vlogdayscount,
                                 'YYYYMMDDHH24');
  vcreatepartdate     := TO_CHAR(trunc(sysdate) + 2, 'YYYYMMDDHH24');
  vcreatenextpartdate := vcreatepartdate;

  BEGIN
  
    FOR i IN 1 .. 24 LOOP
      vquery := 'ALTER TABLE &1..TRANSACTION DROP PARTITION P' ||
                vdroppartdate;
      EXECUTE IMMEDIATE vquery;
      vdroppartdate := TO_CHAR(TO_DATE(vdroppartdate, 'YYYYMMDDHH24') +
                               1 / 24,
                               'YYYYMMDDHH24');
    END LOOP;
  EXCEPTION
    WHEN partition_does_not_exist THEN
      NULL;
  END;
 
  FOR i IN 1 .. 24 LOOP
  
         vcreatenextpartdate := TO_CHAR(TO_DATE(vcreatenextpartdate, 'YYYYMMDDHH24') +
                               1 / 24,
                               'YYYYMMDDHH24');
      vquery        := 'ALTER TABLE &1..TRANSACTION ADD PARTITION P' ||
                       vcreatepartdate || ' VALUES LESS THAN (TO_DATE(''' ||
                       vcreatenextpartdate ||
                       ''',''YYYYMMDDHH24'')) 
    TABLESPACE ESBEXTLOGDATA PCTFREE 0 INITRANS 1 MAXTRANS 255 STORAGE( INITIAL 1M PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS UNLIMITED )
    ';
      EXECUTE IMMEDIATE vquery;
      vcreatepartdate := vcreatenextpartdate;
    
  END LOOP;

  COMMIT;
END;
/


BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => '&1..REPLACE_TRANSACTION_PART_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN &1..REPLACE_TRANSACTION_PARTITION; END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'freq=daily;byhour=1;byminute=0;bysecond=0',
    end_date        => NULL,
    enabled         => TRUE,
    comments        => 'Job for replace partitions (table: TRANSACTION).');
END;
/


BEGIN
  DBMS_SCHEDULER.run_job (job_name            => '&1..REPLACE_TRANSACTION_PART_JOB',
                          use_current_session => FALSE);
END;
/










