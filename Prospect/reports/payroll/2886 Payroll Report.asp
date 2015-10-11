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
<SCRIPT LANGUAGE="JAVASCRIPT1.2" SRC="/prospect/jscript/clear.js"></SCRIPT>
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
parameters=Request.cookies("TA2886")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
items = PickLin.make_options(session("logentry"),"SSELECT", "pp.type by a1|2|pp.type|1")

%>
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm" ><B>Pay type</B>
<TD class="mm">
<select name="1,0,0,Pay type">
<%
response.write(items)
%>
</select>
<TR CLASS="top">
<TH colspan=2><B>Sort Options</B>


<TR>
<TD CLASS="mm"><B>Sort by Name only</B>
<TD><input type="Radio" name="2,0,0,Sort Options" value="N" align="LEFT" size="10" maxlength="10" checked>


<TR CLASS="top">
<TD  CLASS="mm"><B>Sort by cost centre / name</B>
<TD><input type="Radio" name="2,0,0,Sort Options" value="C" align="LEFT" size="10" maxlength="10">


<TR CLASS="top">
<TD  CLASS="mm"><B>Sort by cost centre / location / name </B>
<TD><input type="Radio" name="2,0,0,Sort Options" value="L" align="LEFT" size="10" maxlength="10">

<TR CLASS="top">
<TD  CLASS="mm"><B>Sort by location / name</B>
<TD><input type="Radio" name="2,0,0,Sort Options" value="O" align="LEFT" size="10" maxlength="10">
<TR CLASS="top">
<TH colspan=2>
<B>Report Options</B>

<TR CLASS="top">
<TD  CLASS="mm">
<B>1. Pay Details</B> <BR>
<B>2. Accounts Credited</B><BR>
<B>3. Payments in advance outstanding as of now</B><BR>
<B>4. Cumulative Year-To-Date Adjustments report</B><BR>
<B>5. ALL
<TD valign="bottom"><input type="Radio" name="3,0,0,Report Options" value="ALL" align= "bottom" size="10" maxlength="10" CHECKED>

<TR CLASS="top">
<TH colspan=2><B>Other details</B>

<TR>
<TD CLASS="mm"><B>Do you want year to date for pay details (Y/N)?</B>
<TD><input type="Text" name="4,0,0,>Do you want year to date for pay details (Y/N)?,,YN" value="<%=parms(3)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Do you want summary report only (Y/N)?</B>
<TD><input type="Text" name="5,0,0,>Do you want summary report only (Y/N)?,,YN" value="<%=parms(4)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Pay Date (Enter the last pay date)</B>
<TD><input type="Text" name="6,0,0,Pay Date,,D2X" value="<%=parms(5)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Since what date or leave BLANK for all since start. </B>
<TD><input type="Text" name="7,0,0,Since what date or leave BLANK for all since start.,,D2X" value="<%=parms(6)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B></B>
<TD><input type="hidden" name="8,0,0,OK to continue y/n" value="Y" align="LEFT" size="10" >

<TR>
<TD CLASS="mm"><B>Select one line summary per employee or <BR>full detalis per employee </B>
<TD><input type="radio" name="9,0,0,Select one line summary per employee or full detalis per employee" value="1" align="LEFT" checked>One line <BR>
    <input type="radio" name="9,0,0,Select one line summary per employee or full detalis per employee" value="2" align="LEFT" >Full details

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

