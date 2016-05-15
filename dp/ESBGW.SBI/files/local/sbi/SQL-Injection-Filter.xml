<?xml version="1.0"?>
<!--
  Licensed Materials - Property of IBM
  IBM WebSphere DataPower Appliances
  Copyright IBM Corporation 2007,2012. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure
  restricted by GSA ADP Schedule Contract with IBM Corp.
-->

<!--
     SQL-Injection-Filter.xsl
     Copyright 2004 DataPower Technology, Inc. All Rights Reserved.
     
     SQL Injection Patterns are maintained in the external
     file: store:///SQL-Injection-Patterns.xml
     This can be changed by setting the SQLPatternFile
     (in namespace http://www.datapower.com/param/config)
     parameter on either the firewall or on the filter action
     in the processing policy.

     NOTE: This filter scans for many commonly-known methods
           of SQL Injection attacks, primarily data destruction
           attacks. This method of detecting SQL Injection
           attacks (i.e. via pattern matching) is akin to
           "virus scanning" and *ALONE IS NOT 100% EFFECTIVE*
           against all SQL Injection attacks. This filter can
           catch known exploits, for which there is a detection
           pattern, and data destruction attacks by watching
           for injected database commands and/or query syntax.
           It cannot, however, catch all types (particularly
           those discovered in the future) of data acquisition
           attacks.
                
           The only way to achieve as close to 100% protection as
           possible against all SQL Injection attacks is to implement
           the following two-step policy which is the complete
           DataPower-recommended solution for comprehensive
           SQL Injection attack prevention:
           
              1) Use this filter to detect common SQL query data
                 acquisition and data destruction attack attempts.
              2) SCHEMA VALIDATE ALL SOAP RESPONSE MESSAGES using a
                 business level schema. This schema should ensure
                 that all message responses return only the data
                 that they are supposed to. For example, if you
                 have a Web Service that returns one row of data
                 from your database, your outbound schema validation
                 should enforce that. Any response that contains
                 anything other than a single row of data has the
                 high likelihood of being the response to a successful
                 SQL injection attack.
                 
           DataPower recommends this solution for two reasons:
           
              A) Inbound attack scanning will never catch all injection
                 attacks. Someone will always think of a new clever
                 type of attack that you aren't filtering for. Also,
                 as databases evolve, they will introduce new SQL
                 syntax that will expose your database to new types
                 of attacks. The only true way to protect against
                 unauthorized data acquisition is to *PREVENT THE
                 UNAUTHORIZED DATA FROM EVER LEAVING YOUR NETWORK*.
                 
              B) Allowing the actual request to complete before
                 filtering the data from the response path provides
                 you with the maximum amount of forensics so that you
                 can perform post-mortem analysis on the attack. You
                 can find out exactly what the attacker was trying
                 to do, how he was trying to do it, and what data
                 he/she would have received if the attack had been
                 successful.
     
     REMEMBER: 1) Filter requests for data destruction attacks
               2) Schema validate ALL RESPONSES to protect against
                  unauthorized data acquisition.

     NOTE:     For efficient access to the pattern file
               (the released version of which is on store:
               but a locally modified version of which might
               be on local:), firewalls using policies which
               include a filter step using this stylesheet
               should be configured with the following options
               on the XML Manager (e.g. "default"):

                   documentcache default
                       policy store:*.xml 128 86400
                       policy local:*.xml 128 86400
                       clear
                   exit

  -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:dp="http://www.datapower.com/extensions"
                              xmlns:regexp="http://exslt.org/regular-expressions"
                              xmlns:dpconfig="http://www.datapower.com/param/config"

                              extension-element-prefixes="dp regexp"
                              exclude-result-prefixes="dp">

    <xsl:include href="store:///dp/msgcat/dplane.xml.xsl" dp:ignore-multiple="yes"/>

    <dp:summary xmlns="">
        <operation>filter</operation>
        <description>Scan document for SQL injection attacks.</description>
    </dp:summary>

    <xsl:param name="dpconfig:SQLPatternFile" select="'store:///SQL-Injection-Patterns.xml'"/>
		
    <dp:param name="dpconfig:SQLPatternFile" type="dmFSFile" xmlns="">
        <display>SQL Injection Pattern File</display>
        <location>store:</location>
        <location>local</location>
        <default>local:///sbi/SQL-Injection-Patterns.xml</default>
        <description>The file containing patterns to search for in order to detect SQL injection attacks.</description>
    </dp:param>
    
    <xsl:param name="dpconfig:SQLDEBUG" select="false()"/>

    <xsl:template name="SQL-Injection-Test">
        <xsl:param name="text"/>
        <xsl:param name="searchRegex"/>
        <xsl:param name="attackName"/>
        <xsl:param name="message"/>
        
        <xsl:variable name="injectionMatch" select="regexp:match( $text, $searchRegex, 'i' )"/>

        <xsl:if test="$dpconfig:SQLDEBUG">
            <xsl:message dp:priority="debug" dp:id="{$DPLOG_SQL_INJECTION_COUNT}">
              <dp:with-param value="{$text}"/>
              <dp:with-param value="{$searchRegex}"/>
              <dp:with-param value="{count($injectionMatch)}"/>
            </xsl:message>
        </xsl:if>
        
        <xsl:if test="count( $injectionMatch ) &gt; 0">
            <dp:set-variable name="'var://context/__SQL_INJECTION_FILTER__/hit'" value="'1'"/>            
            <dp:reject>Message contains restricted content</dp:reject>
            <xsl:variable name="serial">
              <dp:serialize select="$message"/>
            </xsl:variable>
            <xsl:message dp:priority="error" dp:id="{$DPLOG_SQL_INJECTION_FULL_MSG}">
              <dp:with-param value="{dp:client-ip-addr()}"/>
              <dp:with-param value="{$attackName}"/>
              <dp:with-param value="{string( $injectionMatch )}"/>
              <dp:with-param value="{$serial}"/>
            </xsl:message>
        </xsl:if>
        
    </xsl:template>

    <xsl:variable name="patterns" select="document( $dpconfig:SQLPatternFile )"/>
    
    <!--
        Test all attribute and node content for Injection Attack attempts
      -->
	<xsl:template match="/">
	    
	    <dp:set-variable name="'var://context/__SQL_INJECTION_FILTER__/hit'" value="'0'"/>	    
	    <xsl:variable name="sourceMessage" select="."/>
    
        <!-- Check the content of all attributes in the document -->
        <xsl:variable name="allAttributes">
            <xsl:apply-templates mode="enumerate" select="//@*"/>
        </xsl:variable>
 
        <xsl:variable name="whatToCheck" select="normalize-space( string( $allAttributes ) )"/>
        <xsl:if test="$dpconfig:SQLDEBUG">
            <xsl:message dp:priority="debug" dp:id="{$DPLOG_SQL_INJECTION_ATTRIBUTE}">
              <dp:with-param value="{$whatToCheck}"/>
            </xsl:message>
        </xsl:if>
        
        <xsl:if test="$whatToCheck != ''">
            <xsl:for-each select="$patterns/patterns/pattern[ not( @type ) ] | $patterns/patterns/pattern[ @type = 'global' ]">

                <xsl:if test="dp:variable( 'var://context/__SQL_INJECTION_FILTER__/hit' ) = '0'">
                    <xsl:if test="$dpconfig:SQLDEBUG">
                        <xsl:message dp:priority="debug" dp:id="{$DPLOG_SQL_INJECTION_ALL_ATTRIBUTES}">
                          <dp:with-param value="{$whatToCheck}"/>
                          <dp:with-param value="{regex}"/>
                        </xsl:message>
                    </xsl:if>
                    
                    <xsl:call-template name="SQL-Injection-Test">
                        <xsl:with-param name="text"        select="$whatToCheck"/>
                        <xsl:with-param name="searchRegex" select="regex"/>
                        <xsl:with-param name="attackName"  select="name"/>
                        <xsl:with-param name="message"     select="$sourceMessage"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>

        <!--
             Check all of the node content in the document. Here we check
             'string( / )' because this will evaluate to all node content
             in the message recursively.
          -->
        <xsl:variable name="content" select="normalize-space( string( . ) )"/>
	    <xsl:if test="$dpconfig:SQLDEBUG">
              <xsl:message dp:priority="debug" dp:id="{$DPLOG_SQL_INJECTION_ALL_ELEMENT_VALUE}">
                <dp:with-param value="{$content}"/> 
              </xsl:message>
	    </xsl:if>
	    
	    <xsl:if test="$content != ''">
    	    <xsl:for-each select="$patterns/patterns/pattern[ not( @type ) ] | $patterns/patterns/pattern[ @type = 'global' ]">
    
    	        <xsl:if test="dp:variable( 'var://context/__SQL_INJECTION_FILTER__/hit' ) = '0'">
                  <xsl:variable name="regex"   select="regex"/>
        	        <xsl:if test="$dpconfig:SQLDEBUG">  
                        <xsl:message dp:priority="debug" dp:id="{$DPLOG_SQL_INJECTION_ALL_ELEMENTS}">
                          <dp:with-param value="{$content}"/>
                          <dp:with-param value="{$regex}"/>
                        </xsl:message>
        	        </xsl:if>
        	    
                    <xsl:call-template name="SQL-Injection-Test">
                        <xsl:with-param name="text"        select="$content"/>
                        <xsl:with-param name="searchRegex" select="$regex"/>
                        <xsl:with-param name="attackName"  select="name"/>
                        <xsl:with-param name="message"     select="$sourceMessage"/>
                    </xsl:call-template>
    	        </xsl:if>
    	        
    	    </xsl:for-each>
	    </xsl:if>
        

        <!--
             Generate concatenation of normalize-string(string()) for all elements.
             Add pseudo begin and end characters for allowing regexp
             matches of the form "^...$". ^ will be represented by \t,
             and $ will be represented by \r, which is fine since neither
             \t nor \r is present after "normalize-space( ... )".
             This allows for doing #patterns regexp evaluations on a big string
             instead of #patterns * #elements regexp evaluations on the elements.
             If any pattern would be hit during iteration on all elements
             (eg. ^insert$), the corresponding pattern (\tinsert\r) would be
             hit on the big string. And the other implication holds, too.
             In case of a hit on the big string we definitely have a hit on an
             element (no false positives because of \t and \r).
        -->
        <xsl:variable name="tabcontentcr"><xsl:apply-templates mode="tabcr" select="$sourceMessage"/></xsl:variable>

	    <!--
	         Perform the 'element' pattern searches
	         These are individual regex searches that are done on all element
	         content individually.
                 The trick is to perform the regex searches for all elements in
                 parallel, see comment on "tabcontentcr".
	      -->
	    <xsl:for-each select="$patterns/patterns/pattern[ @type = 'element' ]">
	        <xsl:variable name="regex"   select="regex"/>
	        <xsl:variable name="name"    select="name"/>
	        
	            <xsl:if test="dp:variable( 'var://context/__SQL_INJECTION_FILTER__/hit' ) = '0'">
	                
                    <xsl:variable name="regex1" select="regexp:replace( regexp:replace( $regex, '\^', 'g', '\t'), '\$', 'g', '\r')"/>
    
    	            <xsl:if test="$dpconfig:SQLDEBUG">                
    	                <xsl:message dp:priority="debug" dp:id="{$DPLOG_SQL_INJECTION_ELEMENT}">
                        <dp:with-param value="{$tabcontentcr}"/>
                        <dp:with-param value="{$regex1}"/>
                      </xsl:message>
    	            </xsl:if>
    	            
    	            <xsl:call-template name="SQL-Injection-Test">
    	                <xsl:with-param name="text"        select="$tabcontentcr"/>
    	                <xsl:with-param name="searchRegex" select="$regex1"/>
    	                <xsl:with-param name="attackName"  select="$name"/>
    	                <xsl:with-param name="message"     select="$sourceMessage"/>
    	            </xsl:call-template>
	            </xsl:if>
	            
	    </xsl:for-each>
	    
	    <!-- Be a good citizen and identity transform if all's well -->
        <xsl:if test="dp:accepting()">
            <xsl:copy-of select="."/>            
        </xsl:if>

	</xsl:template>
	
    <xsl:template match="//@*" mode="enumerate">
        <xsl:value-of select="concat( string( . ), ' ' )"/>
    </xsl:template>	


    <!-- Helper template for creation of string "tabcontentcr" -->
    <xsl:template mode="tabcr" match="*">
        <!-- for "..../elem" attack prevention -->
        <xsl:text>&#9;</xsl:text>
        <xsl:value-of select="normalize-space(string(.))"/>
        <xsl:text>&#13;</xsl:text>

        <xsl:if test="count(*) > 0">
            <!-- for "..../elem/text()" attack prevention -->
            <xsl:variable name="txt"><xsl:copy-of select="text()"/></xsl:variable>
            <xsl:text>&#9;</xsl:text>
            <xsl:value-of select="normalize-space($txt)"/>
            <xsl:text>&#13;</xsl:text>
        </xsl:if>


        <xsl:apply-templates mode="tabcr" select="*"/>
    </xsl:template>
	
</xsl:stylesheet>

