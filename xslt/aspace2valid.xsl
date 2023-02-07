<xsl:stylesheet version="2.0" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink">

    <xsl:output method="xml" encoding="utf-8" indent="yes"/>

    <!-- Identity template : copy all text nodes, elements and attributes -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- strip aspace_ prefix from all c ids -->
    <xsl:template match="@id[starts-with(., 'aspace_') and not(string-length(substring-after(.,'_')) = 32)]">
        <xsl:attribute name="id">
            <xsl:value-of select="substring-after(., 'aspace_')"/>
        </xsl:attribute>
    </xsl:template>

    <!-- strip aspace_ prefix from all ref target attributes -->
    <xsl:template match="ead:ref/@target[starts-with(., 'aspace_')]">
        <xsl:attribute name="target">
            <xsl:value-of select="substring-after(., 'aspace_')"/>
        </xsl:attribute>
    </xsl:template>

    <!-- strip date elements from bibrefs, and move date content up 1 level into bibref -->
    
    <xsl:template match="ead:bibref[ead:date]">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="ead:bibref/ead:date">
        <xsl:value-of select="."/>
    </xsl:template>    

    <xsl:template match="ead:odd[ead:head and ead:p/ead:head]">
        <xsl:copy>
            <xsl:copy-of select="ead:p/ead:head"/>
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="ead:odd[ead:head and ead:p/ead:head]/ead:head|ead:odd[ead:head and ead:p/ead:head]/ead:p[ead:head]"/>
    
    <!-- for hou00070, and others? -->
    <xsl:template match="ead:odd[ead:note][not(ead:p) and text()]">
        <xsl:copy>
            <xsl:apply-templates select="ead:head"/>
            <xsl:element name="p" namespace="urn:isbn:1-931666-22-9"><xsl:value-of select="text()"/></xsl:element>
            <xsl:apply-templates select="node() except (text()|ead:head)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="ead:odd/ead:note[not(ead:p)]">
        <xsl:copy>
            <xsl:element name="p" namespace="urn:isbn:1-931666-22-9">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="ead:archdesc/ead:did/ead:repository/ead:corpname">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="starts-with(//ead:eadid,'art')">
          <xsl:text>Harvard Art Museums Archives, Harvard Art Museums, Harvard University</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(//ead:eadid,'bak')">
          <xsl:text>Baker Library Special Collections, Harvard Business School</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(//ead:eadid,'ddo')">
          <xsl:text>Dumbarton Oaks Image Collections and Fieldwork Archives</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(//ead:eadid,'des')">
          <xsl:text>Frances Loeb Library Special Collections, Graduate School of Design, Harvard University</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(//ead:eadid,'env')">
          <xsl:text>Environmental Science and Public Policy Archives</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(//ead:eadid,'fal')">
          <xsl:text>Fine Arts Library, Harvard Library, Harvard University</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(//ead:eadid,'hou')">
          <xsl:text>Houghton Library, Harvard College Library</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(//ead:eadid,'med')">
          <xsl:text>Countway Library of Medicine, Center for the History of Medicine</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(//ead:eadid,'mus')">
          <xsl:text>Eda Kuhn Loeb Music Library</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(//ead:eadid,'pea')">
          <xsl:text>Peabody Museum of Archaeology and Ethnology Archives, Harvard University</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(//ead:eadid,'uri')">
          <xsl:text>Ukrainian Research Institute Library, Harvard University</xsl:text>
        </xsl:when>
        <xsl:when test="starts-with(//ead:eadid,'sch')">
          <xsl:text>Schlesinger Library on the History of Women in America, Radcliffe Institute for Advanced Study</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
    </xsl:template>

    <!-- this kills atleast 1 fa (des00010), to be reviewed -->
    <!--
    <xsl:template match="ead:ref/@target">
        <xsl:variable name="refmatch" select="//*/@id=."/>
        <xsl:choose>
            <xsl:when test="$refmatch=true()">
                <xsl:attribute name="target">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    -->
    <!-- strip specific bad refids instead -->
    <xsl:template match="ead:ref/@target[.='law00089s1']| ead:ref/@target[.='law00097s8']| ead:ref/@target[.='law00141f1-7']| ead:ref/@target[.='law00164index']| ead:ref/@target[.='law00239f20-30']| ead:ref/@target[.='med00015list']| ead:ref/@target[.='med00016list']| ead:ref/@target[.='med00017list']| ead:ref/@target[.='med00020list']| ead:ref/@target[.='med00031list']| ead:ref/@target[.='med00032list']| ead:ref/@target[.='med00037list']| ead:ref/@target[.='med00038list']| ead:ref/@target[.='med00039list']| ead:ref/@target[.='med00xxxlist']| ead:ref/@target[.='SkipIntro']| ead:ref/@target[.='tar255']| ead:ref/@target[.='tarOnlineIndex']| ead:ref/@target[.='med00018list']| ead:ref/@target[.='med00033list']| ead:ref/@target[.='tarobsolete']"/>    
 

</xsl:stylesheet>
