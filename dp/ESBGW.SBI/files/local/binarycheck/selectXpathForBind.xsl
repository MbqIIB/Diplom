<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:xslf="http://sberbank.ru/sbt/functions/xsl"
	xmlns:Config="http://sberbank.ru/sbt/config"
	xmlns:mq="http://sberbank.ru/sbt/functions/mq"
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:dpconfig="http://www.datapower.com/param/config" 
	extension-element-prefixes="dp xslf mq Config date dpconfig"
	exclude-result-prefixes="dp xslf mq Config date dpconfig">
	
	<xsl:param name="Config:MappingXpath" select="'local:///binarycheck/MappingXPATH.xml'" />
  	<xsl:param name="Config:MappingHexBin" select="'local:///binarycheck/MappingHexBin.xml'" />
	
	<xsl:variable name="MappingXpath">
		<xsl:copy-of select="document($Config:MappingXpath)"/>
	</xsl:variable>	
	
	<xsl:variable name="MappingHexBin">
		<xsl:copy-of select="document($Config:MappingHexBin)"/>
	</xsl:variable>
		
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
		
	<xsl:template match="/">
		<xsl:message terminate="no" dp:priority="info" dp:type="all">
			IP client:<xsl:copy-of select="dp:variable('var://service/client-service-address')" />
		</xsl:message>
		<xsl:call-template name="getBinData" />
	</xsl:template>

	<xsl:template name="getBinData">
		<xsl:variable name="methodName">
			<xsl:copy-of select="local-name(/*[local-name()='Envelope']/*[local-name()='Body']/*)" />
		</xsl:variable>
		<xsl:variable name="tagName">
			<xsl:value-of select="$MappingXpath/services/service[@name = dp:variable('var://context/RQ/ServiceName')]/method[@name = $methodName]/text()" />
		</xsl:variable>
		<!--<xsl:message terminate="no" dp:priority="info" dp:type="all"><xsl:copy-of select="$tagName" /></xsl:message>-->
		<xsl:choose>
			<xsl:when test="$tagName != ''">
				<xsl:variable name="binData">
					<xsl:copy-of select="/*[local-name()='Envelope']/*[local-name()='Body']/*[local-name() = $methodName]//*[local-name() = $tagName]/text()"/>
				</xsl:variable>
				<!--<xsl:message terminate="no" dp:priority="info" dp:type="all"><xsl:copy-of select="$binData"/></xsl:message>-->
				<xsl:choose>
					<xsl:when test="$binData != ''">
						<xsl:variable name="binHEX">
							<xsl:value-of select="dp:radix-convert($binData, 64, 16)"/>
						</xsl:variable>
						<!--<xsl:message terminate="no" dp:priority="info" dp:type="all"><xsl:copy-of select="$binHEX" /></xsl:message>-->
						<xsl:for-each select="$MappingHexBin/files/file/hex/text()">
							<xsl:variable name="curHex">
								<xsl:value-of select="."/>
							</xsl:variable>
							<!--<xsl:message terminate="no" dp:priority="info" dp:type="all"><xsl:copy-of select="$curHex" />:<xsl:copy-of select="string-length($curHex)" /></xsl:message>-->
							<!--<xsl:message terminate="no" dp:priority="info" dp:type="all"><xsl:copy-of select="substring($binHEX, 1, string-length($curHex))" /></xsl:message>-->
							<xsl:choose>
								<xsl:when test="substring($binHEX, 1, string-length($curHex)) = $curHex">
									<dp:set-variable name="'var://context/RQ/binData'" value="$binData" />
								</xsl:when>
							</xsl:choose>
						</xsl:for-each>
						<xsl:choose>
							<xsl:when test="dp:variable('var://context/RQ/binData') != ''">
								<BinData>
									<xsl:copy-of select="dp:variable('var://context/RQ/binData')"/>
								</BinData>
							</xsl:when>
							<xsl:otherwise>
								<xsl:message terminate="yes" dp:priority="error" dp:type="all">
									<xsl:value-of select="'Файл не соответствует разрешённому типу для передачи.'" />
								</xsl:message>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="yes" dp:priority="error" dp:type="all">
							<xsl:value-of select="'Файл для передачи не найден.'" />
						</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!--<dp:set-variable name="'var://context/RQ/binData'" value="/" />-->
				<BinData></BinData>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
