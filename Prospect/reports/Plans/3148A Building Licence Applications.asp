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
parameters=Request.cookies("TA3148A")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
works = PickLin.make_options(session("logentry"),"SSELECT", "bl_work by a1|2|bl_work|1")
buildings = PickLin.make_options(session("logentry"),"SSELECT", "bl_building by a1|2|bl_building|1")
feecodes = PickLin.make_options(session("logentry"),"SSELECT", "BL_FEE by a1|2|BL_FEE|1")
%>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=4><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm"><B>From Application date</B>
<TD><input type="Text" name="1,0,0,From Application date,,D2" value="<%=parms(0)%>" align="LEFT" size="10" maxlength="10">

<TD CLASS="mm"><B>To Application date</B>
<TD><input type="Text" name="2,0,0,To Application date,,D2" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Work Type</B>
<TD colspan=3>
<select name="3,0,0,Work Type">
<%
response.write(works)
%>
</select>

<TR>
<TD CLASS="mm"><B>Building Type</B>
<TD colspan=3>
<select name="4,0,0,Building Type">
<%
response.write(buildings)
%>
</select>

<TR>
<TD CLASS="mm"><B>Fee Codes (multiple selection allowed)</B>
<TD colspan=3>
<select multiple type="select-multiple" name="5,0,0,Fee Codes">
<%
response.write(feecodes)
%>
</select>

<TR>
<TD CLASS="mm"><B>Application Status</B>
<TD colspan=3><select name="C6,0,0,Statistics by" value="<%=parms(2)%>">
<OPTION VALUE="N All applications not cancelled">All applications not cancelled
<OPTION VALUE="Z All approved applications">All approved applications
<OPTION VALUE="P Pending applications">Pending applications
<OPTION VALUE="A Applications approved but fees not raised">Applications approved but fees not raised
<OPTION VALUE="I Applications where fees raised but not started">Applications where fees raised but not started

<OPTION VALUE="B Applications approved but not issued">Applications approved but not issued
<OPTION VALUE="J Applications issued but not started">Applications issued but not started

<OPTION VALUE="S Application construction Started">Application construction Started
<OPTION VALUE="C Application construction complete">Application construction complete
<OPTION VALUE="X Cancelled">Cancelled
</select>

</TABLE>

<TABLE align="center">
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
