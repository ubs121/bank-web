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
parameters=Request.cookies("TA3157")("parms")
parms=split(parameters,chr(8))
redim preserve parms(2)
%>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm"><B>Reporting LGA (eg 0805)</B>
<TD><input type="Text" name="C1,0,0,Report LGA" value="<%=parms(0)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Approval Period (YYMM eg 9906)</B>
<TD><input type="Text" name="C2,0,0,App Period" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

</TABLE>

<TABLE align="center">
<TR>
<TD colspan=2 align="center" CLASS="mm"><B><%=replace(sentence,chr(8),"""")%></B>
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
<%
if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")   
   cook_id="TA3157"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
   Set cka_ta31 = Server.CreateObject("cka_ta31.ta31")
   itemlist=cka_ta31.TA3157(Server.MapPath("\prospect\template\"),session("logentry"), cstr(before),cstr(sentence))
   Set cka_ta31 = nothing
   if left(itemlist,1) = chr(8) then
      response.write("<tr><td alogn=center>" & "Error " & mid(itemlist,2))
   else
      temp=split(itemlist,chr(8))
      response.write("<TR><TD colspan=2 align=center>" & temp(1) & " items. Click on file name to see file")
      response.write("<TR><TD colspan=2 align=center><A href=""" & temp(0) & """>" & temp(0) & "</A>")
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

