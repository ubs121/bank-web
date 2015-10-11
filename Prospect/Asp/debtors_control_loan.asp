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
if validated = "1" then
   controlrec = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   writeerror = d3.d3_writestr(Cstr(session("database")),"DICT TRANS.J", "@LOANS",cstr(controlrec))
   If writeerror <> "0" Then
      result = "Write to " & "DICT TRANS.J" & " item " & "@LOANS" & " failed"
   Else
      result = "Updated"
   end if
   before = Request.Querystring("before")   
   validated = ""
else
   controlrec = PickLin.readstr(session("database"),"DICT TRANS.J","@LOANS")
   result=""
end if
crec=split(controlrec,chr(254))
redim preserve crec(5)
glrec0 = PickLin.readstr(session("database"),"GEN.L",cstr(crec(0)),2)
glrec1 = PickLin.readstr(session("database"),"GEN.L",cstr(crec(1)),2)
%>

<DIV id="Test" STYLE="position: absolute; left: 10px; top: 40px; width: 790px; z-order: 2; visibility: visible;">
<input type="hidden" name="id" value="@LOANS">
<TABLE WIDTH="95%" border="1" cellspacing="1" cellpadding="1">
<TR class=item>
<TD WIDTH="5%">
        <A href="/prospect/asp/menu.asp"><IMG SRC="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="30" HEIGHT="22" ALT="Prospect Explorer"></A>
<TD><B>Waste Water Loan Control Parameters (item @LOANS in DICT TRANS.J)</B>
<TD CLASS="mm" align="CENTER">
 	<OBJECT ID="Update" WIDTH=53 HEIGHT=27
 CLASSID="CLSID:D7053240-CE69-11CD-A777-00DD01143C57">
    <PARAM NAME="ForeColor" VALUE="60">
    <PARAM NAME="BackColor" VALUE="9221330">
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

<TR>
   <TD CLASS="mm"><B>G/L Control Account</B>
   <TD><input type="Text" onChange='GetAssessAddress(document.all.principal,this.value)' name="C1,0,0,Principal G/L Asset Account" value="<%=crec(0)%>"  align="LEFT" size="10" maxlength="10"> 
   <I CLASS="input" id=principal><%=glrec0%></I>
<TR>
   <TD CLASS="mm"><B>Interest Income account</B>
   <TD><input type="Text" onChange='GetAssessAddress(document.all.interest,this.value)' name="C2,0,0,Interest Income account" value="<%=crec(1)%>"  align="LEFT" size="10" maxlength="10"> 
   <I CLASS="input" id=interest><%=glrec1%></I>
<%
response.write("<TR><TD colspan=2 align=center><B>" & result & "</B>")
%>

</TABLE>
</FORM>

<SCRIPT LANGUAGE="JavaScript">
function GetAssessAddress(Address,AssessNum)
 {
   ASPpage = RSGetASPObject("DllCalls.asp");
   co = ASPpage.BuildString(AssessNum,"TACCOUNTDESC");
   Address.innerHTML=co.return_value;
}
</SCRIPT>

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