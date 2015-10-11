<!--#include file="Inc_timeout_test.asp"-->

<HTML>
<HEAD>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/menu.js"></SCRIPT>
<SCRIPT LANGUAGE="VBScript" SRC="/prospect/jscript/sliders.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/navbar.js"></SCRIPT>

<SCRIPT LANGUAGE="VBSCRIPT">
Sub pop_up
	Set  msgform=document.item_status
	if msgform.item.value=chr(254) then
		msgbox "Item Not Found"  & vbCrLf & msgform.baditem.value ,vbInformation,"Search Result"
	end if
end sub

Sub setupinputbox
'Select the input box on the item page 
	document.forms.itemid.item.select
end sub

</SCRIPT>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
%>
</HEAD>

<%
'Builds a page when passed an access sentence

filetouse = Request.Querystring("fn")
template = Request.Querystring("tn")
query = Request.Querystring("query")

'''''''''''''''''''''''''''''''
'Get the list of item id's that match query
'''''''''''''''''''''''''''''''
   readpath="/prospect/search/parking infringements.txt"
   title="": hds="": tds="": dms=""
   PhysicalPath=Server.MapPath(readpath)
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
       end select
      LOOP
      SessionTextFile.Close
   else
     	response.write("Sorry, the file " & readpath & " does not exost")
	response.end
   end if
   itemlist = Picklin.making_html(Server.MapPath("\prospect\template\"),Session("logentry"),cstr(filetouse), cstr(query), cstr(template), "1","20",,,,,,cstr(title),cstr(hds),cstr(tds),cstr(dms))

if itemlist="" then
	Session("FailedSearch")="sselect " & filetouse & query  & sortby
	Response.Redirect Session("searchasp")
end if 
Session("FailedSearch")=""
if instr(itemlist,"items") = 0 then
   response.write "<a href=""/prospect/asp/menu.asp""><IMG SRC=""/prospect/images/default/explorer/start_up.gif"" BORDER=""0"" WIDTH=""30"" HEIGHT=""22"" ALT=""Prospect Explorer""></a>"
end if
response.write(itemlist)
%>

<FORM name="item_status">
<INPUT TYPE=hidden NAME="item" VALUE="<%= found%>">
<INPUT TYPE=hidden NAME="baditem" VALUE="<%= baditem%>">
</FORM>
<FORM name="path"><INPUT TYPE="hidden" NAME="pn" VALUE="<%= PathToUse %>"></FORM>
</BODY>
</HTML>