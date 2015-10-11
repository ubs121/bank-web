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
parameters=Request.cookies("TA1657")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)

logarray = split(session("logentry"),Chr(254))
dbase = logarray(1)
Items = ""
Items = picklin.readstr(cstr(dbase),"DICT TRANS.J","TRANS.INFO",59,3,0)
arrears = pick.oconv(cstr(items),"d2")
YR =  picklin.readstr(cstr(dbase),"DICT TRANS.J","TRANS.INFO",59,1,0)
items = (items + 364)
todate = pick.oconv(cstr(items),"d2")

logarray = split(session("logentry"),Chr(254))
dbase = logarray(1)
LastUsed = ""
LastUsed = picklin.readstr(cstr(dbase),"DICT PRS.DEFER","@LAST",1,0,0)
LastSent = ""
LastSent = picklin.readstr(cstr(dbase),"DICT PRS.DEFER","@LAST",2,0,0)

%>
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
       
<TH colspan=2><%=Request.Querystring("reportname")%>
<TR><TH colspan=2>
This program MUST be run on the 30th June each year, or before any
transactions are allocated to pensioner assessments in the new financial
year.

<TR>
<TD CLASS="mm"><B>Date to which transactions are in arrears</B>
<BR>
<B>Date to which transactions are included</B>

<TD><B>
<%
	response.write(arrears)
%>
<BR>
<%
	response.write(todate)
%>
</B>
<TR>
<TD CLASS="mm">
<B>Dates are controlled by financial year as set in program 1600</B>
<BR>
<B>Are these dates correct?<BR>(Y)es<BR>(N)o</B>
<TD>
&nbsp;
<BR>
&nbsp;
<BR><input type="Radio" name="C1,0,0,Are these dates correct?" value="Y" checked>
<BR><input type="Radio" name="C1,0,0,Are these dates correct?" value="N" >

<TR>
<TD CLASS="mm">
<B>Select Report or Claim option
<BR>(R) Report & Compile Deferred Pensioner Claim
</B>
<BR>
<TD>
&nbsp;
<BR><input type="Radio" name="C2,0,0,Select Report or Compile option" value="R" checked>
<TR>
<TD CLASS="mm"><B>Last Claim sent was</B>
<BR>Last claim used  by the program
<BR>Claim ID for this claim 
<TD class="mm"><B>
<%
	response.write(LastSent)
%>
<BR>
<%
	response.write(LastUsed)
%>
<BR>
<%
	response.write((YR +2000) & "/" &  (YR + 2001))
%>
</B>
<TR>
<TH colspan=2 CLASS="mm"><B>NOTE: If the current claim has the same ID as the last last claim sent it is strongly recommended NOT to continue. </B>
<TR>
<BR><input type=hidden name="C3,0,0,Do you wish to continue?" value="Y" checked>
<TR>
<TD CLASS="mm"><B>If last claim used by the program is the same as the claim ID, 
the Claim has already been compiled. <BR>Do you wish to rebuild this claim? <BR>(Y)es<BR>(N)o</B>
<TD>
&nbsp;
<BR>&nbsp;
<BR><input type="Radio" name="4,0,0,Do you wish to rebuild this claim?" value="Y">
<BR><input type="Radio" name="4,0,0,Do you wish to rebuild this claim?" value="N" >
<TR>
<TD CLASS="mm"><B>Enter the PRS Shire No:</B>
<TD CLASS="mm"><input type="text" name="C5,0,0,Enter the PRS Shire No: value="<%=parms(4)%>" align="LEFT" size="10" maxlength="10">


<TR>
<TD CLASS="mm"><B>Only owners with pensioner numbers? <BR>(Y)es<BR>(N)o</B>
<TD>
&nbsp;
<BR><input type="Radio" name="C6,0,0,Only owners with pensioner numbers?" value="Y" checked>
<BR><input type="Radio" name="C6,0,0,Only owners with pensioner numbers?" value="N" >
<TR>
<input type=hidden name="C7,0,0,OK to continue?" value="Y" checked>


</TABLE>

<TABLE align="center">
<TR>
<TD colspan=2 align="center" CLASS="mm"><B><%=replace(sentence,chr(8),"""")%></B>
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
<%
if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")   
   cook_id="TA1657"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
   result = d3.execute_tcl(session("logentry"),"TA1657",Cstr("PROSPECT" & chr(254) & sentence & chr(254) & after & chr(254) & ""))
   result = "Report Spooled"
   response.write("<TR><TD colspan=2 align=center><B>" & result & "</B>")
   validated = ""
end if
%>
</TABLE>

</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
<FORM name=login ><INPUT TYPE=hidden NAME=status VALUE="<%= status%>"></FORM>

</BODY>
</HTML>

