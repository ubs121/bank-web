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
sentence=Request.Querystring("sentence")
sentence=replace(sentence,"""",chr(254))
%>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/menu.js"></SCRIPT>
<SCRIPT LANGUAGE="VBScript" SRC="/prospect/jscript/sliders.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/navbar.js"></SCRIPT>
<SCRIPT LANGUAGE="VBSCRIPT" SRC="/prospect/jscript/validate.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript1.2" SRC="/prospect/jscript/clear.js"></SCRIPT>
</HEAD>

<%
if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")
   'sentence = request.querystring("sentence")  
   cook_id="ta696"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
   Set cka_loans=Server.CreateObject("cka_loans.loans")
   result = cka_loans.ta696(session("logentry"),cstr(sentence),cstr(after))
   Set cka_loans=Nothing
   if left(result,1)=chr(8) then
      response.write("<TR><TD colspan=2 align=center><B>" & mid(result,2) & "</B>")
   else
      batchnum="test1"
      response.write("<TR><TD colspan=2 align=center><B>" & result & "</B>")
   end if
   validated = ""
else
   response.write("<BODY>")
end if
%>

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
parameters=Request.cookies("ta696")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
%>
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
       
<TH colspan=2>Loans Repayments Statements

<TR>
<TD CLASS="mm"><B>Has the ageing been done? (Y/N)</B>
<TD><input type="Text" name="C1,0,0,Has the ageing been done? (Y/N),,YN" value="<%=parms(0)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Statement month ending date</B>
<TD><input type="Text" name="C2,0,0,Statement month ending date,,D2" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Date to which receipts are on file</B>
<TD><input type="Text" name="C3,0,0,Date to which receipts are on file,,D2" value="<%=parms(2)%>" align="LEFT" size="10" maxlength="10">

</TABLE>

<TABLE align="center">
<TR>
<TD colspan=2 align="center" CLASS="mm"><B><%=replace(sentence,chr(254),"""")%></B>
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
</TABLE>

</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
<FORM name=login ><INPUT TYPE=hidden NAME=status VALUE="<%= status%>"></FORM>

</BODY>
</HTML>

