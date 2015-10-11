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
<input type="hidden" name="item" value="@LOANS">
<input type="hidden" name="file" value="pp.type">
<input type="hidden" name="template" value="ipp_type">
<input type="hidden" name="prefix" value="">
</FORM>

<FORM ACTION="<%=request.servervariables("path_info")%>" METHOD="POST" NAME="assetform">

<%
template_path=Server.MapPath("\prospect\template\")   
the_drive = Left(template_path, InStr(template_path, "\prospect\") - 1) & "\"
if validated = "1" then
   controlrec = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
'response.write(cstr(controlrec))
'response.end 
   'Set d3 = Server.CreateObject("cka_d3.d3")  
   writeerror = d3.d3_writestr(Cstr(session("database")),the_drive & "ckashare\gen_l\gen_l.mdb\currentyear", "YEAR",cstr(controlrec))
   'set d3 = nothing
   If writeerror <> "0" Then
      result = "Write to CURRENTYEAR item YEAR failed" & writeerror
   Else
      result = "Updated"
   end if
   before = Request.Querystring("before")   
   validated = ""
else
   'Set picklin = Server.CreateObject("cka_iis.ckaiis")
   controlrec = PickLin.readstr(session("database"),the_drive & "ckashare\gen_l\gen_l.mdb\currentyear","YEAR")
   'Set picklin = nothing
   result=""
end if
'response.write(controlrec)
'response.end
crec=split(controlrec,chr(254))
redim preserve crec(7)
%>

<DIV id="Test" STYLE="position: absolute; left: 10px; top: 40px; width: 790px; z-order: 2; visibility: visible;">
<input type="hidden" name="id" value="@LOANS">
<TABLE WIDTH="95%" border="1" cellspacing="1" cellpadding="1">
<TR class=top>
<TD WIDTH="5%">
        <A href="/prospect/asp/menu.asp"><IMG SRC="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="30" HEIGHT="22" ALT="Prospect Explorer"></A>
<TD><B>General Ledger Parameters (item YEAR in CURRENTYEAR table)</B>
<TD CLASS="mm" align="CENTER">
 	<OBJECT ID="Update" WIDTH=53 HEIGHT=27
 CLASSID="CLSID:D7053240-CE69-11CD-A777-00DD01143C57">
    <PARAM NAME="Caption" VALUE="Update">
    <PARAM NAME="Size" VALUE="1400;700">
    <PARAM NAME="FontName" VALUE="Arial">
    <PARAM NAME="FontEffects" VALUE="1073750017">
    <PARAM NAME="FontHeight" VALUE="180">
    <PARAM NAME="FontCharSet" VALUE="0">
    <PARAM NAME="FontPitchAndFamily" VALUE="2">
    <PARAM NAME="ParagraphAlign" VALUE="3">
    <PARAM NAME="FontWeight" VALUE="700">
</OBJECT>
</TABLE>

<TABLE WIDTH="95%" border="1" cellspacing="3" cellpadding="1">

<TR CLASS=top>
   <TD><B>Тухайн жил</B>
    <TD> <INPUT type="Text" name="C1,0,0,Current Year,,MD0" value="<%=crec(0)%>"  size="35"> 
<TR CLASS=top> 
    <TD><B>Баталгаажсан гїйлгээний огноо(хойш)</B> 
    <TD> <INPUT type="Text" name="2,0,0,Accept transactions dated from,,D2X" value="<%=day(crec(1)) & " " & monthname(month(crec(1)),true) & " " & year(crec(1))%>"  size="35"> 
<TR CLASS=top> 
    <TD><B>Баталгаажсан гїйлгээний огноо(хїртэл)</B> 
    <TD> <INPUT type="Text" name="C3,0,0,Accept transactions dated to,,D2X" value="<%=day(crec(2)) & " " & monthname(month(crec(2)),true) & " " & year(crec(2))%>"  size="35"> 
<TR CLASS=top> 
    <TD><B>One-sided journal account number</B> 
    <TD><INPUT type="Text" name="C4,0,0,One-sided journal account number" value="<%=crec(3)%>"  size="35"> 
<TR CLASS=top> 
    <TD><B>Accept posting to closed accounts</B> 
    <TD><INPUT type="Text" name="C5,0,0,Accept posting to closed accounts,,YN" value="<%=crec(4)%>"  size="35"> 

<%
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