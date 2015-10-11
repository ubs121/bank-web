<% 
response.expires = 0 
response.buffer=true
%>
<HTML>
<HEAD>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
validated = Request.Querystring("validated")
sentence = Request.Querystring("sentence")
sentence=replace(sentence,"""",chr(8))
logentry = session("logentry")
Dim  years, defyr, defmths, cka_gl
Set cka_gl = CreateObject("cka_gl.gl")
temp = cka_gl.check_budget_status(Cstr(logentry))
Set cka_gl = Nothing
'response.write("<BR>temp = " & temp)
'response.end
If temp = "" Then
	Result = "This procedure copies the Budget from the General Ledger to the Budget Table, where it is held as the"
	Result = Result & "<BR>Adopted Budget. Once this has been done, NO further changes may be made to the Adopted Budget."
	Result = Result & "<BR>Any future changes are only reflected in the Operational Budget"
Else
	Result = "The Budget Has Already been Adopted on " & temp
	Result = Result & "<BR>No further Changes Are allowed to the Adopted Budget."
End If
%>
<SCRIPT LANGUAGE="JavaScript">
 //*******************************************************************
  function AdoptBudget(logentry)
 {
//     var passparams, params;
  
//  passparams=document.all("after");
//  params=passparams.value;
  {
//  alert(logentry)
//  alert(params)
  
     while (RSAspProxyApplet.readyState != 4) {}
     ASPpage = RSGetASPObject("/prospect/asp/DllCalls.asp");
     co=ASPpage.AdoptBudget(logentry);
     newlist=co.return_value;
//	 alert(newlist)
	 return newlist
  }
 }
//***************************************************************************

 </SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/rs.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">RSEnableRemoteScripting("/prospect/java");</SCRIPT>
<SCRIPT LANGUAGE="JavaScript1.2" SRC="/prospect/jscript/clear.js"></SCRIPT>
<SCRIPT LANGUAGE="VBSCRIPT" SRC="/prospect/jscript/validate.js"></SCRIPT>
<SCRIPT LANGUAGE="VBSCRIPT">
'**************************************************************************'
Dim Excel,ExcelBook,Wsheet,excel_name, xlNormal
Dim iassetForm, dataForm,AM,VM,SVM,DoAll

DoAll = 0 
xlnormal = -4143
AM = chr(254)
VM = chr(253)
SVM = chr(252)
BS = Chr(8)
'**************************************************************************
Sub Process_Click()
If document.assetdata.confirm.value <> "Yes" Then
	MsgBox "To Process , You must enter 'Yes' in the TextBox"
	Exit Sub
End If
Reply = AdoptBudget(document.assetdata.logentry.value)
MsgBox Reply
End Sub
'*************************************************************************
</script>
</HEAD>

<BODY >

<FORM ACTION="/prospect/asp/BudgetLoad.asp" METHOD="POST" NAME="assetdata"  ENCTYPE="multipart/form-data">
<input type="hidden" name="before" value="">
<input type="hidden" name="after" value="">
<input type="hidden" name="validated" value="">
<input type="hidden" name="logentry" value="<%=Session("logentry")%>">
<input type="hidden" name="path" value="/prospect_site/budget/">
<input type="hidden" name="AttachColumnId" value="Attachment">
<input type="hidden" name="file" value="">
<input type="hidden" name="trans_rec" value="">
<input type="hidden" name="d3needed" value="<%=Session("d3needed")%>">
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>
<P align=center><FONT face="Microsoft Sans Serif">
<font color="red" ><%=Result%></font> 
</FONT></P>

<% If temp = "" Then %>
<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TD CLASS="mm"><B>Enter "Yes" to Continue</B>
<TD><input type="Text" ID="Confirm" align="LEFT" >
</TABLE>

<TABLE align="center">
<TR>
<TH align=CENTER>
<input type="button" name="Process" value="Process" width="2100" height="700" onclick='Process_Click()'>

</TABLE>
<% End If%>
</FORM>


</BODY>
</HTML>

