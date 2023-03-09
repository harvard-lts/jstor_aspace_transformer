<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	xmlns:ssio="http://catalog.sharedshelf.artstor.org" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xsl:output method="xml" version="1.0"/>

	<xsl:template match="/">
		<xsl:element name="deleteRecordId" inherit-namespaces="no">
			<xsl:value-of select="oai:record/oai:header/oai:identifier"/>
		</xsl:element>
		<!--<xsl:choose>
			<xsl:when test="oai:record/oai:header/@status = 'deleted'">
				<xsl:variable name="harvestdir" as="xs:string">
					<xsl:value-of select="document('harvest.xml')/*/harvestdir"/>
				</xsl:variable>
				<xsl:variable name="deletepath">
					<xsl:value-of select="$harvestdir"/>/DELETES/<xsl:value-of
						select="oai:record/oai:header/oai:identifier"/><xsl:text>.xml</xsl:text>
				</xsl:variable>
				<xsl:result-document href="{$deletepath}" exclude-result-prefixes="#all">
					<deleteRecordId>
						<xsl:value-of select="oai:record/oai:header/oai:identifier"/>
					</deleteRecordId>
				</xsl:result-document>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="oai:record/oai:metadata/ssio:SharedShelf"/>
			</xsl:otherwise>
		</xsl:choose>-->

	</xsl:template>

</xsl:stylesheet>
