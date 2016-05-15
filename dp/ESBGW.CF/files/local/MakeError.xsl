<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:Config="http://sberbank.ru/sbt/config"
	xmlns:mqFunc="http://sberbank.ru/sbt/functions/mq"
	xmlns:XslFunc="http://sberbank.ru/sbt/functions/xsl"
	xmlns:route="http://sberbank.ru/sbt/route" 
	exclude-result-prefixes="dp dpconfig Config mqFunc XslFunc"
	extension-element-prefixes="dp dpconfig Config mqFunc XslFunc">
	<xsl:import href="local:///allParameters.xsl"/>
	<xsl:import href="local:///allMQFunction.xsl"/>
	<xsl:import href="local:///allXSLFunction.xsl"/>
	<xsl:import href="local:///routeFunctions.xsl"/>
	<dp:input-mapping href="local:///hexBinary.ffd" type="ffd"/>
	<xsl:template match="/">
		<xsl:variable name="LogTargetSub">
			<xsl:copy-of select="dp:variable('var://service/processor-name')"/>
		</xsl:variable>
		<xsl:variable name="vRqUID" select="dp:variable('var://context/input/RqUID')"/>
		<xsl:variable name="vRqTm" select="dp:variable('var://context/input/RqTm')"/>
		<xsl:variable name="vOperUID" select="dp:variable('var://context/input/OperUID')"/>
		<xsl:variable name="vSPName" select="dp:variable('var://context/input/SPName')"/>
		<xsl:variable name="vSystemId" select="dp:variable('var://context/input/SystemId')"/>
		<xsl:variable name="vOrgNum" select="dp:variable('var://context/input/OrgNum')"/>
		<xsl:variable name="vInputMesType" select="dp:variable('var://context/input/InputMesType')"/>
		<xsl:variable name="vOperationType" select="dp:variable('var://context/RQ/OperationType')"/>
		<xsl:variable name="vFSHName" select="dp:variable('var://context/RQ/FSHName')"/>
		<xsl:variable name="vErrorString" select="dp:variable('var://service/error-message')"/>
		<xsl:variable name="vErrorCode" select="dp:variable('var://service/error-code')"/>
		<xsl:variable name="vErrorSubCode" select="dp:variable('var://service/error-subcode')"/>
		<!--определим код ошибки-->
		<xsl:variable name="vStatusCode">
			<xsl:choose>
				<xsl:when test="$vErrorCode='0x00230001' and $vErrorSubCode='0x01d30003'">-1</xsl:when>
				<xsl:otherwise>-100</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="vMsg" select="dp:variable('var://context/msg/body')"/>
		<!-- делаем сообщение об ошибке -->
		<xsl:variable name="vError">
			<xsl:copy-of select="dp:transform('local:///cf/maps/CopyAll.Err.xsl', $vMsg)" />
			<!--<xsl:copy-of select="dp:transform(dp:variable('var://context/Error/transformName'), $vMsg)" />-->
		</xsl:variable>
		<xsl:variable name="vErrorSer">
			<dp:serialize select="$vError" omit-xml-decl="yes"/>
		</xsl:variable>
		<!-- клеим заголовки для маршрутизации -->
		<xsl:variable name="vNewMQMD" select="dp:parse(dp:request-header('MQMD'))"/>
		
		<xsl:variable name="vMQMD">
			<MQMD>
				<xsl:for-each select="$vNewMQMD/MQMD/*">
					<xsl:choose>
						<xsl:when test="local-name(.)='MsgType'"><MsgType>8</MsgType></xsl:when>
						<xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</MQMD>
		</xsl:variable>
		
		<xsl:variable name="vTargetXmit">
			<xsl:call-template name="route:getRouteGW">
				<xsl:with-param name="SystemId" select="$vSystemId"/>
				<xsl:with-param name="FSHName" select="$vFSHName"/>
				<xsl:with-param name="OperationName" select="$vInputMesType"/>
				<xsl:with-param name="OperationType" select="$vOperationType"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="vErrorUrl">
			<xsl:choose>
				<xsl:when test="string-length($vTargetXmit/Route/ReplyQ)>0 and (string-length(normalize-space($vMQMD/MQMD/ReplyToQ))=0 or string-length(normalize-space($vMQMD/MQMD/ReplyToQMgr))=0) or  string-length(normalize-space(dp:variable('var://context/RQ/error-routing-url')))=0"><xsl:value-of select="$vTargetXmit/Route/Url"/></xsl:when>
				<xsl:otherwise><xsl:value-of  select="dp:variable('var://context/RQ/error-routing-url')"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--С заголовками для транспортных очередей делается финт, по замене в старом, так как может быть параметр Expiry-->
		<xsl:variable name="vMQXQHbin" select="dp:variable('var://context/msg/xmit')"/>
		<xsl:variable name="vMQXQHbinFinal" select="mqFunc:MQXMITChangeForError($vMQXQHbin,$vMQMD,$vOperationType,$vTargetXmit/Route/ReplyQ,$vTargetXmit/Route/ReplyQMgr)"/>
		
		<!--Замена заголовков в MQMD-->
		<xsl:variable name="vMQMD_Expiry">
			<xsl:call-template name="XslFunc:Replace">
				<xsl:with-param name="vNode" select="$vMQMD"/>
				<xsl:with-param name="vReplaceValue" select="$vMQMD/MQMD/Expiry"/>
				<xsl:with-param name="vTagName" select="'Expiry'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="vMQMD_ReplyQ">
			<xsl:call-template name="XslFunc:Replace">
				<xsl:with-param name="vNode" select="$vMQMD_Expiry"/>
				<xsl:with-param name="vReplaceValue" select="''"/>
				<xsl:with-param name="vTagName" select="'ReplyToQ'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="vMQMD_ReplyQM">
			<xsl:call-template name="XslFunc:Replace">
				<xsl:with-param name="vNode" select="$vMQMD_ReplyQ"/>
				<xsl:with-param name="vReplaceValue" select="''"/>
				<xsl:with-param name="vTagName" select="'ReplyToQMgr'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="vMQHeaders">
			<header name="MQMD">
				<xsl:choose>
					<xsl:when test="$vOperationType='request'">
						<dp:serialize select="$vMQMD_ReplyQM" omit-xml-decl="yes"/>
					</xsl:when>
					<xsl:otherwise>
						<dp:serialize select="$vMQMD_Expiry" omit-xml-decl="yes"/>
					</xsl:otherwise>
				</xsl:choose>
			</header>
			<header name="MQMP">
				<xsl:value-of select="dp:request-header('MQMP')"/>
			</header>
		</xsl:variable>
		<!-- выкидываем сообщение об ошибке туда, куда определили в vErrorUrl. из правила ничего не выходит, т.к. вытираем все заголовки и не указываем очередь ответов -->
		<!--<xsl:if test="string-length(normalize-space($vInputMesType))>0">
			<xsl:variable name="vResp">
				<xsl:call-template name="mqFunc:SendMessageIntoMQ">
					<xsl:with-param name="pMQHeader">
						<xsl:copy-of select="$vMQHeaders"/>
					</xsl:with-param>
					<xsl:with-param name="pMQTarget">
						<xsl:value-of select="$vErrorUrl"/>
					</xsl:with-param>
					<xsl:with-param name="pOutMessage">
						<xsl:copy-of select="dp:binary-decode(dp:radix-convert(concat($vMQXQHbinFinal,dp:radix-convert(dp:encode($vErrorSer/text(),'base-64'),64,16)),16,64))"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
		</xsl:if>-->
		<xsl:message terminate="no" dp:type="{concat($Config:LogCategory,'_',$LogTargetSub)}" dp:priority="notice">Send response message status:		<xsl:copy-of select="$vResp"/></xsl:message>
		<xsl:message terminate="no" dp:type="{concat($Config:LogCategory,'_',$LogTargetSub)}" dp:priority="notice">	<xsl:copy-of select="$vMQHeaders"/></xsl:message>
		<xsl:message terminate="no" dp:type="{concat($Config:LogCategory,'_',$LogTargetSub)}" dp:priority="notice">	<xsl:value-of select="$vMQXQHbinFinal"/></xsl:message>
		<!-- выкидываем для лога -->
		<xsl:copy-of select="$vError"/>
	</xsl:template>
</xsl:stylesheet>