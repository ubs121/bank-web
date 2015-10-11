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
parameters=Request.cookies("TA1680B")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)

Dim selsent, items, sent, sentitems
selsent = "qselect dict rate.model @VERSIONS (1"
items = PickLin.get_dropdown(session("logentry"),cstr(selsent),"")
Itemarray = Split(Items, ">")
For ctr = 0 To UBound(Itemarray)
    Startstr = InStr(1, Itemarray(ctr), Chr(34))
    If Startstr <> 0 Then
        lstr = Len(Itemarray(ctr))
        Endstr = InStr(Startstr + 1, Itemarray(ctr), Chr(34))
        work = Left(Itemarray(ctr), Startstr) & CStr(ctr + 3) & Right(Itemarray(ctr), (lstr - Endstr) + 1)
        Itemarray(ctr) = work
    End If
Next 
Items = Join(Itemarray, ">")

Dim RateDesc()
logarray = split(session("logentry"),Chr(254))
dbase = logarray(1)
nocds = picklin.sr16_catnum(cstr(dbase))
Redim RateDesc(nocds + 1)

for i = 1 to nocds
RateDesc(i) = picklin.sr16_catdesc(cstr(dbase),cint(i))
next

%>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm"><B>Select Rate Model</B>
<td><select name="1,0,0,Version">
<OPTION VALUE="1">Use Current Rating Parameters
<%
response.write(items)
%>
</select>

<TR>
<TD CLASS="mm"><B>Current Values</B>
<TD><input type="Radio" name="2,0,0,Value Options" value="0" align="LEFT" size="10" maxlength="10" checked>

<TR>
<TD  CLASS="mm"><B>Future Values</B>
<TD><input type="Radio" name="2,0,0,Value Options" value="1" align="LEFT" size="10" maxlength="10">


<TR>
<TD CLASS="mm"><B>Charging Category</B>
<td><select name="3,0,0,Category">
<%
For i = 1 to nocds
response.write("<OPTION VALUE = " & Chr(34) & i & Chr(34) & ">" & RateDesc(i))
Next
%>
</select>

<TR>
<TD CLASS="mm"><B>Display Rate Model By</B>
<td><select name="4,0,0,Sorts">
<OPTION VALUE="1">Assesment
<OPTION VALUE="2">Zone
<OPTION VALUE="3">Rate Category
<OPTION VALUE="4">Ward
<OPTION VALUE="5">$ Limits Value
<OPTION VALUE="6">$ Limits Rates
<OPTION VALUE="7">Variances $ Value
<OPTION VALUE="8">Variances % Value
<OPTION VALUE="9">Variances $ Rates
<OPTION VALUE="10">Variances % Rates
</select>

<TR>
<TD CLASS="mm"><B>Lower Limit</B>
<TD><input type="Text" name="5,0,0,Lower Limit" value="<%=parms(0)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Upper Limit</B>
<TD><input type="Text" name="6,0,0,Upper Limit" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

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

