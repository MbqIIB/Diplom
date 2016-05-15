<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:Config="http://sberbank.ru/sbt/config"
	exclude-result-prefixes="dp dpconfig Config"
	extension-element-prefixes="dp dpconfig Config">
	<xsl:import href="local:///allParameters.xsl"/>
	<xsl:template match="/">
		<xsl:variable name="LogTargetSub">
			<xsl:copy-of select="dp:variable('var://service/processor-name')"/>
		</xsl:variable>
		<xsl:variable name="vOperationType" select="dp:variable('var://context/RQ/OperationType')"/>
		<xsl:variable name="vFSHName" select="dp:variable('var://context/RQ/FSHName')"/>
		<xsl:variable name="vMQXQH" select="dp:parse(dp:request-header('MQXQH'))"/>
		<xsl:variable name="vMQMD" select="dp:parse(dp:request-header('MQMD'))"/>
		<xsl:variable name="vQueueToCB">
			<xsl:choose>
				<xsl:when test="contains($vFSHName,'FROM.ESB')"><xsl:value-of select="$vMQXQH//RemoteQMgrName"/></xsl:when>
				<xsl:when test="(contains($vFSHName,'FROM.CB')) and ($vOperationType='request')"><xsl:value-of select="$vMQMD/MQMD/ReplyToQMgr"/></xsl:when>
				<xsl:when test="(contains($vFSHName,'TO.ESB')) and ($vOperationType='request')"><xsl:value-of select="$vMQMD/MQMD/ReplyToQMgr"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$Config:toCB"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="(contains($vFSHName,'FROM.ESB')) and ($vOperationType='request'  or $vOperationType='notification')">
				<dp:set-variable name="'var://service/routing-url'" value="concat('dpmq://',$Config:MQMCB,'/?RequestQueue=',$vQueueToCB)" />
				<dp:set-variable name="'var://context/input/TargetQM'" value="$Config:MQMCB"/>
				<dp:set-variable name="'var://context/input/TargetQueue'" value="$vQueueToCB"/>
				<dp:set-variable name="'var://context/input/SourceQM'" value="$Config:MQMEsb"/>
				<dp:set-variable name="'var://context/RQ/error-routing-url'" value="concat('dpmq://',$Config:MQMEsb,'/?RequestQueue=',$Config:toEsb)" />
				<dp:set-variable name="'var://context/log/eventsource'" value="'ESB'" />
				<dp:set-variable name="'var://context/log/eventreceiver'" value="'DP_GW'" />
				<dp:set-variable name="'var://context/log/operation'" value="'esb2CB'" />
			</xsl:when>
			<xsl:when test="(contains($vFSHName,'FROM.ESB')) and ($vOperationType='response')">
				<dp:set-variable name="'var://service/routing-url'" value="concat('dpmq://',$Config:MQMCB,'/?RequestQueue=',$vQueueToCB)" />
				<dp:set-variable name="'var://context/RQ/error-routing-url'" value="concat('dpmq://',$Config:MQMCB,'/?RequestQueue=',$vQueueToCB)" />
				<dp:set-variable name="'var://context/input/TargetQM'" value="$Config:MQMCB" />
				<dp:set-variable name="'var://context/input/TargetQueue'" value="$vQueueToCB" />
				<dp:set-variable name="'var://context/input/SourceQM'" value="$Config:MQMEsb" />
				<dp:set-variable name="'var://context/log/eventsource'" value="'ESB'" />
				<dp:set-variable name="'var://context/log/eventreceiver'" value="'DP_GW'" />
				<dp:set-variable name="'var://context/log/operation'" value="'esb2CB'" />
			</xsl:when>					
			<xsl:when test="(contains($vFSHName,'FROM.CB')) and ($vOperationType='request')">
				<dp:set-variable name="'var://service/routing-url'" value="concat('dpmq://',$Config:MQMEsb,'/?RequestQueue=',$Config:toEsb)" />
				<dp:set-variable name="'var://context/RQ/error-routing-url'" value="concat('dpmq://',$Config:MQMCB,'/?RequestQueue=',$vQueueToCB)" />
				<dp:set-variable name="'var://context/input/TargetQM'" value="$Config:MQMEsb" />
				<dp:set-variable name="'var://context/input/TargetQueue'" value="$Config:toEsb" />
				<dp:set-variable name="'var://context/input/SourceQM'" value="$Config:MQMCB" />
				<dp:set-variable name="'var://context/log/eventsource'" value="'CB'" />
				<dp:set-variable name="'var://context/log/eventreceiver'" value="'DP_GW'" />
				<dp:set-variable name="'var://context/log/operation'" value="'CB2esb'" />
			</xsl:when>
			<xsl:when test="(contains($vFSHName,'FROM.CB')) and ($vOperationType='response' or $vOperationType='notification')">			
				<dp:set-variable name="'var://service/routing-url'" value="concat('dpmq://',$Config:MQMEsb,'/?RequestQueue=',$Config:toEsb)" />
				<dp:set-variable name="'var://context/input/TargetQM'" value="$Config:MQMEsb" />
				<dp:set-variable name="'var://context/input/TargetQueue'" value="$Config:toEsb" />
				<dp:set-variable name="'var://context/input/SourceQM'" value="$Config:MQMCB" />
				<dp:set-variable name="'var://context/RQ/error-routing-url'" value="concat('dpmq://',$Config:MQMEsb,'/?RequestQueue=',$Config:toEsb)" />
				<dp:set-variable name="'var://context/log/eventsource'" value="'CB'" />
				<dp:set-variable name="'var://context/log/eventreceiver'" value="'DP_GW'" />
				<dp:set-variable name="'var://context/log/operation'" value="'CB2esb'" />
			</xsl:when>	
			<xsl:when test="(contains($vFSHName,'TO.ESB')) and ($vOperationType='request')">
				<dp:set-variable name="'var://service/routing-url'" value="concat('dpmq://',$Config:MQMEsb,'/?RequestQueue=',$Config:toEsb)" />
				<dp:set-variable name="'var://context/input/TargetQM'" value="$Config:MQMEsb" />
				<dp:set-variable name="'var://context/input/TargetQueue'" value="$Config:toEsb" />
				<dp:set-variable name="'var://context/input/SourceQM'" value="$Config:MQMCB" />
				<dp:set-variable name="'var://context/RQ/error-routing-url'" value="concat('dpmq://',$Config:MQMCB,'/?RequestQueue=',$vQueueToCB)" />
				<dp:set-variable name="'var://context/log/eventsource'" value="'CB'" />
				<dp:set-variable name="'var://context/log/eventreceiver'" value="'DP_GW'" />
				<dp:set-variable name="'var://context/log/operation'" value="'CB2esb'" />
			</xsl:when>
			<xsl:when test="(contains($vFSHName,'TO.ESB')) and ($vOperationType='response' or $vOperationType='notification')">			
				<dp:set-variable name="'var://service/routing-url'" value="concat('dpmq://',$Config:MQMEsb,'/?RequestQueue=',$Config:toEsb)" />
				<dp:set-variable name="'var://context/input/TargetQM'" value="$Config:MQMEsb" />
				<dp:set-variable name="'var://context/input/TargetQueue'" value="$Config:toEsb" />
				<dp:set-variable name="'var://context/input/SourceQM'" value="$Config:MQMCB" />
				<dp:set-variable name="'var://context/RQ/error-routing-url'" value="concat('dpmq://',$Config:MQMEsb,'/?RequestQueue=',$Config:toEsb)" />
				<dp:set-variable name="'var://context/log/eventsource'" value="'CB'" />
				<dp:set-variable name="'var://context/log/eventreceiver'" value="'DP_GW'" />
				<dp:set-variable name="'var://context/log/operation'" value="'CB2esb'" />
			</xsl:when>
			<xsl:otherwise><dp:reject>Route Not Found</dp:reject></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>