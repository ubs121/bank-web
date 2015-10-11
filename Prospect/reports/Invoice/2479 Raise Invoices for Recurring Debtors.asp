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
   cook_id="TA2479"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
end if
%>

<%
parameters=Request.cookies("TA2479")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
%>

<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD class=top><B>Invoice amounts billed to before OR upto (including)</B>
<TD class=top><input type="Text" name="C1,0,0,Invoice amounts billed to before OR upto (including),,D2X" value="<%=parms(0)%>">

<TR>
<TD class=top><B>Date for Invoices</B>
<TD class=top><input type="Text" name="C2,0,0,Date for Invoices,,D2X" value="<%=parms(1)%>">

<TR>
<TD class=top><B>General Ledger Date for Invoices</B>
<TD class=top><input type="Text" name="C3,0,0,General Ledger Date for Invoices,,D2X" value="<%=parms(2)%>">

<TR>
<TD class=top><B>Batch Number</B>
<TD class=top><input type="Text" name="C4,0,0,Batch Number" value="<%=parms(3)%>" maxlength="26">

<TR>
<TD class=top><B>Record Invoice Numbers for Printing</B>
<TD class=top><input type="Text" name="C5,0,0,Record Invoice Numbers for Printing,,YN" value="<%=parms(4)%>">

</TABLE>

<TABLE align="center">
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
</TABLE>
<%
if validated = "1" then
'response.write(after)
'response.end
   Set cka_ta31 = Server.CreateObject("cka_ta31.ta31")
   result= cka_ta31.TA2479(session("logentry"), Server.MapPath("\prospect\template\"), cstr(after))
   Set cka_ta31 = nothing

   response.write("<table align=center>")
   if left(result,1)=chr(8) then
      dim lines(0)
      lines(0)=mid(result,2)
      startj=0
   else
      lines=split(result,chr(8))
      response.write("<TR><TD align=center><B><FONT color=""Crimson""><A href=""" & lines(0) & """>" & lines(0) & "</A></FONT></B>")
      startj=1
   end if
   for j=startj to ubound(lines)
      response.write("<TR><TD align=center><B><FONT color=""Crimson"">" & lines(j) & "</FONT></B>")
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

