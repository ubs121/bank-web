<%
connection_string = "DSN=education;"
sqlString = "SELECT * from students"
dosfilename="c:\ckashare\education\students.txt"

dim flds(17) 
%>
<!--#include file="inc_education_provider_code.asp"-->
<%
flds(2)=0
flds(3)=3
flds(4)=4
flds(5)=5
flds(6)="1,1,4:2"
flds(7)=6
flds(8)=7
flds(9)="!"
flds(10)=8
flds(11)=9
flds(12)=10
flds(13)=11
flds(14)=12
flds(15)=13
flds(16)=14
flds(17)=15

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
