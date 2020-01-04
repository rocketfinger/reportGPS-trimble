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
	<xsl:output method="html" omit-xml-declaration="no" encoding="utf-8"/>
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
	<xsl:variable name="fileExt" select="'htm'"/>
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
	<xsl:variable name="userField3" select="'asgeupos1|System stacji referencyjnych|stringMenu|4|ASG-EUPOS|VRSNet|MSPP|TPINet'"/>
	<xsl:variable name="asgeupos1" select="'ASG-EUPOS'"/>
	<xsl:variable name="userField4" select="'asgeupos2|Nazwa użytkownika w systemie|String'"/>
	<xsl:variable name="asgeupos2" select="'geoszkic'"/>

	<xsl:variable name="userField8" select="'wysokosci|Układ wysokości|stringMenu|3|Kronsztadt|Amsterdam|Lokalny'"/>
	<xsl:variable name="wysokosci" select="'Kronsztadt'"/>
	<xsl:variable name="userField6" select="'startDate|Raportuj pomiary od (rrrr-mm-dd)|string'"/>
    <xsl:variable name="startDate" select="''"/>
    <xsl:variable name="userField7" select="'endDate|Raportuj pomiary do (rrrr-mm-dd)|string'"/>
	<xsl:variable name="endDate" select="''"/>
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
	
	<xsl:variable name="user">
	  <xsl:choose>
	    <xsl:when test="$asgeupos2">
	    	<xsl:value-of select="$asgeupos2"/></xsl:when>
	    <xsl:otherwise><xsl:value-of select="/JOBFile/FieldBook/JobPropertiesRecord[Operator/text()]/Operator"/></xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

	<xsl:variable name="reportStartDate">
	  <xsl:choose>
	    <xsl:when test="$startDate = ''">
	      <xsl:value-of select="substring-before(/JOBFile/FieldBook/PointRecord[(Deleted = 'false')][5]/@TimeStamp, 'T')"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$startDate"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

	<xsl:variable name="reportEndDate">
	  <xsl:choose>
	    <xsl:when test="$endDate = ''">
   		  <xsl:value-of select="substring-before(/JOBFile/FieldBook/PointRecord[(Deleted = 'false')][last()]/@TimeStamp, 'T')"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$endDate"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

	<xsl:variable name="startJulianDay">
	  <xsl:call-template name="julianDay">
	    <xsl:with-param name="timeStamp" select="concat($reportStartDate, 'T00:00:00')"/>
	  </xsl:call-template>
	</xsl:variable>

	<xsl:variable name="endJulianDay">
	  <xsl:call-template name="julianDay">
	    <xsl:with-param name="timeStamp" select="concat($reportEndDate, 'T00:00:00')"/>
	  </xsl:call-template>
	</xsl:variable>

	<xsl:variable name="Codeempty">
	  <xsl:choose>
	    <xsl:when test="Code = ''">
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
			
				<TITLE>Raport z pomiaru GPS RTK/RTN Trimble</TITLE>
				  <h2>Raport z pomiaru GPS RTK/RTN "<xsl:value-of select="JOBFile/@jobName"/>"</h2>
				  <style type="text/css">
				    body, table, td, th
				    {
				      font-size:12px;
				      font-face: Arial;
				    }
				    th.blackTitleLine {background-color: black; color: white}
				    th.silverTitleLine {background-color: silver}
				  </style>
			<head>
			</head>
			<body>
			
				<table border="1" width="100%" cellpadding="5">
				  <tr>
				      <td align="left" width="30%">Producent, model odbiornika i numer seryjny odbiornika:</td>
				      <td align="left" width="20%"><b> Trimble,
				      								<xsl:value-of select="/JOBFile/FieldBook/GPSEquipmentRecord[last()]/ReceiverType"/>,
													<xsl:value-of select="/JOBFile/FieldBook/GPSEquipmentRecord[last()]/ReceiverSerialNumber"/>
				      </b></td>
				      <td align="left" width="30%">Producent i model anteny</td>
				      <td align="left" width="20%"><b> Trimble
				      								<xsl:value-of select="/JOBFile/FieldBook/GPSEquipmentRecord[last()]/AntennaType/text()"/>,
				      								<xsl:value-of select="/JOBFile/FieldBook/GPSEquipmentRecord[last()]/AntennaSerialNumber/text()"/>

				      </b></td>
				  </tr>

	  			  <tr>
				      <td align="left" width="30%">Wykorzystany system stacji referencyjnych:</td>
				      <td align="left" width="20%"><b>
									      			<xsl:if test="$asgeupos1 != ''">
														<xsl:value-of select="$asgeupos1"/>
												    </xsl:if>
			    	  </b></td>
				      <td align="left" width="30%">Nazwa użytkownika w systemie:</td>
				      <td align="left" width="20%"><b> <xsl:value-of select="$user"/></b></td>
				  </tr>

				  <tr>
				      <td align="left" width="30%">Wykorzystany strumień poprawek w systemie:</td>
				      <td align="left" width="20%"><b> <xsl:value-of select="/JOBFile/FieldBook/NTRIPDataSourceRecord[last()]/MountPoint/text()"/>
				      </b></td>
				      <td align="left" width="30%">Format danych korekcyjnych:</td>
				      <td align="left" width="20%"><b>  <xsl:value-of select="/JOBFile/FieldBook/NTRIPDataSourceRecord/DataFormat/text()"/>
				      </b></td>
				  </tr>

 				  <tr>
				      <td align="left" width="30%">Adres IP:, Port IP:</td>
				      <td align="left" width="20%"><b> http://<xsl:value-of select="/JOBFile/FieldBook/NTRIPDataSourceRecord[last()]/IPAdress/text()"/>:
				      									<xsl:value-of select="/JOBFile/FieldBook/NTRIPDataSourceRecord[last()]/IPPort/text()"/>
				      </b></td>
				      <td align="left" width="30%">Typ rozwiązania:</td>
				      <td align="left" width="20%"><b>  <xsl:value-of select="/JOBFile/FieldBook/NTRIPDataSourceRecord[last()]/Solution/text()"/>
				      </b></td>
				  </tr>

 				  <tr>
				      <td align="left" width="30%">Maska elewacji odbiornika ruchomego:</td>
				      <td align="left" width="20%"><b><xsl:value-of select="/JOBFile/FieldBook/RoverSurveyOptionsRecord[last()]/ElevationMask/text()"/>
				      </b></td>
				      <td align="left" width="30%">Maska PDOP odbiornika ruchomego:</td>
				      <td align="left" width="20%"><b><xsl:value-of select="/JOBFile/FieldBook/RoverSurveyOptionsRecord[last()]/PDOPMask/text()"/>
				  	    <!-- tu jest przyklad PDOP z pierwszego pomiaru -->
				 		<!-- <xsl:value-of select="/JOBFile/FieldBook/RoverSurveyOptionsRecord[position()=1]/PDOPMask/text()"/>-->
				      </b></td>
				  </tr>
					<tr>
				      <td align="left" width="30%">Rodzaj oprogramowania wewnętrznego:</td>
				      <td align="left" width="20%"><b> <xsl:value-of select="/JOBFile/@product"/>
				      </b></td>
				      <td align="left" width="30%">Wersja oprogramowania:</td>
				      <td align="left" width="20%"><b> <xsl:value-of select="/JOBFile/@productVersion"/>
				      </b></td>
				  </tr>

				</table>

			
				<xsl:call-template name="SeparatingLine"/>
				
	
						
<h2 class="tableHeader">Parametry odwzorowania:</h2>
<table width="100%" border="1">
<tbody>

	<tr>
	<td align="left" width="20%">
				Kraj
				<xsl:call-template name="SeparatingLine"/>
				Układ/strefa
				<xsl:call-template name="SeparatingLine"/>
				Elipsoida odniesienia
	</td>
	<td align="left" width="20%">
				<xsl:choose>
					<xsl:when test="JOBFile/Environment/CoordinateSystem[last()]/SystemName/text()">
						<xsl:value-of select="JOBFile/Environment/CoordinateSystem[last()]/SystemName/text()"/>
					</xsl:when>
					<xsl:otherwise>Polska</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="SeparatingLine"/>
				<xsl:choose>
					<xsl:when test="JOBFile/Environment/CoordinateSystem[last()]/ZoneName/text()">
						<xsl:value-of select="JOBFile/Environment/CoordinateSystem[last()]/ZoneName/text()"/>
					</xsl:when>
					<xsl:otherwise>Układ lokalny zdefiniowany na punktach kalibracji</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="SeparatingLine"/>
				<xsl:choose>
					<xsl:when test="JOBFile/Environment/CoordinateSystem[last()]/Ellipsoid/EarthRadius='6378137'">WGS-84</xsl:when>
					<xsl:when test="JOBFile/Environment/CoordinateSystem[last()]/Ellipsoid/EarthRadius='6378245'">Krasowski 1940</xsl:when>
					<xsl:otherwise>Nieznana</xsl:otherwise>
				</xsl:choose>
	</td>
	</tr>

	<tr>
	<td align="left" width="20%">
				Duża półoś elipsoidy
				<xsl:call-template name="SeparatingLine"/>
				Spłaszczenie elipsoidy
	</td>
	<td>
				<xsl:apply-templates select="JOBFile/Environment/CoordinateSystem/Ellipsoid[last()]/EarthRadius/text()"/>
				<xsl:call-template name="SeparatingLine"/>
				<xsl:apply-templates select="JOBFile/Environment/CoordinateSystem/Ellipsoid[last()]/Flattening/text()"/>
			</td>
</tr>
<tr>
	<td align="left" width="20%">
				Typ odwzorowania
				<xsl:call-template name="SeparatingLine"/>
				Równoleżnik osiowy
				<xsl:call-template name="SeparatingLine"/>
				Południk osiowy
				<xsl:call-template name="SeparatingLine"/>
				Punkt główny X
				<xsl:call-template name="SeparatingLine"/>
				Punkt główny Y
				<xsl:call-template name="SeparatingLine"/>
				Skala w punkcie głównym
				<xsl:call-template name="SeparatingLine"/>
				Azymut
				<xsl:call-template name="SeparatingLine"/>
				Orientacja siatki
	</td>
	<td>
				<xsl:choose>
					<xsl:when test="JOBFile/Environment/CoordinateSystem/Projection[last()]/Type='TransverseMercator'">Gaussa-Krugera</xsl:when>
					<xsl:when test="JOBFile/Environment/CoordinateSystem/Projection[last()]/Type='StereographicDouble'">Podwójne stereograficzne</xsl:when>
					<xsl:otherwise>Nieznana</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="SeparatingLine"/>
				<xsl:apply-templates select="JOBFile/Environment/CoordinateSystem/Projection[last()]/CentralLatitude/text()"/>
				<xsl:call-template name="SeparatingLine"/>
				<xsl:apply-templates select="JOBFile/Environment/CoordinateSystem/Projection[last()]/CentralLongitude/text()"/>
				<xsl:call-template name="SeparatingLine"/>
				<xsl:apply-templates select="JOBFile/Environment/CoordinateSystem/Projection[last()]/FalseNorthing/text()"/>
				<xsl:call-template name="SeparatingLine"/>
				<xsl:apply-templates select="JOBFile/Environment/CoordinateSystem/Projection[last()]/FalseEasting/text()"/>
				<xsl:call-template name="SeparatingLine"/>
				<xsl:apply-templates select="JOBFile/Environment/CoordinateSystem/Projection[last()]/Scale/text()"/>
				<xsl:call-template name="SeparatingLine"/>
				<xsl:choose>
					<xsl:when test="JOBFile/Environment/CoordinateSystem/Projection[last()]/SouthAzimuth='true'">Na południe</xsl:when>
					<xsl:when test="JOBFile/Environment/CoordinateSystem/Projection[last()]/SouthAzimuth='false'">Na północ</xsl:when>
					<xsl:otherwise>Nieznany</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="SeparatingLine"/>
				<xsl:choose>
					<xsl:when test="JOBFile/Environment/CoordinateSystem/Projection[last()]/GridOrientation='IncreasingNorthEast'">Rosnąca północ-wschód</xsl:when>
					<xsl:otherwise>Nieznana</xsl:otherwise>
				</xsl:choose>
			</td>
			</tr>
			<tr>
	<td align="left" width="20%">
				Transformacja wysokościowa
				<xsl:call-template name="SeparatingLine"/>
				Model Geoidy
				<xsl:call-template name="SeparatingLine"/>
				Układ odniesienia
	</td>
	<td>
				<xsl:choose>
					<xsl:when test="JOBFile/Environment/CoordinateSystem/VerticalAdjustment[last()]/Type='GeoidModel'">Geoida</xsl:when>
					<xsl:when test="JOBFile/Environment/CoordinateSystem/VerticalAdjustment[last()]/Type='GeoidModelAndInclinedPlane'">Geoida + płaszczyzna pochylona</xsl:when>
					<xsl:otherwise>Brak</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="SeparatingLine"/>
				<xsl:apply-templates select="JOBFile/Environment/CoordinateSystem/VerticalAdjustment[last()]/GeoidName/text()"/>
				<xsl:call-template name="SeparatingLine"/>
				<xsl:value-of select="$wysokosci"/>
	</td>
</tr>
</tbody>
</table>


				<xsl:call-template name="SeparatingLine"/>
				<xsl:if test="count(/JOBFile/Environment/CoordinateSystem/CalibrationPointPairs/CalibrationPointPair) > 0">
				<h2 class="tableHeader">Punkty kalibracji:</h2>
				<table border="1" width="100%">
					<tr>
						<th>Punkt w układzie lokalnym</th>
						<th>Punkt GPS</th>
						<th>Użycie</th>
						<th>d HD</th>
						<th>d VD</th>
					</tr>
					<xsl:apply-templates select="/JOBFile/Environment/CoordinateSystem/CalibrationPointPairs/CalibrationPointPair"/>
				</table>
				</xsl:if>
				<!-- end of table -->
				<!-- show HorizontalAdjustment -->
				<xsl:if test="count(/JOBFile/Environment/CoordinateSystem/CalibrationPointPairs/CalibrationPointPair) > 0">
				<h2 class="tableHeader">Transformacja pozioma:</h2>
				<table width="100%" border="1">
					<tbody>
						<tr>
							<th>Typ transformacji</th>
							<th>X punktu głównego</th>
							<th>Y punktu głównego</th>
							<th>Przesunięcie na północ</th>
							<th>Przesunięcie na wschód</th>
							<th>Skręcenie</th>
							<th>Skala</th>
						</tr>
						<tr>
							<td>
							<xsl:choose>
								<xsl:when test="JOBFile/Environment/CoordinateSystem/Datum[last()]/Type='ThreeParameter'">3 parametrowa</xsl:when>
								<xsl:when test="JOBFile/Environment/CoordinateSystem/Datum[last()]/Type='SevenParameter'">7 parametrowa</xsl:when>
								<xsl:otherwise>Brak</xsl:otherwise>
							</xsl:choose>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="//HorizontalAdjustment/OriginNorth"/>
									<xsl:with-param name="format" select="$DecPl3"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="//HorizontalAdjustment/OriginEast"/>
									<xsl:with-param name="format" select="$DecPl3"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="//HorizontalAdjustment/TranslationNorth"/>
									<xsl:with-param name="format" select="$DecPl3"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="//HorizontalAdjustment/TranslationEast"/>
									<xsl:with-param name="format" select="$DecPl3"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-angle">
									<xsl:with-param name="Val" select="//HorizontalAdjustment/Rotation"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="//HorizontalAdjustment/ScaleFactor"/>
									<xsl:with-param name="format" select="$DecPl6"/>
								</xsl:call-template>
							</td>
						</tr>
					</tbody>
				</table>
				</xsl:if>
				<!-- show VertivalAdjusment -->
				<xsl:if test="count(/JOBFile/Environment/CoordinateSystem/CalibrationPointPairs/CalibrationPointPair) > 0">
				<h2 class="tableHeader">Transformacja wysokościowa:</h2>
				<table width="100%" border="1">
					<tbody>
						<tr>
							<th>X punktu głównego</th>
							<th>Y punktu głównego</th>
							<th>Pochylenie na Północ</th>
							<th>Pochylenie na Wschód</th>
							<th>Odstęp </th>
						</tr>
						<tr>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="//VerticalAdjustment/OriginNorth"/>
									<xsl:with-param name="format" select="$DecPl3"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="//VerticalAdjustment/OriginEast"/>
									<xsl:with-param name="format" select="$DecPl3"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="//VerticalAdjustment/SlopeNorthPerUnit"/>
									<xsl:with-param name="format" select="$DecPl6"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="//VerticalAdjustment/SlopeEastPerUnit"/>
									<xsl:with-param name="format" select="$DecPl6"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="//VerticalAdjustment/ConstantAdjustment"/>
									<xsl:with-param name="format" select="$DecPl3"/>
								</xsl:call-template>
							</td>
						</tr>
					</tbody>
				</table>
				</xsl:if>
<!-- arek -->
				<xsl:if test="count(/JOBFile/FieldBook/PointRecord[Code='k']) > 0">
					<h2 class="tableTile">Tabela punktów kontrolnych - różnice:</h2>
					<table align="center" border="1" width="100%">
						<tr>
							<th>Pkt kat.</th>
							<th>X kat.</th>
							<th>Y kat.</th>
							<th>h kat.</th>
							<th>Pkt pom.</th>
							<th>X pom.</th>
							<th>Y pom.</th>
							<th>h pom.</th>
							<th>Δx</th>
							<th>Δy</th>
							<th>Δh</th>
						</tr>
					<xsl:for-each select="/JOBFile/FieldBook/PointRecord[Code='k']">
						<tr>
							<td>
								<xsl:call-template name="my-out">
									<xsl:with-param name="Val" select="Stakeout/PointDesign/Name"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="ComputedGrid/North + Stakeout/GridDeltas/DeltaNorth"/>
									<xsl:with-param name="format" select="$DecPl2"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="ComputedGrid/East + Stakeout/GridDeltas/DeltaEast"/>
									<xsl:with-param name="format" select="$DecPl2"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="ComputedGrid/Elevation + Stakeout/GridDeltas/DeltaElevation"/>
									<xsl:with-param name="format" select="$DecPl3"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-out">
									<xsl:with-param name="Val" select="Name"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="ComputedGrid/North"/>
									<xsl:with-param name="format" select="$DecPl2"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="ComputedGrid/East"/>
									<xsl:with-param name="format" select="$DecPl2"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="ComputedGrid/Elevation"/>
									<xsl:with-param name="format" select="$DecPl3"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="Stakeout/GridDeltas/DeltaNorth"/>
									<xsl:with-param name="format" select="$DecPl2"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="Stakeout/GridDeltas/DeltaEast"/>
									<xsl:with-param name="format" select="$DecPl2"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="Stakeout/GridDeltas/DeltaElevation"/>
									<xsl:with-param name="format" select="$DecPl3"/>
								</xsl:call-template>
							</td>
						</tr>
					</xsl:for-each>
					</table>
				</xsl:if>
<!-- arek koniec -->
<!-- tomek - uśrednienia -->
<xsl:if test="count(/JOBFile/FieldBook/PointRecord[Classification='Averaged']) > 0">
					<h2 class="tableTile">Tabela punktów uśrednionych:</h2>
					<table align="center" border="1" width="100%">
						<tr>
							<th>Nr pkt</th>
							<th>x</th>
							<th>y</th>
							<th>h</th>
							<th>x'</th>
							<th>y'</th>
							<th>h'</th>
							<th>x sr</th>
							<th>y sr</th>
							<th>h sr</th>
							<th>mx</th>
							<th>my</th>
							<th>mh</th>
							<th>mp</th>
						</tr>
					<xsl:for-each select="/JOBFile/FieldBook/PointRecord[Classification='Averaged']">
						<tr>
							<td>
								<xsl:call-template name="my-out">
									<xsl:with-param name="Val" select="Name"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="ComputedGrid/North - AverageResiduals/AverageResidual[1]/GridResidual/DeltaNorth"/>
									<xsl:with-param name="format" select="$DecPl2"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="ComputedGrid/East - AverageResiduals/AverageResidual[1]/GridResidual/DeltaEast"/>
									<xsl:with-param name="format" select="$DecPl2"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="ComputedGrid/Elevation - AverageResiduals/AverageResidual[1]/GridResidual/DeltaElevation"/>
									<xsl:with-param name="format" select="$DecPl3"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="ComputedGrid/North - AverageResiduals/AverageResidual[2]/GridResidual/DeltaNorth"/>
									<xsl:with-param name="format" select="$DecPl2"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="ComputedGrid/East - AverageResiduals/AverageResidual[2]/GridResidual/DeltaEast"/>
									<xsl:with-param name="format" select="$DecPl2"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="ComputedGrid/Elevation - AverageResiduals/AverageResidual[2]/GridResidual/DeltaElevation"/>
									<xsl:with-param name="format" select="$DecPl3"/>
								</xsl:call-template>
							</td>
							<td>
								<b>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="ComputedGrid/North"/>
									<xsl:with-param name="format" select="$DecPl2"/>
								</xsl:call-template>
								</b>
							</td>
							<td>
								<b>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="ComputedGrid/East"/>
									<xsl:with-param name="format" select="$DecPl2"/>
								</xsl:call-template>
								</b>
							</td>
							<td>
								<b>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="ComputedGrid/Elevation"/>
									<xsl:with-param name="format" select="$DecPl3"/>
								</xsl:call-template>
								</b>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="GridStandardDeviations/NorthStandardDeviation"/>
									<xsl:with-param name="format" select="$DecPl2"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="GridStandardDeviations/EastStandardDeviation"/>
									<xsl:with-param name="format" select="$DecPl2"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="GridStandardDeviations/ElevationStandardDeviation"/>
									<xsl:with-param name="format" select="$DecPl3"/>
								</xsl:call-template>
							</td>
							<td>
								<xsl:call-template name="my-format">
									<xsl:with-param name="Val" select="(GridStandardDeviations/NorthStandardDeviation + GridStandardDeviations/EastStandardDeviation + GridStandardDeviations/ElevationStandardDeviation) div 2"/>
									<xsl:with-param name="format" select="$DecPl2"/>
								</xsl:call-template>
							</td>
						</tr>						
					</xsl:for-each>
					</table>
				</xsl:if>
<!--koniec uśrednienia -->
				<xsl:call-template name="SeparatingLine"/>
				<!-- Tabela wektorów -->
				<h2 class="tableTile">Tabela wektorów GPS:</h2>
				<table align="center" border="1" width="100%">
					<tr>
						<th>Pkt bazowy</th>
						<th>Nr pkt</th>
						<th>Rozwiązanie</th>
						<th>Data i godzina</th>
						<th>Wys.anteny</th>
						<th>ECEF ∆X</th>
						<th>ECEF ∆Y</th>
						<th>ECEF ∆Z</th>
						<th>PDOP</th>
						<th>sat</th>
						<th>e</th>
						<th>X</th>
						<th>Y</th>
						<th>h</th>
						<th>mp</th>
						<th>mh</th>
					</tr>
					<!-- process all PointRecords except Base record -->
					<xsl:apply-templates select="/JOBFile/FieldBook/PointRecord[Deleted!='true']"/>
				</table>
				<xsl:call-template name="SeparatingLine"/>
				<!-- Tabela wektorów -->
				<xsl:if test="count(/JOBFile/FieldBook/PointRecord[Method='FromABaseline']) > 0">
				<h2 class="tableTile">Punkty wyznaczone ortogonalnie:</h2>
				<table align="center" border="1" width="100%">
					<tr>
						<th>Nr punktu</th>
						<th>Punkt pierwszy [A]</th>
						<th>Punkt drugi [B]</th>
						<th>Kierunek pomiaru</th>
						<th>Bieżąca</th>
						<th>Domiar</th>
						<th>x</th>
						<th>y</th>
					</tr>
					<xsl:for-each select="/JOBFile/FieldBook/PointRecord[Method='FromABaseline']">
					<tr>
						<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="Name"></xsl:with-param>
						</xsl:call-template>
						</td>
						<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="EnteredData/PointOne"/>
						</xsl:call-template>
						</td>
						<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="EnteredData/PointTwo"/>
						</xsl:call-template>
						</td>
						<td>
						<xsl:choose>
							<xsl:when test="EnteredData/DirectionAlongLine='InFromStart'">[A]-[B]</xsl:when>
							<xsl:when test="EnteredData/DirectionAlongLine='InFromEnd'">[B]-[A]</xsl:when>
							<xsl:when test="EnteredData/DirectionAlongLine='OutFromStart'">-[AB]</xsl:when>
							<xsl:otherwise>[AB]-</xsl:otherwise>
						</xsl:choose>
						</td>
						<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="EnteredData/DistanceOne"/>
							<xsl:with-param name="format" select="$DecPl2"/>
						</xsl:call-template>
						</td>
						<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="EnteredData/DistanceTwo"/>
							<xsl:with-param name="format" select="$DecPl2"/>
						</xsl:call-template>				
						</td>
						<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="Grid/North"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>	
						</td>
						<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="Grid/East"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>	
						</td>
					</tr>								
					</xsl:for-each>
				</table>
				</xsl:if>
				<xsl:call-template name="SeparatingLine"/>
				
				<!-- Tabela wektorów -->
				<xsl:if test="count(/JOBFile/FieldBook/PointRecord[Method='FourPointIntersection']) > 0">
				<h2 class="tableTile">Punkty wyznaczone metodą Przecięcie czteropunktowe:</h2>
				<table align="center" border="1" width="100%">
					<tr>
						<th>Nr punktu</th>
						<th>Punkt początkowy pierwszej prostej</th>
						<th>Punkt końcowy pierwszej prostej</th>
						<th>Punkt początkowy drugiej prostej</th>
						<th>Punkt końcowy drugiej prostej</th>
						<th>X</th>
						<th>Y</th>


					</tr>
					<xsl:for-each select="/JOBFile/FieldBook/PointRecord[Method='FourPointIntersection']">
					<tr>
						<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="Name"></xsl:with-param>
						</xsl:call-template>
						</td>
						<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="EnteredData/PointOne"/>
						</xsl:call-template>
						</td>
						<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="EnteredData/PointTwo"/>
						</xsl:call-template>
						</td>

						<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="EnteredData/PointThree"/>
						</xsl:call-template>
						</td>

						<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="EnteredData/PointFour"/>
						</xsl:call-template>
						</td>

						<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="Grid/North"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
						</td>
						<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="Grid/East"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
						</td>


					</tr>
					</xsl:for-each>
				</table>
				</xsl:if>

				
				<!-- Tabela wciec liniowych -->
				<xsl:if test="count(/JOBFile/FieldBook/PointRecord[Method='DistanceDistanceIntersection']) > 0">
				<h2 class="tableTile">Punkty obliczone metodą wcięcie liniowe:</h2>
				<table align="center" border="1" width="100%">
					<tr>
						<th>Nr punktu</th>
						<th>Pierwszy punkt</th>
						<th>Odległość [m]</th>
						<th>Drugi punkt</th>
						<th>Odległość [m]</th>
						<th>x</th>
						<th>y</th>
					</tr>
					<xsl:for-each select="/JOBFile/FieldBook/PointRecord[Method='DistanceDistanceIntersection']">
					<tr>
						<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="Name"></xsl:with-param>
						</xsl:call-template>
						</td>
						<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="EnteredData/PointOne"/>
						</xsl:call-template>
						</td>
						<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="EnteredData/DistanceOne"/>
							<xsl:with-param name="format" select="$DecPl2"/>
						</xsl:call-template>
						</td>
						<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="EnteredData/PointTwo"/>
						</xsl:call-template>
						</td>
						<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="EnteredData/DistanceTwo"/>
							<xsl:with-param name="format" select="$DecPl2"/>
						</xsl:call-template>
						</td>
						<td>
						<xsl:choose>
					<xsl:when test="Grid/North/text()">
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="Grid/North"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="ComputedGrid/North"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</xsl:otherwise>
					</xsl:choose>
						</td>
						<td>
						<xsl:choose>
					<xsl:when test="Grid/East/text()">
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="Grid/East"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="ComputedGrid/East"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</xsl:otherwise>
					</xsl:choose>
						</td>

					</tr>
					</xsl:for-each>
				</table>
				</xsl:if>
				
			<table border="0" width="100%" cellpadding="0">
 			  	<tr><td align="right" width="100%"></td></tr>
		  		<tr><td align="right" width="100%"></td></tr>
		  		<tr><td align="right" width="100%"><xsl:value-of select="$copyrights"/></td></tr>
		  		<tr><td align="left" width="100%"><b>Oznaczenia:</b></td></tr>
		  		<tr><td align="left" width="100%">1. Pkt bazowy - w przypadku rozwiązania sieciowego (RTN Fix) - najbliższy fizyczny punkt bazowy. Odbiorniki firmy Trimble nie wykazują pomiaru do stacji wirtualnej (VRS). Współrzędne stacji wirtualnej (VRS) są jedynie elementem pomocniczym do obliczenia danych korekcyjnych.</td></tr>
		  		<tr><td align="left" width="100%">2. RTK/RTK Fix - pomiar różnicowy do pojedynczej stacji referenycjnej</td></tr>
		  		<tr><td align="left" width="100%">3. RTN/RTN Fix - pomiar różnicowy do sieci stacji referencyjnych</td></tr>
		  		<tr><td align="left" width="100%">4. e - liczba pozycji RTK/RTN zmierzonych na punkcie</td></tr>
				<tr><td align="left" width="100%">5. sat - minimalna liczba śledzonych satelitów, na podstawie których została wyznaczona pozycja</td></tr>
			</table>
				
			</body>
		</HTML>
		
	<!-- koniec raportu -->
	</xsl:template>
	
 	<xsl:template match="ObservationPolarDeltas">
			<tr>
				<td>
					<xsl:call-template name="my-out">
						<xsl:with-param name="Val" select="Name"/>
					</xsl:call-template>
				</td>

				<td>
					<xsl:call-template name="my-out">
						<xsl:with-param name="Val" select="translate(@TimeStamp,' T','  ')"></xsl:with-param>
					</xsl:call-template>
				</td>
				<td>
					<xsl:call-template name="my-out">
						<xsl:with-param name="Val" select="Azimuth"/>
					</xsl:call-template>
				</td>
				<td>
					<xsl:call-template name="my-out">
						<xsl:with-param name="Val" select="HorizontalDistance"/>
					</xsl:call-template>
				</td>
				<td>
					<xsl:call-template name="my-out">
						<xsl:with-param name="Val" select="VerticalDistance"/>
					</xsl:call-template>
				</td>
			</tr>
</xsl:template>
 	
 
 	<xsl:template match="PointRecord">
		<xsl:for-each select="/JOBFile/FieldBook/PointRecord[Deleted!='false']"></xsl:for-each>
		
			<xsl:variable name="AID" select="AntennaID/text()"/>
			<xsl:if test="ECEFDeltas/DeltaX/text()">
				<tr>
					<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="RTK_Base"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="Name"/>
						</xsl:call-template>
					</td>
					<td>
					<xsl:choose>
						<xsl:when test="SurveyMethod='Fix'">RTK Fix</xsl:when>
						<xsl:when test="SurveyMethod='NetworkFix'">RTN Fix</xsl:when>
						<xsl:when test="SurveyMethod='RTK'">RTK</xsl:when>
						<xsl:when test="SurveyMethod='NetworkRTK'">RTN</xsl:when>
						<xsl:otherwise>Float</xsl:otherwise>
					</xsl:choose>
					</td>
					<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="translate(@TimeStamp,' T','  ')"></xsl:with-param>
	
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="/JOBFile/FieldBook/AntennaRecord[@ID=$AID]/MeasuredHeight/text()" />
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="ECEFDeltas/DeltaX"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="ECEFDeltas/DeltaY"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="ECEFDeltas/DeltaZ"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="QualityControl1/PDOP"/>
							<xsl:with-param name="format" select="$DecPl1"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="QualityControl1/NumberOfSatellites"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-out">
							<xsl:with-param name="Val" select="QualityControl1/NumberOfPositionsUsed"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="ComputedGrid/North"/>
							<xsl:with-param name="format" select="$DecPl2"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="ComputedGrid/East"/>
							<xsl:with-param name="format" select="$DecPl2"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="ComputedGrid/Elevation"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="Precision/Horizontal"/>
							<xsl:with-param name="format" select="$DecPl2"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="Precision/Vertical"/>
							<xsl:with-param name="format" select="$DecPl2"/>
						</xsl:call-template>
					</td>
				</tr>
			</xsl:if>
</xsl:template>
	
<!--
	<xsl:when test="//FieldBook/PointRecord[@ID = $ptRecID]/EchoSounding">
 -->
	
	
	<xsl:template match="CalibrationPointPair">
		<xsl:variable name="PointName" select="GridPointName"/>
		<tr>
			<td>
				<xsl:value-of select="$PointName"/>
			</td>
			<td>
				<xsl:value-of select="WGS84PointName"/>
			</td>
			<td>
				<xsl:value-of select="Dimension"/>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="/JOBFile/FieldBook/CalibrationPointRecord[GridPointName=$PointName]">
						<xsl:call-template name="my-format">
						<xsl:with-param name="Val" select="/JOBFile/FieldBook/CalibrationPointRecord[GridPointName=$PointName][last()]/HorizontalResidual/text()"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$Space"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="/JOBFile/FieldBook/CalibrationPointRecord[GridPointName=$PointName]">
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="/JOBFile/FieldBook/CalibrationPointRecord[GridPointName=$PointName] [last()]/VerticalResidual/text()"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$Space"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="Point">
		<tr>
			<td>
				<xsl:value-of select="Name"/>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="WGS84/Latitude/text()">
						<xsl:call-template name="FormatAngle">
							<xsl:with-param name="TheAngle">
								<xsl:value-of select="WGS84/Latitude"/>
							</xsl:with-param>
							<xsl:with-param name="SecDecPlaces">
								<xsl:value-of select="4"/>
							</xsl:with-param>

						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$Space"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="WGS84/Longitude/text()">
						<xsl:call-template name="FormatAngle">
							<xsl:with-param name="TheAngle">
								<xsl:value-of select="WGS84/Longitude"/>
							</xsl:with-param>
							<xsl:with-param name="SecDecPlaces">
								<xsl:value-of select="4"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$Space"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="WGS84/Height/text()">
						<xsl:value-of select="format-number(WGS84/Height, $DecPl3)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$Space"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="Code != ''">
						<xsl:value-of select="Code"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$Space"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="Grid/North/text()">
						<xsl:value-of select="format-number(Grid/North,  $DecPl3)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$Space"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="Grid/East/text()">
						<xsl:value-of select="format-number(Grid/East,  $DecPl3)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$Space"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="Grid/Elevation/text()">
						<xsl:value-of select="format-number(Grid/Elevation,  $DecPl3)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$Space"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** FieldBook Node Processing ******************** -->
	<!-- **************************************************************** -->
	<xsl:template match="FieldBook">
		<!-- Process the records under the FieldBook node in the order encountered -->
		<xsl:for-each select="*">
			<xsl:choose>
				<!-- Handle Corrections record -->
				<xsl:when test="name(current()) = 'CorrectionsRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Job Properties record -->
				<xsl:when test="name(current()) = 'JobPropertiesRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Station record -->
				<xsl:when test="name(current()) = 'StationRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle BackBearing record -->
				<xsl:when test="name(current()) = 'BackBearingRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Atmosphere record -->
				<xsl:when test="name(current()) = 'AtmosphereRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle StationResiduals record -->
				<xsl:when test="name(current()) = 'StationResiduals'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle BaseSurveyOptions record -->
				<xsl:when test="name(current()) = 'BaseSurveyOptionsRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle RoverSurveyOptions record -->
				<xsl:when test="name(current()) = 'RoverSurveyOptionsRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle SurveyEvent record -->
				<xsl:when test="name(current()) = 'SurveyEventRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Reference record (GPS base point) -->
				<xsl:when test="name(current()) = 'ReferenceRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Initialisation record -->
				<xsl:when test="name(current()) = 'InitialisationRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Feature Coding record -->
				<xsl:when test="name(current()) = 'FeatureCodingRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Instrument record -->
				<xsl:when test="name(current()) = 'InstrumentRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Instrument Details record -->
				<xsl:when test="name(current()) = 'InstrumentDetailsRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Rounds mean turned angles residuals record -->
				<xsl:when test="name(current()) = 'RoundsMeanTurnedAngleResiduals'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Road definition record -->
				<xsl:when test="name(current()) = 'RoadRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Note record -->
				<xsl:when test="name(current()) = 'NoteRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Line record -->
				<xsl:when test="name(current()) = 'LineRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Arc record -->
				<xsl:when test="name(current()) = 'ArcRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Inverse record -->
				<xsl:when test="name(current()) = 'InverseRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Calibration Point record -->
				<xsl:when test="name(current()) = 'CalibrationPointRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle GPS Equipment record -->
				<xsl:when test="name(current()) = 'GPSEquipmentRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Post Process record -->
				<xsl:when test="name(current()) = 'PostProcessRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Coordinate System record -->
				<xsl:when test="name(current()) = 'CoordinateSystemRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Projection record -->
				<xsl:when test="name(current()) = 'ProjectionRecord'">
						<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Datum record -->
				<xsl:when test="name(current()) = 'DatumRecord'">
						<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Horizontal Adjustment record -->
				<xsl:when test="name(current()) = 'HorizontalAdjustmentRecord'">
						<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Vertical Adjustment record -->
				<xsl:when test="name(current()) = 'VerticalAdjustmentRecord'">
						<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Traverse Definition record -->
				<xsl:when test="name(current()) = 'TraverseDefinitionRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle Traverse Adjustment record -->
				<xsl:when test="name(current()) = 'TraverseAdjustmentRecord'">
					<!-- TraverseAdjustmentRecords can be written out a number of -->
					<!-- times within a file but we are only really interested in -->
					<!-- the one preceding a TraverseClosureRecord -->
					<xsl:if test="name(following-sibling::*[1]) = 'TraverseClosureRecord'">
						<xsl:apply-templates select="current()"/>
					</xsl:if>
				</xsl:when>
				<!-- Handle Traverse Closure record -->
				<xsl:when test="name(current()) = 'TraverseClosureRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
				<!-- Handle COGO Transformation record -->
				<xsl:when test="name(current()) = 'CogoTransformationRecord'">
					<xsl:apply-templates select="current()"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** Reductions Node Processing ******************* -->
	<!-- **************************************************************** -->
	<xsl:template match="Reductions">
		<xsl:call-template name="BlankLine"/>
		<xsl:call-template name="SeparatingLine"/>
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">
			<B>Survey Controller Reduced Points</B>
		</CAPTION>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="BlankLine"/>
		<xsl:choose>
			<xsl:when test="@error">
				<!-- There is an error attribute so the reduced coords have not been computed -->
				<xsl:value-of select="@error"/>
				<!-- Display the error message -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="Point"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** CorrectionsRecord Output ********************* -->
	<!-- **************************************************************** -->
	<xsl:template match="CorrectionsRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Corrections</CAPTION>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">South azimuth (grid)</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:if test="SouthAzimuth[.='true']">Yes</xsl:if>
				<xsl:if test="SouthAzimuth[.='false']">No</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Grid coords</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:if test="GridOrientation[.='IncreasingNorthEast']">Increase North-East</xsl:if>
				<xsl:if test="GridOrientation[.='IncreasingSouthWest']">Increase South-West</xsl:if>
				<xsl:if test="GridOrientation[.='IncreasingNorthWest']">Increase North-West</xsl:if>
				<xsl:if test="GridOrientation[.='IncreasingSouthEast']">Increase South-East</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Magnetic declination</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="MagneticDeclination"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Distances</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:if test="Distances[.='GroundDistance']">Ground</xsl:if>
				<xsl:if test="Distances[.='GridDistance']">Grid</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Neighborhood adjustment</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:if test="NeighbourhoodAdjustment/Applied[.='true']">On</xsl:if>
				<xsl:if test="NeighbourhoodAdjustment/Applied[.='false']">Off</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="NeighbourhoodAdjustment/Applied[.='true']">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Weight exponent</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:variable name="WeightExp" select="NeighbourhoodAdjustment/WeightExponent"/>
					<xsl:value-of select="format-number($WeightExp, $DecPl1, 'Standard')"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** JobPropertiesRecord Output ******************* -->
	<!-- **************************************************************** -->
	<xsl:template match="JobPropertiesRecord">
		<xsl:if test="Reference != '' or Description != '' or Operator != '' or JobNote != ''">
			<xsl:call-template name="StartTable"/>
			<CAPTION align="left">Job properties</CAPTION>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Reference</xsl:with-param>
				<xsl:with-param name="Val" select="Reference"/>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Description</xsl:with-param>
				<xsl:with-param name="Val" select="Description"/>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Operator</xsl:with-param>
				<xsl:with-param name="Val" select="Operator"/>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Notes</xsl:with-param>
				<xsl:with-param name="Val" select="JobNote"/>
			</xsl:call-template>
			<xsl:call-template name="EndTable"/>
			<xsl:call-template name="SeparatingLine"/>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** FeatureCodingRecord Output ******************* -->
	<!-- **************************************************************** -->
	<xsl:template match="FeatureCodingRecord">
		<xsl:if test="LibraryName != ''">
			<xsl:call-template name="StartTable"/>
			<CAPTION align="left">Feature library</CAPTION>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Library name</xsl:with-param>
				<xsl:with-param name="Val" select="LibraryName"/>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Library File Name</xsl:with-param>
				<xsl:with-param name="Val" select="SourceFilename"/>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Attribute Support</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:if test="AttributesStored[.='true']">Yes</xsl:if>
					<xsl:if test="AttributesStored[.='false']">No</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="EndTable"/>
			<xsl:call-template name="SeparatingLine"/>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- **************** CoordinateSystemRecord Output ***************** -->
	<!-- **************************************************************** -->
	<xsl:template match="CoordinateSystemRecord">
		<xsl:if test="SystemName != '' or ZoneName != '' or DatumName != ''">
			<xsl:call-template name="StartTable"/>
			<CAPTION align="left">Coordinate system</CAPTION>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">System</xsl:with-param>
				<xsl:with-param name="Val" select="SystemName"/>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Zone</xsl:with-param>
				<xsl:with-param name="Val" select="ZoneName"/>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Datum</xsl:with-param>
				<xsl:with-param name="Val" select="DatumName"/>
			</xsl:call-template>
			<xsl:call-template name="EndTable"/>
			<xsl:call-template name="SeparatingLine"/>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** InstrumentRecord Output ********************* -->
	<!-- **************************************************************** -->
	<xsl:template match="InstrumentRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Instrument</CAPTION>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Instrument type</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="InstrumentTypeText">
					<xsl:with-param name="Type" select="Type"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">EDM Refractive Index</xsl:with-param>
			<xsl:with-param name="Val" select="format-number(RefractiveIndex, $DecPl1, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">EDM Carrier Wavelength</xsl:with-param>
			<xsl:with-param name="Val" select="format-number(CarrierWavelength, $DecPl1, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Horizontal Circle Mode</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:if test="SetHorizontalCircleMode[.='DoNothing']">None</xsl:if>
				<xsl:if test="SetHorizontalCircleMode[.='Zero']">Set to zero</xsl:if>
				<xsl:if test="SetHorizontalCircleMode[.='SetToAzimuth']">Set to azimuth</xsl:if>
				<xsl:if test="SetHorizontalCircleMode[.='SetHorizontalNull']">None</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Horizontal Angle Precision</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="HorizontalAnglePrecision"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Vertical Angle Precision</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="VerticalAnglePrecision"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">EDM precision</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:value-of select="format-number(EDMPrecision * 1000, DecPl0, 'Standard')"/>
				<xsl:text>mm +</xsl:text>
				<xsl:value-of select="EDMppm"/>
				<xsl:text>ppm</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="CenteringError != 0">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Centering error</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(CenteringError * $DistConvFactor, DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** Instrument Type Text Output ****************** -->
	<!-- **************************************************************** -->
	<xsl:template name="InstrumentTypeText">
		<xsl:param name="Type"/>
		<xsl:choose>
			<xsl:when test="$Type = 'TrimbleTTS'">Trimble TTS</xsl:when>
			<xsl:when test="$Type = 'Trimble3300'">Trimble 3300</xsl:when>
			<xsl:when test="$Type = 'Trimble3600Elta'">Trimble 3600 Elta</xsl:when>
			<xsl:when test="$Type = 'Trimble3600GDM'">Trimble 3600 GDM</xsl:when>
			<xsl:when test="$Type = 'Trimble600M'">Trimble 600M</xsl:when>
			<xsl:when test="$Type = 'Trimble5600'">Trimble 5600</xsl:when>
			<xsl:when test="$Type = 'TrimbleSSeries'">Trimble S Series</xsl:when>
			<xsl:when test="($Type = 'SETBasic') or ($Type = 'SETEnhanced')">Sokkia SET</xsl:when>
			<xsl:when test="$Type = 'Geodimeter400'">Geodimeter 400</xsl:when>
			<xsl:when test="$Type = 'Geodimeter500Servo'">Geodimeter 500 Servo</xsl:when>
			<xsl:when test="$Type = 'Geodimeter600'">Geodimeter 600</xsl:when>
			<xsl:when test="$Type = 'Geodimeter600Servo'">Geodimeter 600 Servo</xsl:when>
			<xsl:when test="$Type = 'Geodimeter600Robotic'">Geodimeter 600 Robotic</xsl:when>
			<xsl:when test="$Type = 'Geodimeter4000'">Geodimeter 4000</xsl:when>
			<xsl:when test="$Type = 'LeicaTC300'">Leica TC300</xsl:when>
			<xsl:when test="$Type = 'LeicaTC500'">Leica TC500</xsl:when>
			<xsl:when test="$Type = 'LeicaTC800'">Leica TC800</xsl:when>
			<xsl:when test="($Type = 'LeicaT1000_6') or ($Type = 'LeicaT1000_14')">Leica T1000</xsl:when>
			<xsl:when test="$Type = 'LeicaTC1100'">Leica TC1100</xsl:when>
			<xsl:when test="$Type = 'LeicaTC1100ServoGeoCom'">Leica TC1100 Servo</xsl:when>
			<xsl:when test="$Type = 'LeicaTC1100RoboticGeoCom'">Leica TC1100 Robotic</xsl:when>
			<xsl:when test="$Type = 'LeicaTC1600'">Leica TC1600</xsl:when>
			<xsl:when test="$Type = 'LeicaTC2000'">Leica TC2000</xsl:when>
			<xsl:when test="$Type = 'Nikon'">Nikon</xsl:when>
			<xsl:when test="$Type = 'Pentax'">Pentax</xsl:when>
			<xsl:when test="$Type = 'TopconGeneric'">Topcon</xsl:when>
			<xsl:when test="$Type = 'Topcon500'">Topcon 500</xsl:when>
			<xsl:when test="$Type = 'ZeissElta2'">Zeiss Elta2</xsl:when>
			<xsl:when test="$Type = 'ZeissElta3'">Zeiss Elta3</xsl:when>
			<xsl:when test="$Type = 'ZeissElta4'">Zeiss Elta4</xsl:when>
			<xsl:when test="$Type = 'ZeissEltaC'">Zeiss EltaC</xsl:when>
			<xsl:when test="$Type = 'ZeissRecEltaE'">Zeiss RecEltaE</xsl:when>
			<xsl:when test="$Type = 'ZeissRSeries'">Zeiss R Series</xsl:when>
			<xsl:when test="$Type = 'Manual'">Manual</xsl:when>
			<xsl:otherwise>Unknown</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- *************** InstrumentDetailsRecord Output ***************** -->
	<!-- **************************************************************** -->
	<xsl:template match="InstrumentDetailsRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Instrument details</CAPTION>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Model</xsl:with-param>
			<xsl:with-param name="Val" select="Model"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Serial number</xsl:with-param>
			<xsl:with-param name="Val" select="Serial"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Firmware version</xsl:with-param>
			<xsl:with-param name="Val" select="FirmwareVersion"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Horizontal collimation</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="InstrumentAppliedHorizontalCollimation"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Vertical collimation</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="InstrumentAppliedVerticalCollimation"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Trunnion axis tilt correction</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="TrunionAxisTiltCorrection"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************** PointRecord Output ************************ -->
	<!-- **************************************************************** -->
	<xsl:template match="SecPointRecord">
		<xsl:if test="Deleted = 'false'">
			<!-- only output if not deleted -->
			<xsl:if test="Grid">
				<xsl:call-template name="GridPoint"/>
			</xsl:if>
			<xsl:if test="Circle">
				<xsl:call-template name="Observation"/>
			</xsl:if>
			<xsl:if test="MTA">
				<xsl:call-template name="MeanTurnedAngle"/>
			</xsl:if>
			<xsl:if test="ECEF or ECEFDeltas">
				<xsl:call-template name="GPSPosOrDeltas"/>
			</xsl:if>
			<xsl:if test="WGS84">
				<xsl:call-template name="WGS84Pos"/>
			</xsl:if>
			<xsl:if test="Polar">
				<xsl:call-template name="Polar"/>
			</xsl:if>
			<xsl:if test="Features">
				<!-- Point has feature and attribute details - write them out -->
				<xsl:call-template name="FeatureAndAttributes"/>
			</xsl:if>
			<xsl:if test="Stakeout">
				<!-- Point has stakeout data - write it out -->
				<xsl:call-template name="Stakeout"/>
			</xsl:if>
			<xsl:if test="LaserOffset">
				<xsl:call-template name="LaserOffset"/>
			</xsl:if>
			<xsl:if test="ResectionStandardErrors">
				<xsl:call-template name="ResectionStandardErrors"/>
			</xsl:if>
			<xsl:if test="EnteredData">
				<xsl:call-template name="EnteredData"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- **************** Grid Point Details Output ********************* -->
	<!-- **************************************************************** -->
	<xsl:template name="GridPoint">
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">
				<xsl:text>Point</xsl:text>
				<xsl:if test="Method = 'TraverseAdjusted'">
					<xsl:text> (Adjusted)</xsl:text>
				</xsl:if>
			</xsl:with-param>
			<xsl:with-param name="Val1" select="Name"/>
			<xsl:with-param name="Hdr2">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">
						<xsl:value-of select="$northPrompt"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$eastPrompt"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Val2">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">
						<xsl:value-of select="format-number(Grid/North * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(Grid/East * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Hdr3">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">
						<xsl:value-of select="$eastPrompt"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$northPrompt"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Val3">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">
						<xsl:value-of select="format-number(Grid/East * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(Grid/North * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Hdr4" select="$elevPrompt"/>
			<xsl:with-param name="Val4" select="format-number(Grid/Elevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr5">Code</xsl:with-param>
			<xsl:with-param name="Val5" select="Code"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************* WGS-84 Position Output ********************* -->
	<!-- **************************************************************** -->
	<xsl:template name="WGS84Pos">
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Point</xsl:with-param>
			<xsl:with-param name="Val1" select="Name"/>
			<xsl:with-param name="Hdr2">Latitude</xsl:with-param>
			<xsl:with-param name="Val2">
				<xsl:call-template name="LatLongValue">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="WGS84/Latitude"/>
					</xsl:with-param>
					<xsl:with-param name="IsLat" select="'True'"/>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr3">Longitude</xsl:with-param>
			<xsl:with-param name="Val3">
				<xsl:call-template name="LatLongValue">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="WGS84/Longitude"/>
					</xsl:with-param>
					<xsl:with-param name="IsLat" select="'False'"/>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr4">Height</xsl:with-param>
			<xsl:with-param name="Val4" select="format-number(WGS84/Height * $ElevConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr5">Code</xsl:with-param>
			<xsl:with-param name="Val5" select="Code"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- **************** Observation Details Output ******************** -->
	<!-- **************************************************************** -->
	<xsl:template name="Observation">
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">
				<xsl:text>Point</xsl:text>
				<xsl:if test="Classification = 'BackSight'">
					<xsl:text> (B.S.)</xsl:text>
				</xsl:if>
			</xsl:with-param>
			<xsl:with-param name="Val1" select="Name"/>
			<xsl:with-param name="Hdr2">HA</xsl:with-param>
			<xsl:with-param name="Val2">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="Circle/HorizontalCircle"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr3">VA</xsl:with-param>
			<xsl:with-param name="Val3">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="Circle/VerticalCircle"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr4">SD</xsl:with-param>
			<xsl:with-param name="Val4" select="format-number(Circle/EDMDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr5">Code</xsl:with-param>
			<xsl:with-param name="Val5" select="Code"/>
		</xsl:call-template>
		<!-- Add a third line containing the target ht and prism constant values -->
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Target height</xsl:with-param>
			<xsl:with-param name="Val1">
				<xsl:for-each select="key('tgtID-search', TargetID)[1]">
					<xsl:value-of select="format-number(TargetHeight * $DistConvFactor, $DecPl3, 'Standard')"/>
				</xsl:for-each>
			</xsl:with-param>
			<xsl:with-param name="Hdr2">Prism constant</xsl:with-param>
			<xsl:with-param name="Val2">
				<xsl:for-each select="key('tgtID-search', TargetID)[1]">
					<xsl:value-of select="format-number(PrismConstant * 1000, $DecPl1, 'Standard')"/>
					<xsl:text>mm</xsl:text>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
		<xsl:if test="DistanceOffset">
			<!-- Add Distance offset details -->
			<xsl:call-template name="StartTable"/>
			<xsl:variable name="offsetStr">
				<xsl:choose>
					<xsl:when test="DistanceOffset/Direction">
						<!-- This is an earlier type offset record -->
						<xsl:variable name="dirStr">
							<xsl:if test="DistanceOffset/Direction = 'Right'">Right</xsl:if>
							<xsl:if test="DistanceOffset/Direction = 'Left'">Left</xsl:if>
							<xsl:if test="DistanceOffset/Direction = 'Out'">Out</xsl:if>
							<xsl:if test="DistanceOffset/Direction = 'In'">In</xsl:if>
						</xsl:variable>
						<xsl:value-of select="concat(format-number(DistanceOffset/Distance * $DistConvFactor, $DecPl3, 'Standard'), ' ', $dirStr)"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- This must be a newer type distance offset record -->
						<xsl:variable name="LeftRightStr">
							<xsl:if test="DistanceOffset/LeftRightOffset != 0.0">
								<xsl:value-of select="format-number(concat(substring('-',2 - (DistanceOffset/LeftRightOffset &lt; 0)), '1') * DistanceOffset/LeftRightOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
								<!-- Output the absolute value -->
								<xsl:if test="DistanceOffset/LeftRightOffset &lt; 0.0"> Left</xsl:if>
								<xsl:if test="DistanceOffset/LeftRightOffset &gt;= 0.0"> Right</xsl:if>
							</xsl:if>
						</xsl:variable>
						<xsl:variable name="InOutStr">
							<xsl:if test="DistanceOffset/InOutOffset != 0.0">
								<xsl:value-of select="format-number(concat(substring('-',2 - (DistanceOffset/InOutOffset &lt; 0)), '1') * DistanceOffset/InOutOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
								<!-- Output the absolute value -->
								<xsl:if test="DistanceOffset/InOutOffset &lt; 0.0"> In</xsl:if>
								<xsl:if test="DistanceOffset/InOutOffset &gt;= 0.0"> Out</xsl:if>
							</xsl:if>
						</xsl:variable>
						<xsl:variable name="DownUpStr">
							<xsl:if test="DistanceOffset/DownUpOffset != 0.0">
								<xsl:value-of select="format-number(concat(substring('-',2 - (DistanceOffset/DownUpOffset &lt; 0)), '1') * DistanceOffset/DownUpOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
								<!-- Output the absolute value -->
								<xsl:if test="DistanceOffset/DownUpOffset &lt; 0.0"> Down</xsl:if>
								<xsl:if test="DistanceOffset/DownUpOffset &gt;= 0.0"> Up</xsl:if>
							</xsl:if>
						</xsl:variable>
						<xsl:variable name="tempStr">
							<xsl:choose>
								<xsl:when test="(string-length($LeftRightStr) != 0) and (string-length($InOutStr) != 0)">
									<xsl:value-of select="concat($LeftRightStr, ', ', $InOutStr)"/>
								</xsl:when>
								<xsl:when test="(string-length($LeftRightStr) != 0) and (string-length($InOutStr) = 0)">
									<xsl:value-of select="$LeftRightStr"/>
								</xsl:when>
								<xsl:when test="(string-length($LeftRightStr) = 0) and (string-length($InOutStr) != 0)">
									<xsl:value-of select="$InOutStr"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="''"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="(string-length($tempStr) != 0) and (string-length($DownUpStr) != 0)">
								<xsl:value-of select="concat($tempStr, ', ', $DownUpStr)"/>
							</xsl:when>
							<xsl:when test="(string-length($tempStr) != 0) and (string-length($DownUpStr) = 0)">
								<xsl:value-of select="$tempStr"/>
							</xsl:when>
							<xsl:when test="(string-length($tempStr) = 0) and (string-length($DownUpStr) != 0)">
								<xsl:value-of select="$DownUpStr"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="''"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">
					<xsl:text>Distance offset</xsl:text>
					<xsl:value-of select="concat(' (', Name, ')')"/>
				</xsl:with-param>
				<xsl:with-param name="Val" select="$offsetStr"/>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Raw Observation</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:text>HA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="DistanceOffset/RawObservation/HorizontalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> VA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="DistanceOffset/RawObservation/VerticalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> SD: </xsl:text>
					<xsl:value-of select="format-number(DistanceOffset/RawObservation/EDMDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
		<xsl:if test="CircularObject">
			<!-- Add circular object details -->
			<xsl:call-template name="StartTable"/>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">
					<xsl:text>Circular object</xsl:text>
					<xsl:value-of select="concat(' (', Name, ')')"/>
				</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:text>Radius: </xsl:text>
					<xsl:value-of select="format-number(CircularObject/Radius * $DistConvFactor, $DecPl3, 'Standard')"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">First Raw Observation</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:text>HA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="CircularObject/FirstRawObservation/HorizontalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> VA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="CircularObject/FirstRawObservation/VerticalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> SD: </xsl:text>
					<xsl:value-of select="format-number(CircularObject/FirstRawObservation/EDMDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Second Raw Observation</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:text>HA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="CircularObject/SecondRawObservation/HorizontalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> VA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="CircularObject/SecondRawObservation/VerticalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
		<xsl:if test="RemoteObject">
			<!-- Add Remote object details -->
			<xsl:call-template name="StartTable"/>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">
					<xsl:text>Remote object</xsl:text>
					<xsl:value-of select="concat(' (', Name, ')')"/>
				</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:variable name="ObjHeight">
						<xsl:if test="RemoteObject/ObjectHeight != ''">
							<xsl:text>Object height</xsl:text>
							<xsl:value-of select="concat(': ', format-number(RemoteObject/ObjectHeight * $DistConvFactor, $DecPl3, 'Standard'), ' ')"/>
						</xsl:if>
					</xsl:variable>
					<xsl:variable name="ObjWidth">
						<xsl:if test="RemoteObject/ObjectWidth != ''">
							<xsl:text>Object width</xsl:text>
							<xsl:value-of select="concat(': ', format-number(RemoteObject/ObjectWidth * $DistConvFactor, $DecPl3, 'Standard'))"/>
						</xsl:if>
					</xsl:variable>
					<xsl:value-of select="concat($ObjHeight, $ObjWidth)"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Raw Observation</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:text>HA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="RemoteObject/RawObservation/HorizontalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> VA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="RemoteObject/RawObservation/VerticalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
		<xsl:if test="AngleOffset">
			<!-- Add Angle offset details -->
			<xsl:call-template name="StartTable"/>
			<xsl:variable name="offsetStr">
				<xsl:choose>
					<xsl:when test="Method = 'HorizontalAngleOffset'">H. Angle offset</xsl:when>
					<xsl:when test="Method = 'VerticalAngleOffset'">V. Angle offset</xsl:when>
					<xsl:otherwise>Angle offset</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr" select="concat($offsetStr, ' (', Name, ')')"/>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">First Raw Observation</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:text>HA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="AngleOffset/FirstRawObservation/HorizontalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> VA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="AngleOffset/FirstRawObservation/VerticalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> SD: </xsl:text>
					<xsl:value-of select="format-number(AngleOffset/FirstRawObservation/EDMDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Second Raw Observation</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:text>HA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="AngleOffset/SecondRawObservation/HorizontalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> VA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="AngleOffset/SecondRawObservation/VerticalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
		<xsl:if test="DualPrismOffset">
			<!-- Add Dual prism offset details -->
			<xsl:call-template name="StartTable"/>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">
					<xsl:text>Dual-prism offset</xsl:text>
					<xsl:value-of select="concat(' (', Name, ')')"/>
				</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:text>Distance BC: </xsl:text>
					<xsl:value-of select="format-number(DualPrismOffset/DistanceBC * $DistConvFactor, $DecPl3, 'Standard')"/>
					<xsl:text> Computed AB: </xsl:text>
					<xsl:value-of select="format-number(DualPrismOffset/CalculatedDistanceAB * $DistConvFactor, $DecPl3, 'Standard')"/>
					<xsl:text> Prism constant A: </xsl:text>
					<xsl:value-of select="format-number(DualPrismOffset/PrismConstantA * 1000, $DecPl3, 'Standard')"/>
					<xsl:text>mm Prism constant B: </xsl:text>
					<xsl:value-of select="format-number(DualPrismOffset/PrismConstantB * 1000, $DecPl3, 'Standard')"/>
					<xsl:text>mm</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Prism A Observation</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:text>HA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="DualPrismOffset/PrismAObservation/HorizontalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> VA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="DualPrismOffset/PrismAObservation/VerticalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> SD: </xsl:text>
					<xsl:value-of select="format-number(DualPrismOffset/PrismAObservation/EDMDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Prism B Observation</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:text>HA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="DualPrismOffset/PrismBObservation/HorizontalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> VA: </xsl:text>
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="DualPrismOffset/PrismBObservation/VerticalCircle"/>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> SD: </xsl:text>
					<xsl:value-of select="format-number(DualPrismOffset/PrismBObservation/EDMDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
		<xsl:if test="ObservationPolarDeltas">
			<xsl:call-template name="StartTable"/>
			<xsl:call-template name="OutputTableLine">
				<xsl:with-param name="Hdr1">Deltas</xsl:with-param>
				<xsl:with-param name="Val1" select="Name"/>
				<xsl:with-param name="Hdr2">Azimuth</xsl:with-param>
				<xsl:with-param name="Val2">
					<xsl:call-template name="FormatAzimuth">
						<xsl:with-param name="TheAzimuth">
							<xsl:value-of select="ObservationPolarDeltas/Azimuth"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="Hdr3">H.Dist</xsl:with-param>
				<xsl:with-param name="Val3" select="format-number(ObservationPolarDeltas/HorizontalDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
				<xsl:with-param name="Hdr4">V.Dist</xsl:with-param>
				<xsl:with-param name="Val4" select="format-number(ObservationPolarDeltas/VerticalDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************************* Polar Output ************************* -->
	<!-- **************************************************************** -->
	<xsl:template name="Polar">
		<xsl:call-template name="StartTable"/>
		<xsl:variable name="AzType">
			<xsl:if test="AzimuthType[.='Grid']">Azimuth (grid)</xsl:if>
			<xsl:if test="AzimuthType[.='Magnetic']">Azimuth (mag)</xsl:if>
			<xsl:if test="AzimuthType[.='Local']">Azimuth (local)</xsl:if>
			<xsl:if test="AzimuthType[.='WGS84']">Azimuth (WGS84)</xsl:if>
			<xsl:if test="AzimuthType[.='Sun']">Azimuth (Sun)</xsl:if>
		</xsl:variable>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Polar</xsl:with-param>
			<xsl:with-param name="Val1" select="Name"/>
			<xsl:with-param name="Hdr2" select="$AzType"/>
			<xsl:with-param name="Val2">
				<xsl:call-template name="FormatAzimuth">
					<xsl:with-param name="TheAzimuth">
						<xsl:value-of select="Polar/Azimuth"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr3">H.Dist</xsl:with-param>
			<xsl:with-param name="Val3" select="format-number(Polar/HorizontalDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr4">V.Dist</xsl:with-param>
			<xsl:with-param name="Val4" select="format-number(Polar/VerticalDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr5">Code</xsl:with-param>
			<xsl:with-param name="Val5" select="Code"/>
		</xsl:call-template>
		<!-- Add second line providing the source point for the polar data -->
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr2">Source point</xsl:with-param>
			<xsl:with-param name="Val2" select="SourcePoint"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************** Mean Turned Angle Details Output **************** -->
	<!-- **************************************************************** -->
	<xsl:template name="MeanTurnedAngle">
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Point (MTA)</xsl:with-param>
			<xsl:with-param name="Val1" select="Name"/>
			<xsl:with-param name="Hdr2">HA</xsl:with-param>
			<xsl:with-param name="Val2">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="MTA/HorizontalCircle"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr3">VA</xsl:with-param>
			<xsl:with-param name="Val3">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="MTA/VerticalCircle"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr4">SD</xsl:with-param>
			<xsl:with-param name="Val4" select="format-number(MTA/EDMDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr5">Code</xsl:with-param>
			<xsl:with-param name="Val5" select="Code"/>
		</xsl:call-template>
<!-- Add a third line containing the target ht and prism constant values -->
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Target height</xsl:with-param>
			<xsl:with-param name="Val1">
				<xsl:for-each select="key('tgtID-search', TargetID)[1]">
					<xsl:value-of select="format-number(TargetHeight * $DistConvFactor, $DecPl3, 'Standard')"/>
				</xsl:for-each>
			</xsl:with-param>
			<xsl:with-param name="Hdr2">Prism constant</xsl:with-param>
			<xsl:with-param name="Val2">
				<xsl:for-each select="key('tgtID-search', TargetID)[1]">
					<xsl:value-of select="format-number(PrismConstant * 1000, $DecPl1, 'Standard')"/>
					<xsl:text>mm</xsl:text>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ********************** GPS Deltas Output *********************** -->
	<!-- **************************************************************** -->
	<xsl:template name="GPSPosOrDeltas">
		<xsl:call-template name="StartTable"/>
		<xsl:variable name="XPrompt">
			<xsl:if test="ECEF">X</xsl:if>
			<xsl:if test="ECEFDeltas">ΔX</xsl:if>
		</xsl:variable>
		<xsl:variable name="YPrompt">
			<xsl:if test="ECEF">Y</xsl:if>
			<xsl:if test="ECEFDeltas">ΔY</xsl:if>
		</xsl:variable>
		<xsl:variable name="ZPrompt">
			<xsl:if test="ECEF">Z</xsl:if>
			<xsl:if test="ECEFDeltas">ΔZ</xsl:if>
		</xsl:variable>
		<xsl:variable name="XVal">
			<xsl:if test="ECEF">
				<xsl:value-of select="format-number(ECEF/X * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:if>
			<xsl:if test="ECEFDeltas">
				<xsl:value-of select="format-number(ECEFDeltas/DeltaX * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="YVal">
			<xsl:if test="ECEF">
				<xsl:value-of select="format-number(ECEF/Y * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:if>
			<xsl:if test="ECEFDeltas">
				<xsl:value-of select="format-number(ECEFDeltas/DeltaY * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="ZVal">
			<xsl:if test="ECEF">
				<xsl:value-of select="format-number(ECEF/Z * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:if>
			<xsl:if test="ECEFDeltas">
				<xsl:value-of select="format-number(ECEFDeltas/DeltaZ * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:if>
		</xsl:variable>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Point</xsl:with-param>
			<xsl:with-param name="Val1" select="Name"/>
			<xsl:with-param name="Hdr2" select="$XPrompt"/>
			<xsl:with-param name="Val2" select="$XVal"/>
			<xsl:with-param name="Hdr3" select="$YPrompt"/>
			<xsl:with-param name="Val3" select="$YVal"/>
			<xsl:with-param name="Hdr4" select="$ZPrompt"/>
			<xsl:with-param name="Val4" select="$ZVal"/>
			<xsl:with-param name="Hdr5">Code</xsl:with-param>
			<xsl:with-param name="Val5" select="Code"/>
		</xsl:call-template>
		<!-- Add second line with antenna details and hz and vt precision values -->
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Antenna height</xsl:with-param>
			<xsl:with-param name="Val1">
				<xsl:for-each select="key('antennaID-search', AntennaID)[1]">
					<xsl:value-of select="format-number(MeasuredHeight * $DistConvFactor, $DecPl3, 'Standard')"/>
				</xsl:for-each>
			</xsl:with-param>
			<xsl:with-param name="Hdr2">Type</xsl:with-param>
			<xsl:with-param name="Val2">
				<xsl:for-each select="key('antennaID-search', AntennaID)[1]">
					<xsl:choose>
						<xsl:when test="MeasurementType = 'Corrected'">Corrected</xsl:when>
						<xsl:otherwise>Uncorrected</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:with-param>
			<xsl:with-param name="Hdr3">Hz Prec</xsl:with-param>
			<xsl:with-param name="Val3" select="format-number(Precision/Horizontal * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr4">Vt Prec</xsl:with-param>
			<xsl:with-param name="Val4" select="format-number(Precision/Vertical * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<!-- If writing a detailed report and there are QC details available - write them out -->
			<xsl:if test="QualityControl2">
				<xsl:call-template name="OutputTableLine">
					<xsl:with-param name="Hdr1">QC 2</xsl:with-param>
					<xsl:with-param name="Hdr2">Satellites</xsl:with-param>
					<xsl:with-param name="Val2" select="QualityControl2/NumberOfSatellites"/>
					<xsl:with-param name="Hdr3">VCV xx (m&#0178;)</xsl:with-param>
					<xsl:with-param name="Val3" select="format-number(QualityControl2/VCVxx, $DecPl6, 'Standard')"/>
					<xsl:with-param name="Hdr4">VCV xy (m&#0178;)</xsl:with-param>
					<xsl:with-param name="Val4" select="format-number(QualityControl2/VCVxy, $DecPl6, 'Standard')"/>
					<xsl:with-param name="Hdr5">VCV xz (m&#0178;)</xsl:with-param>
					<xsl:with-param name="Val5" select="format-number(QualityControl2/VCVxz, $DecPl6, 'Standard')"/>
				</xsl:call-template>
				<xsl:call-template name="OutputTableLine">
					<xsl:with-param name="Hdr2">Error scale (m)</xsl:with-param>
					<xsl:with-param name="Val2" select="format-number(QualityControl2/ErrorScale, $DecPl3, 'Standard')"/>
					<xsl:with-param name="Hdr4">VCV yy (m&#0178;)</xsl:with-param>
					<xsl:with-param name="Val4" select="format-number(QualityControl2/VCVyy, $DecPl6, 'Standard')"/>
					<xsl:with-param name="Hdr5">VCV yz (m&#0178;)</xsl:with-param>
					<xsl:with-param name="Val5" select="format-number(QualityControl2/VCVyz, $DecPl6, 'Standard')"/>
				</xsl:call-template>
				<xsl:call-template name="OutputTableLine">
					<xsl:with-param name="Hdr5">VCV zz (m&#0178;)</xsl:with-param>
					<xsl:with-param name="Val5" select="format-number(QualityControl2/VCVzz, $DecPl6, 'Standard')"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="QualityControl3">
				<xsl:call-template name="OutputTableLine">
					<xsl:with-param name="Hdr1">QC 3</xsl:with-param>
					<xsl:with-param name="Hdr2">σ North</xsl:with-param>
					<xsl:with-param name="Val2" select="format-number(QualityControl3/SigmaNorth, $DecPl3, 'Standard')"/>
					<xsl:with-param name="Hdr3">σ East</xsl:with-param>
					<xsl:with-param name="Val3" select="format-number(QualityControl3/SigmaEast, $DecPl3, 'Standard')"/>
					<xsl:with-param name="Hdr4">σ Elevation</xsl:with-param>
					<xsl:with-param name="Val4" select="format-number(QualityControl3/SigmaElevation, $DecPl3, 'Standard')"/>
					<xsl:with-param name="Hdr5">Covariance</xsl:with-param>
					<xsl:with-param name="Val5" select="format-number(QualityControl3/CovarianceNorthEast, $DecPl3, 'Standard')"/>
				</xsl:call-template>
				<xsl:call-template name="OutputTableLine">
					<xsl:with-param name="Hdr2">Semi-major axis</xsl:with-param>
					<xsl:with-param name="Val2" select="format-number(QualityControl3/SemiMajorAxis, $DecPl3, 'Standard')"/>
					<xsl:with-param name="Hdr3">Semi-minor axis</xsl:with-param>
					<xsl:with-param name="Val3" select="format-number(QualityControl3/SemiMinorAxis, $DecPl3, 'Standard')"/>
					<xsl:with-param name="Hdr4">Orientation</xsl:with-param>
					<xsl:with-param name="Val4">
						<xsl:call-template name="FormatAngle">
							<xsl:with-param name="TheAngle">
								<xsl:value-of select="QualityControl2/Orientation"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="Hdr5">Unit variance</xsl:with-param>
					<xsl:with-param name="Val5" select="format-number(QualityControl3/UnitVariance, $DecPl3, 'Standard')"/>
				</xsl:call-template>
			</xsl:if>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ********************* Laser Offset Output ********************** -->
	<!-- **************************************************************** -->
	<xsl:template name="LaserOffset">
		<xsl:call-template name="StartTable"/>
		<xsl:variable name="AzType">
			<xsl:if test="AzimuthType[.='Grid']">Grid</xsl:if>
			<xsl:if test="AzimuthType[.='Magnetic']">Mag</xsl:if>
			<xsl:if test="AzimuthType[.='Local']">Local</xsl:if>
			<xsl:if test="AzimuthType[.='WGS84']">WGS84</xsl:if>
			<xsl:if test="AzimuthType[.='Sun']">Sun</xsl:if>
		</xsl:variable>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Laser point</xsl:with-param>
			<xsl:with-param name="Hdr2">Base point</xsl:with-param>
			<xsl:with-param name="Val2" select="BasePoint"/>
			<xsl:with-param name="Hdr3">Laser height</xsl:with-param>
			<xsl:with-param name="Val3" select="format-number(LaserHeight * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr4">Azimuth</xsl:with-param>
			<xsl:with-param name="Val4" select="$AzType"/>
			<xsl:with-param name="Hdr5">
				<xsl:if test="MagneticDeclination">Magnetic declination</xsl:if>
			</xsl:with-param>
			<xsl:with-param name="Val5">
				<xsl:if test="MagneticDeclination">
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="MagneticDeclination"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Point</xsl:with-param>
			<xsl:with-param name="Val1" select="Name"/>
			<xsl:with-param name="Hdr2">Azimuth</xsl:with-param>
			<xsl:with-param name="Val2">
				<xsl:call-template name="FormatAzimuth">
					<xsl:with-param name="TheAzimuth">
						<xsl:value-of select="LaserOffset/Azimuth"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr3">VA</xsl:with-param>
			<xsl:with-param name="Val3">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="LaserOffset/VerticalAngle"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr4">SD</xsl:with-param>
			<xsl:with-param name="Val4" select="format-number(LaserOffset/SlopeDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr5">Target height</xsl:with-param>
			<xsl:with-param name="Val5" select="format-number(LaserTargetHeight * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- **************** Resection Standard Errors Output ************** -->
	<!-- **************************************************************** -->
	<xsl:template name="ResectionStandardErrors">
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Resection</xsl:with-param>
			<xsl:with-param name="Val1" select="Name"/>
			<xsl:with-param name="Hdr2">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">Std Error (N)</xsl:when>
					<xsl:otherwise>Std Error (E)</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Val2">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">
						<xsl:value-of select="format-number(ResectionStandardErrors/NorthStandardError * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(ResectionStandardErrors/EastStandardError * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Hdr3">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">Std Error (E)</xsl:when>
					<xsl:otherwise>Std Error (N)</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Val3">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">
						<xsl:value-of select="format-number(ResectionStandardErrors/EastStandardError * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(ResectionStandardErrors/NorthStandardError * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Hdr4">Std Error (El)</xsl:with-param>
			<xsl:with-param name="Val4" select="format-number(ResectionStandardErrors/ElevationStandardError * $ElevConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** Entered Data Record Output ******************* -->
	<!-- **************************************************************** -->
	<xsl:template name="EnteredData">
		<xsl:choose>
			<xsl:when test="EnteredData/Method[.='BearingDistanceIntersection'] or 
                    EnteredData/Method[.='BearingBearingIntersection'] or
                    EnteredData/Method[.='DistanceDistanceIntersection']">
				<xsl:call-template name="COGOStdIntersection"/>
			</xsl:when>
			<xsl:when test="EnteredData/Method[.='FourPointIntersection']">
				<xsl:call-template name="FourPointIntersection"/>
			</xsl:when>
			<xsl:when test="EnteredData/Method[.='BearingAndDistanceFromAPoint'] or 
                    (EnteredData/Method[.='BearingDistancePointIntersection'] and
                     EnteredData/AzimuthType[.!='Sun'])">
				<xsl:call-template name="BearingDistanceFromPoint"/>
			</xsl:when>
			<xsl:when test="EnteredData/Method[.='TurnedAngleAndDistance'] or
                    (EnteredData/Method[.='BearingDistancePointIntersection'] and
                     EnteredData/AzimuthType[.='Sun'])">
				<xsl:call-template name="TurnedAngleAndDistance"/>
			</xsl:when>
			<xsl:when test="EnteredData/Method[.='FromABaseline']">
				<xsl:call-template name="FromABaseline"/>
			</xsl:when>
			<xsl:when test="EnteredData/Method[.='BearngVerticalPlaneIntersection']">
				<xsl:call-template name="BearngVerticalPlaneIntersection"/>
			</xsl:when>
		</xsl:choose>
		<xsl:call-template name="BlankLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****** Handle Brg-Brg, Brg-Dist and Dist-Dist Int Output ******* -->
	<!-- **************************************************************** -->
	<xsl:template name="COGOStdIntersection">
		<xsl:variable name="Az1Type">
			<xsl:choose>
				<xsl:when test="EnteredData/AzimuthType[.='Grid']">Azimuth 1 (grid)</xsl:when>
				<xsl:when test="EnteredData/AzimuthType[.='Local']">Azimuth 1 (local)</xsl:when>
				<xsl:when test="EnteredData/AzimuthType[.='WGS84']">Azimuth 1 (WGS84)</xsl:when>
				<xsl:otherwise>Azimuth 1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="Az2Type">
			<xsl:choose>
				<xsl:when test="EnteredData/AzimuthType[.='Grid']">Azimuth 2 (grid)</xsl:when>
				<xsl:when test="EnteredData/AzimuthType[.='Local']">Azimuth 2 (local)</xsl:when>
				<xsl:when test="EnteredData/AzimuthType[.='WGS84']">Azimuth 2 (WGS84)</xsl:when>
				<xsl:otherwise>Azimuth 2</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="Dist1Type">
			<xsl:if test="EnteredData/DistanceType[.='Grid']">Distance 1 (grid)</xsl:if>
			<xsl:if test="EnteredData/DistanceType[.='Ground']">Distance 1 (grnd)</xsl:if>
			<xsl:if test="EnteredData/DistanceType[.='Ellipsoid']">Distance 1 (ell)</xsl:if>
		</xsl:variable>
		<xsl:variable name="Dist2Type">
			<xsl:if test="EnteredData/DistanceType[.='Grid']">Distance 2 (grid)</xsl:if>
			<xsl:if test="EnteredData/DistanceType[.='Ground']">Distance 2 (grnd)</xsl:if>
			<xsl:if test="EnteredData/DistanceType[.='Ellipsoid']">Distance 2 (ell)</xsl:if>
		</xsl:variable>
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Calc details</xsl:with-param>
			<xsl:with-param name="Val1">
				<xsl:if test="EnteredData/Method[.='BearingDistanceIntersection']">Brng-dist intersect</xsl:if>
				<xsl:if test="EnteredData/Method[.='BearingBearingIntersection']">Brng-brng intersect</xsl:if>
				<xsl:if test="EnteredData/Method[.='DistanceDistanceIntersection']">Dist-dist intersect</xsl:if>
			</xsl:with-param>
			<xsl:with-param name="Hdr2">Point 1</xsl:with-param>
			<xsl:with-param name="Val2" select="EnteredData/PointOne"/>
			<xsl:with-param name="Hdr3">Point 2</xsl:with-param>
			<xsl:with-param name="Val3" select="EnteredData/PointTwo"/>
			<xsl:with-param name="Hdr4">
				<xsl:choose>
					<xsl:when test="EnteredData/AzimuthOne != ''">
						<xsl:value-of select="$Az1Type"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$Dist1Type"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Val4">
				<xsl:choose>
					<xsl:when test="EnteredData/AzimuthOne != ''">
						<xsl:call-template name="FormatAzimuth">
							<xsl:with-param name="TheAzimuth">
								<xsl:value-of select="EnteredData/AzimuthOne"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(EnteredData/DistanceOne * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Hdr5">
				<xsl:choose>
					<xsl:when test="EnteredData/AzimuthTwo != ''">
						<xsl:value-of select="$Az2Type"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$Dist2Type"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Val5">
				<xsl:choose>
					<xsl:when test="EnteredData/AzimuthTwo != ''">
						<xsl:call-template name="FormatAzimuth">
							<xsl:with-param name="TheAzimuth">
								<xsl:value-of select="EnteredData/AzimuthTwo"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(EnteredData/DistanceTwo * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************* Handle Four Point Intersection Output ************ -->
	<!-- **************************************************************** -->
	<xsl:template name="FourPointIntersection">
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Calc details</xsl:with-param>
			<xsl:with-param name="Val1">Four point intersection</xsl:with-param>
			<xsl:with-param name="Hdr2">Start point (line 1)</xsl:with-param>
			<xsl:with-param name="Val2" select="EnteredData/PointOne"/>
			<xsl:with-param name="Hdr3">End point (line 1)</xsl:with-param>
			<xsl:with-param name="Val3" select="EnteredData/PointTwo"/>
			<xsl:with-param name="Hdr4">Start point (line 2)</xsl:with-param>
			<xsl:with-param name="Val4" select="EnteredData/PointThree"/>
			<xsl:with-param name="Hdr5">End point (line 2)</xsl:with-param>
			<xsl:with-param name="Val5" select="EnteredData/PointFour"/>
		</xsl:call-template>
		<!-- Add a second line with the vertical offset value -->
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr2">Vertical offset</xsl:with-param>
			<xsl:with-param name="Val2" select="format-number(EnteredData/VerticalOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******** Handle Bearing and Distance from Point Output ********* -->
	<!-- **************************************************************** -->
	<xsl:template name="BearingDistanceFromPoint">
		<xsl:variable name="AzType">
			<xsl:choose>
				<xsl:when test="EnteredData/AzimuthType[.='Grid']">Azimuth (grid)</xsl:when>
				<xsl:when test="EnteredData/AzimuthType[.='Magnetic']">Azimuth (mag)</xsl:when>
				<xsl:when test="EnteredData/AzimuthType[.='Local']">Azimuth (local)</xsl:when>
				<xsl:when test="EnteredData/AzimuthType[.='WGS84']">Azimuth (WGS84)</xsl:when>
				<xsl:otherwise>Azimuth</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="DistType">
			<xsl:if test="EnteredData/DistanceType[.='Grid']">Distance (grid)</xsl:if>
			<xsl:if test="EnteredData/DistanceType[.='Ground']">Distance (grnd)</xsl:if>
			<xsl:if test="EnteredData/DistanceType[.='Ellipsoid']">Distance (ell)</xsl:if>
		</xsl:variable>
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Calc details</xsl:with-param>
			<xsl:with-param name="Val1">Brng-dist from a point</xsl:with-param>
			<xsl:with-param name="Hdr2">Start point</xsl:with-param>
			<xsl:with-param name="Val2" select="EnteredData/PointOne"/>
			<xsl:with-param name="Hdr3" select="$AzType"/>
			<xsl:with-param name="Val3">
				<xsl:call-template name="FormatAzimuth">
					<xsl:with-param name="TheAzimuth">
						<xsl:value-of select="EnteredData/AzimuthOne"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr4" select="$DistType"/>
			<xsl:with-param name="Val4" select="format-number(EnteredData/DistanceOne * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr5">Vertical offset</xsl:with-param>
			<xsl:with-param name="Val5" select="format-number(EnteredData/VerticalOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- *********** Handle Turned Angle and Distance Output ************ -->
	<!-- **************************************************************** -->
	<xsl:template name="TurnedAngleAndDistance">
		<xsl:variable name="AzType">
			<xsl:choose>
				<xsl:when test="EnteredData/AzimuthType[.='Grid']">Azimuth (grid)</xsl:when>
				<xsl:when test="EnteredData/AzimuthType[.='Magnetic']">Azimuth (mag)</xsl:when>
				<xsl:when test="EnteredData/AzimuthType[.='Local']">Azimuth (local)</xsl:when>
				<xsl:when test="EnteredData/AzimuthType[.='WGS84']">Azimuth (WGS84)</xsl:when>
				<xsl:otherwise>Azimuth</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="DistType">
			<xsl:if test="EnteredData/DistanceType[.='Grid']">Distance (grid)</xsl:if>
			<xsl:if test="EnteredData/DistanceType[.='Ground']">Distance (grnd)</xsl:if>
			<xsl:if test="EnteredData/DistanceType[.='Ellipsoid']">Distance (ell)</xsl:if>
		</xsl:variable>
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Calc details</xsl:with-param>
			<xsl:with-param name="Val1">
				<xsl:choose>
					<xsl:when test="EnteredData/AzimuthType = 'Sun'">Brng-dist from a point</xsl:when>
					<xsl:otherwise>Turned angle and distance</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Hdr2">Start point</xsl:with-param>
			<xsl:with-param name="Val2" select="EnteredData/PointOne"/>
			<xsl:with-param name="Hdr3">
				<xsl:choose>
					<xsl:when test="EnteredData/PointTwo != ''">End point</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$AzType"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Val3">
				<xsl:choose>
					<xsl:when test="EnteredData/PointTwo != ''">
						<xsl:value-of select="EnteredData/PointTwo"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="FormatAzimuth">
							<xsl:with-param name="TheAzimuth">
								<xsl:value-of select="EnteredData/AzimuthOne"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Hdr4">
				<xsl:choose>
					<xsl:when test="EnteredData/AzimuthType = 'Sun'">Angle from sun</xsl:when>
					<xsl:otherwise>Turned angle</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Val4">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="EnteredData/TurnedAngle"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<!-- Add a second line with the dist and vertical offset values -->
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr2" select="$DistType"/>
			<xsl:with-param name="Val2" select="format-number(EnteredData/DistanceOne * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr3">Vertical offset</xsl:with-param>
			<xsl:with-param name="Val3" select="format-number(EnteredData/VerticalOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- **************** Handle From a Baseline Output ***************** -->
	<!-- **************************************************************** -->
	<xsl:template name="FromABaseline">
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Calc details</xsl:with-param>
			<xsl:with-param name="Val1">From a baseline</xsl:with-param>
			<xsl:with-param name="Hdr2">Start point</xsl:with-param>
			<xsl:with-param name="Val2" select="EnteredData/PointOne"/>
			<xsl:with-param name="Hdr3">End point</xsl:with-param>
			<xsl:with-param name="Val3" select="EnteredData/PointTwo"/>
			<xsl:with-param name="Hdr4">Distance</xsl:with-param>
			<xsl:with-param name="Val4" select="format-number(EnteredData/DistanceOne * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr5">Direction</xsl:with-param>
			<xsl:with-param name="Val5">
				<xsl:if test="EnteredData/DirectionAlongLine[.='InFromStart']">In from start</xsl:if>
				<xsl:if test="EnteredData/DirectionAlongLine[.='OutFromStart']">Out from start</xsl:if>
				<xsl:if test="EnteredData/DirectionAlongLine[.='InFromEnd']">In from end</xsl:if>
				<xsl:if test="EnteredData/DirectionAlongLine[.='OutFromEnd']">Out from end</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<!-- Add a second line with the offset value and distance type -->
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr2">Offset</xsl:with-param>
			<xsl:with-param name="Val2" select="format-number(EnteredData/DistanceTwo * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr3">Distances</xsl:with-param>
			<xsl:with-param name="Val3" select="EnteredData/DistanceType"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- *********** Handle Vertical Plane Intersection Output ********** -->
	<!-- **************************************************************** -->
	<xsl:template name="BearngVerticalPlaneIntersection">
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Calc details</xsl:with-param>
			<xsl:with-param name="Val1">Vertical plane and angle</xsl:with-param>
			<xsl:with-param name="Hdr2">Point 1</xsl:with-param>
			<xsl:with-param name="Val2" select="EnteredData/PointOne"/>
			<xsl:with-param name="Hdr3">Point 2</xsl:with-param>
			<xsl:with-param name="Val3" select="EnteredData/PointTwo"/>
			<xsl:with-param name="Hdr4">HA</xsl:with-param>
			<xsl:with-param name="Val4">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="EnteredData/VerticalPlaneIntersectionRay/HorizontalCircle"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr5">VA</xsl:with-param>
			<xsl:with-param name="Val5">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="EnteredData/VerticalPlaneIntersectionRay/VerticalCircle"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- *************** Features and Attributes Output ***************** -->
	<!-- **************************************************************** -->
	<xsl:template name="FeatureAndAttributes">
		<xsl:for-each select="Features/Feature">
			<xsl:call-template name="StartTable"/>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">
					<xsl:text>Feature</xsl:text>
					<xsl:value-of select="concat(' (', ../../Name, ')')"/>
				</xsl:with-param>
				<xsl:with-param name="Val" select="@Name"/>
			</xsl:call-template>
			<xsl:for-each select="Attribute">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr" select="Name"/>
					<xsl:with-param name="Val" select="Value"/>
				</xsl:call-template>
			</xsl:for-each>
			<xsl:call-template name="EndTable"/>
		</xsl:for-each>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ********************* Stakeout Data Output ********************* -->
	<!-- **************************************************************** -->
	<xsl:template name="Stakeout">
		<xsl:if test="Stakeout/PointDesign">
			<xsl:call-template name="PointDesign"/>
		</xsl:if>
		<xsl:if test="Stakeout/LineDesign">
			<xsl:call-template name="LineDesign"/>
		</xsl:if>
		<xsl:if test="Stakeout/ArcDesign">
			<xsl:call-template name="ArcDesign"/>
		</xsl:if>
		<xsl:if test="Stakeout/SlopeDesign">
			<xsl:call-template name="SlopeDesign"/>
		</xsl:if>
		<xsl:if test="Stakeout/DTMDesign">
			<xsl:call-template name="DTMDesign"/>
		</xsl:if>
		<xsl:if test="Stakeout/RoadDesign">
			<xsl:call-template name="RoadDesign"/>
		</xsl:if>
		<xsl:if test="Stakeout/GridDeltas">
			<xsl:call-template name="GridDeltas"/>
		</xsl:if>
		<xsl:if test="Stakeout/LinearDeltas">
			<xsl:call-template name="LinearDeltas"/>
		</xsl:if>
		<xsl:if test="Stakeout/DTMDeltas">
			<xsl:call-template name="DTMDeltas"/>
		</xsl:if>
		<xsl:if test="Stakeout/PolarDeltas">
			<xsl:call-template name="PolarDeltas"/>
		</xsl:if>
		<xsl:if test="Stakeout/CatchPoint">
			<xsl:call-template name="CatchPoint"/>
		</xsl:if>
		<xsl:if test="Stakeout/CatchPointTemplateReport">
			<xsl:call-template name="CatchPointTemplateRpt"/>
		</xsl:if>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** Point Stakeout Data Output ****************** -->
	<!-- **************************************************************** -->
	<xsl:template name="PointDesign">
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">
				<xsl:text>Stake out point</xsl:text>
				<xsl:value-of select="concat(' (', Name, ')')"/>
			</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:text>Design point: </xsl:text>
				<xsl:value-of select="Stakeout/PointDesign/Name"/>
				<xsl:text>Code: </xsl:text>
				<xsl:value-of select="Stakeout/PointDesign/Code"/>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Method</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="StakeoutMethodText">
					<xsl:with-param name="Method" select="Stakeout/PointDesign/StakeoutMethod"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************* Line Stakeout Data Output ****************** -->
	<!-- **************************************************************** -->
	<xsl:template name="LineDesign">
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">
				<xsl:text>Stake out line</xsl:text>
				<xsl:value-of select="concat(' (', Name, ')')"/>
			</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:text>Line name: </xsl:text>
				<xsl:value-of select="Stakeout/LineDesign/Name"/>
				<xsl:text> Code: </xsl:text>
				<xsl:value-of select="Stakeout/LineDesign/Code"/>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Method</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="StakeoutMethodText">
					<xsl:with-param name="Method" select="Stakeout/LineDesign/StakeoutMethod"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="Stakeout/LineDesign/Station != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Station</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="FormattedStationVal">
						<xsl:with-param name="StationVal" select="Stakeout/LineDesign/Station"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Stakeout/LineDesign/Offset != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Offset</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(Stakeout/LineDesign/Offset * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Stakeout/LineDesign/Elevation != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr" select="$elevPrompt"/>
				<xsl:with-param name="Val" select="format-number(Stakeout/LineDesign/Elevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Stakeout/LineDesign/OriginalDesignElevation and Stakeout/LineDesign/OriginalDesignElevation != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Original design elev</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(Stakeout/LineDesign/OriginalDesignElevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************* Arc Stakeout Data Output ******************* -->
	<!-- **************************************************************** -->
	<xsl:template name="ArcDesign">
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">
				<xsl:text>Stake out arc</xsl:text>
				<xsl:value-of select="concat(' (', Name, ')')"/>
			</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:text>Arc name: </xsl:text>
				<xsl:value-of select="Stakeout/ArcDesign/Name"/>
				<xsl:text> Code: </xsl:text>
				<xsl:value-of select="Stakeout/ArcDesign/Code"/>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Method</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="StakeoutMethodText">
					<xsl:with-param name="Method" select="Stakeout/ArcDesign/StakeoutMethod"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="Stakeout/ArcDesign/Station != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Station</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="FormattedStationVal">
						<xsl:with-param name="StationVal" select="Stakeout/ArcDesign/Station"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Stakeout/ArcDesign/Offset != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Offset</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(Stakeout/ArcDesign/Offset * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Stakeout/ArcDesign/Elevation != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr" select="$elevPrompt"/>
				<xsl:with-param name="Val" select="format-number(Stakeout/ArcDesign/Elevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Stakeout/ArcDesign/OriginalDesignElevation and Stakeout/ArcDesign/OriginalDesignElevation != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Original design elev</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(Stakeout/ArcDesign/OriginalDesignElevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** Slope Stakeout Data Output ******************* -->
	<!-- **************************************************************** -->
	<xsl:template name="SlopeDesign">
		<xsl:if test="Stakeout/SlopeDesign/SlopeLeft">
			<xsl:call-template name="StartTable"/>
			<CAPTION align="left">
				<xsl:text>Stakeout - Slope left: </xsl:text>
				<xsl:call-template name="SlopeMethodText">
					<xsl:with-param name="Method" select="Stakeout/SlopeDesign/SlopeLeft/Type"/>
				</xsl:call-template>
			</CAPTION>
			<xsl:call-template name="OutputTableLine">
				<xsl:with-param name="Hdr1">Slope</xsl:with-param>
				<xsl:with-param name="Hdr2">H.Dist</xsl:with-param>
				<xsl:with-param name="Val2" select="format-number(Stakeout/SlopeDesign/SlopeLeft/HorizontalDistance  * $DistConvFactor, $DecPl3, 'Standard')"/>
				<xsl:with-param name="Hdr3">V.Dist</xsl:with-param>
				<xsl:with-param name="Val3" select="format-number(Stakeout/SlopeDesign/SlopeLeft/VerticalDistance  * $DistConvFactor, $DecPl3, 'Standard')"/>
				<xsl:with-param name="Hdr4">Slope dist</xsl:with-param>
				<xsl:with-param name="Val4" select="format-number(Stakeout/SlopeDesign/SlopeLeft/SlopeDistance  * $DistConvFactor, $DecPl3, 'Standard')"/>
				<xsl:with-param name="Hdr5">Grade</xsl:with-param>
				<xsl:with-param name="Val5" select="concat(format-number(Stakeout/SlopeDesign/SlopeLeft/Grade, $DecPl2, 'Standard'), '%')"/>
			</xsl:call-template>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
		<xsl:if test="Stakeout/SlopeDesign/SlopeRight">
			<xsl:call-template name="StartTable"/>
			<CAPTION align="left">
				<xsl:text>Stakeout - Slope right: </xsl:text>
				<xsl:call-template name="SlopeMethodText">
					<xsl:with-param name="Method" select="Stakeout/SlopeDesign/SlopeRight/Type"/>
				</xsl:call-template>
			</CAPTION>
			<xsl:call-template name="OutputTableLine">
				<xsl:with-param name="Hdr1">Slope</xsl:with-param>
				<xsl:with-param name="Hdr2">H.Dist</xsl:with-param>
				<xsl:with-param name="Val2" select="format-number(Stakeout/SlopeDesign/SlopeRight/HorizontalDistance  * $DistConvFactor, $DecPl3, 'Standard')"/>
				<xsl:with-param name="Hdr3">V.Dist</xsl:with-param>
				<xsl:with-param name="Val3" select="format-number(Stakeout/SlopeDesign/SlopeRight/VerticalDistance  * $DistConvFactor, $DecPl3, 'Standard')"/>
				<xsl:with-param name="Hdr4">Slope dist</xsl:with-param>
				<xsl:with-param name="Val4" select="format-number(Stakeout/SlopeDesign/SlopeRight/SlopeDistance  * $DistConvFactor, $DecPl3, 'Standard')"/>
				<xsl:with-param name="Hdr5">Grade</xsl:with-param>
				<xsl:with-param name="Val5" select="concat(format-number(Stakeout/SlopeDesign/SlopeRight/Grade, $DecPl2, 'Standard'), '%')"/>
			</xsl:call-template>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************* DTM Stakeout Data Output ******************* -->
	<!-- **************************************************************** -->
	<xsl:template name="DTMDesign">
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">
				<xsl:text>Stake out DTM</xsl:text>
				<xsl:value-of select="concat(' (', Name, ')')"/>
			</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:text>Surface: </xsl:text>
				<xsl:value-of select="Stakeout/DTMDesign/Name"/>
				<xsl:text> Vertical offset: </xsl:text>
				<xsl:value-of select="format-number(Stakeout/DTMDesign/VerticalOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- *************** Road Design Stakeout Data Output *************** -->
	<!-- **************************************************************** -->
	<xsl:template name="RoadDesign">
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">
				<xsl:text>Stake out road</xsl:text>
				<xsl:value-of select="concat(' (', Name, ')')"/>
			</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:text>Road name: </xsl:text>
				<xsl:value-of select="Stakeout/RoadDesign/Name"/>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Design code</xsl:with-param>
			<xsl:with-param name="Val" select="Stakeout/RoadDesign/Code"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Method</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="StakeoutMethodText">
					<xsl:with-param name="Method" select="Stakeout/RoadDesign/StakeoutMethod"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="Stakeout/RoadDesign/Station != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Station</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="FormattedStationVal">
						<xsl:with-param name="StationVal" select="Stakeout/RoadDesign/Station"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Stakeout/RoadDesign/Offset != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Offset</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(Stakeout/RoadDesign/Offset * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Stakeout/RoadDesign/Elevation != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Design elevation</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(Stakeout/RoadDesign/Elevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Stakeout/RoadDesign/HorizontalConstructionOffset and 
                  Stakeout/RoadDesign/HorizontalConstructionOffset != 0 and
                  Stakeout/RoadDesign/HorizontalConstructionOffset != ''">
			<xsl:variable name="offsetAppliedAs">
				<xsl:choose>
					<xsl:when test="Stakeout/RoadDesign/HorizontalConstructionOffsetApplied = 'Horizontal'">Horizontal</xsl:when>
					<xsl:otherwise>Slope</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Construction H.Offset</xsl:with-param>
				<xsl:with-param name="Val" select="concat(format-number(Stakeout/RoadDesign/HorizontalConstructionOffset * $DistConvFactor, $DecPl3, 'Standard'),
                                                  ' (', $offsetAppliedAs, ')')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Stakeout/RoadDesign/VerticalConstructionOffset and 
                  Stakeout/RoadDesign/VerticalConstructionOffset != 0 and
                  Stakeout/RoadDesign/VerticalConstructionOffset != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Construction V.Offset</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(Stakeout/RoadDesign/VerticalConstructionOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Stakeout/RoadDesign/StationConstructionOffset and 
                  Stakeout/RoadDesign/StationConstructionOffset != 0 and
                  Stakeout/RoadDesign/StationConstructionOffset != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Construction station offset</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(Stakeout/RoadDesign/StationConstructionOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Stakeout/RoadDesign/StationClass != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Station class</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="StationClassString">
						<xsl:with-param name="ClassStr" select="Stakeout/RoadDesign/StationClass"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Stakeout/RoadDesign/SideSlopeGrade and 
                  Stakeout/RoadDesign/SideSlopeGrade != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Design side slope grade</xsl:with-param>
				<xsl:with-param name="Val" select="concat(format-number(Stakeout/RoadDesign/SideSlopeGrade, $DecPl2, 'Standard'), '%')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Stakeout/RoadDesign/DitchOffset and 
                  Stakeout/RoadDesign/DitchOffset != 0 and
                  Stakeout/RoadDesign/DitchOffset != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Cut ditch width</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(Stakeout/RoadDesign/DitchOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** Stakeout Grid Deltas Output ****************** -->
	<!-- **************************************************************** -->
	<xsl:template name="GridDeltas">
		<xsl:if test="Stakeout/GridDeltas/DeltaNorth != '' or
                Stakeout/GridDeltas/DeltaEast != '' or 
                Stakeout/GridDeltas/DeltaElevation != ''">
			<xsl:call-template name="StartTable"/>
			<xsl:call-template name="OutputTableLine">
				<xsl:with-param name="Hdr1">Stakeout</xsl:with-param>
				<xsl:with-param name="Val1">Deltas: Grid</xsl:with-param>
				<xsl:with-param name="Hdr2">
					<xsl:choose>
						<xsl:when test="$NECoords = 'True'">
							<xsl:value-of select="$dNorthPrompt"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$dEastPrompt"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="Val2">
					<xsl:choose>
						<xsl:when test="$NECoords = 'True'">
							<xsl:value-of select="format-number(Stakeout/GridDeltas/DeltaNorth * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="format-number(Stakeout/GridDeltas/DeltaEast * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="Hdr3">
					<xsl:choose>
						<xsl:when test="$NECoords = 'True'">
							<xsl:value-of select="$dEastPrompt"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$dNorthPrompt"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="Val3">
					<xsl:choose>
						<xsl:when test="$NECoords = 'True'">
							<xsl:value-of select="format-number(Stakeout/GridDeltas/DeltaEast * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="format-number(Stakeout/GridDeltas/DeltaNorth * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="Hdr4" select="$dElevPrompt"/>
				<xsl:with-param name="Val4" select="format-number(Stakeout/GridDeltas/DeltaElevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- **************** Stakeout Linear Deltas Output ***************** -->
	<!-- **************************************************************** -->
	<xsl:template name="LinearDeltas">
		<xsl:if test="Stakeout/LinearDeltas/DeltaStation != '' or
                Stakeout/LinearDeltas/DeltaOffset != '' or 
                Stakeout/LinearDeltas/DeltaElevation != ''">
			<xsl:call-template name="StartTable"/>
			<xsl:call-template name="OutputTableLine">
				<xsl:with-param name="Hdr1">Stakeout</xsl:with-param>
				<xsl:with-param name="Val1">Deltas: Linear</xsl:with-param>
				<xsl:with-param name="Hdr2">Δ Station</xsl:with-param>
				<xsl:with-param name="Val2" select="format-number(Stakeout/LinearDeltas/DeltaStation * $DistConvFactor, $DecPl3, 'Standard')"/>
				<xsl:with-param name="Hdr3">ΔOffset</xsl:with-param>
				<xsl:with-param name="Val3" select="format-number(Stakeout/LinearDeltas/DeltaOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
				<xsl:with-param name="Hdr4" select="$dElevPrompt"/>
				<xsl:with-param name="Val4" select="format-number(Stakeout/LinearDeltas/DeltaElevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
				<xsl:with-param name="Hdr5">
					<xsl:if test="Stakeout/LinearDeltas/GradeToLine != ''">Grade to line</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="Val5">
					<xsl:if test="Stakeout/LinearDeltas/GradeToLine != ''">
						<xsl:value-of select="concat(format-number(Stakeout/LinearDeltas/GradeToLine, $DecPl2, 'Standard'), '%')"/>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** Stakeout Polar Deltas Output ***************** -->
	<!-- **************************************************************** -->
	<xsl:template name="PolarDeltas">
		<xsl:if test="Stakeout/PolarDeltas/Azimuth != '' or
                Stakeout/PolarDeltas/HorizontalDistance != '' or 
                Stakeout/PolarDeltas/VerticalDistance != ''">
			<xsl:call-template name="StartTable"/>
			<xsl:call-template name="OutputTableLine">
				<xsl:with-param name="Hdr1">Stakeout</xsl:with-param>
				<xsl:with-param name="Val1">Deltas: Polar</xsl:with-param>
				<xsl:with-param name="Hdr2">Azimuth</xsl:with-param>
				<xsl:with-param name="Val2">
					<xsl:call-template name="FormatAzimuth">
						<xsl:with-param name="TheAzimuth">
							<xsl:value-of select="Stakeout/PolarDeltas/Azimuth"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="Hdr3">H.Dist</xsl:with-param>
				<xsl:with-param name="Val3" select="format-number(Stakeout/PolarDeltas/HorizontalDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
				<xsl:with-param name="Hdr4">V.Dist</xsl:with-param>
				<xsl:with-param name="Val4" select="format-number(Stakeout/PolarDeltas/VerticalDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** Stakeout Catch Point Output ****************** -->
	<!-- **************************************************************** -->
	<xsl:template name="CatchPoint">
		<xsl:call-template name="StartTable"/>
		<xsl:variable name="catchPtLbl"/>
		<xsl:choose>
			<xsl:when test="Stakeout/CatchPoint/VerticalDistanceToHingePoint &gt; 0">Catch point (Fill)</xsl:when>
			<xsl:otherwise>Catch point (Cut)</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1" select="$catchPtLbl"/>
			<xsl:with-param name="Hdr2">Offset</xsl:with-param>
			<xsl:with-param name="Val2" select="format-number(Stakeout/CatchPoint/Offset * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr3" select="$elevPrompt"/>
			<xsl:with-param name="Val3" select="format-number(Stakeout/CatchPoint/Elevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr4">H.Dist to hinge point</xsl:with-param>
			<xsl:with-param name="Val4" select="format-number(Stakeout/CatchPoint/HorizontalDistanceToHingePoint * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr5">V.Dist to hinge point</xsl:with-param>
			<xsl:with-param name="Val5" select="format-number(Stakeout/CatchPoint/VerticalDistanceToHingePoint * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr2">Grade</xsl:with-param>
			<xsl:with-param name="Val2" select="concat(format-number(Stakeout/CatchPoint/AsStakedSideSlopeGrade, $DecPl2, 'Standard'), '%')"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************** Catch Point Template Report Output ************** -->
	<!-- **************************************************************** -->
	<xsl:template name="CatchPointTemplateRpt">
		<xsl:call-template name="StartTable"/>
		<xsl:for-each select="Stakeout/CatchPointTemplateReport">
			<xsl:call-template name="OutputTableLine">
				<xsl:with-param name="Hdr1">Catch</xsl:with-param>
				<xsl:with-param name="Hdr2">To point</xsl:with-param>
				<xsl:with-param name="Val2" select="Code"/>
				<xsl:with-param name="Hdr3">H.Dist</xsl:with-param>
				<xsl:with-param name="Val3" select="format-number(HorizontalDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
				<xsl:with-param name="Hdr4">V.Dist</xsl:with-param>
				<xsl:with-param name="Val4" select="format-number(DeltaElevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** DTM Stakeout Deltas Output ****************** -->
	<!-- **************************************************************** -->
	<xsl:template name="DTMDeltas">
		<xsl:call-template name="StartTable"/>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Stakeout</xsl:with-param>
			<xsl:with-param name="Val1">DTM</xsl:with-param>
			<xsl:with-param name="Hdr2" select="$dElevPrompt"/>
			<xsl:with-param name="Val2" select="format-number(Stakeout/DTMDeltas/DeltaElevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** Stakeout Method Text Output ****************** -->
	<!-- **************************************************************** -->
	<xsl:template name="StakeoutMethodText">
		<xsl:param name="Method"/>
		<xsl:choose>
			<xsl:when test="$Method = 'ToThePoint'">To the point</xsl:when>
			<xsl:when test="$Method = 'FromAPoint'">From fixed point</xsl:when>
			<xsl:when test="$Method = 'FromStartPosition'">From start position</xsl:when>
			<xsl:when test="$Method = 'FromLastPointStaked'">From last point staked</xsl:when>
			<xsl:when test="$Method = 'ToTheLine'">To the line</xsl:when>
			<xsl:when test="$Method = 'ToTheArc'">To the arc</xsl:when>
			<xsl:when test="$Method = 'PointOffsetFromLine'">Station/offset from line</xsl:when>
			<xsl:when test="$Method = 'PointOffsetFromArc'">Station/offset from arc</xsl:when>
			<xsl:when test="$Method = 'OffsetLine'">Offset line</xsl:when>
			<xsl:when test="$Method = 'OffsetArc'">Offset arc</xsl:when>
			<xsl:when test="$Method = 'PointOnLine'">To the line</xsl:when>
			<xsl:when test="$Method = 'PointOnArc'">To the arc</xsl:when>
			<xsl:when test="$Method = 'IntersectionPointOfArc'">Intersect point of arc</xsl:when>
			<xsl:when test="$Method = 'CentrePointOfArc'">Center point of arc</xsl:when>
			<xsl:when test="$Method = 'SlopeFromLine'">Slope from line</xsl:when>
			<xsl:when test="$Method = 'SlopeFromArc'">Slope from arc</xsl:when>
			<xsl:when test="$Method = 'StationAndOffset'">Station and offset</xsl:when>
			<xsl:when test="$Method = 'PositionOnRoad'">Position on road</xsl:when>
			<xsl:when test="$Method = 'SideSlopeFromAlignment'">Side slope from alignment</xsl:when>
			<xsl:when test="$Method = 'StationOnString'">Station on string</xsl:when>
			<xsl:when test="$Method = 'ToTheDTM'">Stake out DTM</xsl:when>
			<xsl:otherwise>Unknown</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************* Line Method Text Output ******************** -->
	<!-- **************************************************************** -->
	<xsl:template name="LineMethodText">
		<xsl:param name="Method"/>
		<xsl:choose>
			<xsl:when test="$Method = 'TwoPoints'">Two points</xsl:when>
			<xsl:when test="$Method = 'BearingAndDistance'">Bearing and distance</xsl:when>
			<xsl:otherwise>Unknown</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************** Arc Method Text Output ******************** -->
	<!-- **************************************************************** -->
	<xsl:template name="ArcMethodText">
		<xsl:param name="Method"/>
		<xsl:choose>
			<xsl:when test="$Method = 'TwoPointsAndRadius'">Two points and radius</xsl:when>
			<xsl:when test="$Method = 'ArcLengthAndRadius'">Arc length and radius</xsl:when>
			<xsl:when test="$Method = 'DeltaAngleAndRadius'">Delta angle and radius</xsl:when>
			<xsl:when test="$Method = 'IntersectionPointAndTangents'">Intersect point and tangents</xsl:when>
			<xsl:otherwise>Unknown</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************* Slope Method Text Output ******************* -->
	<!-- **************************************************************** -->
	<xsl:template name="SlopeMethodText">
		<xsl:param name="Method"/>
		<xsl:choose>
			<xsl:when test="$Method = 'HorizontalAndVerticalDistance'">Horz. and vert. dist</xsl:when>
			<xsl:when test="$Method = 'GradeAndSlopeDistance'">Grade and slope dist</xsl:when>
			<xsl:when test="$Method = 'GradeAndHorizontalDistance'">Grade and horz. dist</xsl:when>
			<xsl:otherwise>Unknown</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** Station Class Text Output ******************* -->
	<!-- **************************************************************** -->
	<xsl:template name="StationClassText">
		<xsl:param name="Class"/>
		<xsl:choose>
			<xsl:when test="$Class = 'StraightToSpiral'">(TS)</xsl:when>
			<xsl:when test="$Class = 'SpiralToArc'">(SC)</xsl:when>
			<xsl:when test="$Class = 'ArcToSpiral'">(CS)</xsl:when>
			<xsl:when test="$Class = 'SpiralToStraight'">(ST)</xsl:when>
			<xsl:when test="$Class = 'SpiralToSpiral'">(SS)</xsl:when>
			<xsl:when test="$Class = 'StraightToArc'">(PC)</xsl:when>
			<xsl:when test="$Class = 'ArcToStraight'">(PT)</xsl:when>
			<xsl:when test="$Class = 'IntersectionPoint'">(PI)</xsl:when>
			<xsl:when test="$Class = 'CrossSection'">(XS)</xsl:when>
			<xsl:when test="$Class = 'VerticalCurveStart'">(VCS)</xsl:when>
			<xsl:when test="$Class = 'VerticalCurveEnd'">(VCE)</xsl:when>
			<xsl:when test="$Class = 'VerticalPoint'">(VPI)</xsl:when>
			<xsl:when test="$Class = 'RoadStart'">(RS)</xsl:when>
			<xsl:when test="$Class = 'RoadEnd'">(RE)</xsl:when>
			<xsl:when test="$Class = 'TemplateAssignment'">(T)</xsl:when>
			<xsl:when test="$Class = 'SuperelevationStart'">(SES)</xsl:when>
			<xsl:when test="$Class = 'WideningStart'">(WS)</xsl:when>
			<xsl:when test="$Class = 'WideningEnd'">(WE)</xsl:when>
			<xsl:when test="$Class = 'SuperelevationEnd'">(SEE)</xsl:when>
			<xsl:when test="$Class = 'WideningMaxium'">(WM)</xsl:when>
			<xsl:when test="$Class = 'SuperelevationMaximum'">(SEM)</xsl:when>
			<xsl:when test="$Class = 'VerticalSagPoint'">(LO)</xsl:when>
			<xsl:when test="$Class = 'VerticalSummitPoint'">(HI)</xsl:when>
			<xsl:otherwise>Unknown</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** Station Class Text Output ******************* -->
	<!-- **************************************************************** -->
	<xsl:template name="StationClassString">
		<xsl:param name="ClassStr"/>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'StraightToSpiral'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'SpiralToArc'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'ArcToSpiral'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'SpiralToStraight'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'SpiralToSpiral'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'StraightToArc'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'ArcToStraight'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'IntersectionPoint'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'CrossSection'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'VerticalCurveStart'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'VerticalCurveEnd'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'VerticalPoint'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'RoadStart'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'RoadEnd'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'TemplateAssignment'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'SuperelevationStart'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'WideningStart'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'WideningEnd'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'SuperelevationEnd'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'WideningMaxium'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'SuperelevationMaximum'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'VerticalSagPoint'"/>
		</xsl:call-template>
		<xsl:call-template name="OutputStationClassItem">
			<xsl:with-param name="FullString" select="$ClassStr"/>
			<xsl:with-param name="ItemString" select="'VerticalSummitPoint'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** Output Station Class Item ******************* -->
	<!-- **************************************************************** -->
	<xsl:template name="OutputStationClassItem">
		<xsl:param name="FullString"/>
		<xsl:param name="ItemString"/>
		<xsl:if test="contains($FullString, $ItemString)">
			<xsl:if test="not(starts-with($FullString, $ItemString))">
				<xsl:value-of select="', '"/>
			</xsl:if>
			<xsl:call-template name="StationClassText">
				<xsl:with-param name="Class" select="$ItemString"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** GPSEquipmentRecord Output ******************* -->
	<!-- **************************************************************** -->
	<xsl:template match="GPSEquipmentRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">GPS receiver</CAPTION>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Receiver type</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:choose>
					<xsl:when test="ReceiverType = ''">Unknown</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="ReceiverType"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Serial number</xsl:with-param>
			<xsl:with-param name="Val" select="ReceiverSerialNumber"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Firmware version</xsl:with-param>
			<xsl:with-param name="Val" select="ReceiverFirmwareVersion"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Antenna type</xsl:with-param>
			<xsl:with-param name="Val" select="AntennaType"/>
		</xsl:call-template>
		<xsl:if test="AntennaSerialNumber != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Antenna serial number</xsl:with-param>
				<xsl:with-param name="Val" select="AntennaSerialNumber"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Measurement method</xsl:with-param>
			<xsl:with-param name="Val" select="AntennaMeasurementMethod"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Tape adjustment</xsl:with-param>
			<xsl:with-param name="Val" select="format-number(AntennaTapeAdjustment * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Horizontal offset</xsl:with-param>
			<xsl:with-param name="Val" select="format-number(AntennaHorizontalOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Vertical offset</xsl:with-param>
			<xsl:with-param name="Val" select="format-number(AntennaVerticalOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- **************** CalibrationPointRecord Output ***************** -->
	<!-- **************************************************************** -->
	<xsl:template match="pmaCalibrationPointRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Calibration point</CAPTION>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Grid</xsl:with-param>
			<xsl:with-param name="Val1" select="GridPointName"/>
			<xsl:with-param name="Hdr2">WGS84</xsl:with-param>
			<xsl:with-param name="Val2" select="WGS84PointName"/>
			<xsl:with-param name="Hdr3">Dimensions</xsl:with-param>
			<xsl:with-param name="Val3" select="Dimension"/>
			<xsl:with-param name="Hdr4">H.Resid</xsl:with-param>
			<xsl:with-param name="Val4" select="format-number(HorizontalResidual * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr5">V.Resid</xsl:with-param>
			<xsl:with-param name="Val5" select="format-number(VerticalResidual * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- *************** BaseSurveyOptionsRecord Output ***************** -->
	<!-- **************************************************************** -->
	<xsl:template match="BaseSurveyOptionsRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Base options</CAPTION>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Elevation mask</xsl:with-param>
			<xsl:with-param name="Val1" select="ElevationMask"/>
			<xsl:with-param name="Hdr2">PDOP mask</xsl:with-param>
			<xsl:with-param name="Val2" select="PDOPMask"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************** RoverSurveyOptionsRecord Output ***************** -->
	<!-- **************************************************************** -->
	<xsl:template match="RoverSurveyOptionsRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Rover options</CAPTION>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Elevation mask</xsl:with-param>
			<xsl:with-param name="Val1" select="ElevationMask"/>
			<xsl:with-param name="Hdr2">PDOP mask</xsl:with-param>
			<xsl:with-param name="Val2" select="PDOPMask"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** SurveyEventRecord Output ********************* -->
	<!-- **************************************************************** -->
	<xsl:template match="SurveyEventRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Survey event</CAPTION>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Survey event</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="SurveyEventText">
					<xsl:with-param name="Event" select="Event"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************* Survey Event Text Output ******************* -->
	<!-- **************************************************************** -->
	<xsl:template name="SurveyEventText">
		<xsl:param name="Event"/>
		<xsl:choose>
			<xsl:when test="$Event = 'StartBaseSurvey'">Base started</xsl:when>
			<xsl:when test="$Event = 'StartRoverSurvey'">Rover started</xsl:when>
			<xsl:when test="$Event = 'AbortSurvey'">Aborting survey</xsl:when>
			<xsl:when test="$Event = 'EndSurvey'">End survey</xsl:when>
			<xsl:when test="$Event = 'BaseStarted'">Base started</xsl:when>
			<xsl:when test="$Event = 'ReceiverModeSetError'">Receiver mode setting error</xsl:when>
			<xsl:when test="$Event = 'CommunicationsError'">Communications error</xsl:when>
			<xsl:when test="$Event = 'InfillSystemAdopted'">Infill started</xsl:when>
			<xsl:when test="$Event = 'RealtimeSystemAdopted'">Infill stopped</xsl:when>
			<xsl:when test="$Event = 'StartContinuous'">Continuous topo (Start)</xsl:when>
			<xsl:when test="$Event = 'EndContinuous'">Continuous topo (End)</xsl:when>
			<xsl:otherwise>Unknown</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************* ReferenceRecord Output ********************* -->
	<!-- **************************************************************** -->
	<xsl:template match="ReferenceRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Base point</CAPTION>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Point</xsl:with-param>
			<xsl:with-param name="Val1" select="PointName"/>
			<xsl:with-param name="Hdr2">Antenna height</xsl:with-param>
			<xsl:with-param name="Val2">
				<xsl:for-each select="key('antennaID-search', AntennaID)[1]">
					<xsl:value-of select="format-number(MeasuredHeight * $DistConvFactor, $DecPl3, 'Standard')"/>
				</xsl:for-each>
			</xsl:with-param>
			<xsl:with-param name="Hdr3">Type</xsl:with-param>
			<xsl:with-param name="Val3">
				<xsl:for-each select="key('antennaID-search', AntennaID)[1]">
					<xsl:choose>
						<xsl:when test="MeasurementType = 'Corrected'">Corrected</xsl:when>
						<xsl:otherwise>Uncorrected</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************* PostProcessRecord Output ******************* -->
	<!-- **************************************************************** -->
	<xsl:template match="PostProcessRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Postprocessing file</CAPTION>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">File name</xsl:with-param>
			<xsl:with-param name="Val1" select="FileName"/>
			<xsl:with-param name="Hdr2">Started</xsl:with-param>
			<xsl:with-param name="Hdr3">GPS week</xsl:with-param>
			<xsl:with-param name="Val3" select="StartTime/GPSWeek"/>
			<xsl:with-param name="Hdr4">Seconds</xsl:with-param>
			<xsl:with-param name="Val4" select="StartTime/Seconds"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** InitialisationRecord Output ****************** -->
	<!-- **************************************************************** -->
	<xsl:template match="InitialisationRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">
			<xsl:text>Initialization event: </xsl:text>
			<xsl:call-template name="InitialisationEventText">
				<xsl:with-param name="Event" select="InitialisationEvent"/>
			</xsl:call-template>
		</CAPTION>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">GPS week</xsl:with-param>
			<xsl:with-param name="Val1" select="Time/GPSWeek"/>
			<xsl:with-param name="Hdr2">Seconds</xsl:with-param>
			<xsl:with-param name="Val2" select="Time/Seconds"/>
			<xsl:with-param name="Hdr3">Initialization type</xsl:with-param>
			<xsl:with-param name="Val3">
				<xsl:call-template name="InitialisationTypeText">
					<xsl:with-param name="Type" select="InitialisationType"/>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr4">Survey type</xsl:with-param>
			<xsl:with-param name="Val4">
				<xsl:choose>
					<xsl:when test="SurveyType = 'RealTime'">Real-time</xsl:when>
					<xsl:when test="SurveyType = 'PostProcess'">Postprocess</xsl:when>
					<xsl:otherwise>Infill</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Hdr5">Initialization count</xsl:with-param>
			<xsl:with-param name="Val5" select="InitialisationCounter"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- *************** Initialisation Event Text Output *************** -->
	<!-- **************************************************************** -->
	<xsl:template name="InitialisationEventText">
		<xsl:param name="Event"/>
		<xsl:choose>
			<xsl:when test="$Event = 'GainedInitialisation'">Gained</xsl:when>
			<xsl:when test="$Event = 'LostInitialisation'">Lost</xsl:when>
			<xsl:when test="$Event = 'FailedInitialisation'">Failed</xsl:when>
			<xsl:when test="$Event = 'BadInitialisation'">Failed</xsl:when>
			<xsl:when test="$Event = 'HighRMS'">High RMS</xsl:when>
			<xsl:when test="$Event = 'GoodRMS'">Good RMS</xsl:when>
			<xsl:when test="$Event = 'UserCancelled'">User cancelled</xsl:when>
			<xsl:otherwise>Unknown</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- *************** Initialisation Type Text Output **************** -->
	<!-- **************************************************************** -->
	<xsl:template name="InitialisationTypeText">
		<xsl:param name="Type"/>
		<xsl:choose>
			<xsl:when test="$Type = 'Plate'">Plate</xsl:when>
			<xsl:when test="$Type = 'KnownPoint'">Known point</xsl:when>
			<xsl:when test="$Type = 'NewPoint'">New point</xsl:when>
			<xsl:when test="$Type = 'OnTheFly'">On the fly</xsl:when>
			<xsl:when test="$Type = 'Null'">Null</xsl:when>
			<xsl:otherwise>Unknown</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** AtmosphereRecord Output ********************* -->
	<!-- **************************************************************** -->
	<xsl:template match="AtmosphereRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Atmosphere</CAPTION>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Pressure</xsl:with-param>
			<xsl:with-param name="Val1">
				<xsl:variable name="Press" select="Pressure"/>
				<xsl:choose>
					<xsl:when test="string(number($Press))='NaN'">
						<xsl:value-of select="string('?')"/>
					</xsl:when>
					<!-- could use &#160; for space -->
					<xsl:otherwise>
						<xsl:variable name="PUnit">
							<xsl:choose>
								<xsl:when test="$PressUnit='mmHg'">mmHg</xsl:when>
								<xsl:when test="$PressUnit='InchHg'">inHg</xsl:when>
								<xsl:otherwise>mbar</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:value-of select="concat(format-number($Press * $PressConvFactor, $DecPl2, 'Standard'), $PUnit)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Hdr2">Temperature</xsl:with-param>
			<xsl:with-param name="Val2">
				<xsl:variable name="Temp" select="Temperature"/>
				<xsl:choose>
					<xsl:when test="string(number($Temp))='NaN'">
						<xsl:value-of select="string('?')"/>
					</xsl:when>
					<!-- could use &#160; for space -->
					<xsl:otherwise>
						<xsl:variable name="TUnit">
							<xsl:choose>
								<xsl:when test="$TempUnit='Fahrenheit'">&#0176;F</xsl:when>
								<xsl:otherwise>&#0176;C</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="$TempUnit='Fahrenheit'">
								<xsl:value-of select="concat(format-number($Temp * 1.8 + 32, $DecPl1, 'Standard'), $TUnit)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat(format-number($Temp, $DecPl1, 'Standard'), $TUnit)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Hdr3">ppm</xsl:with-param>
			<xsl:with-param name="Val3">
				<xsl:choose>
					<xsl:when test="PPM = ''">&#160;</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(PPM, $DecPl1, 'Standard')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Hdr4">Refraction Const.</xsl:with-param>
			<xsl:with-param name="Val4">
				<xsl:choose>
					<xsl:when test="Refraction = ''">&#160;</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="Refraction"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************** StationRecord Output ********************** -->
	<!-- **************************************************************** -->
	<xsl:template match="StationRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Station setup</CAPTION>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Station</xsl:with-param>
			<xsl:with-param name="Val1" select="StationName"/>
			<xsl:with-param name="Hdr2">Instrument height</xsl:with-param>
			<xsl:with-param name="Val2" select="format-number(TheodoliteHeight * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr3">Station type</xsl:with-param>
			<xsl:with-param name="Val3">
				<xsl:if test="StationType[.='StationSetup']">Station setup</xsl:if>
				<xsl:if test="StationType[.='StationSetupPlus']">Station setup plus</xsl:if>
				<xsl:if test="StationType[.='StandardResection']">Resection (Standard)</xsl:if>
				<xsl:if test="StationType[.='HelmertResection']">Resection (Helmert)</xsl:if>
			</xsl:with-param>
			<xsl:with-param name="Hdr4">Scale factor</xsl:with-param>
			<xsl:with-param name="Val4" select="format-number(ScaleFactor, $DecPl8, 'Standard')"/>
			<xsl:with-param name="Hdr5">Std Error</xsl:with-param>
			<xsl:with-param name="Val5" select="format-number(ScaleFactorStandardError, $DecPl8, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** BackBearingRecord Output ********************* -->
	<!-- **************************************************************** -->
	<xsl:template match="BackBearingRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Orientation</CAPTION>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Station</xsl:with-param>
			<xsl:with-param name="Val1" select="Station"/>
			<xsl:with-param name="Hdr2">Backsight point</xsl:with-param>
			<xsl:with-param name="Val2" select="BackSight"/>
			<xsl:with-param name="Hdr3">Orientation correction</xsl:with-param>
			<xsl:with-param name="Val3">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="OrientationCorrection"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr4">Orient. Std Err</xsl:with-param>
			<xsl:with-param name="Val4">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="OrientationCorrectionStandardError"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** Station Residuals Output ******************** -->
	<!-- **************************************************************** -->
	<xsl:template match="StationResiduals">
		<xsl:call-template name="SeparatingLine"/>
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Residuals (Station)</CAPTION>
		<xsl:call-template name="EndTable"/>
		<xsl:apply-templates select="ResidualsRecord"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** Residual Details Output ********************* -->
	<!-- **************************************************************** -->
	<xsl:template match="ResidualsRecord">
		<xsl:call-template name="StartTable"/>
		<!-- First line contains the grid residuals -->
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">Point</xsl:with-param>
			<xsl:with-param name="Val1" select="PointName"/>
			<xsl:with-param name="Hdr2">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">ΔN</xsl:when>
					<xsl:otherwise>ΔE</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Val2">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">
						<xsl:value-of select="format-number(GridResidual/DeltaNorth * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(GridResidual/DeltaEast * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Hdr3">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">ΔE</xsl:when>
					<xsl:otherwise>ΔN</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Val3">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">
						<xsl:value-of select="format-number(GridResidual/DeltaEast * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(GridResidual/DeltaNorth * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="Hdr4" select="$dElevPrompt"/>
			<xsl:with-param name="Val4" select="format-number(GridResidual/DeltaElevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<!-- Second line has the angular and distance residuals -->
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr2">ΔHA</xsl:with-param>
			<xsl:with-param name="Val2">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="AngleResidual/HorizontalCircle"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr3">ΔVA</xsl:with-param>
			<xsl:with-param name="Val3">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="AngleResidual/VerticalCircle"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr4">ΔSD</xsl:with-param>
			<xsl:with-param name="Val4">
				<xsl:value-of select="format-number(AngleResidual/SlopeDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************* Rounds Residuals Output ******************** -->
	<!-- **************************************************************** -->
	<xsl:template match="RoundsMeanTurnedAngleResiduals">
		<xsl:call-template name="SeparatingLine"/>
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Residuals (Rounds)</CAPTION>
		<xsl:for-each select="MeanTurnedAngleResiduals">
			<xsl:call-template name="OutputTableLine">
				<xsl:with-param name="Hdr1">Point</xsl:with-param>
				<xsl:with-param name="Val1" select="PointName"/>
				<xsl:with-param name="Hdr2">Round</xsl:with-param>
				<xsl:with-param name="Val2" select="Round"/>
				<xsl:with-param name="Hdr3">ΔHA</xsl:with-param>
				<xsl:with-param name="Val3">
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="HorizontalAngleResidual"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="Hdr4">ΔVA</xsl:with-param>
				<xsl:with-param name="Val4">
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="VerticalAngleResidual"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="Hdr5">ΔSD</xsl:with-param>
				<xsl:with-param name="Val5">
					<xsl:value-of select="format-number(SlopeDistanceResidual * $DistConvFactor, $DecPl3, 'Standard')"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ********************* Road Record Output *********************** -->
	<!-- **************************************************************** -->
	<xsl:template match="RoadRecord">
		<xsl:if test="Deleted = 'false'">
			<!-- Road definition has not been deleted -->
			<xsl:call-template name="StartTable"/>
			<CAPTION align="left">Road</CAPTION>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Road name</xsl:with-param>
				<xsl:with-param name="Val" select="Name"/>
			</xsl:call-template>
			<xsl:call-template name="EndTable"/>
			<xsl:call-template name="SeparatingLine"/>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ********************* Note Record Output *********************** -->
	<!-- **************************************************************** -->
	<xsl:template match="NoteRecord">
		<xsl:call-template name="StartTable"/>
		<xsl:for-each select="Notes/Note">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Note</xsl:with-param>
				<xsl:with-param name="Val" select="."/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ********************* Line Record Output *********************** -->
	<!-- **************************************************************** -->
	<xsl:template match="LineRecord">
		<xsl:if test="Deleted = 'false'">
			<!-- Line definition has not been deleted -->
			<xsl:call-template name="StartTable"/>
			<CAPTION align="left">Line</CAPTION>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Line</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:text>Name: </xsl:text>
					<xsl:value-of select="Name"/>
					<xsl:text> Code: </xsl:text>
					<xsl:value-of select="Code"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Definition</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="LineMethodText">
						<xsl:with-param name="Method" select="Method"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="StartPoint and StartPoint != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Start point</xsl:with-param>
					<xsl:with-param name="Val" select="StartPoint"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="EndPoint and EndPoint != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">End point</xsl:with-param>
					<xsl:with-param name="Val" select="EndPoint"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="Azimuth and Azimuth != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Azimuth</xsl:with-param>
					<xsl:with-param name="Val">
						<xsl:call-template name="FormatAzimuth">
							<xsl:with-param name="TheAzimuth">
								<xsl:value-of select="Azimuth"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="Length and Length != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Length</xsl:with-param>
					<xsl:with-param name="Val" select="format-number(Length * $DistConvFactor, $DecPl3, 'Standard')"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="Grade and Grade != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Grade</xsl:with-param>
					<xsl:with-param name="Val" select="concat(format-number(Grade, $DecPl2, 'Standard'), '%')"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="StartStation and StartStation != ''">
				<xsl:variable name="startStn">
					<xsl:call-template name="FormattedStationVal">
						<xsl:with-param name="StationVal" select="StartStation"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Stationing</xsl:with-param>
					<xsl:with-param name="Val">
						<xsl:text>Start station: </xsl:text>
						<xsl:value-of select="$startStn"/>
						<xsl:text> Station interval: </xsl:text>
						<xsl:value-of select="format-number(StationInterval * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ********************** Arc Record Output *********************** -->
	<!-- **************************************************************** -->
	<xsl:template match="ArcRecord">
		<xsl:if test="Deleted = 'false'">
			<!-- Arc definition has not been deleted -->
			<xsl:call-template name="StartTable"/>
			<CAPTION align="left">Arc</CAPTION>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Arc</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:text>Name: </xsl:text>
					<xsl:value-of select="Name"/>
					<xsl:text> Code: </xsl:text>
					<xsl:value-of select="Code"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Definition</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="ArcMethodText">
						<xsl:with-param name="Method" select="Method"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="StartPoint and StartPoint != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Start point</xsl:with-param>
					<xsl:with-param name="Val" select="StartPoint"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="EndPoint and EndPoint != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">End point</xsl:with-param>
					<xsl:with-param name="Val" select="EndPoint"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="Direction and Direction != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Direction</xsl:with-param>
					<xsl:with-param name="Val" select="Direction"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="Radius and Radius != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Radius</xsl:with-param>
					<xsl:with-param name="Val" select="format-number(Radius * $DistConvFactor, $DecPl3, 'Standard')"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="StartAzimuth and StartAzimuth != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Start azimuth</xsl:with-param>
					<xsl:with-param name="Val">
						<xsl:call-template name="FormatAzimuth">
							<xsl:with-param name="TheAzimuth">
								<xsl:value-of select="StartAzimuth"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="Length and Length != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Length</xsl:with-param>
					<xsl:with-param name="Val" select="format-number(Length * $DistConvFactor, $DecPl3, 'Standard')"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="Grade and Grade != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Grade</xsl:with-param>
					<xsl:with-param name="Val" select="concat(format-number(Grade, $DecPl2, 'Standard'), '%')"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="DeltaAngle and DeltaAngle != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Delta angle</xsl:with-param>
					<xsl:with-param name="Val">
						<xsl:call-template name="FormatAngle">
							<xsl:with-param name="TheAngle">
								<xsl:value-of select="DeltaAngle"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="IntersectionPoint and IntersectionPoint != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Intersect point</xsl:with-param>
					<xsl:with-param name="Val" select="IntersectionPoint"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="EndAzimuth and EndAzimuth != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">End azimuth</xsl:with-param>
					<xsl:with-param name="Val">
						<xsl:call-template name="FormatAzimuth">
							<xsl:with-param name="TheAzimuth">
								<xsl:value-of select="EndAzimuth"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="StartStation and StartStation != ''">
				<xsl:variable name="startStn">
					<xsl:call-template name="FormattedStationVal">
						<xsl:with-param name="StationVal" select="StartStation"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Stationing</xsl:with-param>
					<xsl:with-param name="Val">
						<xsl:text>Start station: </xsl:text>
						<xsl:value-of select="$startStn"/>
						<xsl:text> Station interval: </xsl:text>
						<xsl:value-of select="format-number(StationInterval * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ********************* Inverse Record Output ******************** -->
	<!-- **************************************************************** -->
	<xsl:template match="InverseRecord">
		<xsl:variable name="AzLbl">
			<xsl:choose>
				<xsl:when test="AzimuthType[.='Grid']">Azimuth (grid)</xsl:when>
				<xsl:when test="AzimuthType[.='Magnetic']">Azimuth (mag)</xsl:when>
				<xsl:when test="AzimuthType[.='Local']">Azimuth (local)</xsl:when>
				<xsl:when test="AzimuthType[.='WGS84']">Azimuth (WGS84)</xsl:when>
				<xsl:otherwise>Azimuth</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="DistType">
			<xsl:choose>
				<xsl:when test="DistanceType[.='Grid']">Grid</xsl:when>
				<xsl:when test="DistanceType[.='Ground']">Ground</xsl:when>
				<xsl:when test="DistanceType[.='Ellipsoid']">Ellipsoid</xsl:when>
				<xsl:otherwise>Grid</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Inverse</CAPTION>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr1">From point</xsl:with-param>
			<xsl:with-param name="Val1" select="FromPoint"/>
			<xsl:with-param name="Hdr2">To point</xsl:with-param>
			<xsl:with-param name="Val2" select="ToPoint"/>
			<xsl:with-param name="Hdr3">
				<xsl:value-of select="$AzLbl"/>
			</xsl:with-param>
			<xsl:with-param name="Val3">
				<xsl:call-template name="FormatAzimuth">
					<xsl:with-param name="TheAzimuth" select="Azimuth"/>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="Hdr4">H.Dist</xsl:with-param>
			<xsl:with-param name="Val4" select="format-number(HorizontalDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr5">V.Dist</xsl:with-param>
			<xsl:with-param name="Val5" select="format-number(VerticalDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="OutputTableLine">
			<xsl:with-param name="Hdr3">Slope dist</xsl:with-param>
			<xsl:with-param name="Val3" select="format-number(SlopeDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
			<xsl:with-param name="Hdr4">Grade</xsl:with-param>
			<xsl:with-param name="Val4" select="concat(format-number(Grade, $DecPl2, 'Standard'), '%')"/>
			<xsl:with-param name="Hdr5">Distance</xsl:with-param>
			<xsl:with-param name="Val5">
				<xsl:value-of select="$DistType"/>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** ProjectionRecord Output ********************* -->
	<!-- **************************************************************** -->
	<xsl:template match="ProjectionRecord">
		<xsl:call-template name="ProjDetailsOutput"/>
		<xsl:call-template name="LocalSiteOutput"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- *************** CoordinateSystem Details Output **************** -->
	<!-- **************************************************************** -->
	<xsl:template match="CoordinateSystem">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Coordinate system (Job)</CAPTION>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">System</xsl:with-param>
			<xsl:with-param name="Val" select="SystemName"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Zone</xsl:with-param>
			<xsl:with-param name="Val" select="ZoneName"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Datum</xsl:with-param>
			<xsl:with-param name="Val" select="DatumName"/>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="ProjDetailsOutput"/>
		<xsl:call-template name="LocalSiteOutput"/>
		<xsl:apply-templates select="Datum"/>
		<xsl:apply-templates select="HorizontalAdjustment"/>
		<xsl:apply-templates select="VerticalAdjustment"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************** Datum Details Output ********************** -->
	<!-- **************************************************************** -->
	<xsl:template match="Datum">
		<xsl:call-template name="DatumTransformationOutput"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** DatumRecord Details Output ******************* -->
	<!-- **************************************************************** -->
	<xsl:template match="DatumRecord">
		<xsl:call-template name="DatumTransformationOutput"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************* HorizontalAdjustment Details Output ************** -->
	<!-- **************************************************************** -->
	<xsl:template match="HorizontalAdjustment">
		<xsl:call-template name="HorizontalAdjustmentOutput"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ********** HorizontalAdjustmentRecord Details Output *********** -->
	<!-- **************************************************************** -->
	<xsl:template match="HorizontalAdjustmentRecord">
		<xsl:call-template name="HorizontalAdjustmentOutput"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************** VerticalAdjustment Details Output *************** -->
	<!-- **************************************************************** -->
	<xsl:template match="VerticalAdjustment">
		<xsl:call-template name="VerticalAdjustmentOutput"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- *********** VerticalAdjustmentRecord Details Output ************ -->
	<!-- **************************************************************** -->
	<xsl:template match="VerticalAdjustmentRecord">
		<xsl:call-template name="VerticalAdjustmentOutput"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** ProjectionRecord Output ********************* -->
	<!-- **************************************************************** -->
	<xsl:template name="ProjDetailsOutput">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Projection</CAPTION>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Projection</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="ProjectionTypeText">
					<xsl:with-param name="Type" select="Projection/Type"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="Projection/CentralLatitude">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Origin lat</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="LatLongValue">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="Projection/CentralLatitude"/>
						</xsl:with-param>
						<xsl:with-param name="IsLat" select="'True'"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/CentralLongitude">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Origin long</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="LatLongValue">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="Projection/CentralLongitude"/>
						</xsl:with-param>
						<xsl:with-param name="IsLat" select="'False'"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/OriginHeight">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Origin height</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(Projection/OriginHeight * $ElevConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$NECoords = 'True'">
				<xsl:if test="Projection/FalseNorthing">
					<xsl:call-template name="OutputSingleElementTableLine">
						<xsl:with-param name="Hdr">False northing</xsl:with-param>
						<xsl:with-param name="Val" select="format-number(Projection/FalseNorthing * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="Projection/FalseEasting">
					<xsl:call-template name="OutputSingleElementTableLine">
						<xsl:with-param name="Hdr">False easting</xsl:with-param>
						<xsl:with-param name="Val" select="format-number(Projection/FalseEasting * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="Projection/FalseEasting">
					<xsl:call-template name="OutputSingleElementTableLine">
						<xsl:with-param name="Hdr">False easting</xsl:with-param>
						<xsl:with-param name="Val" select="format-number(Projection/FalseEasting * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="Projection/FalseNorthing">
					<xsl:call-template name="OutputSingleElementTableLine">
						<xsl:with-param name="Hdr">False northing</xsl:with-param>
						<xsl:with-param name="Val" select="format-number(Projection/FalseNorthing * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="Projection/OriginElevation">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">False elevation</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(Projection/OriginElevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/Parallel1">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Parallel 1</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="LatLongValue">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="Projection/Parallel1"/>
						</xsl:with-param>
						<xsl:with-param name="IsLat" select="'True'"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/Parallel2">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Parallel 2</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="LatLongValue">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="Projection/Parallel2"/>
						</xsl:with-param>
						<xsl:with-param name="IsLat" select="'True'"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/Scale">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Scale</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(Projection/Scale, $DecPl8, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/Rotation">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Rotation</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="Projection/Rotation"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/Azimuth">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Azimuth</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="FormatAzimuth">
						<xsl:with-param name="TheAzimuth">
							<xsl:value-of select="Projection/Azimuth"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/AzimuthAt">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Azimuth at</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:if test="Projection/AzimuthAt[.='Equator']">Equator</xsl:if>
					<xsl:if test="Projection/AzimuthAt[.='ProjectionCentre']">Center of projection</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/OriginAt">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Origin at</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:if test="Projection/OriginAt[.='Equator']">Equator</xsl:if>
					<xsl:if test="Projection/OriginAt[.='ProjectionCentre']">Center of projection</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/Rectify">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Rectify coordinates</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:if test="Projection/Rectify[.='true']">Yes</xsl:if>
					<xsl:if test="Projection/Rectify[.='false']">No</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/FerroConstant">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Ferro constant</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="LatLongValue">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="Projection/FerroConstant"/>
						</xsl:with-param>
						<xsl:with-param name="IsLat" select="'False'"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/Area">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Denmark</xsl:with-param>
				<xsl:with-param name="Val" select="Projection/Area"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/ShiftGridFileName and 
                  Projection/ShiftGridFileName != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Shift grid file</xsl:with-param>
				<xsl:with-param name="Val" select="Projection/ShiftGridFileName"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/ProjectionGridFile and
                  Projection/ProjectionGridFile != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Projection grid file</xsl:with-param>
				<xsl:with-param name="Val" select="Projection/ProjectionGridFile"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/NorthGridFile">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Shift grid file (North)</xsl:with-param>
				<xsl:with-param name="Val" select="Projection/NorthGridFile"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/EastGridFile">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Shift grid file (East)</xsl:with-param>
				<xsl:with-param name="Val" select="Projection/EastGridFile"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/SouthAzimuth">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">South azimuth (grid)</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:if test="Projection/SouthAzimuth[.='true']">Yes</xsl:if>
					<xsl:if test="Projection/SouthAzimuth[.='false']">No</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Projection/GridOrientation">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Grid coords</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:if test="Projection/GridOrientation[.='IncreasingNorthEast']">Increase North-East</xsl:if>
					<xsl:if test="Projection/GridOrientation[.='IncreasingSouthWest']">Increase South-West</xsl:if>
					<xsl:if test="Projection/GridOrientation[.='IncreasingNorthWest']">Increase North-West</xsl:if>
					<xsl:if test="Projection/GridOrientation[.='IncreasingSouthEast']">Increase South-East</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ***************** Projection Type Text Output ****************** -->
	<!-- **************************************************************** -->
	<xsl:template name="ProjectionTypeText">
		<xsl:param name="Type"/>
		<xsl:choose>
			<xsl:when test="$Type = 'NoProjection'">No projection</xsl:when>
			<xsl:when test="$Type = 'ScaleOnly'">Scale factor only</xsl:when>
			<xsl:when test="$Type = 'Plane'">Plane</xsl:when>
			<xsl:when test="$Type = 'Mercator'">Mercator</xsl:when>
			<xsl:when test="$Type = 'TransverseMercator'">Transverse Mercator</xsl:when>
			<xsl:when test="$Type = 'UniversalTransverseMercator'">Universal Transverse Mercator</xsl:when>
			<xsl:when test="$Type = 'Lambert1Parallel'">Lambert Conformal Conic 1 Parallel</xsl:when>
			<xsl:when test="$Type = 'Lambert2Parallel'">Lambert Conformal Conic 2 Parallel</xsl:when>
			<xsl:when test="$Type = 'ObliqueMercatorAngle'">Oblique Mercator Angle</xsl:when>
			<xsl:when test="$Type = 'ObliqueConformalCylindrical'">Oblique Conformal Cylindrical</xsl:when>
			<xsl:when test="$Type = 'PolarStereographic'">Polar Stereographic</xsl:when>
			<xsl:when test="$Type = 'RDStereographic'">R.D. Stereographic</xsl:when>
			<xsl:when test="$Type = 'AlbersEqualAreaConic'">Albers Equal Area Conic</xsl:when>
			<xsl:when test="$Type = 'CassiniSoldner'">Cassini-Soldner</xsl:when>
			<xsl:when test="$Type = 'Krovak'">Krovak</xsl:when>
			<xsl:when test="$Type = 'NewZealandMapGrid'">New Zealand Map Grid</xsl:when>
			<xsl:when test="$Type = 'UnitedKingdomNationalGrid'">United Kingdom National Grid</xsl:when>
			<xsl:when test="$Type = 'Denmark'">Denmark</xsl:when>
			<xsl:when test="$Type = 'HungarianEOV'">Hungarian EOV</xsl:when>
			<xsl:when test="$Type = 'StereographicDouble'">Stereographic Double</xsl:when>
			<xsl:when test="$Type = 'RSO'">RSO</xsl:when>
			<xsl:when test="$Type = 'UPSNorth'">UPS north</xsl:when>
			<xsl:when test="$Type = 'UPSSouth'">UPS south</xsl:when>
			<xsl:when test="$Type = 'ProjectionGrid'">Projection grid</xsl:when>
			<xsl:otherwise>Unknown</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************* LocalSite Details Output ******************* -->
	<!-- **************************************************************** -->
	<xsl:template name="LocalSiteOutput">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Local site</CAPTION>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Type</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:if test="LocalSite/Type[.='Grid']">Grid</xsl:if>
				<xsl:if test="LocalSite/Type[.='KeyedInGroundScaleFactor']">Ground (keyed in scale factor)</xsl:if>
				<xsl:if test="LocalSite/Type[.='CalculatedGroundScaleFactor']">Ground (calculated scale factor)</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="LocalSite/ProjectLocationLatitude and
                  LocalSite/ProjectLocationLatitude != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Project location (Latitude)</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="LatLongValue">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="LocalSite/ProjectLocationLatitude"/>
						</xsl:with-param>
						<xsl:with-param name="IsLat" select="'True'"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="LocalSite/ProjectLocationLongitude and
                  LocalSite/ProjectLocationLongitude != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Project location (Longitude)</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="LatLongValue">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="LocalSite/ProjectLocationLongitude"/>
						</xsl:with-param>
						<xsl:with-param name="IsLat" select="'False'"/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="LocalSite/ProjectLocationLongitude and
                  LocalSite/ProjectLocationLongitude != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Project location (Height)</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(LocalSite/ProjectLocationHeight * $ElevConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="LocalSite/GroundScaleFactor and
                  LocalSite/GroundScaleFactor != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Ground scale factor</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(LocalSite/GroundScaleFactor, $DecPl8, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="LocalSite/NorthingOffset and LocalSite/NorthingOffset != '' and 
                  LocalSite/EastingOffset and LocalSite/EastingOffset != ''">
			<xsl:choose>
				<xsl:when test="$NECoords = 'True'">
					<xsl:call-template name="OutputSingleElementTableLine">
						<xsl:with-param name="Hdr">Northing offset</xsl:with-param>
						<xsl:with-param name="Val" select="format-number(LocalSite/NorthingOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:call-template>
					<xsl:call-template name="OutputSingleElementTableLine">
						<xsl:with-param name="Hdr">Easting offset</xsl:with-param>
						<xsl:with-param name="Val" select="format-number(LocalSite/EastingOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="OutputSingleElementTableLine">
						<xsl:with-param name="Hdr">Easting offset</xsl:with-param>
						<xsl:with-param name="Val" select="format-number(LocalSite/EastingOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:call-template>
					<xsl:call-template name="OutputSingleElementTableLine">
						<xsl:with-param name="Hdr">Northing offset</xsl:with-param>
						<xsl:with-param name="Val" select="format-number(LocalSite/NorthingOffset * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="LocalSite/ProjectionOriginNorthingDelta and LocalSite/ProjectionOriginNorthingDelta != '' and 
                  LocalSite/ProjectionOriginEastingDelta and LocalSite/ProjectionOriginEastingDelta != ''">
			<xsl:choose>
				<xsl:when test="$NECoords = 'True'">
					<xsl:call-template name="OutputSingleElementTableLine">
						<xsl:with-param name="Hdr">Origin north delta</xsl:with-param>
						<xsl:with-param name="Val" select="format-number(LocalSite/ProjectionOriginNorthingDelta * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:call-template>
					<xsl:call-template name="OutputSingleElementTableLine">
						<xsl:with-param name="Hdr">Origin east delta</xsl:with-param>
						<xsl:with-param name="Val" select="format-number(LocalSite/ProjectionOriginEastingDelta * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="OutputSingleElementTableLine">
						<xsl:with-param name="Hdr">Origin east delta</xsl:with-param>
						<xsl:with-param name="Val" select="format-number(LocalSite/ProjectionOriginEastingDelta * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:call-template>
					<xsl:call-template name="OutputSingleElementTableLine">
						<xsl:with-param name="Hdr">Origin north delta</xsl:with-param>
						<xsl:with-param name="Val" select="format-number(LocalSite/ProjectionOriginNorthingDelta * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************** Datum Transformation Details Output ************* -->
	<!-- **************************************************************** -->
	<xsl:template name="DatumTransformationOutput">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Datum transformation</CAPTION>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Type</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:if test="Type[.='NoDatum']">None</xsl:if>
				<xsl:if test="Type[.='SevenParameter']">Seven parameter</xsl:if>
				<xsl:if test="Type[.='ThreeParameter']">Three parameter</xsl:if>
				<xsl:if test="Type[.='GridDatum']">Datum grid</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="EarthRadius and EarthRadius != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Semi-major axis</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(EarthRadius * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Flattening and Flattening != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Flattening</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(1.0 div Flattening, $DecPl6, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="RotationX and RotationX != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Rotation X</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="SecDecPlaces" select="4"/>
						<xsl:with-param name="DMSOutput" select="'True'"/>
						<!-- Will override current angle units -->
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="RotationX"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="RotationY and RotationY != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Rotation Y</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="SecDecPlaces" select="4"/>
						<xsl:with-param name="DMSOutput" select="'True'"/>
						<!-- Will override current angle units -->
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="RotationY"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="RotationZ and RotationZ != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Rotation Z</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="SecDecPlaces" select="4"/>
						<xsl:with-param name="DMSOutput" select="'True'"/>
						<!-- Will override current angle units -->
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="RotationZ"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="TranslationX and TranslationX != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Translation X</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(TranslationX * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="TranslationY and TranslationY != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Translation Y</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(TranslationY * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="TranslationZ and TranslationZ != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Translation Z</xsl:with-param>
				<xsl:with-param name="Val" select="format-number(TranslationZ * $DistConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Scale and Scale != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Scale</xsl:with-param>
				<xsl:with-param name="Val">
					<xsl:value-of select="format-number((Scale - 1.0) * 1000000.0, $DecPl5, 'Standard')"/>
					<xsl:text>ppm</xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="GridName and GridName != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">Datum Grid File</xsl:with-param>
				<xsl:with-param name="Val" select="GridName"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************* Horizontal Adjustment Details Output ************* -->
	<!-- **************************************************************** -->
	<xsl:template name="HorizontalAdjustmentOutput">
		<xsl:if test="Type != 'NoAdjustment'">
			<!-- Don't output table at all if there is no adjustment -->
			<xsl:call-template name="StartTable"/>
			<CAPTION align="left">Horizontal adjustment</CAPTION>
			<xsl:if test="OriginNorth and OriginNorth != '' and 
                    OriginEast and OriginEast != ''">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Origin north</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(OriginNorth * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:call-template>
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Origin east</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(OriginEast * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Origin east</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(OriginEast * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:call-template>
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Origin north</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(OriginNorth * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="TranslationNorth and TranslationNorth != '' and 
                    TranslationEast and TranslationEast != ''">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Translation north</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(TranslationNorth * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:call-template>
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Translation east</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(TranslationEast * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Translation east</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(TranslationEast * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:call-template>
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Translation north</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(TranslationNorth * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="Rotation and Rotation != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Rotation</xsl:with-param>
					<xsl:with-param name="Val">
						<xsl:call-template name="FormatAngle">
							<xsl:with-param name="SecDecPlaces" select="4"/>
							<xsl:with-param name="TheAngle">
								<xsl:value-of select="Rotation"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="ScaleFactor and ScaleFactor != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Scale factor</xsl:with-param>
					<xsl:with-param name="Val" select="format-number(ScaleFactor, $DecPl8, 'Standard')"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************** Vertical Adjustment Details Output ************** -->
	<!-- **************************************************************** -->
	<xsl:template name="VerticalAdjustmentOutput">
		<xsl:if test="Type != 'NoAdjustment'">
			<!-- Don't output table at all if there is no adjustment -->
			<xsl:call-template name="StartTable"/>
			<CAPTION align="left">Vertical adjustment</CAPTION>
			<xsl:if test="OriginNorth and OriginNorth != '' and 
                    OriginEast and OriginEast != ''">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Origin north</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(OriginNorth * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:call-template>
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Origin east</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(OriginEast * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Origin east</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(OriginEast * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:call-template>
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Origin north</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(OriginNorth * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="SlopeNorthPerUnit and SlopeNorthPerUnit != '' and 
                    SlopeEastPerUnit and SlopeEastPerUnit != ''">
				<xsl:choose>
					<xsl:when test="$NECoords = 'True'">
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Slope north</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(SlopeNorthPerUnit, $DecPl6, 'Standard')"/>
						</xsl:call-template>
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Slope east</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(SlopeEastPerUnit, $DecPl6, 'Standard')"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Slope east</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(SlopeEastPerUnit, $DecPl6, 'Standard')"/>
						</xsl:call-template>
						<xsl:call-template name="OutputSingleElementTableLine">
							<xsl:with-param name="Hdr">Slope north</xsl:with-param>
							<xsl:with-param name="Val" select="format-number(SlopeNorthPerUnit, $DecPl6, 'Standard')"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="ConstantAdjustment and ConstantAdjustment != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Constant adjustment</xsl:with-param>
					<xsl:with-param name="Val" select="format-number(ConstantAdjustment * $DistConvFactor, $DecPl3, 'Standard')"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="GeoidName and GeoidName != ''">
				<xsl:call-template name="OutputSingleElementTableLine">
					<xsl:with-param name="Hdr">Geoid file</xsl:with-param>
					<xsl:with-param name="Val" select="GeoidName"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************* Traverse Definition Output ***************** -->
	<!-- **************************************************************** -->
	<xsl:template match="TraverseDefinitionRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Traverse Definition</CAPTION>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Name</xsl:with-param>
			<xsl:with-param name="Val" select="TraverseName"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Backsight azimuth</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="FormatAzimuth">
					<xsl:with-param name="TheAzimuth">
						<xsl:value-of select="BacksightAzimuth"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:text> to </xsl:text>
				<xsl:value-of select="BacksightPoint"/>
				<xsl:if test="BacksightAzimuthKeyedIn = 'true'">
					<xsl:text> (Keyed in)</xsl:text>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:for-each select="ListOfStations/Item">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr">
					<xsl:text>Traverse Point </xsl:text>
					<xsl:value-of select="@n"/>
				</xsl:with-param>
				<xsl:with-param name="Val" select="."/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Foresight azimuth</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="FormatAzimuth">
					<xsl:with-param name="TheAzimuth">
						<xsl:value-of select="ForesightAzimuth"/>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:text> to </xsl:text>
				<xsl:value-of select="ForesightPoint"/>
				<xsl:if test="ForesightAzimuthKeyedIn = 'true'">
					<xsl:text> (Keyed in)</xsl:text>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************* Traverse Adjustment Output ***************** -->
	<!-- **************************************************************** -->
	<xsl:template match="TraverseAdjustmentRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">Traverse Adjustment Method</CAPTION>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Adjustment method</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:if test="AdjustmentMethod[.='Transit']">Transit</xsl:if>
				<xsl:if test="AdjustmentMethod[.='Compass']">Compass</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Error distribution (Angular)</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:if test="AngularErrorDistribution[.='ProportionalToDistance']">Proportional to distance</xsl:if>
				<xsl:if test="AngularErrorDistribution[.='EqualProportions']">Equal proportions</xsl:if>
				<xsl:if test="AngularErrorDistribution[.='None']">None</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">
				<xsl:text>Error distribution</xsl:text>
				<xsl:value-of select="concat(' (', $elevPrompt, ')')"/>
			</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:if test="ElevationErrorDistribution[.='ProportionalToDistance']">Proportional to distance</xsl:if>
				<xsl:if test="ElevationErrorDistribution[.='EqualProportions']">Equal proportions</xsl:if>
				<xsl:if test="ElevationErrorDistribution[.='None']">None</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="EndTable"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************** Traverse Closure Output ******************* -->
	<!-- **************************************************************** -->
	<xsl:template match="TraverseClosureRecord">
		<xsl:variable name="TraverseName">
			<xsl:for-each select="key('travID-search', TraverseDefinitionID)">
				<xsl:value-of select="TraverseName"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="AdjMethod">
			<xsl:if test="preceding-sibling::TraverseAdjustmentRecord[1]/AdjustmentMethod = 'Transit'">Transit</xsl:if>
			<xsl:if test="preceding-sibling::TraverseAdjustmentRecord[1]/AdjustmentMethod = 'Compass'">Compass</xsl:if>
		</xsl:variable>
		<!-- If the traverse has been adjusted output the traverse details in a 'spreadsheet' table.  -->
		<!-- This record needs to be followed by a TraverseAdjusted PointRecord that is not deleted.  -->
		<!-- This is because a traverse may have been adjusted more than once and if this is the case -->
		<!-- then the original traverse adjusted points are deleted.  Therefore if this is not the    -->
		<!-- final adjustment we don't want to output the traverse 'spreadsheet' details              -->
		<!-- Test the first PointRecord after the current TraverseClosureRecord to ensure it is a     -->
		<!-- non-deleted TraverseAdjusted point.                                                      -->
		<xsl:if test="ClosureStatus[.='Adjusted'] and
                following-sibling::PointRecord[1]/Method[.='TraverseAdjusted'] and
                following-sibling::PointRecord[1]/Deleted[.='false']">
			<xsl:call-template name="StartTable"/>
			<CAPTION align="left">
				<xsl:text>Traverse Summary: </xsl:text>
				<xsl:value-of select="$TraverseName"/>
			</CAPTION>
			<xsl:for-each select="TraverseLegs/Leg">
				<xsl:variable name="FromPt" select="FromPoint"/>
				<xsl:variable name="ToPt" select="ToPoint"/>
				<xsl:if test="position() = 1">
					<!-- The first traverse leg -->
					<!-- Get the starting point coordinates from the Reductions section -->
					<xsl:variable name="Coords">
						<xsl:for-each select="/JOBFile/Reductions/Point">
							<xsl:if test="Name = $FromPt">
								<xsl:value-of select="concat(Grid/North, '|', Grid/East)"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:call-template name="OutputTableLine">
						<xsl:with-param name="Hdr1">Point</xsl:with-param>
						<xsl:with-param name="Val1" select="FromPoint"/>
						<xsl:with-param name="Hdr4">
							<xsl:if test="$NECoords = 'True'">
								<xsl:value-of select="$northPrompt"/>
							</xsl:if>
							<xsl:if test="$NECoords != 'True'">
								<xsl:value-of select="$eastPrompt"/>
							</xsl:if>
						</xsl:with-param>
						<xsl:with-param name="Val4">
							<xsl:if test="$NECoords = 'True'">
								<xsl:value-of select="format-number(number(substring-before($Coords, '|')) * $DistConvFactor, $DecPl3, 'Standard')"/>
							</xsl:if>
							<xsl:if test="$NECoords != 'True'">
								<xsl:value-of select="format-number(number(substring-after($Coords, '|')) * $DistConvFactor, $DecPl3, 'Standard')"/>
							</xsl:if>
						</xsl:with-param>
						<xsl:with-param name="Hdr5">
							<xsl:if test="$NECoords = 'True'">
								<xsl:value-of select="$eastPrompt"/>
							</xsl:if>
							<xsl:if test="$NECoords != 'True'">
								<xsl:value-of select="$northPrompt"/>
							</xsl:if>
						</xsl:with-param>
						<xsl:with-param name="Val5">
							<xsl:if test="$NECoords = 'True'">
								<xsl:value-of select="format-number(number(substring-after($Coords, '|')) * $DistConvFactor, $DecPl3, 'Standard')"/>
							</xsl:if>
							<xsl:if test="$NECoords != 'True'">
								<xsl:value-of select="format-number(number(substring-before($Coords, '|')) * $DistConvFactor, $DecPl3, 'Standard')"/>
							</xsl:if>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
				<!-- Locate the traverse adjusted coordinates for the ToPoint following this closure record -->
				<xsl:variable name="Coords">
					<xsl:choose>
						<xsl:when test="position() != last()">
							<xsl:for-each select="following::PointRecord[Name = $ToPt]">
								<xsl:if test="(Method = 'TraverseAdjusted') and
                            (Deleted = 'false')">
									<xsl:value-of select="concat(Grid/North, '|', Grid/East, '|')"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<!-- This is the closing point so get coords from Reductions section -->
							<xsl:for-each select="/JOBFile/Reductions/Point">
								<xsl:if test="Name = $ToPt">
									<xsl:value-of select="concat(Grid/North, '|', Grid/East, '|')"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:call-template name="OutputTableLine">
					<xsl:with-param name="Hdr1">Point</xsl:with-param>
					<xsl:with-param name="Val1" select="ToPoint"/>
					<xsl:with-param name="Hdr2">Azimuth</xsl:with-param>
					<xsl:with-param name="Val2">
						<xsl:call-template name="FormatAzimuth">
							<xsl:with-param name="TheAzimuth">
								<xsl:value-of select="Polar/Azimuth"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="Hdr3">H.Dist</xsl:with-param>
					<xsl:with-param name="Val3" select="format-number(Polar/HorizontalDistance * $DistConvFactor, $DecPl3, 'Standard')"/>
					<xsl:with-param name="Hdr4">
						<xsl:if test="$NECoords = 'True'">
							<xsl:value-of select="$northPrompt"/>
						</xsl:if>
						<xsl:if test="$NECoords != 'True'">
							<xsl:value-of select="$eastPrompt"/>
						</xsl:if>
					</xsl:with-param>
					<xsl:with-param name="Val4">
						<xsl:if test="$NECoords = 'True'">
							<xsl:value-of select="format-number(number(substring-before($Coords, '|')) * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:if>
						<xsl:if test="$NECoords != 'True'">
							<xsl:variable name="Temp" select="substring-after($Coords, '|')"/>
							<xsl:value-of select="format-number(number(substring-before($Temp, '|')) * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:if>
					</xsl:with-param>
					<xsl:with-param name="Hdr5">
						<xsl:if test="$NECoords = 'True'">
							<xsl:value-of select="$eastPrompt"/>
						</xsl:if>
						<xsl:if test="$NECoords != 'True'">
							<xsl:value-of select="$northPrompt"/>
						</xsl:if>
					</xsl:with-param>
					<xsl:with-param name="Val5">
						<xsl:if test="$NECoords = 'True'">
							<xsl:variable name="Temp" select="substring-after($Coords, '|')"/>
							<xsl:value-of select="format-number(number(substring-before($Temp, '|')) * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:if>
						<xsl:if test="$NECoords != 'True'">
							<xsl:value-of select="format-number(number(substring-before($Coords, '|')) * $DistConvFactor, $DecPl3, 'Standard')"/>
						</xsl:if>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
			<xsl:call-template name="EndTable"/>
		</xsl:if>
		<!-- Now output the closure details -->
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">
			<xsl:text>Traverse Closure Details: </xsl:text>
			<xsl:value-of select="$TraverseName"/>
		</CAPTION>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Adjustment status</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:if test="ClosureStatus[.='NotAdjusted']">Not adjusted</xsl:if>
				<xsl:if test="ClosureStatus[.='Closed']">Closed</xsl:if>
				<xsl:if test="ClosureStatus[.='Adjusted']">
					<xsl:text>Adjusted</xsl:text>
					<xsl:value-of select="concat(' (', $AdjMethod, ')')"/>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Angular close</xsl:with-param>
			<xsl:with-param name="Val">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="AzimuthMisclose"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Distance close</xsl:with-param>
			<xsl:with-param name="Val" select="format-number(DistanceMisclose * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Traverse length</xsl:with-param>
			<xsl:with-param name="Val" select="format-number(TraverseLength * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr">Precision</xsl:with-param>
			<xsl:with-param name="Val" select="concat('1 : ', format-number(Precision, $DecPl1, 'Standard'))"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr" select="$dNorthPrompt"/>
			<xsl:with-param name="Val" select="format-number(DeltaNorth * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:call-template name="OutputSingleElementTableLine">
			<xsl:with-param name="Hdr" select="$dEastPrompt"/>
			<xsl:with-param name="Val" select="format-number(DeltaEast * $DistConvFactor, $DecPl3, 'Standard')"/>
		</xsl:call-template>
		<xsl:if test="DeltaElevation != ''">
			<xsl:call-template name="OutputSingleElementTableLine">
				<xsl:with-param name="Hdr" select="$dElevPrompt"/>
				<xsl:with-param name="Val" select="format-number(DeltaElevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** COGO Transformation Output ****************** -->
	<!-- **************************************************************** -->
	<xsl:template match="CogoTransformationRecord">
		<xsl:call-template name="StartTable"/>
		<CAPTION align="left">
			<xsl:text>Transformations: (Points transformed: </xsl:text>
			<xsl:value-of select="concat(NumberOfPointsTransformed, ')')"/>
		</CAPTION>
		<xsl:if test="Rotation">
			<xsl:call-template name="OutputTableLine">
				<xsl:with-param name="Hdr1">Rotation</xsl:with-param>
				<xsl:with-param name="Val1">Origin at</xsl:with-param>
				<xsl:with-param name="Hdr2">Point</xsl:with-param>
				<xsl:with-param name="Val2" select="Rotation/RotationOriginPoint"/>
				<xsl:with-param name="Hdr3">
					<xsl:if test="$NECoords = 'True'">
						<xsl:value-of select="$northPrompt"/>
					</xsl:if>
					<xsl:if test="$NECoords != 'True'">
						<xsl:value-of select="$eastPrompt"/>
					</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="Val3">
					<xsl:if test="$NECoords = 'True'">
						<xsl:value-of select="format-number(Rotation/RotationOriginGrid/North * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:if>
					<xsl:if test="$NECoords != 'True'">
						<xsl:value-of select="format-number(Rotation/RotationOriginGrid/East * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="Hdr4">
					<xsl:if test="$NECoords = 'True'">
						<xsl:value-of select="$eastPrompt"/>
					</xsl:if>
					<xsl:if test="$NECoords != 'True'">
						<xsl:value-of select="$northPrompt"/>
					</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="Val4">
					<xsl:if test="$NECoords = 'True'">
						<xsl:value-of select="format-number(Rotation/RotationOriginGrid/East * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:if>
					<xsl:if test="$NECoords != 'True'">
						<xsl:value-of select="format-number(Rotation/RotationOriginGrid/North * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="Hdr5" select="$elevPrompt"/>
				<xsl:with-param name="Val5" select="format-number(Rotation/RotationOriginGrid/Elevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
			<xsl:call-template name="OutputTableLine">
				<xsl:with-param name="Hdr1">Rotation</xsl:with-param>
				<xsl:with-param name="Hdr2">Angle</xsl:with-param>
				<xsl:with-param name="Val2">
					<xsl:call-template name="FormatAngle">
						<xsl:with-param name="TheAngle">
							<xsl:value-of select="Rotation/RotationAngle"/>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Scale">
			<xsl:call-template name="OutputTableLine">
				<xsl:with-param name="Hdr1">Scale</xsl:with-param>
				<xsl:with-param name="Val1">Origin at</xsl:with-param>
				<xsl:with-param name="Hdr2">Point</xsl:with-param>
				<xsl:with-param name="Val2" select="Scale/ScaleOriginPoint"/>
				<xsl:with-param name="Hdr3">
					<xsl:if test="$NECoords = 'True'">
						<xsl:value-of select="$northPrompt"/>
					</xsl:if>
					<xsl:if test="$NECoords != 'True'">
						<xsl:value-of select="$eastPrompt"/>
					</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="Val3">
					<xsl:if test="$NECoords = 'True'">
						<xsl:value-of select="format-number(Scale/ScaleOriginGrid/North * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:if>
					<xsl:if test="$NECoords != 'True'">
						<xsl:value-of select="format-number(Scale/ScaleOriginGrid/East * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="Hdr4">
					<xsl:if test="$NECoords = 'True'">
						<xsl:value-of select="$eastPrompt"/>
					</xsl:if>
					<xsl:if test="$NECoords != 'True'">
						<xsl:value-of select="$northPrompt"/>
					</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="Val4">
					<xsl:if test="$NECoords = 'True'">
						<xsl:value-of select="format-number(Scale/ScaleOriginGrid/East * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:if>
					<xsl:if test="$NECoords != 'True'">
						<xsl:value-of select="format-number(Scale/ScaleOriginGrid/North * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="Hdr5" select="$elevPrompt"/>
				<xsl:with-param name="Val5" select="format-number(Scale/ScaleOriginGrid/Elevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
			<xsl:call-template name="OutputTableLine">
				<xsl:with-param name="Hdr1">Scale</xsl:with-param>
				<xsl:with-param name="Hdr2">Scale factor</xsl:with-param>
				<xsl:with-param name="Val2" select="format-number(Scale/ScaleFactor, $DecPl8, 'Standard')"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="Translation">
			<xsl:call-template name="OutputTableLine">
				<xsl:with-param name="Hdr1">Translation</xsl:with-param>
				<xsl:with-param name="Val1">Deltas</xsl:with-param>
				<xsl:with-param name="Hdr2">Definition</xsl:with-param>
				<xsl:with-param name="Val2">
					<xsl:if test="Translation/TranslationDefinitionMethod[.='EnteredDeltas']">Entered data</xsl:if>
					<xsl:if test="Translation/TranslationDefinitionMethod[.='TwoPoints']">Two points</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="Hdr3">
					<xsl:if test="$NECoords = 'True'">
						<xsl:value-of select="$dNorthPrompt"/>
					</xsl:if>
					<xsl:if test="$NECoords != 'True'">
						<xsl:value-of select="$dEastPrompt"/>
					</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="Val3">
					<xsl:if test="$NECoords = 'True'">
						<xsl:value-of select="format-number(Translation/TranslationDeltas/DeltaNorth * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:if>
					<xsl:if test="$NECoords != 'True'">
						<xsl:value-of select="format-number(Translation/TranslationDeltas/DeltaEast * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="Hdr4">
					<xsl:if test="$NECoords = 'True'">
						<xsl:value-of select="$dEastPrompt"/>
					</xsl:if>
					<xsl:if test="$NECoords != 'True'">
						<xsl:value-of select="$dNorthPrompt"/>
					</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="Val4">
					<xsl:if test="$NECoords = 'True'">
						<xsl:value-of select="format-number(Translation/TranslationDeltas/DeltaEast * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:if>
					<xsl:if test="$NECoords != 'True'">
						<xsl:value-of select="format-number(Translation/TranslationDeltas/DeltaNorth * $DistConvFactor, $DecPl3, 'Standard')"/>
					</xsl:if>
				</xsl:with-param>
				<xsl:with-param name="Hdr5" select="$dElevPrompt"/>
				<xsl:with-param name="Val5" select="format-number(Translation/TranslationDeltas/DeltaElevation * $ElevConvFactor, $DecPl3, 'Standard')"/>
			</xsl:call-template>
			<xsl:if test="Translation/TranslationDefinitionMethod[.='TwoPoints']">
				<xsl:call-template name="OutputTableLine">
					<xsl:with-param name="Hdr1">Translation</xsl:with-param>
					<xsl:with-param name="Hdr2">Points</xsl:with-param>
					<xsl:with-param name="Hdr3">From point</xsl:with-param>
					<xsl:with-param name="Val3" select="Translation/TranslationFromPoint"/>
					<xsl:with-param name="Hdr4">To point</xsl:with-param>
					<xsl:with-param name="Val4" select="Translation/TranslationToPoint"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>
		<xsl:call-template name="EndTable"/>
		<xsl:call-template name="SeparatingLine"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ********************** Format a DMS Angle ********************** -->
	<!-- **************************************************************** -->
	<xsl:template name="FormatDMSAngle">
		<xsl:param name="DecimalAngle"/>
		<xsl:param name="SecDecPlaces" select="0"/>
		<xsl:variable name="Sign">
			<xsl:if test="$DecimalAngle &lt; '0.0'">-1</xsl:if>
			<xsl:if test="$DecimalAngle &gt;= '0.0'">1</xsl:if>
		</xsl:variable>
		<xsl:variable name="PosDecimalDegrees" select="number($DecimalAngle * $Sign)"/>
		<xsl:variable name="PositiveDecimalDegrees">
			<!-- Ensure an angle very close to 360° is treated as 0° -->
			<xsl:choose>
				<xsl:when test="(360.0 - $PosDecimalDegrees) &lt; 0.00001">
					<xsl:value-of select="0"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$PosDecimalDegrees"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="decPlFmt">
			<xsl:choose>
				<xsl:when test="$SecDecPlaces = 0">
					<xsl:value-of select="''"/>
				</xsl:when>
				<xsl:when test="$SecDecPlaces = 1">
					<xsl:value-of select="'.0'"/>
				</xsl:when>
				<xsl:when test="$SecDecPlaces = 2">
					<xsl:value-of select="'.00'"/>
				</xsl:when>
				<xsl:when test="$SecDecPlaces = 3">
					<xsl:value-of select="'.000'"/>
				</xsl:when>
				<xsl:when test="$SecDecPlaces = 4">
					<xsl:value-of select="'.0000'"/>
				</xsl:when>
				<xsl:when test="$SecDecPlaces = 5">
					<xsl:value-of select="'.00000'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="''"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="Degrees" select="floor($PositiveDecimalDegrees)"/>
		<xsl:variable name="DecimalMinutes" select="number(number($PositiveDecimalDegrees - $Degrees) * 60 )"/>
		<xsl:variable name="Minutes" select="floor($DecimalMinutes)"/>
		<xsl:variable name="Seconds" select="number(number($DecimalMinutes - $Minutes)*60)"/>
		<xsl:variable name="PartiallyNormalisedMinutes">
			<xsl:if test="number(format-number($Seconds, concat('00', $decPlFmt))) = 60">
				<xsl:value-of select="number($Minutes + 1)"/>
			</xsl:if>
			<xsl:if test="not(number(format-number($Seconds, concat('00', $decPlFmt))) = 60)">
				<xsl:value-of select="$Minutes"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="NormalisedSeconds">
			<xsl:if test="number(format-number($Seconds, concat('00', $decPlFmt))) = 60">
				<xsl:value-of select="0"/>
			</xsl:if>
			<xsl:if test="not(number(format-number($Seconds, concat('00', $decPlFmt))) = 60)">
				<xsl:value-of select="$Seconds"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="PartiallyNormalisedDegrees">
			<xsl:if test="format-number($PartiallyNormalisedMinutes, '0') = '60'">
				<xsl:value-of select="number($Degrees + 1)"/>
			</xsl:if>
			<xsl:if test="not(format-number($PartiallyNormalisedMinutes, '0') = '60')">
				<xsl:value-of select="$Degrees"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="NormalisedDegrees">
			<xsl:if test="format-number($PartiallyNormalisedDegrees, '0') = '360'">
				<xsl:value-of select="0"/>
			</xsl:if>
			<xsl:if test="not(format-number($PartiallyNormalisedDegrees, '0') = '360')">
				<xsl:value-of select="$PartiallyNormalisedDegrees"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="NormalisedMinutes">
			<xsl:if test="format-number($PartiallyNormalisedMinutes, '00') = '60'">
				<xsl:value-of select="0"/>
			</xsl:if>
			<xsl:if test="not(format-number($PartiallyNormalisedMinutes, '00') = '60')">
				<xsl:value-of select="$PartiallyNormalisedMinutes"/>
			</xsl:if>
		</xsl:variable>
		<xsl:value-of select="format-number(number($NormalisedDegrees * $Sign), '0')"/>
		<xsl:value-of select="$DegreesSymbol"/>
		<xsl:value-of select="format-number($NormalisedMinutes, '00')"/>
		<xsl:value-of select="$MinutesSymbol"/>
		<xsl:value-of select="format-number($NormalisedSeconds, concat('00', $decPlFmt))"/>
		<xsl:value-of select="$SecondsSymbol"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ******************* Format a Quadrant Bearing ****************** -->
	<!-- **************************************************************** -->
	<xsl:template name="FormatQuadrantBearing">
		<xsl:param name="DecimalAngle"/>
		<xsl:param name="SecDecPlaces" select="0"/>
		<xsl:choose>
			<!-- Null azimuth value -->
			<xsl:when test="string(number($DecimalAngle))='NaN'">
				<xsl:value-of select="'?'"/>
			</xsl:when>
			<!-- There is an azimuth value -->
			<xsl:otherwise>
				<xsl:variable name="QuadrantAngle">
					<xsl:if test="($DecimalAngle &lt;= '90.0')">
						<xsl:value-of select="number ( $DecimalAngle )"/>
					</xsl:if>
					<xsl:if test="($DecimalAngle &gt; '90.0') and ($DecimalAngle &lt;= '180.0')">
						<xsl:value-of select="number( 180.0 - $DecimalAngle )"/>
					</xsl:if>
					<xsl:if test="($DecimalAngle &gt; '180.0') and ($DecimalAngle &lt; '270.0')">
						<xsl:value-of select="number( $DecimalAngle - 180.0 )"/>
					</xsl:if>
					<xsl:if test="($DecimalAngle &gt;= '270.0') and ($DecimalAngle &lt;= '360.0')">
						<xsl:value-of select="number( 360.0 - $DecimalAngle )"/>
					</xsl:if>
				</xsl:variable>
				<xsl:variable name="QuadrantPrefix">
					<xsl:if test="($DecimalAngle &lt;= '90.0') or ($DecimalAngle &gt;= '270.0')">N</xsl:if>
					<xsl:if test="($DecimalAngle &gt; '90.0') and ($DecimalAngle &lt; '270.0')">S</xsl:if>
				</xsl:variable>
				<xsl:variable name="QuadrantSuffix">
					<xsl:if test="($DecimalAngle &lt;= '180.0')">E</xsl:if>
					<xsl:if test="($DecimalAngle &gt; '180.0')">W</xsl:if>
				</xsl:variable>
				<xsl:value-of select="$QuadrantPrefix"/>
				<xsl:choose>
					<xsl:when test="($AngleUnit='DMSDegrees') or ($AngleUnit='QuadrantBearings')">
						<xsl:call-template name="FormatDMSAngle">
							<xsl:with-param name="DecimalAngle" select="$QuadrantAngle"/>
							<xsl:with-param name="SecDecPlaces" select="$SecDecPlaces"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="FormatAngle">
							<xsl:with-param name="TheAngle" select="$QuadrantAngle"/>
							<xsl:with-param name="SecDecPlaces" select="$SecDecPlaces"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$QuadrantSuffix"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************ Output Angle in Appropriate Format **************** -->
	<!-- **************************************************************** -->
	<xsl:template name="FormatAngle">
		<xsl:param name="TheAngle"/>
		<xsl:param name="SecDecPlaces" select="0"/>
		<xsl:param name="DMSOutput" select="'False'"/>
		<xsl:choose>
			<!-- Null angle value -->
			<xsl:when test="string(number($TheAngle))='NaN'">
				<xsl:value-of select="'?'"/>
			</xsl:when>
			<!-- There is an angle value -->
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="($AngleUnit='DMSDegrees') or not($DMSOutput = 'False')">
						<xsl:call-template name="FormatDMSAngle">
							<xsl:with-param name="DecimalAngle" select="$TheAngle"/>
							<xsl:with-param name="SecDecPlaces" select="$SecDecPlaces"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="($AngleUnit='Gons') and ($DMSOutput = 'False')">
						<xsl:choose>
							<xsl:when test="$SecDecPlaces > 0">
								<!-- More accurate angle output required -->
								<xsl:value-of select="format-number($TheAngle * $AngleConvFactor, $DecPl8, 'Standard')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="format-number($TheAngle * $AngleConvFactor, $DecPl5, 'Standard')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="($AngleUnit='Mils') and ($DMSOutput = 'False')">
						<xsl:choose>
							<xsl:when test="$SecDecPlaces > 0">
								<!-- More accurate angle output required -->
								<xsl:value-of select="format-number($TheAngle * $AngleConvFactor, $DecPl6, 'Standard')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="format-number($TheAngle * $AngleConvFactor, $DecPl4, 'Standard')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="($AngleUnit='DecimalDegrees') and ($DMSOutput = 'False')">
						<xsl:choose>
							<xsl:when test="$SecDecPlaces > 0">
								<!-- More accurate angle output required -->
								<xsl:value-of select="format-number($TheAngle * $AngleConvFactor, $DecPl8, 'Standard')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="format-number($TheAngle * $AngleConvFactor, $DecPl5, 'Standard')"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************ Output Azimuth in Appropriate Format ************** -->
	<!-- **************************************************************** -->
	<xsl:template name="FormatAzimuth">
		<xsl:param name="TheAzimuth"/>
		<xsl:param name="SecDecPlaces" select="0"/>
		<xsl:param name="DMSOutput" select="'False'"/>
		<xsl:choose>
			<xsl:when test="(//Environment/DisplaySettings/AzimuthFormat = 'QuadrantBearings') or
                    ($AngleUnit = 'QuadrantBearings')">
				<xsl:call-template name="FormatQuadrantBearing">
					<xsl:with-param name="DecimalAngle" select="$TheAzimuth"/>
					<xsl:with-param name="SecDecPlaces" select="$SecDecPlaces"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle" select="$TheAzimuth"/>
					<xsl:with-param name="SecDecPlaces" select="$SecDecPlaces"/>
					<xsl:with-param name="DMSOutput" select="$DMSOutput"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ********* Output latitude or Longitude in DMS Format *********** -->
	<!-- **************************************************************** -->
	<xsl:template name="LatLongValue">
		<xsl:param name="TheAngle"/>
		<xsl:param name="IsLat" select="'True'"/>
		<xsl:choose>
			<!-- Null angle value -->
			<xsl:when test="string(number($TheAngle))='NaN'">?</xsl:when>
			<!-- There is a lat or long value -->
			<xsl:otherwise>
				<xsl:variable name="Sign">
					<xsl:choose>
						<xsl:when test="$TheAngle &lt; '0.0'">
							<xsl:choose>
								<!-- Negative value -->
								<xsl:when test="$IsLat = 'True'">S</xsl:when>
								<xsl:otherwise>W</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<!-- Positive value -->
							<xsl:choose>
								<xsl:when test="$IsLat = 'True'">N</xsl:when>
								<xsl:otherwise>E</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- Convert to a positive angle before changing to DMS format -->
				<xsl:variable name="PosAngle">
					<xsl:call-template name="Abs">
						<xsl:with-param name="TheValue" select="$TheAngle"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="latLongAngle">
					<xsl:call-template name="FormatDMSAngle">
						<xsl:with-param name="DecimalAngle" select="$PosAngle"/>
						<xsl:with-param name="SecDecPlaces" select="5"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="concat($latLongAngle, $Sign)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- *************** Return Formatted Station Value ***************** -->
	<!-- **************************************************************** -->
	<xsl:template name="FormattedStationVal">
		<xsl:param name="StationVal"/>
		<xsl:variable name="FormatStyle" select="/JOBFile/Environment/DisplaySettings/StationingFormat"/>
		<xsl:variable name="StnVal" select="format-number($StationVal * $DistConvFactor, $DecPl3, 'Standard')"/>
		<xsl:variable name="SignChar">
			<xsl:choose>
				<xsl:when test="$StnVal &lt; 0.0">
					<xsl:value-of select="'-'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="''"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="AbsStnVal">
			<xsl:call-template name="Abs">
				<xsl:with-param name="TheValue" select="$StnVal"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="IntPart" select="substring-before(format-number($AbsStnVal, $DecPl3, 'Standard'), $DecPt)"/>
		<xsl:variable name="DecPart" select="substring-after($StnVal, $DecPt)"/>
		<xsl:if test="$FormatStyle = '1000.0'">
			<xsl:value-of select="$StnVal"/>
		</xsl:if>
		<xsl:if test="$FormatStyle = '10+00.0'">
			<xsl:choose>
				<xsl:when test="string-length($IntPart) > 2">
					<xsl:value-of select="concat($SignChar, substring($IntPart, 1, string-length($IntPart) - 2),
                                     '+', substring($IntPart, string-length($IntPart) - 1, 2),
                                     $DecPt, $DecPart)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($SignChar, '0+', substring('00', 1, 2 - string-length($IntPart)),
                                     $IntPart, $DecPt, $DecPart)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$FormatStyle = '1+000.0'">
			<xsl:choose>
				<xsl:when test="string-length($IntPart) > 3">
					<xsl:value-of select="concat($SignChar, substring($IntPart, 1, string-length($IntPart) - 3),
                                     '+', substring($IntPart, string-length($IntPart) - 2, 3),
                                     $DecPt, $DecPart)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($SignChar, '0+', substring('000', 1, 3 - string-length($IntPart)),
                                     $IntPart, $DecPt, $DecPart)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** Return the absolute value ******************* -->
	<!-- **************************************************************** -->
	<xsl:template name="Abs">
		<xsl:param name="TheValue"/>
		<xsl:variable name="Sign">
			<xsl:choose>
				<xsl:when test="$TheValue &lt; '0.0'">
        -1
      </xsl:when>
				<xsl:otherwise>
        1
      </xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="number($Sign * $TheValue)"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************ Return value raised to specified power ************ -->
	<!-- **************************************************************** -->
	<xsl:template name="raiseToPower">
		<xsl:param name="number"/>
		<xsl:param name="power"/>
		<xsl:call-template name="raiseToPowerIter">
			<xsl:with-param name="multiplier" select="$number"/>
			<xsl:with-param name="accumulator" select="1"/>
			<xsl:with-param name="reps" select="$power"/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="raiseToPowerIter">
		<xsl:param name="multiplier"/>
		<xsl:param name="accumulator"/>
		<xsl:param name="reps"/>
		<xsl:choose>
			<xsl:when test="$reps &gt; 0">
				<xsl:call-template name="raiseToPowerIter">
					<xsl:with-param name="multiplier" select="$multiplier"/>
					<xsl:with-param name="accumulator" select="$accumulator * $multiplier"/>
					<xsl:with-param name="reps" select="$reps - 1"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$accumulator"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** Reductions Point Output ********************* -->
	<!-- **************************************************************** -->
	<xsl:template match="secPoint">
		<xsl:call-template name="GridPoint"/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ****************** Separating Line Output ********************** -->
	<!-- **************************************************************** -->
	<xsl:template name="SeparatingLine">
		<xsl:choose>
			<xsl:when test="$IncludeBorders != $YesStr">
				<!-- Only include separating lines -->
				<hr/>
				<!-- if there are no table borders -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="BlankLine"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************************ Output Table Line ********************* -->
	<!-- **************************************************************** -->
	<xsl:template name="OutputTableLine">
		<xsl:param name="Hdr1" select="''"/>
		<xsl:param name="Val1" select="''"/>
		<xsl:param name="Hdr2" select="''"/>
		<xsl:param name="Val2" select="''"/>
		<xsl:param name="Hdr3" select="''"/>
		<xsl:param name="Val3" select="''"/>
		<xsl:param name="Hdr4" select="''"/>
		<xsl:param name="Val4" select="''"/>
		<xsl:param name="Hdr5" select="''"/>
		<xsl:param name="Val5" select="''"/>
		<TR>
			<TH width="9%" align="left">
				<xsl:value-of select="$Hdr1"/>
			</TH>
			<TD width="11%" align="right">
				<xsl:value-of select="$Val1"/>
			</TD>
			<TH width="9%" align="left">
				<xsl:value-of select="$Hdr2"/>
			</TH>
			<TD width="11%" align="right">
				<xsl:value-of select="$Val2"/>
			</TD>
			<TH width="9%" align="left">
				<xsl:value-of select="$Hdr3"/>
			</TH>
			<TD width="11%" align="right">
				<xsl:value-of select="$Val3"/>
			</TD>
			<TH width="9%" align="left">
				<xsl:value-of select="$Hdr4"/>
			</TH>
			<TD width="11%" align="right">
				<xsl:value-of select="$Val4"/>
			</TD>
			<TH width="9%" align="left">
				<xsl:value-of select="$Hdr5"/>
			</TH>
			<TD width="11%" align="right">
				<xsl:value-of select="$Val5"/>
			</TD>
		</TR>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************** Output Single Element Table Line **************** -->
	<!-- **************************************************************** -->
	<xsl:template name="OutputSingleElementTableLine">
		<xsl:param name="Hdr" select="''"/>
		<xsl:param name="Val" select="''"/>
		<TR>
			<TH width="20%" align="left">
				<xsl:value-of select="$Hdr"/>
			</TH>
			<TD width="80%" align="left">
				<xsl:value-of select="$Val"/>
			</TD>
		</TR>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ********************* Blank Line Output ************************ -->
	<!-- **************************************************************** -->
	<xsl:template name="BlankLine">
		<xsl:value-of select="string(' ')"/>
		<BR/>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************************* Start Table ************************** -->
	<!-- **************************************************************** -->
	<xsl:template name="StartTable">
		<xsl:choose>
			<xsl:when test="$IncludeBorders = $YesStr">
				<xsl:value-of disable-output-escaping="yes" select="'&lt;TABLE BORDER=1 width=100% cellpadding=2 rules=cols&gt;'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of disable-output-escaping="yes" select="'&lt;TABLE BORDER=1 width=100% cellpadding=2 rules=cols&gt;'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- **************************************************************** -->
	<!-- ************************** End Table *************************** -->
	<!-- **************************************************************** -->
	<xsl:template name="EndTable">
		<xsl:value-of disable-output-escaping="yes" select="'&lt;/TABLE&gt;'"/>
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
	<xsl:template name="my-angle">
		<xsl:param name="Val" select="''"/>
		<xsl:choose>
			<xsl:when test="$Val">
				<xsl:call-template name="FormatAngle">
					<xsl:with-param name="TheAngle">
						<xsl:value-of select="$Val"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Space"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Datum template -->
	<xsl:template match="Datum">
		<h2 class="tableHeader">Transformacja układu odniesienia:</h2>
		<table width="100%" border="1">
			<tbody>
				<tr>
					<th>Typ</th>
					<th>Półoś większa</th>
					<th>Spłaszczenie</th>
					<th>Obrót dookoła X</th>
					<th>Obrót dookoła Y</th>
					<th>Obrót dookoła Z</th>
					<th>Przesunięcie X </th>
					<th>Przesunięcie Y</th>
					<th>Przesunięcie Z</th>
					<th>Skala</th>
				</tr>
				<tr>
					<td>
						<xsl:choose>
							<xsl:when test="Type='SevenParameter'">7 parametrowa</xsl:when>
							<xsl:when test="Type='ThreeParameter'">3 parametrowa</xsl:when>
							<xsl:otherwise>Nieznana</xsl:otherwise>
						</xsl:choose>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="EarthRadius"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="Flattening"/>
							<xsl:with-param name="format" select="$DecPl5"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-angle">
							<xsl:with-param name="Val" select="RotationX"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-angle">
							<xsl:with-param name="Val" select="RotationY"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-angle">
							<xsl:with-param name="Val" select="RotationZ"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="TranslationX"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="TranslationY"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="TranslationZ"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</td>
					<td>
						<xsl:call-template name="my-format">
							<xsl:with-param name="Val" select="Scale"/>
							<xsl:with-param name="format" select="$DecPl3"/>
						</xsl:call-template>
					</td>
				</tr>
			</tbody>
		</table>
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
	
	
	<!-- **************************************************************** -->
	<!-- ***************** Return Formatted Date String ***************** -->
	<!-- **************************************************************** -->
	<xsl:template name="formattedDate">
	  <xsl:param name="timeStamp"/>

	  <xsl:variable name="date" select="substring($timeStamp, 9, 2)"/>

	  <xsl:variable name="month">
	    <xsl:variable name="monthNbr" select="substring($timeStamp, 6, 2)"/>
	    <xsl:choose>
	      <xsl:when test="number($monthNbr) = 1">styczeń</xsl:when>
	      <xsl:when test="number($monthNbr) = 2">luty</xsl:when>
	      <xsl:when test="number($monthNbr) = 3">marzec</xsl:when>
	      <xsl:when test="number($monthNbr) = 4">kwieceń</xsl:when>
	      <xsl:when test="number($monthNbr) = 5">maj</xsl:when>
	      <xsl:when test="number($monthNbr) = 6">czerwiec</xsl:when>
	      <xsl:when test="number($monthNbr) = 7">lipiec</xsl:when>
	      <xsl:when test="number($monthNbr) = 8">sierpień</xsl:when>
	      <xsl:when test="number($monthNbr) = 9">wrzesień</xsl:when>
	      <xsl:when test="number($monthNbr) = 10">październik</xsl:when>
	      <xsl:when test="number($monthNbr) = 11">listopad</xsl:when>
	      <xsl:when test="number($monthNbr) = 12">grudzień</xsl:when>
	    </xsl:choose>
	  </xsl:variable>

	  <xsl:value-of select="concat($date, ' ', $month, ' ', substring($timeStamp, 1, 4))"/>
	</xsl:template>


	<!-- **************************************************************** -->
	<!-- ******** Build up a node set of the valid output dates ********* -->
	<!-- **************************************************************** -->
	<xsl:template name="inDateRange">
	  <xsl:param name="date"/>

	  <xsl:choose>
	    <xsl:when test="($startJulianDay = '') or ($endJulianDay = '')">true</xsl:when>
	    <xsl:otherwise>
	      <xsl:variable name="thisJulianDay">
	        <xsl:call-template name="julianDay">
	          <xsl:with-param name="timeStamp" select="concat($date, 'T00:00:00')"/>
	        </xsl:call-template>
	      </xsl:variable>

	      <xsl:choose>
	        <xsl:when test="($thisJulianDay &gt;= $startJulianDay) and ($thisJulianDay &lt;= $endJulianDay)">true</xsl:when>
	        <xsl:otherwise>false</xsl:otherwise>
	      </xsl:choose>
	    </xsl:otherwise>
	  </xsl:choose>

	</xsl:template>


	<!-- **************************************************************** -->
	<!-- ********* Return the Julian Day for a given TimeStamp ********** -->
	<!-- **************************************************************** -->
	<xsl:template name="julianDay">
	  <!-- The formula used in this function is valid for the years 1901 - 2099 -->
	  <xsl:param name="timeStamp"/>

	  <xsl:variable name="Y" select="substring($timeStamp, 1, 4)"/>
	  <xsl:variable name="M" select="substring($timeStamp, 6, 2)"/>
	  <xsl:variable name="D" select="substring($timeStamp, 9, 2)"/>
	  <xsl:variable name="h" select="substring($timeStamp, 12, 2)"/>
	  <xsl:variable name="m" select="substring($timeStamp, 15, 2)"/>
	  <xsl:variable name="s" select="substring($timeStamp, 18, 2)"/>

	  <xsl:value-of select="format-number(367 * $Y - floor(7 * ($Y + floor(($M + 9) div 12)) div 4) +
	                                      floor(275 * $M div 9) + $D + 1721013.5 +
	                                      ($h + $m div 60 + $s div 3600) div 24, '0.000000000')"/>
	</xsl:template>



	
</xsl:stylesheet>
