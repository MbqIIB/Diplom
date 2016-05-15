<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dp="http://www.datapower.com/extensions"
	xmlns:dpconfig="http://www.datapower.com/param/config"
	xmlns:str="http://exslt.org/strings"
	xmlns:Config="http://sberbank.ru/sbt/config"
	xmlns:regexp="http://exslt.org/regular-expressions"
	exclude-result-prefixes="dp dpconfig Config str regexp"
	extension-element-prefixes="dp dpconfig Config str regexp">
	
	<xsl:import href="local:///allParameters.xsl"/>
	<xsl:output method="xml" cdata-section-elements="Body"/>
	<dp:input-mapping href="local:///hexBinary.ffd" type="ffd"/>
	<dp:output-mapping href="local:///HeaderAndBodyOutput.ffd" type="ffd"/>	
	<xsl:template match="/">
		<xsl:variable name="LogTargetSub">
			<xsl:copy-of select="dp:variable('var://service/processor-name')"/>
		</xsl:variable>
		<!-- Magick offset, where XMIT starts	-->
		<xsl:variable name="XMITOffset">857</xsl:variable>		
			<xsl:variable name="FakeManagerCZ" select="'435a2e4553422e434f4d2e4d4350'" />
			<xsl:variable name="FakeManagerM99" select="'4d39392e4553422e434f4d2e4d4350'" />
			
			<xsl:variable name="ManagerCZ" select="'435a2e4553422e434f4d20202020'" />
			<xsl:variable name="ManagerM99" select="'4d39392e4553422e434f4d20202020'" />
			
			<!-- M99.ESB.COM.MCP -> M99.ESB.COM -->
			<xsl:variable name="bin">
				<xsl:choose>
					<xsl:when test="contains(/object/message,$FakeManagerCZ)"><xsl:value-of select="substring-before(/object/message,$FakeManagerCZ)"/><xsl:value-of select="$ManagerCZ"/><xsl:value-of select="substring-after(/object/message,$FakeManagerCZ)"/></xsl:when>
					<xsl:when test="contains(/object/message,$FakeManagerM99)"><xsl:value-of select="substring-before(/object/message,$FakeManagerM99)"/><xsl:value-of select="$ManagerM99"/><xsl:value-of select="substring-after(/object/message,$FakeManagerM99)"/></xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="/object/message"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>	
			
		<xsl:variable name="msg">					
			<xsl:variable name="binaryMsg">
				<xsl:value-of select="substring($bin, $XMITOffset)"/>
			</xsl:variable>
			<xsl:variable name="b64Msg">
				<xsl:copy-of select="dp:radix-convert($binaryMsg, 16, 64)"/>
			</xsl:variable>		
			<xsl:variable name="result" select="dp:parse($b64Msg, 'base-64')"/>
			<xsl:copy-of select="$result"/>
		</xsl:variable>
		<xsl:variable name="xmitHeader">					
			<xsl:value-of select="substring($bin, 0,$XMITOffset)"/>
		</xsl:variable>
		<xsl:variable name="vTransformedMsg">
			<!--<xsl:copy-of select="dp:transform(dp:variable('var://context/RQ/transformName'), $msg)" />-->
			<xsl:copy-of select="dp:transform('local:///sbi/maps/CopyAll.xsl', $msg)" />
		</xsl:variable>
		<xsl:variable name="vSerTransformedMsg"><dp:serialize select="$vTransformedMsg"/></xsl:variable>	
<Result>
	<XMIT><xsl:value-of select="$xmitHeader"/></XMIT>
	<Body><xsl:call-template name="decodeNCR"><xsl:with-param name="SerString" select="$vSerTransformedMsg"/></xsl:call-template></Body>
	<!--<Body><xsl:value-of select="$vSerTransformedMsg" disable-output-escaping="yes"/></Body>-->
</Result>
	</xsl:template>
	<xsl:template name="decodeNCR"><xsl:param name="SerString" select="''"/><xsl:value-of select="regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace(regexp:replace($SerString,'&amp;#1040;','g','А'),'&amp;#1041;','g','Б'),'&amp;#1042;','g','В'),'&amp;#1043;','g','Г'),'&amp;#1044;','g','Д'),'&amp;#1028;','g','Є'),'&amp;#1045;','g','Е'),'&amp;#1025;','g','Ё'),'&amp;#1046;','g','Ж'),'&amp;#1029;','g','Ѕ'),'&amp;#1047;','g','З'),'&amp;#1030;','g','І'),'&amp;#1048;','g','И'),'&amp;#1049;','g','Й'),'&amp;#1050;','g','К'),'&amp;#1051;','g','Л'),'&amp;#1052;','g','М'),'&amp;#1053;','g','Н'),'&amp;#1054;','g','О'),'&amp;#1055;','g','П'),'&amp;#1056;','g','Р'),'&amp;#1057;','g','С'),'&amp;#1058;','g','Т'),'&amp;#1144;','g','Ѹ'),'&amp;#1059;','g','У'),'&amp;#1060;','g','Ф'),'&amp;#1061;','g','Х'),'&amp;#1120;','g','Ѡ'),'&amp;#1062;','g','Ц'),'&amp;#1063;','g','Ч'),'&amp;#1064;','g','Ш'),'&amp;#1065;','g','Щ'),'&amp;#1066;','g','Ъ'),'&amp;#1067;','g','Ы'),'&amp;#1068;','g','Ь'),'&amp;#1122;','g','Ѣ'),'&amp;#1069;','g','Э'),'&amp;#1070;','g','Ю'),'&amp;#1124;','g','Ѥ'),'&amp;#1126;','g','Ѧ'),'&amp;#1071;','g','Я'),'&amp;#1130;','g','Ѫ'),'&amp;#1128;','g','Ѩ'),'&amp;#1132;','g','Ѭ'),'&amp;#1134;','g','Ѯ'),'&amp;#1136;','g','Ѱ'),'&amp;#1138;','g','Ѳ'),'&amp;#1138;','g','Ѵ'),'&amp;#1072;','g','а'),'&amp;#1073;','g','б'),'&amp;#1074;','g','в'),'&amp;#1075;','g','г'),'&amp;#1076;','g','д'),'&amp;#1108;','g','є'),'&amp;#1077;','g','е'),'&amp;#1105;','g','ё'),'&amp;#1078;','g','ж'),'&amp;#1109;','g','ѕ'),'&amp;#1079;','g','з'),'&amp;#1110;','g','і'),'&amp;#1080;','g','и'),'&amp;#1081;','g','й'),'&amp;#1082;','g','к'),'&amp;#1083;','g','л'),'&amp;#1084;','g','м'),'&amp;#1085;','g','н'),'&amp;#1086;','g','о'),'&amp;#1087;','g','п'),'&amp;#1088;','g','р'),'&amp;#1089;','g','с'),'&amp;#1090;','g','т'),'&amp;#1145;','g','ѹ'),'&amp;#1091;','g','у'),'&amp;#1092;','g','ф'),'&amp;#1093;','g','х'),'&amp;#1121;','g','ѡ'),'&amp;#1094;','g','ц'),'&amp;#1095;','g','ч'),'&amp;#1096;','g','ш'),'&amp;#1097;','g','щ'),'&amp;#1098;','g','ъ'),'&amp;#1099;','g','ы'),'&amp;#1100;','g','ь'),'&amp;#1123;','g','ѣ'),'&amp;#1101;','g','э'),'&amp;#1102;','g','ю'),'&amp;#1125;','g','ѥ'),'&amp;#1127;','g','ѧ'),'&amp;#1103;','g','я'),'&amp;#1131;','g','ѫ'),'&amp;#1129;','g','ѩ'),'&amp;#1133;','g','ѭ'),'&amp;#1135;','g','ѯ'),'&amp;#1137;','g','ѱ'),'&amp;#1139;','g','ѳ'),'&amp;#1139;','g','ѵ'),'&amp;#1031;','g','Ї'),'&amp;#1150;','g','Ѿ'),'&amp;#1146;','g','Ѻ'),'&amp;#1111;','g','ї'),'&amp;#1151;','g','ѿ'),'&amp;#1147;','g','ѻ'),'&amp;#714;','g','ˊ'),'&amp;#715;','g','ˋ'),'&amp;#785;','g','а̑'),'&amp;#728;','g','˘'),'&amp;#830;','g','д̾'),'&amp;#168;','g','¨'),'&amp;#1155;','g','҃'),'&amp;#175;','g','¯'),'&amp;#704;','g','ˀ'),'&amp;#777;','g','а̉'),'&amp;#1156;','g','҄'),'&amp;#1154;','g','҂')" disable-output-escaping="yes"/></xsl:template>
</xsl:stylesheet>
