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
validated = Request.Querystring("validated")
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

<FORM NAME="assetdata">
<input type="hidden" name="before" value="">
<input type="hidden" name="after" value="">
<input type="hidden" name="validated" value="">
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
parameters=Request.cookies("TA1654")("parms")
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

codestr = picklin.sr16_cat_str(cstr(database))
temp = split(codestr,chr(254))
tempcodes = temp(3)

RateCodes = split(cstr(tempcodes),Cstr(chr(253)))


itemsnum = PickLin.make_options(session("logentry"),"PRINTERSNUM", "")
%>
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR CLASS="top">
<TD  CLASS="mm">
<TR>
<TD CLASS="mm"><B>Charging Category</B>
<td><select name="1,0,0,Category">
<%
For i = 1 to nocds
response.write("<OPTION VALUE = " & Chr(34) & RateCodes(i-1) & Chr(34) & ">" & RateDesc(i))
Next
%>
</select>


<TR>
<TD CLASS="mm">Date Range FROM Date
<TD><input type="Text" name="C2,0,0,Date Range FROM Date,,D2X" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm">Date Range TO Date
<TD><input type="Text" name="C3,0,0,Date Range TO Date,,D2X" value="<%=parms(2)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm">Summary only 
<TD><input type="radio" name="C4,0,0,Report Type" value="1" align="LEFT"  checked>
<TR>
<TD CLASS="mm">Full Report
<TD><input type="radio" name="C4,0,0,Report Type" value="0" align="LEFT" >

<TR>
<TD CLASS="mm"><B>Printer</B>
<TD><select name="C5,0,0,Printer"">
<%
response.write(itemsnum)
%>

</TABLE>

<TABLE align="center">
<TR>
<TD colspan=2 align="center" CLASS="mm"><B><%=replace(sentence,chr(8),"""")%></B>
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
<%
if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")   
   cook_id="TA1654"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
   Set cka_ta16 = Server.CreateObject("cka_ta16.ta16")
'response.write("after = " & after)
'response.end
   itemlist=cka_ta16.TA1654(session("logentry"), cstr(after))
   Set cka_ta16 = nothing
   if left(itemlist,1) = chr(8) then
      response.write("<tr><td align=center>" & "Error " & mid(itemlist,2))
   else
      response.write("<tr><td align=center" & "Printed</tr>")
   end if
   validated = ""
end if
%>
</TABLE>

</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
<FORM name=login ><INPUT TYPE=hidden NAME=status VALUE="<%= status%>"></FORM>

</BODY>
</HTML>

