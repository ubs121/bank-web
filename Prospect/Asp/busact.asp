<% 
response.expires = 0 
response.buffer=true
%>
<HTML>
<HEAD>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
result = Request.Querystring("result")
%>
<TITLE>Prospect Log In</TITLE>

</HEAD>

<BODY>
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<%
  sentence= Request.Form("sentence")
  template= Request.Form("template")
  reportname= Request.Form("reportname")
  after=    Request.Form("after")
  account_name= session("account_name")
  user_name= session("user_name")
  passwrd=session("passwrd")
  Dim Str
  Str = empty
  Dim Ystr
  Ystr = "Y"
  BasPath=Server.MapPath("/prospect/template")
  ExcelPath=Server.MapPath("/prospect_site/excel")
  pararray = split(after,chr(254))
  Set cka_ta31 = Server.CreateObject("cka_gl.gl")
  result=cka_ta31.TA514(session("logentry"),Cstr(pararray(0)),Cstr(pararray(1)),Cstr(BasPath & "\BAS.htm"),Cstr(ExcelPath))
  Set cka_ta31 = nothing
  response.Write("<TABLE ALIGN=CENTER BORDER=1 CELLSPACING=1 CELLPADDING=1>" & result & "</TABLE>")
 
%>
</BODY>
</HTML>


