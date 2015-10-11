<% 
response.expires = 0
response.buffer=true
%>
<HTML>
<HEAD>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
validated = Request.Querystring("validated")
%>
<SCRIPT LANGUAGE="VBSCRIPT" SRC="/prospect/jscript/validate.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript1.2" SRC="/prospect/jscript/clear.js"></SCRIPT>
</HEAD>

<BODY>

<FORM NAME="assetdata">
<input type="hidden" name="before" value="">
<input type="hidden" name="after" value="">
<input type="hidden" name="after_trans" value="">
<input type="hidden" name="validated" value="">
<input type="hidden" name="reportname" value="<%=Request.Querystring("reportname")%>">
<input type="hidden" name="template" value="<%=Request.Querystring("template")%>">
</FORM>

<FORM ACTION="<%=request.servervariables("path_info")%>" METHOD="POST" NAME="assetform">
<%
if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")   
   cook_id="TA2480"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
end if
%>

<%
parameters=Request.cookies("TA2480")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
Dim items
mdb_name = session("the_drive") & "\ckashare\debtors\debtors.mdb"
items = picklin.get_dropdown(session("logentry"), "select distinct batch from inv_batch order by batch", CSTR(mdb_name))
%>

<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE border=1 cellspacing=1 cellpadding=1 align=center>
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm"><B>Batch Number</B>
<select name="1,0,0,Batches">
<%
response.write(items)
%>
</select>

</TABLE>

<TABLE align="center">
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
</TABLE>
<%
if validated = "1" then
'response.write(after)
'response.end
   Set cka_ta31 = Server.CreateObject("cka_ta31.ta31")
   result= cka_ta31.TA2480(session("logentry"), Server.MapPath("\prospect\template\"), CSTR(mdb_name), cstr(after), "I")
   Set cka_ta31 = nothing

   response.write("<table  border=1 cellspacing=1 cellpadding=1 align=center>")
   if left(result,1)=chr(8) then
      dim lines(0)
      lines(0)=mid(result,2)
      startj=0
   else
      lines=split(result,chr(8))
   '   response.write("<TR><TD align=center><B><FONT color=""Crimson""><A href=""" & lines(0) & """>" & lines(0) & "</A></FONT></B>")
      startj=0
   end if
   for j=startj to ubound(lines)
      response.write(lines(j))
   next
   response.write("</table")
   validated = ""
end if
%>

</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
<FORM name=login ><INPUT TYPE=hidden NAME=status VALUE="<%= status%>"></FORM>

</BODY>
</HTML>

