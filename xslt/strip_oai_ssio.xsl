<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	xmlns:ssio="http://catalog.sharedshelf.artstor.org" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" version="1.0"/>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="oai:record/oai:header/@status = 'deleted'">
				<xsl:element name="deleteRecordId" inherit-namespaces="no">
					<xsl:value-of select="oai:record/oai:header/oai:identifier"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="oai:record/oai:metadata/ssio:SharedShelf"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

</xsl:stylesheet>