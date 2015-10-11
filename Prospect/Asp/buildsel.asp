<!--#include file="Inc_timeout_test.asp"-->
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")

filetouse = Request.Querystring("fn")
template = Request.Querystring("tn")
title = Request.Querystring("title")
srchitem = Request.Querystring("item")
ref = Request.Querystring("ref")
' this from property.htm as must use sn= so dll will put in correct info
if ref = "" then
   ref = Request.Querystring("sn")
end if
by = Request.Querystring("by")
if by = "" then by="by-dsnd"

Select Case template
  Case "dr_trans"
     SLIDER = "preLoad_slider(0);"
     by="by-exp" & mid(by,3)
     sortby = " " & by & " date "
     code_attr = 2
     filetouse="td.oflow"
     'query = "sselect " & "td.oflow" & " with " & "a0" & " = " & chr(34) & "[*" & cstr(ref) & chr(34) & sortby
     query = "sselect td.oflow with client = " & chr(34) & cstr(ref) & chr(34) & sortby
     title="Debtor transactions" 
  Case "gl_trans"
     SLIDER = "preLoad_slider(0);"
     sortby = " " & by
     code_attr = 1
	 title="General Ledger transactions"
  Case "cr_trans"
     SLIDER = "preLoad_slider(0);"
     sortby = " " & by & " trdate "
     code_attr = 3
     title="Creditor transactions" 
  Case "st_trans"
     SLIDER = "preLoad_slider(0);"
     sortby = " by a10 " & " " & by & " date"   'by branch
     code_attr = 2
     title="Stock transactions" 
  Case "ut_install"
     SLIDER = "preLoad_slider(0);"
     by="by-exp" & mid(by,3)
     sortby = " "
     code_attr = 0
     filetouse="ut.install"
     query = "sselect " & "ut.install" & " with " & "a0" & " = " & chr(34) & cstr(ref) & "*]"  & chr(34) & sortby
     title="ut_install" 
  Case else :
     SLIDER = "preLoad_slider(1);"
     sortby = " by a0 "
     code_attr = 0
End Select

'if title="" then 
'   title=template 'extended database
'   template=filetouse & "_1" 'if only one item on property page for an extended database selection
'end if

'New section to handle exact matches (ie in Infringe for pickup details)
   readpath="/prospect/search/" & title & ".txt"
   title="": hds="": tds="": dms=""
   database_prefix="": where=""
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
          case database_prefix & "numerics": numerics=mid(textline,pos+1)
          case database_prefix & "hds": hds=mid(textline,pos+1)
          case database_prefix & "tds": tds=mid(textline,pos+1)
          case database_prefix & "dms": dms=replace(mid(textline,pos+1),"@WHERE@",where)
          case database_prefix & "helpname": helpname=mid(textline,pos+1)
       end select
      LOOP
      SessionTextFile.Close
   else
      textline=picklin.sr_make_extended_database(session("database"),cstr(filetouse),cstr(template))
      crec=split(textline,vbcrlf,-1,vbbinarycompare)
      redim preserve crec(9)
      filetouse= crec(0)
      template= crec(1)
      if instr(ref,"<BR>")=0 then template=filetouse & "_1" 'only one item so needs individual item template
      title= crec(5)
      hds= crec(6)
      tds= crec(7)
      dms= crec(8)
      if filetouse="" then
         response.write("Sorry, the file " & readpath & " does not exost")
         response.end
      end if
   end if
   
yr = right(filetouse, 2)
if IsNumeric(yr) then
	if title="GENERAL LEDGER TRANSACTIONS" then
		title=title & "-" & yr
		dms=replace(dms,"fn=gl_trans","fn=gl_trans_" & yr)
	end if	
end if		

if len(srchitem) = 0 then
   ref = replace(ref,"<BR>","''") ' changing id1 vm id2 to id1''id2 - <BR> because ckaiis.dll changes vm to this
   query = "sselect " & filetouse & " '" & cstr(ref) & "'" & sortby
else
   if query = "" then 'done dr_trans above using td.oflow
      query = "sselect " & filetouse & " with " & cstr(srchitem) & " = " & chr(34) & cstr(ref) & chr(34) & sortby
   end if
end if
'response.write(query & "=" & CODE_ATTR & "=" & filetouse & "=" & hds)
itemlist = Picklin.making_html(Server.MapPath("\prospect\template\"),Session("logentry"),cstr(filetouse), cstr(query), cstr(template), "1","20",,,,cint(code_attr),cstr(ref),cstr(title),cstr(hds),cstr(tds),cstr(dms),,,,1) ' the 20 is the page size wanted
%>
<HTML>
<HEAD>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/navbar.js"></SCRIPT>
<SCRIPT LANGUAGE="VBSCRIPT">
Sub pop_up
Set  msgform=document.item_status
if msgform.item.value=chr(254) then
	msgbox "Item Not Found"  & vbCrLf & replace(msgform.baditem.value,chr(254),"""") ,vbInformation,"Search Result"
	'window.location.href = ShowPrevSearch 'history.back()
end if
end sub

Sub setupinputbox
'Select the input box on the item page 
	document.forms.itemid.item.select
end sub

</SCRIPT>

<%	
	if itemlist="" then
		scripttag = ""
		'bodytag = "</HEAD><BODY onLoad=" & chr(34) & "pop_up();" & chr(34) & ">" & chr(13)
		bodytag=""
		found=chr(254)
		baditem = replace(query,"""",chr(254))
    	ShowPrevSearch="/prospect/asp/bi.asp?fn=" & filetouse & "&tn=" & template & "&item=" & replace(query,"""",chr(8))
	else
		scripttag = "<SCRIPT LANGUAGE=" & chr(34) & "JavaScript" & chr(34) & " SRC=" & chr(34) & "/prospect/jscript/menu.js" & chr(34) & "></SCRIPT>" & chr(13)
		scripttag = scripttag & "<SCRIPT LANGUAGE=" & chr(34) & "VBScript" & chr(34) & " SRC=" & chr(34) & "/prospect/jscript/sliders.js" & chr(34) & "></SCRIPT>" & chr(13)
		bodytag=""
        ShowPrevSearch="/prospect/asp/bi.asp?fn=" & filetouse & "&tn=" & template & "&item=" & replace(query,"""",chr(8))
            'Response.Redirect ShowPrevSearch
	end if 
	
	response.write(scripttag)
	response.write(bodytag)
      if itemlist="" then
	     Response.Redirect ShowPrevSearch
      else
	   response.write(itemlist)
      end if

%>

<FORM name=item_status>
<INPUT TYPE=hidden NAME=item VALUE="<%= found%>">
<INPUT TYPE=hidden NAME=baditem VALUE="<%= baditem%>">
</FORM>

<FORM name="path"><INPUT TYPE="hidden" NAME="pn" VALUE="<%= PathToUse %>"></FORM>

</BODY>
</HTML>