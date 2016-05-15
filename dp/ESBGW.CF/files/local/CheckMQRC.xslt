<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:Config="http://sberbank.ru/sbt/config"
	exclude-result-prefixes="dp dpconfig Config"
	extension-element-prefixes="dp dpconfig Config">
	
	<xsl:import href="local:///allParameters.xsl"/>
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:template match="/">
		<xsl:variable name="LogTargetSub">
			<xsl:copy-of select="dp:variable('var://service/processor-name')"/>
		</xsl:variable>
		<xsl:variable name="xCode" select="normalize-space(dp:response-header('x-dp-response-code'))" />
		<xsl:message terminate="no" dp:type="{concat($Config:LogCategory,'_',$LogTargetSub)}" dp:priority="debug">Mq return code:<xsl:value-of select="$xCode"/>           			 </xsl:message>
		<xsl:if test="starts-with($xCode, '2') and string-length($xCode)=4">
			<dp:reject>MQ Error with mqrc=<xsl:value-of select="$xCode"/></dp:reject>
		</xsl:if>
		<xsl:copy-of select="dp:variable('var://context/msg/body')"/>
	</xsl:template>
</xsl:stylesheet>
