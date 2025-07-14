<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1747312582452"
    version="3.0"
    xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:param name="input"/>
    <xsl:output method="xml" indent="true"/>
    
    <xsl:template name="xsl:initial-template">
        <xsl:variable name="input-as-xml" select="json-to-xml(unparsed-text($input))"/>
        <xsl:apply-templates select="$input-as-xml"/>
    </xsl:template>

    <xsl:template match="map">
        <cmd:CMD xmlns:cmd="http://www.clarin.eu/cmd/1"
            xmlns:cue="http://www.clarin.eu/cmd/cues/1"
            xmlns:cue_old="http://www.clarin.eu/cmdi/cues/1"
            xmlns:cmdp="http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1747312582452"
            xmlns:dcr="http://www.isocat.org/ns/dcr"
            xmlns:vc="http://www.w3.org/2007/XMLSchema-versioning"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.clarin.eu/cmd/1 https://infra.clarin.eu/CMDI/1.x/xsd/cmd-envelop.xsd
            http://www.clarin.eu/cmd/1/profiles/clarin.eu:cr1:p_1747312582452 https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/clarin.eu:cr1:p_1747312582452/xsd"
            CMDVersion="1.2">
            <cmd:Header>
                <cmd:MdProfile>clarin.eu:cr1:p_1747312582452</cmd:MdProfile>
            </cmd:Header>
            <cmd:Resources>
                <cmd:ResourceProxyList>
                </cmd:ResourceProxyList>
                <cmd:JournalFileProxyList>
                </cmd:JournalFileProxyList>
                <cmd:ResourceRelationList>
                </cmd:ResourceRelationList>
            </cmd:Resources>
            <cmd:Components>
                <GenericToolService>
                    <TitleInfo>
                        <xsl:for-each select="./string[@key = 'name']">
                            <title>
                                <xsl:value-of select="./text()"/>
                            </title>
                        </xsl:for-each>
                    </TitleInfo>
                    <ToolInfo>
                        <xsl:if test="normalize-space(./string[@key = 'webApplication']) != ''">
                            <ToolServiceType>
                                <label>Web application</label>
                            </ToolServiceType>
                        </xsl:if>
                        <xsl:for-each select="./string[@key='task']">
                            <TaskType>
                                <label><xsl:value-of select="./text()"/></label>
                            </TaskType>
                        </xsl:for-each>
                    </ToolInfo>
                </GenericToolService>
            </cmd:Components>
        </cmd:CMD>
    </xsl:template>
</xsl:stylesheet>