<!--#include file="Inc_timeout_test.asp"-->
<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="<%=Session("content")%>">
<TITLE>Search Prospect</TITLE>
<%
'function window_resize() { object1.style.height = document.body.clientHeight * .75 object1.style.width = document.body.clientWidth * .75 window.status = 'document.body.clientHeight } window.onload = window_resize window.onresize = window_resize

StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
failed_search=Session("FailedSearch")
Session("FailedSearch")=""
language=Session("language")

Dim rname()
Redim rname(0)
 
   srchname = Request.Querystring("sn")
   headingname=Request.Querystring("hn")
   if headingname="" then headingname=srchname
   particular=Request.Querystring("particular")
   srchkey = "1"
   extended=""
'*********************************************************************** dg1/3/02
   If srchname = "General Ledger" and Session("d3needed") <> "yes" Then
   		Set gl_dll=Server.CreateObject("cka_gl.gl")
		temp=gl_dll.gl_searchvariables(Cstr(Session("logentry")))
		Set gl_dll = Nothing
'response.write(temp)
'response.end
		temparr = Split(temp,chr(8))
		levnames = temparr(0)
		levdescs = temparr(1)
		levnums = temparr(2)
		levopts = temparr(3)
		levhds = temparr(4)
		levtds = temparr(5)
		levdms = temparr(6)
		setnames = temparr(7)
		setdescs = temparr(8)
		setnums = temparr(9)
		setopts = temparr(10)
		sethds = temparr(11)
		settds = temparr(12)
		setdms = temparr(13)
'response.write(levopts)
'response.end
   End if
'***********************************************************************

   PhysicalPath=Server.MapPath("/prospect/search/" & srchname & ".txt")
   Set SessionFileObject=Server.CreateObject("Scripting.FileSystemObject")
   filetouse="": database_prefix="": where=""
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
          case "reports": reports=mid(textline,pos+1)
          case database_prefix & "reports": reports=mid(textline,pos+1)
	    case database_prefix & "filetouse": filetouse=replace(mid(textline,pos+1),"@WHERE@",where)
	    case database_prefix & "templatetouse": templatetouse=mid(textline,pos+1)
	    case database_prefix & "srchlist"
			If srchname = "General Ledger" and Session("d3needed") <> "yes" Then
				srchlist = replace(mid(textline,pos+1),"@LEVNAMES@",levnames)
				srchlist = replace(srchlist,"@SETNAMES@",setnames)
			Else
				srchlist=mid(textline,pos+1)
			End If
	    case database_prefix & "numerics"
			If srchname = "General Ledger" and Session("d3needed") <> "yes" Then
				numerics = replace(mid(textline,pos+1),"@LEVNUMS@",levnums)
				numerics = replace(numerics,"@SETNUMS@",setnums)
			Else
				numerics=mid(textline,pos+1)
			End If
	    case database_prefix & "srchkey": srchkey=mid(textline,pos+1)
	    case database_prefix & "labellist"
			If srchname = "General Ledger" and Session("d3needed") <> "yes" Then
				labellist = replace(mid(textline,pos+1),"@LEVDESCS@",levdescs)
				labellist = replace(labellist,"@SETDESCS@",setdescs)
			Else
				labellist=mid(textline,pos+1)
			End If
	    case database_prefix & "itemlist"
			If srchname = "General Ledger" and Session("d3needed") <> "yes" Then
				itemlist = replace(mid(textline,pos+1),"@LEVOPTS@",levopts)
				itemlist = replace(itemlist,"@SETOPTS@",setopts)
			Else
				itemlist=mid(textline,pos+1)
			End If
	    case database_prefix & "sortlist": sortlist=mid(textline,pos+1)
          case database_prefix & "defaultsort"
			If srchname = "General Ledger" and Session("d3needed") <> "yes" Then
				defaultsort = replace(mid(textline,pos+1),"@LEVNAMES@",levnames)
			Else
				defaultsort=mid(textline,pos+1)
			End If
          case database_prefix & "codeattr": codeattr=mid(textline,pos+1)
          case database_prefix & "sorts": sorts=mid(textline,pos+1)
          case database_prefix & "sortdescs": sortdescs=mid(textline,pos+1)
 	    case database_prefix & "radiobtns": radiobtns=mid(textline,pos+1)
	    case database_prefix & "radiocode": radiocode=replace(mid(textline,pos+1),"@WHERE@",where)
	    case database_prefix & "prefix": prefix=mid(textline,pos+1)
	    case database_prefix & "suffix": suffix=mid(textline,pos+1)
          case database_prefix & "hds"
			If srchname = "General Ledger" and Session("d3needed") <> "yes" Then
				hds = replace(mid(textline,pos+1),"@LEVHDS@",levhds)
				hds = replace(hds,"@SETHDS@",sethds)
			Else
		  		hds=mid(textline,pos+1)
			End If
          case database_prefix & "tds"
		  	If srchname = "General Ledger" and Session("d3needed") <> "yes" Then
				tds = replace(mid(textline,pos+1),"@LEVTDS@",levtds)
				tds = replace(tds,"@SETTDS@",settds)
			Else
		  		tds=mid(textline,pos+1)
			End If	  
          case database_prefix & "dms"
			If srchname = "General Ledger" and Session("d3needed") <> "yes" Then
				dms = replace(mid(textline,pos+1),"@LEVDMS@",levdms)
				dms = replace(dms,"@SETDMS@",setdms)
				dms = replace(dms,"@WHERE@",where)
			Else
		  		dms=replace(mid(textline,pos+1),"@WHERE@",where)
			End If
          case database_prefix & "adhoc": adhoc=mid(textline,pos+1)
          case database_prefix & "helpname": helpname=mid(textline,pos+1)
       end select
      LOOP
      SessionTextFile.Close
   end if
'response.write(filetouse)
'response.end
   if filetouse = "" then
      extended=Request.Querystring("fn") 'see extended_database.htm passes fn
      if extended<>"" then
         textline=picklin.sr_make_extended_database(session("database"),cstr(extended),cstr(srchname))
      end if
      crec=split(textline,vbcrlf,-1,vbbinarycompare)
      redim preserve crec(9)
      filetouse= crec(0)

      templatetouse= crec(1)
      srchlist= crec(2)
      srchkey= crec(3)
      labellist= crec(4)
      title= crec(5)
      hds= crec(6)
      tds= crec(7)
      dms= crec(8)
      itemlist= crec(9)
'response.write(filetouse & "=" & extended)
'response.end
   end if
   if filetouse = "" then
	response.write("Sorry, the file " & srchname & " is not in search.asp")
	response.end
   end if
'response.write("helpname = " & helpname & "<BR> srchname = " & srchname)
'response.end
   if helpname="" then helpname=srchname
   PhysicalPath=Server.MapPath("/prospect/help/" & helpname & ".txt")
   Set SessionFileObject=Server.CreateObject("Scripting.FileSystemObject")
   the_help = ""
   if SessionFileObject.FileExists(PhysicalPath) then
      Set SessionTextFile=SessionFileObject.OpenTextFile(PhysicalPath)
      the_help=SessionTextFile.Readall
   end if

   if radiobtns="BANKS" then
      radiobtns = PickLin.make_options(session("logentry"),"BANKS","",cstr(yrtouse),Session("d3needed"),Server.MapPath("\prospect\template\"),"raw")
      varray = split(radiobtns,",")
      radiocode=""
      for k=0 to ubound(varray)
         if radiocode<>"" then
            radiocode=radiocode & ","
         end if
         banks="chq.rec"
         if k<>0 then banks=banks & (k+1)
         radiocode=radiocode & "|" & banks & "|" & templatetouse & "|" & varray(k)
      next
   end if
   if radiobtns="YEARS" then
      values = PickLin.make_options(session("logentry"),"GLYEARS","",cstr(yrtouse),Session("d3needed"),Server.MapPath("\prospect\template\"),"raw")
      varray = split(values,chr(253))
      radiobtns="": radiocode=""
      if Session("d3needed") = "no" then bdesc=filetouse: uscore="_" else bdesc=filetouse: uscore="."
      if values<>"" then
       for k=0 to ubound(varray)
         banks=right(varray(k),2)
         if radiobtns<>"" then
            radiobtns=radiobtns & ","
            radiocode=radiocode & ","
         end if
         radiobtns=radiobtns & varray(k)
         radiocode=radiocode & "|" & bdesc & uscore & banks & "|" & templatetouse & "|" & varray(k) & " " & srchname
       next
       radiobtns=radiobtns & ","
       radiocode=radiocode & ","
      end if
      if radiobtns <> "" then 
         radiobtns=radiobtns & "Current Year"
         radiocode=radiocode & "|" & bdesc & "|" & templatetouse & "|Current Year" & " " & srchname
      end if
   end if

   searcharray = SPLIT(srchlist,",")
   labelarray = SPLIT(labellist,",")
   redim preserve labelarray(ubound(searcharray))
   max = ubound(searcharray)
   for k=0 to max
      useop=searcharray(k)
      if useop<>"" then
         if left(useop,2) = "@@" then
            pos=instr(useop,"|")
            useop=mid(useop,pos+1)
            pos=instr(useop,"|")
            useop=mid(useop,pos+1)
            pos=instr(useop,"|")
            useop=left(useop,pos-1)
         end if
         sdesc=labelarray(k)
         pos=instr(sdesc,"(")
         if pos<>0 then sdesc=left(sdesc,pos-1)
         if instr("," & sorts & ",","," & useop & ",") = 0 then
            if sorts="" then
               sorts=useop
               sortdescs=sdesc
            else
               sorts=sorts & "," & useop
               sortdescs=sortdescs & "," & sdesc
            end if
         end if
      end if
   next

ReportsFound=GetReports(rname)

'//*********************************************************************************************************
Function GetReports(rname)
  cnt=0
  On Error Resume Next

    ReportPath=Server.MapPath("/prospect/reports/")
    if reports="" then reports=templatetouse
    ReportPath=ReportPath & "\" & reports

    set f = SessionFileObject.GetFolder(ReportPath)

    If Err = 0 then
       set fc = f.Files
       for each f1 in fc
          redim preserve rname(cnt)
          rname(cnt)=reports & "/" & f1.name
          cnt=cnt+1
          GetReports=True
       next
    Else
       GetReports=False
    End if
End Function
'//*********************************************************************************************************
%>
<SCRIPT LANGUAGE="JAVASCRIPT">
//*************************************
function checkViewButton(selectbox,button)
 {
  if(selectbox=="")button.disabled=true;
  else button.disabled=false; 
 }
//*********************************
function show_report(report)
  {
   var locationstring,viewer;
   init="actx";
   locationstring="/prospect/reports/" + report + "?init=" + init;
  if(reportwindow==null || reportwindow.closed)
     {
      reportwindow=open(locationstring,"reportwindow");
     }
   else
     {
      reportwindow.location.href=locationstring;
     }
    reportwindow.focus();
}
//**********************************
function getRadioValue(RadioGroup)
 {
  var i = getSelectedButton(RadioGroup)
  return RadioGroup[i].value;
  }
//*****************************************
function getSelectedButton(RadioGroup)
{
	for (var i = 0; i < RadioGroup.length; i++)if (RadioGroup[i].checked)return i;
	return 0;
}
//*****************************************
function checkViewButton(selectbox,button)
 {
  if(selectbox=="")button.disabled=true;
  else button.disabled=false; 
 }
//*************************
</SCRIPT>

<SCRIPT LANGUAGE="VBSCRIPT">
'*********************************************
Sub pop_up
  Set msgform=document.popup
  errmsg=msgform.failed.value
  if errmsg<>"" then
     language=msgform.language.value
     if language = "_mongolia" then
        pop_title = "&#1053;&#1091;&#1091;&#1094;&#1111;&#1075;"
        pop_message = "Nothing found for "
     else
        pop_title = "Search Result"
        pop_message = "Nothing found for "
     end if
     msgbox pop_message & vbCrLf & errmsg,vbInformation,pop_title
     msgform.failed.value=""
  end if
end sub
'*********************************************
Sub setupinputbox
'Select the first input box on the search page (index starts at 0)
on error resume next   
document.forms.item(0).elements(5).select
end sub
'*********************************************
Sub Clear_OnClick
   size=document.searchfrm.Elements.Length-1
   for i = 0 to size
      etype=document.searchfrm.Elements(i).type 
      if etype <> "hidden" and etype <> "button"  and etype <> "radio" then 
         if left(document.searchfrm.Elements(i).name,1) <> "O" then 
            document.searchfrm.Elements(i).value=""
         end if
      end if   
   next
End sub
'********************************************************************************************************
Sub Clear_sort_OnClick
   size=document.searchfrm.Elements.Length-1
   for i = 0 to size
      etype=document.searchfrm.Elements(i).type 
      if etype <> "hidden" and etype <> "button"  and etype <> "radio" then 
         if left(document.searchfrm.Elements(i).name,4) = "sort" then 
            document.searchfrm.Elements(i).value=""
         end if
      end if   
   next
End sub
'********************************************************************************************************
Sub Clear_select_OnClick
   size=document.searchfrm.Elements.Length-1
   for i = 0 to size
      etype=document.searchfrm.Elements(i).type 
      if etype <> "hidden" and etype <> "button"  and etype <> "radio" then 
         if left(document.searchfrm.Elements(i).name,4) = "head" then 
            document.searchfrm.Elements(i).value=""
         end if
      end if   
   next
End sub
'********************************************************************************************************
Sub Clear_search_OnClick
   size=document.searchfrm.Elements.Length-1
   for i = 0 to size
      etype=document.searchfrm.Elements(i).type 
      if etype <> "hidden" and etype <> "button" and etype <> "radio" then 
         if left(document.searchfrm.Elements(i).name,1) <> "O" and left(document.searchfrm.Elements(i).name,4) <> "head" and left(document.searchfrm.Elements(i).name,4) <> "sort" then
            document.searchfrm.Elements(i).value=""
         end if
      end if   
   next
End sub
'********************************************************************************************************
Sub Search_Click(report)
   if report="" then exit sub
   if right(report,4) = ".rpt" then
      call show_report(report)
      exit sub
   else
      if report="adhoc" then report=report & ".asp"
      if report<>"search" then 
         document.searchfrm.reports.value=report
      else
         document.searchfrm.reports.value=""
      end if    
   end if

'Check search terms before submitting. If only a single item id is selected then go straight to bi.asp
      searchkey = document.searchfrm.srchkey.value
      'msgbox "searchkey=" & searchkey & "=" & report
  
	if searchkey <> "none" and document.searchfrm.reports.value="" then 'if want report then single item must go to report
       skeys=split(searchkey,",")
       for k=0 to ubound(skeys)
         elm=skeys(k)
         if not(isnumeric(elm)) then elm = 1
         elm=elm+3 'allow for all clear boxes
         if document.forms.item(0).elements(elm).value = "=" then
            sname = document.forms.item(0).elements(elm+1).value
            if sname <> "" then
	         if instr(sname,"[") = "0" and instr(sname,"]") = "0" and instr(sname,"<") = "0" and instr(sname,">") = "0" then
                  fname=document.searchfrm.fn.value
                  tname=document.searchfrm.tn.value
                  if fname="dict cash" then
                     select case k
                        case 0: tname="cash_deposit": sname="D" & sname & "D"
                        case 1: fname="daily.cash": tname="daily_cash"
                                if isdate(sname) then sname = DateDiff("d", "31/12/67", sname)
                        case 2: fname="cash": tname="cash"
                     end select
                  end if

	           radiolen = document.searchfrm.radiolength.value
                 radiocode = document.searchfrm.radiocode.value

	           'If there are no radio codes or the code is blank (ie Select everything) then don't do anything
	           if radiolen > 0 and len(radiocode) > 0 then
                    radiocode=getRadioValue(document.searchfrm.radio)
                    radlen=len(radiocode)
                    if radlen > 0 then
                      radiocode=right(radiocode,radlen-1)
                      RadioData=split(radiocode,"|")
                      fname = RadioData(0)      
                      tname=RadioData(1)        
                      title=RadioData(2)
                    end if        
                 end if
                 placetogo = "/prospect/asp/bi.asp?fn=" & fname & "&tn=" & tname & "&item=" & sname &  "&sn=" & title  & "&who=searchasp"
                 document.searchfrm.action = placetogo
              end if
		end if
	   end if
	 next
      end if
      usehds=document.searchfrm.hds.value
      hdarr=split(usehds,"|")
      max=ubound(hdarr)
      usehds="": dms=""
      size=document.searchfrm.Elements.Length-1
      redim headnames(size)
      for i = 0 to size
         ename=document.searchfrm.Elements(i).name
         if left(ename,4)="head" then
            sname = document.searchfrm.Elements(i).value
            headnames(mid(ename,5))=sname
         end if
      next
      for i=0 to ubound(headnames)
         if headnames(i)<>"" then
            sname=headnames(i)
            sarray=split(sname,"|")
            redim preserve sarray(2)
            pos=instr(sname,"|")
            if sarray(0)<>"" then
               if usehds<>"" then usehds=usehds & "|": dms=dms & "|": tds=tds & "|"
               usehds=usehds & sarray(0) 'elm
               dms=dms & sarray(1) 'mid(sname,pos+1)
               tds=tds & sarray(2)
             end if
          end if 
      next
      document.searchfrm.usehds.value=usehds
      document.searchfrm.usedms.value=dms
      document.searchfrm.usetds.value=tds 'replace(tds,"<TD>","<TD align=right>")
      searchfrm.submit

End Sub
'********************************************************************************************************
</SCRIPT>
</HEAD>

<BODY  onLoad="pop_up();setupinputbox()"> 

<FORM name=searchfrm method=POST action="/prospect/asp/b.asp">
<TABLE align=center BORDER="1" CELLSPACING="1" CELLPADDING="1">
<TR class=top><TD align=center>
       <a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>
      <TD colspan=5 ALIGN=CENTER>
<!--       <FONT size=+2><B><%=headingname%></B></FONT>-->
         <FONT size=+1><B><%=title%></B></FONT>

<%if language = "_mongolia" then%>
   <TR class=top>    
      <TD> &nbsp;     
      <TD ALIGN=CENTER colspan=2>
        <FONT ><B>Õàéõ øèíæ¿¿ð</B></FONT>
      <TD ALIGN=CENTER>
        <FONT ><B>Ýðýìáýëýõ</B></FONT> 
      <TD ALIGN=CENTER colspan=2>
        <FONT ><B>Òàëáàðóóäûã ¿ç¿¿ë</B></FONT>
   <TR class=top>     
     <TD align=center>
         <INPUT type="button" class="smallButt" name ="Clear" value="Á¿ãäèéã öýâýðëý">
     <TD colspan=2 align=center>
         <INPUT type="button" class="smallButt" name ="Clear_search" value="Õàéëòûã öýâýðëý">
     <TD align=center>
         <INPUT type=button name ="Clear_sort" value="Ýðýìáýëýëòèéã öýâýðëý">
     <TD colspan=2 align=center>
         <INPUT type=button name ="Clear_select" value="Òàëáàðóóäûã öýâýðëý">
<%else%>
   <TR class=top>    
      <TD> &nbsp;     
      <TD ALIGN=CENTER colspan=2>
        <FONT size=+1><B>Search Criteria</B></FONT>
      <TD ALIGN=CENTER>
        <FONT size=+1><B>Sort required</B></FONT> 
      <TD ALIGN=CENTER colspan=2>
        <FONT size=+1><B>Display Fields</B></FONT>
   <TR class=top>     
     <TD align=center>
         <INPUT type="button" class="smallButt" name ="Clear" value="Clear All">
     <TD colspan=2 align=center>
         <INPUT type="button" class="smallButt" name ="Clear_search" value="Clear Searches">
     <TD align=center>
         <INPUT type=button name ="Clear_sort" value="Clear Sorts">
     <TD colspan=2 align=center>
         <INPUT type=button name ="Clear_select" value="Clear Fields">
<%end if

'Next if statements are required so we can choose not to try passing these parameters
   itemarray = SPLIT(itemlist,",")
	
   redim preserve itemarray(max)
   operators="<OPTION VALUE=""="">=<OPTION VALUE=""#"">#<OPTION VALUE=""<"">&lt<OPTION VALUE=""<=""><=<OPTION VALUE="">"">&gt<OPTION VALUE="">="">>="        
   cook_id="search_" & templatetouse & particular
'sorts  
   sortitems="<OPTION VALUE="""">"
   sortarray=split(sorts,",")
   descarray=split(sortdescs,",")
   redim preserve descarray(ubound(sortarray))
   for k=0 to ubound(sortarray)
      useop=sortarray(k)
      if instr(sortitems,"VALUE=""by " & useop & """") = 0 then
         sortitems=sortitems & "<OPTION VALUE=""by " & useop & """>" & descarray(k)
         sortitems=sortitems & "<OPTION VALUE=""by-dsnd " & useop & """>" & "DESC " & descarray(k)
      end if
   next
   numsorts=ubound(sortarray)+1
'displays
   displayitems="<OPTION VALUE="""">"
   hdsarray=split(hds,"|")
   dmsarray=split(dms,"|")
   tdsarray=split(tds,"|")
   redim preserve hdsarray(ubound(dmsarray))
   redim preserve tdsarray(ubound(dmsarray))
   for k=0 to ubound(dmsarray)
      useop=dmsarray(k)
      if instr(displayitems,"VALUE=""" & useop & """") = 0 then
         displayitems=displayitems & "<OPTION VALUE=""" & hdsarray(k) & "|" & useop & "|" & tdsarray(k) & """>" & hdsarray(k)
      end if
   next
   defaulthead=request.cookies(cook_id)("head0") 'if nothing in first cookie - then default to our setup in hds
defaulthead = ""
   response.write("<TR class=top>")
   if max<numsorts then maxuse=numsorts else maxuse=max
   numheads=ubound(hdsarray)
   if numheads > maxuse then
      first=numheads-int(numheads/2)
      if first<maxuse then first=maxuse
   else
      first=maxuse
   end if
   if maxuse<first then maxuse=first
   for j = 0 to maxuse
     normal=1
     if j>max then
        response.write("<td><TD><TD>")
     else
      uselabel = "F" & j
      useop = "O" & j
      if searcharray(j) = "" or left(searcharray(j),1) = "(" then
         response.write("<TD colspan=5><B>" & labelarray(j) & "<INPUT TYPE=hidden NAME=""" & uselabel & """ VALUE=""""> </B><TR class=top>")
      else
         default=request.cookies(cook_id)("O" & j)
         if default="" then default="="
         default="<OPTION VALUE=""" & default & """>" & default
         default = default & replace(operators,default,"")  
         response.write("<TD class=top><B>" & labelarray(j) & "</B><TD width=1><select " & "name=" & useop & ">" & default & "</select><TD width=1>")
         If len(itemarray(j)) = 0 then 'normal input box
            response.write("<INPUT CLASS=smallTxt size=30 NAME=" & uselabel & " wrap=virtual value=""" & request.cookies(cook_id)(uselabel) & """>")
         else
            default=request.cookies(cook_id)(uselabel)
            if left(itemarray(j),7) = "DRCONTS" or itemarray(j)="TRCODES" then
               items = PickLin.make_options(session("logentry"), cstr(left(itemarray(j),7)), cstr(mid(itemarray(j),9)),cstr(default))
            else
               if left(itemarray(j),7) = "<OPTION" then
                  items=itemarray(j)
               else
                  if left(itemarray(j),7) ="sselect" then 'd3 select
                     items = d3.d3_select_str(session("logentry"),cstr(itemarray(j)),1,cstr(default),cstr(extended))
                  else
                     selsent = replace(itemarray(j),"!",",")
                     items = d3.msa_select_str(cstr(where),cstr(selsent),1,cstr(default))
                  end if
               end if
            end if
            response.write("<select name=" & uselabel & ">" & items & "</select>")
         end if
	end if
   end if
'sorts
   if j<numsorts then      
      useop=request.cookies(cook_id)("sort" & j)
      if useop <> "" then
         sname=useop
         for k=0 to ubound(descarray)
            if useop=descarray(k) then sname="by " & sortarray(k): exit for
            if useop="DESC " & descarray(k) then sname="by-dsnd " & sortarray(k): exit for
         next
         uitems="<OPTION VALUE=""" & sname & """>" & useop 
         uitems=uitems & replace(sortitems,uitems,"") 'remove the other occurence of item
      else
         uitems=sortitems
      end if   
      useop="sort" & j
      response.write("<TD width=1><select " & "name=" & useop & ">" & uitems & "</select>")
   else
      response.write("<TD width=1>")
   end if
'display fields
   if j<first then
      for hj=j to j+first step first
        if hj<=numheads then
         useop=request.cookies(cook_id)("head" & hj)
useop = ""
         if useop="" and defaulthead="" then useop=hdsarray(hj) & "|" & dmsarray(hj) & "|" & tdsarray(hj)
         if useop <> "" then
            pos=instr(useop,"|")
            if pos<>0 then sname=left(useop,pos-1) else sname="": useop=""
            uitems="<OPTION VALUE=""" & useop & """>" & sname
            uitems=uitems & replace(displayitems,uitems,"") ' this removes the other occurrence of the item
         else
            uitems=displayitems
         end if  
         response.write("<TD width=1><select name=""head" & cstr(hj) & """>" & uitems & "</select>")
        else
         response.write("<TD width=1>")
        end if
      next
   else
      response.write("<TD width=1><TD width=1>")
   end if
   response.write("<TR class=top>")
next
   
   if len(radiobtns) > 0 then
	radioarray = split(radiobtns,",")
	radiocodearray = split(radiocode,",")
	response.write("<TD colspan=6 ALIGN=center class=top>")
	for k = 0 to ubound(radioarray)
	   if k = ubound(radioarray) then chk="checked" else chk="" 'last button is default
	   response.write("<INPUT TYPE=radio NAME=radio VALUE=" & chr(34) & radiocodearray(k) & chr(34) & chk & ">" & radioarray(k))
	next
   end if
%>
<TR>

<INPUT TYPE=hidden NAME=fn VALUE="<%= filetouse %>">
<INPUT TYPE=hidden NAME=srchitems VALUE="<%= srchlist %>">
<INPUT TYPE=hidden NAME=particular VALUE="<%= particular %>">
<INPUT TYPE=hidden NAME=numerics VALUE="<%= numerics %>">
<INPUT TYPE=hidden NAME=tn VALUE="<%= templatetouse %>">
<INPUT TYPE=hidden NAME=sortlist VALUE="<%= sortlist %>">
<INPUT TYPE=hidden NAME=defaultsort VALUE="<%= defaultsort %>">
<INPUT TYPE=hidden NAME=codeattr VALUE="<%= codeattr %>">
<INPUT TYPE=hidden NAME=sortdescs VALUE="<%= sortdescs %>">
<INPUT TYPE=hidden NAME=sorts VALUE="<%= sorts %>">
<INPUT TYPE=hidden NAME=radiolength VALUE="<%= len(radiocode) %>">
<INPUT TYPE=hidden NAME=radiocode VALUE="<%=radiocode%>">
<INPUT TYPE=hidden NAME=sn VALUE="<%=srchname%>">
<INPUT TYPE=hidden NAME=pre VALUE="<%=prefix%>">
<INPUT TYPE=hidden NAME=suf VALUE="<%=suffix%>">
<INPUT TYPE=hidden NAME=title VALUE="<%=title%>">
<INPUT TYPE=hidden NAME=hds VALUE="<%=hds%>">
<INPUT TYPE=hidden NAME=tds VALUE="<%=tds%>">
<INPUT TYPE=hidden NAME=dms VALUE="<%=dms%>">
<INPUT TYPE=hidden NAME=hn VALUE="<%=headingname%>">
<INPUT TYPE=hidden NAME=srchkey VALUE="<%= srchkey %>">
<INPUT TYPE=hidden NAME=usehds VALUE="">
<INPUT TYPE=hidden NAME=usedms VALUE="">
<INPUT TYPE=hidden NAME=usetds VALUE="">
<INPUT TYPE=hidden NAME=reports VALUE="">
<INPUT TYPE=hidden NAME=adhoc VALUE="<%= adhoc %>">



<%if particular<>"" then%>
</TABLE>
<%excelname=request.cookies(cook_id)("excelname")%>
<P ALIGN=CENTER>Enter name of Excel Workbook &nbsp;<INPUT TYPE=text NAME=excelname VALUE="<%=excel_name%>">
<P ALIGN=CENTER><INPUT ALIGN=CENTER TYPE=button name="search" value="<%=mid(particular,3)%>" OnClick='search_click("search")'>

<%else%>
<TR class=top>
<%if language = "_mongolia" then%>
   <TD colspan=4><FONT size=+2 ><B> Ìýäýýëýõ </B></FONT>
<%else%>
   <TD colspan=4><FONT size=+2 ><B>Reports</B></FONT>
<%end if%>

<%if reportsfound then%>
        <SELECT NAME=reportbox Onchange='checkViewButton(this.value,document.all.View)'><OPTION VALUE="">
       <%for cnt=0 to Ubound(rname)%>
          <OPTION VALUE="<%=rname(cnt)%>">
<%
nme=mid(rname(cnt),instr(rname(cnt),"/")+1)
pos = instr(nme,".") 
if pos then nme=left(nme,pos-1)
response.write(left(nme,30))
next%>
       </SELECT>
       <INPUT TYPE="Button" NAME="View" Disabled CLASS=smallButt VALUE="View" OnClick='search_click(document.all.reportbox.value)'>
<%end if%> 
<%if language = "_mongolia" then%>
   <INPUT TYPE="Button" NAME="adhoc" CLASS=smallButt VALUE="Adhoc reporting" OnClick='search_click("adhoc")'>
   <TD ALIGN=center colspan=2><INPUT TYPE="button" class=smallButt name="Search" value="Õàé" OnClick='search_click("search")'>
<%else%>
   <INPUT TYPE="Button" NAME="adhoc" CLASS=smallButt VALUE="Adhoc reporting" OnClick='search_click("adhoc")'>
   <TD ALIGN=center colspan=2><INPUT TYPE="button" class=smallButt name="Search" value="Search" OnClick='search_click("search")'>
<%end if%>

</TABLE>
<%end if%>

<P ALIGN=CENTER><%response.write(replace(the_help,vbcrlf,"<BR>"))%>
<INPUT type=hidden NAME=page_size VALUE="20">
</form>
<FORM name=popup>
<INPUT TYPE=hidden NAME=failed VALUE="<%=failed_search%>">
<INPUT TYPE=hidden NAME=language VALUE="<%=language%>">
</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
  
</BODY>
</HTML>