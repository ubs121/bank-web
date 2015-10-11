<%
 response.expires = 0 
 response.cachecontrol = "public"

 pickfile= Request.Form("pickfile")
 page_size=Request.Form("page_size")
 page = Request.Form("page")
 sentence = Request.Form("sentence")
 template= Request.Form("template")
 title = Request.Form("title")
 hds = Request.Form("hds")
 tds = Request.Form("tds")
 dms = Request.Form("dms")
 want_excel= Request.Form("want_excel")
 codeattr = Request.Form("codeattr")

 'Set picklin = Server.CreateObject("cka_iis.ckaiis")
 itemlist = Picklin.making_html(Server.MapPath("\prospect\template\"),Session("logentry"),cstr(pickfile), cstr(sentence), cstr(template), cstr(page),cstr(page_size),cstr(want_excel),,Server.MapPath("\prospect_site\excel\"),cint(codeattr),"",cstr(title),cstr(hds),cstr(tds),cstr(dms))
 'set picklin = nothing
%>

<HTML>
<HEAD>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/menu.js"></SCRIPT>
<SCRIPT LANGUAGE="VBSCRIPT" SRC="/prospect/jscript/sliders.js"></SCRIPT>

<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
%>
</HEAD>

<%
response.write(itemlist)
%>
<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
</BODY>
</HTML>