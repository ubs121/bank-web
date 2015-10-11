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
parameters=Request.cookies("TA182")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
Dim DocPath
DocPath = Server.MapPath("/Prospect_site/Documents")
%>
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
       
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm"><B>Up to Ledger Date (Inclusive)</B>
<TD><input type="Text" name="C1,0,0,Up to Ledger Date (Inclusive),,D2" value="<%=parms(0)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Print Addresses (Y/N)</B>
<TD><input type="Text" name="C2,0,0,Print Addresses (Y/N),,YN" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

</TABLE>

<TABLE align="center">
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
<%
if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")   
   cook_id="TA182"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
   result = d3.execute_tcl(session("logentry"),"TA182",Cstr("PROSPECT" & chr(254) & replace(sentence,chr(8),"""") & chr(254) & after & chr(254) & ""))
   result = GetHoldFile(logentry,result,DocPath)
   response.write("<TR><TD colspan=2 align=center><B>" & result & "</B>")
   validated = ""
end if
'************************************************************************************************************************************
Function GetHoldfile(logentry,result,DocPath)
	Dim HoldPos,HoldNo,Cmd,Reply,DQ
	DQ = Chr(34)
	HoldPos = Instr(result,"Hold Entry # ")
	HoldPos = HoldPos + 13
	HoldNo = ""
	Do While IsNumeric(Mid(result,HoldPos,1))
		HoldNo = Holdno & Mid(result,HoldPos,1)
		HoldPos = HoldPos + 1
	Loop
   	Cmd = "COPY PEQS " & holdno & " (O"
   	Reply = d3.execute_tcl(session("logentry"),Cstr(Cmd),"(PROSPOOL",Cint(0))
   	Reply = picklin.prosprt(session("logentry"),CStr(holdno))
	GetHoldFile = "<a href=" & DQ &  reply & DQ & "target=" & DQ & reply & DQ & "name=" & DQ & "Document File" & DQ & ">Document File:" &  reply & "</a>"
End Function
'***********************************************************************************************************************************
%>
</TABLE>

</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
<FORM name=login ><INPUT TYPE=hidden NAME=status VALUE="<%= status%>"></FORM>

</BODY>
</HTML>

