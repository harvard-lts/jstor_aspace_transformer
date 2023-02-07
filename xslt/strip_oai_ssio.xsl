<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns:ssio="http://catalog.sharedshelf.artstor.org">
	<xsl:output method="xml" version="1.0"/>

	<xsl:template match="/">
		<xsl:copy-of select="oai:record/oai:metadata/ssio:SharedShelf"/>
	</xsl:template>

</xsl:stylesheet>
