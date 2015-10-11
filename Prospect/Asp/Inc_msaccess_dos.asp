<%
'This page is reliant on an ODBC Data Source System, System DSN having been setup throgh Control Panel
'Passed variables are;
'	connection_string = "DSN=education;"
'	sqlString = "SELECT * from students"
'	dosfilename="c:\ckashare\education\returns.txt"
'	flds 
'	lens 
'On error Resume Next

	Set conn = Server.CreateObject("ADODB.Connection")
	conn.Open connection_string
	Set rs = Server.CreateObject("ADODB.RecordSet")
	rs.Open sqlString, conn

	if NOT(Err.Number<>0) then
		if rs.EOF and rs.BOF then
                        response.write "There are no items" & vbCr	
		end if
	else
		response.write "There were errors" & vbCr
	end if


Set dosobject = CreateObject("Scripting.FileSystemObject")
Set dosfile = dosobject.CreateTextFile(dosfilename, true)

do until rs.eof
   mystr=""
   for j = 1 to ubound(flds)
      temp = flds(j)
      if instr(temp,":")<>0 then
         tfs = split(temp,":")
         temp=""
         for k=0 to ubound(tfs)
            if instr(tfs(k),",")<>0 then
               tfss=split(tfs(k),",")
               tfs(k)=mid(rs(cint(tfss(0))) & string(cint(tfss(2))," "),cint(tfss(1)),cint(tfss(2)))
            else
               tfs(k) = rs(cint(tfs(k)))
            end if
            temp=temp & tfs(k)
         next
      else
         if left(temp,1) <> "!" then
            temp=rs(flds(j))
         else
            temp = mid(temp,2)
         end if      
      end if
      mystr=mystr & left(temp & string(lens(j)," "),lens(j))
   next
   dosfile.WriteLine(mystr)
   rs.movenext
loop
dosfile.Close
Set dosobject = nothing
rs.close
conn.close
set conn = nothing

referer_page=Request.ServerVariables("http_referer")
start_pos = instr(referer_page,"&msgbox")
if start_pos <> 0 then referer_page = left(referer_page,start_pos-1)
response.redirect referer_page & "&msgbox=" & dosfilename & " Created Successfully"

%>