<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/TR/xlink"
    xmlns:ino="http://namespaces.softwareag.com/tamino/response2" exclude-result-prefixes="xs ino"
    version="2.0">

    <xsl:output method="xml" omit-xml-declaration="yes" encoding="utf-8" indent="yes"/>

    <!-- Identity template : copy all text nodes, elements and attributes -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@* | node()" mode="oneimage">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- When matching DataSeriesBodyType: do nothing -->
    <xsl:template match="viaRecord">
        <xsl:element name="ino:object" inherit-namespaces="no">
            <xsl:copy>
                <xsl:variable name="numImg">
                    <xsl:value-of select="count(.//image)"/>
                </xsl:variable>
                <xsl:variable name="numSub">
                    <xsl:value-of select="count(.//subwork)"/>
                </xsl:variable>
                <xsl:variable name="numSur">
                    <xsl:value-of select="count(.//surrogate)"/>
                </xsl:variable>
                <xsl:attribute name="images">
                    <xsl:choose>
                        <xsl:when test="$numImg > 0">
                            <xsl:text>true</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>false</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="numberOfImages">
                    <xsl:value-of select="$numImg"/>
                </xsl:attribute>
                <xsl:attribute name="numberOfSubworks">
                    <xsl:value-of select="$numSub"/>
                </xsl:attribute>
                <xsl:attribute name="numberOfSurrogates">
                    <xsl:value-of select="$numSur"/>
                </xsl:attribute>
                <xsl:attribute name="sortTitle">
                    <xsl:value-of select="./*/title[1]/textElement"/>
                </xsl:attribute>
                <xsl:apply-templates select="@* | node()"/>
            </xsl:copy>
        </xsl:element>
    </xsl:template>

    <xsl:template match="work">
        <xsl:variable name="numComponents">
            <xsl:value-of select="count(./image) + count(./surrogate)"/>
        </xsl:variable>
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="$numComponents = 1 and count(./image) &lt; 2">
                    <xsl:apply-templates select="@* | node()" mode="oneimage"/>
                </xsl:when>
                <xsl:when test="$numComponents = 1 and count(./image) = 0">
                    <xsl:apply-templates select="@* | node()" mode="oneimage"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="image" mode="oneimage">
        <xsl:copy>
            <xsl:apply-templates select="@* except (@xlink:show, @xlink:actuate) | node()"
                mode="oneimage"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="thumbnail" mode="oneimage">
        <xsl:copy>
            <xsl:apply-templates select="@* except (@xlink:show, @xlink:actuate) | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="surrogate[parent::work]" mode="oneimage">
        <xsl:element name="hvd_componentID">
            <xsl:value-of select="@componentID"/>
        </xsl:element>
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="image[parent::work]">
        <xsl:element name="component">
            <xsl:attribute name="componentID">
                <xsl:value-of select="@componentID"/>
            </xsl:attribute>
            <xsl:copy>
                <xsl:copy-of select="@* | node()"/>
            </xsl:copy>
        </xsl:element>
    </xsl:template>

    <xsl:template match="surrogate[parent::work]">
        <xsl:element name="component">
            <xsl:attribute name="componentID">
                <xsl:value-of select="@componentID"/>
            </xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="group">
        <xsl:element name="work">
            <!--<xsl:variable name="numComponents">
                <xsl:value-of
                    select="count(./image) + count(./subwork[not(surrogate)]) + count(./surrogate) + count(subwork/surrogate)"
                />
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$numComponents &lt; 2">
                    <xsl:copy-of select="@* | node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:otherwise>
            </xsl:choose>-->
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="subwork">
        <xsl:apply-templates select="image | surrogate"/>
    </xsl:template>

    <xsl:template match="image[parent::subwork]">
        <xsl:element name="component">
            <xsl:attribute name="componentID">
                <xsl:value-of select="@componentID"/>
            </xsl:attribute>
            <xsl:copy>
                <xsl:copy-of select="@* | node()"/>
            </xsl:copy>
            <xsl:apply-templates select="../*[not(self::image) and not(self::surrogate)]"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="surrogate[parent::subwork]">
        <xsl:element name="component">
            <xsl:attribute name="componentID">
                <xsl:value-of select="@componentID"/>
            </xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
            <!--<xsl:copy-of select="../*[not(self::surrogate)]"/>-->
            <xsl:apply-templates
                select="parent::subwork/*[not(name() = 'surrogate') and not(name() = 'image')]"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="image[parent::group]">
        <xsl:element name="component">
            <xsl:attribute name="componentID">
                <xsl:value-of select="@componentID"/>
            </xsl:attribute>
            <xsl:copy>
                <xsl:copy-of select="@* | node()"/>
            </xsl:copy>
        </xsl:element>
    </xsl:template>

    <xsl:template match="surrogate[parent::group]">
        <xsl:element name="component">
            <xsl:attribute name="componentID">
                <xsl:value-of select="@componentID"/>
            </xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[not(name() = 'image')][parent::surrogate]">
        <xsl:variable name="elemName">
            <xsl:text>hvd_</xsl:text>
            <xsl:value-of select="name()"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$elemName = 'hvd_classification'">
                <xsl:choose>
                    <xsl:when test="./number = //viaRecord/work/repository/number"/>
                    <xsl:otherwise>
                        <xsl:element name="{$elemName}">
                            <xsl:apply-templates select="@* | node()"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$elemName = 'hvd_repository'">
                <xsl:choose>
                    <xsl:when test="./repositoryName = //viaRecord/work/repository/repositoryName"/>
                    <xsl:otherwise>
                        <xsl:element name="{$elemName}">
                            <xsl:apply-templates select="@* | node()"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{$elemName}">
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>


    </xsl:template>

    <xsl:template match="relatedInformation">
        <xsl:choose>
            <xsl:when test="@xlink:href = ''">
                <xsl:element name="note">
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:element name="link">
                        <xsl:value-of select="@xlink:href"/>
                    </xsl:element>
                    <xsl:element name="text">
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="relatedInformation" mode="oneimage">
        <xsl:choose>
            <xsl:when test="@xlink:href = ''">
                <xsl:element name="note">
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:element name="link">
                        <xsl:value-of select="@xlink:href"/>
                    </xsl:element>
                    <xsl:element name="text">
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="admin"/>

</xsl:stylesheet>
