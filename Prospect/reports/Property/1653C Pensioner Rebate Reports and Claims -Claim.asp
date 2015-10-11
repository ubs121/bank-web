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
parameters=Request.cookies("TA1653")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
Dim selsent, items
selsent = "sselect PRS.TXT"
items = PickLin.get_dropdown(session("logentry"),cstr(selsent),"")

%>


<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
       
<TH colspan=2><%=Request.Querystring("reportname")%>
<TR>
<TH colspan=2> Generate DOS diskette for Pensioner Rebate Claim
<input type="hidden" name="C1,0,0,Generate DOS diskette for Pensioner Rebate Claim" value="C">
<TR>
<TD CLASS="mm"><B>Select a Batch Number to process</B>
<TD CLASS="mm"><B><select name="2,0,0,claims">

<%	response.write(items)%> 
<!---
<OPTION name="validation">VALIDATION</OPTION>
<OPTION name="new">NEW</OPTION>
--->

</select>
</B>
<TR>
<TH colspan=2>Select REPORT option for this claim
<TR>
<TD CLASS="mm">REPORT only on items in this claim.<BR>(Note: Claim diskette will not be generated) 
<TD CLASS="mm"><INPUT type="radio" name="3,0,0,Select REPORT or DOS option for this claim" value="REPORT" checked>
<input type="hidden" name="4,0,0,END" value="END">
<input type="hidden" name="4,0,0,END" value="END">
</TABLE>

<TABLE align="center">
<TR>
<TD colspan=2 align="center" CLASS="mm"><B><%=replace(sentence,chr(8),"""")%></B>
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
<%

if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")   
   cook_id="TA1653"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
   result = d3.execute_tcl(session("logentry"),"TA1653",Cstr("PROSPECT" & chr(254) & sentence & chr(254) & after & "END" & "END"))
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

