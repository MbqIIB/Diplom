<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:Config="http://sberbank.ru/sbt/config"
	xmlns:XslFunc="http://sberbank.ru/sbt/functions/xsl"
	exclude-result-prefixes="dp dpconfig Config XslFunc"
	extension-element-prefixes="dp dpconfig Config XslFunc">
	<dp:input-mapping href="local:///hexBinary.ffd" type="ffd"/>
	<!--
		separates msg from headers. converts binaryMsg -> b64Msg -> result
-->
	<xsl:import href="local:///allParameters.xsl"/>
	<xsl:import href="local:///allXSLFunction.xsl"/>
	
	<xsl:template match="/">
		<xsl:variable name="LogTargetSub">
			<xsl:copy-of select="dp:variable('var://service/processor-name')"/>
		</xsl:variable>
		<!-- Magick offset, where XMIT starts	-->
		<xsl:variable name="XMITOffset">857</xsl:variable>		
		<xsl:message terminate="no" dp:type="{concat($Config:LogCategory,'_',$LogTargetSub)}" dp:priority="debug">enter processXMIT.</xsl:message>
		<xsl:message terminate="no" dp:type="{concat($Config:LogCategory,'_',$LogTargetSub)}" dp:priority="debug">processXMIT. input: <xsl:value-of select="."/></xsl:message>	
		<xsl:variable name="bin">
			<xsl:value-of select="/object/message"/>
		</xsl:variable>		
		<xsl:variable name="vMQXQHbin" select="substring(/object/message/text(),0,$XMITOffset)"/>
		
		<xsl:variable name="msg">					
					<xsl:message terminate="no" dp:type="{concat($Config:LogCategory,'_',$LogTargetSub)}" dp:priority="debug">processXMIT. bin: <xsl:value-of select="$bin"/>					</xsl:message>
					<xsl:variable name="binaryMsg">
						<xsl:value-of select="substring($bin, $XMITOffset)"/>
					</xsl:variable>
					<xsl:message terminate="no" dp:type="{concat($Config:LogCategory,'_',$LogTargetSub)}" dp:priority="debug">processXMIT. binaryMsg: <xsl:value-of select="$binaryMsg"/>					</xsl:message>
					<xsl:variable name="b64Msg">
						<xsl:copy-of select="dp:radix-convert($binaryMsg, 16, 64)"/>
					</xsl:variable>
					<xsl:message terminate="no" dp:type="{concat($Config:LogCategory,'_',$LogTargetSub)}" dp:priority="debug">processXMIT. b64Msg: <xsl:value-of select="$b64Msg"/>					</xsl:message>					
					<xsl:variable name="result" select="dp:parse($b64Msg, 'base-64')"/>
					<xsl:copy-of select="$result"/>
		</xsl:variable>
		<xsl:message terminate="no" dp:type="{concat($Config:LogCategory,'_',$LogTargetSub)}" dp:priority="debug">processXMIT. result msg: <xsl:copy-of select="$msg"/>		</xsl:message>
		<dp:set-variable name="'var://context/msg/body'" value="$msg"/>
		<dp:set-variable name="'var://context/msg/xmit'" value="$vMQXQHbin"/>
		<dp:set-variable name="'var://context/RQ/reqRcvTime'" value="XslFunc:GetTimestamp_ms()"/>
		<xsl:copy-of select="$msg"/>
	</xsl:template>
</xsl:stylesheet>
