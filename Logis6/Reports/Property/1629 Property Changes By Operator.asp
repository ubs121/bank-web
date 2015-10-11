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
validated = Request.Querystring("validated")
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

<FORM NAME="assetdata">
<input type="hidden" name="before" value="">
<input type="hidden" name="after" value="">
<input type="hidden" name="validated" value="">
<input type="hidden" name="sentence" value="<%=Request.Querystring("sentence")%>">
<input type="hidden" name="reportname" value="<%=Request.Querystring("reportname")%>">
<input type="hidden" name="template" value="<%=Request.Querystring("template")%>">
</FORM>

<FORM name=item_status>
<INPUT TYPE=hidden NAME=item VALUE="<%= found%>">
<INPUT TYPE=hidden NAME=baditem VALUE="<%= baditem%>">
</FORM>


<FORM NAME="assetform">

<%
parameters=Request.cookies("TA1629")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
Dim selsent, items
selsent = "sselect ch.batch"
items = PickLin.get_dropdown(session("logentry"),cstr(selsent),"")
itemsnum = PickLin.make_options(session("logentry"),"PRINTERSNUM", "")
%>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm"><B>Operator Name</B>
<select name="C1,0,0,Operators">
<%
response.write(items)
%>
</select>

<TR>
<TD CLASS="mm"><B>Printer</B>
<TD><select name="C2,0,0,Printer"">
<%
response.write(itemsnum)
%>

</TABLE>

<TABLE align="center">
<TR>
<TD colspan=2 align="center" CLASS="mm"><B><%=Request.Querystring("sentence")%></B>
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
<%
if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")   
   cook_id="TA1629"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
'response.write("before = " & before)
'response.end
   Set cka_ta16 = Server.CreateObject("cka_ta16.ta16")
   itemlist=cka_ta16.ta1629(session("logentry"), cstr(before))
   Set cka_ta16 = nothing
   if left(itemlist,1) = chr(8) then
      response.write("<tr><td alogn=center>" & "Error " & mid(itemlist,2))
   else
      response.write("<tr><td alogn=center>" & "Printed " & itemlist)
   end if
   validated = ""
else
   response.write("<BODY>")
end if
%>
</TABLE>

</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
<FORM name=login ><INPUT TYPE=hidden NAME=status VALUE="<%= status%>"></FORM>

</BODY>
</HTML>

