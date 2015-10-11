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
parameters=Request.cookies("TA2867")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
items = PickLin.make_options(session("logentry"),"SSELECT", "pp.type by a1|2|pp.type|1")
%>
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR CLASS="top">
<TD  CLASS="mm"><B>Enter the Pay Type</B>
<TD class="mm">
<select name="1,0,0,Pay type">
<%
response.write(items)
%>
</select>
<TR>
<TD CLASS="mm"><B>Pay Date</B>
<TD><input type="Text" name="C2,0,0,Pay Date,,D2X" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm" ><B>Sort by (C)ost Centre <BR>or by (N)ame</B>
<TD >
<input type="radio" name="C3,0,0,Sort by (C)ost Centre or by (N)ame" value="C" align="LEFT" size="10" maxlength="10" checked><BR>
<input type="radio" name="C3,0,0,Sort by (C)ost Centre or by (N)ame" value="N" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Enter the selected Cost Centres (seperated by a space) or BLANK for all. </B>
<TD><input type="Text" name="4,0,0,Enter the selected Cost Centres (seperated by a space) or BLANK for all." value="<%=parms(3)%>" align="LEFT" size="10" maxlength="10">

<TR CLASS="top">
<TH colspan=2><B>Select Report Type</B>

<TR>
<TD CLASS="mm"><B>1. Report one-line summary per employee </B>
<TD><input type="radio" name="5,0,0,Select Report Type" value="1" align="LEFT" size="10" maxlength="10" checked>

<TR>
<TD CLASS="mm"><B>2. Full details per employee </B>
<TD><input type="radio" name="5,0,0,Select Report Type" value="2" align="LEFT" size="10" maxlength="10">



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

