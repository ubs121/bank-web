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
parameters=Request.cookies("TA2031")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
%>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TR>
<TD CLASS="mm"><B>All Orders</b>
<TD><input type="radio" name="1,0,0,Order Selection" value="A" align="LEFT" size="10" maxlength="10" checked>

<TR>
<TD CLASS="mm"><B>Outstanding Orders</b>
<TD><input type="radio" name="1,0,0,Order Selection" value="O" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Due By</B>
<TD><input type="Text" name="2,0,0,Due By,,D2X" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Supplier</B>
<TD><input type="Text" name="3,0,0,Supplier" value="<%=parms(2)%>" align="LEFT" size="10" maxlength="10">


<TR>
<TD CLASS="mm"><B>Product, G/L Account or Job</B>
<TD><input type="Text" name="4,0,0,Product, G/L Account or Job,," value="<%=parms(3)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Branch</B>
<TD><input type="Text" name="5,0,0,Branch" value="<%=parms(4)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>1. Sort by Supplier </b>
<TD><input type="radio" name="6,0,0,Sort Order" value="S" align="LEFT" size="10" maxlength="10" checked>

<TR>
<TD CLASS="mm"><B>2. Sort by Order Number </b>
<TD><input type="radio" name="6,0,0,Sort Order" value="O" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>3. Sort by Job Number </b>
<TD><input type="radio" name="6,0,0,Sort Order" value="J" align="LEFT" size="10" maxlength="10">


<TR>
<TD CLASS="mm"><B>Double Spacing (Y/N)?</B>
<TD><input type="Text" name="C7,0,0,Double Spacing,,YN" value="<%=parms(6)%>" align="LEFT" size="10" maxlength="10">

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

