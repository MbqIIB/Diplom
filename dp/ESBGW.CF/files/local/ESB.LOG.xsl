<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:dp="http://www.datapower.com/extensions"
	xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:Config="http://sberbank.ru/sbt/config"
	xmlns:mqFunc="http://sberbank.ru/sbt/functions/mq"
	xmlns:XslFunc="http://sberbank.ru/sbt/functions/xsl"
	xmlns:wsdlbp="http://sbrf.ru/baseproduct/cod/adapter/1" 
	xmlns:bp="http://sbrf.ru/baseproduct/codadapter/schema/1" 	
	extension-element-prefixes="dp dpconfig Config mqFunc XslFunc date" exclude-result-prefixes="dp soap date Config mqFunc XslFunc wsdlbp bp dpconfig" >
	<xsl:import href="local:///allMQFunction.xsl"/>
	<xsl:import href="local:///allXSLFunction.xsl"/>
	<xsl:import href="local:///allParameters.xsl"/>
	<xsl:output omit-xml-declaration="yes" dp:escaping="minimum"/>
	
	<xsl:param name="dpconfig:eventsrc" select="'1'" />
	<dp:param name="dpconfig:eventsrc">
		<display>eventsource string</display>
		<default></default>
		<tab-override>basic</tab-override>
		<no-save-checkbox>true</no-save-checkbox>
	</dp:param>

<xsl:param name="dpconfig:eventrcv" select="'1'" />
	<dp:param name="dpconfig:eventrcv">
		<display>eventreceiver string</display>
		<default></default>
		<tab-override>basic</tab-override>
		<no-save-checkbox>true</no-save-checkbox>
	</dp:param>
	
	<xsl:param name="dpconfig:operation" select="'1'" />
	<dp:param name="dpconfig:operation">
		<display>operation string</display>
		<default></default>
		<tab-override>basic</tab-override>
		<no-save-checkbox>true</no-save-checkbox>
	</dp:param>
	
<xsl:template match="/">	


		<xsl:variable name="vRqUID">
			<xsl:choose>
				<xsl:when test="dp:variable('var://context/input/RqUID')">
					<xsl:copy-of select="dp:variable('var://context/input/RqUID')"/>			
				</xsl:when>
				<xsl:otherwise>
					<RqUID>UNKNOWN</RqUID>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>		
	
		
		<xsl:variable name="vInputMesType">
			<xsl:choose>
				<xsl:when test="dp:variable('var://context/input/InputMesType')">
					<xsl:copy-of select="dp:variable('var://context/input/InputMesType')"/>			
				</xsl:when>
				<xsl:otherwise>UNKNOWN</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="vOperUID">
			<xsl:copy-of select="dp:variable('var://context/input/OperUID')"/>
		</xsl:variable>
		<xsl:variable name="vRqTm">
			<xsl:choose>
				<xsl:when test="boolean(dp:variable('var://context/input/RqTm'))">
					<xsl:value-of select="dp:variable('var://context/input/RqTm')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="//*[local-name() = 'RqTm']"/>					
				</xsl:otherwise>		
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="msgsPath" select="concat('local:///dict/', dp:variable('var://context/input/gatewayType'), '/', 'msgs.xml')"></xsl:variable>

		<xsl:variable name="msgs" select="document($msgsPath)"></xsl:variable>	

		<xsl:variable name="xCode">
			<xsl:value-of select="dp:response-header('x-dp-response-code')"/>
		</xsl:variable>
		
		<xsl:variable name="error-message">
			<xsl:value-of select="dp:variable('var://service/error-message')"/>
		</xsl:variable>
		
		
		<xsl:variable name="esbErrorCode">
			<xsl:choose>
				<xsl:when test="$xCode = '2033'">
					<xsl:value-of select="$Config:TimeoutError"/></xsl:when>			
				<xsl:otherwise>
					<xsl:value-of select="$Config:SystemError"/>
				</xsl:otherwise>			
			</xsl:choose>	
		</xsl:variable>
		
		<xsl:variable name="esbStatus">
			<xsl:choose>
				<xsl:when test="$xCode = '2033'">TIMEOUT</xsl:when>			
				<xsl:otherwise>ERROR</xsl:otherwise>			
			</xsl:choose>	
		</xsl:variable>	
		
			
		<xsl:variable name="vOperation">
			<xsl:choose>
				<xsl:when test="$dpconfig:operation = 'ERROR'">
					<xsl:value-of select="$errorMessage"/>					
				</xsl:when>			
				<xsl:otherwise>
					<xsl:value-of select="$msgs/msgs/*[local-name()=$dpconfig:operation]"/>
				</xsl:otherwise>			
			</xsl:choose>	
		</xsl:variable>	
		
		<xsl:variable name="vProcStatus">
			<xsl:choose>
				<xsl:when test="$dpconfig:operation = 'ERROR'">
					<xsl:value-of select="$esbStatus"/>					
				</xsl:when>			
				<xsl:otherwise>SUCCESS</xsl:otherwise>			
			</xsl:choose>	
		</xsl:variable>	
		
		<xsl:variable name="vInputMes">
			<xsl:copy-of select="."/>											
		</xsl:variable>

		<xsl:variable name="headers" select="dp:response-header('MQMD')"/>    
        
		<xsl:variable name="mqmd">
			<xsl:if test="$headers">
				<xsl:copy-of select="dp:parse($headers)"></xsl:copy-of>
			</xsl:if>
		</xsl:variable> 
		
		<xsl:variable name="errorMessage">
			<xsl:choose>
				<xsl:when test="$xCode = '2033'">Таймаут ожидания ответа</xsl:when>						
				<xsl:otherwise>
					<xsl:value-of select="dp:variable('var://service/error-message')"/>
				</xsl:otherwise>			
			</xsl:choose>	
		</xsl:variable>


		<xsl:variable name="ruleType" select="dp:variable('var://service/transaction-rule-type')"></xsl:variable>
				
		<xsl:variable name="vQMName">
			<xsl:choose>
				<xsl:when test="$ruleType = 'response' and boolean($headers)">
					<xsl:copy-of select="string(normalize-space($mqmd//ReplyToQMgr/text()))"/>					
				</xsl:when>			
				<xsl:otherwise></xsl:otherwise>			
			</xsl:choose>	
		</xsl:variable>	
		
		<xsl:variable name="vSourceQueue">
			<xsl:choose>
				<xsl:when test="not(normalize-space(dp:variable('var://context/input/SourceQueue'))='')"><xsl:value-of select="dp:variable('var://context/input/SourceQueue')"/></xsl:when>
				<xsl:otherwise>UNKNOWN</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="vTargetQueue">
			<xsl:choose>
				<xsl:when test="not(normalize-space(dp:variable('var://context/input/TargetQueue'))='')"><xsl:value-of select="dp:variable('var://context/input/TargetQueue')"/></xsl:when>
				<xsl:otherwise>UNKNOWN</xsl:otherwise>
			</xsl:choose>			
		</xsl:variable>
		
		<xsl:variable name="vSourceQM">
			<xsl:choose>
				<xsl:when test="not(normalize-space(dp:variable('var://context/input/SourceQM'))='')"><xsl:value-of select="dp:variable('var://context/input/SourceQM')"/></xsl:when>
				<xsl:otherwise>UNKNOWN</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="vTargetQM">
			<xsl:choose>
				<xsl:when test="not(normalize-space(dp:variable('var://context/input/TargetQM'))='')"><xsl:value-of select="dp:variable('var://context/input/TargetQM')"/></xsl:when>
				<xsl:otherwise>UNKNOWN</xsl:otherwise>
			</xsl:choose>			
		</xsl:variable>
		

<!--
	<xsl:message terminate="no" dp:type="all" dp:priority="error">vQMName <xsl:copy-of select="$vQMName"/> </xsl:message> 
-->	


	<xsl:variable name="local-service-address">
		<xsl:value-of select="dp:variable('var://service/local-service-address')"></xsl:value-of>
	</xsl:variable> 

	<!--<xsl:variable name="vOperationPlusIP" select="concat($vOperation, '. DataPower IP=', $local-service-address, '. ',dp:variable('var://context/log/AdditionalString'))"/>-->
	<xsl:variable name="vOperationPlusIP" select="concat($vOperation, ' DataPower IP=', substring-before($local-service-address, ':'))"/>
	
	<xsl:if test="$Config:LogEnabled='on' ">
		<xsl:variable name="vMQReply">
			<xsl:call-template name="XslFunc:SendLogMsgSBT">
				<xsl:with-param name="peventmsg">
					<xsl:copy-of select="$vInputMes"/>
				</xsl:with-param>
				<xsl:with-param name="peventsource" select="$dpconfig:eventsrc"/>
				<xsl:with-param name="peventreceiver" select="$dpconfig:eventrcv"/>
				<xsl:with-param name="prquid" select="$vRqUID"/>
				<xsl:with-param name="poperation" select="$vOperationPlusIP"/>			
				<xsl:with-param name="pprocstatus" select="$vProcStatus"/>
				<xsl:with-param name="preplyqm" select="$vQMName"/>
				<xsl:with-param name="psourceq" select="$vSourceQueue"/>
				<xsl:with-param name="psourceqm" select="$vSourceQM"/>
				<xsl:with-param name="ptargetq" select="$vTargetQueue"/>
				<xsl:with-param name="ptargetqm" select="$vTargetQM"/>
				<xsl:with-param name="perrortext" select="$errorMessage"/>
				<xsl:with-param name="p_QMObject" select="$Config:MQLogConn"/>
				<xsl:with-param name="p_DestinationQ" select="$Config:QModForLog"/>
				<xsl:with-param name="p_Operationname" select="$vInputMesType"/>
			</xsl:call-template>
		</xsl:variable>	
	</xsl:if>		

	</xsl:template>
			
</xsl:stylesheet>
