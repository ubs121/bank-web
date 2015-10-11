<HTML>
<HEAD><TITLE>Session Terminated</TITLE>

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
&nbsp;
<P>
<CENTER>
<H1>Your Prospect session has terminated</h1>
<P>
&nbsp;
<P>
You will be redirected to the login page shortly, or you may click the button below.
<P>
&nbsp;
<P>
<FORM METHOD=GET ACTION="<%=Request.cookies("login")("index_page")%>">
<INPUT TYPE=SUBMIT VALUE="Go to Start">
</FORM>
</CENTER>
</BODY>
</HTML>