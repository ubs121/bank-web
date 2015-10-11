<!--#include file="Inc_timeout_test.asp"-->
<%
response.expires=0

Set SessionFileObject=Server.CreateObject("Scripting.FileSystemObject")

dim Prospect_explorer, menujs
   name= Request.cookies("login")("username")
   uname = "user.asp"
   if Session("ex_template") <> "ex_template.asp" then uname = "user_" & Session("ex_template")
   fname="/prospect_site/security/" & uname
   PhysicalPath=Server.MapPath(fname)
Set SessionFileObject=Server.CreateObject("Scripting.FileSystemObject")
   error = ""
   if NOT SessionFileObject.FileExists(PhysicalPath) then
      error = fname & " does not exist, or is not shared as IIS Virtual Directory"
      response.write(error)
   end if
if error = "" then
   Set SessionTextFile=SessionFileObject.OpenTextFile(PhysicalPath)
   counter=0
   found=0

   DO WHILE NOT SessionTextFile.AtEndofstream
   
       textline=SessionTextFile.ReadLine
       pos = Instr(textline,";")
       file_userid=""

     IF pos > 0 THEN  file_userid=LEFT(textline,pos-1)
  
     IF file_userid=name AND  file_userid <>"" then
        permits = Right(textline,Len(textline)-pos)
	  found =1   
        EXIT DO	 
     END IF
       counter=counter+1
  LOOP
  SessionTextFile.Close

  Dim Tags()
  Dim Links()
  Dim Keep
  Redim Links(1)
  Redim Tags(1)
  Redim Keep(1)

  IF found=1  THEN
%>
   <!--#include virtual= "/prospect/asp/inc_setupexplorer.asp"-->
   <%
     SetupExplorer
ELSE
     Response.Redirect "/prospect/asp/login.asp?a=fail"
 END IF
end if
%>

<HTML>
<HEAD>
<meta http-equiv="Content-Type" content="<%=Session("content")%>">
<TITLE>Welcome To Prospect</TITLE>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/<%=menujs%>"></SCRIPT>

<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
SSIpath = REPLACE(PathToUse,"/prospect","..")
%>

<STYLE>
TD           { background-image:none; font: 9pt "Arial";font-weight: normal;color: black;}
</STYLE>


</HEAD>

<BODY  onLoad="
          available_width=document.body.clientWidth;
          available_height=document.body.clientHeight;
		  preLoad_menu();"> 
		  
<%Response.Write(Prospect_explorer)%>
<FORM name="path"><INPUT TYPE=hidden NAME="pn" VALUE="<%= PathToUse %>"></FORM>
</BODY>

</HTML>