<% 
response.expires = 0 
response.addHeader "pragma", "no-cache"
response.cachecontrol = "public"
response.buffer=true
%>
<HTML>
<HEAD>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
validated = Request.Querystring("validated")
sentence = Request.Querystring("sentence")
sentence=replace(sentence,"""",chr(8))
spos=instr(sentence," by ")
if spos then
   sentence=left(sentence,spos-1)
end if
%>
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

<FORM ACTION="<%=request.servervariables("path_info")%>" METHOD="POST" NAME="assetform">
<%
parameters=Request.cookies("TA1465")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
dates=picklin.make_options(session("logentry"), "MEASSET", "9|8|7|33",cstr(parms(0)))
dim sort(4)
' DO NOT ALTER THESE NAMES - THEY ARE CHECKED IN TA1465 DLL
sort(0)="<OPTION VALUE=""BY LOCN BY GROUP BY ASSET.NO"">by Location by Group by Asset Id"
sort(1)="<OPTION VALUE=""BY LOCN BY CLASS BY ASSET.NO"">by Location by Class by Asset Id"
sort(2)="<OPTION VALUE=""BY TYPE BY CLASS BY GROUP BY PUR.DATE BY ASSET.NO"">by Location by Class by Purchase Date by Asset Id"
sort(3)="<OPTION VALUE=""BY GL.ACC BY ASSET.NO"">by G/L Provision for Depreciation Account by Asset Id"
'sort(4)="<OPTION VALUE=""BY LOCN BY PROJECT BY GROUP BY ASSET.NO"">by Location by Project by Group by Asset Id"
defsort="<OPTION VALUE=""" & parms(2) & """>"
sorts=""
for j=0 to 4
   if defsort=left(sort(j),len(defsort)) then sorts=sorts & sort(j): thej=j: exit for
next
for j=0 to 4
   if j<>thej and sort(j) <> "" then sorts=sorts & sort(j)
next
%>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm"><B>Depreciation Date</B>
<TD>
<select name="1,0,0,Depreciation Date,,D2">
<%response.write(dates)%>
</select>

<TR>
<TD CLASS="mm"><B>Totals Only (Y/N)</B>
<TD><input type="Text" name="C2,0,0,Totals Only (Y/N),,YN" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">
</TR>

<TR>
<TD CLASS="mm"><B>Sort order (to allow sub-totals)</B>
<td><select name="C3,0,0,Sort order (to allow sub-totals)">
<%response.write(sorts)%>
</select>
</TR>

<TABLE align="center">
<TR>
<TD colspan=2 align="center" CLASS="mm"><B><%=replace(sentence,chr(8),"""")%></B>
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
<%
if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")   
   cook_id="TA1465"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
'response.write(after)
'response.end
   Set cka_ta31 = Server.CreateObject("cka_ta31.ta31")
   itemlist=cka_ta31.ta1465(session("logentry"), cstr(sentence), cstr(after))
   Set cka_ta31 = nothing
   if left(itemlist,1) = chr(8) then
      response.write("<tr><td alogn=center>" & "Error " & mid(itemlist,2))
   else
      response.write("<TR><TD colspan=2 align=center><A href=""" & itemlist & """>" & itemlist & "</A>")
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

