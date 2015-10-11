<!--#include file="Inc_timeout_test.asp"-->
<HTML>
<HEAD><TITLE>Search Prospect</TITLE>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
show_empty_box=Request.Querystring("popup")
failed_search=Session("FailedSearch")
Session("FailedSearch")=""

Dim rname()
Redim rname(0)
 
   srchname = Request.Querystring("sn")
   headingname=Request.Querystring("hn")
   if headingname="" then headingname=srchname
   srchkey = "1"
   extended=""

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
	    case database_prefix & "srchlist": srchlist=mid(textline,pos+1)
	    case database_prefix & "numerics": numerics=mid(textline,pos+1)
	    case database_prefix & "srchkey": srchkey=mid(textline,pos+1)
	    case database_prefix & "labellist": labellist=mid(textline,pos+1)
	    case database_prefix & "itemlist": itemlist=mid(textline,pos+1)
	    case database_prefix & "sortlist": sortlist=mid(textline,pos+1)
          case database_prefix & "defaultsort": defaultsort=mid(textline,pos+1)
          case database_prefix & "codeattr": codeattr=mid(textline,pos+1)
          case database_prefix & "sorts": sorts=mid(textline,pos+1)
          case database_prefix & "sortdescs": sortdescs=mid(textline,pos+1)
 	    case database_prefix & "radiobtns": radiobtns=mid(textline,pos+1)
	    case database_prefix & "radiocode": radiocode=replace(mid(textline,pos+1),"@WHERE@",where)
	    case database_prefix & "prefix": prefix=mid(textline,pos+1)
	    case database_prefix & "suffix": suffix=mid(textline,pos+1)
          case database_prefix & "hds": hds=mid(textline,pos+1)
          case database_prefix & "tds": tds=mid(textline,pos+1)
          case database_prefix & "dms": dms=replace(mid(textline,pos+1),"@WHERE@",where)
          case database_prefix & "adhoc": adhoc=mid(textline,pos+1)
          case database_prefix & "helpname": helpname=mid(textline,pos+1)
       end select
      LOOP
      SessionTextFile.Close
   end if
'response.write(tds)
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

   if helpname="" then helpname=srchname
   PhysicalPath=Server.MapPath("/prospect/help/" & helpname & ".txt")
   Set SessionFileObject=Server.CreateObject("Scripting.FileSystemObject")
   the_help = ""
   if SessionFileObject.FileExists(PhysicalPath) then
      Set SessionTextFile=SessionFileObject.OpenTextFile(PhysicalPath)
      the_help=SessionTextFile.Readall
   end if

   if radiobtns="BANKS" then
      values = PickLin.make_options(session("logentry"),"BANKS","",cstr(yrtouse),Session("d3needed"),Server.MapPath("\prospect\template\"),"raw")
      varray = split(values,chr(253))
      radiobtns="": radiocode=""
      for k=ubound(varray) to 0 step -1
         banks=varray(k)
         bdesc=split(varray(k),chr(252))
         if radiobtns<>"" then
            radiobtns=radiobtns & ","
            radiocode=radiocode & ","
         end if
         radiobtns=radiobtns & bdesc(1)
         banks="chq.rec"
         if k<>0 then banks=banks & (k+1)
         radiocode=radiocode & "|" & banks & "|" & templatetouse & "|" & bdesc(1)
      next
   end if
   if radiobtns="YEARS" then
      'Set picklin = Server.CreateObject("cka_iis.ckaiis")
      values = PickLin.make_options(session("logentry"),"GLYEARS","",cstr(yrtouse),Session("d3needed"),Server.MapPath("\prospect\template\"),"raw")
      'set picklin = nothing
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
      radiobtns=radiobtns & "Current Year"
      radiocode=radiocode & "|" & bdesc & "|" & templatetouse & "|Current Year" & " " & srchname
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
//************************************************************************************************************
var reportwindow=null;
function check_element_exists(ThisDoc,eType,eName,eId)
{
 //supports button,select-one,select-multiple
  for(var i=0;i<ThisDoc.length;i++)
    {
	 if(ThisDoc(i).type==eType)
	   {
	    if(ThisDoc(i).name!="")if(ThisDoc(i).name==eName)return "1";
		if(ThisDoc(i).id!="")if(ThisDoc(i).id==eId)return "1";
       }
	 }
 return "0";
}
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
'*************************
Sub pop_up
  Set  msgform=document.popup
  errmsg=REPLACE(msgform.failed.value,chr(254),"""")

  if msgform.box.value="Not" then
     msgbox "Item Not Found "  & vbCrLf & errmsg,vbInformation,"Search Result"
     msgform.box.value=""
  else
     if errmsg<>"" then
        if left(errmsg,1)=chr(8) then
	     msgbox "Report produced for "  & vbCrLf & mid(errmsg,2),vbInformation,"Report Information"
	     msgform.failed.value=""
        else
	     msgbox "No items found for "  & vbCrLf & errmsg,vbInformation,"Search Result"
	     msgform.failed.value=""
        end if
      end if
   end if
end sub
'**************
Sub setupinputbox
'Select the first input box on the search page (index starts at 0)
on error resume next   
document.forms.item(0).elements(5).select
end sub
'********************************************************************************************************
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
            'msgbox placetogo
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
      'if document.searchfrm.reports.value<>"adhoc.asp" then
      '   exists=check_element_exists(document.all,"select-one","reportbox","")
      '   if exists="1" then
      '      if document.all.reportbox.value="" then document.searchfrm.reports.value=""
      '      document.all.reportbox.value="" 
      '   end if   
      'end if
'msgbox tds & "=" & dms
      searchfrm.submit

End Sub
'********************************************************************************************************
</SCRIPT>
</HEAD>

<BODY  onLoad="pop_up();setupinputbox()"> 

<TABLE WIDTH="90%" ALIGN=CENTER BORDER="0" CELLSPACING="8" CELLPADDING="2">

<TR><TD>
    <TABLE WIDTH="90%" BORDER="1" CELLSPACING="1" CELLPADDING="1">
       <TR class=top><TD WIDTH=4% align=center class=browngrad>
       <a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>
<TD WIDTH=60% class=browngrad>
       <FONT size=+2 ><B>Reports</B></FONT>
<%if reportsfound then%>
        <SELECT NAME=reportbox Onchange='checkViewButton(this.value,document.all.View)'><OPTION VALUE="">
       <%for cnt=0 to Ubound(rname)%>
          <OPTION VALUE="<%=rname(cnt)%>">
<%
nme=mid(rname(cnt),instr(rname(cnt),"/")+1)
pos = instr(nme,".") 
if pos then nme=left(nme,pos-1)
response.write(nme)
next%>
       </SELECT>
       <INPUT TYPE="Button" NAME="View" Disabled CLASS=smallButt VALUE="View" OnClick='search_click(document.all.reportbox.value)'>
<%end if%> 
       <INPUT TYPE="Button" NAME="adhoc" CLASS=smallButt VALUE="Adhoc reporting" OnClick='search_click("adhoc")'>
 </TABLE>

<TR><TD>
<TR><TD>

<FORM name=searchfrm method=POST action="/prospect/asp/b.asp">
<TABLE WIDTH="90%" BORDER="1" CELLSPACING="1" CELLPADDING="1">
  <TR class=top>
      <TD ALIGN=CENTER class=TH>
         <FONT size=+2><B><%=headingname%></B></FONT>      
      <TD ALIGN=CENTER class=TH colspan=2>
        <FONT size=+1><B>Search Criteria</B></FONT>
      <TD ALIGN=CENTER class=TH>
        <FONT size=+1><B>Sort required</B></FONT> 
      <TD ALIGN=CENTER class=TH colspan=2>
        <FONT size=+1><B>Display Fields</B></FONT>
<TR class=top>     
     <TD class=TH align=center>
       <INPUT type="button" class="smallButt" name ="Clear" value="Clear All">
     <TD class=TH colspan=2 align=center>
       <INPUT type="button" class="smallButt" name ="Clear_search" value="Clear Searches">
 
      <TD class=TH align=center>
       <INPUT type=button name ="Clear_sort" value="Clear Sorts">
       <TD class=TH colspan=2 align=center>
      <INPUT type=button name ="Clear_select" value="Clear Fields">

<TR>

<%
'Next if statements are required so we can choose not to try passing these parameters
   itemarray = SPLIT(itemlist,",")
	
   redim preserve itemarray(max)
   operators="<OPTION VALUE=""="">=<OPTION VALUE=""#"">#<OPTION VALUE=""<"">&lt<OPTION VALUE=""<=""><=<OPTION VALUE="">"">&gt<OPTION VALUE="">="">>="        
   cook_id="search_" & templatetouse
'sorts  
   sortitems="<OPTION VALUE="""">"
   sortarray=split(sorts,",")
   descarray=split(sortdescs,",")
   redim preserve descarray(ubound(sortarray))
   for k=0 to ubound(sortarray)
      useop=sortarray(k)
      if instr(sortitems,"VALUE=""by " & useop & """") = 0 then
         sortitems=sortitems & "<OPTION VALUE=""by " & useop & """>" & "by " & descarray(k)
         sortitems=sortitems & "<OPTION VALUE=""by-dsnd " & useop & """>" & "by-dsnd " & descarray(k)
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

   response.write("<TR>")
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
         response.write("<TD colspan=5 class=browngrad><B>" & labelarray(j) & "<INPUT TYPE=hidden NAME=""" & uselabel & """ VALUE=""""> </B><TR>")
      else
         default=request.cookies(cook_id)("O" & j)
         if default="" then default="="
         default="<OPTION VALUE=""" & default & """>" & default
         default = default & replace(operators,default,"")  
         response.write("<TD width=20% class=top><B>" & labelarray(j) & "</B><TD width=""5%""><select " & "name=" & useop & ">" & default & "</select><TD width=""25%"">")
         If len(itemarray(j)) = 0 then 'normal input box
            response.write("<INPUT CLASS=smallTxt NAME=" & uselabel & " wrap=virtual value=""" & request.cookies(cook_id)(uselabel) & """>")
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
            if useop="by " & descarray(k) then sname="by " & sortarray(k): exit for
            if useop="by-dsnd " & descarray(k) then sname="by-dsnd " & sortarray(k): exit for
         next
         uitems="<OPTION VALUE=""" & sname & """>" & useop 
         uitems=uitems & replace(sortitems,uitems,"") 'remove the other occurence of item
      else
         uitems=sortitems
      end if   
      useop="sort" & j
      response.write("<TD><select " & "name=" & useop & ">" & uitems & "</select>")
   else
      response.write("<TD>")
   end if
'display fields
   if j<first then
      for hj=j to j+first step first
        if hj<=numheads then
         useop=request.cookies(cook_id)("head" & hj)
         if useop="" and defaulthead="" then useop=hdsarray(hj) & "|" & dmsarray(hj) & "|" & tdsarray(hj)
         if useop <> "" then
            pos=instr(useop,"|")
            if pos<>0 then sname=left(useop,pos-1) else sname="": useop=""
            uitems="<OPTION VALUE=""" & useop & """>" & sname
            uitems=uitems & replace(displayitems,uitems,"") ' this removes the other occurrence of the item
         else
            uitems=displayitems
         end if  
         response.write("<TD><select name=""head" & cstr(hj) & """>" & uitems & "</select>")
        else
         response.write("<TD>")
        end if
      next
   else
      response.write("<TD><TD>")
   end if
   response.write("<TR>")
next
   
   if len(radiobtns) > 0 then
	radioarray = split(radiobtns,",")
	radiocodearray = split(radiocode,",")
	response.write("<TR><TD colspan=6 ALIGN=center class=top>")
	for k = 0 to ubound(radioarray)
	   if k = ubound(radioarray) then chk="checked" else chk="" 'last button is default
	   response.write("<INPUT TYPE=radio NAME=radio VALUE=" & chr(34) & radiocodearray(k) & chr(34) & chk & ">" & radioarray(k))
	next
   end if
%>
</TABLE>

<TABLE WIDTH="90%" BORDER="0" CELLSPACING="1" CELLPADDING="1">
<TR>
<TD ALIGN=center>
<INPUT TYPE="button" class=smallButt name="Search" value="Search" OnClick='search_click("search")'>
<INPUT type=hidden NAME=page_size VALUE="20">
<TR>
<TD><%response.write(replace(the_help,vbcrlf,"<BR>"))%>
</TABLE>

</TABLE>

<INPUT TYPE=hidden NAME=fn VALUE="<%= filetouse %>">
<INPUT TYPE=hidden NAME=srchitems VALUE="<%= srchlist %>">
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
<input type="Submit" name="submit_trick" value="" align="MIDDLE" style="height: 10; width: 10; BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; background: transparent">
</form>

<FORM name=popup>
<INPUT TYPE=hidden NAME=box VALUE="<%=show_empty_box%>">
<INPUT TYPE=hidden NAME=failed VALUE="<%=failed_search%>">
</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
  
</BODY>
</HTML>