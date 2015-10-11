<% 
response.expires = 0 
response.addHeader "pragma", "no-cache"
response.cachecontrol = "public"
%>
<HTML>
<HEAD>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
result = Request.Querystring("result")
sentence = Request.Querystring("sentence")
sentence=replace(sentence,"""",chr(8))
%>
<TITLE>Prospect Log In</TITLE>
<SCRIPT LANGUAGE="VBSCRIPT">
Sub setupinputbox
	document.forms.verify.Username.select
end sub
</SCRIPT>
<SCRIPT LANGUAGE="VBSCRIPT" SRC="/prospect/jscript/validate.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript1.2" SRC="/prospect/jscript/clear.js"></SCRIPT>
</HEAD>

<BODY>

<FORM ACTION="/prospect/asp/reporting.asp" METHOD="POST" NAME="assetdata">
<input type="hidden" name="before" value="">
<input type="hidden" name="after" value="">
<input type="hidden" name="sentence" value="<%=sentence%>">
<input type="hidden" name="reportname" value="<%=Request.Querystring("reportname")%>">
<input type="hidden" name="template" value="<%=Request.Querystring("template")%>">
</FORM>

<FORM name=item_status>
<INPUT TYPE=hidden NAME=item VALUE="<%= found%>">
<INPUT TYPE=hidden NAME=baditem VALUE="<%= baditem%>">
</FORM>


<FORM ACTION="/prospect/asp/reporting.asp" METHOD="POST" NAME="assetform">

<%
parameters=Request.cookies("TA2857")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
%>
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR CLASS="top">
<TH colspan=2><B>Report Selection Options</B>


<TR>
<TD CLASS="mm"><B>All Timesheets</B>
<TD><input type="Radio" name="1,0,0,Timesheets Options" value="A" align="LEFT" size="10" maxlength="10" checked>


<TR CLASS="top">
<TD  CLASS="mm"><B>By nominated location</B>
<TD><input type="Radio" name="1,0,0,Timesheets Options" value="L" align="LEFT" size="10" maxlength="10">


<TR CLASS="top">
<TD  CLASS="mm"><B>by nominated Pay Type </B>
<TD><input type="Radio" name="1,0,0,Timesheets Options" value="P" align="LEFT" size="10" maxlength="10">

<TR CLASS="top">
<TD  CLASS="mm"><B>by nominated Employee </B>
<TD><input type="Radio" name="1,0,0,Timesheets Options" value="E" align="LEFT" size="10" maxlength="10">


<TR CLASS="top">
<TH colspan=2><B>Enter Date Range</B>

<TR>
<TD CLASS="mm"><B>Pay Dates from Start Date</B>
<TD><input type="Text" name="C2,0,0,Pay Dates from Start Date,,D2X" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>to End Date </B>
<TD><input type="Text" name="C3,0,0,to End Date,,D2X" value="<%=parms(2)%>" align="LEFT" size="10" maxlength="10">

<TR CLASS="top">
<TH colspan=2><B>Report Sort Options</B>

<TR>
<TD CLASS="mm"><B>1. Timesheet Date by Employee Number</B>
<TD><input type="Radio" name="4,0,0,Report Sort Options" value="1" align="LEFT" size="10" maxlength="10" checked>
<TR>
<TD CLASS="mm"><B>2. Timesheets Date by Employee Name</B>
<TD><input type="Radio" name="4,0,0,Report Sort Options" value="2" align="LEFT" size="10" maxlength="10">
<TR>
<TD CLASS="mm"><B>3. Timesheets Date by Employee Location by Employee Name</B>
<TD><input type="Radio" name="4,0,0,Report Sort Options" value="3" align="LEFT" size="10" maxlength="10">
<TR>
<TD CLASS="mm"><B>4. Employee Number by Timesheet Date</B>
<TD><input type="Radio" name="4,0,0,Report Sort Options" value="4" align="LEFT" size="10" maxlength="10">
<TR>
<TD CLASS="mm"><B>5. Employee Name by Timesheet Date</B>
<TD><input type="Radio" name="4,0,0,Report Sort Options" value="5" align="LEFT" size="10" maxlength="10">
<TR>
<TD CLASS="mm"><B>6. Employee Location by Employee Name</B>
<TD><input type="Radio" name="4,0,0,Report Sort Options" value="6" align="LEFT" size="10" maxlength="10">



</TABLE>

<TABLE align="center">
<TR>
<TD colspan=2 align="center" CLASS="mm"><B><%=replace(sentence,chr(8),"""")%></B>
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
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

