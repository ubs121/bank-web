<!--#include file="Inc_timeout_test.asp"-->

<%

PathToUse =  Session("imagePath")
StyleToUse = Session("userStyle")
session("dd") = "n"

'*******
filetouse = Request.Querystring("fn")
template =  "gen_l"
itemtoget = Request.Querystring("ref")
whattodo = Request.Querystring("show")

if found="no" then found =chr(254) else found =itemtoget
if itemtoget ="empty" AND baditem<>"empty" then  found=chr(8)
'*******
%>

<HTML>
<HEAD>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/menu.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/navbar.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript1.2" SRC="/prospect/jscript/graph.js"></SCRIPT>

<SCRIPT LANGUAGE="VBSCRIPT">
Sub pop_up
Set  msgform=document.item_status
if msgform.item.value=chr(254) then
msgbox "Item Not Found"  & vbCrLf & msgform.baditem.value ,vbInformation,"Search Result"
end if
end sub

Sub setupinputbox
'Select the input box on the item page 
	document.forms.itemid.item.select
end sub

</SCRIPT>

</HEAD>
<BODY>
<!--#include file="Inc_home.asp"-->
<H1 align=center>General Ledger <%=itemtoget%></H1>

<%

'''this works!!!!
listofyears = PickLin.readstr(session("database"),"DICT TRANS.J", "TRANS.INFO","140")
yeararray = split(listofyears, chr(253))
'Maxyr is the current g/l year
thisyr = yeararray(ubound(yeararray))
nextyr = thisyr + 1
lastyr = thisyr - 1

budgetlist = PickLin.readstr(session("database"),cstr(filetouse), cstr(itemtoget),"8")
if budgetlist = "" then budgetlist = "0"
budgetarray = split(budgetlist, chr(253))

bigthis = 0
biglast = 0
bignext = 0
redim preserve budgetarray(35)
for j = 0 to ubound(budgetarray)
   if budgetarray(j) = "" then budgetarray(j) = "0"
next

'Multiply by -1 as budgetss held as -ve figures
b_this = budgetarray(0) * -1
if abs(budgetarray(0)) > bigthis then bigthis = abs(budgetarray(0))
for j = 1 to 11
   b_this = b_this & "," & budgetarray(j) * -1
   if abs(budgetarray(j)) > bigthis then bigthis = abs(budgetarray(j))
next

b_last = budgetarray(12) * -1
if abs(budgetarray(12)) > biglast then biglast = abs(budgetarray(12))
for j = 13 to 23
   b_last = b_last & "," & budgetarray(j) * -1
   if abs(budgetarray(j)) > biglast then biglast = abs(budgetarray(j))
next

b_next = budgetarray(24) * -1
if abs(budgetarray(24)) > bignext then bignext = abs(budgetarray(24))
for j = 25 to 35
   b_next = b_next & "," & budgetarray(j) * -1
   if abs(budgetarray(j)) > bignext then bignext = abs(budgetarray(j))
next

actuallist = PickLin.readstr(session("database"),cstr(filetouse), cstr(itemtoget),"9")
if actuallist="" then actuallist = "0"
actualarray = split(actuallist, chr(253))
redim preserve actualarray(35)

for j = 0 to ubound(actualarray)
   if actualarray(j) = "" then actualarray(j) = "0"
next

'divide by 100 as actual shows cents
a_this = int(actualarray(0) / 100 * -1)
if abs(int(actualarray(0)/100)) > bigthis then bigthis = abs(int(actualarray(0)/100))
for j = 1 to 11
   a_this = a_this & "," & int(actualarray(j) / 100 * -1)
   if abs(int(actualarray(j)/100)) > bigthis then bigthis = abs(int(actualarray(j)/100))
next

a_last = int(actualarray(12) /100 * -1)
if abs(int(actualarray(12)/100)) > biglast then biglast = abs(int(actualarray(12)/100))
for j = 13 to 23
   a_last = a_last & "," & int(actualarray(j) / 100 * -1)
   if abs(int(actualarray(j)/100)) > biglast then biglast = abs(int(actualarray(j)/100))
next

a_next = int(actualarray(24) /100 * -1)
if abs(int(actualarray(24)/100)) > bignext then bignext = abs(int(actualarray(24)/100))
for j = 25 to 35
   a_next = a_next & "," & int(actualarray(j) / 100 * -1)
   if abs(int(actualarray(j)/100)) > bignext then bignext = abs(int(actualarray(j)/100))
next

bigthis = int(bigthis / 20)
if bigthis=0 then bigthis=1
bigthis=int(bigthis/(10^(len(bigthis)-1)))*10^(len(bigthis)-1)
biglast = int(biglast / 20)
if biglast=0 then biglast=1
biglast=int(biglast/(10^(len(biglast)-1)))*10^(len(biglast)-1)
bignext = int(bignext / 20)
if bignext=0 then bignext=1
bignext=int(bignext/(10^(len(bignext)-1)))*10^(len(bignext)-1)

'response.write(biggest & "=")
'response.write("Result is : " & b_this & "<P>")
'response.write("Result is : " & b_last & "<P>")
'response.write("Result is : " & b_next & "<P>")
'response.write("Result is : " & a_this & "<P>")
'response.write("Result is : " & a_last & "<P>")
'response.write("Result is : " & a_next & "<P>")
'response.end

%>

<P align=center>
<SCRIPT LANGUAGE="JavaScript1.2">
var g = new Graph(300,400);
//g.stacked=true;
//g.addRow(124,138,216,143,256,302);
//g.addRow(201,234,340,210,314,320);
g.addRow(<%=b_this%>);
g.addRow(<%=a_this%>);
g.scale = <%=bigthis%>;
g.longDate=true;
g.showYear=true;
g.longYear=true;
g.setDate(31,7,19<%=thisyr %>);
g.inc = 30;
g.title = "This Year";
g.xLabel = "Date";
g.yLabel = "Dollars";
g.setLegend("Budget","Actual");
g.build();
</SCRIPT>

<HR width=65% size=1>
<B><A HREF="javascript:history.go(-1)">Back to Account Display</A></B>
<P align=center>

<SCRIPT LANGUAGE="JavaScript1.2">
var g = new Graph(300,400);
//g.stacked=true;
//g.addRow(124,138,216,143,256,302);
//g.addRow(201,234,340,210,314,320);
g.addRow(<%=b_last%>);
g.addRow(<%=a_last%>);
g.scale = <%=biglast%>;
g.showYear=true;
g.longYear=true;
g.longDate=true;
g.setDate(31,7,19<%=lastyr%>);
g.inc = 30;
g.title = "Last Year";
g.xLabel = "Date";
g.yLabel = "Dollars";
g.setLegend("Budget","Actual");
g.build();
</SCRIPT>

<HR width=65% size=1>
<B><A HREF="javascript:history.go(-1)">Back to Account Display</A></B>
<P align=center>

<SCRIPT LANGUAGE="JavaScript1.2">
var g = new Graph(300,400);
//g.stacked=true;
//g.addRow(124,138,216,143,256,302);
//g.addRow(201,234,340,210,314,320);
g.addRow(<%=b_next%>);
g.addRow(<%=a_next%>);
g.scale = <%=bignext%>;
g.showYear=true;
g.longYear=true;
g.longDate=true;
g.setDate(31,7,19<%=nextyr%>);
g.inc = 30;
g.title = "Next Year";
g.xLabel = "Date";
g.yLabel = "Dollars";
g.setLegend("Budget","Actual");
g.build();
</SCRIPT>

<P>
<A HREF="javascript:history.go(-1)">Back to Account Display</A>

<%

%>


<FORM name="item_status">
<INPUT TYPE=hidden NAME="item" VALUE="<%= found%>">
<INPUT TYPE=hidden NAME="baditem" VALUE="<%= baditem%>">
</FORM>
<FORM name="path"><INPUT TYPE=hidden NAME="pn" VALUE="<%= PathToUse %>"></FORM>
</BODY>
</HTML>