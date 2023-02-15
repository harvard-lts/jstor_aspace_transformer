<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
    xmlns:xlink="http://www.w3.org/TR/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:template match="ssw:Work">
        <xsl:param name="subwork"/>
        <xsl:if test="$subwork = 'true'">
            <xsl:choose>
                <xsl:when test="starts-with(@refid, 'W')">
                    <xsl:attribute name="componentID">
                        <xsl:text>olvwork</xsl:text>
                        <xsl:value-of select="substring-after(@refid, 'W')"/>
                    </xsl:attribute>
                    <xsl:attribute name="altComponentID">
                        <xsl:value-of select="@id"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="componentID">
                        <xsl:value-of select="@id"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:apply-templates select="Titles"/>
        <xsl:apply-templates select="Notes/Note[contains(@type_lkup, 'associated number')]"/>

        <!-- via classification -->
        <xsl:apply-templates select="WorkTypes"/>
        <xsl:apply-templates
            select="
                Agents/Agent[not(@role_lkup = 'owner')
                and not(@role_lkup = 'patron')
                and not(@role_lkup = 'publisher')
                and not(@role_lkup = 'recipient')
                and not(@role_lkup = 'sitter')
                and not(@role_lkup = 'sponsor')
                and not(@role_lkup = 'subject')
                and not(@role_lkup = 'assignee')
                and not(@role_lkup = 'associated name')
                and not(@role_lkup = 'associated names')
                and not(@role_lkup = 'client')
                and not(@role_lkup = 'collector')
                and not(@role_lkup = 'donor')
                and not(@role_lkup = 'dedicatee')
                and not(@role_lkup = 'dedicator')
                and not(@role_lkup = 'funder')
                and not(@role_lkup = 'honoree')
                and not(@role_lkup = 'compiler')]"/>
        <xsl:apply-templates select="Subjects/Subject[@type_lkup = 'creator']"/>
        <xsl:apply-templates select="Locations/Location[@type_lkup = 'creation']"/>
        <xsl:apply-templates select="Locations/Location[@type_lkup = 'publication']"/>
        <xsl:apply-templates select="Dates"/>
        <xsl:apply-templates select="StateEditions"/>

        <xsl:apply-templates select="Descriptions"/>
        <xsl:apply-templates select="Measurements"/>
        <xsl:apply-templates
            select="
                Agents/Agent[@role_lkup = 'owner'
                or @role_lkup = 'patron'
                or @role_lkup = 'publisher'
                or @role_lkup = 'recipient'
                or @role_lkup = 'sitter'
                or @role_lkup = 'sponsor'
                or @role_lkup = 'subject'
                or @role_lkup = 'assignee'
                or @role_lkup = 'associated name'
                or @role_lkup = 'associated names'
                or @role_lkup = 'client'
                or @role_lkup = 'collector'
                or @role_lkup = 'donor'
                or @role_lkup = 'dedicatee'
                or @role_lkup = 'dedicator'
                or @role_lkup = 'funder'
                or @role_lkup = 'honoree'
                or @role_lkup = 'compiler']"/>
        <!-- doing both associated name|s b/c artstor can't seem to decide -->
        <xsl:apply-templates select="Subjects/Subject[@type_lkup = 'associated names']"/>
        <xsl:apply-templates select="Subjects/Subject[@type_lkup = 'associated name']"/>
        <xsl:apply-templates select="Locations/Repository[@type_lkup = 'former repository']"/>
        <xsl:apply-templates select="Locations/PrivateOwner"/>
        <xsl:apply-templates select="Subjects/Subject[@type_lkup = 'associated site']"/>
        <xsl:apply-templates select="Subjects/Subject[@type_lkup = 'Associated site']"/>
        <xsl:apply-templates select="Subjects/Subject[not(@type_lkup)]"/>
        <xsl:apply-templates select="StylePeriods"/>
        <xsl:apply-templates select="Cultures"/>
        <xsl:apply-templates select="Materials"/>
        <xsl:apply-templates select="Techniques"/>
        <xsl:apply-templates select="Notes/Note[@type_lkup = 'materials and techniques']"/>
        <xsl:apply-templates select="Notes/Note" mode="vianotes">
            <xsl:sort data-type="text" select="@type_lkup"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="Inscriptions"/>
        <xsl:apply-templates
            select="Locations/Location[@type_lkup and not(@type_lkup = 'creation') and not(@type_lkup = 'publication')]"/>
        <xsl:apply-templates select="Rights/Right[@type_lkup = 'Copyright']"/>
        <!-- via relatedWork -->
        <xsl:apply-templates select="LocalInformation/RelatedInfo[@type_lkup = 'related work']"/>
        <xsl:apply-templates
            select="LocalInformation/RelatedInfo[@type_lkup = 'related information']"/>
        <xsl:apply-templates select="Rights/Right[@type_lkup = 'Access Restrictions']"/>
        <xsl:apply-templates select="Locations/Repository[not(@type_lkup = 'former repository')]"/>
        <xsl:apply-templates select="display:DR[@sequence > 0]" mode="surrogate">
            <xsl:sort data-type="number" select="@sequence"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="display:DR[@sequence = '0']" mode="surrogate"/>
        <xsl:apply-templates
            select="RelatedWorks[ssw:RelatedWork/@type_lkup = 'Larger context for']"/>
        <xsl:apply-templates
            select="RelatedWorks[ssw:RelatedWork/@type_lkup = 'larger context for']"/>
    </xsl:template>

    <!-- elements to not display -->
    <xsl:template match="aat:AAT | ssn:Name"/>

    <!-- surrogates from display record -->
    <xsl:template match="display:DR" mode="surrogate">

        <xsl:choose>
            <xsl:when test="./@status_lkup = 'Deleted'"> </xsl:when>
            <!-- look for positive occurrences instead 2015-07-29 -->
            <xsl:when
                test="./DisplayRecord/field_boolean[@label = 'Send To Harvard'][@value = true()]">
                <xsl:element name="surrogate">


                    <xsl:if
                        test="DisplayRecord/field_string[@label = 'Olivia ID'][not(@value = 'None') and not(@value = '')]">
                        <xsl:attribute name="altComponentID">
                            <xsl:choose>
                                <xsl:when
                                    test="starts-with(DisplayRecord/field_string[@label = 'Olivia ID']/@value, 'U')">
                                    <xsl:text>olvsurrogate</xsl:text>
                                    <xsl:value-of
                                        select="substring-after(DisplayRecord/field_string[@label = 'Olivia ID']/@value, 'U')"
                                    />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                        select="DisplayRecord/field_string[@label = 'Olivia ID']/@value"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="componentID">
                        <xsl:value-of select="@id"/>
                    </xsl:attribute>

                    <xsl:apply-templates select="Assets"/>
                    <xsl:apply-templates
                        select="DisplayRecord/field_string[@label = 'Image View Description'][not(@value = 'None') and not(normalize-space(@value) = '')]"/>
                    <xsl:apply-templates
                        select="DisplayRecord/field_string[@label = 'Image Classification Number'][not(@value = 'None') and not(normalize-space(@value) = '')]"/>
                    <!-- 2021-02-24 deprecated, now use linkedField/@preferedTerm, Jira SS-55 -->
                    <!--<xsl:apply-templates
                                select="DisplayRecord/field_string[@label = 'Image Type'][not(@value = 'None') and not(normalize-space(@value) = '')]"/>-->
                    <xsl:apply-templates
                        select="DisplayRecord/field_lookup[@label = 'Image Type'][not(normalize-space(display) = '')]"/>
                    <xsl:apply-templates
                        select="DisplayRecord/field_lookup[@label = 'Photographer'][not(normalize-space(display) = '')]"/>
                    <xsl:apply-templates
                        select="DisplayRecord/field_string[@label = 'Image Start Year'][not(@value = 'None') and not(normalize-space(@value) = '')]"/>
                    <xsl:apply-templates
                        select="DisplayRecord/field_string[@label = 'Image Date'][not(@value = 'None') and not(normalize-space(@value) = '')]"/>
                    <xsl:apply-templates
                        select="DisplayRecord/field_string[@label = 'Image Measurements'][not(@value = 'None') and not(normalize-space(@value) = '')]"/>
                    <xsl:if
                        test="
                            DisplayRecord/field_string[@label = 'Image Location Created Latitude'][not(@value = 'None') and not(normalize-space(@value) = '')]
                            or DisplayRecord/field_string[@label = 'Image Location Created Longitude'][not(@value = 'None') and not(normalize-space(@value) = '')]
                            or DisplayRecord/field_string[@label = 'Image Location Created Altitude'][not(@value = 'None') and not(normalize-space(@value) = '')]
                            or DisplayRecord/field_string[@label = 'Image Location Created Bearing'][not(@value = 'None') and not(normalize-space(@value) = '')]">
                        <xsl:variable name="single_quote"><xsl:text>'</xsl:text></xsl:variable>
                        <xsl:element name="coordinates">
                            <xsl:if
                                test="DisplayRecord/field_string[@label = 'Image Location Created Altitude'][not(@value = 'None') and not(normalize-space(@value) = '')]">
                                <xsl:attribute name="altitude">
                                    <xsl:value-of select="replace(DisplayRecord/field_string[@label = 'Image Location Created Altitude']/@value,$single_quote,'')"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:if
                                test="DisplayRecord/field_string[@label = 'Image Location Created Bearing'][not(@value = 'None') and not(normalize-space(@value) = '')]">
                                <xsl:attribute name="decimal">
                                    <xsl:value-of select="replace(DisplayRecord/field_string[@label = 'Image Location Created Bearing']/@value,$single_quote,'')"/>
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:if
                                test="DisplayRecord/field_string[@label = 'Image Location Created Latitude'][not(@value = 'None') and not(normalize-space(@value) = '')]">
                                <xsl:element name="latitude">
                                    <xsl:attribute name="decimal">
                                        <xsl:value-of select="replace(DisplayRecord/field_string[@label = 'Image Location Created Latitude']/@value,$single_quote,'')"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:if>
                            <xsl:if
                                test="DisplayRecord/field_string[@label = 'Image Location Created Longitude'][not(@value = 'None') and not(normalize-space(@value) = '')]">
                                <xsl:element name="longitude">
                                    <xsl:attribute name="decimal">
                                        <xsl:value-of select="replace(DisplayRecord/field_string[@label = 'Image Location Created Longitude']/@value,$single_quote,'')"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:if>
                        </xsl:element>
                    </xsl:if>
                    <xsl:apply-templates
                        select="DisplayRecord/field_lookup[@label = 'Image Associated Name'][not(normalize-space(display) = '')]"/>
                    <xsl:apply-templates
                        select="DisplayRecord/field_lookup[@label = 'Image Subject'][not(normalize-space(display) = '')]"/>
                    <xsl:apply-templates
                        select="DisplayRecord/field_lookup[@label = 'Image Materials'][not(normalize-space(display) = '')]"/>
                    <xsl:apply-templates
                        select="DisplayRecord/field_lookup[@label = 'Image Technique'][not(normalize-space(display) = '')]"/>
                    <xsl:apply-templates
                        select="DisplayRecord/field_string[@label = 'Image Notes'][not(@value = 'None') and not(normalize-space(@value) = '')]"/>
                    <xsl:apply-templates
                        select="DisplayRecord/field_string[@label = 'Image Rights'][not(@value = 'None') and not(normalize-space(@value) = '')]"/>
                    <xsl:apply-templates
                        select="DisplayRecord/field_lookup[@label = 'Image Repository'][not(normalize-space(display) = '')]"
                    />
                </xsl:element>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <!-- surrogate templates -->
    <xsl:template match="field_string[@label = 'Image View Description']">
        <xsl:element name="title">
            <xsl:element name="textElement">
                <xsl:value-of select="@value"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field_string[@label = 'Image Classification Number']">
        <xsl:element name="classification">
            <xsl:element name="number">
                <xsl:value-of select="@value"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- 2021-02-24 deprecated, now use linkedField/@preferedTerm -->
    <!--
    <xsl:template match="field_string[@label = 'Image Type']">
        <xsl:if test="not(normalize-space(@value) = '')">
            <xsl:element name="workType">
                <xsl:value-of select="@value"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    -->

    <xsl:template match="field_lookup[@label = 'Image Type']">
        <xsl:apply-templates select="linkedField" mode="imagetype"/>
    </xsl:template>

    <xsl:template match="linkedField" mode="imagetype">
        <xsl:element name="workType">
            <xsl:value-of select="@preferredTerm"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field_lookup[@label = 'Photographer']">
        <xsl:apply-templates select="linkedField" mode="photographer"/>
    </xsl:template>

    <xsl:template match="linkedField" mode="photographer">
        <xsl:variable name="photogid">
            <xsl:value-of select="@id"/>
        </xsl:variable>
        <xsl:element name="creator">
            <xsl:element name="nameElement">
                <xsl:value-of
                    select="//ssn:Name[@conceptId = $photogid]/Terms/Term[@preferred = 'true']/@name"
                />
            </xsl:element>
            <xsl:apply-templates select="//ssn:Name[@conceptId = $photogid]" mode="namerec"/>
            <xsl:element name="role">
                <xsl:text>photographer</xsl:text>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field_string[@label = 'Image Start Year']">
        <xsl:element name="structuredDate">
            <xsl:element name="beginDate">
                <xsl:value-of select="@value"/>
            </xsl:element>
            <xsl:apply-templates select="../field_string[@label = 'Image End Year']"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field_string[@label = 'Image End Year']">
        <xsl:element name="endDate">
            <xsl:value-of select="@value"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field_string[@label = 'Image Date']">
        <xsl:element name="freeDate">
            <xsl:value-of select="@value"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field_string[@label = 'Image Measurements']">
        <xsl:element name="dimensions">
            <!-- one too many Measurement elements, clean up -->
            <xsl:value-of select="@value"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field_lookup[@label = 'Image Associated Name']">
        <xsl:apply-templates select="linkedField" mode="assocname"/>
    </xsl:template>

    <xsl:template match="linkedField" mode="assocname">
        <xsl:variable name="assocnameid">
            <xsl:value-of select="@id"/>
        </xsl:variable>
        <xsl:element name="associatedName">
            <xsl:element name="nameElement">
                <xsl:value-of
                    select="//ssn:Name[@conceptId = $assocnameid]/Terms/Term[@preferred = 'true']/@name"
                />
            </xsl:element>
            <xsl:apply-templates select="//ssn:Name[@conceptId = $assocnameid]" mode="namerec"/>
            <!--<xsl:element name="role"><xsl:text>photographer</xsl:text></xsl:element>-->
        </xsl:element>
    </xsl:template>

    <xsl:template match="field_lookup[@label = 'Image Subject']">
        <xsl:apply-templates select="linkedField" mode="subject"/>
    </xsl:template>

    <xsl:template match="linkedField" mode="subject">
        <xsl:variable name="linkingid">
            <xsl:value-of select="./@id"/>
        </xsl:variable>
        <xsl:element name="topic">
            <xsl:element name="term">
                <xsl:value-of select="@preferredTerm"/>
            </xsl:element>
            <xsl:apply-templates
                select="//tgn:TGN[tgn:latitude | tgn:longitude | tgn:altitude | tgn:bearing][@subjectId = $linkingid]"
            />
        </xsl:element>
    </xsl:template>

    <xsl:template match="field_lookup[@label = 'Image Materials']">
        <xsl:element name="materials">
            <xsl:value-of select="linkedField/@preferredTerm"/>
            <xsl:apply-templates select="../field_lookup[@label = 'Image Support']"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field_lookup[@label = 'Image Support']">
        <xsl:text> on </xsl:text>
        <xsl:value-of select="linkedField/@preferredTerm"/>
    </xsl:template>

    <xsl:template match="field_lookup[@label = 'Image Technique']">
        <xsl:element name="materials">
            <xsl:value-of select="linkedField/@preferredTerm"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field_string[@label = 'Image Notes']">
        <xsl:element name="notes">
            <xsl:value-of select="@value"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field_string[@label = 'Image Rights']">
        <xsl:element name="copyright">
            <xsl:value-of select="@value"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field_lookup[@label = 'Image Repository']">
        <xsl:variable name="reposid">
            <xsl:value-of select="linkedField/@id"/>
        </xsl:variable>
        <xsl:element name="repository">
            <xsl:element name="repositoryName">
                <xsl:value-of
                    select="//ssn:Name[@conceptId = $reposid][1]/Terms/Term[@preferred = true()]/@name"
                />
            </xsl:element>
            <xsl:apply-templates
                select="../field_string[not(@value = 'None') and not(@value = '') and @label = 'Image Accession Number']"
            />
        </xsl:element>
    </xsl:template>

    <xsl:template match="field_string[@label = 'Image Accession Number']">
        <xsl:element name="number">
            <xsl:value-of select="@value"/>
        </xsl:element>
    </xsl:template>

    <!-- end surrogate templates -->

    <xsl:template match="RelatedWorks[ssw:RelatedWork/@type_lkup = 'Part of']">
        <xsl:apply-templates select="ssw:RelatedWork[@type_lkup = 'Part of']"/>
    </xsl:template>

    <xsl:template match="RelatedWorks[ssw:RelatedWork/@type_lkup = 'part of']">
        <xsl:apply-templates select="ssw:RelatedWork[@type_lkup = 'part of']"/>
    </xsl:template>

    <xsl:template
        match="ssw:RelatedWork[@type_lkup = 'Part of'] | ssw:RelatedWork[@type_lkup = 'part of']">
        <xsl:variable name="getrec">
            <xsl:value-of select="$baseurl"/>
            <xsl:text>?verb=GetRecord&amp;metadataPrefix=oai_ssio&amp;identifier=</xsl:text>
            <!--<xsl:value-of select="@id"/>-->
            <xsl:value-of select="@refid"/>
        </xsl:variable>
        <xsl:element name="recordId">
            <xsl:apply-templates select="document($getrec)//ssw:Work/LocalInformation"/>
        </xsl:element>
        <xsl:element name="group">
            <xsl:apply-templates select="document($getrec)//ssw:Work"/>
        </xsl:element>
    </xsl:template>

    <xsl:template
        match="RelatedWorks[ssw:RelatedWork/@type_lkup = 'Larger context for'] | RelatedWorks[ssw:RelatedWork/@type_lkup = 'larger context for']">
        <xsl:apply-templates select="ssw:RelatedWork[@type_lkup = 'Larger context for']"/>
        <xsl:apply-templates select="ssw:RelatedWork[@type_lkup = 'larger context for']"/>
    </xsl:template>

    <xsl:template
        match="ssw:RelatedWork[@type_lkup = 'Larger context for'] | ssw:RelatedWork[@type_lkup = 'larger context for']">
        <xsl:variable name="getrec">
            <xsl:value-of select="$baseurl"/>
            <xsl:text>?verb=GetRecord&amp;metadataPrefix=oai_ssio&amp;identifier=</xsl:text>
            <!--<xsl:value-of select="@id"/>-->
            <xsl:value-of select="@refid"/>
        </xsl:variable>
        <xsl:element name="subwork">

            <xsl:apply-templates select="document($getrec)//ssw:Work">
                <xsl:with-param name="subwork">true</xsl:with-param>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Assets">
        <xsl:param name="imagecompid"/>
        <xsl:param name="imagealtcompid"/>
        <xsl:if
            test="Asset[@size = 'DRS_full' and not(@id = 'BLANK') and not(../../DisplayRecord/field_boolean[@label = 'In House Use Only'][@value = true()])]">
            <xsl:element name="image">
                <xsl:if test="not($imagecompid = '')">
                    <xsl:attribute name="componentID">
                        <xsl:value-of select="$imagecompid"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="not($imagealtcompid = '')">
                    <xsl:attribute name="altComponentID">
                        <xsl:value-of select="$imagealtcompid"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="Asset/@restriction = 't'">
                    <xsl:attribute name="restrictedImage">true</xsl:attribute>
                </xsl:if>
                <xsl:if test="Asset/@restriction = 'f'">
                    <xsl:attribute name="restrictedImage">false</xsl:attribute>
                </xsl:if>
                <xsl:attribute name="xlink:href">
                    <xsl:value-of select="Asset[@size = 'DRS_full']/@uri"/>
                </xsl:attribute>
                <xsl:if
                    test="../DisplayRecord/field_string[@label = 'Image View Description' and not(@value = 'None') and not(@value = '')]">
                    <xsl:choose>
                        <!-- SS-55
                        <xsl:when
                            test="../DisplayRecord/field_string[not(@value = 'None') and not(@value = '')]/@label = 'Image Type'"/>-->
                        <xsl:when
                            test="../DisplayRecord/field_string[not(@value = 'None') and not(@value = '')]/@label = 'Image View Type'"/>
                        <xsl:when
                            test="../DisplayRecord/field_string[not(@value = 'None') and not(@value = '')]/@label = 'Image Date'"/>
                        <xsl:when
                            test="../DisplayRecord/field_string[not(@value = 'None') and not(@value = '')]/@label = 'Image Start Year'"/>
                        <xsl:when
                            test="../DisplayRecord/field_string[not(@value = 'None') and not(@value = '')]/@label = 'Image End Year'"/>
                        <xsl:when
                            test="../DisplayRecord/field_string[not(@value = 'None') and not(@value = '')]/@label = 'Image Measurements'"/>
                        <xsl:when
                            test="../DisplayRecord/field_string[not(@value = 'None') and not(@value = '')]/@label = 'Image Notes'"/>
                        <xsl:when
                            test="../DisplayRecord/field_string[not(@value = 'None') and not(@value = '')]/@label = 'Image Rights'"/>
                        <xsl:when
                            test="../DisplayRecord/field_string[not(@value = 'None') and not(@value = '')]/@label = 'Image Accession Number'"/>
                        <xsl:when
                            test="../DisplayRecord/field_lookup[not(display = '')]/@label = 'Image Subject'"/>
                        <xsl:when
                            test="../DisplayRecord/field_lookup[not(display = '')]/@label = 'Image Associated Name'"/>
                        <xsl:when
                            test="../DisplayRecord/field_lookup[not(display = '')]/@label = 'Image Materials'"/>
                        <xsl:when
                            test="../DisplayRecord/field_lookup[not(display = '')]/@label = 'Image Support'"/>
                        <xsl:when
                            test="../DisplayRecord/field_lookup[not(display = '')]/@label = 'Image Technique'"/>
                        <!-- SS-55 -->
                        <xsl:when
                            test="../DisplayRecord/field_lookup[not(display = '')]/@label = 'Image Type'"/>
                        <xsl:otherwise>
                            <xsl:element name="caption">
                                <xsl:value-of
                                    select="../DisplayRecord/field_string[@label = 'Image View Description']/@value"
                                />
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>

                <xsl:element name="thumbnail">
                    <xsl:choose>
                        <xsl:when test="Asset[@size = 'DRS_thumb']">
                            <xsl:attribute name="xlink:href">
                                <xsl:value-of select="Asset[@size = 'DRS_thumb']/@uri"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="xlink:href">
                                <xsl:value-of select="Asset[@size = 'DRS_full']/@uri"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="@representationId">
        <xsl:element name="image">
            <xsl:attribute name="xlink:href">
                <xsl:text>http://nrs.harvard.edu/</xsl:text>
                <xsl:value-of select="substring(., 5)"/>
            </xsl:attribute>
            <xsl:element name="thumbnail">
                <xsl:attribute name="xlink:href">
                    <xsl:text>http://nrs.harvard.edu/</xsl:text>
                    <xsl:value-of select="substring(., 5)"/>
                </xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- plural elements -->
    <xsl:template match="Titles">
        <xsl:apply-templates select="Title"/>
    </xsl:template>

    <xsl:template match="WorkTypes">
        <xsl:apply-templates select="WorkType"/>
    </xsl:template>

    <xsl:template match="Dates">
        <xsl:apply-templates select="Date"/>
        <xsl:apply-templates select="Display"/>
    </xsl:template>

    <xsl:template match="StateEditions">
        <xsl:apply-templates select="StateEdition"/>
    </xsl:template>

    <xsl:template match="Descriptions">
        <xsl:apply-templates select="Description"/>
    </xsl:template>

    <xsl:template match="Measurements">
        <xsl:element name="dimensions">
            <xsl:value-of select="Display"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="StylePeriods">
        <xsl:apply-templates select="StylePeriod"/>
    </xsl:template>
    <xsl:template match="Cultures">
        <xsl:apply-templates select="Culture"/>
    </xsl:template>

    <xsl:template match="Materials">
        <xsl:apply-templates
            select="Material[@supporttype_lkup = 'Medium' or @supporttype_lkup = 'medium']"/>
        <xsl:apply-templates
            select="Material[@supporttype_lkup = 'Support' or @supporttype_lkup = 'support']"/>
        <xsl:apply-templates
            select="Material[not(@supporttype_lkup = 'Medium') and not(@supporttype_lkup = 'medium') and not(@supporttype_lkup = 'Support') and not(@supporttype_lkup = 'support')]"
        />
    </xsl:template>

    <xsl:template match="Material[@supporttype_lkup = 'Medium' or @supporttype_lkup = 'medium']">
        <xsl:element name="materials">
            <xsl:value-of select="@term"/>
            <xsl:if test="following-sibling::Material[@supporttype_lkup = 'Support'][1]">
                <xsl:text> on </xsl:text>
                <xsl:value-of
                    select="following-sibling::Material[@supporttype_lkup = 'Support'][1]/@term"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Material[@supporttype_lkup = 'Support' or @supporttype_lkup = 'support']">
        <xsl:if test="not(following-sibling::Material[@supporttype_lkup = 'Material'][1])">
            <xsl:element name="materials">
                <xsl:value-of select="@term"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template
        match="Material[not(@supporttype_lkup = 'Medium') and not(@supporttype_lkup = 'medium') and not(@supporttype_lkup = 'Support') and not(@supporttype_lkup = 'support')]">
        <xsl:element name="materials">
            <xsl:value-of select="@term"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Techniques">
        <xsl:apply-templates select="Technique"/>
    </xsl:template>

    <xsl:template match="ArtstorCountries">
        <xsl:apply-templates select="Country"/>
    </xsl:template>

    <xsl:template match="LocalInformation">
        <xsl:apply-templates select="LocalInfo"/>
    </xsl:template>

    <!-- each singular element from plural elements above individually -->
    <xsl:template match="Title">
        <xsl:element name="title">
            <xsl:choose>
                <xsl:when test="not(@type_lkup)">
                    <!-- no type element -->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="type">
                        <xsl:value-of select="@type_lkup"/>
                        <xsl:text> Title</xsl:text>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:element name="textElement">
                <xsl:value-of select="@term"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="WorkType">
        <xsl:element name="workType">
            <xsl:value-of select="@term"/>
        </xsl:element>
    </xsl:template>

    <xsl:template
        match="
            Agents/Agent[not(@role_lkup = 'owner')
            and not(@role_lkup = 'patron')
            and not(@role_lkup = 'publisher')
            and not(@role_lkup = 'recipient')
            and not(@role_lkup = 'sitter')
            and not(@role_lkup = 'sponsor')
            and not(@role_lkup = 'subject')
            and not(@role_lkup = 'assignee')
            and not(@role_lkup = 'associated name')
            and not(@role_lkup = 'associated names')
            and not(@role_lkup = 'client')
            and not(@role_lkup = 'collector')
            and not(@role_lkup = 'donor')
            and not(@role_lkup = 'dedicatee')
            and not(@role_lkup = 'dedicator')
            and not(@role_lkup = 'funder')
            and not(@role_lkup = 'honoree')
            and not(@role_lkup = 'compiler')]">
        <xsl:variable name="agentid">
            <xsl:value-of select="./@id"/>
        </xsl:variable>
        <xsl:element name="creator">
            <xsl:element name="nameElement">
                <xsl:if test="@attribution">
                    <xsl:value-of select="@attribution"/>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <!--<xsl:value-of select="@term"/>-->
                <xsl:value-of
                    select="//ssn:Name[@conceptId = $agentid]/Terms/Term[@preferred = 'true']/@name"/>
                <xsl:if
                    test="//ssn:Name[@conceptId = $agentid][@recordType = 'CORPORATE BODY']/Events/Event">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of
                        select="//ssn:Name[@conceptId = $agentid][@recordType = 'CORPORATE BODY']/Events/Event/@place"
                    />
                </xsl:if>
            </xsl:element>
            <xsl:apply-templates select="//ssn:Name[@conceptId = $agentid]" mode="namerec"/>
            <xsl:element name="role">
                <xsl:value-of select="@role_lkup"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Subjects/Subject[@type_lkup = 'creator']">
        <xsl:variable name="agentid">
            <xsl:value-of select="./@id"/>
        </xsl:variable>
        <xsl:element name="creator">
            <xsl:element name="nameElement">
                <!--<xsl:value-of select="@term"/>-->
                <xsl:value-of
                    select="//ssn:Name[@conceptId = $agentid]/Terms/Term[@preferred = 'true']/@name"/>
                <xsl:if
                    test="//ssn:Name[@conceptId = $agentid][@recordType = 'CORPORATE BODY']/Events/Event">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of
                        select="//ssn:Name[@conceptId = $agentid][@recordType = 'CORPORATE BODY']/Events/Event/@place"
                    />
                </xsl:if>
            </xsl:element>
            <xsl:apply-templates select="//ssn:Name[@conceptId = $agentid]" mode="namerec"/>
            <xsl:element name="role">
                <xsl:text>subject</xsl:text>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template
        match="
            Agents/Agent[@role_lkup = 'owner'
            or @role_lkup = 'patron'
            or @role_lkup = 'publisher'
            or @role_lkup = 'recipient'
            or @role_lkup = 'sitter'
            or @role_lkup = 'sponsor'
            or @role_lkup = 'subject'
            or @role_lkup = 'assignee'
            or @role_lkup = 'associated name'
            or @role_lkup = 'associated names'
            or @role_lkup = 'client'
            or @role_lkup = 'collector'
            or @role_lkup = 'donor'
            or @role_lkup = 'dedicatee'
            or @role_lkup = 'dedicator'
            or @role_lkup = 'funder'
            or @role_lkup = 'honoree'
            or @role_lkup = 'compiler']">
        <xsl:variable name="agentid">
            <xsl:value-of select="./@id"/>
        </xsl:variable>
        <xsl:element name="associatedName">
            <xsl:element name="nameElement">
                <xsl:if test="@attribution">
                    <xsl:value-of select="@attribution"/>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:value-of
                    select="//ssn:Name[@conceptId = $agentid]/Terms/Term[@preferred = 'true']/@name"/>
                <xsl:if
                    test="//ssn:Name[@conceptId = $agentid][@recordType = 'CORPORATE BODY']/Events/Event">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of
                        select="//ssn:Name[@conceptId = $agentid][@recordType = 'CORPORATE BODY']/Events/Event/@place"
                    />
                </xsl:if>
                <!--<xsl:value-of select="@term"/>-->
            </xsl:element>
            <xsl:apply-templates select="//ssn:Name[@conceptId = $agentid]" mode="namerec"/>
            <xsl:element name="role">
                <!-- shouldn't this be apply templates to avoid empties? -->
                <xsl:value-of select="@role_lkup"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template
        match="Subjects/Subject[@type_lkup = 'associated names'] | Subjects/Subject[@type_lkup = 'associated name']">
        <xsl:variable name="agentid">
            <xsl:value-of select="./@id"/>
        </xsl:variable>
        <xsl:element name="associatedName">
            <xsl:element name="nameElement">
                <!--<xsl:value-of select="@term"/>-->
                <xsl:value-of
                    select="//ssn:Name[@conceptId = $agentid]/Terms/Term[@preferred = 'true']/@name"/>
                <xsl:if
                    test="//ssn:Name[@conceptId = $agentid][@recordType = 'CORPORATE BODY']/Events/Event">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of
                        select="//ssn:Name[@conceptId = $agentid][@recordType = 'CORPORATE BODY']/Events/Event/@place"
                    />
                </xsl:if>
            </xsl:element>
            <xsl:element name="role">
                <xsl:text>subject</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="//ssn:Name[@conceptId = $agentid]" mode="namerec"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="PrivateOwner">
        <xsl:variable name="agentid">
            <xsl:value-of select="./@id"/>
        </xsl:variable>
        <xsl:element name="associatedName">
            <xsl:element name="nameElement">
                <xsl:value-of
                    select="//ssn:Name[@conceptId = $agentid]/Terms/Term[@preferred = 'true']/@name"/>
                <xsl:if
                    test="//ssn:Name[@conceptId = $agentid][@recordType = 'CORPORATE BODY']/Events/Event">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of
                        select="//ssn:Name[@conceptId = $agentid][@recordType = 'CORPORATE BODY']/Events/Event/@place"
                    />
                </xsl:if>
            </xsl:element>
            <xsl:apply-templates select="//ssn:Name[@conceptId = $agentid]" mode="namerec"/>
            <xsl:element name="role">
                <xsl:value-of select="@type_lkup"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template
        match="Subjects/Subject[@type_lkup = 'associated site'] | Subjects/Subject[@type_lkup = 'Associated site']">
        <xsl:variable name="linkingid">
            <xsl:value-of select="./@id"/>
        </xsl:variable>
        <xsl:element name="placeName">
            <xsl:element name="place">
                <xsl:value-of select="@term"/>
            </xsl:element>
            <xsl:apply-templates
                select="//tgn:TGN[tgn:latitude | tgn:longitude | tgn:altitude | tgn:bearing][@subjectId = $linkingid]"
            />
        </xsl:element>
    </xsl:template>

    <xsl:template match="ssn:Name" mode="namerec">
        <xsl:apply-templates select="Biographies"/>
        <!--<xsl:apply-templates select="Nationalities"/>-->
    </xsl:template>

    <xsl:template match="Biographies">
        <xsl:if test="Biography/@name">
            <xsl:element name="dates">
                <xsl:value-of select="Biography[@preferred = 'true']/@name"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="Nationalities">
        <xsl:apply-templates select="Nationality[@preferred = 'true']"/>
        <xsl:apply-templates select="Nationality[not(@preferred = 'true')]"/>
    </xsl:template>

    <xsl:template match="Nationality">
        <xsl:element name="nationality">
            <xsl:value-of select="./@name"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Date">
        <xsl:if test="@startDate and not(@startDate = '')">
            <xsl:element name="structuredDate">
                <xsl:apply-templates select="@startDate"/>
                <xsl:apply-templates select="@endDate"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="StateEdition">
        <xsl:element name="state">
            <xsl:value-of select="./@description"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Display">
        <xsl:element name="freeDate">
            <xsl:value-of select="."/>
            <!-- ? -->
        </xsl:element>
    </xsl:template>

    <xsl:template match="Description">
        <xsl:element name="description">
            <xsl:value-of select="@term"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Measurement">
        <xsl:element name="dimensions">
            <!-- one too many Measurement elements, clean up -->
            <xsl:value-of select="Measurement/@term"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@startDate">
        <xsl:element name="beginDate">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@endDate">
        <xsl:element name="endDate">
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Subjects/Subject[not(@type_lkup)]">
        <!-- don't forget source -->
        <xsl:element name="topic">
            <xsl:element name="term">
                <xsl:value-of select="@term"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="StylePeriod">
        <!-- don't forget source -->
        <xsl:element name="style">
            <xsl:element name="term">
                <xsl:value-of select="@term"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Culture">
        <!-- don't forget source -->
        <xsl:element name="culture">
            <xsl:element name="term">
                <xsl:value-of select="@term"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Material">
        <!-- support -->
        <xsl:element name="materials">
            <xsl:if test="@supporttype_lkup = 'Medium'">
                <xsl:value-of select="@term"/>
            </xsl:if>
            <xsl:if test="@supporttype_lkup = 'Support'">
                <xsl:text> on </xsl:text>
                <xsl:value-of select="@term"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Technique">
        <xsl:element name="materials">
            <xsl:value-of select="@term"/>
        </xsl:element>
    </xsl:template>


    <xsl:template match="Notes/Note" mode="vianotes">
        <!-- prefixes? -->
        <xsl:if
            test="not(contains(@type_lkup, 'associated number')) and not(@type_lkup = 'materials and techniques') and not(@type_lkup = 'In House Notes') and not(@type_lkup = 'Formats Available')">
            <xsl:element name="notes">
                <xsl:value-of select="upper-case(substring(@type_lkup, 1, 1))"/>
                <xsl:value-of select="substring(@type_lkup, 2)"/>
                <xsl:text>: </xsl:text>
                <xsl:value-of select="@term"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="Inscriptions">
        <xsl:apply-templates select="Inscription"/>
    </xsl:template>

    <xsl:template match="Inscription">
        <xsl:element name="notes">
            <xsl:text>Inscription: </xsl:text>
            <xsl:value-of select="ssw:Inscribe/@term"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tgn:TGN">
        <xsl:element name="coordinates">
            <xsl:apply-templates select="tgn:latitude"/>
            <xsl:apply-templates select="tgn:longitude"/>
            <xsl:apply-templates select="tgn:altitude"/>
            <xsl:apply-templates select="tgn:bearing"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tgn:latitude | tgn:longitude | tgn:altitude | tgn:bearing">
        <xsl:element name="{local-name()}">
            <xsl:if test="@decimal">
                <xsl:attribute name="decimal">
                    <xsl:value-of select="@decimal"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@degree">
                <xsl:attribute name="degree">
                    <xsl:value-of select="@degree"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@minute">
                <xsl:attribute name="minute">
                    <xsl:value-of select="@minute"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@second">
                <xsl:attribute name="second">
                    <xsl:value-of select="@second"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@direction">
                <xsl:attribute name="direction">
                    <xsl:value-of select="@direction"/>
                </xsl:attribute>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Notes/Note[contains(@type_lkup, 'associated number')]">
        <!-- prefixes? -->
        <xsl:element name="itemIdentifier">
            <xsl:element name="number">
                <xsl:value-of select="@term"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Notes/Note[@type_lkup = 'materials and techniques']">
        <!-- prefixes? -->
        <xsl:element name="materials">
            <xsl:value-of select="@term"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="Country">
        <xsl:variable name="linkingid">
            <xsl:value-of select="./@id"/>
        </xsl:variable>
        <xsl:element name="location">
            <xsl:apply-templates
                select="//tgn:TGN[tgn:latitude | tgn:longitude | tgn:altitude | tgn:bearing][@subjectId = $linkingid]"/>
            <!--<xsl:element name="geodata">
                <xsl:element name="country">
                    <xsl:value-of select="@term_lkup"/>
                </xsl:element>
            </xsl:element>-->
        </xsl:element>
    </xsl:template>

    <xsl:template match="Right">
        <xsl:choose>
            <xsl:when test="@type_lkup = 'Copyright'">
                <xsl:element name="copyright">
                    <xsl:value-of select="@term"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="@type_lkup = 'Access Restrictions'">
                <xsl:element name="useRestrictions">
                    <xsl:value-of select="replace(//Locations/Repository/@term, ' / ', '/')"/>
                    <xsl:text>: </xsl:text>
                    <xsl:value-of select="@term"/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template
        match="Locations/Location[@type_lkup and not(@type_lkup = 'creation') and not(@type_lkup = 'publication')]">
        <xsl:variable name="linkingid">
            <xsl:value-of select="./@id"/>
        </xsl:variable>
        <xsl:element name="location">
            <xsl:element name="type">
                <xsl:value-of select="@type_lkup"/>
            </xsl:element>
            <xsl:element name="place">
                <xsl:value-of select="@term"/>
            </xsl:element>
            <xsl:apply-templates
                select="//tgn:TGN[tgn:latitude | tgn:longitude | tgn:altitude | tgn:bearing][@subjectId = $linkingid]"
            />
        </xsl:element>
    </xsl:template>

    <xsl:template
        match="Locations/Location[@type_lkup = 'creation'] | Locations/Location[@type_lkup = 'publication']">
        <xsl:variable name="linkingid">
            <xsl:value-of select="./@id"/>
        </xsl:variable>
        <xsl:element name="production">
            <xsl:element name="placeOfProduction">
                <xsl:element name="place">
                    <xsl:value-of select="@term"/>
                </xsl:element>
                <xsl:apply-templates
                    select="//tgn:TGN[tgn:latitude | tgn:longitude | tgn:altitude | tgn:bearing][@subjectId = $linkingid]"
                />
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="RelatedInfo">
        <xsl:choose>
            <xsl:when test="@type_lkup = 'related information'">
                <xsl:element name="relatedInformation">
                    <xsl:attribute name="xlink:href">
                        <xsl:value-of select="@term"/>
                    </xsl:attribute>
                    <xsl:value-of select="@description"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="@type_lkup = 'related work'">
                <xsl:element name="relatedWork">
                    <xsl:if test="@relType_lkup">
                        <xsl:element name="relationship">
                            <xsl:value-of select="@relType_lkup"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:element name="textElement">
                        <xsl:value-of select="@description"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="Repository[not(@type_lkup = 'former repository')]">
        <xsl:variable name="repositoryid">
            <xsl:value-of select="./@id"/>
        </xsl:variable>
        <xsl:element name="repository">
            <xsl:element name="repositoryName">
                <xsl:value-of
                    select="//ssn:Name[@conceptId = $repositoryid][1]/Terms/Term[@preferred = 'true']/@name"/>
                <xsl:if
                    test="//ssn:Name[@conceptId = $repositoryid][@recordType = 'CORPORATE BODY']/Events/Event">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of
                        select="//ssn:Name[@conceptId = $repositoryid][@recordType = 'CORPORATE BODY']/Events/Event/@place"
                    />
                </xsl:if>
                <!--<xsl:value-of select="//ssn:Name[@conceptId=$repositoryid]/Nationalities/Nationality[@preferred='true']/@name"/>-->
            </xsl:element>
            <xsl:apply-templates select="ssw:RefIdDetail"/>
        </xsl:element>
    </xsl:template>


    <xsl:template match="Repository[@type_lkup = 'former repository']">
        <xsl:variable name="agentid">
            <xsl:value-of select="./@id"/>
        </xsl:variable>
        <xsl:element name="associatedName">
            <xsl:element name="nameElement">
                <xsl:value-of
                    select="//ssn:Name[@conceptId = $agentid]/Terms/Term[@preferred = 'true']/@name"/>
                <xsl:if
                    test="//ssn:Name[@conceptId = $agentid][@recordType = 'CORPORATE BODY']/Events/Event">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of
                        select="//ssn:Name[@conceptId = $agentid][@recordType = 'CORPORATE BODY']/Events/Event/@place"
                    />
                </xsl:if>
            </xsl:element>
            <xsl:apply-templates select="//ssn:Name[@conceptId = $agentid]" mode="namerec"/>
            <xsl:element name="role">
                <xsl:value-of select="@type_lkup"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="ssw:RefIdDetail">
        <xsl:if test="not(@type_lkup = 'accession date')">
            <xsl:element name="number">
                <xsl:value-of select="@term"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
