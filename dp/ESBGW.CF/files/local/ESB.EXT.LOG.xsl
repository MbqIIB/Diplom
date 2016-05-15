<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:dp="http://www.datapower.com/extensions" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dpconfig="http://www.datapower.com/param/config"
    xmlns:Config="http://sberbank.ru/sbt/config"
	xmlns:XslFunc="http://sberbank.ru/sbt/functions/xsl"
extension-element-prefixes="dp Config XslFunc dpconfig"  
exclude-result-prefixes="dp xsl Config XslFunc dpconfig">

	<xsl:import href="local:///allXSLFunction.xsl"/>
	<xsl:import href="local:///allParameters.xsl"/>
	<xsl:output omit-xml-declaration="yes" dp:escaping="minimum"/>
	
	<xsl:param name="dpconfig:ExtLogOperationStatus" select="'1'" />
	<dp:param name="dpconfig:ExtLogOperationStatus">
		<display>operation status string</display>
		<default></default>
		<tab-override>basic</tab-override>
		<no-save-checkbox>true</no-save-checkbox>
	</dp:param>
<xsl:template match="/">	
		
	<!-- точка возврата адаптер на ДП -->
	<xsl:variable name="RsSentTime">
		<xsl:value-of select="XslFunc:GetTimestamp_ms()"/>
	</xsl:variable>

	<xsl:variable name="vRqUID">
		<xsl:value-of select="dp:variable('var://context/input/RqUID')"/>
	</xsl:variable>
	<xsl:variable name="vErrorString" select="dp:variable('var://service/error-message')"/>
		<xsl:variable name="vErrorCode" select="dp:variable('var://service/error-code')"/>
		<xsl:variable name="vErrorSubCode" select="dp:variable('var://service/error-subcode')"/>
		<xsl:variable name="vErrorCodeCS" select="dp:variable('var://context/CSError/ErrorCode')"/>
		<xsl:variable name="vReturnCode">
			<xsl:choose>
				<xsl:when test="normalize-space($vErrorCodeCS)!=''"><xsl:value-of select="$vErrorCodeCS"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$vErrorCode"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	
	<xsl:variable name="vMsgProps">
		<MsgProps>	
			<DPExtRqTm><xsl:value-of select="dp:variable('var://context/RQ/reqRcvTime')"/></DPExtRqTm>
			<ExtLogRqTm><xsl:value-of select="dp:variable('var://context/RQ/reqRcvTime')"/></ExtLogRqTm> 
			<ExtLogRsTm><xsl:value-of select="$RsSentTime"/></ExtLogRsTm> 
			<DPExtRsTm><xsl:value-of select="$RsSentTime"/></DPExtRsTm> 
			<ExtLogOperationName><xsl:value-of select="dp:variable('var://context/RQ/InputMesType')"/></ExtLogOperationName> 	
			<ExtLogRqUID><xsl:value-of select="$vRqUID"/></ExtLogRqUID>	
			<ExtLogOperationStatus><xsl:value-of select="$dpconfig:ExtLogOperationStatus"/></ExtLogOperationStatus> 
			<ExtLogTargetSystem><xsl:value-of select="dp:variable('var://context/RQ/TargetSystem')"/></ExtLogTargetSystem>				
			<ExtLogReplyCode><xsl:value-of select="$vReturnCode"/></ExtLogReplyCode>	
			<ExtLogErrorMsg><xsl:value-of select="$vErrorString"/></ExtLogErrorMsg>	
		</MsgProps>
	</xsl:variable>

	<xsl:message terminate="no" dp:type="all" dp:priority="notice">vMsgProps: <xsl:copy-of select="$vMsgProps"/> </xsl:message>        

	<xsl:if test="$Config:ExtLogEnabled='on'">
		<xsl:variable name="vMQReply">
			<xsl:call-template name="XslFunc:SendExtLog">
				<xsl:with-param name="p_MesProps" select="$vMsgProps"/>
				<xsl:with-param name="p_QMObject" select="$Config:MQExtLogConn"/>
				<xsl:with-param name="p_DestinationQ" select="$Config:QExtLog"/>
			</xsl:call-template>
		</xsl:variable>		
	</xsl:if>

	<xsl:if test="dp:variable('var://service/protocol') = 'http' or dp:variable('var://service/protocol') = 'https'">
		<dp:remove-http-response-header name="MQRFH2"/>
		<dp:remove-http-response-header name="MQMD"/>
		<dp:remove-http-response-header name="X-MQRFH2-Data-0"/>
	</xsl:if>
	
	</xsl:template>
			
</xsl:stylesheet>
