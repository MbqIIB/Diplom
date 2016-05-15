<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:Config="http://sberbank.ru/sbt/config"
	exclude-result-prefixes="dp dpconfig Config"
	extension-element-prefixes="dp dpconfig Config">
	<xsl:import href="local:///allParameters.xsl"/>
	
		<xsl:template match="/">
			<xsl:variable name="FakeManager" select="'435a2e4553422e434f4d2e4d4350'" />
			<xsl:variable name="Manager" select="'435a2e4553422e434f4d20202020'" />
			
			<!-- M99.ESB.COM.MCP -> M99.ESB.COM -->
			<xsl:variable name="bin">
				<xsl:choose>
					<xsl:when test="contains(/object/message,$FakeManager)"><xsl:value-of select="substring-before(/object/message,$FakeManager)"/><xsl:value-of select="$Manager"/><xsl:value-of select="substring-after(/object/message,$FakeManager)"/></xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="/object/message"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>		
			
			
					<xsl:variable name="bin">
						<xsl:value-of select="/object/message"/>
					</xsl:variable>		
		</xsl:template>
		
</xsl:stylesheet>