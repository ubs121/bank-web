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

<FORM ACTION="/prospect/asp/reporting.asp?mysent=<%=sentence%>" METHOD="POST" NAME="assetdata">
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
parameters=Request.cookies("TA692")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
%>

<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm"><B>Aged Balances Summary (Y/N)</B>
<TD><input type="Text" name="C1,0,0,Aged Balances Summary (Y/N),,YN" value="<%=parms(0)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Print Transactions (Y/N)</B>
<TD><input type="Text" name="C2,0,0,Print Transactions (Y/N),,YN" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>To Date</B>
<TD><input type="Text" name="3,0,0,To Date,,D2X" value="<%=parms(2)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>From Date</B>
<TD><input type="Text" name="4,0,0,From Date,,D2X" value="<%=parms(3)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Transactions with Reference Similar to</B>
<TD><input type="Text" name="5,0,0,Transactions with Reference Similar to" value="<%=parms(4)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Print All Transaction Narratives (Y/N)?</B>
<TD><input type="Text" name="C6,0,0,Print All Transaction Narratives (Y/N),,YN" value="<%=parms(5)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Print All Transaction Posting Detail (Y/N)?</B>
<TD><input type="Text" name="C7,0,0,Print All Transaction Posting Detail,,YN" value="<%=parms(6)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Print Paid Transactions (Y/N)?</B>
<TD><input type="Text" name="C8,0,0,Print Paid Transactions,,YN" value="<%=parms(7)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Details of Pre Allocated Receipts (Y/N)?</B>
<TD><input type="Text" name="C9,0,0,Details of Pre Allocated Receipts,,YN" value="<%=parms(8)%>" align="LEFT" size="10" maxlength="10">

</TABLE>

<TABLE align="center">
<TR>
<TH colspan=2 align="center" CLASS="mm"><B><%=replace(sentence,chr(8),"""")%></B>
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
<%
if result <> "" then
   response.write("<TR><TD colspan=2 align=center><B>" & result & "</B>")
end if
%>
</TABLE>

</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
<FORM name=login ><INPUT TYPE=hidden NAME=status VALUE="<%= status%>"></FORM>

</BODY>
</HTML>

