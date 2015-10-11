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
   crec=split("DATES" & chr(8) & controlrec,chr(8))
   'response.write(crec(2))
   writeerror = d3.d3_writestr(Cstr(session("database")),session("the_drive") & "ckashare\debtors\debtors.mdb\control_debtor", "DATES",cstr(controlrec),chr(8))
   If writeerror <> "0" Then
      result = "Write to control_debtor item DATES failed" & writeerror
   Else
      result = "Updated"
   end if
   before = Request.Querystring("before")   
   validated = ""
end if
ok = d3.d3_readmat_var(session("database"), session("the_drive") & "ckashare\debtors\debtors.mdb\control_debtor", "DATES", crec)
result=""
if ubound(crec) < 3 then redim preserve crec(3)
%>

<input type="hidden" name="id" value="">
<TABLE align=center border="1" cellspacing="1" cellpadding="1">
<TR class=top>
<TD WIDTH="5%">
        <A href="/prospect/asp/menu.asp"><IMG SRC="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="30" HEIGHT="22" ALT="Prospect Explorer"></A>
<TD><B>Debtor Parameters (item DATES in CONTROL_DEBTOR table)</B>
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
<TR CLASS=top> 
    <TD><B>Баталгаажсан гїйлгээний огноо(хойш)</B> 
    <TD> <INPUT type="Text" name="2,0,0,Баталгаажсан гїйлгээний огноо(хойш),,D2X" value="<%=crec(2)%>"  size="35"> 
<TR CLASS=top> 
    <TD><B>Баталгаажсан гїйлгээний огноо(хїртэл)</B> 
    <TD> <INPUT type="Text" name="C3,0,0,Баталгаажсан гїйлгээний огноо(хїртэл),,D2X" value="<%=crec(3)%>"  size="35"> 
<%else%>
<TR CLASS=top> 
    <TD><B>Accept transactions dated from</B> 
    <TD> <INPUT type="Text" name="2,0,0,Accept transactions dated from,,D2X" value="<%=crec(2)%>"  size="35"> 
<TR CLASS=top> 
    <TD><B>Accept transactions dated to</B> 
    <TD> <INPUT type="Text" name="C3,0,0,Accept transactions dated to,,D2X" value="<%=crec(3)%>"  size="35"> 
<%
end if
response.write("<TR class=top><TD colspan=2 align=center><B>" & result & "</B>")
%>

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