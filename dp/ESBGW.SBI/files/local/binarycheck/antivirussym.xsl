<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dp="http://www.datapower.com/extensions" xmlns:dpconfig="http://www.datapower.com/param/config" extension-element-prefixes="dp" exclude-result-prefixes="dp dpconfig" version="1.0">
  <xsl:output method="xml"/>
  <dp:summary xmlns="">
    <operation>antivirus</operation>
    <description>Symantec</description>
  </dp:summary>
  <xsl:include href="antivirus.xsl" dp:ignore-multiple="yes"/>
  <!-- the core of the tests. -->
  <xsl:template name="icap-test">
    <xsl:param name="icap-data"/>
    <xsl:param name="icap-data-type"/>
    <xsl:variable name="httpHeaders">
      <header name="Host">localhost</header>
    </xsl:variable>
    <xsl:message dp:priority="debug" dp:type="all">
      <xsl:value-of select="concat('icapdata: ', $icap-data)"/>
    </xsl:message>
    <xsl:message dp:priority="debug" dp:type="all">
      <xsl:value-of select="concat('icap-data-type: ', $icap-data-type)"/>
    </xsl:message>
    <xsl:choose>
      <xsl:when test="$icap-data != ''">
        <xsl:variable name="test-result">
          <dp:url-open target="{$icap-url}" response="responsecode-ignore" data-type="base64" http-headers="$httpHeaders">
            <xsl:value-of select="$icap-data"/>
          </dp:url-open>
        </xsl:variable>
        <!--
		response example. responscode from KAV is ALWAYS 200. at least now. 

		<url-open xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dp="http://www.datapower.com/schemas/management">
			<responsecode>200</responsecode>
			<headers>
				<header name="ISTag">"KAVPROXY"</header>
				<header name="Date">Thu, 13 Jun 2013 10:48:52 GMT</header>
				<header name="Server">KAV-ICAP-Sever/5.5</header>
				<header name="X-ICAP-msg-id">r5DEmqC00302232</header>
				<header name="X-Virus-ID">INFECTED EICAR-Test-File</header>
				<header name="X-Response-Info">blocked</header>
				<header name="Encapsulated">res-hdr=0, res-body=72</header>
			</headers>
		</url-open>
		-->
        <xsl:choose>
          <xsl:when test="string($test-result/url-open/responsecode) = '201'        or $test-result/url-open/headers/header[@name = 'X-Infection-Found']        or $test-result/url-open/headers/header[@name = 'X-Clam-Virus'] = 'yes'        or $test-result/url-open/headers/header[@name = 'X-Response-Info'] = 'blocked'">
            <xsl:message dp:priority="error" dp:type="all">ICAP RESPONDED ABOUT VIRUS IN INCOMING MESSAGE. <xsl:copy-of select="$test-result/url-open"/>  </xsl:message>
            <virus/>
          </xsl:when>
          <xsl:when test="string($test-result/url-open/responsecode) = '405'">
            <error>
              <xsl:text>Method not allowed. Code: </xsl:text>
              <xsl:value-of select="$test-result/url-open/responsecode"/>
            </error>
          </xsl:when>
          <xsl:when test="string($test-result/url-open/responsecode) != '200'">
            <error>
              <xsl:text>Unrecognized response code "</xsl:text>
              <xsl:value-of select="$test-result/url-open/responsecode"/>
              <xsl:text>".</xsl:text>
              <xsl:if test="$test-result/url-open/errorstring">
                <xsl:text> Error: "</xsl:text>
                <xsl:value-of select="$test-result/url-open/errorstring"/>
                <xsl:text>"</xsl:text>
              </xsl:if>
            </error>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!--
ICAP error codes that differ from their HTTP counterparts are:
100 - Continue after ICAP Preview (Section 4.5).
204 - No modifications needed (Section 4.6).
400 - Bad request.
404 - ICAP Service not found.
405 - Method not allowed for service (e.g., RESPMOD requested for
service that supports only REQMOD).
408 - Request timeout. ICAP server gave up waiting for a request
from an ICAP client.
500 - Server error. Error on the ICAP server, such as "out of disk
space".
501 - Method not implemented. This response is illegal for an
OPTIONS request since implementation of OPTIONS is mandatory.
502 - Bad Gateway. This is an ICAP proxy and proxying produced an
error.
503 - Service overloaded. The ICAP server has exceeded a maximum
connection limit associated with this service; the ICAP client
should not exceed this limit in the future.
505 - ICAP version not supported by server.

SendAVScanResult=true|false Notification mode for alerting about a detected threat. If the 
parameter value is true, the following information is added to the ICAP response:

 X-Virus-ID – name of detected threat XResponse-Info – request processing result (blocked, filtered, or 
passed). Default value: false.

-->
</xsl:stylesheet>
