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

%>
<TITLE>999 Budget Upload</TITLE>
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
function validate(budget)
{
 if(budget.Attachment.value==""){alert("budget File Name Required");budget.Attachment.focus();return;}
 if(!check_conforms(budget.AccountCol.value,"AccountCol")){alert("Accounts Column Required");budget.AccountCol.focus();return;}
 if(!check_conforms(budget.SRow.value,"SRow")){alert("Start Row Must be Numeric");budget.SRow.focus();return;}
 if(!check_conforms(budget.ERow.value,"ERow")){alert("End Row Must be Numeric");budget.ERow.focus();return;}
 budget.submit();
}
//*********************************************************************************************************
function check_conforms(number,name)
 {
  len= number.length;
  pdigits= new String(number);

   for(var y=0;y<len;y++)
      {
       ok=isvalid(pdigits.charAt(y),name);
       if(!ok)return false;
      }
  return true;
 }
//*********************************************************************************************************
function isvalid(character,field)
 {
  if(field=="SRow")digits= new Array('0','1','2','3','4','5','6','7','8','9');
  if(field=="ERow")digits= new Array('0','1','2','3','4','5','6','7','8','9');
  if(field=="AccountCol")digits= new Array('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','W','X','Y','Z');
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

<FORM ACTION="/prospect/asp/BudgetLoad.asp" METHOD="POST" NAME="budget" ENCTYPE="multipart/form-data">
<input type="hidden" name="sentence" value="<%=sentence%>">
<input type="hidden" name="reportname" value="<%=Request.Querystring("reportname")%>">
<input type="hidden" name="template" value="<%=Request.Querystring("template")%>">
<input type="hidden" name="path" value="/prospect_site/budget/">
<input type="hidden" name="AttachColumnId" value="Attachment">

<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>
<TR>
 <TD CLASS="mm"><B> Excel дээрх тооцооллын хvснэгт</B>
 <TD><INPUT CLASS="smallTxt" TYPE="file" NAME="Attachment" SIZE=40>
<TR>
<TD CLASS="mm"><B>Дансны багана</B>
<TD><INPUT CLASS="smallTxt" TYPE="text" NAME="AccountCol" SIZE=10>
<TR>
<TD CLASS="mm"><B>Мєрийн эхэн</B>
<TD><input type="Text" name="SRow"  align="LEFT" size="10" maxlength="10">
<TR>
<TD CLASS="mm"><B>Мєрийн тєгсгєл</B>
<TD><input type="Text" name="ERow"  align="LEFT" size="10" maxlength="10">
<TR>
<TD colspan="2" CLASS="mm" align="CENTER">
  <INPUT TYPE="Button" NAME="Report" CLASS=smallButt VALUE="Process File" onClick='validate(document.budget)'>
   <INPUT TYPE="Reset" NAME="Clear" CLASS=smallButt VALUE="Clear">
  <%
if result <> "" then
   result = replace(result,"_"," ")
   response.write("<TR><TD colspan=2 align=center><FONT color=""Crimson""><B>" & result & "</B></FONT>")
end if
%>
<INPUT TYPE="hidden" NAME="DepositLink" VALUE="<%=DepositLink%>">
</TABLE>
</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
<FORM name=login ><INPUT TYPE=hidden NAME=status VALUE="<%= status%>"></FORM>

</BODY>
</HTML>
