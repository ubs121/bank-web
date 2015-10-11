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
parameters=Request.cookies("TA1648")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
%>
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR CLASS="top">
<TH colspan=2><B>Select Instalment payment option to be reported.</B> 
<TR>
<TD CLASS="mm"><B> 2    Instalment Payments </B>
<TD><input type="radio" name="1,0,0,Instalment Payments" value="2" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B> 4    Instalment Payments </B>
<TD><input type="radio" name="1,0,0,Instalment Payments" value="4" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B> ALL    Instalment Payments </B>
<TD><input type="radio" name="1,0,0,Instalment Payments" value="ALL" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B> REPORT - Instalment Variances </B>
<TD><input type="radio" name="1,0,0,Instalment Payments" value="REPORT" align="LEFT" size="10" maxlength="10" checked>

<TR CLASS="top">
<TH colspan=2> <B>Select the report format.</b>
<TR>
<TD CLASS="mm"><B>Summarised report (50 assessments per page)</B>
<TD><input type="radio" name="2,0,0,Report format" value="1" align="LEFT" size="10" maxlength="10" checked>

<TR>
<TD CLASS="mm"><B>Summary only (3 schemes per page)</B>
<TD><input type="radio" name="2,0,0,Report format" value="2" align="LEFT" size="10" maxlength="10">

<TR CLASS="top">
<TH colspan=2><B>Enter the following Details.</B>
<TR>
<TD CLASS="mm"><B>Report Instalment Position as at date: </<B>
<TD><input type="text" name="3,0,0,Report Instalment Position as at date:,,D2X " value="<%=parms(2)%>" align="LEFT" size="10" maxlength="10" >

</TABLE>

<TABLE align="center">
<TR>
<TD colspan=2 align="center" CLASS="mm"><B><%=replace(sentence,chr(8),"""")%></B>
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
<%
if result <> "" then
   response.write("<TR><TD colspan=2 align=center><B>" & result & "</B>")
end if
%>
</TABLE>

</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
<FORM name=login ><INPUT TYPE=hidden NAME=status VALUE="<%= status%>"></FORM>

</BODY>
</HTML>

