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

	<!--<xsl:param name="Config:MappingXpath" select="'local:///binarycheck/MappingXPATH.xml'" />-->
	<xsl:param name="Config:MappingHexBin" select="'local:///binarycheck/MappingHexBin.xml'" />

	<!--<xsl:variable name="MappingXpath">
		<xsl:copy-of select="document($Config:MappingXpath)"/>
	</xsl:variable>-->
	<xsl:variable name="MappingHexBin">
		<xsl:copy-of select="document($Config:MappingHexBin)"/>
	</xsl:variable>
	<!--Beware! Hardcode below.-->
	<xsl:variable name="service" select="dp:variable('var://context/input/InputMesType')"/>
	<xsl:variable name="service_1" select="'SrvGetContractRs'"/>
	<xsl:variable name="service_2" select="'SrvGetClientManagerContactsRs'"/>
	<xsl:variable name="service_3" select="'SrvActivateMTokenRs'"/>
	<xsl:variable name="service_4" select="'SrvUpdateMTokenRs'"/>

	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<xsl:template match="/">
		<xsl:message terminate="no" dp:priority="info" dp:type="all">
			IP client:<xsl:copy-of select="dp:variable('var://service/client-service-address')" />
		</xsl:message>
		<xsl:if test="$service = $service_1">
			<xsl:call-template name="getBinData">
				<xsl:with-param name="pathToBinData" select="/*[local-name()=$service]/*[local-name()='ContractPDFAttachment']"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$service = $service_2">
			<xsl:call-template name="getBinData">
				<xsl:with-param name="pathToBinData" select="/*[local-name()=$service]/*[local-name()='PersonalBankerBlock']/*[local-name()='BankerPhoto']"/>
			</xsl:call-template>
		</xsl:if>
		<!--<xsl:if test="$service = $service_3 or $service = $service_4">
			<xsl:call-template name="getBinData">
				<xsl:with-param name="pathToBinData" select="/*[local-name()=$service]/*[local-name()='qrCode']"/>
			</xsl:call-template>
		</xsl:if>-->
	</xsl:template>

	<xsl:template name="getBinData">
	
		<xsl:param name="pathToBinData"/>
		
		<!--<xsl:message terminate="no" dp:priority="error" dp:type="all"><xsl:value-of select="$pathToBinData"/></xsl:message>-->
		<!--<xsl:message terminate="no" dp:priority="error" dp:type="all"><xsl:value-of select="$binData"/></xsl:message>-->
		<xsl:choose>
			<xsl:when test="$pathToBinData != ''">
				<xsl:variable name="binData" select="$pathToBinData/text()"/>
				<xsl:choose>
					<xsl:when test="$binData != ''">
						<xsl:variable name="binHEX">
							<xsl:value-of select="dp:radix-convert($binData, 64, 16)"/>
						</xsl:variable>
						<!--<xsl:message terminate="no" dp:priority="error" dp:type="all"><xsl:copy-of select="$binHEX" /></xsl:message>-->
						<xsl:for-each select="$MappingHexBin/files/file/hex/text()">
							<xsl:variable name="curHex">
								<xsl:value-of select="."/>
							</xsl:variable>
							<!--<xsl:message terminate="no" dp:priority="error" dp:type="all"><xsl:copy-of select="$curHex" />:<xsl:copy-of select="string-length($curHex)" /></xsl:message>-->
							<!--<xsl:message terminate="no" dp:priority="error" dp:type="all"><xsl:copy-of select="substring($binHEX, 1, string-length($curHex))" /></xsl:message>-->
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
									<xsl:value-of select="'Attachment has invalid format'" />
								</xsl:message>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="yes" dp:priority="error" dp:type="all">
							<xsl:value-of select="'Attachment not found'" />
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
