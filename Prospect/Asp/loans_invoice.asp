<% 
response.expires = 0 
response.buffer=true
%>
<HTML>
<HEAD>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
validated = Request.Querystring("validated")
%>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/menu.js"></SCRIPT>
<SCRIPT LANGUAGE="VBScript" SRC="/prospect/jscript/sliders.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/navbar.js"></SCRIPT>
<SCRIPT LANGUAGE="VBSCRIPT" SRC="/prospect/jscript/validate.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript1.2" SRC="/prospect/jscript/clear.js"></SCRIPT>
<SCRIPT LANGUAGE="VBSCRIPT">

Sub setupinputbox
'Select the input box on the item page 
	document.forms.itemid.item.select
end sub

</SCRIPT>
</HEAD>

<%
if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")   
   cook_id="loansinvoice"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
   Set cka_loans=Server.CreateObject("cka_loans.loans")
   result = cka_loans.ta_loans_invoice(session("logentry"),cstr(sentence),cstr(after))
   Set cka_loans = Nothing
   if left(result,1)=chr(8) then
      response.write("<TR><TD colspan=2 align=center><B>" & mid(result,2) & "</B>")
   else
      batchnum=result
      srchname="debtor invoices"
      PhysicalPath=Server.MapPath("/prospect/search/" & srchname & ".txt")
      Set SessionFileObject=Server.CreateObject("Scripting.FileSystemObject")
      if SessionFileObject.FileExists(PhysicalPath) then
         Set SessionTextFile=SessionFileObject.OpenTextFile(PhysicalPath)
         DO WHILE NOT SessionTextFile.AtEndofstream
          textline=SessionTextFile.ReadLine
          pos=instr(textline,"=")
          if pos<> 0  then temp=left(textline,pos-1) else temp=""
          select case temp
             case "title": title=mid(textline,pos+1)
             case "hds": hds=mid(textline,pos+1)
             case "tds": tds=mid(textline,pos+1)
             case "dms": dms=mid(textline,pos+1)
             case "adhoc": adhoc=mid(textline,pos+1)
             case "reports": reports=mid(textline,pos+1)
          end select
         LOOP
         SessionTextFile.Close
      end if
      dms=replace(dms,"fn=invoice","fn=inv.batch")
      itemlist = Picklin.making_html(Server.MapPath("\prospect\template\"),session("logentry"),"INV.BATCH", "SSELECT INV.BATCH WITH BATCH = """ & batchnum & """","invoice", "1", "200", "0", "","",0,"",cstr(title),cstr(hds),cstr(tds),cstr(dms)) ' the 20 is the page size wanted
      response.write(itemlist)
      response.end
   '   response.write("<TR><TD colspan=2 align=center><B>" & result & "</B>")
   end if
   validated = ""
else
   response.write("<BODY>")
end if
%>

<FORM NAME="assetdata">
<input type="hidden" name="before" value="">
<input type="hidden" name="after" value="">
<input type="hidden" name="validated" value="">
<input type="hidden" name="sentence" value="<%=Request.Querystring("sentence")%>">
<input type="hidden" name="reportname" value="<%=Request.Querystring("reportname")%>">
<input type="hidden" name="template" value="<%=Request.Querystring("template")%>">
</FORM>

<FORM ACTION="<%=request.servervariables("path_info")%>" METHOD="POST" NAME="assetform">

<%
parameters=Request.cookies("loansinvoice")("parms")
parms=split(parameters,chr(254))
redim preserve parms(10)
%>
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
       
<TH colspan=2>Raise and Report Invoices for Loans Repayments

<TR>
<TD CLASS="mm"><B>Invoice all Loan payments due before (Inclusive)</B>
<TD><input type="Text" name="C1,0,0,Invoice all Loan payments due before (Inclusive),,D2" value="<%=parms(0)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Invoices to be ledger dated</B>
<TD><input type="Text" name="C2,0,0,Invoices to be ledger dated,,D2" value="<%=parms(1)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Batch number for invoices</B>
<TD><input type="Text" name="C3,0,0,Batch number for invoices" value="<%=parms(2)%>" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Record invoices for printing (Y/N)?</B>
<TD><input type="Text" name="C4,0,0,Record invoices for printing (Y/N)?,,YN" value="<%=parms(3)%>" align="LEFT" size="10" maxlength="10">

</TABLE>

<TABLE align="center">
<TR>
<TD colspan=2 align="center" CLASS="mm"><B><%=Request.Querystring("sentence")%></B>
<TR>
<TD CLASS="tdempty" align="CENTER">
    <OBJECT ID="Report"
     CLASSID="CLSID:D7053240-CE69-11CD-A777-00DD01143C57" >
        <PARAM NAME="ForeColor" VALUE="60">
        <PARAM NAME="BackColor" VALUE="9221330">
        <PARAM NAME="Caption" VALUE="Report">
        <PARAM NAME="Size" VALUE="1400;700">
        <PARAM NAME="FontName" VALUE="Arial">
        <PARAM NAME="FontEffects" VALUE="1073741825">
        <PARAM NAME="FontHeight" VALUE="180">
        <PARAM NAME="FontCharSet" VALUE="0">
        <PARAM NAME="FontPitchAndFamily" VALUE="2">
        <PARAM NAME="ParagraphAlign" VALUE="3">
        <PARAM NAME="FontWeight" VALUE="700">
    </OBJECT>
<TD CLASS="tdempty" align="CENTER">
     <OBJECT ID="Clear"
     CLASSID="CLSID:D7053240-CE69-11CD-A777-00DD01143C57" >
        <PARAM NAME="ForeColor" VALUE="60">
        <PARAM NAME="BackColor" VALUE="9221330">
        <PARAM NAME="Caption" VALUE="Clear">
        <PARAM NAME="Size" VALUE="1400;700">
        <PARAM NAME="FontName" VALUE="Arial">
        <PARAM NAME="FontEffects" VALUE="1073741825">
        <PARAM NAME="FontHeight" VALUE="180">
        <PARAM NAME="FontCharSet" VALUE="0">
        <PARAM NAME="FontPitchAndFamily" VALUE="2">
        <PARAM NAME="ParagraphAlign" VALUE="3">
        <PARAM NAME="FontWeight" VALUE="700">
    </OBJECT>
</TABLE>

</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
<FORM name=login ><INPUT TYPE=hidden NAME=status VALUE="<%= status%>"></FORM>
</BODY>
</HTML>

