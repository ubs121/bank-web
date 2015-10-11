<HTML>
<HEAD>
<TITLE>Session has Timed Out</TITLE>

<META http-equiv="Refresh" content="5; url=<%=Request.cookies("login")("index_page")%>">

<STYLE>
A:link {text-decoration:none;}
A:visited {text-decoration:none;}
A:active {text-decoration:none;}
</STYLE>
</HEAD>

<BODY>
<P>
&nbsp;
<P>
<CENTER>
<H1>Sorry, your session has timed out.</h1> 
<font size=+1>You will have to log on again if you wish to continue using Prospect.</font>
<P>
&nbsp;
<P>
<FORM METHOD=GET ACTION="<%=Request.cookies("login")("index_page")%>">
<INPUT TYPE=SUBMIT VALUE="Go to Start">
</FORM>
</CENTER>
</BODY>
</HTML>