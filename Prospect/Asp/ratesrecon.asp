<% 
response.expires = 0 
%>
<HTML>
<HEAD>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
result = Request.Querystring("result")
%>
<TITLE>Prospect Log In</TITLE>
<SCRIPT LANGUAGE="VBSCRIPT">
Sub setupinputbox
	document.forms.verify.Username.select
end sub
</SCRIPT>
<SCRIPT LANGUAGE="VBSCRIPT" SRC="/prospect/jscript/validate.js"></SCRIPT>
<SCRIPT LANGUAGE="JAVASCRIPT1.2" SRC="/prospect/jscript/clear.js"></SCRIPT>
</HEAD>

<BODY>

<FORM ACTION="/prospect/asp/reporting.asp" METHOD="POST" NAME="assetdata">
<input type="hidden" name="before" value="">
<input type="hidden" name="after" value="">
<input type="hidden" name="sentence" value="<%=Replace(Request.Form("sentence"),chr(34),"|")%>">
<input type="hidden" name="reportname" value="1651 Rates Reconciliation Report">
<input type="hidden" name="template" value="<%=Request.Querystring("template")%>">
</FORM>

<FORM name=item_status>
<INPUT TYPE=hidden NAME=item VALUE="<%= found%>">
<INPUT TYPE=hidden NAME=baditem VALUE="<%= baditem%>">
</FORM>


<FORM ACTION="/prospect/asp/reporting.asp" METHOD="POST" NAME="assetform">

<%
parameters=Request.cookies("TA1651")("parms")
parms=split(parameters,chr(254))
redim preserve parms(10)

%>
<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2>Rates Reconciliation Report
<TR>
<TD colspan=2 align="center" CLASS="mm"><B><%=Request.Form("sentence")%></B>

<TR>
<TD CLASS="mm"><B>Date Before Which Rates will be in Arrears</B>
<TD><input type="text" name="C1,0,0,Arrears Date,,D2" value="<%=parms(0)%>" align="LEFT" size="10" maxlength="10" >
<TR>
<TD CLASS="mm"><B>Date To Process To</B>
<TD><input type="text" name="C2,0,0,Process To Date,,D2" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10" >

<TR>
<TD CLASS="mm"><B>Summarise By</B>
<td><select name="3,0,0,Summaries">
<OPTION VALUE="1">Zoning
<OPTION VALUE="2">Use
<OPTION VALUE="3">Rating Flag {catg.1}
<OPTION VALUE="4">Ward
</select>

<TR>
<TD CLASS="mm"><B>Summary By Sort Option</B>
<TD><input type="Radio" name="4,0,0,Value Options" value="1" align="LEFT" size="10" maxlength="10" checked>

<TR>
<TD  CLASS="mm"><B>One Line per Assessment</B>
<TD><input type="Radio" name="4,0,0,Value Options" value="2" align="LEFT" size="10" maxlength="10">

<TR>
<TD  CLASS="mm"><B>Full Report</B>
<TD><input type="Radio" name="4,0,0,Value Options" value="2" align="LEFT" size="10" maxlength="10">

</TABLE>
<TABLE align="center">
<TR>
<TD CLASS="tdempty" align="CENTER">
    <OBJECT ID="Report"
     CLASSID="CLSID:D7053240-CE69-11CD-A777-00DD01143C57" >
        <PARAM NAME="ForeColor" VALUE="60">
        <PARAM NAME="BackColor" VALUE="9221330">
        <PARAM NAME="Caption" VALUE="Report">
        <PARAM NAME="Size" VALUE="1400;700">
        <PARAM NAME="FontName" VALUE="Arial">
        <PARAM NAME="FontEffects" VALUE="1073741825">
        <PARAM NAME="FontHeight" VALUE="180">
        <PARAM NAME="FontCharSet" VALUE="0">
        <PARAM NAME="FontPitchAndFamily" VALUE="2">
        <PARAM NAME="ParagraphAlign" VALUE="3">
        <PARAM NAME="FontWeight" VALUE="700">
    </OBJECT>
<TD CLASS="tdempty" align="CENTER">
<%
if result <> "" then
   result = replace(result,"_"," ")
   response.write("<TR><TD colspan=2 align=center><B>" & result & "</B>")
end if
%>
</TABLE>

</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
<FORM name=login ><INPUT TYPE=hidden NAME=status VALUE="<%= status%>"></FORM>

</BODY>
</HTML>

