<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dp="http://www.datapower.com/extensions" exclude-result-prefixes="dp" extension-element-prefixes="dp">
	<xsl:template match="/">
		<xsl:variable name="msg" select="."/>
		<xsl:variable name="vTransformedMsg">
			<xsl:copy-of select="dp:transform('local:///sbi/MakeErrorSBIDefault.xsl', $msg)"/>
		</xsl:variable>
		<xsl:copy-of select="$vTransformedMsg"/>
	</xsl:template>
</xsl:stylesheet>
