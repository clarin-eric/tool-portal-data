<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:cmd="http://www.clarin.eu/cmd/1"
    xmlns:cmdp="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1747312582452"
    xmlns="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1747312582452" version="3.0"
    xpath-default-namespace="http://www.w3.org/2005/xpath-functions">

    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:param name="input"/>
    <xsl:output method="xml" indent="true"/>

    <xsl:template name="xsl:initial-template">
        <xsl:variable name="input-as-xml" select="json-to-xml(unparsed-text($input))"/>
        <xsl:apply-templates select="$input-as-xml"/>
    </xsl:template>

    <xsl:template match="map">
        <!-- TODO: more accurate (instead of just unique) selflink -->
        <xsl:variable name="cmdiSelfLink"
            select="
                concat(
                'https://tool-portal.clarin.eu/metadata/codemeta/',
                tokenize($input, '/')[last()])"/>
        <cmd:CMD CMDVersion="1.2"
            xsi:schemaLocation="http://www.clarin.eu/cmd/1 https://infra.clarin.eu/CMDI/1.x/xsd/cmd-envelop.xsd
            http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1747312582452 https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/clarin.eu:cr1:p_1747312582452/xsd">
            <cmd:Header>
                <cmd:MdCreator>Codemeta JSON - CMDI stylesheet (automatic)</cmd:MdCreator>
                <cmd:MdSelfLink>
                    <xsl:value-of select="$cmdiSelfLink"/>
                </cmd:MdSelfLink>
                <cmd:MdProfile>clarin.eu:cr1:p_1747312582452</cmd:MdProfile>
            </cmd:Header>
            <cmd:Resources>
                <cmd:ResourceProxyList>
                    <xsl:for-each select="./string[@key = 'url']">
                        <cmd:ResourceProxy>
                            <xsl:attribute name="id">url_<xsl:value-of select="position()"
                                /></xsl:attribute>
                            <cmd:ResourceType>LandingPage</cmd:ResourceType>
                            <cmd:ResourceRef>
                                <xsl:value-of select="text()"/>
                            </cmd:ResourceRef>
                        </cmd:ResourceProxy>
                    </xsl:for-each>
                    <xsl:for-each select="./string[@key = 'sameAs']">
                        <cmd:ResourceProxy>
                            <xsl:attribute name="id">sameAs_<xsl:value-of select="position()"
                                /></xsl:attribute>
                            <cmd:ResourceType>Resource</cmd:ResourceType>
                            <cmd:ResourceRef>
                                <xsl:value-of select="text()"/>
                            </cmd:ResourceRef>
                        </cmd:ResourceProxy>
                    </xsl:for-each>
                    <xsl:for-each select="./string[@key = 'downloadUrl']">
                        <cmd:ResourceProxy>
                            <xsl:attribute name="id">download_<xsl:value-of select="position()"
                                /></xsl:attribute>
                            <cmd:ResourceType>Resource</cmd:ResourceType>
                            <cmd:ResourceRef>
                                <xsl:value-of select="text()"/>
                            </cmd:ResourceRef>
                        </cmd:ResourceProxy>
                    </xsl:for-each>
                </cmd:ResourceProxyList>
                <cmd:JournalFileProxyList> </cmd:JournalFileProxyList>
                <cmd:ResourceRelationList> </cmd:ResourceRelationList>
            </cmd:Resources>
            <cmd:Components>
                <GenericToolService>
                    <IdentificationInfo>
                        <xsl:for-each select="./string[@key = '@id']">
                            <identifier>
                                <xsl:value-of select="text()"/>
                            </identifier>
                        </xsl:for-each>
                        <xsl:for-each select="./string[@key = 'sameAs']">
                            <alternativeIdentifier>
                                <xsl:value-of select="text()"/>
                            </alternativeIdentifier>
                        </xsl:for-each>
                    </IdentificationInfo>

                    <TitleInfo>
                        <xsl:for-each select="./string[@key = 'name']">
                            <title>
                                <xsl:value-of select="text()"/>
                            </title>
                        </xsl:for-each>
                    </TitleInfo>
                    <Description>
                        <xsl:for-each select="./string[@key = 'description']">
                            <description>
                                <xsl:value-of select="text()"/>
                            </description>
                        </xsl:for-each>
                    </Description>
                    
                    <xsl:for-each select="array[@key = 'author']/map">
                        <!-- TODO: lookup by ID? -->
                        <xsl:variable name="creatorName" select="concat(concat(./string[@key = 'familyName'][1], ', '), ./string[@key = 'givenName'][1])"/>
                        <Creator>
                            <xsl:for-each select="./string[@key = '@id' and not(starts-with(text(), '_'))]">
                                <identifier><xsl:value-of select="text()"/></identifier>
                            </xsl:for-each>
                            <xsl:for-each select="./string[@key = 'sameAs']">
                                <identifier><xsl:value-of select="text()"/></identifier>
                            </xsl:for-each>
                            
                            <!-- TODO: sameAs -->
                            <label><xsl:value-of select="$creatorName"/></label>
                            <role>author</role>
                            <AgentInfo>
                                <PersonInfo>
                                    <name><xsl:value-of select="$creatorName"/></name>
                                    <alternativeName><xsl:value-of select="concat(concat(./string[@key = 'givenName'], ' '), ./string[@key = 'familyName'])"/></alternativeName>
                                </PersonInfo>
                            </AgentInfo>
                        </Creator>
                    </xsl:for-each>
                    <ToolInfo>
                        <xsl:for-each select="array[@key = 'applicationCategory']/string">
                            <ToolServiceType>
                                <identifier>
                                    <xsl:value-of select="."/>
                                </identifier>
                                <!-- TODO: look up label? -->
                                <xsl:choose>
                                    <xsl:when test="matches(text(), 'http.*#.*')">
                                        <label>
                                            <xsl:value-of select="replace(text(), '.*#(.*)$', '$1')"/>
                                        </label>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <label>
                                            <xsl:value-of select="."/>
                                        </label>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </ToolServiceType>
                        </xsl:for-each>
                        <xsl:for-each select="./string[@key = 'task']">
                            <TaskType>
                                <label>
                                    <xsl:value-of select="./text()"/>
                                </label>
                            </TaskType>
                        </xsl:for-each>
                        <xsl:if test="./array[@key = 'languages']">
                            <LanguageSupport>
                                <InputLanguages>
                                    <xsl:for-each select="./array[@key = 'languages']/string">
                                        <Language>
                                            <name>
                                                <xsl:value-of select="."/>
                                            </name>
                                            <code>
                                                <xsl:value-of select="."/>
                                            </code>
                                        </Language>
                                    </xsl:for-each>
                                </InputLanguages>
                            </LanguageSupport>
                        </xsl:if>
                    </ToolInfo>

                    <MetadataInfo>
                        <ProvenanceInfo>
                            <Creation>
                                <ActivityInfo>
                                    <method>Conversion to CMDI</method>
                                    <note>Automatically converted from the Codemeta record for this
                                        item</note>
                                    <When>
                                        <date>
                                            <xsl:value-of select="current-date()"/>
                                        </date>
                                    </When>
                                </ActivityInfo>
                            </Creation>
                        </ProvenanceInfo>
                    </MetadataInfo>
                </GenericToolService>
            </cmd:Components>
        </cmd:CMD>
    </xsl:template>
</xsl:stylesheet>
