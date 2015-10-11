<% 
response.expires = 0 
%>
<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="<%=Session("content")%>">
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
status = Request.Querystring("a")
error = Request.Querystring("error")
%>
<TITLE>Prospect Log In</TITLE>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/login.js"></SCRIPT>
<SCRIPT LANGUAGE="VBSCRIPT">
Sub setupinputbox
	document.forms.verify.Username.select
end sub
</SCRIPT>
<script language="javascript">
function jump() {
document.location.href="login_check.asp"
}
</script>
<script>
<!--
// The Central Randomizer 1.3 (C) 1997 by Paul Houle (houle@msc.cornell.edu)
// See:  http://www.msc.cornell.edu/~houle/javascript/randomizer.html

rnd.today=new Date();
rnd.seed=rnd.today.getTime();

function rnd() {
        rnd.seed = (rnd.seed*9301+49297) % 233280;
        return rnd.seed/(233280.0);
};

function rand(number) {
        return Math.ceil(rnd()*number);
};

// end central randomizer. -->
</SCRIPT>
</HEAD>

<BODY MARGINWIDTH="0" MARGINHEIGHT="0" SCROLL="NO" onLoad="available_width=document.body.clientWidth; available_height=document.body.clientHeight;position_login();check_status();setupinputbox();"
     onResize="history.go(0)">

<DIV ID="collierLayer" STYLE="position: absolute; left: 200; top: 10; width: 354; height: 29;  visibility: hidden; z-index: 21;">
<IMG SRC="<%=PathToUse%>collier.gif" HEIGHT=29 WIDTH=354 BORDER=0>
</div>

<table width=100%>
<td align=left valign=top>
<script language="JavaScript"><!--
document.write('<img src="/prospect/images/bird_' + rand(3) + '_cropped.gif" alt="One of the Lorikeets nesting outside CKAs second floor window">');
//--></script>
</td>
<td align=right valign=top>
<script language="JavaScript"><!--
document.write('<img src="/prospect/images/bird_' + rand(3) + '_cropped.gif" alt="One of the Lorikeets nesting outside CKAs second floor window">');
//--></script>
</td>

</table>

<DIV ID="loginLayer" STYLE="position: absolute; left: 250px; top: 100px; width: 320px; height: 200px;visibility: hidden; z-index: 20;">

<table align=center border=1 cellspacing=3 cellpadding=1>
<FORM ACTION="/prospect/asp/login_check.asp" METHOD="POST" NAME="verify">
<tr class=top><th  align="CENTER" valign="MIDDLE" colspan=2>PROSPECT LOG ON

<tr class=top>
<%if session("d3needed")="yes" then%>
   <td width=50%>Account name
   <td><input TYPE="TEXT" NAME="Accountname" VALUE="<%=Request.cookies("login")("accountname")%>"
    OnMouseOver="window.status='Please Enter Account Name';return true;"
    OnMouseOut="window.status='';return true;">
<%end if%>  

<tr class=top>
<td width=50%>Username
<td><input TYPE="TEXT" NAME="Username" VALUE="<%=Request.cookies("login")("username")%>"
     OnMouseOver="window.status='Please Enter Your User ID';return true;"
	 OnMouseOut="window.status='';return true;">
  

<tr class=top>
<td width=50%>Password
<td><input TYPE="password" NAME="Password" VALUE=""
     OnMouseOver="window.status='Please Enter Your Password';return true;"
	 OnMouseOut="window.status='';return true;">
 
</table>

<table width="320">
<TR>
<TD align=center><INPUT class = th TYPE="IMAGE" src="<%= PathToUse %>log_submit.gif" name="Login" value="Login"
      OnMouseOver="window.status='Click to submit log on details';return true;"
	  OnMouseOut="window.status='';return true;">
</table>
<%
if error <> "" then
   error = replace(error,"_"," ")
   response.write("Try again. " & error)
end if
%>
<input type="Submit" name="change_style" value="" align="MIDDLE" style="height: 10; width: 10; BORDER-LEFT-WIDTH: 0px; BORDER-RIGHT-WIDTH: 0px; BORDER-TOP-WIDTH: 0px; BORDER-BOTTOM-WIDTH: 0px; background: transparent">


</FORM>
</div>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
<FORM name=login ><INPUT TYPE=hidden NAME=status VALUE="<%= status%>"></FORM>

</BODY>
</HTML>

