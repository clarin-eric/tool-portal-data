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
            select="concat(
            'https://tool-portal.clarin.eu/metadata/switchboard/', 
            tokenize($input, '/')[last()])"/>
        <cmd:CMD CMDVersion="1.2"
            xsi:schemaLocation="http://www.clarin.eu/cmd/1 https://infra.clarin.eu/CMDI/1.x/xsd/cmd-envelop.xsd
            http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1747312582452 https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/clarin.eu:cr1:p_1747312582452/xsd">
            <cmd:Header>
                <cmd:MdCreator>Switchboard JSON - CMDI stylesheet (automatic)</cmd:MdCreator>
                <cmd:MdSelfLink><xsl:value-of select="$cmdiSelfLink"/></cmd:MdSelfLink>
                <cmd:MdProfile>clarin.eu:cr1:p_1747312582452</cmd:MdProfile>
            </cmd:Header>
            <cmd:Resources>
                <cmd:ResourceProxyList>
                    <xsl:choose>
                        <xsl:when
                            test="normalize-space(./map[@key = 'webApplication']/string[@key = 'url']) != ''">
                            <cmd:ResourceProxy id="webapp">
                                <cmd:ResourceType>LandingPage</cmd:ResourceType>
                                <cmd:ResourceRef>
                                    <xsl:value-of
                                        select="./map[@key = 'webApplication'][1]/string[@key = 'url'][1]"
                                    />
                                </cmd:ResourceRef>
                            </cmd:ResourceProxy>
                        </xsl:when>
                        <xsl:otherwise>
                            <cmd:ResourceProxy id="switchboard">
                                <cmd:ResourceType>Resource</cmd:ResourceType>
                                <cmd:ResourceRef>
                                    <xsl:value-of
                                        select="concat('https://switchboard.clarin.eu/api/tools/', ./number[@key = 'id'])"
                                    />
                                </cmd:ResourceRef>
                            </cmd:ResourceProxy>
                        </xsl:otherwise>
                    </xsl:choose>
                </cmd:ResourceProxyList>
                <cmd:JournalFileProxyList> </cmd:JournalFileProxyList>
                <cmd:ResourceRelationList> </cmd:ResourceRelationList>
            </cmd:Resources>
            <cmd:Components>
                <GenericToolService>
                    <IdentificationInfo>
                        <xsl:for-each select="./number[@key = 'id']">
                            <identifier>
                                <xsl:value-of
                                    select="concat('https://switchboard.clarin.eu/api/tools/', ./text())"
                                />
                            </identifier>
                            <internalIdentifier>
                                <xsl:value-of select="text()"/>
                            </internalIdentifier>
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

                    <ToolInfo>
                        <xsl:if test="normalize-space(./map[@key = 'webApplication']) != ''">
                            <ToolServiceType>
                                <label>Web application</label>
                            </ToolServiceType>
                        </xsl:if>
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
                                        <name ><xsl:value-of select="."/></name>
                                        <code ><xsl:value-of select="."/></code>
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
                                    <note>Automatically converted from JSON representation
                                        retrieved from the Switchboard tool registry</note>
                                    <When>
                                        <date>
                                            <xsl:value-of select="current-date()"/>
                                        </date>
                                    </When>
                                </ActivityInfo>
                            </Creation>
                            <Publication>
                                <ActivityInfo>
                                    <When>
                                        <label>Unkown</label>
                                    </When>
                                    <Responsible>
                                        <AgentInfo>
                                            <OrganisationInfo>
                                                <name>CLARIN ERIC - Language Resource Switchboard</name>
                                                <ContactInfo>
                                                  <url>https://switchboard.clarin.eu</url>
                                                </ContactInfo>
                                            </OrganisationInfo>
                                        </AgentInfo>
                                    </Responsible>
                                </ActivityInfo>
                            </Publication>
                        </ProvenanceInfo>
                    </MetadataInfo>
                </GenericToolService>
            </cmd:Components>
        </cmd:CMD>
    </xsl:template>
</xsl:stylesheet>
