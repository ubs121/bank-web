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
   cook_id="TA2401"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365
   
   batchnum=before
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
   validated = ""
else
   response.write("<BODY>")
end if
%>

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
parameters=Request.cookies("TA2401")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
Dim selsent, items
selsent = "qselect dict inv.batch @batches (2"
items = PickLin.get_dropdown(session("logentry"),cstr(selsent),"")

%>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm"><B>Batch Number</B>
<select name="1,0,0,Batches">
<%
response.write(items)
%>
</select>


</TABLE>

<TABLE align="center">
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
</TABLE>

</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
<FORM name=login ><INPUT TYPE=hidden NAME=status VALUE="<%= status%>"></FORM>

</BODY>
</HTML>

