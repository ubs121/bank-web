<!--#include file="Inc_timeout_test.asp"-->
<%

    searchname=Request.Form("sn")
    filetouse = Request.Form("fn")
    if instr(filetouse,".mdb\") <> 0 or left(filetouse,4) = "sql," then sql=1 else sql=0
    Session("searchasp")="/prospect/asp/search.asp?sn=" & Server.URLencode(searchname) & "&fn=" & filetouse
    session("dd") = "n"
    itemtoget = Request.Querystring("item")
    template = Request.Form("tn")
    excel="0"
    particular=Request.Form("particular")
    if particular<>"" then excel="1"
    excelname=Request.Form("excelname")
    codeattr = Request.Form("codeattr")
    if codeattr="" then codeattr=0
    srchlist = Request.Form("srchitems")
    numerics = Request.Form("numerics")
    sortlist = Request.Form("sortlist")
    sortdescs = Request.Form("sortdescs")
    sorts = Request.Form("sorts")
    prefix = Request.Form("pre")
    suffix = Request.Form("suf")
    title = Request.Form("title")
    page_size = Request.Form("page_size")
    if page_size="" then page_size="20"
    default_hds = Request.Form("hds")
    usehds = Request.Form("usehds")
    usedms = Request.Form("usedms")
    usetds = Request.Form("usetds")
    if usehds<>"" then
       hds=usehds
       dms=usedms
       tds=usetds
    else
       hds=default_hds
	 dms = Request.Form("dms")
       tds = Request.Form("tds")
    end if
%>
<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="<%=Session("content")%>">
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
%>
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
</HEAD>

<%
'Build the query using the srchitems list to get the results of the form
searcharray = SPLIT(srchlist,",")
numarray = split(numerics,",")
redim preserve numarray(ubound(searcharray))

sortby = ""

if prefix <> "" then prearray = SPLIT(prefix,",")
if suffix <> "" then sufarray = SPLIT(suffix,",")

found_a_search = 0: used_where = 0
max = ubound(searcharray)
sortarray = SPLIT(sortlist,",")
redim preserve sortarray(max)
cook_id="search_" & template & particular
for counter = 0 to max

   operator = " = " 'Use "and with" if there is already a query with xxx = xxx

   if itemtoget = "" then 
      if searcharray(counter) <> "" and left(searcharray(counter),1) <> "(" then
         uselabel="F" & counter
         operator = Request.Form("O" & counter)
         response.cookies(cook_id)("O" & counter) = operator
         if sql=1 then
            if operator="#" then operator="<>"
         end if
         operator=" " & operator & " "
         searchterm = Request.Form(cstr(uselabel))
'response.write(uselabel & "=" & searchterm) - here allow for multiple selections?
         response.cookies(cook_id)(uselabel) = searchterm
      end if
   end if

   if len(searchterm) > 0 then 'If there is actually something in the search input field
      found_a_search = 1
      if sortby = "" then 'If sort list specified, sort on first selected field on search page
	     if sortarray(counter) <> "" and sortarray(counter) <> "by-exp" then sortby = " " & sortarray(counter)
      end if
	if prefix <> "" then 'Add prefix and suffix characters passed from search.asp
		if left(searchterm,1) <> "[" then
               searchterm = prearray(counter) & searchterm
		end if
	end if
	if suffix <> "" then
		if right(searchterm,1) <> "]" then
       	   searchterm = searchterm & sufarray(counter)
 		end if
	end if
      if sortarray(counter)="by-exp" then
         uwith = " by-exp "
      else 
         if sql=1 then
            if used_where = 1 then uwith = " " else uwith = " where ": used_where = 1
         else
            uwith=" with "
         end if
      end if
	if len(query) > 0 then
		query = query & " and"
	end if
      quotechar=chr(34)
      if numarray(counter)<>"" then 
         select case numarray(counter)
            case "1": quotechar="": if not isnumeric(searchterm) then searchterm=0
            case "2": quotechar="#": if not isdate(searchterm) then searchterm=date
         end select
      end if
	query = query & uwith & searcharray(counter) & operator & quotechar & searchterm & quotechar
      if sortarray(counter)="by-exp" then exit for '??? cannot do more than one
   end if
next
''''''''''''''''''''''''''''''''''''
'Add code from radio buttons if any - may alter file name
''''''''''''''''''''''''''''''''''''
	radiolen = Request.Form("radiolength")
	radiocode = Request.Form("radio")
	'If there are no radio codes or the code is blank (ie Select everything) then don't do anything
	if radiolen > 0 and len(radiocode) > 0 then
            if left(radiocode,1) = "|" then
            RadioData=split(radiocode,"|")
            filetouse = RadioData(1)      
            templatetouse=RadioData(2)        
            title=RadioData(3)        
            pos=instr(dms,"fn=") 'fn=cr.inv&tn=cr_inv
            if pos<>0 then
               rest=mid(dms,pos+3)
               pos2=instr(rest,"&")
               fn=left(rest,pos2-1)
               dms=left(dms,pos+2) & filetouse & mid(rest,pos2)
               pos=instr(dms,"tn=") 'fn=cr.inv&tn=cr_inv
               rest=mid(dms,pos+3)
               pos2=instr(rest,"&")
               fn=left(rest,pos2-1)
               dms=left(dms,pos+2) & templatetouse & mid(rest,pos2)
            end if
         else
		if len(query) > 0 then
			query = " " & radiocode & " and" & query
		else
			query = " " & radiocode
		end if
         end if
	end if
'''''''''''''''''''''''''''''''
'Now get the list of item id's that match query
'''''''''''''''''''''''''''''''
if found_a_search = 0 then
   if sortarray(0)<>"" then sortby = " " & sortarray(0)
   if left(sortby,4) = " and" then 'must remove the and as no other with clauses
      sortby=mid(sortby,5)
   end if
end if

   pos=instr(sortby,"|")
   if pos then
      filetouse=trim(left(sortby,pos-1)) 'remove first space added to sortby above
      template=mid(sortby,pos+1)
      pos=instr(template,"|")
      sortby=mid(template,pos+1)
      template=left(template,pos-1)
   end if

   sorting=""
   sdarr=split(sortdescs,",")
   sarr=split(sorts,",")
   redim preserve sdarr(ubound(sarr))
   for j=0 to 3 'max number of sorts is 4
      sortterm = Request.Form("sort" & j)
      if sortterm<>"" then sorting=sorting & " " & sortterm
      sd=sortterm
      for k=0 to ubound(sarr)
         if sortterm="by " & sarr(k) then sd=sdarr(k): exit for
         if sortterm="by-dsnd " & sarr(k) then sd="DESC " & sdarr(k): exit for
      next
      response.cookies(cook_id)("sort" & j) = sd
   next
   if sorting="" then sorting=" " & Request.Form("defaultsort")

   sdarr=split(default_hds,"|")
   max=ubound(sdarr)
   sdarr=split(hds,"|")
   dmsarr=split(dms,"|")
   tdsarr=split(tds,"|")
   redim preserve sdarr(max)
   redim preserve dmsarr(max)
   redim preserve tdsarr(max)
   for j=0 to max
      if sdarr(j)<>"" then tmp=sdarr(j) & "|" & dmsarr(j) & "|" & tdsarr(j) else tmp=""
      response.cookies(cook_id)("head" & cstr(j)) = tmp
   next

   response.cookies(cook_id).expires = date + 365
   fullsentence = "sselect " & filetouse & query & sorting & sortby 
'response.write(fullsentence)
'response.end
reportname=Request.Form("reports")
if reportname <> "" then
   pos1 = InStr(1, fullsentence, "@@")
   If pos1 <> 0 Then
      pos2 = InStr(pos1 + 2, fullsentence, "@@")
      indexstr = Mid(fullsentence, pos1, pos2 - pos1)
      indarray = Split(indexstr, "|")
      dictname = indarray(2)
      fullsentence = Left(fullsentence, pos1 - 1) & dictname & Mid(fullsentence, pos2 + 2)
   End If
   if reportname="adhoc.asp" then
      response.redirect "/prospect/asp/adhoc.asp?templatetouse=" & template & "&AdhocIds=" & request.form("adhoc") & "&title=" & title & "&sentence=" & fullsentence & "&hds=" & hds & "&fn=" & filetouse
   else
      pos=instr(reportname,"/")
      reporthead=mid(reportname,pos+1)
      template=left(reportname,pos-1)
      pos=instr(reporthead,".")
      reporthead=left(reporthead,pos-1)
      response.redirect "/prospect/reports/" & reportname & "?sentence=" & fullsentence & "&reportname=" & reporthead & "&template=" & template & "&filetouse=" & filetouse
   end if
else
   fullsentence=replace(fullsentence,chr(254),chr(34)) 'for cash recipting and radio buttons
'response.write(tds & "=" & hds & "=" & template)
'response.end
   'Set picklin = Server.CreateObject("cka_iis.ckaiis")
   itemlist = Picklin.making_html(Server.MapPath("\prospect\template\"),session("logentry"),cstr(filetouse), cstr(fullsentence), cstr(template), "1", cstr(page_size), cstr(excel), "","",cint(codeattr),"",cstr(title),cstr(hds),cstr(tds),cstr(dms),cstr(particular),cstr(excelname))
   'set picklin=nothing
end if
if itemlist="" then
	fullsentence = replace(fullsentence, chr(34),"&quot;")
	Session("FailedSearch")=fullsentence
	Response.Redirect Session("searchasp")
end if 
Session("FailedSearch")=""
response.write(itemlist) 

%>
<FORM name="item_status">
<INPUT TYPE=hidden NAME="item" VALUE="<%= found%>">
<INPUT TYPE=hidden NAME="baditem" VALUE="<%= baditem%>">
</FORM>
<FORM name="path"><INPUT TYPE=hidden NAME="pn" VALUE="<%= PathToUse %>"></FORM>
</BODY>
</HTML>