<%
response.buffer=true
response.expires = 0 
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
%>
<HTML>
<HEAD>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/menu.js"></SCRIPT>
<SCRIPT LANGUAGE="VBSCRIPT">
Sub setupinputbox
	document.forms.item(0).elements(3).select
end sub
</SCRIPT>
<%
template = Request.Querystring("tn")
itemtoget = Request.Querystring("item")
%>
</HEAD>

<BODY onLoad="available_width=document.body.clientWidth;available_height=document.body.clientHeight;setupinputbox()">
<!--#include file="Inc_home.asp"-->
<P>
&nbsp;
<P>
<center>
<B><FONT SIZE=+1>PROPERTY: Penalties / Instalments / Settlement Statement</FONT></B>
<P>
<center><B><FONT SIZE=+1>Assessment <%= itemtoget %></FONT></B>
<P>
&nbsp;
<P>
<CENTER>
<FORM name=property_penalty_date method=GET action="/prospect/asp/bi.asp">
<INPUT TYPE=hidden NAME=item VALUE="<%= itemtoget %>">
<INPUT TYPE=hidden NAME=tn VALUE="<%= template %>">
<INPUT TYPE=hidden NAME=fn VALUE="<%= chr(8) %>">
Calculations to date: <INPUT TYPE=text NAME="parameter" VALUE ="<%=date%>">
</FORM>
</CENTER>

<FORM name="path"><INPUT TYPE=hidden NAME="pn" VALUE="<%=PathToUse%>"></FORM>

</BODY>
</HTML>