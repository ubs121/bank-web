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
sentence=Request.Querystring("sentence")
sentence=replace(sentence,"""",chr(254))
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
parameters=Request.cookies("TA1685")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
Set tempobj = Server.CreateObject("cka_ta16.ta16")
temp=tempobj.ta1682_report(session("database"))
logreport=split(temp,chr(254))

rateformats = tempobj.readstr(session("database"),"RATES.CTL", "@RATES.NOTICE.CTL")
temp=split(rateformats,chr(254))
rcs=split(temp(0),chr(253))
rnames=split(temp(1),chr(253))
formats=""
for i=0 to ubound(rcs)
   formats=formats & "<OPTION VALUE=""" & "@RATES.NOTICE.LAYOUT." & rcs(i) & """>" & rnames(i) 
next

ratesrec = tempobj.sr16_cat_str(session("database"))
set tempobj=nothing
rra=split(ratesrec,chr(254))
redim preserve rra(16)
redim rrc(10,16)
for i=0 to 10
   temp=split(rra(i),chr(253))
   redim preserve temp(15)
   for j=1 to 10
      rrc(i,j)=temp(j-1)
   next
next

%>
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=3><%=Request.Querystring("reportname")%>
<TR><TH colspan=3>
<%
for ii=0 to 2
   if logreport(ii)<>"" then
%>
<%=logreport(ii)%><BR>
<%
   end if
next
%>

<TABLE align=centre BORDER=1 CELLSPACING=0 CELLPADDING=0>
<TR CLASS="top">
<TH><font size=-1>No</font>
<TH><font size=-1>Category</font>
<TH><font size=-1>Code</font>
<TH><font size=-1>Discount %</font>
<TH><font size=-1>Penalty %</font>
<TH><font size=-1>Rebatable</font>
<TH><font size=-1>Deferrable</font>
<TH><font size=-1>Pensioner Arrears Penalty</font>
<TH><font size=-1>GST Code</font>
<TH><font size=-1>Special</font>
<%
     dim rateopts()
     redim rateopts(0)
     for k = 1 to ubound(rrc,1)-1
         response.write "<TR>"
         if isnumeric(rrc(10,k)) then special=cint(rrc(10,k)) else special=0
         if ubound(rateopts) < special then redim preserve rateopts(special)
         rateopts(special)=rateopts(special) & "<OPTION VALUE=""" & rrc(1,k) & """>" & rrc(2,k) 
         for kk=1 to 10
            cc=64+k+(kk-1)*13
	      response.write("<TD>" & rrc(kk,k))
         next
      next
%>
</TABLE>

<TR>
<%
if ubound(rateopts) <> 0 then
%>
   <TD CLASS="mm" colspan=2><B>Select from one or other group of Rate Codes (multiple selection allowed)</B>
<%else%>
   <TD CLASS="mm" colspan=2><B>Select Rate Codes (multiple selection allowed)</B>
<%end if%>
<TR>
<%
for special=0 to ubound(rateopts)
%>
<TD class="mm">
<select size=7 multiple type="select-multiple" name="<%=special+1%>,0,0,Rate Code">
<%
response.write(rateopts(special))
next
%>
</select>

<TR>
<TD CLASS="mm"><B>Date of Service of Rate Charges</B>
<TD><input type="Text" name="C5,0,0,Date of Service of Rate Charges,,D2" value="<%=parms(4)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Date payment due by</B>
<TD><input type="Text" name="C6,0,0,Date payment due by,,D2" value="<%=parms(5)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>EXCLUDE current interim DEBITS if dated after (exclusive)<BR>(leave null if none are to be excluded)</B>
<TD><input type="Text" name="7,0,0,EXCLUDE current interim DEBITS if dated after (exclusive),,D2" value="<%=parms(6)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Select rates notice format</B>
<TD>
<select name="sel8">
<%response.write(formats)%>
</select>

</TABLE>

<TABLE align="center">
<TR>
<TD colspan=2 align="center" CLASS="mm"><B><%=Request.Querystring("sentence")%></B>
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
<%
if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")   
   sentence = Request.Querystring("sentence")
   cook_id="TA1685"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
'response.write(after & "=" & sentence)
'response.end
   liverun=1
   Set tempobj = Server.CreateObject("cka_ta16.ta16")
   result = tempobj.TA1685(session("logentry"),"",cint(liverun),0,0,cstr(sentence),cstr(after))
   Set tempobj = nothing
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

