<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:cmd="http://www.clarin.eu/cmd/1"
    xmlns:cmdp="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1747312582452"
    xmlns:conversion="http://toolportal.clarin.eu/conversion/codemeta"
    xmlns="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1747312582452" version="3.0"
    xpath-default-namespace="http://www.w3.org/2005/xpath-functions">

    <!--
        TODO:
            - platform (operatingSystem)
            - organisation (publisher?)
    -->

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
            
            <xsl:apply-templates mode="resourceProxies" select="." />
            <xsl:apply-templates mode="componentPayload" select="." />
        </cmd:CMD>
    </xsl:template>
    
    <xsl:template mode="resourceProxies" match="map">
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
                <xsl:for-each select="./string[@key = 'codeRepository']">
                    <cmd:ResourceProxy>
                        <xsl:attribute name="id">repo_<xsl:value-of select="position()"
                        /></xsl:attribute>
                        <cmd:ResourceType>Resource</cmd:ResourceType>
                        <cmd:ResourceRef>
                            <xsl:value-of select="text()"/>
                        </cmd:ResourceRef>
                    </cmd:ResourceProxy>
                </xsl:for-each>
            </cmd:ResourceProxyList>
            <cmd:JournalFileProxyList /> 
            <cmd:ResourceRelationList /> 
        </cmd:Resources>
    </xsl:template>
    
    <xsl:template mode="componentPayload" match="map">
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
                
                <xsl:apply-templates mode="descriptivePropertiesInfo" select="." />
                
                <!-- Authors -->
                <xsl:apply-templates select="map[@key = 'author'] | array[@key = 'author']/map"/>
                <!-- Contributors -->
                <xsl:apply-templates
                    select="map[@key = 'contributor'] | array[@key = 'contributor']/map"/>
                <!-- Maintainers -->
                <xsl:apply-templates
                    select="map[@key = 'maintainer'] | array[@key = 'maintainer']/map"/>
                
                <xsl:apply-templates mode="toolInfo" select="." />
                
                <xsl:apply-templates mode="accessInfo" select="." />
                
                <xsl:apply-templates select="map[@key = 'sourceOrganization']"/>
                
                <xsl:apply-templates mode="provenanceInfo" select="."/>
                
                <xsl:apply-templates select="string[@key = 'version']" />
                
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
    </xsl:template>

    <xsl:template match="map[@key = 'author'] | array[@key = 'author']/map">
        <xsl:apply-templates select="." mode="agentById">
            <xsl:with-param name="type" select="'Creator'"/>
            <xsl:with-param name="role">Author</xsl:with-param>
            <xsl:with-param name="document" select="root()"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="map[@key = 'contributor'] | array[@key = 'contributor']/map">
        <xsl:apply-templates select="." mode="agentById">
            <xsl:with-param name="type">Contributor</xsl:with-param>
            <xsl:with-param name="role">Contributor</xsl:with-param>
            <xsl:with-param name="document" select="root()"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="map[@key = 'maintainer'] | array[@key = 'maintainer']/map">
        <xsl:apply-templates select="." mode="agentById">
            <xsl:with-param name="type">Contributor</xsl:with-param>
            <xsl:with-param name="role">Maintainer</xsl:with-param>
            <xsl:with-param name="document" select="root()"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template mode="agentById" match="map">
        <xsl:param name="type"/>
        <xsl:param name="role"/>
        <xsl:param name="document" select="map/root()"/>

        <!-- Try to find an agent with the identifier that has at least a family name specified -->
        <xsl:variable name="agentId" select="normalize-space(./string[@key = '@id'])"/>
        <xsl:variable name="matchedAgent"
            select="
                $document//map[
                ./string[@key = '@id'] = $agentId
                and normalize-space(./*[@key = 'familyName']) != '']"/>

        <xsl:choose>
            <xsl:when test="$agentId != '' and $matchedAgent != ''">
                <!-- Create information for the resolved person -->
                <xsl:apply-templates mode="agent" select="$matchedAgent[1]">
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="role" select="$role"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <!-- Failed lookup, use what we have -->
                <xsl:apply-templates mode="agent" select=".">
                    <xsl:with-param name="type" select="$type"/>
                    <xsl:with-param name="role" select="$role"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:function name="conversion:stringValueOrFirstFromArray">
        <xsl:param name="context"/>
        <xsl:param name="key"/>
        <xsl:value-of select="$context/string[@key = $key] | $context/array[@key = $key]/string[1]"
        />
    </xsl:function>

    <xsl:function name="conversion:combineName">
        <xsl:param name="familyName"/>
        <xsl:param name="givenName"/>
        <xsl:choose>
            <xsl:when
                test="normalize-space($familyName) != '' and normalize-space($givenName) != ''">
                <xsl:value-of select="concat(concat($familyName, ', '), $givenName)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="normalize-space($familyName) != ''">
                        <xsl:value-of select="$familyName"/>                        
                    </xsl:when>
                    <xsl:when test="normalize-space($givenName) != ''">
                        <xsl:value-of select="$givenName"/>                        
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template mode="agent" match="map[string[@key = '@type'] = 'Organization']">
        <xsl:param name="type"/>
        <xsl:param name="role" required="false"/>
        <xsl:element name="{$type}">
            <xsl:for-each select="./string[@key = '@id' and not(starts-with(text(), '_'))]">
                <identifier>
                    <xsl:value-of select="text()"/>
                </identifier>
            </xsl:for-each>
            <xsl:for-each select="./string[@key = 'sameAs']">
                <identifier>
                    <xsl:value-of select="text()"/>
                </identifier>
            </xsl:for-each>
            <xsl:for-each select="string[@key = 'name'] | array[@key = 'name']/string">
                <label>
                    <xsl:value-of select="."/>
                </label>
            </xsl:for-each>
            <xsl:if test="normalize-space($role) != ''">
                <role>
                    <xsl:value-of select="$role"/>
                </role>
            </xsl:if>
            <AgentInfo>
                <xsl:apply-templates mode="organisationInfo" select="." />
            </AgentInfo>
        </xsl:element>
    </xsl:template>

    <xsl:template mode="organisationInfo" match="map[string[@key = '@type'] = 'Organization']">
        <OrganisationInfo>
            <xsl:for-each select="string[@key = 'name'] | array[@key = 'name']/string">
                <name>
                    <xsl:value-of select="."/>
                </name>
            </xsl:for-each>
            <xsl:if test="string[@key = 'url']">
                <ContactInfo>
                    <url>
                        <xsl:value-of select="string[@key = 'url']"/>
                    </url>
                </ContactInfo>
            </xsl:if>
            <xsl:for-each select="map[@key = 'parentOrganization']">
                <ParentOrganisation>
                    <xsl:for-each select="string[@key = 'name'] | array[@key = 'name']/string">
                        <label>
                            <xsl:value-of select="."/>
                        </label>
                    </xsl:for-each>
                    <xsl:if test="string[@key = 'url']">
                        <ContactInfo>
                            <url>
                                <xsl:value-of select="string[@key = 'url']"/>
                            </url>
                        </ContactInfo>
                    </xsl:if>
                </ParentOrganisation>
            </xsl:for-each>
        </OrganisationInfo>
    </xsl:template>


    <xsl:template mode="agent" match="map[string[@key = '@type'] = 'Person']">
        <xsl:param name="type"/>
        <xsl:param name="role"/>

        <xsl:variable name="familyName"
            select="normalize-space(conversion:stringValueOrFirstFromArray(., 'familyName'))"/>
        <xsl:variable name="givenName"
            select="normalize-space(conversion:stringValueOrFirstFromArray(., 'givenName'))"/>
        <xsl:variable name="creatorName"
            select="normalize-space(conversion:combineName($familyName, $givenName))"/>

        <xsl:element name="{$type}">
            <xsl:for-each select="./string[@key = '@id' and not(starts-with(text(), '_'))]">
                <identifier>
                    <xsl:value-of select="text()"/>
                </identifier>
            </xsl:for-each>
            <xsl:for-each select="./string[@key = 'sameAs']">
                <identifier>
                    <xsl:value-of select="text()"/>
                </identifier>
            </xsl:for-each>

            <!-- TODO: sameAs -->
            <label>
                <xsl:value-of select="$creatorName"/>
            </label>
            <role>
                <xsl:value-of select="$role"/>
            </role>
            <xsl:if test="normalize-space(./string[@key = '@type']) = 'Person'">
                <AgentInfo>
                    <PersonInfo>
                        <name>
                            <xsl:value-of select="$creatorName"/>
                        </name>
                        <xsl:if test="normalize-space(concat($givenName, $familyName)) != ''">
                            <alternativeName>
                                <xsl:value-of select="concat(concat($givenName, ' '), $familyName)"
                                />
                            </alternativeName>
                        </xsl:if>
                        <xsl:if test="./string[@key = 'email'] | ./string[@key = 'url']">
                            <ContactInfo>
                                <xsl:for-each select="./string[@key = 'email']">
                                    <email>
                                        <xsl:value-of select="."/>
                                    </email>
                                </xsl:for-each>
                                <xsl:for-each select="./string[@key = 'url']">
                                    <url>
                                        <xsl:value-of select="."/>
                                    </url>
                                </xsl:for-each>
                            </ContactInfo>
                        </xsl:if>
                    </PersonInfo>
                </AgentInfo>
            </xsl:if>
        </xsl:element>
    </xsl:template>
    
    <xsl:template mode="descriptivePropertiesInfo" match="map">
        <DescriptivePropertiesInfo>
            <xsl:for-each select="array[@key = 'keywords']/string">
                <keyword>
                    <xsl:value-of select="."/>
                </keyword>
            </xsl:for-each>
            
            <xsl:for-each select="array[@key = 'applicationCategory']/string | string[@key = 'applicationCategory']">
                <FieldOfStudy>
                    <label><xsl:value-of select="."/></label>
                </FieldOfStudy>
            </xsl:for-each>
            
            <xsl:for-each select="array[@key = 'applicationCategory']/map | map[@key = 'applicationCategory']">
                <FieldOfStudy>
                    <xsl:for-each select="string[@key = '@id']">
                        <identifier><xsl:value-of select="."/></identifier>
                    </xsl:for-each>
                    <xsl:if test="count(array[@key = 'skos:prefLabel']/map | map[@key = 'skos:prefLabel']) = 0">
                        <label><xsl:value-of select="string[@key = '@id'][1]"/></label>
                    </xsl:if>
                    <xsl:for-each select="array[@key = 'skos:prefLabel']/map | map[@key = 'skos:prefLabel']">
                        <xsl:variable name="language" select="normalize-space(string[@key = '@language'])"/>
                        <xsl:if test="$language = '' or $language='en'">
                            <label>
                                <xsl:if test="normalize-space($language) != ''">
                                    <xsl:attribute name="xml:lang" select="$language" />
                                </xsl:if>
                                <xsl:value-of select="string[@key = '@value']"/>
                            </label>    
                        </xsl:if>
                    </xsl:for-each>
                </FieldOfStudy>
            </xsl:for-each>
        </DescriptivePropertiesInfo>
    </xsl:template>
    
    <xsl:template mode="toolInfo" match="map">
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
                                <xsl:value-of select="replace(text(), '.*#(.*)$', '$1')"
                                />
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
    </xsl:template>
    
    <xsl:template mode="accessInfo" match="map">
        <AccessInfo>
            <xsl:apply-templates mode="licence" select="map[@key = 'license']" />
        </AccessInfo>
    </xsl:template>
    
    <xsl:template mode="licence" match="map[@key = 'license']">
        <Licence>
            <xsl:for-each select="string[@key = '@id']">
                <identifier><xsl:value-of select="."/></identifier>
            </xsl:for-each>
            <xsl:for-each select="string[@key = 'name']">
                <label><xsl:value-of select="."/></label>
            </xsl:for-each>
            <xsl:if test="normalize-space(string[@key = 'name']) = ''">
                <label><xsl:value-of select="string[@key = '@id']"/></label>
            </xsl:if>
            <xsl:if test="starts-with(lower-case(normalize-space(string[@key = '@id'])), 'http')">
                <url><xsl:value-of select="string[@key = '@id']"/></url>
            </xsl:if>
        </Licence>
    </xsl:template>

    <xsl:template match="map[@key = 'sourceOrganization']">
        <Source>
            <xsl:for-each select="string[@key = 'name']">
                <label>
                    <xsl:value-of select="."/>
                </label>
            </xsl:for-each>
            <xsl:for-each select="array[@key = 'name']/string">
                <label>
                    <xsl:value-of select="."/>
                </label>
            </xsl:for-each>
            <xsl:apply-templates mode="organisationInfo" select="."/>
        </Source>
    </xsl:template>

    <xsl:template mode="provenanceInfo" match="map">
        <xsl:variable name="creation">
            <xsl:apply-templates mode="provenanceInfoActivity" select="map[@key = 'producer']"/>
        </xsl:variable>

        <xsl:if test="$creation">
            <ProvenanceInfo>
                <xsl:copy-of select="$creation"/>
            </ProvenanceInfo>
        </xsl:if>
    </xsl:template>

    <xsl:template mode="provenanceInfoActivity" match="map[@key = 'producer']">
        <Creation>
            <ActivityInfo>
                <note>Production of the software</note>
                <When/>
                <xsl:apply-templates mode="agentById" select=".">
                    <xsl:with-param name="type">Responsible</xsl:with-param>
                </xsl:apply-templates>
            </ActivityInfo>
        </Creation>
    </xsl:template>
    
    <xsl:template match="string[@key = 'version']">
        <VersionInfo>
            <versionIdentifier><xsl:value-of select="."/></versionIdentifier>
        </VersionInfo>
    </xsl:template>

    <xsl:template match="array">
        <xsl:comment>Nothing for @key=<xsl:value-of select="@key"/></xsl:comment>
    </xsl:template>

    <xsl:template match="*">
        <!-- Nothing -->
    </xsl:template>
</xsl:stylesheet>
