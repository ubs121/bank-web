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
parameters=Request.cookies("TA1665")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)

Dim RateDesc()
logarray = split(session("logentry"),Chr(254))
dbase = logarray(1)
nocds = picklin.sr16_catnum(cstr(dbase))
Redim RateDesc(nocds + 1)

for i = 1 to nocds
RateDesc(i) = picklin.sr16_catdesc(cstr(dbase),cint(i))
next
Dim DQ
DQ = Chr(34)
'For i = 1 to nocds
'response.write(RateDesc(i) & "<BR>")
'Next
'response.end

%>
<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm" align="center"><B>Charging Category</B>
<%
For i = 1 to nocds
response.write("<TR><TD><input type=" & DQ & "checkbox" & DQ & " name=" & DQ & "1," & i & ",,Categ" & i & DQ & " value=" & DQ & i & DQ & ">" & RateDesc(i))
Next
%>
<TR>
<TD CLASS="mm"><B>Year to Appear on Heading</B>
<TD><input type="text" name="2,0,0,Year on Heading" value="2000/2001"LEFT" size="10" maxlength="10" >
<TR>
<TD CLASS="mm"><B>Ex Gratia Rates Account</B>
<TD><input type="text" name="3,0,0,Ex Gratia Rates" value="NONE" align="LEFT" size="10" maxlength="10" >

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
