<% response.expires = 0 
   response.buffer=true
%>
<HTML>
<HEAD>
</HEAD>

<BODY>
<%
account_name= Request.Form("Accountname")
user_name= Request.Form("Username")
passwrd= Request.Form("Password")
template_path=ucase(Server.MapPath("\prospect\template\"))
the_drive = Left(template_path, InStr(template_path, "\PROSPECT\") - 1) & "\"
logentry =  chr(254) & account_name & chr(254) & user_name & chr(254) & passwrd & chr(254) & Server.MapPath("/Prospect_site/Documents") & chr(254) & Server.MapPath("/Prospect_site/Excel") & chr(254) & Server.MapPath("/Prospect_site/Memory/") & day(now) & month(now) & year(now) & timer() * 100 & chr(254) & Session("newzealand") & chr(254) & the_drive

if Session("d3needed") <> "yes" then
   msg=""
else
   msg=d3.d3_initialize(cstr(logentry))
end if

if Session("newzealand") = "mongolia" then
   Session("language") = request.form("language")
else
   Session("language") = ""
end if

if msg <> "" then
   msg = replace(msg, " ", "_")
   Response.Redirect "/prospect/asp/login.asp?error=" & msg
else
   response.cookies("login")("index_page") = Session("name")
   if account_name <> "" then response.cookies("login")("accountname") = account_name
   response.cookies("login")("username") = user_name
   response.cookies("login").expires = date + 365
 
   Session("logentry") = logentry
   Session("the_drive") = the_drive
   Session("database") = account_name 
   Response.Redirect "/prospect/asp/menu.asp"
end if
%>
</BODY>

</HTML>
