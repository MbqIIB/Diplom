<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:dpconfig="http://www.datapower.com/param/config" 
	xmlns:Config="http://sberbank.ru/sbt/config" 
	xmlns:route="http://sberbank.ru/sbt/route" 
	extension-element-prefixes="dp dpconfig route Config" exclude-result-prefixes="dp dpconfig route Config">

	<xsl:import href="local:///allParameters.xsl"/>
	
<!-- проверяет, можно ли этой системе к КСШ -->
	
	
	<!-- возвращает URL по имени системы назначения + имени адаптера (для ИШ)-->
	<xsl:template name="route:getRouteByTarget">
		<xsl:param name="targetName"/>		
		<xsl:param name="serviceName"/>

		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByTarget targetName: <xsl:copy-of select="$targetName"></xsl:copy-of></xsl:message>
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByTarget serviceName: <xsl:copy-of select="$serviceName"></xsl:copy-of></xsl:message>
		
		<xsl:variable name="routes">
			<xsl:copy-of select="document($Config:routes)"/>
		</xsl:variable>
		
		<xsl:variable name="URL">
			<xsl:copy-of select="$routes/routes/adapter[@name=$serviceName]/route[@system=$targetName]"></xsl:copy-of>			
		</xsl:variable>

		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByTarget URL <xsl:copy-of select="$URL"/> </xsl:message> 		

		<xsl:copy-of select="$URL"/>
	
	</xsl:template>	
	
	
<!-- возвращает дефолтное имя системы получателя по имени адаптера (для ИШ) -->
	<xsl:template name="route:getDefaultTarget">
		<xsl:param name="serviceName"/>

		<xsl:message terminate="no" dp:type="all" dp:priority="info">getDefaultTarget serviceName: <xsl:copy-of select="$serviceName"></xsl:copy-of></xsl:message>
		
		<xsl:variable name="routes">
			<xsl:copy-of select="document($Config:routes)"/>
		</xsl:variable>
		
		<xsl:variable name="targetName">
			<xsl:value-of select="$routes/routes/adapter[@name=$serviceName]/route[@default='true']/@system"></xsl:value-of>						
		</xsl:variable>

		<xsl:message terminate="no" dp:type="all" dp:priority="info">getDefaultTarget targetName: <xsl:copy-of select="$targetName"/> </xsl:message> 		

		<xsl:copy-of select="$targetName"/>
	
	</xsl:template>			
	
	<xsl:template name="route:getAccessByCert">
			<xsl:param name="serviceName"/>
			<xsl:param name="port"/>
			<xsl:param name="cert"/>
	
		<xsl:variable name="routes">
			<xsl:copy-of select="document($Config:routes)"/>
		</xsl:variable>
	
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getAccessByCert incoming serviceName: <xsl:copy-of select="$serviceName"></xsl:copy-of></xsl:message>
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getAccessByCert incoming port: <xsl:copy-of select="$port"></xsl:copy-of></xsl:message>
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getAccessByCert incoming cert: <xsl:copy-of select="$cert"></xsl:copy-of></xsl:message>
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getAccessByCert from TB: <xsl:value-of select="$routes/routes/adapter[@name=$serviceName]/route[@port=$port and @ssl='yes' and @cert=$cert]/@TB"></xsl:value-of></xsl:message>
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getAccessByCert port from routing table: <xsl:value-of select="$routes/routes/adapter[@name=$serviceName]/route[@ssl='yes' and @cert=$cert]/@port"></xsl:value-of></xsl:message>
	
		<xsl:variable name="access">
			<xsl:choose>
				<xsl:when test="$routes/routes/adapter[@name=$serviceName]/route[@port=$port and @ssl='yes' and @cert=$cert]">yes</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="not($port=$routes/routes/adapter[@name=$serviceName]/route[@ssl='yes' and @cert=$cert]/@port)">bad port</xsl:when>
						<xsl:otherwise>no</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="TB">
			<TB>
				<xsl:value-of select="$routes/routes/adapter[@name=$serviceName]/route[@port=$port and @ssl='yes' and @cert=$cert]/@TB"></xsl:value-of>
			</TB>	
		</xsl:variable>
		
		<!-- добавляем в контекст номер ТБ, чтобы потом можно было например маршрутизировать -->
		<dp:set-variable name="'var://context/input/TB'" value="$TB" />
		
		
		<xsl:copy-of select="$access"/>
		
	</xsl:template>
	  
	
	
	
	<!-- возвращает URL по сертификату + имени адаптера, по которому надо кинуть сообщение от обратившейся системы, TODO -->
	<xsl:template name="route:getRouteByCert">
		<xsl:param name="port"/>		
		<xsl:param name="cert"/>
		<xsl:param name="serviceName"/>	
		
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByCert port: <xsl:copy-of select="$port"></xsl:copy-of></xsl:message>
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByCert cert: <xsl:copy-of select="$cert"></xsl:copy-of></xsl:message>
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByCert serviceName: <xsl:copy-of select="$serviceName"></xsl:copy-of></xsl:message>
	
		
		<xsl:variable name="routes">
			<xsl:copy-of select="document($Config:routes)"/>
		</xsl:variable>
	
		
		<xsl:variable name="URL">
			<xsl:copy-of select="$routes/routes/adapter[@name=$serviceName]/route[@port=$port and @ssl='yes' and @cert=$cert]"></xsl:copy-of>
		</xsl:variable>

		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByCert URL <xsl:copy-of select="$URL"/> </xsl:message> 

		<xsl:copy-of select="$URL"/>
	</xsl:template>
	
	
	<!-- возвращает URL по номеру порта + имени адаптера. Для тех кто без SSL -->
	<xsl:template name="route:getRouteByPort">
		<xsl:param name="port"/>
		<xsl:param name="serviceName"/>

		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByPort port: <xsl:copy-of select="$port"></xsl:copy-of></xsl:message>
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByPort serviceName: <xsl:copy-of select="$serviceName"></xsl:copy-of></xsl:message>
	
		
		<xsl:variable name="routes">
			<xsl:copy-of select="document($Config:routes)"/>
		</xsl:variable>
	
		<xsl:variable name="URL">
			<xsl:copy-of select="$routes/routes/adapter[@name=$serviceName]/route[@port=$port]"></xsl:copy-of>
		</xsl:variable>

		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByPort URL <xsl:copy-of select="$URL"/> </xsl:message> 		

		<xsl:copy-of select="$URL"/>
	
	</xsl:template>
	
	
<!-- возвращает URL по номеру ТБ, выдранному из контекста. Для тех кто без SSL -->
	<xsl:template name="route:getRouteByTB">
		<xsl:param name="TB"/>
		<xsl:param name="serviceName"/>

		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByTB TB: <xsl:copy-of select="$TB"></xsl:copy-of></xsl:message>
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByTB serviceName: <xsl:copy-of select="$serviceName"></xsl:copy-of></xsl:message>
	
		
		<xsl:variable name="routes">
			<xsl:copy-of select="document($Config:routes)"/>
		</xsl:variable>
		
		<xsl:variable name="URL">
			<xsl:copy-of select="$routes/routes/adapter[@name=$serviceName]/route[@TB=$TB and @ssl='none' ]"></xsl:copy-of>
		</xsl:variable>

		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByTB URL <xsl:copy-of select="$URL"/> </xsl:message> 		

		<xsl:copy-of select="$URL"/>
	
	</xsl:template>	
	<!--возвращает данные маршрутизации для ИШ-->
	<xsl:template name="route:getRouteGW">
		<xsl:param name="SystemId"/>
		<xsl:param name="FSHName"/>
		<xsl:param name="OperationName"/>
		<xsl:param name="OperationType"/>
		<xsl:variable name="routes">
			<xsl:copy-of select="document($Config:routes)"/>
		</xsl:variable>
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteGW SystemId: <xsl:copy-of select="$SystemId"></xsl:copy-of></xsl:message>
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteGW FSHName: <xsl:copy-of select="$FSHName"></xsl:copy-of></xsl:message>
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteGW OperationName: <xsl:copy-of select="$OperationName"></xsl:copy-of></xsl:message>
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteGW OperationType: <xsl:copy-of select="$OperationType"></xsl:copy-of></xsl:message>
		<Route>
			<Url><xsl:value-of select="$routes/routes/adapter[@name=$OperationName]/route[@SystemId=$SystemId or (string-length(@SystemId/text())=0 and string-length($SystemId)=0)]"/></Url>
			<ReplyQ><xsl:value-of select="$routes/routes/adapter[@name=$OperationName]/route[@SystemId=$SystemId or (string-length(@SystemId/text())=0 and string-length($SystemId)=0)]/@ReplyQ"/></ReplyQ>
			<ReplyQMgr><xsl:value-of select="$routes/routes/adapter[@name=$OperationName]/route[@SystemId=$SystemId or (string-length(@SystemId/text())=0 and string-length($SystemId)=0)]/@ReplyQMgr"/></ReplyQMgr>
		</Route>
	</xsl:template>
	<xsl:template name="route:getRouteByTargetAndType">
		<xsl:param name="targetName"/>		
		<xsl:param name="serviceName"/>
		<xsl:param name="operationType"/>

		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByTargetAndType targetName: <xsl:copy-of select="$targetName"></xsl:copy-of></xsl:message>
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByTargetAndType serviceName: <xsl:copy-of select="$serviceName"></xsl:copy-of></xsl:message>
		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByTargetAndType OperationType: <xsl:copy-of select="$operationType"></xsl:copy-of></xsl:message>
		
		<xsl:variable name="routes">
			<xsl:copy-of select="document($Config:routes)"/>
		</xsl:variable>
		
		<xsl:variable name="URL">
			<xsl:copy-of select="$routes/routes/adapter[@name=$serviceName]/route[@system=$targetName and @type=$operationType]"></xsl:copy-of>			
		</xsl:variable>

		<xsl:message terminate="no" dp:type="all" dp:priority="info">getRouteByTargetAndType URL <xsl:copy-of select="$URL"/> </xsl:message> 		

		<xsl:copy-of select="$URL"/>
	
	</xsl:template>
</xsl:stylesheet>
