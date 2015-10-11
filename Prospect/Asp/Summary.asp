<!--#include file="Inc_timeout_test.asp"-->
<HTML>
<HEAD>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/menu.js"></SCRIPT>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")

yrtouse = request.form("genlyear")
if yrtouse="" then filetouse="gen.l" else filetouse="gen.l." & yrtouse
items = PickLin.make_options(session("logentry"),"GLYEARS","",cstr(yrtouse),Session("d3needed"),Server.MapPath("\prospect\template\"))
%>
<SCRIPT LANGUAGE="VBSCRIPT">
Sub Summarise_OnClick
   document.glsummfrm.genlyear.value=document.summaryfrm.genlyear.value
   glsummfrm.submit
End Sub
</SCRIPT>
</HEAD>

<BODY onLoad="
          available_width=document.body.clientWidth;
          available_height=document.body.clientHeight;"> 
<!--#include file="Inc_home.asp"-->

<FORM name=summaryfrm method=POST action="/prospect/asp/summary.asp">
<P>
<h2 align=center>General Ledger Summary</h2>
<P>
<table border align=center>
<TR class=top><TD align=left><B>Year</B>
<TD ALIGN=center>
<select name="genlyear"><%response.write(items)%>
<INPUT TYPE="button" class=smallButt name="Summarise" value="Summarise Year">

<tr>
<td class=top>
<B><A HREF="/prospect/asp/bsumm.asp?fn=<%= filetouse %>&tn=gen_l_summary&qtype=0&atype=A">Assets</A></B><td align=right> 

<%
sentence = "select " & filetouse & " with a0 = " & chr(34) & "[.0" & chr(34) & " and with a10 = " & chr(34) & "A" & chr(34) & " a3"
valuelist =  PickLin.get_ids(Session("logentry"),cstr(sentence),  "", "", "","1")
response.write(FormatCurrency(valuelist/100))
%>

<tr>
<td class=top>
<B><A HREF="/prospect/asp/bsumm.asp?fn=<%= filetouse %>&tn=gen_l_summary&qtype=0&atype=L">Liabilities</A></B><td align=right>

<%
sentence = "sselect " & filetouse & " with a0 = " & chr(34) & "[.0" & chr(34) & " and with a10 = " & chr(34) & "L" & chr(34) & " a3"
sumvals =  PickLin.get_ids(Session("logentry"),cstr(sentence),  "", "", "","1")
response.write(FormatCurrency(sumvals/100))
%>

<tr>
<td colspan=3>
&nbsp;
<tr>
<td class=top>
<A HREF="/prospect/asp/bsumm.asp?fn=<%= filetouse %>&tn=gen_l_summary&qtype=0&atype=U">Unappropriated Operating Result</A></B><td align=right> 
<%
sentence = "sselect " & filetouse & " with a0 = " & chr(34) & "[.0" & chr(34) & " and with a1 = " & chr(34) & "C" & chr(34) & " a3"
sumvals =  PickLin.get_ids(Session("logentry"),cstr(sentence),  "", "", "","1")
response.write(FormatCurrency(sumvals/100))%>

</table>
</FORM>

<FORM name=glsummfrm method=POST action="/prospect/asp/summary.asp">
  <INPUT TYPE=hidden NAME="genlyear">
</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
</BODY>
</HTML>