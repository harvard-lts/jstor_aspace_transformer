<?xml version="1.0" encoding="UTF-8"?>
<!--
   This version of ssio2via is for full harvest, 
   as opposed to ssio2via.xsl, which is used for nightly harvests. 
   The difference is that the latter will look up group recs for recs 
   that contain "Part of" related works, and write those separately 
   as a result document, under the group record name, 
   in addition to the normal xsl transform of this "part of" records. 
   This is because SS doesn't ensure that the grop record (and other sibling parts of) 
   will get datestamped for harvest, so we must do manually. 
   This is not necessary for full harvests, because we know all records 
   will be harvested. 
 -->    
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:ssio="http://catalog.sharedshelf.artstor.org"
    xmlns:aat="http://catalog.sharedshelf.artstor.org/aat"
    xmlns:tgn="http://catalog.sharedshelf.artstor.org/tgn"
    xmlns:display="http://catalog.sharedshelf.artstor.org/display"
    xmlns:ns0="http://www.w3.org/2001/XML_Schema-instance"
    xmlns:ssc="http://catalog.sharedshelf.artstor.org/ssc"
    xmlns:ssd="http://catalog.sharedshelf.artstor.org/ssd"
    xmlns:ssn="http://catalog.sharedshelf.artstor.org/ssn"
    xmlns:ssw="http://catalog.sharedshelf.artstor.org/ssw"
    xmlns:ssw_lkup="http://catalog.sharedshelf.artstor.org/ssw_lkup"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns:xlink="http://www.w3.org/TR/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema">

    <xsl:output method="xml" version="1.0" omit-xml-declaration="yes" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>

    <xsl:variable name="baseurl" as="xs:string">
        <xsl:value-of select="document('harvest.xml')/*/baseurl"/>
    </xsl:variable>
    <xsl:variable name="harvestdir" as="xs:string">
        <xsl:value-of select="document('harvest.xml')/*/harvestdir"/>
    </xsl:variable>

    <xsl:variable name="ssid">
        <xsl:value-of select="//ssw:Work/@id"/>
    </xsl:variable>

    <xsl:template match="deleteRecordId">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="ssio:SharedShelf">
        <xsl:variable name="displaycount">
            <xsl:value-of select="count(//display:DR)"/>

        </xsl:variable>
        <xsl:variable name="deletecount">
            <xsl:value-of select="count(//display:DR[@status_lkup = 'Deleted'])"/>
        </xsl:variable>
        <xsl:variable name="sendcount">
            <xsl:value-of
                select="count(//display:DR/DisplayRecord/field_boolean[@label = 'Send To Harvard'][@value = true()])"
            />
        </xsl:variable>

        <xsl:choose>
            <!--<xsl:when test="$displaycount = $deletecount"/>
            <xsl:when test="$sendcount = 0"/>-->

            <xsl:when test="$displaycount = $deletecount">
                <xsl:element name="deleteRecordId" inherit-namespaces="no">
                    <xsl:apply-templates select="ssw:Work/LocalInformation"/>
                </xsl:element>
            </xsl:when>
            <!-- it is difficult to determine when a rec has already been loaded and should be deleted, or is a first time rec, 
                and should never be sent. So we just always create a delete record; trying to delete something in via that doesn't exist
                is how we handled olivia loads, no damage done
            -->
            <xsl:when test="$sendcount = 0">
                <xsl:element name="deleteRecordId" inherit-namespaces="no">
                    <xsl:apply-templates select="ssw:Work/LocalInformation"/>
                </xsl:element>
            </xsl:when>

            <xsl:when test="not(ssw:Work)">
                <xsl:element name="dropRecordId" inherit-namespaces="no">
                    <xsl:value-of select="display:DR/@id"/>
                </xsl:element>
            </xsl:when>

            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when
                        test="ssw:Work/RelatedWorks/ssw:RelatedWork[lower-case(@type_lkup) = 'part of'] and ssw:Work/display:DR/DisplayRecord/field_boolean[@label = 'Export Only In Group'][@value = true()]"/>
                    <xsl:when test="not(ssw:Work)"/>
                    <xsl:otherwise>
                        <xsl:element name="viaRecord">
                            <xsl:attribute name="originalAtHarvard">
                                <!--<xsl:variable name="originalAtHarvardFilename">
                                    <xsl:value-of select="$harvestdir"/>
                                    <xsl:text>/originalAtHarvard.xml</xsl:text>
                                </xsl:variable>
                                <xsl:variable name="originalAtHarvard"
                                    select="document($originalAtHarvardFilename)"/>-->
                                <xsl:variable name="originalAtHarvard"
                                    select="document('originalAtHarvard.xml')"/>
                                <xsl:choose>
                                    <xsl:when
                                        test="$originalAtHarvard/ids/id = ssw:Work/Locations/Repository/@id">
                                        <xsl:text>true</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>false</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:apply-templates
                                select="ssw:Work/display:DR[@primary = 'true']/Assets/Asset[@size = 'DRS_thumb']"
                                mode="primaryThumb"/>
                            <xsl:choose>
                                <xsl:when
                                    test="ssw:Work/RelatedWorks/ssw:RelatedWork[lower-case(@type_lkup) = 'larger context for']">
                                    <xsl:element name="recordId">
                                        <xsl:apply-templates select="ssw:Work/LocalInformation"/>
                                    </xsl:element>
                                    <xsl:element name="group">
                                        <xsl:apply-templates select="ssw:Work"/>
                                    </xsl:element>
                                </xsl:when>
                                <!--<xsl:when test="ssw:Work/RelatedWorks/ssw:RelatedWork[@type_lkup='Part of'] and ssw:Work/display:DR/DisplayRecord/field_boolean[@label='Export Only In Group'][@value=true()]">
                            <xsl:apply-templates select="ssw:Work/RelatedWorks/ssw:RelatedWork[@type_lkup='Part of']"/>
                        </xsl:when> -->
                                <xsl:otherwise>
                                    <xsl:element name="recordId">
                                        <xsl:apply-templates select="ssw:Work/LocalInformation"/>
                                    </xsl:element>
                                    <xsl:element name="work">
                                        <xsl:apply-templates select="ssw:Work"/>
                                    </xsl:element>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:variable name="earliest">
                                <xsl:for-each
                                    select="ssw:Work/display:DR[not(@status_lkup = 'Deleted')]">
                                    <xsl:sort select="@createdDate" order="ascending"/>
                                    <xsl:if test="position() = 1">
                                        <xsl:value-of select="substring-before(@createdDate, 'T')"/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:element name="admin">
                                <xsl:element name="createDate">
                                    <xsl:value-of select="$earliest"/>
                                </xsl:element>
                                <xsl:element name="updateNote">
                                    <xsl:element name="updateDate">
                                        <xsl:value-of select="ssw:Work/@lastUpdateDate"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="ssw:Work/LocalInformation">
        <xsl:choose>
            <xsl:when test="matches(@legacyId, '^[GWS][0-9]+') or starts-with(@legacyId, 'JPCD')">
                <xsl:attribute name="altRecordId">
                    <xsl:text>ss_</xsl:text>
                    <xsl:value-of select="../@id"/>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="starts-with(@legacyId, 'W')">
                        <xsl:text>olvwork</xsl:text>
                        <xsl:value-of select="substring-after(@legacyId, 'W')"/>
                        <!-- 20131104 for testing only -->
                        <!--<xsl:text>_ss</xsl:text>-->
                    </xsl:when>
                    <xsl:when test="starts-with(@legacyId, 'G')">
                        <xsl:text>olvgroup</xsl:text>
                        <xsl:value-of select="substring-after(@legacyId, 'G')"/>
                        <!-- 20131104 for testing only -->
                        <!--<xsl:text>_ss</xsl:text>-->
                    </xsl:when>
                    <xsl:when test="starts-with(@legacyId, 'S')">
                        <xsl:text>olvsite</xsl:text>
                        <xsl:value-of select="substring-after(@legacyId, 'S')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@legacyId"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="../@id"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="ssw:Work/display:DR[@primary = 'true']/Assets/Asset[@size = 'DRS_thumb']"
        mode="primaryThumb">
        <xsl:attribute name="primaryImageThumbnailURN">
            <xsl:value-of select="@uri"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="oai:header"/>

    <!-- all template matches are now included from the xsl below -->
    <xsl:include href="ssio2viaTemplates.xsl"/>

</xsl:stylesheet>
