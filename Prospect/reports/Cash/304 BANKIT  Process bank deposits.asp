<% 
response.expires = 0 
response.addHeader "pragma", "no-cache"
response.cachecontrol = "public"
%>
<HTML>
<HEAD>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
result = Request.Querystring("result")
sentence = Request.Querystring("sentence")
sentence=replace(sentence,"""",chr(8))


erroruploadfile=Request.QueryString("erroruploadfile")
filetypes=Request.QueryString("filetypes")
DepositNumber=Request.QueryString("DepositNumber")

DepStatus="Disabled"

If DepositNumber <>"" then
   DepositLink="/prospect/asp/bi.asp?fn=dict%20cash&tn=cash_deposit&sn=Cash%20Deposits&hn=Cash%20Deposits&who=searchasp&item=" & DepositNumber
   DepStatus=""
End if
 
%>
<TITLE>304 BankIt</TITLE>
<SCRIPT LANGUAGE="JavaScript">
//*********************************************************************************************************
var toggle=0;
function check_uploaderror(errordescription,filetypes)
{
   if(errordescription!="")
    {
     
     if(toggle==0)
       {
        alert(errordescription + "\n" + filetypes);
        toggle=!toggle;
        history.back();
       }
    }
}
//*********************************************************************************************************
function validate(bankit)
{
 if(bankit.Attachment.value==""){alert("BankIt File Name Required");bankit.Attachment.focus();return;}
 if(!check_conforms(bankit.DepositNumber.value)){alert("Deposit Number Required");bankit.DepositNumber.focus();return;}
 bankit.submit();
}
//*********************************************************************************************************
function check_conforms(number)
 {
  len= number.length;
  pdigits= new String(number);

   for(var y=0;y<len;y++)
      {
       ok=isvalid(pdigits.charAt(y),"depositnumber");
       if(!ok)return false;
      }
  return true;
 }
//*********************************************************************************************************
function isvalid(character,field)
 {
  if(field=="depositnumber")digits= new Array('0','1','2','3','4','5','6','7','8','9');
  for(var x=0;x<digits.length;x++){if(character==digits[x])return true;}
  return false;
 }
//*********************************************************************************************************
</SCRIPT>
<SCRIPT LANGUAGE="VBSCRIPT">
Sub setupinputbox
	document.forms.verify.Username.select
end sub
</SCRIPT>
</HEAD>

<BODY onload='check_uploaderror(document.all.erroruploadfile.value,document.all.filetypes.value);'>
 <input TYPE="hidden" NAME="erroruploadfile" VALUE="<%=erroruploadfile%>">
 <input TYPE="hidden" NAME="filetypes" VALUE="<%=filetypes%>">
 

<FORM name=item_status>
<INPUT TYPE=hidden NAME=item VALUE="<%= found%>">
<INPUT TYPE=hidden NAME=baditem VALUE="<%= baditem%>">
</FORM>

<FORM ACTION="/prospect/asp/BankIt.asp" METHOD="POST" NAME="bankit" ENCTYPE="multipart/form-data">
<input type="hidden" name="sentence" value="<%=sentence%>">
<input type="hidden" name="reportname" value="<%=Request.Querystring("reportname")%>">
<input type="hidden" name="template" value="<%=Request.Querystring("template")%>">
<input type="hidden" name="path" value="/prospect_site/Bankit/">
<input type="hidden" name="AttachColumnId" value="Attachment">
<%
'parameters=Request.cookies("TA304")("parms")
'parms=split(parameters,chr(8))
'redim preserve parms(10)
todaydate=right("0" & day(date),2) & right("0" & month(date),2) & right(year(date),2) & "0" 'formatdatetime(date,vbshortdate
items = PickLin.make_options(session("logentry"),"BANKS", "")

' reading banks.ini to get this information
'[which_debtors]
'1=all
 
   readpath="/prospect_site/Bankit/banks.ini"
   f_which_debtors="": found=false
   PhysicalPath=Server.MapPath(readpath)
   Set SessionFileObject=Server.CreateObject("Scripting.FileSystemObject")
   if SessionFileObject.FileExists(PhysicalPath) then
      Set SessionTextFile=SessionFileObject.OpenTextFile(PhysicalPath)
      DO WHILE NOT SessionTextFile.AtEndofstream
       textline=SessionTextFile.ReadLine
       if textline="[which_debtors]" then 
          found=true
       else
          if found then
             if left(textline,2) = "1=" then
                f_which_debtors=mid(textline,3)
                exit do
             end if
          end if
       end if
      LOOP
      SessionTextFile.Close
   else
     	response.write("Sorry, the file " & readpath & " does not exist")
	response.end
   end if

   If f_which_debtors <> "all" Then
      f_which_debtors = "PROPERTY DEBTORS ONLY"
   Else
      f_which_debtors = "ALL DEBTORS"
   End If
%>

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>
<TR CLASS="top">
<TH colspan=2><%=response.write(f_which_debtors)%>
<TR>
 <TD CLASS="mm"><B>Locate Bank File</B>
 <TD><INPUT CLASS="smallTxt" TYPE="file" NAME="Attachment" SIZE=40>
<TR>
<TD CLASS="mm"><B>Bank Account</B>
<TD><select name="BankAccount">
<%
response.write(items)
%>

<TR>
<TD CLASS="mm"><B>Deposit Number</B>
<TD><input type="Text" name="DepositNumber" value="<%=todaydate%>" align="LEFT" size="10" maxlength="10">
<TR>
<TD colspan="2" CLASS="mm" align="CENTER">
  <INPUT TYPE="Button" NAME="Report" CLASS=smallButt VALUE="Process File" onClick='validate(document.bankit)'>
   <INPUT TYPE="Reset" NAME="Clear" CLASS=smallButt VALUE="Clear">
  <INPUT TYPE="Button" <%=DepStatus%> NAME="ShowDeposit" CLASS=smallButt VALUE="ShowDeposit" onClick='location.href="<%=DepositLink%>"'>
  <%
if result <> "" then
   result = replace(result,"_"," ")
   response.write("<TR><TD colspan=2 align=center><FONT color=""Crimson""><B>" & result & "</B></FONT>")
end if
%>
<INPUT TYPE="hidden" NAME="DepositLink" VALUE="<%=DepositLink%>">
</TABLE>
<P>
<P>Check the caption bar to see whether receipts will be processed from ALL DEBTORS or PROPERTY DEBTORS ONLY
<P>
<P>	(This setting is established by [which_debtors] in the /prospect/bank.ini item)
<P>
<P>The deposit number will default to todays date in numeric format followed by 0
(eg for 1 august 01 deposit number will defaut to 0108010)
<P>The suffixed 0 is to avoid clashes with default deposit numbers generate by programs 300 / 303 and yet make the deposit number meaningful.  It can be altered to a bank supplied deposit number, if there is one.

<P>The program will automatically detect the bank which supplied the file (see bank.ini documentation as to how this is done - users should not attempt to alter this by themselves)
</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
<FORM name=login ><INPUT TYPE=hidden NAME=status VALUE="<%= status%>"></FORM>

</BODY>
</HTML>
