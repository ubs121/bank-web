<%
connection_string = "DSN=education;"
sqlString = "SELECT * from students"
dosfilename="c:\ckashare\education\enrolments.txt"

dim flds(18) 
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
flds(12)=11
flds(13)="!" 
flds(14)=13
flds(15)=14
flds(16)=15
flds(17)=16
flds(18)="!"

dim lens(18)
lens(1)=4
lens(2)=10
lens(3)=6
lens(4)=20
lens(5)=8
lens(6)=8
lens(7)=8
lens(8)=2
lens(9)=1
lens(10)=2
lens(11)=2
lens(12)=1
lens(13)=2
lens(14)=2
lens(15)=4
lens(16)=6
lens(17)=6
lens(18)=84

%>
<!--#include file="inc_msaccess_dos.asp"-->
