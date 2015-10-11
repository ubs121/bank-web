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
invoice=Request.Querystring("invoice")
%>
<SCRIPT LANGUAGE="VBSCRIPT" SRC="/prospect/jscript/validate.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript1.2" SRC="/prospect/jscript/clear.js"></SCRIPT>
</HEAD>

<BODY>

<FORM NAME="assetdata">
<input type="hidden" name="before" value="">
<input type="hidden" name="after" value="">
<input type="hidden" name="validated" value="">
<input type="hidden" name="reportname" value="<%=Request.Querystring("reportname")%>">
<input type="hidden" name="template" value="<%=Request.Querystring("template")%>">
<input type="hidden" name="invoice" value="<%=Request.Querystring("invoice")%>">
</FORM>

<FORM ACTION="<%=request.servervariables("path_info")%>" METHOD="POST" NAME="assetform">
<%
if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")   
   cook_id="TA293"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
end if
%>
<%
parameters=Request.cookies("TA293")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
items = PickLin.make_options(session("logentry"),"BANKS", "")
ok = d3.d3_readmat_var(session("database"), "DICT TRANS.J", "@CEMTEX", cemtex)
%>

<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<%if invoice <> "1" then%>
<TR>
<TD class=top><B>Bank Account</B>
<TD class=top><select name="1,0,0,Bank Account">

<%
   response.write(items)
end if
%>

<TR>
<TD class=top><B>File Reference</B>
<TD class=top><input type="Text" name="C2,0,0,Tape Reference" value="<%=parms(1)%>">

<TR>
<TD class=top><B>Processing date for bank</B>
<TD class=top><input type="Text" name="C3,0,0,Processing date for bank,,D2" value="<%=parms(2)%>">

<TR>
<TD class=top><B>User name</B>
<TD class=top><input type="Text" name="C4,0,0,User name" value="<%=cemtex(1)%>" maxlength="26">
<TR>
<TD class=top><B>User number</B>
<TD class=top><input type="Text" name="C5,0,0,User number" value="<%=cemtex(2)%>" maxlength="6">
<TR>
<TD class=top><B>BANK-BSB (nnn-nnn)</B>
<TD class=top><input type="Text" name="6,0,0,BANK-BSB (nnn-nnn),,???-???" value="<%=cemtex(3) & "-" & cemtex(4)%>" maxlength="7">
<TR>
<TD class=top><B>Account number</B>
<TD class=top><input type="Text" name="C7,0,0,Account number" value="<%=cemtex(5)%>" maxlength="9">

</TABLE>

<TABLE align="center">
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
</TABLE>
<%
if validated = "1" then
'   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
'   before = Request.Querystring("before")   
'   cook_id="TA293"
'   response.cookies(cook_id)("parms") = before
'   response.cookies(cook_id).expires = date + 365
'response.write(after)
'response.end
   Set cka_ta16 = Server.CreateObject("cka_ta16.ta16")
   result= cka_ta16.sr293(session("logentry"), cstr(after), cstr(invoice))
   Set cka_ta16 = nothing

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

