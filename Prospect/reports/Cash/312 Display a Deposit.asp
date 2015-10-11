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
<SCRIPT LANGUAGE="JavaScript1.2" SRC="/prospect/jscript/clear.js"></SCRIPT>
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
parameters=Request.cookies("TA312")("parms")
parms=split(parameters,chr(8))
redim preserve parms(4)
%><a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm"><B>1. Select a particular DEPOSIT. </b>
<TD><input type="radio" name="1,0,0,Option Number" value="1" align="LEFT" size="10" maxlength="10" checked>

<TR>
<TD CLASS="mm"><B>2. All deposits between selected PROCESS dates. </b>
<TD><input type="radio" name="1,0,0,Option Number" value="2" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>3. All deposits between selected GENERAL LEDGER dates. </b>
<TD><input type="radio" name="1,0,0,Option Number" value="3" align="LEFT" size="10" maxlength="10">


<TR>
<TD CLASS="mm"><B>4. All POLICE deposits between given dates. </b>
<TD><input type="radio" name="1,0,0,Option Number" value="4" align="LEFT" size="10" maxlength="10" >
 
<TR>
<TD CLASS="mm"><B>5. All EFT deposits between selected GENERAL LEDGER dates. </b>
<TD><input type="radio" name="1,0,0,Option Number" value="5" align="LEFT" size="10" maxlength="10" >



<TR CLASS="top">
<TH colspan=2>1-5. All Options.

<TR>
<TD CLASS="mm"><B>Enter the Deposit Number for a Particular Deposit <BR> OR Enter the Deposits FROM date for options 2-5</B>
<TD><input type="Text" name="C2,0,0,Deposit Number" value="<%=parms(0)%>" align="LEFT" size="10" maxlength="10">


<TR CLASS="top">
<TH colspan=2>2-5. Enter Date Ranges<BR>

<TR>
<TD CLASS="mm"><B>Deposits TO Date</B>
<TD><input type="Text" name="4,0,0,Deposits TO Date,,D2X" value="<%=parms(2)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Enter EFT code or Blank for All (option 5 only) </B>
<TD><input type="Text" name="5,0,0,Enter EFT code or Blank for All (option 5 only)" value="<%=parms(3)%>" align="LEFT" size="10" maxlength="10">

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

