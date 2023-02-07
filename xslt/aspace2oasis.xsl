<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:ead="urn:isbn:1-931666-22-9"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink">
	<xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes"/>

	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ead:eadid">
		<xsl:variable name="HID">
			<xsl:choose>
				<xsl:when test="//ead:processinfo[lower-case(ead:head)='aleph id']">
					<xsl:text>99</xsl:text><xsl:value-of select="//ead:processinfo[lower-case(ead:head)='aleph id']/ead:p"/><xsl:text>0203941</xsl:text>
				</xsl:when>
				<xsl:when test="//ead:processinfo[lower-case(ead:head)='alma id']">
					<xsl:value-of select="//ead:processinfo[lower-case(ead:head)='alma id']/ead:p"/>
				</xsl:when>
				<xsl:otherwise>000000000000000000</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:copy>
			<xsl:attribute name="identifier">
				<xsl:value-of select="$HID"/>
			</xsl:attribute>
			<xsl:copy-of select="@*"/>
			<xsl:value-of select="."/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ead:title" mode="frontmatter">
		<xsl:apply-templates select="ead:num" mode="frontmatter"/>
	</xsl:template>

	<xsl:template match="ead:num" mode="frontmatter"/>

	<xsl:template match="ead:eadheader">
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
		<xsl:element name="frontmatter" namespace="urn:isbn:1-931666-22-9">
			<xsl:element name="titlepage" namespace="urn:isbn:1-931666-22-9">
				<xsl:copy-of select="ead:filedesc/ead:titlestmt/ead:titleproper/ead:num"/>
				<xsl:element name="titleproper" namespace="urn:isbn:1-931666-22-9">
					<xsl:apply-templates select="ead:filedesc/ead:titlestmt/ead:titleproper" mode="frontmatter"/>
				</xsl:element>	
				<xsl:element name="author" namespace="urn:isbn:1-931666-22-9">
					<xsl:value-of select="../ead:archdesc/ead:did/ead:repository/ead:corpname"/>
				</xsl:element>
				<xsl:call-template name="getshields"/>
				<xsl:apply-templates select="ead:filedesc/ead:publicationstmt/ead:publisher"/>				
				<xsl:element name="p" namespace="urn:isbn:1-931666-22-9">
					<xsl:text>&#169; President and Fellows of Harvard College</xsl:text>
				</xsl:element>
				<xsl:apply-templates select="ead:filedesc/ead:titlestmt/ead:sponsor"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ead:filedesc/ead:titlestmt/ead:sponsor">
		<xsl:copy-of select="."/>
	</xsl:template>

	<!--<xsl:template match="ead:processinfo[ead:head='Aleph ID']"/>-->

	<xsl:template match="ead:archdesc">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="ead:did" mode="archdesclevel"/>
			<xsl:copy-of select="ead:acqinfo"/>
			<xsl:copy-of select="ead:custodhist"/>
			<xsl:copy-of select="ead:processinfo[not(ead:head='Aleph ID')]"/>
			<xsl:copy-of select="ead:accessrestrict"/>
			<xsl:copy-of select="ead:phystech"/>
			<xsl:copy-of select="ead:userestrict"/>
			<xsl:copy-of select="ead:altformavail"/>
			<xsl:copy-of select="ead:prefercite"/>
			<xsl:copy-of select="ead:relatedmaterial"/>
			<xsl:copy-of select="ead:separatedmaterial"/>
			<xsl:copy-of select="ead:bioghist"/>
			<!-- see note -->
			<xsl:copy-of select="ead:bibliography"/>
			<xsl:copy-of select="ead:arrangement"/>
			<xsl:copy-of select="ead:scopecontent"/>
			<!-- accruals through runner added post-ATK -->
			<xsl:copy-of select="ead:accruals"/>
			<xsl:copy-of select="ead:appraisal"/>
			<xsl:copy-of select="ead:fileplan"/>
			<xsl:copy-of select="ead:odd"/>
			<xsl:copy-of select="ead:note"/>
			<xsl:copy-of select="ead:originalsloc"/>
			<xsl:copy-of select="ead:otherfindaid"/>
			<xsl:copy-of select="ead:runner"/>
			
			<!--<xsl:copy-of select="ead:dsc"/>-->
			<xsl:apply-templates select="ead:dsc"/>
			<xsl:copy-of select="ead:controlaccess"/>
			<xsl:apply-templates select="ead:index"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ead:did" mode="archdesclevel">
		<xsl:copy>
			<xsl:copy-of select="ead:physloc"/>
			<xsl:copy-of select="ead:unitid"/>
			<xsl:copy-of select="ead:repository"/>
			<xsl:copy-of select="ead:origination"/>
			<xsl:copy-of select="ead:unittitle"/>
			<xsl:copy-of select="ead:unitdate"/>
			<!--<xsl:copy-of select="ead:physdesc"/>-->
			<!-- need to add parens -->

			<xsl:apply-templates select="//ead:archdesc/ead:did/ead:physdesc"/>
			<!--<xsl:copy-of select="ead:langmaterial[not(.='') and not(./lanugage='')]"/>-->
			<!--<xsl:apply-templates select="ead:langmaterial"/>-->
			<xsl:choose>
				<xsl:when test="ead:langmaterial[2]">
					<xsl:copy-of select="ead:langmaterial[2]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="ead:langmaterial[1]"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:copy-of select="ead:abstract"/>
			<!-- added post-ATK - why not there before? -->
			<xsl:copy-of select="ead:container"/>
		</xsl:copy>
	</xsl:template>

	<!--<xsl:template match="ead:langmaterial">
		<xsl:copy>
			<xsl:value-of select="normalize-space(.)"/>
		</xsl:copy>
	</xsl:template>-->

<!--
	<xsl:template match="ead:archdesc/ead:did/ead:physdesc">
		<xsl:copy>
			<xsl:for-each select="ead:extent">
				<xsl:if test="position() = 1">
					<xsl:copy-of select="."/>
				</xsl:if>
				<xsl:if test="position() > 1">
					<xsl:text> (</xsl:text>
					<xsl:copy-of select="."/>
					<xsl:text>)</xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>
-->
	<xsl:template match="ead:c/ead:did">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<!--<xsl:copy-of select="ead:unitid"/>-->
			<xsl:apply-templates select="ead:unitid"/>
			<xsl:if test="not($code='hua') and not($code='hou') and not($code='bbb') and not($code='ccc') and not($code='ddd')">
				<xsl:copy-of select="ead:container"/>
			</xsl:if>
			<!--<xsl:copy-of select="ead:unittitle"/>-->
			<xsl:apply-templates select="ead:unittitle"/>
			<!--<xsl:apply-templates select="ead:unitdate"/>-->
			<!--<xsl:copy-of select="ead:physdesc"/>-->
			<xsl:apply-templates select="ead:physdesc"/>
			<xsl:copy-of select="ead:physloc"/>
			<xsl:if test="$code='hua' or$code='hou' or $code='bbb' or $code='ccc' or $code='ddd'">
				<xsl:copy-of select="ead:container"/>
			</xsl:if>
			<!--<xsl:copy-of select="../ead:odd"/>-->
			<!--<xsl:apply-templates select="ead:unitdate"/>-->
			<xsl:copy-of select="ead:unitdate"/>
			<!--<xsl:apply-templates select="ead:container"/>-->
			<xsl:copy-of select="ead:origination"/>
			<xsl:copy-of select="ead:langmaterial"/>
			<!--<xsl:apply-templates/>-->
			<xsl:choose>
				<xsl:when test="count(ead:dao) > 1">
					<xsl:element name="daogrp" namespace="urn:isbn:1-931666-22-9">
						<xsl:element name="resource" namespace="urn:isbn:1-931666-22-9">
							<xsl:attribute name="xlink:label">start</xsl:attribute>
							<xsl:attribute name="xlink:type">resource</xsl:attribute>
						</xsl:element>
						<xsl:apply-templates select="ead:dao[@xlink:actuate='onLoad']" mode="daogrp"/>
						<xsl:apply-templates select="ead:dao[@xlink:actuate='onRequest']" mode="daogrp"/>
					</xsl:element>	
				</xsl:when>
				<xsl:when test="count(ead:dao) = 1">
					<xsl:copy-of select="ead:dao"/>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
			<xsl:copy-of select="ead:daogrp"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ead:dao" mode="daogrp">
			<xsl:variable name="resourcenumber">
				<xsl:choose>
					<xsl:when test="position() = 1">resource-1</xsl:when>
					<xsl:when test="position() = 2">resource-2</xsl:when>
					<!--<xsl:when test="@xlink:actuate='onLoad'">resource-1</xsl:when>
					<xsl:when test="@xlink:actuate='onRequest'">resource-2</xsl:when>-->
				</xsl:choose>
			</xsl:variable>
			<xsl:element name="daoloc" namespace="urn:isbn:1-931666-22-9">
				<xsl:attribute name="xlink:href">
					<xsl:value-of select="@xlink:href"/>
				</xsl:attribute>
				<xsl:attribute name="xlink:label"><xsl:value-of select="$resourcenumber"/></xsl:attribute>
				<xsl:apply-templates select=".[@xlink:actuate='onRequest']/ead:daodesc" mode="daogrp"/>
			</xsl:element>
			<xsl:element name="arc" namespace="urn:isbn:1-931666-22-9">
				<xsl:copy-of select="@xlink:actuate"/>
				<xsl:attribute name="xlink:from">start</xsl:attribute>
				<xsl:copy-of select="@xlink:show"/>
				<xsl:attribute name="xlink:to"><xsl:value-of select="$resourcenumber"/></xsl:attribute>
				<xsl:attribute name="xlink:type">arc</xsl:attribute>
			</xsl:element>
	</xsl:template>

	<xsl:template match="ead:daodesc" mode="daogrp">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ead:unitid">
		<xsl:copy>
			<xsl:value-of select="."/>
			<!--<xsl:if test="not(ends-with(.,'.'))">
				<xsl:text>.</xsl:text>
			</xsl:if>
			<xsl:text> </xsl:text>-->
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ead:unittitle">
		<xsl:copy>
			<!--<xsl:copy-of select="@*|text()"/>-->
			<xsl:copy-of select="@* | text() | node()"/>
			<!--<xsl:text> </xsl:text>-->
			<!--<xsl:if test="ends-with(.,',')">
				<xsl:text> </xsl:text>
			</xsl:if>-->
			<!--<xsl:if test="../ead:unitdate">
				<xsl:if test="not(ends-with(normalize-space(.),','))">
					<xsl:text>, </xsl:text>
				</xsl:if>
				<xsl:apply-templates select="../ead:unitdate" mode="componentlevel"/>
			</xsl:if>-->
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ead:unitdate">
		<xsl:copy>
			<xsl:value-of select="."/><!--<xsl:text> </xsl:text>-->
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ead:extent">
		<xsl:copy>
		<xsl:choose>
			<xsl:when test="preceding-sibling::ead:extent">
				<xsl:variable name="followingextent">
					<xsl:text> (</xsl:text><xsl:value-of select="."/><xsl:text>)</xsl:text>
				</xsl:variable>
				<xsl:value-of select="replace(replace($followingextent,'\(\(','('),'\)\)',')')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="ead:c/@id[starts-with(.,'aspace_')]">
		<xsl:attribute name="id">
			<xsl:choose>
				<xsl:when test="string-length(.) = 39">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(., 'aspace_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<xsl:template match="ead:ref[ead:ptr]">
		<xsl:element name="ptrgrp" namespace="urn:isbn:1-931666-22-9">
			<xsl:apply-templates mode="ptr2ref"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="ead:ptr" mode="ptr2ref">
		<xsl:element name="ref" namespace="urn:isbn:1-931666-22-9">
			<!--<xsl:attribute name="target"><xsl:value-of select="@target"/></xsl:attribute>-->
			<xsl:apply-templates select="@target"/>
			<xsl:attribute name="xlink:type">simple</xsl:attribute>
			<xsl:value-of select="@xlink:title"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ead:ptr/@target">
		<xsl:attribute name="target"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>

	<xsl:template match="ead:physdesc[not(*)]">
		<xsl:copy>
			<xsl:text> </xsl:text><xsl:value-of select="."/>
		</xsl:copy>	
	</xsl:template>

	<xsl:template match="ead:physdesc/ead:physfacet|ead:physdesc/ead:dimensions">
		<xsl:copy>
			<xsl:text> </xsl:text><xsl:value-of select="."/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="ead:publisher">
		<xsl:copy>
			<xsl:apply-templates select="$publishers">
				<xsl:with-param name="pub" select="."/>
			</xsl:apply-templates>
		</xsl:copy>	
	</xsl:template>

	<xsl:template match="publishers">
		<xsl:param name="pub"/>
		<xsl:choose>
			<xsl:when test="key('reposlookup',$code)/publisher !=''">
				<xsl:value-of select="key('reposlookup',$code)/publisher"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$pub"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="getshields">
		<xsl:apply-templates select="$shields"/>
	</xsl:template>
	
	<xsl:template match="shields">
		<xsl:choose>
			<xsl:when test="key('reposlookup',$code)/shield !=''">
				<xsl:element name="p" namespace="urn:isbn:1-931666-22-9">
					<xsl:element name="extptr" namespace="urn:isbn:1-931666-22-9">
						<xsl:attribute name="xlink:href"><xsl:value-of select="key('reposlookup',$code)/shield"/></xsl:attribute>
						<xsl:attribute name="xlink:type">simple</xsl:attribute>
					</xsl:element>
				</xsl:element>	
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>		
	</xsl:template>

	<xsl:key name="reposlookup" match="map" use="reposcode"/>
	<xsl:variable name="publishers" select="document('publishers.xml')/publishers"/>
	<xsl:variable name="shields" select="document('shields.xml')/shields"/>
	<xsl:variable name="code" select="substring(/ead:ead/ead:eadheader/ead:eadid,1,3)"/>

</xsl:stylesheet>
