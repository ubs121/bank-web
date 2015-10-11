<%
response.expires = 0 
response.buffer=true

PathToUse= Session("imagePath")
StyleToUse= Session("userStyle")

filetouse = replace(Request.Querystring("fn"),"@@PATH@@",session("the_drive"))
template =  Request.Querystring("tn")
itemtoget = Request.Querystring("item")
baditem =    Request.Querystring("baditem")
clearscreen =  Request.Querystring("blank")
input_error = Request.Querystring("err")
found=      Request.Querystring("found")
action=      Request.Querystring("action")
sentence=Request.Querystring("sentence")
search=Request.Querystring("search")
printdoc=replace(Request.Querystring("printdoc"),"@@PATH@@",session("the_drive"))
defaulting=Request.Querystring("defaulting")
mergefile=Request.Querystring("merge")
docname=Request.Querystring("docname")
transfile=replace(Request.Querystring("fn1"),"@@PATH@@",session("the_drive"))
no_update_delete=Request.Querystring("no_update_delete")
mainfile=replace(Request.Querystring("mainfile"),"@@PATH@@",session("the_drive"))
subfile=replace(Request.Querystring("subfile"),"@@PATH@@",session("the_drive"))
if action="" then action="4"
found=itemtoget

if clearscreen="yes" then  itemtoget=cstr(chr(8)) : found=chr(8)
If InStr(filetouse, ".mdb\") Then how = 1 Else how = 0  'how=0 on pick, how=1 on msaccess
'response.write(Server.MapPath("\prospect\template\") & "<BR> log:" & Session("logentry") & "<BR>how:" & how & "<BR>filetouse:" & filetouse & "<BR>item:" & itemtoget & "<BR>temp:" & template & "<BR>action:" & action & "<BR>sentence:" & sentence & "<BR>srch:" & search & "<BR>transfile:" & transfile & "<BR>noupdel:" & no_update_delete & "<BR>mainfle:" & mainfile & "<BR>subfle:" & subfile & "<BR>prdoc:" & printdoc & "<BR>mergfle:" & mergefile & "<BR>docname:" & docname & "<BR>default:" & defaulting)
'response.end
result = Picklin.make_html_item(Server.MapPath("\prospect\template\"),Session("logentry"),CStr(how), cstr(filetouse), cstr(itemtoget), cstr(template), cstr(action),cstr(sentence),cstr(search),cstr(transfile),cstr(no_update_delete),cstr(mainfile),cstr(subfile),cstr(printdoc),cstr(mergefile),cstr(docname),cstr(defaulting))

if left(result,1)=chr(8) then 
   result=mid(result,2)
   found="no"
end if  

Session("LastGoodItem")="/prospect/asp/binput.asp?fn=" & Server.URLencode(filetouse) & "&tn=" & Server.URLencode(template) & "&item=" & Server.URLencode(itemtoget) & "&baditem=empty&blank=no&err=noerrors&found=no&search=" & search
%>
<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="<%=Session("content")%>">

<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/Search.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/RSNav.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/rs.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">RSEnableRemoteScripting("/prospect/java");</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/menu.js"></SCRIPT>
<SCRIPT LANGUAGE="VBScript" SRC="/prospect/jscript/validate.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/clear.js"></SCRIPT>

<SCRIPT LANGUAGE="JavaScript">
 layersArray = new Array;
 layersArray[0]="Test";
 layersArray[1]="SearchResults";
 
function show(slayer)
 {
 for(x=0;x<2;x++)
     {
	if(slayer==x)
	    {
		 eval(layersArray[x] + ".style.visibility='visible'");
		 }
      else
     	 eval(layersArray[x] + ".style.visibility='hidden'");
     }  
 }
</SCRIPT>

<%response.write(StyleToUse)%>
</HEAD>

<BODY onLoad="available_width=document.body.clientWidth;available_height=document.body.clientHeight;LoadDropDowns();ShowError();pop_up();show(0)">

<form Name="frmTop"> 
<DIV id="Top" STYLE="position: absolute; left: 10px; top: 10px; width:900px; z-order: 12; visibility: visible">

<%if search="yes" then%>
     <TD> <INPUT TYPE="button" VALUE="Current Item" onClick="show(0);">
<%end if%>

<%if printdoc<>"" then%>
<B>Select WORD document to use for PRINT </b><SELECT NAME="printdocnames">
<% PhysicalPath=printdoc & mergefile
   Set SessionFileObject=Server.CreateObject("Scripting.FileSystemObject")
   if SessionFileObject.FileExists(PhysicalPath) then
      Set SessionTextFile=SessionFileObject.OpenTextFile(PhysicalPath)
      mergetext=SessionTextFile.ReadAll
      SessionTextFile.Close
   end if
   mergetext=replace(mergetext,chr(13) & chr(10),chr(8))

    cnt=0
    set f = SessionFileObject.GetFolder(printdoc)

    docnames=""
    If Err = 0 then
       set fc = f.Files
       for each f1 in fc
          if right(f1.name,4) = ".doc" then
             docnames=docnames & "<OPTION VALUE=" & f1.name & ">" & f1.name
          end if
       next
    End if
    if docname<>"" then docnames="<OPTION VALUE=" & docname & ">" & docname & replace(docnames,"<OPTION VALUE=" & docname & ">" & docname,"")
	docnames = docnames &  "</SELECT>"
  
printnames = "<b>Select Printer</b><SELECT NAME='printernames'>"	   
Set WshNetwork = CreateObject("Wscript.Network")
Set oPrinters = WshNetwork.EnumPrinterConnections
if oPrinters.count > 0 then
	printnames = printnames & "<Option value = " & oPrinters.item(0) & ">" & oPrinters.item(0)
for k=1 to oprinters.count-1
	if oPrinters.item(k) <> oPrinters.item(k-1) then
	   printnames = printnames & "<Option value = " & oPrinters.item(k) & ">" & oPrinters.item(k)
	end if   
next
end if
printnames = printnames &  "</SELECT>"
response.write(docnames & "         " & printnames)
%>
<input class=bold type="button" name="Print" value="Print" onclick='Print_Click("<%=mergetext%>")'>
<%end if%> 

</DIV>
</form>

<%= result%>

<FORM name=item_status><INPUT TYPE=hidden NAME=item VALUE="<%=found%>"><INPUT TYPE=hidden NAME=baditem VALUE="<%=baditem%>"></FORM>
<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%=PathToUse %>"></FORM>

<DIV class="sent1" ID="sql" style="visibility:hidden"></DIV>

<DIV ID="ErrLayer" STYLE="position: absolute; left: 15px; top: 40px; width: 790px; z-index: 60; visibility:hidden;">
  <FORM NAME="Error">
   <TABLE>
     <TR><TD><INPUT TYPE=hidden NAME="errMessage" VALUE="<%=input_error%>">
   </TABLE>
  </FORM>
</DIV>

<INPUT TYPE="Hidden" NAME="CurrentSearchField" VALUE="">

<FORM NAME="page_details">
  <DIV id="SearchResults" STYLE="position: absolute; left: 10px; top: 40px; width: 790px; z-order: 12; visibility:hidden">
  </DIV>
</FORM>

</BODY>
</HTML>
