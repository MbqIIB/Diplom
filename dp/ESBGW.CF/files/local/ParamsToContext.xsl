<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions" 
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:Config="http://sberbank.ru/sbt/config"
	xmlns:mqFunc="http://sberbank.ru/sbt/functions/mq"
	xmlns:XslFunc="http://sberbank.ru/sbt/functions/xsl"
extension-element-prefixes="Config mqFunc XslFunc dp dpconfig" exclude-result-prefixes="Config mqFunc XslFunc dp dpconfig" >

	<xsl:import href="local:///allXSLFunction.xsl"/>
	
	<xsl:param name="dpconfig:gatewayType" select="'true'" />
	<dp:param name="dpconfig:gatewayType">
		<display>name of gateway (AS)</display>
		<default></default>
		<tab-override>basic</tab-override>
		<no-save-checkbox>true</no-save-checkbox>
	</dp:param>		
	<!-- на основе него определяем, что за шлюз - АС Запрос, ИШ для КСШ, КСШ КФ или платёжный шлюз -->
	<xsl:param name="dpconfig:versioning" select="'true'" />
	<dp:param name="dpconfig:versioning">
		<display>if true - adds version to paths</display>
		<default>true</default>
		<tab-override>basic</tab-override>
		<no-save-checkbox>true</no-save-checkbox>
	</dp:param>	
	
	<xsl:template match="/">
	
	<dp:set-variable name="'var://context/input/gatewayType'" value="string($dpconfig:gatewayType)" />
	<xsl:variable name="vInputMes">
		<xsl:copy-of select="."/>
	</xsl:variable>
	
	<xsl:variable name="vInputMesType">
		<xsl:choose>
			<xsl:when test="(/*[local-name()='Message']/*[local-name()='MessageType']/text()='CustContAddRq') and (not(boolean(/*[local-name()='Message']/*[local-name()='MessageBody']/*[local-name()='MessageStatus'])))"><xsl:value-of select="'BY_CustContAddRq'"/></xsl:when>
			<xsl:when test="(/*[local-name()='Message']/*[local-name()='MessageType']/text()='CustOrgAddRq') and (not(boolean(/*[local-name()='Message']/*[local-name()='MessageBody']/*[local-name()='MessageStatus'])))"><xsl:value-of select="'BY_CustOrgAddRq'"/></xsl:when>
			<xsl:when test="boolean(/*[local-name()='Message']/*[local-name()='MessageBody']/*[local-name()='MessageStatus'])"><xsl:value-of select="BY_Reply"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="local-name($vInputMes/*[1])"/></xsl:otherwise>
		</xsl:choose>		
	</xsl:variable>
	
		
	<xsl:variable name="reqRcvTime">
		<reqRcvTime>
			<xsl:value-of select="XslFunc:GetTimestamp_ms()"/>
		</reqRcvTime>
	</xsl:variable>
	
	<xsl:variable name="vInUrl" select="dp:variable('var://service/URL-in')"/>
	<xsl:variable name="vSourceQueue" select="substring-after($vInUrl,'RequestQueue=')"/>

<!-- тип операции - reqest/response/notification. смотрим в operations.xml, если там ничего не сказано про исключение, то определяем по тегу -->
	<xsl:variable name="vOperationType" select="XslFunc:GetTypeOperation($vInputMesType, $dpconfig:gatewayType)"/>

	<xsl:variable name="vFSHName" select="substring-before(substring-after($vInUrl,'/'),'?')"/>
	
	
<!-- TODO определить откуда идёт сообщение, чтобы правильно логировать -->	
<!--	<xsl:variable name="vSource">
		<xsl:choose>
			<xsl:when test="contains($vFSHName,'FROM.ESB')">ESB</xsl:when>
			<xsl:when test="contains($vFSHName,'FROM.CB')">CB</xsl:when>
		</xsl:choose>	
	</xsl:variable>-->

	
<!-- откусываем два последних символа от названия запроса, получится имя сервиса, по которому выбираем версию. трансформацию и валидацию -->
	<xsl:variable name="srvName">
		<xsl:copy-of select="substring($vInputMesType, 0, string-length($vInputMesType) - 1)"/>
	</xsl:variable> 

	<!-- определяем номер версии сервиса. по нему будут доставаться схемы и карты.преобразования. берётся из defaults.xml, если там ничего не сказано, то считаем, что 1.0-->
	<!-- строка клеится в виде имясервиса/номерверсии/ - в таком виде добавляется в путь схемы и мапинга-->
	<!-- если версионность выключена, делаем просто слеш -->
	<xsl:variable name="srvAndVersion">
		<xsl:choose>
			<xsl:when test="$dpconfig:versioning = 'true'">
				<xsl:copy-of select="concat('/', $srvName, '/', XslFunc:getVersion($srvName), '/')"/>
			</xsl:when>
			<xsl:otherwise>/</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>


<!-- для сценария КСШ -> внешний контрагент 
TODO обратно в отдельном файле 
-->

<!-- имя системы-отправителя достаётся из маршуртов и заносится в контекст раньше, например из esb.to.outer.xsl -->
	<xsl:variable name="sourceSystem">
		<xsl:copy-of select="dp:variable('var://context/RQ/sourceSystem')"/>
	</xsl:variable>

<!-- имя системы-получателя достаётся из маршуртов и заносится в контекст раньше, например из esb.to.outer.xsl -->
	<xsl:variable name="targetSystem">
		<xsl:copy-of select="dp:variable('var://context/input/systemName')"/>
	</xsl:variable>

<!-- одной карты должно хватить и для запроса, и для ответа. Матчим по корневому тегу -->
	<xsl:variable name="transformName" select="concat('local:///', $dpconfig:gatewayType, '/maps', $srvAndVersion, $vInputMesType, '.xsl')"/>	
		
	<xsl:variable name="transformNameEr" select="concat('local:///', $dpconfig:gatewayType, '/maps', $srvAndVersion, $vInputMesType, '.Err.xsl')"/>	

	<xsl:variable name="rsSchemaName" select="concat('local:///', $dpconfig:gatewayType, '/xsd', $srvAndVersion, $srvName, '.xsd')"/>

	<xsl:variable name="rqSchemaName" select="concat('local:///', $dpconfig:gatewayType, '/xsd', $srvAndVersion, $srvName, '.xsd')"/>

	
	<dp:set-variable name="'var://context/RQ/transformName'" value="string($transformName)"/>		
	<dp:set-variable name="'var://context/Error/transformName'" value="string($transformNameEr)"/>
	<dp:set-variable name="'var://context/RQ/schemaPath'" value="string($rqSchemaName)"/>		
	<dp:set-variable name="'var://context/RS/schemaPath'" value="string($rsSchemaName)"/>		

	<dp:set-variable name="'var://context/RQ/InputMesType'" value="string($vInputMesType)"/>		
	<dp:set-variable name="'var://context/RQ/reqRcvTime'" value="string($reqRcvTime)" />

	<dp:set-variable name="'var://context/input/SourceQueue'" value="string($vSourceQueue)" />
	<dp:set-variable name="'var://context/RQ/SourceQueue'" value="string($vSourceQueue)" />
	<dp:set-variable name="'var://context/RQ/OperationType'" value="string($vOperationType)" />
	<dp:set-variable name="'var://context/RQ/FSHName'" value="string($vFSHName)" />
	<dp:set-variable name="'var://context/RQ/MQXMITHeaders'" value="string(dp:request-header('MQXQH'))" />
	
	<xsl:variable name="vRqUID">
		<xsl:choose>
			<xsl:when test="boolean(/*[1]/*[local-name()='MessageId'])"><xsl:value-of select="/*[1]/*[local-name()='MessageId']"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="string($vInputMes/*[local-name()=$vInputMesType]//*[local-name()='RqUID'])"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<dp:set-variable name="'var://context/input/RqUID'" value="string($vRqUID)" />
	<dp:set-variable name="'var://context/input/RqTm'" value="string($vInputMes/*[local-name()=$vInputMesType]//*[local-name()='RqTm'])" />
	<dp:set-variable name="'var://context/input/OperUID'" value="string($vInputMes/*[local-name()=$vInputMesType]//*[local-name()='OperUID'])" />
	<dp:set-variable name="'var://context/input/SPName'" value="string($vInputMes/*[local-name()=$vInputMesType]//*[local-name()='SPName'])" />
	<dp:set-variable name="'var://context/input/SystemId'" value="string($vInputMes/*[local-name()=$vInputMesType]//*[local-name()='SystemId'])" />
	<dp:set-variable name="'var://context/input/OrgNum'" value="string($vInputMes//*[local-name()='OrgNum'])" />
	<dp:set-variable name="'var://context/input/InputMesType'" value="string($vInputMesType)" />

</xsl:template>	

</xsl:stylesheet>