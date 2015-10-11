<!--#include file="Inc_timeout_test.asp"-->
<%
PathToUse =  Session("imagePath")
StyleToUse = Session("userStyle")
session("dd") = "n"

Dim DrillDown,SingleItem,Action
Action="\prospect\asp\next_page.asp"

DrillDown=True
'*******

filetouse = Request.Querystring("fn")
template =  Request.Querystring("tn")
itemtoget = Request.Querystring("item")
baditem=    Request.Querystring("baditem")
found=      Request.Querystring("found")
who       = Request.Querystring("who")
write_result = Request.Querystring("write_result")
glitem=Request.Querystring("glitem")

if found="no" then found =chr(254) else found =itemtoget
if itemtoget ="empty" AND baditem<>"empty" then  found=chr(8)
'*******

if template="gen_l" then
	searchtable=filetouse
	searchtable=replace(searchtable,".","-")
end if
	
if filetouse = chr(8) then 
   filetouse = chr(8) & request.querystring("parameter")
   if request.querystring("parameter2") <> "" then filetouse = filetouse & chr(8) & request.querystring("parameter2")
end if

 if glitem<>"" then
    itemtoget=glitem
    levels=split(itemtoget,".")
    redim preserve levels(2)
    posn = instr(itemtoget,".")
    if instr(filetouse,".mdb\") <> 0 then
       if levels(1) = "" then
          sentence="sselect " & filetouse & " where level1 = " & itemtoget & " and level3 = 0 by level2"
       else
          sentence="sselect " & filetouse & " where level1 = " & levels(0) & " and level2 = " & levels(1) & " by level2,level3"
       end if
    else
       if mid(itemtoget,posn+1) = "0" then
          sentence="sselect " & filetouse & " with group = '" & levels(0) & ".]' and with no subclass by class"
       else
          sentence="sselect " & filetouse & " with group.class = '" & itemtoget & ".]' by sub.class"
       end if
    end if
'response.write(sentence)
'response.end
    DrillCount=2'CLng(PickLin.RSSelectCount(Session("logentry"),cstr(sentence),SingleItem))
    if DrillCount = 0 then DrillDown=False else DrillDown=True
    if levels(2)<>"" then drilldown=false
    if DrillCount= 1 then Action="bi.asp?fn=gen.l&tn=gen_l&glitem=" & SingleItem
    readpath="/prospect/search/general ledger.txt"
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
	    case "database"
             database=mid(textline,pos+1)
             if database<>"" then database_prefix=database & "_"
             if session("d3needed")="yes" then database_prefix=""
          case "where": where=replace(mid(textline,pos+1),"@@PATH@@",session("the_drive"))
          case "title": title=mid(textline,pos+1)
          case database_prefix & "hds": hds=mid(textline,pos+1)
          case database_prefix & "tds": tds=mid(textline,pos+1)
          case database_prefix & "dms": dms=replace(mid(textline,pos+1),"@WHERE@",where)
       end select
      LOOP
      SessionTextFile.Close
    else
     	response.write("Sorry, the file " & readpath & " does not exist")
	response.end
    end if
    dms = replace(dms, "@@PICKFILE@@", filetouse)
 end if

%>

<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="<%=Session("content")%>">
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/menu.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/navbar.js"></SCRIPT>
<% response.write(StyleToUse)%>
 
<SCRIPT LANGUAGE="VBSCRIPT">
Sub pop_up
dim searchtable
Set  msgform=document.item_status
with msgform
   if .item.value=chr(254) then
      msgbox "Item Not Found"  & vbCrLf & replace(.baditem.value,chr(8),"""") ,vbInformation,"Search Result"
   end if
   if .write_result.value<>"" then
      msgbox .write_result.value ,vbInformation,"Add to rates notice list"
   end if
'   if .searchtable.value<>"" then
'   		searchtable=.searchtable.value
'   		document.all("transactions").href=replace(document.all("transactions").href,"fn=gl_trans","fn=" & searchtable)
'   end if
end with
end sub

Sub setupinputbox
'Select the input box on the item page 
	document.forms.itemid.item.select
end sub

</SCRIPT>

</HEAD>
<!--#include file="Inc_home.asp"-->
<%
if who="searchasp" then
   cook_id="search_" & template 
   response.cookies(cook_id)("F0") = itemtoget
end if
If InStr(filetouse, ".mdb\") Then how = 1 Else how = 0
'response.write(filetouse & "=" & itemtoget)
'response.end
result = PickLin.make_html_item(Server.MapPath("\prospect\template\"),Session("logentry"),cstr(how), cstr(filetouse), cstr(itemtoget), cstr(template), "3")
'****************
if left(result,1)=chr(8) then

      if who="searchasp" then
         searchname=Request.Form("sn")
	   Session("FailedSearch")="Item ID: " & itemtoget & vbCrLf & " File: " &  filetouse
         ShowPrevSearch="/prospect/asp/search.asp?popup=NotFound" & "&sn=" & Server.URLencode(searchname)
         Response.Redirect ShowPrevSearch
      end if
	  
	ShowPrevItem = Session("PrevGoodItem") 
      bad_item_details = Server.URLencode("Item ID: " & itemtoget & vbCrLf & " File: " &  filetouse)
      ShowPrevItem=REPLACE(ShowPrevItem,"baditem=empty","baditem=" & bad_item_details)
      ShowPrevItem=REPLACE(ShowPrevItem,"found=yes","found=no")
      Response.Redirect ShowPrevItem
else
	  Session("PrevGoodItem")="/prospect/asp/bi.asp?fn=" & Server.URLencode(filetouse) & "&tn=" & Server.URLencode(template) & "&item=" & Server.URLencode(itemtoget) & "&baditem=empty&found=no"
	  Session("FailedSearch")=""
end if
'**************
response.write(result)
'response.write(Server.MapPath("\prospect\template\") & "==")
%>

<%If glitem <>"" then  %>
<%If DrillDown=False then %>
<%Else%>
  <FORM NAME="GLInfo" ACTION="<%=Action%>" method="POST">
   <INPUT TYPE="Submit" NAME="DrillDown" VALUE="DrillDown">
   <INPUT TYPE=hidden NAME=pickfile VALUE="<%= filetouse%>">
   <INPUT TYPE=hidden NAME=template VALUE="<%=template%>">
   <INPUT TYPE=hidden NAME=sentence VALUE="<%=sentence%>">
   <INPUT TYPE=hidden NAME=title VALUE="<%=title%>">
   <INPUT TYPE=hidden NAME=hds VALUE="<%=hds%>">
   <INPUT TYPE=hidden NAME=tds VALUE="<%=tds%>">
   <INPUT TYPE=hidden NAME=dms VALUE="<%=dms%>">
   <INPUT TYPE=hidden NAME=page_size VALUE="20">
   <INPUT TYPE=hidden NAME=page VALUE="1">
   <INPUT TYPE="hidden" NAME="want_excel" value="0">
   </FORM>
 <%End IF%>
<%End IF%>
<FORM name="item_status">
<INPUT TYPE=hidden NAME=item VALUE="<%= found%>">
<INPUT TYPE=hidden NAME=baditem VALUE="<%= baditem%>">
<INPUT TYPE=hidden NAME=searchtable VALUE="<%= searchtable%>">
<INPUT TYPE=hidden NAME=write_result VALUE="<%= write_result%>">
</FORM>
<FORM name="path"><INPUT TYPE=hidden NAME="pn" VALUE="<%= PathToUse %>"></FORM>
</BODY>
</HTML>