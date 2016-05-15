<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:date="http://exslt.org/dates-and-times" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:func="http://exslt.org/functions"
xmlns:dp="http://www.datapower.com/extensions"
xmlns:mqFunc="http://sberbank.ru/sbt/functions/mq"
extension-element-prefixes="dp mqFunc func date"
exclude-result-prefixes="dp mqFunc func date">


<!-- SBT. Просто шлёт сообщение в очередь для логирования -->	
<xsl:template name="mqFunc:LogIntoMQ" >	
	<xsl:param name="pOutMessage"/>
	<xsl:param name="p_QMObject"/>
	<xsl:param name="p_DestinationQ"/>
	<xsl:param name="pusrFolder"/>
	
	<xsl:variable name="vMQMD">
		<xsl:call-template name="tMQMD">
			<xsl:with-param name="pMsgType" select="'8'"/>
		</xsl:call-template>	
	</xsl:variable>

	<xsl:variable name="vMQHeader">
		<xsl:if test="boolean($pusrFolder)">
			<!-- С версии MQ 7 MQRFH2.usr заголовок проставляется через новые Message Properties при помощи заголовка MQMP-->
			<xsl:variable name="vMQMP">
				<xsl:call-template name="tMQMP">
					<xsl:with-param name="pMesProp">
						<xsl:copy-of select="$pusrFolder"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>			

			<header name="MQMD">
				<dp:serialize select="$vMQMD" omit-xml-decl="yes"/>
			</header>
			<header name="MQMP">
				<dp:serialize select="$vMQMP" omit-xml-decl="yes"/>
			</header>
		</xsl:if>
	</xsl:variable>
		
	<xsl:variable name="vQMObject">
		<xsl:choose>
			<xsl:when test="boolean($p_QMObject) and not(normalize-space($p_QMObject) ='')">
				<xsl:value-of select="$p_QMObject"/>			
			</xsl:when>
		</xsl:choose>
	</xsl:variable>

	<!-- AsyncPut работает только с версии MQ 7-->
	<xsl:variable name="vMqTarget">dpmq://<xsl:value-of select="$vQMObject"/>//?RequestQueue=<xsl:value-of select="$p_DestinationQ"/>;ParseHeaders=false</xsl:variable>		
	
	<xsl:variable name="vResp">
		<dp:url-open target="{$vMqTarget}" response="responsecode-ignore" http-headers="$vMQHeader">
			<xsl:copy-of select="$pOutMessage"/>
		</dp:url-open>
	</xsl:variable>
	
		<xsl:variable name="vReply">
			<xsl:if test="boolean($vResp/url-open/responsecode)">
		    <xsl:choose>
				<xsl:when test="$vResp/url-open/responsecode != 0 and $vResp/url-open/responsecode !=2033">
					<Reply>
						<ReplyCode>-1</ReplyCode>
						<ReplyDescription>MQ system error. </ReplyDescription>
						<Error>
							<ErrorSystem>MQ</ErrorSystem>
							<ErrorType>3</ErrorType>
							<ErrorCode>
								<xsl:value-of select="$vResp/url-open/responsecode"/>
							</ErrorCode>
							<ErrorDescription/>
						</Error>
					</Reply>	
				</xsl:when>
				<xsl:when test="$vResp/url-open/responsecode=2033">
					<Reply>
					<ReplyCode>-1</ReplyCode>
							<ReplyDescription>MQ system error. </ReplyDescription>
						<Error>
							<ErrorSystem>MQ</ErrorSystem>
							<ErrorType>3</ErrorType>
							<ErrorCode>2033</ErrorCode>
							<ErrorDescription>The answer is not found. </ErrorDescription>
						</Error>
					</Reply>
				</xsl:when>
				<xsl:when test="$vResp/url-open/responsecode = 0">
				  <Reply>
					<ReplyCode>0</ReplyCode>
				  </Reply>
				</xsl:when>
			   </xsl:choose>
			</xsl:if>  	
		</xsl:variable>
		<xsl:copy-of select="$vReply"/>
	
</xsl:template>
	
<xsl:template name="mqFunc:SendMessageIntoMQ" >
	<xsl:param name="pOutMessage"/>
	<xsl:param name="p_QMObject"/>
	<xsl:param name="p_DestinationQ"/>
	<xsl:param name="p_MsgId"/>
	<xsl:param name="p_CorrelId"/>
	<xsl:param name="p_ReplyToQMgr"/>
	<xsl:param name="p_ReplyToQ"/>
	<xsl:param name="p_Report"/>
	<xsl:param name="pTransaction" select=" 'true' "/>
	<xsl:param name="p_Timeout" select="40000"/>
	<xsl:param name="p_TransformName" select="'TRANSFORM'"/>
	<xsl:param name="p_Persistence"/>
	<xsl:param name="pusrFolder"/>
	<xsl:param name="pMQHeader"/>
	<xsl:param name="pMQTarget"/>
    
	<xsl:variable name="vMQMD">
		<xsl:choose>
			<!-- Если просто отправляем сообщение и не ждем никакого ответа-->
			<xsl:when test="not(boolean($p_ReplyToQ))">
				<xsl:call-template name="tMQMD">
					<xsl:with-param name="pMsgType" select="'8'"/>
				</xsl:call-template>				
			</xsl:when>
			<!-- Если необходимо просто гарантированно выложить сообщение в очередь MQ -->
			<xsl:when test="$p_Report='256'">
				<xsl:call-template name="tMQMD">
					<xsl:with-param name="pMsgId" select="$p_MsgId"/>
					<xsl:with-param name="pCorrelId" select="$p_CorrelId"/>
					<xsl:with-param name="pReplyToQMgr" select="$p_ReplyToQMgr"/>
					<xsl:with-param name="pReplyToQ" select="$p_ReplyToQ"/>			
					<xsl:with-param name="pExpiry" select="$p_Timeout"/>
					<xsl:with-param name="pReport" select="$p_Report"/>
					<xsl:with-param name="pPersistence" select="$p_Persistence"/>
				</xsl:call-template>
			</xsl:when>
			<!-- Если необходимо переложить устаревшее сообщение в отдельную очередь или послать нотификацию, что оно устарело-->
			<xsl:when test="$p_Report='14680256' or $p_Report='14680064' or $p_Report='14680192'">
				<xsl:call-template name="tMQMD">
					<xsl:with-param name="pMsgId" select="$p_MsgId"/>
					<xsl:with-param name="pCorrelId" select="$p_CorrelId"/>
					<xsl:with-param name="pReplyToQMgr"/>
					<xsl:with-param name="pReplyToQ" />			
					<xsl:with-param name="pExpiry" select="$p_Timeout"/>
					<xsl:with-param name="pReport" select="$p_Report"/>
					<xsl:with-param name="pPersistence" select="$p_Persistence"/>					
				</xsl:call-template>
			</xsl:when>
			<!-- Время жизни сообщений выставляется в два раза больше чем время таймаута, которое система ждет ответ-->
			<xsl:otherwise>
				<xsl:call-template name="tMQMD">
					<xsl:with-param name="pMsgId" select="$p_MsgId"/>
					<xsl:with-param name="pCorrelId" select="$p_CorrelId"/>
					<xsl:with-param name="pReplyToQMgr" select="$p_ReplyToQMgr"/>
					<xsl:with-param name="pReplyToQ" select="$p_ReplyToQ"/>
					<xsl:with-param name="pExpiry" select="$p_Timeout div 50 "/>
					<xsl:with-param name="withMQRFH2">
						<xsl:if test="boolean($pusrFolder)">true</xsl:if>
						<xsl:if test="not(boolean($pusrFolder))">false</xsl:if>
					</xsl:with-param>					
					<xsl:with-param name="pPersistence" select="$p_Persistence"/>										
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="vMQHeader">
		<xsl:choose>
			<xsl:when test="boolean($pusrFolder) and not(boolean($pMQHeader))">
				<!-- С версии MQ 7 MQRFH2.usr заголовок проставляется через новые Message Properties при помощи заголовка MQMP-->
				<xsl:variable name="vMQMP">
					<xsl:call-template name="tMQMP">
						<xsl:with-param name="pMesProp">
							<xsl:copy-of select="$pusrFolder"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>			
				<header name="MQMD">
					<dp:serialize select="$vMQMD" omit-xml-decl="yes"/>
				</header>
				<header name="MQMP">
					<dp:serialize select="$vMQMP" omit-xml-decl="yes"/>
				</header>
			</xsl:when>
			<xsl:when test="not(boolean($pusrFolder)) and not(boolean($pMQHeader))">
				<header name="MQMD">
					<dp:serialize select="$vMQMD" omit-xml-decl="yes"/>
				</header>
			</xsl:when>
			<xsl:when test="boolean($pMQHeader)"><xsl:copy-of select="$pMQHeader"/></xsl:when>
		</xsl:choose>
	</xsl:variable>
  
	<xsl:variable name="vQMObject">
		<xsl:choose>
			<xsl:when test="boolean($p_QMObject) and not(normalize-space($p_QMObject) ='')">
				<xsl:value-of select="$p_QMObject"/>			
			</xsl:when>
			<xsl:otherwise>
	<!--			<xsl:value-of select="$bpconfig:MQConn"/>-->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- AsyncPut работает только с версии MQ 7-->
	<xsl:variable name="vMqTarget">
		<xsl:choose>
			<xsl:when test="boolean($p_ReplyToQ)">dpmq://<xsl:value-of select="$vQMObject"/>//?RequestQueue=<xsl:value-of select="$p_DestinationQ"/>;ReplyQueue=<xsl:value-of select="$p_ReplyToQ"/>;TimeOut=<xsl:value-of select="$p_Timeout"/>;Transactional=<xsl:value-of select="$pTransaction"/>;Sync=true;PMO=4;GMO=4;ParseHeaders=true</xsl:when>
			<xsl:when test="boolean($pMQTarget)"><xsl:value-of select="$pMQTarget"/></xsl:when>
			<xsl:otherwise>dpmq://<xsl:value-of select="$vQMObject"/>//?RequestQueue=<xsl:value-of select="$p_DestinationQ"/>;ParseHeaders=false</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>		
	<xsl:variable name="vReplyMQ">
		<dp:url-open target="{$vMqTarget}" response="binaryNode" http-headers="$vMQHeader">
			<xsl:copy-of select="$pOutMessage"/>
		</dp:url-open>
	</xsl:variable>
	<xsl:variable name="vRespCode">
		<xsl:value-of select="dp:variable(concat('var://context/',$p_TransformName,'/_extension/responsecode'))"/>
	</xsl:variable>
	
<!--
	<xsl:message terminate="no" dp:type="all" dp:priority="error">vReplyMQ: <xsl:copy-of select="$vReplyMQ" /> </xsl:message>	
	<xsl:message terminate="no" dp:type="all" dp:priority="error">vRespCode: <xsl:copy-of select="$vRespCode" /> </xsl:message>	
	<xsl:message terminate="no" dp:type="all" dp:priority="error">vRespCode: <xsl:value-of select="$vRespCode" /> </xsl:message>
-->
	
	<xsl:variable name="vReply">
		<xsl:if test="boolean($vRespCode)">
		   <xsl:choose>
			<xsl:when test="$vRespCode!= 0 and $vRespCode!=2033">
				<Reply>
					<ReplyCode>-1</ReplyCode>
					<ReplyDescription>MQ system error. </ReplyDescription>
					<Error>
						<ErrorSystem>MQ</ErrorSystem>
						<ErrorType>3</ErrorType>
						<ErrorCode>
							<xsl:value-of select="$vRespCode"/>
						</ErrorCode>
						<ErrorDescription/>
					</Error>
				</Reply>	
			</xsl:when>
			<xsl:when test="$vRespCode=2033">
				<Reply>
				<ReplyCode>-1</ReplyCode>
						<ReplyDescription>MQ system error. </ReplyDescription>
					<Error>
						<ErrorSystem>MQ</ErrorSystem>
						<ErrorType>3</ErrorType>
						<ErrorCode>2033</ErrorCode>
						<ErrorDescription>The answer is not found. </ErrorDescription>
					</Error>
				</Reply>
			</xsl:when>
			<xsl:when test="$vRespCode = 0">
			  <Reply>
				<ReplyCode>0</ReplyCode>
				<ReplyHeaders>
					<xsl:copy-of select="$vReplyMQ/result/headers/*"/>
				</ReplyHeaders>
				<ReplyBody>
					<xsl:copy-of select="dp:binary-encode($vReplyMQ/result/binary/child::node())"/>
				</ReplyBody>
			  </Reply>
			</xsl:when>
		   </xsl:choose>
		</xsl:if>  
		
<!-- ответа не ждали	-->		
		<xsl:if test="not(boolean($vRespCode))">
			<Reply>
				<ReplyCode>0</ReplyCode>			
			</Reply>
		</xsl:if>
	</xsl:variable>

	<xsl:copy-of select="$vReply"/>
</xsl:template>

<xsl:template name="mqFunc:GetMessageFromMQ">
	<xsl:param name="pDestQM"/>
	<xsl:param name="pDestQ"/>
	<xsl:param name="p_CorrelId"/>
	
	<xsl:variable name="vMQMD">
		<xsl:call-template name="tMQMD">
			<xsl:with-param name="pCorrelId" select="$p_CorrelId"/>						
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="vMQMDHeader">
		<header name="MQMD">
			<xsl:copy-of select="$vMQMD"/>
		</header>
	</xsl:variable>

	<xsl:variable name="vMqTarget">
		<xsl:choose>
			<xsl:when test="boolean($p_CorrelId)">dpmq://<xsl:value-of select="$pDestQM"/>//?ReplyQueue=<xsl:value-of select="$pDestQ"/>;TimeOut=5;Transactional=true;Sync=true;GMO=2;MatchOptions=2</xsl:when>
			<xsl:otherwise>dpmq://<xsl:value-of select="$pDestQM"/>//?ReplyQueue=<xsl:value-of select="$pDestQ"/>;TimeOut=5;Transactional=true;Sync=true;GMO=2</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="vReplyMQ">
		<dp:url-open target="{$vMqTarget}" response="binaryNode" http-headers="$vMQMDHeader"/>
	</xsl:variable>
	
	<xsl:variable name="vRespCode">
		<xsl:value-of select="dp:variable('var://context/TRANSFORM/_extension/responsecode')"/>
	</xsl:variable>
	
	<xsl:variable name="vReply">
		<xsl:choose>
			<xsl:when test="$vRespCode!=0 and $vRespCode!=2033">
				<Reply>
					<ReplyCode>-1</ReplyCode>
					<ReplyBody/>
					<ReplyDescription>MQ system error. </ReplyDescription>
					<Error>
						<ErrorSystem>MQ</ErrorSystem>
						<ErrorType>2</ErrorType>
						<ErrorCode>
							<xsl:value-of select="$vRespCode"/>
						</ErrorCode>
						<ErrorDescription/>
					</Error>
				</Reply>	
			</xsl:when>
			<xsl:when test="$vRespCode = 2033">
				<Reply>
					<ReplyCode>-1</ReplyCode>
					<ReplyDescription>MQ system error. </ReplyDescription>
					<Error>
						<ErrorSystem>MQ</ErrorSystem>
						<ErrorType>3</ErrorType>
						<ErrorCode>2033</ErrorCode>
						<ErrorDescription>The answer is not found. </ErrorDescription>
					</Error>
				</Reply>	
			</xsl:when>
			<xsl:when test="$vRespCode = 0">
				<Reply>
					<ReplyCode>0</ReplyCode>
					<ReplyHeaders>
						<xsl:copy-of select="$vReplyMQ/result/headers/child::node()"/>
					</ReplyHeaders>
					<ReplyBody>
						<xsl:copy-of select="dp:binary-encode($vReplyMQ/result/binary/child::node())"/>
					</ReplyBody>
				</Reply>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:copy-of select="$vReply"/>
	
</xsl:template>	

<func:function name="mqFunc:GetMsgIdFromHeader">
		<xsl:param name="pHeader"/>
		
	<xsl:variable name="vSerHeader">
		<xsl:copy-of select="dp:parse($pHeader)"/>
	</xsl:variable>	
		
	<func:result>
		<xsl:value-of select="$vSerHeader//MsgId"/>
	</func:result>
</func:function>
	
<func:function name="mqFunc:GetCorrelIdFromHeader">
        <xsl:param name="pHeader"/>
        
        <xsl:variable name="vSerHeader">
            <xsl:copy-of select="dp:parse($pHeader)"/>
        </xsl:variable>	
        
        <func:result>
            <xsl:value-of select="$vSerHeader//CorrelId"/>
        </func:result>
</func:function>

<func:function name="mqFunc:GenNewMsgId">
	
	<func:result>
		<xsl:value-of select="concat(translate(dp:generate-uuid(),'-',''),'0000000000000000')"/>	
	</func:result>	
</func:function>
	
<xsl:template name="tMQMD">
		<xsl:param name="pOldMQMD">
			<MQMD>
				<StrucId>MD</StrucId>
				<Version>2</Version>
				<Report>0</Report>
				<MsgType>1</MsgType>
				<Expiry>-1</Expiry>
				<Feedback>0</Feedback>
				<Encoding>546</Encoding>
				<CodedCharSetId>1208</CodedCharSetId>
				<Format>MQSTR</Format>
				<Priority>5</Priority>
				<Persistence>0</Persistence>
				<MsgId>000000000000000000000000000000000000000000000000</MsgId>
				<CorrelId>000000000000000000000000000000000000000000000000</CorrelId>
				<BackoutCount>0</BackoutCount>
				<ReplyToQ/>
				<ReplyToQMgr/>
				<UserIdentifier/>
				<AccountingToken/>
				<ApplIdentityData/>
				<PutApplType/>
				<PutApplName/>
				<PutDate/>
				<PutTime/>
				<ApplOriginData/>
			</MQMD>
		</xsl:param>
		<xsl:param name="pMsgId"/>
		<xsl:param name="pCorrelId"/>
		<xsl:param name="pReplyToQMgr"/>
		<xsl:param name="pReplyToQ"/>
		<xsl:param name="pExpiry"/>
		<xsl:param name="pPersistence"/>
		<xsl:param name="pReport"/>
		<xsl:param name="pMsgType"/>
		<xsl:param name="withMQRFH2" select="'false'"/>	
		<xsl:param name="pSerialize" select="'true'"/>

		<xsl:variable name="vMQMD">
			<MQMD>
				<StrucId>
					<xsl:value-of select="$pOldMQMD/MQMD/StrucId"/>
				</StrucId>
				<Version>
					<xsl:value-of select="$pOldMQMD/MQMD/Version"/>
				</Version>
				<Report>
					<xsl:choose>
						<xsl:when test="boolean($pReport)">
							<xsl:value-of select="$pReport"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$pOldMQMD/MQMD/Report"/>
						</xsl:otherwise>
					</xsl:choose>
				</Report>
				<MsgType>
					<xsl:choose>
						<xsl:when test="boolean($pMsgType)">
							<xsl:value-of select="$pMsgType"/>							
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$pOldMQMD/MQMD/MsgType"/>
						</xsl:otherwise>
					</xsl:choose>
				</MsgType>
				<Expiry>
					<xsl:choose>
						<xsl:when test="boolean($pExpiry)">
							<xsl:value-of select="$pExpiry"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$pOldMQMD/MQMD/Expiry"/>
						</xsl:otherwise>
					</xsl:choose>
				</Expiry>
				<Feedback>
					<xsl:value-of select="$pOldMQMD/MQMD/Feedback"/>
				</Feedback>
				<Encoding>
					<xsl:value-of select="$pOldMQMD/MQMD/Encoding"/>
				</Encoding>
				<CodedCharSetId>
					<xsl:value-of select="$pOldMQMD/MQMD/CodedCharSetId"/>
				</CodedCharSetId>
				<Format>
					<xsl:choose>
						<xsl:when test="$withMQRFH2='false'">
							<xsl:value-of select="'MQSTR'"/>							
						</xsl:when>
						<xsl:when test="$withMQRFH2='true'">
							<xsl:value-of select="'MQHRF2'"/>
						</xsl:when>
					</xsl:choose>
				</Format>
				<Priority>
					<xsl:value-of select="$pOldMQMD/MQMD/Priority"/>
				</Priority>
				<Persistence>
					<xsl:choose>
						<xsl:when test="boolean($pPersistence)">
							<xsl:value-of select="$pPersistence"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$pOldMQMD/MQMD/Persistence"/>
						</xsl:otherwise>
					</xsl:choose>
				</Persistence>
				<MsgId>
					<xsl:choose>
						<xsl:when
							test="$pMsgId != '000000000000000000000000000000000000000000000000'">
							<xsl:value-of select="$pMsgId"/>
						</xsl:when>
						<xsl:when test="boolean($pOldMQMD/MQMD/MsgId)">
							<xsl:value-of select="$pOldMQMD/MQMD/MsgId"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$pMsgId"/>
						</xsl:otherwise>
					</xsl:choose>
				</MsgId>
				<CorrelId>
					<xsl:choose>
						<xsl:when test="boolean($pCorrelId)">
							<xsl:value-of select="$pCorrelId"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$pOldMQMD/MQMD/CorrelId"/>
						</xsl:otherwise>
					</xsl:choose>
				</CorrelId>
				<BackoutCount>
					<xsl:value-of select="$pOldMQMD/MQMD/BackoutCount"/>
				</BackoutCount>
				<ReplyToQ>
					<xsl:choose>
						<xsl:when test="$pReplyToQ = 'null'"/>
						<xsl:when test="boolean($pReplyToQ)">
							<xsl:value-of select="$pReplyToQ"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$pOldMQMD/MQMD/ReplyToQ"/>
						</xsl:otherwise>
					</xsl:choose>
				</ReplyToQ>
				<ReplyToQMgr>
					<xsl:choose>
						<xsl:when test="$pReplyToQMgr = 'null'"/>
						<xsl:when test="boolean($pReplyToQMgr)">
							<xsl:value-of select="$pReplyToQMgr"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$pOldMQMD/MQMD/ReplyToQMgr"/>
						</xsl:otherwise>
					</xsl:choose>
				</ReplyToQMgr>
				<UserIdentifier>
					<xsl:value-of select="$pOldMQMD/MQMD/UserIdentifier"/>
				</UserIdentifier>
				<AccountingToken>
					<xsl:value-of select="$pOldMQMD/MQMD/AccountingToken"/>
				</AccountingToken>
				<ApplIdentityData>
					<xsl:value-of select="$pOldMQMD/MQMD/ApplIdentityData"/>
				</ApplIdentityData>
				<PutApplType>
					<xsl:value-of select="$pOldMQMD/MQMD/PutApplType"/>
				</PutApplType>
				<PutApplName>
					<xsl:value-of select="$pOldMQMD/MQMD/PutApplName"/>
				</PutApplName>
				<PutDate>
					<xsl:value-of select="$pOldMQMD/MQMD/PutDate"/>
				</PutDate>
				<PutTime>
					<xsl:value-of select="$pOldMQMD/MQMD/PutTime"/>
				</PutTime>
				<ApplOriginData>
					<xsl:value-of select="$pOldMQMD/MQMD/ApplOriginData"/>
				</ApplOriginData>
				<xsl:if test="boolean($pOldMQMD/MQMD/GroupId)">
					<GroupId>
						<xsl:value-of select="$pOldMQMD/MQMD/GroupId"/>
					</GroupId>
				</xsl:if>
				<xsl:if test="boolean($pOldMQMD/MQMD/MsgSeqNumber)">
					<MsgSeqNumber>
						<xsl:value-of select="$pOldMQMD/MQMD/MsgSeqNumber"/>
					</MsgSeqNumber>
				</xsl:if>
				<xsl:if test="boolean($pOldMQMD/MQMD/Offset)">
					<Offset>
						<xsl:value-of select="$pOldMQMD/MQMD/Offset"/>
					</Offset>
				</xsl:if>
				<xsl:if test="boolean($pOldMQMD/MQMD/MsgFlags)">
					<MsgFlags>
						<xsl:value-of select="$pOldMQMD/MQMD/MsgFlags"/>
					</MsgFlags>
				</xsl:if>
				<xsl:if test="boolean($pOldMQMD/MQMD/OriginalLength)">
					<OriginalLength>
						<xsl:value-of select="$pOldMQMD/MQMD/OriginalLength"/>
					</OriginalLength>
				</xsl:if>
			</MQMD>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$pSerialize = 'true'">
				<dp:serialize select="$vMQMD" omit-xml-decl="yes"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$vMQMD"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<xsl:template name="tMQOD">
	<xsl:param name="pQueueMgr"/>
	<xsl:param name="pQueue"/>
	<xsl:param name="pSerialize" select="'true'"/>
	
	<xsl:variable name="vMQOD">
		<MQOD>
			<ObjectQMgrName>
				<xsl:value-of select="$pQueueMgr"/>
			</ObjectQMgrName>
			<ObjectName>
				<xsl:value-of select="$pQueue"/>
			</ObjectName>
		</MQOD>
	</xsl:variable>

	<xsl:choose>
		<xsl:when test="$pSerialize = 'true'">
			<dp:serialize select="$vMQOD" omit-xml-decl="yes"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="$vMQOD"/>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<xsl:template name="tMQRFH2">
	<xsl:param name="pusrFolder"/>
	<xsl:param name="pSerialize" select="'false'"/>
	
	<xsl:variable name="v_MQRFH2">	
		<MQRFH2>
			<StrucId>RFH </StrucId>
			<Version>2</Version>
			<Encoding>546</Encoding>
			<CodedCharSetId>1208</CodedCharSetId>
			<Format>MQSTR </Format>
			<Flags>0</Flags>
			<NameValueCCSID>1208</NameValueCCSID>
			<NameValueData>
				<NameValue>
					<usr>
						<xsl:copy-of select="$pusrFolder"/>
					</usr>
				</NameValue>
			</NameValueData>
		</MQRFH2>
	</xsl:variable>

	<xsl:choose>
		<xsl:when test="$pSerialize = 'true'">
			<dp:serialize select="$v_MQRFH2" omit-xml-decl="yes"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="$v_MQRFH2"/>
		</xsl:otherwise>
	</xsl:choose>
		
</xsl:template>

<xsl:template name="tMQMP">
	<xsl:param name="pMesProp"/>
	<xsl:param name="pSerialize" select="'false'"/>
	
	<xsl:variable name="v_MQMP">	
		<MQMP>
			<xsl:for-each select="$pMesProp/MsgProps/child::node()">
				<xsl:element name="Property">
					<xsl:attribute name="name">
						<xsl:value-of select="name()"/>
					</xsl:attribute>
					<xsl:attribute name="type">
						<xsl:value-of select="'string'"/>
					</xsl:attribute>
					<xsl:value-of select="text()"/>
				</xsl:element>
			</xsl:for-each>
		</MQMP>
	</xsl:variable>

	<xsl:choose>
		<xsl:when test="$pSerialize = 'true'">
			<dp:serialize select="$v_MQMP" omit-xml-decl="yes"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:copy-of select="$v_MQMP"/>
		</xsl:otherwise>
	</xsl:choose>
		
</xsl:template>

	<!--Функция выставдяет Очередь и Менеджер назначения в MQXMIT заголовке, а также меняет CorrelId на MsgId:
Принимает 4 параметра:
	1 - исходный заголовок XMIT
	2 - Распарсенный заголовок MQMD
	3 - Тип операции request|response|notification
	4 - Очередь назначения, необязательный параметр
	5 - Менеджер назначения, необязательный параметр
Примеры вызова:
	1 - <xsl:value-of select="mqFunc:MQXMITChangeForError($vMQXMIT,$vMQMD,$vOperationType,$vReplyQ,$vReplyQMgr)"/>
	2 - <xsl:value-of select="mqFunc:MQXMITChangeForError($vMQXMIT,$vMQMD,$vOperationType)"/>
Порядок работы:
	Если тип запроса request, то меняет CorrelId на MsgId, в остальных случаях, оставляет его прежним.
	Выбор Очереди и Менеджера идет по следующим вариантам:
	1) Значение очереди ответов или значение менеджера ответа в MQMD не заполненно, и длина значения Очереди назначения/Менеджера назначения больше нуля, то  используется значение Очереди назначения/Менеджера назначения.
	2) Значение очереди ответов или значение менеджера ответа в MQMD не заполненно, и длина значения Очереди назначения/Менеджера назначения равна нулю, то  используется из исходного заголовка XMIT.
	3) Значение очереди ответов и значение менеджера ответа в MQMD заполненно, и тип операции request, используется из заголовка MQMD.
	4) Значение очереди ответов и значение менеджера ответа в MQMD заполненно, и тип операции не request, используется из исходного заголовка XMIT.
-->
	<func:function name="mqFunc:MQXMITChangeForError">
		<xsl:param name="vMQXQHbin"/>
		<xsl:param name="vMQMD"/>
		<xsl:param name="vOperationType"/>
		<xsl:param name="vReplyQ" select="''"/>
		<xsl:param name="vReplyQMgr" select="''"/>
		
		<xsl:variable name="vMQXQHbin_QName">
			<xsl:choose>
				<xsl:when test="string-length($vReplyQ)>0 and (string-length(normalize-space($vMQMD/MQMD/ReplyToQ))=0 or string-length(normalize-space($vMQMD/MQMD/ReplyToQMgr))=0)">
					<xsl:value-of select="substring(concat(dp:radix-convert(dp:encode(normalize-space($vReplyQ),'base-64'),64,16),'202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020'),0,97)"/>
				</xsl:when>
				<xsl:when test="($vOperationType='request') and not(string-length(normalize-space($vMQMD/MQMD/ReplyToQ))=0 or string-length(normalize-space($vMQMD/MQMD/ReplyToQMgr))=0)">
					<xsl:value-of select="substring(concat(dp:radix-convert(dp:encode(normalize-space(normalize-space($vMQMD/MQMD/ReplyToQ)),'base-64'),64,16),'202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020'),0,97)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring($vMQXQHbin,17,96)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="vMQXQHbin_MsgId">
			<xsl:value-of select="substring($vMQXQHbin,305,48)"/>
		</xsl:variable>
		<xsl:variable name="vMQXQHbin_CorrelId">
			<xsl:choose>
				<xsl:when test="$vOperationType='request'">
					<xsl:value-of select="substring($vMQXQHbin,305,48)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring($vMQXQHbin,353,48)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="vMQXQHbin_QMgrName">
			<xsl:choose>
				<xsl:when test="string-length($vReplyQMgr)>0 and (string-length(normalize-space($vMQMD/MQMD/ReplyToQ))=0 or string-length(normalize-space($vMQMD/MQMD/ReplyToQMgr))=0)">
					<xsl:value-of select="substring(concat(dp:radix-convert(dp:encode(normalize-space($vReplyQMgr),'base-64'),64,16),'202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020'),0,97)"/>
				</xsl:when>
				<xsl:when test="($vOperationType='request') and not(string-length(normalize-space($vMQMD/MQMD/ReplyToQ))=0 or string-length(normalize-space($vMQMD/MQMD/ReplyToQMgr))=0)">
					<xsl:value-of select="substring(concat(dp:radix-convert(dp:encode(normalize-space(normalize-space($vMQMD/MQMD/ReplyToQMgr)),'base-64'),64,16),'202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020'),0,97)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring($vMQXQHbin,113,96)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<func:result><xsl:value-of select="concat(substring($vMQXQHbin,0,17),normalize-space($vMQXQHbin_QName),normalize-space($vMQXQHbin_QMgrName),substring($vMQXQHbin,209,96),normalize-space($vMQXQHbin_MsgId),normalize-space($vMQXQHbin_CorrelId),substring($vMQXQHbin,401))"/></func:result>
	</func:function>
	<func:function name="mqFunc:MQXMITMake">
		<xsl:param name="vMsgId" select="'000000000000000000000000000000000000000000000000'"/>
		<xsl:param name="vCorrelId" select="'000000000000000000000000000000000000000000000000'"/>
		<xsl:param name="vTargetQ" select="''"/>
		<xsl:param name="vTargetQMgr" select="''"/>
		
		<xsl:variable name="vDefault">58514820010000004553422e47572e5941442e524553504f4e534520202020202020202020202020202020202020202020202020202020204d39392e4553422e475731202020202020202020202020202020202020202020202020202020202020202020202020204d442020010000000000000008000000ffffffff0000000022020000000000004D51535452202020ffffffff02000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000</xsl:variable>
		
		<xsl:variable name="vMQXQHbin_QName">
			<xsl:value-of select="substring(concat(dp:radix-convert(dp:encode(normalize-space($vTargetQ),'base-64'),64,16),'202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020'),0,97)"/>
		</xsl:variable>
		<xsl:variable name="vMQXQHbin_QMgrName">
			<xsl:value-of select="substring(concat(dp:radix-convert(dp:encode(normalize-space($vTargetQMgr),'base-64'),64,16),'202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020'),0,97)"/>
		</xsl:variable>
		<xsl:variable name="vPutTime">
			<xsl:variable name="vPutReal">
				<xsl:value-of select="mqFunc:GetPutTime()"/>
			</xsl:variable>
			<xsl:message>vPutReal: <xsl:value-of select="$vPutReal"/>, length: <xsl:value-of select="string-length($vPutReal)"/></xsl:message>
			<xsl:choose>
				<xsl:when test="string-length($vPutReal) = 16"><xsl:value-of select="dp:radix-convert(dp:encode(normalize-space($vPutReal),'base-64'),64,16)"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="dp:radix-convert(dp:encode(normalize-space('0000000000000000'),'base-64'),64,16)"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
						
		<func:result><xsl:value-of select="concat(substring($vDefault,0,17),normalize-space($vMQXQHbin_QName),normalize-space($vMQXQHbin_QMgrName),substring($vDefault,209,96),normalize-space($vMsgId),normalize-space($vCorrelId),substring($vDefault,401, 416), normalize-space($vPutTime), substring($vDefault, 849))"/></func:result>
	</func:function>
	
	<func:function name="mqFunc:GetPutTime">
		<xsl:variable name="timestamp" select="date:date-time()"/>
		<!-- Получим милисекунду из функции, которая возвращает период в милисекундах с 1 января 1970 года -->
		<xsl:variable name="ms" select="substring(dp:time-value(),11,2)"/>
		<func:result>
			<xsl:value-of select="translate(translate(translate(concat(substring-before($timestamp,'+'),$ms), ':', ''), '-', ''), 'T', '')"/>
		</func:result>
	</func:function>
	
	<func:function name="mqFunc:setMQXMITReplyParams">
		<xsl:param name="pMQXQHbin"/>
		<xsl:param name="pReplyToQMgr" select="''"/>
		<xsl:param name="pReplyToQ" select="''"/>
		<xsl:variable name="vReplyToQMgrbin" select="substring(concat(dp:radix-convert(dp:encode(normalize-space($pReplyToQMgr),'base-64'),64,16),'202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020'),0,97)"/>
		<xsl:variable name="vReplyToQbin" select="substring(concat(dp:radix-convert(dp:encode(normalize-space($pReplyToQ),'base-64'),64,16),'202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020'),0,97)"/>
		<xsl:variable name="vReplaced">
			<xsl:choose>
				<xsl:when test="normalize-space($pReplyToQ) != '' and normalize-space($pReplyToQMgr) != ''">
					<xsl:value-of select="concat(substring($pMQXQHbin,0,409),$vReplyToQbin, $vReplyToQMgrbin, substring($pMQXQHbin,601))"/>
				</xsl:when>
				<xsl:when test="normalize-space($pReplyToQMgr) != ''">					
					<xsl:value-of select="concat(substring($pMQXQHbin,0,505), $vReplyToQMgrbin, substring($pMQXQHbin,601))"/>
				</xsl:when>
				<xsl:when test="normalize-space($pReplyToQ) != ''">					
					<xsl:value-of select="concat(substring($pMQXQHbin,0,409), $vReplyToQbin, substring($pMQXQHbin,505))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$pMQXQHbin"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<func:result>
			<xsl:value-of select="$vReplaced"/>
		</func:result>
	</func:function>
	
</xsl:stylesheet>
