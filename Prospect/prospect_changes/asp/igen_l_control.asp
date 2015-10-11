<% 
response.expires = 0 
response.buffer=true
%>
<HTML>
<HEAD>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/search.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/RSNav.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/rs.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">RSEnableRemoteScripting("/prospect/java");</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/menu.js"></SCRIPT>
<SCRIPT LANGUAGE="VBScript" SRC="/prospect/jscript/validate.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript1.2" SRC="/prospect/jscript/clear.js"></SCRIPT>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
validated = Request.Querystring("validated")

filetouse = session("the_drive") & "\ckashare\gen_l\gen_l.mdb\reportsets"
ReportSets = PickLin.make_options(session("logentry"),"SSELECT", "reportsets order by [level]|2|" & filetouse & "|1")
%>

</HEAD>

<BODY onLoad="available_width=document.body.clientWidth;available_height=document.body.clientHeight;ReportButtons();ShowError();pop_up();">

<FORM NAME="assetdata">
<input type="hidden" name="before" value="">
<input type="hidden" name="after" value="">
<input type="hidden" name="validated" value="">
<input type="hidden" name="action" value="">
<input type="hidden" name="item" value="">
<input type="hidden" name="file" value="">
<input type="hidden" name="trfile" value="">
<input type="hidden" name="before_trans" value="@@TRANSREC@@">
<input type="hidden" name="after_trans" value="">
<input type="hidden" name="template" value="">
<input type="hidden" name="prefix" value="">
<input type="hidden" name="changed" value="0">
</FORM>

<FORM ACTION="<%=request.servervariables("path_info")%>" METHOD="POST" NAME="assetform">

<%
if validated = "1" then
   controlrec = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   crec=split("YEAR" & chr(8) & controlrec,chr(8))
   writeerror = d3.d3_writestr(Cstr(session("database")),session("the_drive") & "ckashare\gen_l\gen_l.mdb\currentyear", "YEAR",cstr(controlrec),chr(8))
   If writeerror <> "0" Then
      result = "Write to CURRENTYEAR item YEAR failed" & writeerror
   Else
      result = "Updated"
   end if
   before = Request.Querystring("before")   
   validated = ""
else
   ok = d3.d3_readmat_var(session("database"), session("the_drive") & "ckashare\gen_l\gen_l.mdb\CurrentYear", "YEAR", crec)
   result=""
end if
if ubound(crec) < 7 then redim preserve crec(7)
ok = d3.d3_readmat_var(session("database"), session("the_drive") & "ckashare\gen_l\gen_l.mdb\reportsets", cstr(crec(6)), rrec)
if rrec(1)<>"" then
   default="<OPTION VALUE=""" & crec(6) & """>" & rrec(1) & "(" & crec(6) & ")"
else
   default=""
end if
reportsets = default & replace(reportsets,default,"")  
%>

<input type="hidden" name="id" value="">
<TABLE align=center border="1" cellspacing="1" cellpadding="1">
<TR class=top>
<TD WIDTH="5%">
        <A href="/prospect/asp/menu.asp"><IMG SRC="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="30" HEIGHT="22" ALT="Prospect Explorer"></A>
<TD><B>General Ledger Parameters (item YEAR in CURRENTYEAR table)</B>
<TD CLASS="mm" align="CENTER">
<%if Session("language") = "_mongolia" then%>
<input class=bold type="button" name="Update" value="Шинэчил" onclick='Update_Click()'> 
<%else%>
<input class=bold type="button" name="Update" value="Update" onclick='Update_Click()'>
<%end if%>
</TABLE>

<TABLE align=center border="1" cellspacing="3" cellpadding="1">
<TR CLASS=top>
<%if Session("language") = "_mongolia" then%>
   <TD><B>Тухайн жил</B>
    <TD> <INPUT type="Text" name="C1,0,0,Тухайн жил,,MD0" value="<%=crec(1)%>"  size="35"> 
<TR CLASS=top> 
    <TD><B>Баталгаажсан гїйлгээний огноо(хойш)</B> 
    <TD> <INPUT type="Text" name="2,0,0,Баталгаажсан гїйлгээний огноо(хойш),,D2X" value="<%=crec(2)%>"  size="35"> 
<TR CLASS=top> 
    <TD><B>Баталгаажсан гїйлгээний огноо(хїртэл)</B> 
    <TD> <INPUT type="Text" name="C3,0,0,Баталгаажсан гїйлгээний огноо(хїртэл),,D2X" value="<%=crec(3)%>"  size="35"> 
<TR CLASS=top> 
    <TD><B>One-sided journal account number</B> 
    <TD><INPUT type="Text" name="C4,0,0,One-sided journal account number" value="<%=crec(4)%>"  size="35"> 
<TR CLASS=top> 
    <TD><B>Accept posting to closed accounts</B> 
    <TD><INPUT type="Text" name="C5,0,0,Accept posting to closed accounts,,YN" value="<%=crec(5)%>"  size="35"> 
<%else%>
   <TD><B>Current Year</B>
    <TD> <INPUT type="Text" name="C1,0,0,Current Year,,MD0" value="<%=crec(1)%>"  size="35"> 
<TR CLASS=top> 
    <TD><B>Accept transactions dated from</B> 
    <TD> <INPUT type="Text" name="2,0,0,Accept transactions dated from,,D2X" value="<%=crec(2)%>"  size="35"> 
<TR CLASS=top> 
    <TD><B>Accept transactions dated to</B> 
    <TD> <INPUT type="Text" name="C3,0,0,Accept transactions dated to,,D2X" value="<%=crec(3)%>"  size="35"> 
<TR CLASS=top> 
    <TD><B>One-sided journal account number</B> 
    <TD><INPUT type="Text" name="C4,0,0,One-sided journal account number" value="<%=crec(4)%>"  size="35"> 
<TR CLASS=top> 
    <TD><B>Accept posting to closed accounts</B> 
    <TD><INPUT type="Text" name="C5,0,0,Accept posting to closed accounts,,YN" value="<%=crec(5)%>"  size="35"> 
<TR CLASS=top> 
    <TD><B>Report Set used for Fund Accounting (if any)</B> 
<TD>
<select name="6,0,0,Report Set used for Fund Accounting (if any)">
<%
response.write(reportsets)
end if %>

</TABLE>
</FORM>

<FORM NAME="page_details">
  <DIV id="SearchResults" STYLE="position: absolute; left: 10px; top: 40px; width: 790px; z-order: 12; visibility: hidden;">
  </DIV>    
</FORM>

<FORM name=item_status><INPUT TYPE=hidden NAME=item VALUE=""><INPUT TYPE=hidden NAME=baditem VALUE="empty"></FORM>
<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="/prospect/images/default/"></FORM>

<DIV class="sent1" ID="sql" style="visibility:hidden"></DIV>

<DIV ID="ErrLayer" STYLE="position: absolute; left: 15px; top: 40px; width: 790px; z-index: 60; visibility:hidden;">
  <FORM NAME="Error">
   <TABLE>
     <TR><TD><INPUT TYPE=hidden NAME="errMessage" VALUE="noerrors">
   </TABLE>
  </FORM>
</DIV>

</BODY>

</HTML>