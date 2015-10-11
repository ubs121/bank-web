<%
connection_string = "DSN=education;"
sqlString = "SELECT * from students"
dosfilename="c:\ckashare\education\returns.txt"

dim flds(17) 
  Set SessionFileObject=Server.CreateObject("Scripting.FileSystemObject")
  Set SessionTextFile=SessionFileObject.OpenTextFile("c:\ckashare\education\provider_code.txt")
  flds(1)="""" & SessionTextFile.ReadAll
  SessionTextFile.Close
  Set SessionFileObject=nothing
flds(2)=0
flds(3)=3
flds(4)=4
flds(5)=5
flds(6)="1,1,4:2"
flds(7)=6
flds(8)=7
flds(9)=8
flds(10)=9
flds(11)=10
flds(12)=11
flds(13)=12
flds(14)=13
flds(15)=14
flds(16)=15
flds(17)=16

dim lens(17)
lens(1)=4
lens(2)=10
lens(3)=1
lens(4)=8
lens(5)=6
lens(6)=5
lens(7)=2
lens(8)=4
lens(9)=1
lens(10)=4
lens(11)=4
lens(12)=2
lens(13)=3
lens(14)=2
lens(15)=1
lens(16)=1
lens(17)=12


%>
<!--#include file="inc_msaccess_dos.asp"-->
