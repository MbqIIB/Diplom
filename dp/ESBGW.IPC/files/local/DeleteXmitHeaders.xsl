<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	exclude-result-prefixes="dp"
	xmlns:Config="http://sberbank.ru/sbt/config"
	extension-element-prefixes="dp Config">
	<xsl:import href="local:///allParameters.xsl"/>
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
		<xsl:variable name="LogTargetSub">
			<xsl:copy-of select="dp:variable('var://service/processor-name')"/>
		</xsl:variable>
		<xsl:message terminate="no" dp:type="{concat($Config:LogCategory,'_',$LogTargetSub)}" dp:priority="debug">Delete MQXMIT headers.</xsl:message>
		<dp:set-request-header name="'MQXQH'" value="''"/>
		<dp:set-response-header name="'MQXQH'" value="''"/>
	</xsl:template>
</xsl:stylesheet>
