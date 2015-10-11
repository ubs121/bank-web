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
parameters=Request.cookies("TA5430")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
         database=pick.extract(Session("logentry"),2,0,0)
         grps = picklin.readstr(cstr(database), "DICT GEN.L", "XGRP")
         items = "<OPTION VALUE=""" & """>"
         grplist=split(grps,chr(253))
         max =ubound(grplist)
         For Kk = 0 To max
            grp = grplist(kk)
            desc = picklin.readstr(cstr(database), "GEN.L", cstr(grp & ".0"), "2")
            desc=pick.extract(cstr(desc),1,1,1)
            items = items & "<OPTION VALUE=""" & grp & """>" & grp & " " & desc
         Next
%>

<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="90%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm"><B>Groups (multiple selection allowed). <BR>Leave null for entire ledger</B>
<TD>
<select multiple type="select-multiple" name="6,0,0,Groups">
<%
response.write(items)
%>
</select>

<TR>
<TD CLASS="mm"><B>Actuals Commitment or Both ? (A/C/B)</B>
<TD><input type="Text" name="C1,0,0,Actuals Commitment or Both ?,,ACB" value="<%=parms(0)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Exclude Accounts with Zero Balance ? (Y/N)</B>
<TD><input type="Text" name="C2,0,0,Exclude Accounts with Zero Balance (Y/N),,YN" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Start Date for Trial Balance</B>
<TD><input type="Text" name="C3,0,0,Start Date for Trial Balance,,D2" value="<%=parms(2)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Final Date for Trial Balance</B>
<TD><input type="Text" name="C4,0,0,Final Date for Trial Balance,,D2" value="<%=parms(3)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Report Type Included ? (Y/N)</B>
<TD><input type="Text" name="C5,0,0,Report Type Included (Y/N),,YN" value="<%=parms(4)%>" align="LEFT" size="10" maxlength="10">


</TABLE>

<TABLE align=center>
<TR class=top><TH colspan=2 align=center><B><%=replace(sentence,chr(8),"""")%></B>
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
<%
if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")   
   cook_id="TA5430"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
'response.write(after)
'response.end
   Set cka_ta31 = Server.CreateObject("cka_ta31.ta31")
   itemlist=cka_ta31.TA5430(session("logentry"), cstr(after))
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

