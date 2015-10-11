<%
dim srchname,textline,TemplatePath,PhysicalPath,SessionFileObject,SessionTextFile
dim tblName,database,searchColumns,searchString,template,title,page_size
dim pos,paramName,paramValue,result

page_size=15
srchname=Request.QueryString("fn")
searchString=Request.QueryString("searchString")
if not right(srchname,4)=".txt" then
	srchname=srchname&".txt"
end if	
Session("AccountDll")="Journal.Account"

TemplatePath = Server.MapPath("/prospect/template/")
PhysicalPath=Server.MapPath("/prospect/search/" & srchname)
Set SessionFileObject=Server.CreateObject("Scripting.FileSystemObject")
if SessionFileObject.FileExists(PhysicalPath) then
	set SessionTextFile=SessionFileObject.OpenTextFile(PhysicalPath)
    DO WHILE NOT SessionTextFile.AtEndofstream
       textline=SessionTextFile.ReadLine
       pos=instr(textline,"=")
       if pos<>0 then
	   		paramName=left(textline,pos-1)
			paramValue=mid(textline,pos+1)
       else
	   		paramName=""
			paramValue=""
	   end if

select case paramName
	case "filetouse"
		tblName=paramValue
	case "database" 								   	
		database=paramValue
	case "templatetouse" 
		template=paramValue
	case "title"
		title=paramValue
	case "srchkey"
		searchColumns=split(paramValue,",")	
end select
	loop
end if			

set AccountObj=Server.createObject(Session("AccountDll"))
result=AccountObj.generateHTML(database,tblName,searchString,searchColumns,TemplatePath,template,title,cInt(page_size))
%>
