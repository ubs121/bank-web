<% 
response.expires = 0 
response.buffer=true

PathToUse= Session("imagePath")
StyleToUse= Session("userStyle")

filetouse = replace(Request.Querystring("fn"),"@@PATH@@",session("the_drive"))
template =  Request.Querystring("tn")
itemtoget = Request.Querystring("item")
action=Request.Querystring("action")
sentence=Request.Querystring("sentence")
search=Request.Querystring("search")
transfile= Request.Querystring("fn1")
found = Request.Querystring("found")
clearscreen =  Request.Querystring("blank")
input_error = Request.Querystring("err")

if action="" then action="4"
found=itemtoget

if clearscreen="yes" then  itemtoget=cstr(chr(8)) : found=chr(8)
If InStr(filetouse, ".mdb\") Then how = 1 Else how = 0  'how=0 on pick, how=1 on msaccess

ResultPage = Picklin.make_html_item(Server.MapPath("\prospect\template\"),Session("logentry"),CStr(how), cstr(filetouse), cstr(itemtoget), cstr(template), cstr(action),cstr(sentence),cstr(search),cstr(transfile))

if left(ResultPage,1)=chr(8) then 
   ResultPage=mid(ResultPage,2)
   found="no"
end if  

'Session("LastGoodItem")="/prospect/asp/debtors_control_account.asp?fn=" & Server.URLencode(filetouse) & "&tn=" & Server.URLencode(template) & "&item=" & Server.URLencode(itemtoget) & "&baditem=empty&blank=no&err=noerrors&found=no&search=" & search
%>

<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="<%=Session("content")%>">
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/search.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/RSNav.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/rs.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">RSEnableRemoteScripting("/prospect/java");</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/menu.js"></SCRIPT>
<SCRIPT LANGUAGE="VBScript" SRC="/prospect/jscript/validate.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript1.2" SRC="/prospect/jscript/clear.js"></SCRIPT>

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

<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
validated = Request.Form("validated")

if validated = "1" then
   controlrec = Request.Form("item") 
   relate = Request.Form("desc") 
   writeerror = d3.d3_writestr(Cstr(session("database")),"DICT TRANS.J", "TRANS.INFO",cstr(controlrec))
   If writeerror <> "0" Then
      result = "Write to " & "DICT TRANS.J" & " item " & "TRANS.INFO" & " failed"
   Else
      result = "Updated"
   end if
   writeerror = d3.d3_writestr(Cstr(session("database")),"DICT TDEBTOR", "@RELATE",cstr(relate))
   If writeerror <> "0" Then
      result = "Write to " & "DICT TDEBTOR" & " item " & "RELATE" & " failed"
   end if		
   validated = ""
   If result <> "Updated" Then 
	   result = chr(8) & result
   else
       result = "0" & Chr(253) 
   end if
   
  error_type=LEFT(result,1)
  if error_type<>chr(8) then
     info_array=SPLIT(result,chr(253))
     if ubound(info_array) < 2 then redim preserve info_array(2)
     write_status=info_array(0)
     dll_message=info_array(2)
     if write_status = "0" then dll_message="noerrors"
  else
     dll_message=result
  end if
  page = request.servervariables("path_info") & "?fn=" & filetouse & "&tn=" & template & "&item=" & itemtoget & "&baditem=empty&blank=no" & "&err=" & dll_message & "&found=yes&search=" & search
  Response.Redirect page 
else
   controlrec = PickLin.readstr(session("database"),"DICT TRANS.J","TRANS.INFO")
   accountdesc = PickLin.readstr(session("database"),"DICT TDEBTOR","@RELATE")
   result=""
end if
%>
<%response.write(StyleToUse)%>

</HEAD>

<BODY onLoad="available_width=document.body.clientWidth;available_height=document.body.clientHeight;ShowError();pop_up();">

<FORM NAME="assetdata" ACTION="<%=request.servervariables("path_info")%>?fn=<%=filetouse%>&tn=<%=template%>&item=<%=itemtoget%>&baditem=empty&blank=no&err=<%=dll_message%>&found=yes&search=<%=search%>"  METHOD="POST">
<input type="hidden" name="item" value="<%=controlrec%>">
<input type="hidden" name="desc" value="<%=accountdesc%>">
<input type="hidden" name="template" value="<%=template%>">
<input type="hidden" name="validated" value="">
</FORM>

<FORM  NAME="assetform">

<DIV id="Test" STYLE="position: absolute; left: 10px; top: 40px; width: 790px; z-order: 2; visibility: visible;">
<TABLE WIDTH="95%" border="1" cellspacing="1" cellpadding="1" align="center">
<TR class=top>
<TD WIDTH="5%">
        <A href="/prospect/asp/menu.asp"><IMG SRC="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="30" HEIGHT="22" ALT="Prospect Explorer"></A>
<TD><input class=bold type="button" name="Update" value="Update" onClick="SubmitForm();"> 	
</TABLE>
</DIV>
<%= ResultPage%>

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