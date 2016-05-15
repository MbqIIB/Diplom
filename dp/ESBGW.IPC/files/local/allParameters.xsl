<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:Config="http://sberbank.ru/sbt/config"
extension-element-prefixes="Config">

    <xsl:param name="Config:routes" select="'local:///routes/IGRoutes.xml'" />
    <xsl:param name="Config:diag" select="'local:///dict/ipc/diagnostic.xml'" />

		<!-- менеджер логирования -->
	<xsl:param name="Config:MQLogConn" select="'LOG.MQGR'"/>
	<!-- менеджер расширенного логирования -->	
	<xsl:param name="Config:MQExtLogConn" select="'LOG.MQGR'"/>
	
   <!--Очередь для логирования сообщений-->
    <xsl:param name="Config:QModForLog" select="'EVENT.LOGGING'" />
    <xsl:param name="Config:QExtLog" select="'EVENT.TRANSACTION.LOG'" />	
    <xsl:param name="Config:QForError" select="'EVENT.LOGGING.OLD'" />
	<xsl:param name="Config:QForErrorForMDM" select="'EVENT.LOGGING.OLD'" />    
     
	<!-- Категория лога на Datapower-->
    <xsl:param name="Config:LogCategory" select="'ESBGW'"/>    <!-- 'bp' or 'bpdev' -->
    
	<!-- Логирование вкл/выкл. Касается только нового через ESB.LOG.xsl)-->
    <xsl:param name="Config:LogEnabled" select="'on'"/>    <!-- 'on' or 'off'. По умолчанию включено -->    
    
    <!-- Расширенное логирование вкл/выкл. ESB.EXT.LOG.xsl)-->
    <xsl:param name="Config:ExtLogEnabled" select="'on'"/>    <!-- 'on' or 'off'.  -->  
    
	<!--Менеджеры очередей-->
    <xsl:param name="Config:MQMEsb" select="'IN.MQGR'"/><!--Менеджер со стороны шины IRUS.ESB.GW1-->
    <xsl:param name="Config:MQMCB" select="'OUT.MQGR'"/><!--Менеджер со стороны ДБ IRUS.ESB.OUT.GW1-->    
	<!--Очереди-->
	<!--M99.ESB.GW1-->
	<xsl:param name="Config:toEsb" select="'IRUS.SBI.IN.GW1'"/><!--Очередь к шине-->
	<xsl:param name="Config:toEsbMDM" select="'IRUS.SBI.IN.GW1'"/><!--Очередь к шине-->
	<xsl:param name="Config:toCB" select="'DB.SBI.OUT.GW1'"/><!--Очередь к ДБ. TODO: очередь не верна, так как у банков своя, а для адаптеров то же, надо какое-то значение по умолчанию, откуда потом общий сервис будет читать.-->
	
    <!--default Parameters-->
    <xsl:param name="Config:MQConn" select="'IRUS.SBI.GW1'"/><!--Queue Manager по умолчанию-->
    <xsl:param name="Config:MQName" select="'IRUS.SBI.GW1'"/><!--Queue Manager по умолчанию как ReplyQM-->
    <xsl:param name="Config:QOutForSV" select="'EVENT.LOGGING.OLD'"/><!--Очередь по умолчанию для вычитки сообщений через функцию-->
    <xsl:param name="Config:SystemError" select="'-100'"/><!--код ошибки по умолчанию-->
    <xsl:param name="Config:TimeoutError" select="'-105'"/><!--код ошибки при таймауте по умолчанию-->
	<xsl:param name="Config:ESBTimeout" select="'60000'"/>      
	<xsl:param name="Config:YandexTimeout" select="'60000'"/>    
</xsl:stylesheet>
