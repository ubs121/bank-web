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
parameters=Request.cookies("TA245")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
items = PickLin.make_options(session("logentry"),"BANKS", "")

%>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm"><B>Bank Accounts</B>
<select name="1,0,0,Bank Accounts">
<%
response.write(items)
%>
</select>

<TR>
<TD CLASS="mm"><B>Cheque Range (N,N)</B>
<TD><input type="Text" name="2,0,0,Cheque Range" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Date Submitted to Council/Finance</B>
<TD><input type="Text" name="C3,0,0,Date Submitted to Council/Finance,,D2X" value="<%=parms(2)%>" align="LEFT" size="10" maxlength="10">

</TABLE>

<TABLE align="center">
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

