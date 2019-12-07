<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/02/xpath-functions">
    <!-- (c) 2006, Trimble Navigation Limited. All rights reserved.                                -->
    <!-- Permission is hereby granted to use, copy, modify, or distribute this style sheet for any -->
    <!-- purpose and without fee, provided that the above copyright notice appears in all copies   -->
    <!-- and that both the copyright notice and the limited warranty and restricted rights notice  -->
    <!-- below appear in all supporting documentation.                                             -->
    <!-- TRIMBLE NAVIGATION LIMITED PROVIDES THIS STYLE SHEET "AS IS" AND WITH ALL FAULTS.         -->
    <!-- TRIMBLE NAVIGATION LIMITED SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF MERCHANTABILITY -->
    <!-- OR FITNESS FOR A PARTICULAR USE. TRIMBLE NAVIGATION LIMITED DOES NOT WARRANT THAT THE     -->
    <!-- OPERATION OF THIS STYLE SHEET WILL BE UNINTERRUPTED OR ERROR FREE.                        -->
    <xsl:output method="text" omit-xml-declaration="no" encoding="utf-8"/>
    <!-- Set the numeric display details i.e. decimal point, thousands separator etc -->
    <xsl:variable name="DecPt" select="string('.')"/>
    <!-- Change as appropriate for US/European -->
    <xsl:variable name="GroupSep" select="string(',')"/>
    <!-- Change as appropriate for US/European -->
    <!-- Also change decimal-separator & grouping-separator in decimal-format below 
    as appropriate for US/European output -->
    <xsl:decimal-format name="Standard" decimal-separator="." grouping-separator="," infinity="Infinity" minus-sign="-" NaN="?" percent="%" per-mille="&#2030;" zero-digit="0" digit="#" pattern-separator=";"/>
    <xsl:variable name="DecPl0" select="string('#0')"/>
    <xsl:variable name="DecPl1" select="string(concat('#0', $DecPt, '0'))"/>
    <xsl:variable name="DecPl2" select="string(concat('#0', $DecPt, '00'))"/>
    <xsl:variable name="DecPl3" select="string(concat('#0', $DecPt, '000'))"/>
    <xsl:variable name="DecPl4" select="string(concat('#0', $DecPt, '0000'))"/>
    <xsl:variable name="DecPl5" select="string(concat('#0', $DecPt, '00000'))"/>
    <xsl:variable name="DecPl6" select="string(concat('#0', $DecPt, '000000'))"/>
    <xsl:variable name="DecPl8" select="string(concat('#0', $DecPt, '00000000'))"/>
    <xsl:variable name="DegreesSymbol" select="'&#0176;'"/>
    <xsl:variable name="MinutesSymbol">
        <xsl:text>'</xsl:text>
    </xsl:variable>
    <xsl:variable name="SecondsSymbol" select="'&quot;'"/>
    <xsl:variable name="fileExt" select="'txt'"/>
    <xsl:key name="tgtID-search" match="//JOBFile/FieldBook/TargetRecord" use="@ID"/>
    <xsl:key name="antennaID-search" match="//JOBFile/FieldBook/AntennaRecord" use="@ID"/>
    <xsl:key name="travID-search" match="//JOBFile/FieldBook/TraverseDefinitionRecord" use="@ID"/>
    <!-- User variable definitions - Appropriate fields are displayed on the       -->
    <!-- Survey Controller screen to allow the user to enter specific values       -->
    <!-- which can then be used within the style sheet definition to control the   -->
    <!-- output data.                                                              -->
    <!--                                                                           -->
    <!-- All user variables must be identified by a variable element definition    -->
    <!-- named starting with 'userField' (case sensitive) followed by one or more  -->
    <!-- characters uniquely identifying the user variable definition.             -->
    <!--                                                                           -->
    <!-- The text within the 'select' field for the user variable description      -->
    <!-- references the actual user variable and uses the '|' character to         -->
    <!-- separate the definition details into separate fields as follows:          -->
    <!-- For all user variables the first field must be the name of the user       -->
    <!-- variable itself (this is case sensitive) and the second field is the      -->
    <!-- prompt that will appear on the Survey Controller screen.                  -->
    <!-- The third field defines the variable type - there are four possible       -->
    <!-- variable types: Double, Integer, String and StringMenu.  These variable   -->
    <!-- type references are not case sensitive.                                   -->
    <!-- The fields that follow the variable type change according to the type of  -->
    <!-- variable as follow:                                                       -->
    <!-- Double and Integer: Fourth field = optional minimum value                 -->
    <!--                     Fifth field = optional maximum value                  -->
    <!--   These minimum and maximum values are used by the Survey Controller for  -->
    <!--   entry validation.                                                       -->
    <!-- String: No further fields are needed or used.                             -->
    <!-- StringMenu: Fourth field = number of menu items                           -->
    <!--             Remaining fields are the actual menu items - the number of    -->
    <!--             items provided must equal the specified number of menu items. -->
    <!--                                                                           -->
    <!-- The style sheet must also define the variable itself, named according to  -->
    <!-- the definition.  The value within the 'select' field will be displayed in -->
    <!-- the Survey Controller as the default value for the item.                  -->
    <!-- Need to use the select attribute for userField definitions and also include the -->
    <!-- contents in single quotes so that the user information can be picked up by the  -->
    <!-- Survey Controller and ASCII File Generator.  This means it is not possible to   -->
    <!-- have text that includes any apostrophes (single quotes) in it.                  -->
    <!-- Remove the presentation of this option and always set to yes
    <xsl:variable name="userField3" select="'IncludeBorders|Include borders in report|stringMenu|2|Yes|No'"/>
    -->
    <xsl:variable name="IncludeBorders" select="'Yes'"/>
    <!-- Save the possible selected values in variables for comparison purposes -->
    <!-- so that there is no need to include the translated strings in quotes.  -->
    <xsl:variable name="copyrights"></xsl:variable>
    <xsl:variable name="YesStr">Yes</xsl:variable>
    <xsl:variable name="Space">&#160;</xsl:variable>
    <xsl:variable name="NoStr">No</xsl:variable>
    <!-- **************************************************************** -->
    <!-- Set global variables from the Environment section of JobXML file -->
    <!-- **************************************************************** -->
    <xsl:variable name="DistUnit" select="/JOBFile/Environment/DisplaySettings/DistanceUnits"/>
    <xsl:variable name="ElevUnit" select="/JOBFile/Environment/DisplaySettings/HeightUnits"/>
    <xsl:variable name="AngleUnit" select="/JOBFile/Environment/DisplaySettings/AngleUnits"/>
    <xsl:variable name="CoordOrder" select="/JOBFile/Environment/DisplaySettings/CoordinateOrder"/>
    <xsl:variable name="TempUnit" select="/JOBFile/Environment/DisplaySettings/TemperatureUnits"/>
    <xsl:variable name="PressUnit" select="/JOBFile/Environment/DisplaySettings/PressureUnits"/>
    <!-- Setup conversion factor for coordinate and distance values -->
    <xsl:variable name="DistConvFactor">
        <xsl:choose>
            <xsl:when test="$DistUnit='Metres'">1.0</xsl:when>
            <xsl:when test="$DistUnit='InternationalFeet'">3.280839895</xsl:when>
            <xsl:when test="$DistUnit='USSurveyFeet'">3.2808333333357</xsl:when>
            <xsl:otherwise>1.0</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- Setup conversion factor for coordinate and distance values -->
    <xsl:variable name="ElevConvFactor">
        <xsl:choose>
            <xsl:when test="$ElevUnit='Metres'">1.0</xsl:when>
            <xsl:when test="$ElevUnit='InternationalFeet'">3.280839895</xsl:when>
            <xsl:when test="$ElevUnit='USSurveyFeet'">3.2808333333357</xsl:when>
            <xsl:otherwise>1.0</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- Setup conversion factor for angular values -->
    <xsl:variable name="AngleConvFactor">
        <xsl:choose>
            <xsl:when test="$AngleUnit='DMSDegrees'">1.0</xsl:when>
            <xsl:when test="$AngleUnit='Gons'">1.111111111111</xsl:when>
            <xsl:when test="$AngleUnit='Mils'">17.77777777777</xsl:when>
            <xsl:otherwise>1.0</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- Setup boolean variable for coordinate order -->
    <xsl:variable name="NECoords">
        <xsl:choose>
            <xsl:when test="$CoordOrder='North-East-Elevation'">
                <xsl:value-of select="'True'"/>
            </xsl:when>
            <xsl:when test="$CoordOrder='X-Y-Z'">
                <xsl:value-of select="'True'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'False'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- Set up global variables for the north, east, elevation, delta north, delta east and -->
    <!-- delta elevation prompts according to the type of coordinate labeling.               -->
    <xsl:variable name="northPrompt">
        <xsl:choose>
            <xsl:when test="($CoordOrder='North-East-Elevation') or ($CoordOrder='East-North-Elevation')">North</xsl:when>
            <xsl:otherwise>X</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="eastPrompt">
        <xsl:choose>
            <xsl:when test="($CoordOrder='North-East-Elevation') or ($CoordOrder='East-North-Elevation')">East</xsl:when>
            <xsl:otherwise>Y</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="elevPrompt">
        <xsl:choose>
            <xsl:when test="($CoordOrder='North-East-Elevation') or ($CoordOrder='East-North-Elevation')">Elevation</xsl:when>
            <xsl:otherwise>Z</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="dNorthPrompt">
        <xsl:choose>
            <xsl:when test="($CoordOrder='North-East-Elevation') or ($CoordOrder='East-North-Elevation')">Δ North</xsl:when>
            <xsl:otherwise>ΔX</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="dEastPrompt">
        <xsl:choose>
            <xsl:when test="($CoordOrder='North-East-Elevation') or ($CoordOrder='East-North-Elevation')">Δ East</xsl:when>
            <xsl:otherwise>ΔY</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="dElevPrompt">
        <xsl:choose>
            <xsl:when test="($CoordOrder='North-East-Elevation') or ($CoordOrder='East-North-Elevation')">ΔElev</xsl:when>
            <xsl:otherwise>ΔZ</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- Setup conversion factor for pressure values -->
    <!-- Pressure values in JobXML file are always in millibars (hPa) -->
    <xsl:variable name="PressConvFactor">
        <xsl:choose>
            <xsl:when test="$PressUnit='MilliBar'">
                1.0
            </xsl:when>
            <xsl:when test="$PressUnit='InchHg'">
                0.029529921
            </xsl:when>
            <xsl:when test="$PressUnit='mmHg'">
                0.75006
            </xsl:when>
            <xsl:otherwise>
                1.0
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
	


    <xsl:variable name="Codeempty">
        <xsl:choose>
            <xsl:when test="Code = ' '">
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="Code"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
	
    <!-- **************************************************************** -->
    <!-- ************************** Main Loop *************************** -->
    <!-- **************************************************************** -->
    <xsl:template match="/">


        <HTML>
            <body>

                <!-- process all PointRecords except Base record -->
                <xsl:apply-templates select="/JOBFile/FieldBook/PointRecord[Deleted!='true']"/>

				
            </body>
        </HTML>
		
        <!-- koniec raportu -->
    </xsl:template>
    <xsl:template name="NewLine">
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    <xsl:template name="my-out">
        <xsl:param name="Val" select="''"/>
        <xsl:choose>
            <xsl:when test="$Val">
                <xsl:value-of select="$Val"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$Space"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="my-format">
        <xsl:param name="Val" select="''"/>
        <xsl:param name="format" select="''"/>
        <xsl:choose>
            <xsl:when test="$Val!=''">
                <xsl:message>
                    <xsl:value-of select="$Val"/>
                </xsl:message>
                <xsl:value-of select="format-number($Val, $format)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$Space"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="PointRecord">
        <xsl:for-each select="/JOBFile/FieldBook/PointRecord[Deleted!='false']"></xsl:for-each>
		
        <xsl:variable name="AID" select="AntennaID/text()"/>
        <xsl:if test="ECEFDeltas/DeltaX/text()">
            <xsl:call-template name="my-out">
                <xsl:with-param name="Val" select="concat(RTK_Base,',')"/>
            </xsl:call-template>
            <xsl:call-template name="my-out">
                <xsl:with-param name="Val" select="concat(Name,',')"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="SurveyMethod='Fix'">RTK Fix</xsl:when>
                <xsl:when test="SurveyMethod='NetworkFix'">RTN Fix</xsl:when>
                <xsl:when test="SurveyMethod='RTK'">RTK</xsl:when>
                <xsl:when test="SurveyMethod='NetworkRTK'">RTN</xsl:when>
                <xsl:otherwise>Float</xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="my-out">
                <xsl:with-param name="Val" select="concat(',',translate(@TimeStamp,' T','  '),',')"></xsl:with-param>
	
            </xsl:call-template>
            <xsl:call-template name="my-format">
                <xsl:with-param name="Val" select="/JOBFile/FieldBook/AntennaRecord[@ID=$AID]/MeasuredHeight/text()" />
                <xsl:with-param name="format" select="concat($DecPl3,',')"/>
            </xsl:call-template>
            <xsl:call-template name="my-format">
                <xsl:with-param name="Val" select="ECEFDeltas/DeltaX"/>
                <xsl:with-param name="format" select="concat($DecPl3,',')"/>
            </xsl:call-template>
            <xsl:call-template name="my-format">
                <xsl:with-param name="Val" select="ECEFDeltas/DeltaY"/>
                <xsl:with-param name="format" select="concat($DecPl3,',')"/>
            </xsl:call-template>
            <xsl:call-template name="my-format">
                <xsl:with-param name="Val" select="ECEFDeltas/DeltaZ"/>
                <xsl:with-param name="format" select="concat($DecPl3,',')"/>
            </xsl:call-template>
            <xsl:call-template name="my-format">
                <xsl:with-param name="Val" select="QualityControl1/PDOP"/>
                <xsl:with-param name="format" select="concat($DecPl1,',')"/>
            </xsl:call-template>
            <xsl:call-template name="my-out">
                <xsl:with-param name="Val" select="concat(QualityControl1/NumberOfSatellites,',')"/>
            </xsl:call-template>
            <xsl:call-template name="my-out">
                <xsl:with-param name="Val" select="concat(QualityControl1/NumberOfPositionsUsed,',')"/>
            </xsl:call-template>
            <xsl:call-template name="my-format">
                <xsl:with-param name="Val" select="ComputedGrid/North"/>
                <xsl:with-param name="format" select="concat($DecPl2,',')"/>
            </xsl:call-template>
            <xsl:call-template name="my-format">
                <xsl:with-param name="Val" select="ComputedGrid/East"/>
                <xsl:with-param name="format" select="concat($DecPl2,',')"/>
            </xsl:call-template>
            <xsl:call-template name="my-format">
                <xsl:with-param name="Val" select="ComputedGrid/Elevation"/>
                <xsl:with-param name="format" select="concat($DecPl3,',')"/>
            </xsl:call-template>
            <xsl:call-template name="my-format">
                <xsl:with-param name="Val" select="Precision/Horizontal"/>
                <xsl:with-param name="format" select="concat($DecPl2,',')"/>
            </xsl:call-template>
            <xsl:call-template name="my-format">
                <xsl:with-param name="Val" select="Precision/Vertical"/>
                <xsl:with-param name="format" select="concat($DecPl2,',')"/>
            </xsl:call-template>
            <xsl:call-template name="my-out">
                <xsl:with-param name="Val" select="Code"/>
            </xsl:call-template>
            <xsl:call-template name="NewLine"/>                             
        </xsl:if>
        
    </xsl:template>

</xsl:stylesheet>
