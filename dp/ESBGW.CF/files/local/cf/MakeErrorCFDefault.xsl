<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:Config="http://sberbank.ru/sbt/config"
	xmlns:XslFunc="http://sberbank.ru/sbt/functions/xsl"
	exclude-result-prefixes="dp dpconfig Config XslFunc"
	extension-element-prefixes="dp dpconfig Config XslFunc">
	<xsl:import href="local:///allParameters.xsl"/>
	<xsl:import href="local:///allXSLFunction.xsl"/>
	<xsl:template match="/">
		<xsl:variable name="LogTargetSub">
			<xsl:copy-of select="dp:variable('var://service/processor-name')"/>
		</xsl:variable>
		<xsl:variable name="vMsg" select="."/>
		<xsl:variable name="NameSp"><xsl:value-of select="namespace-uri($vMsg/node())"/></xsl:variable>
		<xsl:variable name="vRqUID" select="dp:variable('var://context/input/RqUID')"/>
		<xsl:variable name="vRqTm" select="dp:variable('var://context/input/RqTm')"/>
		<xsl:variable name="vErrorString" select="dp:variable('var://service/error-message')"/>
		<xsl:variable name="vErrorCode" select="'-100'"/>
		<xsl:variable name="vStatus" select="XslFunc:getStatusFromContext(dp:variable('var://context/input/InputMesType'),normalize-space(dp:response-header('x-dp-response-code')))"/>
		<xsl:message>vStatus: <xsl:copy-of select="$vStatus"/></xsl:message>
		<xsl:variable name="vErrorSubCode" select="dp:variable('var://service/error-subcode')"/>
		<xsl:call-template name="XslFunc:MakeError">
			<xsl:with-param name="pRqUID" select="$vRqUID"/>
			<xsl:with-param name="pRqTm" select="$vRqTm"/>
			<xsl:with-param name="pErrCode" select="$vStatus/status/StatusCode"/>
			<xsl:with-param name="pErrMess" select="$vStatus/status/StatusDesc"/>
			<xsl:with-param name="pNode" select="$vMsg"/>
			<xsl:with-param name="pMT" select="$NameSp"/>
			<xsl:with-param name="pCA" select="$NameSp"/>
			<xsl:with-param name="pWithSeverity" select="'false'"/>
		</xsl:call-template>
	</xsl:template>
</xsl:stylesheet>