<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" 
	xmlns:date="http://exslt.org/dates-and-times"
	xmlns:func="http://exslt.org/functions"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:Config="http://sberbank.ru/sbt/config"
	xmlns:mqFunc="http://sberbank.ru/sbt/functions/mq"
	xmlns:XslFunc="http://sberbank.ru/sbt/functions/xsl"
	xmlns:sb="http://sbrf.ru/baseproduct/httpgate/service/1"
	xmlns:erib="http://sbrf.ru/baseproduct/erib/adapter/1"
	xmlns:mdm="http://sbrf.ru/mdm/adapter/1" 
	xmlns:esberrns="http://croc.ru/sbrf/bp/EventMsg" 
  extension-element-prefixes="dp date func Config mqFunc XslFunc" exclude-result-prefixes="dp soap date func esberrns sb mdm erib Config mqFunc XslFunc">
	<xsl:import href="local:///allParameters.xsl"/>
	<xsl:import href="local:///allMQFunction.xsl"/>
	
	<xsl:output dp:escaping="minimum"/>
	<func:function name="XslFunc:GenDateTime">
		<xsl:variable name="vDateTime" select="date:date-time()"/>
		<xsl:variable name="vNormDate">
			<xsl:choose>
				<xsl:when test="contains($vDateTime,'+')">
					<xsl:value-of select="substring-before($vDateTime,'+')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$vDateTime"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<func:result>
			<xsl:value-of select="translate($vNormDate,'T',' ')"/>
		</func:result>
	</func:function>
	
	<func:function name="XslFunc:GenDateTimeForVSP">
		<xsl:variable name="vDateTime" select="date:date-time()"/>
		<xsl:variable name="vNormDate">
			<xsl:choose>
				<xsl:when test="contains($vDateTime,'+')">
					<xsl:value-of select="substring-before($vDateTime,'+')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$vDateTime"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<func:result>
			<xsl:value-of select="$vNormDate"/>
		</func:result>
	</func:function>
	
	<func:function name="XslFunc:GenDateWithoutTZ">
		<xsl:variable name="vDateTime" select="date:date()"/>
		<xsl:variable name="vNormDate">
			<xsl:choose>
				<xsl:when test="contains($vDateTime,'+')">
					<xsl:value-of select="substring-before($vDateTime,'+')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$vDateTime"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<func:result>
			<xsl:value-of select="$vNormDate"/>
		</func:result>
	</func:function>
	
	<func:function name="XslFunc:ConvertUIDToMqId">
		<xsl:param name="pUID"/>
		<func:result>
			<xsl:value-of select="concat(translate($pUID,'-',''),'0000000000000000')"/>
		</func:result>
	</func:function>
	
	<func:function name="XslFunc:GenUID">
		<func:result>
			<xsl:value-of select="translate(dp:generate-uuid(),'-','')"/>
		</func:result>
	</func:function>
	
	<func:function name="XslFunc:IFXMesHeadCreate">
		<xsl:param name="pFSName"/>
		<xsl:param name="pRqUID"/>
		<xsl:param name="pRqTm"/>
		<xsl:param name="pOperUID"/>
		<xsl:param name="pErrCode"/>
		<xsl:param name="pErrMess"/>
		<xsl:variable name="vErrCode">
			<xsl:choose>
				<xsl:when test="boolean($pErrCode) and not(normalize-space($pErrCode)='' )">
					<xsl:value-of select="$pErrCode"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$Config:SystemError"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<func:result>
			<xsl:choose>
				<xsl:when test="$pFSName ='BP_ES' or $pFSName ='BP_ERIB'  or $pFSName ='BP_ASBC' or $pFSName ='ISPPN'  or $pFSName ='BP_UFO' ">
					<sb:RqUID>
						<xsl:value-of select="$pRqUID"/>
					</sb:RqUID>
					<sb:RqTm>
						<xsl:value-of select="XslFunc:GenDateTimeForVSP()"/>
					</sb:RqTm>
					<sb:OperUID>
						<xsl:value-of select="$pOperUID"/>
					</sb:OperUID>
					<sb:Status>
						<sb:StatusCode>
							<xsl:value-of select="$vErrCode"/>
						</sb:StatusCode>
						<sb:StatusDesc>
							<xsl:value-of select="$pErrMess"/>
						</sb:StatusDesc>
					</sb:Status>
				</xsl:when>
				<xsl:when test="$pFSName='BP_VSP' or $pFSName='BP_SPOOBK'">
					<sb:RqUID>
						<xsl:value-of select="$pRqUID"/>
					</sb:RqUID>
					<sb:RqTm>
						<xsl:value-of select="XslFunc:GenDateTimeForVSP()"/>
					</sb:RqTm>
					<sb:Status>
						<sb:StatusCode>
							<xsl:value-of select="$vErrCode"/>
						</sb:StatusCode>
						<sb:StatusDesc>
							<xsl:value-of select="$pErrMess"/>
						</sb:StatusDesc>
					</sb:Status>
				</xsl:when>
				<xsl:when test="$pFSName='BP_MDM'">
					<mdm:IFX>
						<mdm:Status>
							<mdm:StatusCode>
								<xsl:value-of select="$vErrCode"/>
							</mdm:StatusCode>
							<mdm:StatusDesc>
								<xsl:value-of select="$pErrMess"/>
							</mdm:StatusDesc>
						</mdm:Status>
					</mdm:IFX>
				</xsl:when>
			</xsl:choose>
		</func:result>
	</func:function>
	
	<func:function name="XslFunc:IFXErrMesCreate">
		<xsl:param name="pFSName"/>
		<xsl:param name="pMesType"/>
		<xsl:param name="pRqUID"/>
		<xsl:param name="pRqTm"/>
		<xsl:param name="pOperUID"/>
		<xsl:param name="pErrCode" select="$Config:SystemError"/>
		<xsl:param name="pErrMess" select="'Ошибка обработки, операция не может быть выполнена'"/>
		<func:result>
			<xsl:choose>
				<xsl:when test="$pMesType='CustInqRs'">
					<sb:CustInqRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:CustInqRs>
				</xsl:when>
				<xsl:when test="$pMesType='BankAcctInqRs'">
					<sb:BankAcctInqRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:BankAcctInqRs>
				</xsl:when>
				<xsl:when test="$pMesType='AcctInqRs'">
					<sb:AcctInqRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:AcctInqRs>
				</xsl:when>
				<xsl:when test="$pMesType='DepAcctStmtInqRs'">
					<sb:DepAcctStmtInqRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:DepAcctStmtInqRs>
				</xsl:when>
				<xsl:when test="$pMesType='BankAcctStmtInqRs'">
					<sb:BankAcctStmtInqRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:BankAcctStmtInqRs>
				</xsl:when>
				<xsl:when test="$pMesType='CCAcctStmtInqRs'">
					<sb:CCAcctStmtInqRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:CCAcctStmtInqRs>
				</xsl:when>
				<xsl:when test="$pMesType='LoanInqRs'">
					<sb:LoanInqRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:LoanInqRs>
				</xsl:when>
				<xsl:when test="$pMesType='XferAddRs'">
					<sb:XferAddRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:XferAddRs>
				</xsl:when>
				<xsl:when test="$pMesType='CustAddRs'">
					<sb:CustAddRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:CustAddRs>
				</xsl:when>
				<xsl:when test="$pMesType='BankAcctAddRs'">
					<sb:BankAcctAddRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:BankAcctAddRs>
				</xsl:when>
				<xsl:when test="$pMesType='CardReissueRs'">
					<sb:CardReissueRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:CardReissueRs>
				</xsl:when>
				<xsl:when test="$pMesType='AddCardIssueRs'">
					<sb:AddCardIssueRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:AddCardIssueRs>
				</xsl:when>
				<xsl:when test="$pMesType='CardAcctDInqRs'">
					<sb:CardAcctDInqRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:CardAcctDInqRs>
				</xsl:when>
				<xsl:when test="$pMesType='CardAcctInqRs'">
					<sb:CardAcctInqRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:CardAcctInqRs>
				</xsl:when>
				<xsl:when test="$pMesType='BankAcctStmtImgInqRs'">
					<sb:BankAcctStmtImgInqRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:BankAcctStmtImgInqRs>
				</xsl:when>
				<xsl:when test="$pMesType='CCAcctExtStmtInqRs'">
					<sb:CCAcctExtStmtInqRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:CCAcctExtStmtInqRs>
				</xsl:when>
				<xsl:when test="$pMesType='CardBlockRs'">
					<sb:CardBlockRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:CardBlockRs>
				</xsl:when>
				<xsl:when test="$pMesType='InfoInqRs'">
					<sb:InfoInqRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:InfoInqRs>
				</xsl:when>
				<xsl:when test="$pMesType='DepToNewDepAddRs'">
					<sb:DepToNewDepAddRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:DepToNewDepAddRs>
				</xsl:when>
				<xsl:when test="$pMesType='CardToNewDepAddRs'">
					<sb:CardToNewDepAddRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:CardToNewDepAddRs>
				</xsl:when>
				<xsl:when test="$pMesType='CustInqBySNILSRs'">
					<sb:CustInqBySNILSRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:CustInqBySNILSRs>
				</xsl:when>
				<xsl:when test="$pMesType='CtrlWordModRs'">
					<sb:CtrlWordModRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:CtrlWordModRs>
				</xsl:when>
				<xsl:when test="$pMesType='BankAcctModRs'">
					<sb:BankAcctModRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:BankAcctModRs>
				</xsl:when>
				<xsl:when test="$pMesType='CardContractCreditLimitModRs'">
					<sb:CardContractCreditLimitModRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:CardContractCreditLimitModRs>
				</xsl:when>
				<xsl:when test="$pMesType='CardStatusModSyncRs'">
					<sb:CardStatusModSyncRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:CardStatusModSyncRs>
				</xsl:when>
				<xsl:when test="$pMesType='GetNPLsRs'">
					<sb:GetNPLsRs>
						<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
					</sb:GetNPLsRs>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="XslFunc:IFXMesHeadCreate($pFSName,$pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess)"/>
				</xsl:otherwise>
			</xsl:choose>
		</func:result>
	</func:function>
	
	<func:function name="XslFunc:ERIBMesHeadCreate">
		<xsl:param name="pRqUID"/>
		<xsl:param name="pRqTm"/>
		<xsl:param name="pOperUID"/>
		<xsl:param name="pErrCode"/>
		<xsl:param name="pErrMess"/>
		<xsl:param name="pServErrMess"/>
		<xsl:variable name="vErrCode">
			<xsl:choose>
				<xsl:when test="boolean($pErrCode) and not(normalize-space($pErrCode)='' )">
					<xsl:value-of select="$pErrCode"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$Config:SystemError"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<func:result>
			<erib:RqUID>
				<xsl:value-of select="$pRqUID"/>
			</erib:RqUID>
			<erib:RqTm>
				<xsl:value-of select="XslFunc:GenDateTimeForVSP()"/>
			</erib:RqTm>
			<xsl:if test="not(normalize-space($pOperUID)='')">
				<erib:OperUID>
					<xsl:value-of select="$pOperUID"/>
				</erib:OperUID>
			</xsl:if>
			<erib:Status>
				<erib:StatusCode>
					<xsl:value-of select="$vErrCode"/>
				</erib:StatusCode>
				<xsl:if test="not(normalize-space($pErrMess)='')">
					<erib:StatusDesc>
						<xsl:value-of select="$pErrMess"/>
					</erib:StatusDesc>
				</xsl:if>
				<xsl:if test="boolean($pServErrMess)">
					<erib:ServerStatusDesc>
						<xsl:value-of select="$pServErrMess"/>
					</erib:ServerStatusDesc>
				</xsl:if>
			</erib:Status>
		</func:result>
	</func:function>
	
	<func:function name="XslFunc:ERIBErrMesCreate">
		<xsl:param name="pMesType"/>
		<xsl:param name="pRqUID"/>
		<xsl:param name="pRqTm"/>
		<xsl:param name="pOperUID"/>
		<xsl:param name="pErrCode" select="$Config:SystemError"/>
		<xsl:param name="pErrMess" select="'Ошибка обработки, операция не может быть выполнена'"/>
		<xsl:param name="pServErrMess" select="''"/>
		<func:result>
			<xsl:choose>
				<xsl:when test="$pMesType='DepAcctStmtInqRs'">
					<erib:DepAcctExtRs>
						<xsl:copy-of select="XslFunc:ERIBMesHeadCreate($pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess,$pServErrMess)"/>
					</erib:DepAcctExtRs>
				</xsl:when>
				<xsl:when test="$pMesType='TCDXferAddRs' or $pMesType='TDDXferAddRs' or $pMesType='TDCXferAddRs' or $pMesType='TCPXferAddRs' or $pMesType='TCCXferAddRs' or $pMesType='TDDCXferAddRs' or $pMesType= 'TDCCXferAddRs' ">
					<erib:XferAddRs>
						<xsl:copy-of select="XslFunc:ERIBMesHeadCreate($pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess,$pServErrMess)"/>
					</erib:XferAddRs>
				</xsl:when>
				<xsl:when test="$pMesType='TCDSvcAcctAddRs' or $pMesType='TDDSvcAcctAddRs' or $pMesType='TCP_TCDSvcAcctAddRs' or $pMesType='TCPSvcAcctAddRs' or $pMesType='TCCSvcAcctAddRs' ">
					<erib:XferAddRs>
						<xsl:copy-of select="XslFunc:ERIBMesHeadCreate($pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess,$pServErrMess)"/>
					</erib:XferAddRs>
				</xsl:when>
				<xsl:when test="$pMesType='SDPSvcAddRs' or $pMesType='SDCSvcAddRs' ">
					<erib:SvcAddRs>
						<xsl:copy-of select="XslFunc:ERIBMesHeadCreate($pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess,$pServErrMess)"/>
					</erib:SvcAddRs>
				</xsl:when>
				<xsl:when test="$pMesType='LoanInfoRs'">
					<erib:LoanInfoRs>
						<erib:RqUID>
							<xsl:value-of select="$pRqUID"/>
						</erib:RqUID>
						<erib:RqTm>
							<xsl:value-of select="XslFunc:GenDateTimeForVSP()"/>
						</erib:RqTm>
						<xsl:if test="not(normalize-space($pOperUID)='')">
							<erib:OperUID>
								<xsl:value-of select="$pOperUID"/>
							</erib:OperUID>
						</xsl:if>
						<erib:LoanRec>
							<erib:Status>
								<erib:StatusCode>
									<xsl:value-of select="$pErrCode"/>
								</erib:StatusCode>
								<erib:StatusDesc>
									<xsl:value-of select="$pErrMess"/>
								</erib:StatusDesc>
								<xsl:if test="not(normalize-space($pServErrMess)='')">
									<erib:ServerStatusDesc>
										<xsl:value-of select="$pServErrMess"/>
									</erib:ServerStatusDesc>
								</xsl:if>
							</erib:Status>
						</erib:LoanRec>	
					</erib:LoanInfoRs>							
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="erib:{$pMesType}">
						<xsl:copy-of select="XslFunc:ERIBMesHeadCreate($pRqUID,$pRqTm,$pOperUID,$pErrCode,$pErrMess,$pServErrMess)"/>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</func:result>
	</func:function>
	
	<func:function name="XslFunc:ESBMesHeadCreate">
		<xsl:param name="pRqUID"/>
		<xsl:param name="pRqTm"/>
		<xsl:param name="pOperUID"/>
		<xsl:param name="pSPName"/>
		<func:result>
			<RqUID>
				<xsl:value-of select="$pRqUID"/>
			</RqUID>
			<RqTm>
				<xsl:value-of select="$pRqTm"/>
			</RqTm>
			<xsl:if test="not(normalize-space($pOperUID)='')">
				<OperUID>
					<xsl:value-of select="$pOperUID"/>
				</OperUID>
			</xsl:if>
			<SPName>
				<xsl:value-of select="$pSPName"/>
			</SPName>
		</func:result>
	</func:function>
	
	<xsl:template name="tLogMessage">
		<xsl:param name="pErrorCode"/>
		<xsl:param name="pErrorReason"/>
		<xsl:param name="pErrorPlace"/>
		<xsl:text>ErrorCode: </xsl:text>
		<xsl:value-of select="$pErrorCode"/>
		<xsl:text>. Place: </xsl:text>
		<xsl:value-of select="$pErrorPlace"/>
		<xsl:text>. Reason: </xsl:text>
		<xsl:value-of select="$pErrorReason" disable-output-escaping="yes"/>
	</xsl:template>
	
	<func:function name="XslFunc:setResult">
		<xsl:param name="pReason"/>
		<xsl:param name="pDescription"/>
		<func:result>
			<Result>
				<reason>
					<xsl:value-of select="$pReason"/>
				</reason>
				<description>
					<xsl:value-of select="$pDescription"/>
				</description>
			</Result>
		</func:result>
	</func:function>
	
	<func:function name="XslFunc:setError">
		<xsl:param name="pResult" select="''"/>
		<xsl:param name="pErrorPlace" select="'Error place undefined'"/>
		<xsl:param name="pTerminate" select="'yes'"/>
		<xsl:param name="pPriority" select="'error'"/>
		<xsl:param name="pErrorCode" select="'0xFFFFFFFF'"/>
		<xsl:param name="pFaultCode" select="'Client'"/>
		<func:result>
			<xsl:variable name="vFaultCode">
				<xsl:value-of select="$pFaultCode"/>
			</xsl:variable>
			<xsl:variable name="vErrorCode">
				<xsl:value-of select="$pErrorCode"/>
			</xsl:variable>
			<xsl:variable name="vErrorReason">
				<xsl:value-of select="$pResult//reason"/>, <xsl:value-of select="$pResult//description"/>
			</xsl:variable>
			<xsl:variable name="vErrorPlace">
				<xsl:value-of select="$pErrorPlace"/>
			</xsl:variable>
			<xsl:variable name="vPriority">
				<xsl:value-of select="$pPriority"/>
			</xsl:variable>
			<xsl:variable name="vTerminate">
				<xsl:choose>
					<xsl:when test="($pTerminate = 'false') or ($pTerminate = 'no')">
						<xsl:value-of select="'no'"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'yes'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="vLogMessage">
				<xsl:call-template name="tLogMessage">
					<xsl:with-param name="pErrorCode" select="$vErrorCode"/>
					<xsl:with-param name="pErrorReason" select="$vErrorReason"/>
					<xsl:with-param name="pErrorPlace" select="$vErrorPlace"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="vErrorMessage">
				<xsl:call-template name="tSOAP11Error">
					<xsl:with-param name="pFaultCode" select="$vFaultCode"/>
					<xsl:with-param name="pErrorReason" select="$vLogMessage"/>
				</xsl:call-template>
			</xsl:variable>
			<dp:set-variable name="'var://context/message/formatted-error-message'" value="$vErrorMessage"/>
			<dp:set-variable name="'var://context/message/error-message'" value="$vLogMessage"/>
			<xsl:value-of select="$vErrorMessage"/>
			<xsl:choose>
				<xsl:when test="$vTerminate = 'yes'">
					<xsl:message dp:type="{$Config:LogCategory}" dp:priority="{$vPriority}" terminate="yes">
						<xsl:copy-of select="$vLogMessage"/>
					</xsl:message>
					<dp:reject>
						<xsl:copy-of select="$vLogMessage"/>
					</dp:reject>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message dp:type="{$Config:LogCategory}" dp:priority="{$vPriority}" terminate="no">
						<xsl:copy-of select="$vLogMessage"/>
					</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</func:result>
	</func:function>
	
	<xsl:template name="tSOAP11Error">
		<xsl:param name="pFaultCode"/>
		<xsl:param name="pErrorReason"/>
		<soap:Envelope>
			<soap:Body>
				<soap:Fault>
					<faultcode>
						<xsl:value-of select="concat('soap:', $pFaultCode)"/>
					</faultcode>
					<faultstring>
						<xsl:value-of select="$pErrorReason" disable-output-escaping="yes"/>
					</faultstring>
				</soap:Fault>
			</soap:Body>
		</soap:Envelope>
	</xsl:template>
	
<!-- Функция возвращает локальное время с милисекундами и с локальной временной зоной-->
	<func:function name="XslFunc:GetTimestamp_ms">
		<xsl:variable name="timestamp" select="date:date-time()"/>
		<!-- Получим милисекунду из функции, которая возвращает период в милисекундах с 1 января 1970 года -->
		<xsl:variable name="ms" select="substring(dp:time-value(),11,3)"/>
		<func:result>
			<xsl:value-of select="concat(substring-before($timestamp,'+'),'.',$ms,'+',substring-after($timestamp,'+'))"/>
		</func:result>
	</func:function>
	<!-- Создаем сообщение для логирования в таблицу EVENTLOG-->
	<xsl:template name="XslFunc:CreateLogMessage">
		<xsl:param name="peventsource" select="''"/>
		<xsl:param name="peventreceiver" select="''"/>
		<xsl:param name="poperation" select="'UNKNOWN'"/>
		<xsl:param name="psourceq" select="'UNKNOWN'"/>
		<xsl:param name="psourceqm" select="'UNKNOWN'"/>
		<xsl:param name="ptargetq" select="'UNKNOWN'"/>
		<xsl:param name="ptargetqm" select="'UNKNOWN'"/>
		<xsl:param name="preplyq" select="'UNKNOWN'"/>
		<xsl:param name="preplyqm" select="'UNKNOWN'"/>
		<xsl:param name="pprocstatus" select="'UNKNOWN'"/>
		<xsl:param name="perrortext" select="''"/>
		<xsl:param name="peventmsg" select="' '"/>
		<xsl:param name="prquid"/>
		<esberrns:Event>
			<esberrns:EventDate>
				<xsl:value-of select="XslFunc:GetTimestamp_ms()"/>
			</esberrns:EventDate>
			<esberrns:EventSource>
				<xsl:value-of select="$peventsource"/>
			</esberrns:EventSource>
			<esberrns:EventReciever>
				<xsl:value-of select="$peventreceiver"/>
			</esberrns:EventReciever>
			<esberrns:Operation>
				<xsl:value-of select="$poperation" disable-output-escaping="yes"/>
			</esberrns:Operation>
			<esberrns:SourceQueue>
				<xsl:value-of select="$psourceq"/>
			</esberrns:SourceQueue>
			<esberrns:SourceQM>
				<xsl:value-of select="$psourceqm"/>
			</esberrns:SourceQM>
			<esberrns:TargetQueue>
				<xsl:value-of select="$ptargetq"/>
			</esberrns:TargetQueue>
			<esberrns:TargetQM>
				<xsl:value-of select="$ptargetqm"/>
			</esberrns:TargetQM>
			<esberrns:ReplyQueue>
				<xsl:value-of select="$preplyq"/>
			</esberrns:ReplyQueue>
			<esberrns:ReplyQM>
				<xsl:value-of select="$preplyqm"/>
			</esberrns:ReplyQM>
			<esberrns:ProcStatus>
				<xsl:value-of select="$pprocstatus"/>
			</esberrns:ProcStatus>
			<esberrns:ErrorText>
				<xsl:value-of select="$perrortext"/>
			</esberrns:ErrorText>
			<esberrns:EventMsg>
				<xsl:value-of select="$peventmsg"/>
			</esberrns:EventMsg>
			<esberrns:RqUID>
				<xsl:value-of select="$prquid"/>
			</esberrns:RqUID>
		</esberrns:Event>
	</xsl:template>
	<!-- Создаем RFH-заголовок для логирования в таблицу EVENTLOG-->
	<xsl:template name="XslFunc:CreateMessageProperties">
		<xsl:param name="peventsource" select="''"/>
		<xsl:param name="peventreceiver" select="''"/>
		<xsl:param name="poperation" select="'UNKNOWN'"/>
		<xsl:param name="psourceq" select="'UNKNOWN'"/>
		<xsl:param name="psourceqm" select="'UNKNOWN'"/>
		<xsl:param name="ptargetq" select="'UNKNOWN'"/>
		<xsl:param name="ptargetqm" select="'UNKNOWN'"/>
		<xsl:param name="preplyq" select="'UNKNOWN'"/>
		<xsl:param name="preplyqm" select="'UNKNOWN'"/>
		<xsl:param name="pprocstatus" select="'UNKNOWN'"/>
		<xsl:param name="perrortext" select="''"/>
		<xsl:param name="poperationname" select="'UNKNOWN'"/>
		<xsl:param name="prquid"/>
		<MsgProps>
			<EventDate>
				<xsl:value-of select="XslFunc:GetTimestamp_ms()"/>
			</EventDate>
<!--			<EventDate>
				<xsl:choose>
				<xsl:when test="string-length($peventdate)">
					<xsl:copy-of select="$peventdate"/>						
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="XslFunc:GetTimestamp_ms()"/>					
					</xsl:otherwise>
				</xsl:choose>				
			</EventDate>-->
			<EventSource>
				<xsl:value-of select="$peventsource"/>
			</EventSource>
			<EventReciever>
				<xsl:value-of select="$peventreceiver"/>
			</EventReciever>
			<Operation>
				<xsl:value-of select="$poperation" disable-output-escaping="yes"/>
			</Operation>
			<SourceQueue>
				<xsl:value-of select="$psourceq"/>
			</SourceQueue>
			<SourceQM>
				<xsl:value-of select="$psourceqm"/>
			</SourceQM>
			<TargetQueue>
				<xsl:value-of select="$ptargetq"/>
			</TargetQueue>
			<TargetQM>
				<xsl:value-of select="$ptargetqm"/>
			</TargetQM>
			<ReplyQueue>
				<xsl:value-of select="$preplyq"/>
			</ReplyQueue>
			<ReplyQM>
				<xsl:value-of select="$preplyqm"/>
			</ReplyQM>
			<ProcStatus>
				<xsl:value-of select="$pprocstatus"/>
			</ProcStatus>
			<ErrorText>
				<xsl:value-of select="$perrortext"/>
			</ErrorText>
			<RqUID>
				<xsl:value-of select="$prquid"/>
			</RqUID>
			<OperationName>
				<xsl:value-of select="$poperationname"/>
			</OperationName>
		</MsgProps>
	</xsl:template>
	<!-- Шаблон для отправки сообщения о событии в очередь сообщений -->
	<xsl:template name="XslFunc:SendLogMessage">
		<xsl:param name="peventsource"/>
		<xsl:param name="peventreceiver"/>
		<xsl:param name="poperation"/>
		<xsl:param name="psourceq" select="'UNKNOWN'"/>
		<xsl:param name="psourceqm" select="'UNKNOWN'"/>
		<xsl:param name="ptargetq" select="'UNKNOWN'"/>
		<xsl:param name="ptargetqm" select="'UNKNOWN'"/>
		<xsl:param name="preplyq" select="'UNKNOWN'"/>
		<xsl:param name="preplyqm" select="'UNKNOWN'"/>
		<xsl:param name="pprocstatus"/>
		<xsl:param name="perrortext"/>
		<xsl:param name="peventmsg"/>
		<xsl:param name="prquid"/>
		<xsl:param name="p_QMObject" select="$Config:MQConn"/>
		<xsl:param name="p_DestinationQ" select="$Config:QForError"/>
		<xsl:variable name="vEventLog">
			<xsl:call-template name="XslFunc:CreateLogMessage">
				<xsl:with-param name="peventsource" select="$peventsource"/>
				<xsl:with-param name="peventreceiver" select="$peventreceiver"/>
				<xsl:with-param name="poperation" select="$poperation"/>
				<xsl:with-param name="psourceq" select="$psourceq"/>
				<xsl:with-param name="psourceqm" select="$psourceqm"/>
				<xsl:with-param name="ptargetq" select="$ptargetq"/>
				<xsl:with-param name="ptargetqm" select="$ptargetqm"/>
				<xsl:with-param name="preplyq" select="$preplyq"/>
				<xsl:with-param name="preplyqm" select="$preplyqm"/>
				<xsl:with-param name="pprocstatus" select="$pprocstatus"/>
				<xsl:with-param name="perrortext" select="$perrortext"/>
				<xsl:with-param name="peventmsg" select="$peventmsg"/>
				<xsl:with-param name="prquid" select="$prquid"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="vSerEventLog">
			<dp:serialize select="$vEventLog" omit-xml-decl="no"/>
		</xsl:variable>
		<!-- Отправляем сообщение в очередь для логирования вне транзакции-->
		<xsl:variable name="vSendEventToQ">
			<xsl:call-template name="mqFunc:SendMessageIntoMQ">
				<xsl:with-param name="pOutMessage">
					<xsl:copy-of select="$vSerEventLog"/>
				</xsl:with-param>
				<xsl:with-param name="p_QMObject">
					<xsl:value-of select="$p_QMObject"/>
				</xsl:with-param>
				<xsl:with-param name="p_DestinationQ">
					<xsl:value-of select="$p_DestinationQ"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="vLogMes">
			<xsl:if test="not($vSendEventToQ/Reply/ReplyCode=0)">
				<xsl:call-template name="XslFunc:LogErrorMessage">
					<xsl:with-param name="pErrorMessage">
						<xsl:copy-of select="$vSendEventToQ"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>
	</xsl:template>
	
	<xsl:template name="XslFunc:SendLogMsgSBT">
		<xsl:param name="peventsource"/>
		<xsl:param name="peventreceiver"/>
		<xsl:param name="poperation"/>
		<xsl:param name="psourceq" select="'UNKNOWN'"/>
		<xsl:param name="psourceqm" select="'UNKNOWN'"/>
		<xsl:param name="ptargetq" select="'UNKNOWN'"/>
		<xsl:param name="ptargetqm" select="'UNKNOWN'"/>
		<xsl:param name="preplyq" select="'UNKNOWN'"/>
		<xsl:param name="preplyqm" select="'UNKNOWN'"/>
		<xsl:param name="pprocstatus"/>
		<xsl:param name="perrortext"/>
		<xsl:param name="peventmsg"/>
		<xsl:param name="prquid"/>
		<xsl:param name="p_QMObject" select="$Config:MQConn"/>
		<xsl:param name="p_DestinationQ" select="$Config:QModForLog"/>
		<xsl:param name="p_Operationname" select="'UNKNOWN'"/>
		<xsl:param name="peventdate" select="''"/>
		<xsl:variable name="vMesProps">
			<xsl:call-template name="XslFunc:CreateMessageProperties">
				<xsl:with-param name="peventsource" select="$peventsource"/>
				<xsl:with-param name="peventreceiver" select="$peventreceiver"/>
				<xsl:with-param name="poperation" select="$poperation"/>
				<xsl:with-param name="psourceq" select="$psourceq"/>
				<xsl:with-param name="psourceqm" select="$psourceqm"/>
				<xsl:with-param name="ptargetq" select="$ptargetq"/>
				<xsl:with-param name="ptargetqm" select="$ptargetqm"/>
				<xsl:with-param name="preplyq" select="$preplyq"/>
				<xsl:with-param name="preplyqm" select="$preplyqm"/>
				<xsl:with-param name="pprocstatus" select="$pprocstatus"/>
				<xsl:with-param name="perrortext" select="$perrortext"/>
				<xsl:with-param name="prquid" select="$prquid"/>
				<xsl:with-param name="poperationname" select="$p_Operationname"/>
				
<!--				<xsl:with-param name="peventdate" select="$peventdate"/>	-->
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:message terminate="no" dp:type="all" dp:priority="notice">SendLogMsgSBT</xsl:message>
		<xsl:message terminate="no" dp:type="all" dp:priority="notice">vMesProps:  <xsl:copy-of select="$vMesProps" /></xsl:message>
	
	

		<xsl:variable name="vSendEventToQ">
			<xsl:call-template name="mqFunc:LogIntoMQ">
				<xsl:with-param name="pOutMessage">
					<xsl:copy-of select="$peventmsg"/>
				</xsl:with-param>
				<xsl:with-param name="p_QMObject">
					<xsl:value-of select="$p_QMObject"/>
				</xsl:with-param>
				<xsl:with-param name="p_DestinationQ">
					<xsl:value-of select="$p_DestinationQ"/>
				</xsl:with-param>
				<xsl:with-param name="pusrFolder">
					<xsl:copy-of select="$vMesProps"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="vLogMes">
			<xsl:if test="not($vSendEventToQ/Reply/ReplyCode=0)">
				<xsl:call-template name="XslFunc:LogErrorMessage">
					<xsl:with-param name="pErrorMessage">
						<xsl:copy-of select="$vSendEventToQ"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>
	</xsl:template>
	

<!-- отправка расширенного лога в очередь -->

<xsl:template name="XslFunc:SendExtLog">
<!--	<xsl:param name="prquid"/>			
	<xsl:param name="pRqRcvTime"/>			
	<xsl:param name="pESBRqTime"/>		
	<xsl:param name="pESBRsTime"/>		
	<xsl:param name="pRsSentTime"/>											
	<xsl:param name="ExtLogOperationName"/>		
	<xsl:param name="ExtLogSourceSystem"/>					


-->
	<xsl:param name="pprocstatus" select="'OK_STATUS'"/>
	<xsl:param name="p_QMObject"/>
	<xsl:param name="p_DestinationQ"/>
	<xsl:param name="p_MesProps"/>

	

	
	<!-- заголовки MQ для расширенного логирования-->
	<!--
	<xsl:variable name="vMesProps">
		<xsl:if test="dp:variable('var://context/input/RqUID')">
			<ExtLogRqUID>
				<xsl:value-of select="dp:variable('var://context/input/RqUID')" />
			</ExtLogRqUID>
		</xsl:if>
		<xsl:if test="dp:variable('var://context/input/reqRcvTime')">
			<ExtLogRqTm>
				<xsl:copy-of select="dp:variable($dpconfig:eventdate)"/>
			</ExtLogRqTm>
		</xsl:if>
		<xsl:if test="dp:variable('var://context/input/sourceSystem')">
			<ExtLogSourceSystem>
				<xsl:value-of select="dp:variable('var://context/input/sourceSystem')" />
			</ExtLogSourceSystem>
		</xsl:if>
		<xsl:if test="dp:variable('var://context/input/OutputMesType')">
			<ExtLogOperationName>
				<xsl:value-of select="dp:variable('var://context/input/OutputMesType')" />
			</ExtLogOperationName>
		</xsl:if>		
	</xsl:variable>
-->		
	
	<!-- пустое, чтоб не было ошибок -->		
	<xsl:variable name="pOutMessage"></xsl:variable>
	
	<xsl:variable name="vSendEventToQ">
		<xsl:call-template name="mqFunc:LogIntoMQ">
			<xsl:with-param name="pOutMessage">
				<xsl:copy-of select="$pOutMessage"/>
			</xsl:with-param>
			<xsl:with-param name="p_QMObject">
				<xsl:value-of select="$p_QMObject"/>
			</xsl:with-param>
			<xsl:with-param name="p_DestinationQ">
				<xsl:value-of select="$p_DestinationQ"/>
			</xsl:with-param>
			<xsl:with-param name="pusrFolder">
				<xsl:copy-of select="$p_MesProps"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>

	<xsl:variable name="vLogMes">
		<xsl:if test="not($vSendEventToQ/Reply/ReplyCode=0)">
			<xsl:call-template name="XslFunc:LogErrorMessage">
				<xsl:with-param name="pErrorMessage">
					<xsl:copy-of select="$vSendEventToQ"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:variable>
</xsl:template>

<!-- Шаблон для отправки сообщения о событии в очередь сообщений -->
	<xsl:template name="XslFunc:SendLogMessageMod">
		<xsl:param name="peventsource"/>
		<xsl:param name="peventreceiver"/>
		<xsl:param name="poperation"/>
		<xsl:param name="psourceq" select="'UNKNOWN'"/>
		<xsl:param name="psourceqm" select="'UNKNOWN'"/>
		<xsl:param name="ptargetq" select="'UNKNOWN'"/>
		<xsl:param name="ptargetqm" select="'UNKNOWN'"/>
		<xsl:param name="preplyq" select="'UNKNOWN'"/>
		<xsl:param name="preplyqm" select="'UNKNOWN'"/>
		<xsl:param name="pprocstatus"/>
		<xsl:param name="perrortext"/>
		<xsl:param name="peventmsg"/>
		<xsl:param name="prquid"/>
		<xsl:param name="p_QMObject" select="$Config:MQConn"/>
		<xsl:param name="p_DestinationQ" select="$Config:QModForLog"/>
		<xsl:variable name="vMesProps">
			<xsl:call-template name="XslFunc:CreateMessageProperties">
				<xsl:with-param name="peventsource" select="$peventsource"/>
				<xsl:with-param name="peventreceiver" select="$peventreceiver"/>
				<xsl:with-param name="poperation" select="$poperation"/>
				<xsl:with-param name="psourceq" select="$psourceq"/>
				<xsl:with-param name="psourceqm" select="$psourceqm"/>
				<xsl:with-param name="ptargetq" select="$ptargetq"/>
				<xsl:with-param name="ptargetqm" select="$ptargetqm"/>
				<xsl:with-param name="preplyq" select="$preplyq"/>
				<xsl:with-param name="preplyqm" select="$preplyqm"/>
				<xsl:with-param name="pprocstatus" select="$pprocstatus"/>
				<xsl:with-param name="perrortext" select="$perrortext"/>
				<xsl:with-param name="prquid" select="$prquid"/>
			</xsl:call-template>
		</xsl:variable>
		<!-- Отправляем сообщение в очередь для логирования вне транзакции-->
		<xsl:variable name="vSendEventToQ">
			<xsl:call-template name="mqFunc:SendMessageIntoMQ">
				<xsl:with-param name="pOutMessage">
					<xsl:copy-of select="$peventmsg"/>
				</xsl:with-param>
				<xsl:with-param name="p_QMObject">
					<xsl:value-of select="$p_QMObject"/>
				</xsl:with-param>
				<xsl:with-param name="p_DestinationQ">
					<xsl:value-of select="$p_DestinationQ"/>
				</xsl:with-param>
				<xsl:with-param name="pusrFolder">
					<xsl:copy-of select="$vMesProps"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="vLogMes">
			<xsl:if test="not($vSendEventToQ/Reply/ReplyCode=0)">
				<xsl:call-template name="XslFunc:LogErrorMessage">
					<xsl:with-param name="pErrorMessage">
						<xsl:copy-of select="$vSendEventToQ"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>
	</xsl:template>
	<!--
	********************************
	* Put message to log
	********************************
	Format reply message is
	<Reply>
		<ReplyCode></ReplyCode>                - 0 - OK, else - error
		<ReplyDescription></ReplyDescription>
		<ReplyBody></ReplyBody>
			<Error>                            - there is if ReplyCode !=0
				<ErrorSystem></ErrorSystem>    - SV,MQ
				<ErrorType></ErrorType>        - 1 - business, 2 - network, 3 - system,4 - runtime
				<ErrorCode></ErrorCode>
				<ErrorDescription></ErrorDescription>
			</Error>
	</Reply>
	-->
	<xsl:template name="XslFunc:PutErrorMessage">
		<xsl:param name="pErrorCode"/>
		<xsl:param name="pErrorDescription"/>
		<xsl:message dp:priority="'error'">
			<Error>
				<ErrorCode>
					<xsl:value-of select="$pErrorCode"/>
				</ErrorCode>
				<ErrorDescription>
					<xsl:value-of select="$pErrorDescription"/>
				</ErrorDescription>
			</Error>
		</xsl:message>
	</xsl:template>
	
	<xsl:template name="XslFunc:LogErrorMessage">
		<xsl:param name="pErrorMessage"/>
		<xsl:param name="pPriority" select="'error'"/>
		<xsl:param name="pTerm" select="'no'"/>
		<xsl:variable name="vError">
			<Reply>
				<ReplyCode>
					<xsl:value-of select="$pErrorMessage/Reply/ReplyCode"/>
				</ReplyCode>
				<ReplyDescription>
					<xsl:value-of select="$pErrorMessage/Reply/ReplyDescription" disable-output-escaping="yes"/>
				</ReplyDescription>
				<ReplyBody>
					<xsl:value-of select="$pErrorMessage/Reply/ReplyBody" disable-output-escaping="yes"/>
				</ReplyBody>
				<Error>
					<ErrorSystem>
						<xsl:value-of select="$pErrorMessage//ErrorSystem"/>
					</ErrorSystem>
					<ErrorType>
						<xsl:value-of select="$pErrorMessage//ErrorType"/>
					</ErrorType>
					<ErrorCode>
						<xsl:value-of select="$pErrorMessage//ErrorCode"/>
					</ErrorCode>
					<ErrorDescription>
						<xsl:value-of select="$pErrorMessage//ErrorDescription" disable-output-escaping="yes"/>
					</ErrorDescription>
				</Error>
			</Reply>
		</xsl:variable>
		<xsl:variable name="vErrorMessage">
			<dp:serialize select="$vError" omit-xml-decl="yes"/>
		</xsl:variable>
		<xsl:message terminate="{$pTerm}" dp:type="{$Config:LogCategory}" dp:priority="{$pPriority}">
			<xsl:value-of select="$vErrorMessage" disable-output-escaping="yes"/>
		</xsl:message>
	</xsl:template>


	<xsl:template name="AddChar">
		<xsl:param name="inputstr"/>
		<xsl:param name="count" select="4"/>
		<xsl:param name="char" select="'0'"/>
		<xsl:param name="direction" select="'left'"/>
		<xsl:choose>
			<xsl:when test="not($count) or not($inputstr)"/>
			<xsl:when test="string-length($inputstr)=$count">
				<xsl:value-of select="$inputstr"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$direction = 'left' ">
						<xsl:call-template name="AddChar">
							<xsl:with-param name="inputstr" select="concat($char,$inputstr)"/>
							<xsl:with-param name="count" select="$count"/>
							<xsl:with-param name="char" select="$char"/>
							<xsl:with-param name="direction" select="$direction"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="AddChar">
							<xsl:with-param name="inputstr" select="concat($inputstr,$char)"/>
							<xsl:with-param name="count" select="$count"/>
							<xsl:with-param name="char" select="$char"/>
							<xsl:with-param name="direction" select="$direction"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<func:function name="XslFunc:CountDaysInMonth">
		<xsl:param name="year"/>
		<xsl:param name="month"/>
		<xsl:variable name="day">
			<xsl:choose>
				<xsl:when test="$month = 02 and not($year mod 4) and ($year mod 100 or not($year mod 400))">
					<xsl:value-of select="29"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring('312831303130313130313031', 2 * $month - 1, 2)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<func:result>
			<xsl:value-of select="$day"/>
		</func:result>
	</func:function>
	
	<func:function name="XslFunc:ConvertEndCardDate">
		<xsl:param name="date"/>
		<xsl:variable name="year" select="concat('20', substring($date,1,2))"/>
		<xsl:variable name="month" select="substring($date,3,2)"/>
		<xsl:variable name="day" select="XslFunc:CountDaysInMonth($year, $month)"/>
		<func:result>
			<xsl:value-of select="concat($year, '-', $month, '-', $day)"/>
		</func:result>
	</func:function>
	
	<func:function name="XslFunc:ConvertBonusId">
		<xsl:param name="bonusId"/>
		<func:result>
			<xsl:choose>
				<xsl:when test="$bonusId='A'">
					<xsl:value-of select="'AE'"/>
				</xsl:when>
				<xsl:when test="$bonusId='G'">
					<xsl:value-of select="'GM'"/>
				</xsl:when>
				<xsl:when test="$bonusId='Z'">
					<xsl:value-of select="'PG'"/>
				</xsl:when>
				<xsl:when test="$bonusId='O'">
					<xsl:value-of select="'OB'"/>
				</xsl:when>
				<xsl:when test="$bonusId='M'">
					<xsl:value-of select="'MT'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="''"/>
				</xsl:otherwise>
			</xsl:choose>
		</func:result>
	</func:function>
	
	<xsl:template name="CurrenciesISO2Name">
		<xsl:param name="iso"/>
		<xsl:variable name="currencies" select="document('local:///dict/currencies.xml')"></xsl:variable>
		<xsl:copy-of select="local-name($currencies/currencies/*[text()=$iso])"></xsl:copy-of>	
	</xsl:template>
	
	<xsl:template name="CurrenciesName2ISO">
		<xsl:param name="name"/>
		<xsl:variable name="currencies" select="document('local:///dict/currencies.xml')"></xsl:variable>
		<xsl:copy-of select="$currencies/currencies/*[local-name()=$name]"></xsl:copy-of>	
	</xsl:template>
	<!--шаблон для получения типа сообщения request|response|notification-->
	<func:function name="XslFunc:GetTypeOperation">
		<xsl:param name="pOperation"/>
		<xsl:param name="gatewayType" select="dp:variable('var://context/input/gatewayType')"/>
		
		<xsl:variable name="vOperationTypes" select="document(concat('local:///dict/', $gatewayType, '/', 'operations.xml'))"/>
		<func:result>
			<xsl:choose>
				<xsl:when test="count($vOperationTypes/operations/*[local-name()=$pOperation])>0"><xsl:value-of select="$vOperationTypes/operations/*[local-name()=$pOperation]"/></xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="XslFunc:ends-with(XslFunc:toUpperCase($pOperation),'NF')='true'">notification</xsl:when>
						<xsl:when test="XslFunc:ends-with(XslFunc:toUpperCase($pOperation),'RQ')='true'">request</xsl:when>
						<xsl:when test="XslFunc:ends-with(XslFunc:toUpperCase($pOperation),'RS')='true'">response</xsl:when>
						<xsl:otherwise>request</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</func:result>
	</func:function>
	<!--шаблон для получения ответного тега-->
	<func:function name="XslFunc:GetResponseName">
		<xsl:param name="pOperation"/>
		<xsl:param name="gatewayType" select="dp:variable('var://context/input/gatewayType')"/>
		
		<xsl:variable name="vOperationTypes" select="document(concat('local:///dict/', $gatewayType, '/', 'operations.xml'))"/>
		<func:result>
			<xsl:choose>
				<xsl:when test="count($vOperationTypes/operations/*[local-name()=$pOperation])"><xsl:value-of select="$vOperationTypes/operations/*[local-name()=$pOperation]/@responseTagName"/></xsl:when>
				<xsl:when test="not(normalize-space(substring-before($pOperation,'Rq'))='')"><xsl:value-of select="concat(substring-before($pOperation,'Rq'),'Rs',substring-after($pOperation,'Rq'))"/></xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$pOperation"/>
				</xsl:otherwise>
			</xsl:choose>
		</func:result>
	</func:function>
	<!--шаблон для формирования ошибки-->
	<xsl:template name="XslFunc:MakeError">
		<xsl:param name="pRqUID"/>
		<xsl:param name="pRqTm"/>
		<xsl:param name="pErrCode"/>
		<xsl:param name="pErrMess"/>
		<xsl:param name="pServErrMess"/>
		<xsl:param name="pNode"/>
		<xsl:param name="pMT" select="'http://sberbank.ru/dem/moneytransfers/moneytransferAggregates/15'"/>
		<xsl:param name="pCA" select="'http://sberbank.ru/dem/commonAggregates/15'"/>
		<xsl:param name="pWithSeverity" select="'true'"/>
		<xsl:variable name="vErrCode">
			<xsl:choose>
				<xsl:when test="boolean($pErrCode) and not(normalize-space($pErrCode)='' )">
					<xsl:value-of select="$pErrCode"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$Config:SystemError"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="vRootTagName" select="XslFunc:GetResponseName(local-name($pNode/*[1]))"/>
		<!--<xsl:message terminate="no" dp:type="all" dp:priority="error"><xsl:value-of select="$pMT"/> milliseconds</xsl:message>--> 
		<xsl:element name="{$vRootTagName}" namespace="{namespace-uri($pNode/*[1])}">
			<xsl:element name="Header" namespace="{$pMT}">
				<xsl:element name="RqUID" namespace="{$pMT}"><xsl:value-of select="$pRqUID"/></xsl:element>
				<xsl:element name="RqTm" namespace="{$pMT}"><xsl:value-of select="$pRqTm"/></xsl:element>
			</xsl:element>
			<!--<xsl:element name="Status" namespace="{$pMT}">
				<xsl:choose>
					<xsl:when test="contains($vErrCode,'x')"><xsl:element name="StatusCode" namespace="{$pCA}"><xsl:value-of select="concat('-',substring-after($vErrCode,'x'))"/></xsl:element></xsl:when>
					<xsl:otherwise><xsl:element name="StatusCode" namespace="{$pCA}"><xsl:value-of select="$vErrCode"/></xsl:element></xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$pWithSeverity = 'true'">
					<xsl:element name="Severity" namespace="{$pCA}">Error</xsl:element>
				</xsl:if>
				<xsl:if test="not(normalize-space($pErrMess)='')">
					<xsl:element name="StatusDesc" namespace="{$pCA}"><xsl:value-of select="$pErrMess"/></xsl:element>
				</xsl:if>
				<xsl:if test="boolean($pServErrMess)">		
					<xsl:element name="ServerStatusDesc" namespace="{$pCA}"><xsl:value-of select="$pServErrMess"/></xsl:element>
				</xsl:if>
				</xsl:element>-->
			<xsl:element name="Status" namespace="{$pMT}">
				<xsl:element name="StatusCode" namespace="{$pMT}">2</xsl:element>
				<xsl:element name="StatusDescription" namespace="{$pMT}">Error on the external Datapower</xsl:element>
				<xsl:element name="AdditionalStatus" namespace="{$pMT}">
					<xsl:element name="StatusCode" namespace="{$pMT}"><xsl:value-of select="$vErrCode"/></xsl:element>
					<xsl:if test="$pWithSeverity = 'true'">
						<xsl:element name="Severity" namespace="{$pMT}">Error</xsl:element>
					</xsl:if>
					<xsl:element name="StatusDesc" namespace="{$pMT}"><xsl:value-of select="dp:variable('var://service/error-message')"/></xsl:element>
				</xsl:element>
			</xsl:element>		
		</xsl:element>
	</xsl:template>
	<!--шаблон добавления элемента в дерево после указанного элемента-->
	<xsl:template name="XslFunc:AddElementLastToPath">
		<xsl:param name="pNode"/>
		<xsl:param name="pPath" select="''"/>
		<xsl:param name="pElement"/>
		<xsl:param name="pCurPath" select="''"/>
		<xsl:if test="$pCurPath=$pPath"><xsl:copy-of select="$pElement"/></xsl:if>
		<xsl:for-each select="$pNode/*">
			<xsl:element name="{local-name(.)}">
			<xsl:for-each select="./@*">
				<xsl:attribute name="{local-name(.)}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each>
				<xsl:call-template name="XslFunc:AddElementLastToPath">
					<xsl:with-param name="pNode" select="."/>
					<xsl:with-param name="pPath" select="$pPath"/>
					<xsl:with-param name="pElement" select="$pElement"/>
					<xsl:with-param name="pCurPath" select="concat($pCurPath,'/',local-name(.))"/>
				</xsl:call-template>
			<xsl:value-of select="./text()"/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<!--замена значения тега в документе-->
	<xsl:template name="XslFunc:Replace">
		<xsl:param name="vNode"/>
		<xsl:param name="vReplaceValue" select="''"/>
		<xsl:param name="vTagName" select="''"/>
		<xsl:if test="not($vNode='')">
			<xsl:variable name="pValue">
				<xsl:choose>
					<xsl:when test="local-name($vNode)=$vTagName">
						<xsl:value-of select="$vReplaceValue"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$vNode/text()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:element name="{local-name($vNode)}" namespace="{namespace-uri($vNode)}">		
				<xsl:for-each select="$vNode/@*">
					<xsl:attribute name="{local-name(.)}" namespace="{namespace-uri(.)}"><xsl:value-of select="."/></xsl:attribute>
				</xsl:for-each>		
				<xsl:for-each select="$vNode/*">
					<xsl:call-template name="XslFunc:Replace">
						<xsl:with-param name="vNode" select="."/>
						<xsl:with-param name="vReplaceValue" select="$vReplaceValue"/>
						<xsl:with-param name="vTagName" select="$vTagName"/>
					</xsl:call-template>
				</xsl:for-each>				
				<xsl:value-of select="$pValue"/>				
			</xsl:element>
		</xsl:if>
	</xsl:template>

	
	<!--шаблон для получения дефолтной версии сервиса-->
	<func:function name="XslFunc:getVersion">
		<xsl:param name="pOperation"/>
		
		<xsl:variable name="defaultsPath" select="concat('local:///cfg/', dp:variable('var://context/input/gatewayType'), '/', 'defaults.xml')"></xsl:variable>

		<xsl:variable name="vDefaults" select="document($defaultsPath)"/>
		<func:result>
			<xsl:choose>
				<xsl:when test="count($vDefaults/defaults/*[local-name()=$pOperation])"><xsl:value-of select="$vDefaults/defaults/*[local-name()=$pOperation]"/></xsl:when>
				<xsl:otherwise>1.0</xsl:otherwise>
			</xsl:choose>
		</func:result>
	</func:function>	
	
	<func:function name="XslFunc:ends-with">
		<xsl:param name="pString"/>
		<xsl:param name="pSubString"/>
		<func:result>
			<xsl:value-of select="$pSubString = substring($pString, string-length($pString) - string-length($pSubString) + 1)"/>
		</func:result>
	</func:function>
	
	<func:function name="XslFunc:toUpperCase">
		<xsl:param name="pString"/>
		<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
		<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
		<func:result>
			<xsl:value-of select="translate($pString, $smallcase, $uppercase)"/>		
		</func:result>
	</func:function>
	
	<func:function name="XslFunc:toLowerCase">
		<xsl:param name="pString"/>
		<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
		<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
		<func:result>
			<xsl:value-of select="translate($pString, $uppercase, $smallcase)"/>		
		</func:result>
	</func:function>
	
	<!--Для корректной обработки ошибок от криптосервиса необходимо положить -->
	<func:function name="XslFunc:getStatusFromContext">
		<xsl:param name="pOperation"/>
	
		<xsl:variable name="diag" select="document($Config:diag)"></xsl:variable>	
		<xsl:variable name="vErrorString" select="dp:variable('var://service/error-message')"/>
		<xsl:variable name="vErrorCode" select="dp:variable('var://service/error-code')"/>
		<xsl:variable name="vErrorSubCode" select="dp:variable('var://service/error-subcode')"/>
		<xsl:variable name="filterHit" select="dp:variable('var://context/__SQL_INJECTION_FILTER__/hit')"/>
		<xsl:variable name="vBackSideTimeout"><xsl:value-of select="dp:variable('var://service/mpgw/backend-timeout')"/></xsl:variable>
		<xsl:variable name="vTimeElapsed"><xsl:value-of select="dp:variable('var://service/time-response-complete')"/></xsl:variable>
		<xsl:variable name="vMsgType" select="XslFunc:GetTypeOperation($pOperation)"/>
		<xsl:message>
		vErrorString <xsl:value-of select="$vErrorString"/>;
vErrorCode <xsl:value-of select="$vErrorCode"/>;
vErrorSubCode <xsl:value-of select="$vErrorSubCode"/>;
filterHit <xsl:value-of select="$filterHit"/>;
 vBackSideTimeout <xsl:value-of select="$vBackSideTimeout"/>;
vTimeElapsed <xsl:value-of select="$vTimeElapsed"/>;
</xsl:message>
		
		<xsl:variable name="vStatus">
			<xsl:choose>
				<xsl:when test="$vErrorSubCode='0x01d30003' and $vErrorCode='0x00230001' and $vMsgType='request'">	<!-- аОбаИаБаКаА аВаАаЛаИаДаАбаИаИ -->			
					<xsl:copy-of select="$diag/diag/status[@name='requestValidationError']"/>
				</xsl:when>
				<xsl:when test="$vErrorSubCode='0x01d30003' and $vErrorCode='0x00230001' and $vMsgType='response'">	<!-- аОбаИаБаКаА аВаАаЛаИаДаАбаИаИ -->			
					<xsl:copy-of select="$diag/diag/status[@name='responseValidationError']"/>
				</xsl:when>		
				<xsl:when test="$vErrorSubCode='0x01d30003' and $vErrorCode='0x00230001'">	<!-- аОбаИаБаКаА аВаАаЛаИаДаАбаИаИ -->			
					<xsl:copy-of select="$diag/diag/status[@name='generalValidationError']"/>
				</xsl:when>		
				<xsl:when test="$vErrorString='Message contains restricted content' and $filterHit='1' ">		<!-- SQL аИаНбаЕаКбаИб -->
					<xsl:copy-of select="$diag/diag/status[@name='SQLInjectionError']"/>
				</xsl:when>	
				<xsl:when test="$vErrorString='Bad Body'">		<!--  аЁаОаВбаЕаМ аПаЛаОбаОаЙ аОбаВаЕб -->		
					<xsl:copy-of select="$diag/diag/status[@name='incorrectExternalResponseError']"/>
				</xsl:when>	
				<xsl:when test="$vErrorCode='0x01130006' and not($vBackSideTimeout * 1000 &lt; $vTimeElapsed)">
					<xsl:copy-of select="$diag/diag/status[@name='HTTPErrorBeforeTOError']"/>
				</xsl:when>
				<xsl:when test="$vErrorCode='0x01130006' and ($vBackSideTimeout * 1000 &lt; $vTimeElapsed)">
					<xsl:copy-of select="$diag/diag/status[@name='externalServiceTimeout']"/>					
				</xsl:when>
				<xsl:when test="$vErrorString='Dynamic backend host not specified'">
					<xsl:copy-of select="$diag/diag/status[@name='noURLProvidedError']"/>					
				</xsl:when>	<!-- аНаЕ аЗаАаДаАаН аБбаКаЕаНаДб ббаЛ -->	
				<xsl:when test="$vErrorCode='0x00d30003' and $vErrorSubCode='0x01d30005'"> <!--ICAP virus alarm-->
					<xsl:copy-of select="$diag/diag/status[@name='virusError']"/>					
				</xsl:when>
				<xsl:when test="contains($vErrorString, 'Attachment has invalid format')"> <!--Invalid attachment-->
					<xsl:copy-of select="$diag/diag/status[@name='attachmentFormatError']"/>					
				</xsl:when>
				<xsl:when test="contains($vErrorString, 'Attachment not found')"> <!--Invalid attachment-->
					<xsl:copy-of select="$diag/diag/status[@name='emptyAttachmentError']"/>					
				</xsl:when>
				<xsl:when test="starts-with($vErrorString,'HTTP response code')">
					<xsl:copy-of select="$diag/diag/status[@name='HTTPErrorFromExternal']"/>					
				</xsl:when>
				<xsl:when test="starts-with($vErrorString, 'MQ Error')">		<!--  аЁаИббаЕаМаНаАб аОбаИаБаКаА аПбаИ баАаБаОбаЕ б аМаЕаНаЕаДаЖаЕбаОаМ аОбаЕбаЕаДаЕаЙ. -->		
					<xsl:copy-of select="$diag/diag/status[@name='generalMQError']"/>					
				</xsl:when>			
				<xsl:when test="contains($vErrorString, 'route not found')">		<!--  ааЕ аНаАаЙаДаЕаН аМаАббббб. -->		
					<xsl:copy-of select="$diag/diag/status[@name='routeNotFound']"/>					
				</xsl:when>			
				<xsl:otherwise>
					<xsl:copy-of select="$diag/diag/status[@name='generalError']"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<func:result>
			<xsl:copy-of select="$vStatus"/>
		</func:result>
	</func:function>
</xsl:stylesheet>