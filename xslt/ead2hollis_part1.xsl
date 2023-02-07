<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink">
    
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    
    <!-- Identity template : copy all text nodes, elements and attributes -->   
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
    <!-- When matching DataSeriesBodyType: do nothing -->
    <xsl:template match="ead:head|ead:unitid|ead:container|ead:daodesc"/>
    
</xsl:stylesheet>