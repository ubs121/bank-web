<!--#include file="Inc_timeout_test.asp"-->
<%
filetouse = Request.Querystring("fn")
template =  "gen_l"
itemtoget = Request.Querystring("ref")
whattodo = Request.Querystring("show")

if found="no" then found =chr(254) else found =itemtoget
if itemtoget ="empty" AND baditem<>"empty" then  found=chr(8)

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
 
budget=split(b_this,",")
actual=split(a_this,",")

nextbudget=split(b_next,",")
nextactual=split(a_next,",")

lastbudget=split(b_last,",")
lastactual=split(a_last,",")

' for ctr= 0 to Ubound(budget)
'  response.write("budget(" & ctr + 1 & ")=" & budget(ctr) & "<BR>")
'  response.write("actual(" & ctr + 1 & ")=" & actual(ctr) & "<BR>")
'  response.write("nextbudget(" & ctr + 1 & ")=" & nextbudget(ctr) & "<BR>")
'  response.write("nextactual(" & ctr + 1 & ")=" & nextactual(ctr) & "<BR>")
'  response.write("lastbudget(" & ctr + 1 & ")=" & lastbudget(ctr) & "<BR>")
'  response.write("lastactual(" & ctr + 1 & ")=" & lastactual(ctr) & "<BR>")
' next
'response.end
%>
<HTML xmlns:MMflash>
<?IMPORT namespace="MMflash" implementation="../swf/bargraph/bar_graph.htc">
<html>
<head>
 <Title>Charts and graphs</Title>

 <SCRIPT LANGUAGE="VBSCRIPT">
 Sub pop_up
  Set  msgform=document.item_status
    if msgform.item.value=chr(254) then
       msgbox "Item Not Found"  & vbCrLf & msgform.baditem.value ,vbInformation,"Search Result"
    end if
 End Sub
 </SCRIPT>
</head>
<body>
<H1 align=center>General Ledger <%=itemtoget%></H1>

<!--#include file="Inc_home.asp"-->
<TABLE ALIGN="LEFT" WIDTH="100%" BORDER="1" CELLSPACING="0" CELLPADDING="0">
  <TR><TD>
<MMflash:bargraph id="sna3" width="360" height="320" label="Last Year (<%=lastyr%>)">
 <%for ctr= 0 to Ubound(budget)%>
   <param value="<%=lastactual(ctr)%>" color="red" label="Actual" />
   <param value="<%=lastbudget(ctr)%>" color="blue" label="Budget" />
<%next%>
</MMflash:bargraph>
  <TD>
<MMflash:bargraph id="sna1" width="360" height="320" label="This Year (<%=thisyr%>)">
 <%for ctr= 0 to Ubound(budget)%>
   <param value="<%=actual(ctr)%>" color="red" label="Actual" />
   <param value="<%=budget(ctr)%>" color="blue" label="Budget" />
<%next%>
</MMflash:bargraph>
  <TD>
<MMflash:bargraph id="sna2" width="360" height="320" label="Next Year (<%=nextyr%>)">
 <%for ctr= 0 to Ubound(budget)%>
   <param value="<%=nextactual(ctr)%>" color="red" label="Actual" />
   <param value="<%=nextbudget(ctr)%>" color="blue" label="Budget" />
<%next%>
</MMflash:bargraph>
</TABLE>

<FORM name="item_status">
  <INPUT TYPE=hidden NAME="item" VALUE="<%= found%>">
  <INPUT TYPE=hidden NAME="baditem" VALUE="<%= baditem%>">
</FORM>

</body>
</html>
