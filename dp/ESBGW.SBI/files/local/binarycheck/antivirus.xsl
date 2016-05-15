<?xml version="1.0"?>
<!--
  Licensed Materials - Property of IBM
  IBM WebSphere DataPower Appliances
  Copyright IBM Corporation 2007. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure
  restricted by GSA ADP Schedule Contract with IBM Corp.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dp="http://www.datapower.com/extensions"
                xmlns:dpconfig="http://www.datapower.com/param/config"
                xmlns:dpfunc="http://www.datapower.com/extensions/functions"

                xmlns:func="http://exslt.org/functions"
                xmlns:dyn="http://exslt.org/dynamic"
                xmlns:regexp="http://exslt.org/regular-expressions"
                xmlns:exsl="http://exslt.org/common"
                xmlns:set="http://exslt.org/sets"

                extension-element-prefixes="dp dyn func regexp exsl set"
                exclude-result-prefixes="dp dpconfig dyn dpfunc func regexp exsl set"
                >

<xsl:output method="xml" />

    <xsl:include href="store:///dp/msgcat/xslt.xml.xsl" dp:ignore-multiple="yes"/>

    <dp:summary xmlns="">
        <operation>antivirus</operation>
        <description>Virus Scanning</description>
    </dp:summary>

    <xsl:variable name="eol" select="'&#13;&#10;'" />

    <!-- AV Processing Mode -->
    <xsl:param name="dpconfig:AntiVirusProcessingMode" select="'entire-message'" />
    <dp:param name="dpconfig:AntiVirusProcessingMode" type="AntiVirusProcessingModeType" xmlns="">
        <display>Anti-Virus Scan Type</display>
        <description>Please enter the remote address of the Virus Scanner.</description>

        <tab-override>basic</tab-override>
        <refresh-on-change>true</refresh-on-change>
        <no-save-checkbox>true</no-save-checkbox>
        <format>radio</format>

        <required-when><condition evaluation="logical-true" /></required-when>
        <default>entire-message</default>

        <type name="AntiVirusProcessingModeType" base="enumeration" displayOrder="fixed">
            <value-list>
                <value name="entire-message">
                    <display>Scan Entire Message</display>
                    <description>Scan both the message body and attachments.</description>
                </value>
                <value name="attachments">
                    <display>Scan All Attachments</display>
                    <description>Scan all message attachments.</description>
                </value>
                <value name="attachment-content-type">
                    <display>Scan Attachments by Content Type</display>
                    <description>Scan every attachment with a specified content type.</description>
                </value>
                <value name="attachment-uri">
                    <display>Scan Attachments by URI</display>
                    <description>Scan attachments with a specified uri.</description>
                </value>
                <value name="xpath">
                    <display>Scan by XPath Expression</display>
                    <description>Scan a partial message, selected by XPath expression.</description>
                </value>
            </value-list>
        </type>
    </dp:param>

    <!-- XPath Selection -->
    <xsl:param name="dpconfig:AntiVirusXPathSelection" select="'/'" />
    <dp:param name="dpconfig:AntiVirusXPathSelection" type="dmXPathExpr" xmlns="">
        <display>XPath Expression</display>
        <description>XPath expression defining the partial message to evaluate.</description>

        <tab-override>basic</tab-override>
        <no-save-checkbox>true</no-save-checkbox>

        <required-when>
            <condition evaluation="property-equals">
                <parameter-name>dpconfig:AntiVirusProcessingMode</parameter-name>
                <value>xpath</value>
            </condition>
        </required-when>
        <ignored-when><condition evaluation="logical-true" /></ignored-when>
    </dp:param>

    <!-- Attachment Content-Type Selection -->
    <xsl:param name="dpconfig:AntiVirusAttachmentContentType" select="'.*'" />
    <dp:param name="dpconfig:AntiVirusAttachmentContentType" type="dmPCRE" xmlns="">
        <display>Attachment Content-Type</display>
        <description>PCRE matching attachment content types to scan.</description>

        <tab-override>basic</tab-override>
        <no-save-checkbox>true</no-save-checkbox>

        <required-when>
            <condition evaluation="property-equals">
                <parameter-name>dpconfig:AntiVirusProcessingMode</parameter-name>
                <value>attachment-content-type</value>
            </condition>
        </required-when>
        <ignored-when><condition evaluation="logical-true" /></ignored-when>
    </dp:param>

    <!-- URI Selection -->
    <xsl:param name="dpconfig:AntiVirusAttachmentURI" select="'.*'" />
    <dp:param name="dpconfig:AntiVirusAttachmentURI" type="dmPCRE" xmlns="">
        <display>Attachment URI PCRE</display>
        <description>URI of attachments to scan.</description>

        <tab-override>basic</tab-override>
        <no-save-checkbox>true</no-save-checkbox>

        <required-when>
            <condition evaluation="property-equals">
                <parameter-name>dpconfig:AntiVirusProcessingMode</parameter-name>
                <value>attachment-uri</value>
            </condition>
        </required-when>
        <ignored-when><condition evaluation="logical-true" /></ignored-when>
    </dp:param>



    <!-- ICAP Host Type -->
    <xsl:param name="dpconfig:ICAPHostType" select="'clam'" />
    <dp:param name="dpconfig:ICAPHostType" type="ICAPHostType" xmlns="">
        <display>ICAP Host Type</display>
        <description>Please enter the remote address of the Virus Scanner.</description>

        <tab-override>basic</tab-override>
        <refresh-on-change>true</refresh-on-change>
        <no-save-checkbox>true</no-save-checkbox>
        <format>radio</format>

        <required-when><condition evaluation="logical-true" /></required-when>


        <type name="ICAPHostType" base="enumeration" displayOrder="fixed">
            <value-list>
                <value name="clam">
                    <display>Clam</display>
                    <description>Clam AV ICAP Server</description>
                </value>
                <value name="symantec">
                    <display>Symantec</display>
                    <description>Symantec Scan Engine ICAP</description>
                </value>
                <value name="trend">
                    <display>Trend Micro</display>
                    <description>Trend Micro InterScan WebProtect for ICAP</description>
                </value>
                <value name="webwasher">
                    <display>Webwasher</display>
                    <description>Webwasher ICAP Server</description>
                </value>
                <value name="custom">
                    <display>Custom</display>
                    <description>Custom ICAP client</description>
                </value>
            </value-list>
        </type>
    </dp:param>

    <!-- ICAP Server Address -->
    <xsl:param name="dpconfig:ICAPRemoteHost" select="''" />
    <dp:param name="dpconfig:ICAPRemoteHost" type="dmHostname" xmlns="">
        <display>Remote Host Name</display>
        <description>The host name of the Virus Scanner.</description>

        <tab-override>basic</tab-override>
        <no-save-checkbox>true</no-save-checkbox>

        <required-when><condition evaluation="logical-true" /></required-when>
    </dp:param>

    <!-- ICAP Server Port -->
    <xsl:param name="dpconfig:ICAPRemotePort" select="''" />
    <dp:param name="dpconfig:ICAPRemotePort" type="dmIPPort" xmlns="">
        <display>Remote Port</display>
        <description>Remote port of the Virus Scanner.</description>

        <tab-override>basic</tab-override>
        <no-save-checkbox>true</no-save-checkbox>
    </dp:param>

    <!-- ICAP Server URI -->
    <xsl:param name="dpconfig:ICAPRemoteURI" select="''" />
    <dp:param name="dpconfig:ICAPRemoteURI" type="dmString" xmlns="">
        <display>Remote URI</display>
        <description>URI of the Virus Scanner.</description>

        <tab-override>basic</tab-override>
        <no-save-checkbox>true</no-save-checkbox>
    </dp:param>




    <!-- AV Processing Mode -->
    <xsl:param name="dpconfig:AntiVirusPolicy" select="'reject'" />
    <dp:param name="dpconfig:AntiVirusPolicy" type="AntiVirusPolicy" xmlns="">
        <display>Anti-Virus Policy</display>
        <description>Virus handling policy</description>
        <default>reject</default>

        <tab-override>basic</tab-override>
        <no-save-checkbox>true</no-save-checkbox>
        <format>radio</format>

        <type name="AntiVirusPolicy" base="enumeration" displayOrder="fixed">
            <value-list>
                <value name="log">
                    <display>Log</display>
                    <description>Log but do not strip attachment or reject policy.</description>
                </value>
                <value name="reject">
                    <display>Reject</display>
                    <description>Reject message</description>
                </value>
                <value name="strip">
                    <display>Strip</display>
                    <description>Strip offending attachment</description>
                </value>
            </value-list>
        </type>
    </dp:param>

    <!-- AV Processing Mode -->
    <xsl:param name="dpconfig:AntiVirusErrorPolicy" select="'reject'" />
    <dp:param name="dpconfig:AntiVirusErrorPolicy" type="AntiVirusErrorPolicy" xmlns="">
        <display>Anti-Virus Error Policy</display>
        <description>Anti-virus error handling policy</description>
        <default>reject</default>

        <tab-override>basic</tab-override>
        <no-save-checkbox>true</no-save-checkbox>
        <format>radio</format>

        <type name="AntiVirusErrorPolicy" base="enumeration" displayOrder="fixed">
            <value-list>
                <value name="log">
                    <display>Log</display>
                    <description>Log but do not strip attachment or reject policy.</description>
                </value>
                <value name="reject">
                    <display>Reject</display>
                    <description>Reject message</description>
                </value>
                <value name="strip">
                    <display>Strip</display>
                    <description>Strip offending attachment</description>
                </value>
            </value-list>
        </type>
    </dp:param>


    <!-- Logging Category -->
    <xsl:param name="dpconfig:LogCategory" select="'xsltmsg'" />
    <dp:param name="dpconfig:LogCategory" type="dmReference" reftype="LogLabel" xmlns="">
        <display>Log Category</display>
        <description>The log category for Virus Scanner logs.</description>
        <default>xsltmsg</default>

        <tab-override>basic</tab-override>
        <no-save-checkbox>true</no-save-checkbox>
    </dp:param>


    <xsl:variable name="icap-url">
        <xsl:text>icap://</xsl:text>
        <xsl:value-of select="$dpconfig:ICAPRemoteHost" />
        <xsl:if test="$dpconfig:ICAPRemotePort and string($dpconfig:ICAPRemotePort) != ''">
            <xsl:text>:</xsl:text>
            <xsl:value-of select="$dpconfig:ICAPRemotePort" />
        </xsl:if>
        <xsl:value-of select="$dpconfig:ICAPRemoteURI" />
    </xsl:variable>

    <!-- ##### COMMON TEMPLATES ##### -->

    <xsl:template match="/">
        <!-- default to accept, any reject after this will override -->
        <dp:accept />

        <xsl:variable name="attachments" select="dp:variable('var://local/attachment-manifest')/manifest/attachments" />

        <xsl:variable name="attachments-to-test">
            <xsl:choose>
                <xsl:when test="$dpconfig:AntiVirusProcessingMode = 'entire-message' or $dpconfig:AntiVirusProcessingMode = 'attachments'">
                    <xsl:copy-of select="$attachments/attachment" />
                </xsl:when>

                <xsl:when test="$dpconfig:AntiVirusProcessingMode = 'attachment-content-type'">
                    <xsl:copy-of select="$attachments/attachment[regexp:test( header[name = 'Content-Type']/value, $dpconfig:AntiVirusAttachmentContentType, '')]" />
                </xsl:when>

                <xsl:when test="$dpconfig:AntiVirusProcessingMode = 'attachment-uri'">
                    <xsl:copy-of select="$attachments/attachment[regexp:test( uri, $dpconfig:AntiVirusAttachmentURI, '')]" />
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="test-attachments-result">
            <xsl:apply-templates mode="icap-test-attachment" select="$attachments-to-test/attachment" />
        </xsl:variable>

        <xsl:choose>
            <!-- if we have no attachments, this will not be reject -->
            <xsl:when test="$test-attachments-result/reject">
                <dp:reject override="true"><xsl:value-of select="dpfunc:join(set:distinct($test-attachments-result/reject), '; ')" /></dp:reject>
            </xsl:when>

            <xsl:when test="$dpconfig:AntiVirusProcessingMode = 'entire-message' or $dpconfig:AntiVirusProcessingMode = 'xpath'">
                <xsl:variable name="icap-result">
                    <xsl:choose>
                        <xsl:when test="$dpconfig:AntiVirusProcessingMode = 'xpath'">
                            <xsl:copy-of select="dpfunc:icap-test(dyn:evaluate($dpconfig:AntiVirusXPathSelection), 'xml')" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="dpfunc:icap-test(., 'xml')" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <!-- There are three possible results: a clean message, a virus, and an error -->
                <xsl:choose>
                    <xsl:when test="$icap-result/virus">
                        <xsl:choose>
                            <xsl:when test="$dpconfig:AntiVirusProcessingMode = 'xpath'">
                                <xsl:message dp:type="{$dpconfig:LogCategory}" dp:priority="error" dp:id="{$DPLOG_XSLT_VIRUSINEXTRACTED}">
                                  <dp:with-param value="{$dpconfig:AntiVirusXPathSelection}" />
                                </xsl:message>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:message dp:type="{$dpconfig:LogCategory}" dp:priority="error" dp:id="{$DPLOG_XSLT_VIRUSINBODY}"/>
                            </xsl:otherwise>
                        </xsl:choose>

                        <xsl:choose>
                            <xsl:when test="$dpconfig:AntiVirusPolicy = 'reject' or $dpconfig:AntiVirusPolicy = 'strip'">
                                <!-- if the policy is reject virus, we don't need to continue -->
                                <dp:reject>Virus Found</dp:reject>
                                <!--  <dp:set-variable name="'var://service/error-subcode'" value="'0x01d30005'" /> -->
                                <dp:set-variable name="'var://service/error-subcode'" value="30605317" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="." />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$icap-result/error">
                        <xsl:message dp:type="{$dpconfig:LogCategory}" dp:priority="error" dp:id="{$DPLOG_XSLT_VIRUSSCANFAILED}">
                          <dp:with-param value="{$icap-result/error}" />
                        </xsl:message>
                        <xsl:choose>
                            <xsl:when test="$dpconfig:AntiVirusErrorPolicy = 'reject' or $dpconfig:AntiVirusErrorPolicy = 'strip'">
                                <dp:reject override="true">Unable to virus scan.</dp:reject>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="." />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$dpconfig:AntiVirusProcessingMode = 'attachments' or $dpconfig:AntiVirusProcessingMode = 'attachment-content-type' or $dpconfig:AntiVirusProcessingMode = 'attachment-uri'">
                <!-- do nothing -->
                <xsl:copy-of select="." />
            </xsl:when>
            <xsl:otherwise>
              <xsl:message dp:type="{$dpconfig:LogCategory}" dp:priority="error" dp:id="{$DPLOG_XSLT_VIRUSSCANFAILED_UNKNOWNMODE}">
                <dp:with-param value="{$dpconfig:AntiVirusProcessingMode}" />
              </xsl:message>


                <xsl:choose>
                    <xsl:when test="$dpconfig:AntiVirusErrorPolicy = 'reject' or $dpconfig:AntiVirusErrorPolicy = 'strip'">
                        <dp:reject override="true">Unable to virus scan.</dp:reject>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- join a list of nodes with an arbitrary delimiter
         @param nodes the node set to join
         @param delimiter the delimiter
     -->
    <func:function name="dpfunc:join">
        <xsl:param name="nodes" />
        <xsl:param name="delimiter" select="','" />

        <func:result>
            <xsl:for-each select="$nodes/self::node()">
                <xsl:value-of select="." />
                <xsl:if test="position() != last()"><xsl:value-of select="$delimiter" /></xsl:if>
            </xsl:for-each>
        </func:result>
    </func:function>


    <xsl:template mode="icap-test-attachment" match="attachment">
        <xsl:variable name="uri" select="normalize-space(uri)" />

        <xsl:choose>
            <xsl:when test="$uri = ''">
                <xsl:message dp:type="{$dpconfig:LogCategory}" dp:priority="error" dp:id="{$DPLOG_XSLT_VIRUSSCANFAILED_NOATTURI}"/>

                <xsl:choose>
                    <xsl:when test="$dpconfig:AntiVirusErrorPolicy = 'reject'">
                        <reject>Unable to virus scan.</reject>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$dpconfig:AntiVirusErrorPolicy = 'strip'">
                            <dp:strip-attachments uri="{uri}"/>
                            <xsl:message dp:type="{$dpconfig:LogCategory}" dp:priority="error" dp:id="{$DPLOG_XSLT_UNSCANNABLESTRIPPED}">
                              <dp:with-param value="{$uri}" />
                            </xsl:message>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- get base64 encoded attachment -->
                <xsl:variable name="binarydata">
                    <dp:url-open target="{concat($uri,'?Encode=base64')}" />
                </xsl:variable>

                <xsl:message dp:type="{$dpconfig:LogCategory}" dp:priority="notice" dp:id="{$DPLOG_XSLT_SCANNINGATTACH}">
                  <dp:with-param value="{$uri}" />
                </xsl:message>

                <!-- do the actual scanning -->
                <xsl:variable name="icap-result" select="dpfunc:icap-test($binarydata/base64/text(), 'base64')" />


                <!-- There are three possible results: a clean message, a virus, and an error -->
                <xsl:choose>
                    <xsl:when test="$icap-result/virus">
                        <xsl:message dp:type="{$dpconfig:LogCategory}" dp:priority="error" dp:id="{$DPLOG_XSLT_VIRUSINATTACH}">
                          <dp:with-param value="{$uri}" />
                        </xsl:message>

                        <xsl:choose>
                            <xsl:when test="$dpconfig:AntiVirusPolicy = 'reject'">
                                <!-- if the policy is reject virus, we don't need to continue -->
                                <reject>Virus Found</reject>
                                <!-- <dp:set-variable name="'var://service/error-subcode'" value="'0x01d30005'" /> -->
                                <dp:set-variable name="'var://service/error-subcode'" value="30605317" />
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- if the policy if strip infected attachments, do it an log it -->
                                <xsl:if test="$dpconfig:AntiVirusPolicy = 'strip'">
                                    <dp:strip-attachments uri="{uri}"/>
                                    <xsl:message dp:type="{$dpconfig:LogCategory}" dp:priority="warning" dp:id="{$DPLOG_XSLT_INFECTEDSTRIPPED}">
                                      <dp:with-param value="{$uri}" />
                                    </xsl:message>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$icap-result/error">
                        <xsl:message dp:type="{$dpconfig:LogCategory}" dp:priority="error" dp:id="{$DPLOG_XSLT_VIRUSSCANFAILED}">
                          <dp:with-param value="{$icap-result/error}" />
                        </xsl:message>

                        <xsl:choose>
                            <xsl:when test="$dpconfig:AntiVirusErrorPolicy = 'reject'">
                                <reject override="true">Unable to virus scan.</reject>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="$dpconfig:AntiVirusErrorPolicy = 'strip'">
                                    <dp:strip-attachments uri="{uri}"/>
                                    <xsl:message dp:type="{$dpconfig:LogCategory}" dp:priority="error" dp:id="{$DPLOG_XSLT_UNSCANNABLESTRIPPED}">
                                      <dp:with-param value="{$uri}" />
                                    </xsl:message>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- EXSLT wrapper around the icap-test template for simplicity -->
    <func:function name="dpfunc:icap-test">
        <xsl:param name="icap-data" />
        <xsl:param name="icap-data-type" />

        <func:result>
            <xsl:call-template name="icap-test">
                <xsl:with-param name="icap-data" select="$icap-data" />
                <xsl:with-param name="icap-data-type" select="$icap-data-type" />
            </xsl:call-template>
        </func:result>
    </func:function>

</xsl:stylesheet>
