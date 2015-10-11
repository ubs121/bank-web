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
<SCRIPT LANGUAGE="JAVASCRIPT1.2" SRC="/prospect/jscript/clear.js"></SCRIPT>
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
parameters=Request.cookies("TA2878")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
items = PickLin.make_options(session("logentry"),"SSELECT", "pp.type by a1|2|pp.type|1")

%>
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>

<TR>
<TD CLASS="mm" ><B>Pay type</B>
<TD class="mm">
<select name="1,0,0,Pay type">
<%
response.write(items)
%>
</select>

<TR>
<TD CLASS="mm"><B>Starting date for report</B>
<TD><input type="Text" name="C2,0,0,Start Date,,D2X" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Ending date for report</B>
<TD><input type="text" name="3,0,0,Ending date,,D2X" value="<%=parms(2)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Previous deduction period ended</B>
<TD><input type="text" name="4,0,0,Previous ending date,,D2X" value="<%=parms(3)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Report All deduction codes</B>
<TD><input type="radio" name="5,0,0,All deduction codes" value="A" align="LEFT" size="10" maxlength="10" checked >

<TR>
<TD CLASS="mm"><B>Print employee Surname and initials?</B>
<TD><input type="radio" name="6,0,0,Print employee Surname " value="S" align="LEFT" size="10" maxlength="10" checked>

<TR>
<TD CLASS="mm"><B>Print employee Full name and address?</B>
<TD><input type="radio" name="6,0,0,Print employee Surname " value="F" align="LEFT" size="10" maxlength="10">



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

