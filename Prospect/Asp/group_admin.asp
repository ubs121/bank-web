
<%
  response.buffer =true
  response.cachecontrol = "public"
  StyleToUse=Session("userStyle")
  response.write(StyleToUse)
  PathToUse=Session("imagePath")

  Dim Prospect_explorer,box_size,received_permissions,received_id
  Dim ids(),Tags(),Links(),Keep(),Permissions()

  Redim ids(1)
  Redim Permissions(1)
  Redim Links(1)
  Redim Tags(1)
  Redim Keep(1)

  box_size =0
  
  received_permissions= Request.Form("perm")
  received_id= Request.Form("perm_id")
  Set SessionFileObject=Server.CreateObject("Scripting.FileSystemObject") 

%>
<!--#include file="Inc_timeout_test.asp"-->
<!--#include virtual= "/prospect/asp/inc_security.asp"-->
<!--#include virtual= "/prospect/asp/inc_setupexplorer.asp"-->
   <%
      permits = "all"
      SetupExplorer
  %>
<HTML>
<HEAD>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/<%=Session("checkboxjs")%>"></SCRIPT>
<SCRIPT LANGUAGE="VBSCRIPT" SRC="/prospect/jscript/id_refresh.js"></SCRIPT>
</HEAD>		
<BODY  onLoad='
          available_width=document.body.clientWidth;
          available_height=document.body.clientHeight;
          Load_CheckBoxes();LoadListItem(0)'> 

<DIV ID="gobackLayer" STYLE="position: absolute; left: 10px; top: 10px; width: 100px;visibility: hidden; z-index: 8;">
<FORM>
<INPUT TYPE="button" NAME="GoBack" VALUE="Explorer Menu">
</FORM>
</DIV>

<H2 align="center">Group Security Maintenance</H2>
<DIV ID="loadingLayer" STYLE="visibility: visible; z-index: 8;">
<H2 align="center">Processing ...</H2>
</DIV>

<DIV ID="displayLayer" STYLE="position: absolute; left: 312px; top: 30px; width: 250px;visibility: hidden; z-index: 5;">
<FORM ACTION="/prospect/asp/write.asp" METHOD="POST" NAME="display_all">
   
   <%
response.write(Prospect_explorer)

   %>


</DIV>

<DIV ID="buttLayer" STYLE="position: absolute; left: 300px; top: 316px; width: 205px;visibility: hidden; z-index: 7;">
<TABLE border="1" cellspacing="2" cellpadding="1">
<TR><TD colspan=2><INPUT TYPE="Button" NAME="Update" VALUE="Update">
<TR><TD><INPUT TYPE="button" NAME="Clear" VALUE="Remove All">
<TD><INPUT TYPE="button" NAME="All" VALUE="Allow All">
<INPUT TYPE="hidden" NAME="userid" VALUE="">
<INPUT TYPE="hidden" NAME="itemType" VALUE="">
<INPUT TYPE=hidden NAME=perms_type VALUE="group">
</TABLE>
</DIV>
</FORM>

<%Get_List("group.asp")%>
<DIV ID="ulistLayer" STYLE="position: absolute; left: 50px; top: 50px; width: 200px;visibility: hidden; z-index: 5;">
<FORM name="user_list">
<TABLE WIDTH="100%" border="1" cellspacing="3" cellpadding="1">
<TH colspan=2>Groups
<TR>
<TD width="90%" CLASS="mm">
<SELECT NAME=usr SIZE="<%=box_size%>">
<%Select_ID("user")%>
</SELECT>
<TR><TD class="mm""><INPUT TYPE="Button" NAME="Load" VALUE="Load">
<TR><TD class="mm""><INPUT TYPE="Button" NAME="Add" VALUE="Add">
<INPUT TYPE="Text" NAME="NewUser" SIZE="18" MAXLENGTH="18">
<TR><TD class="mm""><INPUT TYPE="Button" NAME="Delete" VALUE="Delete">
</TABLE>
</FORM>
</DIV>

<DIV ID="groupLayer" STYLE="position: absolute; left: 50px; top: 50px; width: 200px;visibility: hidden; z-index: 55;"></DIV>

 <FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
 <FORM name=permissions ACTION="/prospect/asp/write.asp" METHOD="POST">
  <INPUT TYPE=hidden NAME=perms VALUE="<%=received_permissions%>">
  <INPUT TYPE=hidden NAME=perms_id VALUE="<%=received_id%>">
  <INPUT TYPE=hidden NAME=perms_type VALUE="group">
  
 </FORM>

</BODY>
</HTML>
