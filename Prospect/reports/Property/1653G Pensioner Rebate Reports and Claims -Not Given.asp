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

logarray = split(session("logentry"),Chr(254))
dbase = logarray(1)
LastUsed = ""
LastUsed = picklin.readstr(cstr(dbase),"DICT PRS.TXT","@LAST",1,0,0)
LastSent = ""
LastSent = picklin.readstr(cstr(dbase),"DICT PRS.TXT","@LAST",2,0,0)

logarray = split(session("logentry"),Chr(254))
dbase = logarray(1)
Items = ""
Items = picklin.readstr(cstr(dbase),"DICT TRANS.J","TRANS.INFO",59,3,0)
rebatedate = pick.oconv(cstr(items),"d2")
todate = pick.oconv(cstr(items),"d2")


'response.write(items)
'replace(Items,"<","")
'response.write(items)

%>
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
       
<TH colspan=2><%=Request.Querystring("reportname")%>
<TR>
<TH colspan=2>Rebate offered not given and a credit exists
<B><input type="hidden" name="1,0,0,Rebate offered not given and a credit exists" value="G">
</B>
<TR>
<TD CLASS="mm"><B>Rebate offered from what date (inclusive):</B>
<TD><B><input type=text name="C1,0,0,Rebate offered from what date(inclusive):,,D2" value="
<%	response.write(rebatedate)%> " align="LEFT" size="10" maxlength="10">
</B>
<TR>
<input type=hidden name="C4,0,0,OK to continue?" value="Y" checked>


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

