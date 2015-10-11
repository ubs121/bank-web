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
filetouse=Request.Querystring("filetouse")
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
<input type="hidden" name="filetouse" value="<%=filetouse%>">
<input type="hidden" name="reportname" value="<%=Request.Querystring("reportname")%>">
<input type="hidden" name="template" value="<%=Request.Querystring("template")%>">
</FORM>

<FORM ACTION="<%=request.servervariables("path_info")%>" METHOD="POST" NAME="assetform">
<%
parameters=Request.cookies("TA511")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
posn=instr(filetouse,".mdb")
database=left(filetouse,posn+3) 'leave off last\
filename=mid(filetouse,posn+5)
items=d3.msa_select_str(cstr(database),"select account,description from " & filename & " where account_level = 1 order by level1",1)
%>

<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%
the_year = Right(filename, 2)
If IsNumeric(the_year) Then
   If CInt(the_year) > 80 Then the_year = "19" & the_year Else the_year = "20" & the_year
else
   the_year=" current year"
end if
response.write(Request.Querystring("reportname") & " for " & the_year)
%>

<TR>
<TD CLASS="mm"><B>Groups (multiple selection allowed). <BR>Leave null for entire ledger</B>
<TD CLASS="mm">
<select multiple type="select-multiple" name="6,0,0,Groups">
<%
response.write(items)
%>
</select>

<TR>
<TD CLASS="mm"><B>Actuals Commitment or Both ? (A/C/B)</B>
<TD CLASS="mm"><input type="Text" name="C1,0,0,Actuals Commitment or Both ?,,ACB" value="<%=parms(0)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Exclude Accounts with Zero Balance ? (Y/N)</B>
<TD CLASS="mm"><input type="Text" name="C2,0,0,Exclude Accounts with Zero Balance (Y/N),,YN" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Start Date for Trial Balance</B>
<TD CLASS="mm"><input type="Text" name="C3,0,0,Start Date for Trial Balance,,D2X" value="<%=parms(2)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Final Date for Trial Balance</B>
<TD CLASS="mm"><input type="Text" name="C4,0,0,Final Date for Trial Balance,,D2X" value="<%=parms(3)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Report Type Included ? (Y/N)</B>
<TD CLASS="mm"><input type="Text" name="C5,0,0,Report Type Included (Y/N),,YN" value="<%=parms(4)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Cost Centre Accounts from Start of Year only (Y/N)</B>
<TD CLASS="mm"><input type="Text" name="C7,0,0,Cost Centre Accounts from Start of Year only (Y/N),,YN" value="<%=parms(6)%>" align="LEFT" size="10" maxlength="10">

</TABLE>

<TABLE align="center">
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
<%
if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")   
   cook_id="TA511"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
'response.write(after)
'response.end
   Set cka_gl = Server.CreateObject("cka_gl.gl")
   itemlist=cka_gl.TA511_msa(session("logentry"),cstr(database),cstr(filename),cstr(after))
   Set cka_gl = nothing
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

