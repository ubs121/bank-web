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
sentence = Request.Querystring("sentence")
sentence=replace(sentence,"""",chr(8))
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
parameters=Request.cookies("TA194")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
%>

<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm"><B>Pay all transactions due by date</B>
<TD><input type="Text" name="C1,0,0,Pay all transactions due by date,,D2" value="<%=parms(0)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Enter date to which discount may be applied</B>
<TD><input type="Text" name="2,0,0,Enter date to which discount may be applied,,D2" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Pay only transactions with settlement discount ? (Y/N)</B>
<TD><input type="Text" name="C3,0,0,Pay only transactions with settlement discount (Y/N),,YN" value="<%=parms(2)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Draw cheques for amounts up to</B>
<TD><input type="Text" name="4,0,0,Draw cheques for amounts up to,,MD2" value="<%=parms(3)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Draw cheques for amounts greater than</B>
<TD><input type="Text" name="5,0,0,Draw cheques for amounts greater than,,MD2,<A4" value="<%=parms(4)%>" align="LEFT" size="10" maxlength="10">

<%
values = PickLin.readstr(session("database"),"DICT TRANS.J", "TRANS.INFO","34")
values_array = split(values,chr(253))
if ubound(values_array) < 5 then redim preserve values_array(5)
%>
<TR>
<TD CLASS="mm"><B>Ledger date for cheques</B>
<TD><input type="Text" name="C6,0,0,Ledger date for cheques,,D2,<%response.write(values_array(4) & "," & values_array(5))%>" value="<%=parms(5)%>" align="LEFT" size="10" maxlength="10">


<TR>
<TD CLASS="mm"><B>Do you want to print ledger numbers on report (Y/N)?</B>
<TD><input type="Text" name="C7,0,0,Do you want to print ledger numbers on report (Y/N),,YN" value="<%=parms(6)%>" align="LEFT" size="10" maxlength="10">

<%
values = PickLin.readstr("DICT TRANS.J", "TRANS.INFO","49")
values=mid(values,4,1)
if values="1" then
%>
<TR>
<TD CLASS="mm"><B>Starting date for transactions (no date for ALL)</B>
<TD><input type="Text" name="8,0,0,Starting date for transactions,,D2,A1" value="<%=parms(7)%>" align="LEFT" size="10" maxlength="10">
<%
end if
%>
</TABLE>

<TABLE align="center">
<TR class=top><TH colspan=2 align=center><B><%=replace(sentence,chr(8),"""")%></B>
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
<%
if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")   
   cook_id="TA194"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
'response.write(Request.Querystring("sentence"))
'response.end
   Set cka_ta31 = Server.CreateObject("cka_ta31.ta31")
   itemlist=cka_ta31.TA194(session("logentry"), cstr(sentence),cstr(after))
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

