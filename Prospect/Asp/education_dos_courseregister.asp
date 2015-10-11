<%
connection_string = "DSN=education;"
sqlString = "SELECT * from students"
dosfilename="c:\ckashare\education\courseregister.txt"

dim flds(11) 
%>
<!--#include file="inc_education_provider_code.asp"-->
<%
flds(2)=0
flds(3)=3
flds(4)=4
flds(5)=5
flds(6)="!"
flds(7)=6
flds(8)="!" 
flds(9)=8
flds(10)=9
flds(11)=10

dim lens(11)
lens(1)=4
lens(2)=20
lens(3)=75
lens(4)=6
lens(5)=4
lens(6)=6
lens(7)=1
lens(8)=3
lens(9)=2
lens(10)=6
lens(11)=2

%>
<!--#include file="inc_msaccess_dos.asp"-->
