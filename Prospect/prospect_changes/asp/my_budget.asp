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
Dim temp, years, defyr, defmths
temp = PickLin.make_options(session("logentry"),"GLYEARSMONTHS","",cstr(yrtouse),Session("d3needed"),Server.MapPath("\prospect\template\"),"")
par = split(temp,chr(254))
years = par(0)
%>
<SCRIPT LANGUAGE="JavaScript">
 //*******************************************************************
  function UpdBudgets(logentry,params,d3needed,Reference)
 {
//     var passparams, params;
  
//  passparams=document.all("after");
//  params=passparams.value;
  {
//  alert(logentry)
//  alert(params)
  
     while (RSAspProxyApplet.readyState != 4) {}
     ASPpage = RSGetASPObject("/prospect/asp/DllCalls.asp");
     co=ASPpage.UpdBudgets(logentry,params,d3needed,Reference);
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
Sub DisableButtons
document.assetform.Process.Disabled = True
End Sub
'**************************************************************************'
Function ShowWrkBkList(Document)

Dim  WrkSheetName(), WrkSheetVal(), temp, NoOpts, WSN, WSV, FileMessage

excel_name = Document.assetdata.Attachment.value
If IsObject(Excel) Then Set Excel = Nothing
Set Excel = CreateObject("Excel.Application")
Set ExcelBook = Excel.Workbooks.Open(excel_name)
NoOpts = 0
For Each Wsheet in ExcelBook.Worksheets
    NoOpts = NoOpts + 1
	Redim Preserve WrkSheetName(NoOpts)
	Redim Preserve WrkSheetVal(NoOpts)
	WrkSheetName(NoOpts) = Wsheet.Name
	WrkSheetVal(NoOpts) = Wsheet.Name
Next
'Excel.Application.Windowstate = xlNormal
PopulateSheets WrkSheetName, WrkSheetVal, NoOpts
Document.assetdata.WorkSheet.Options(0).selected = True
Wsheet = document.assetdata.WorkSheet.value
GetPrefs(Wsheet)
End Function
'**************************************************************************
Sub PopulateSheets(arrOptions, arrVals, intNumber)

Dim objOption, i
Document.assetdata.WorkSheet.length = 0
For i = 1 to intNumber
	Set objOption = document.CreateElement("OPTION")
	objOption.Value = arrVals(i)
	objOption.Text = arrOptions(i)
	Document.assetdata.WorkSheet.add objOption
	Set objOption = Nothing
Next
End Sub
'**************************************************************************
Sub GetPrefs(Wsheet)
Dim Result,temp
Dim Rows, Cols, CellVal, StoAfter, StoResult
Set ExcelSheet = ExcelBook.WorkSheets(Wsheet)
On Error Resume Next
temp = ""
temp = ExcelSheet.Cells(1,"B").Comment.Text
Result = Split(temp,BS)
document.assetform.FinYear.value = Result(0)
document.assetform.AcctCol.value = Result(1)
document.assetform.StRow.value = Result(2)
document.assetform.EndRow.value = Result(3)
document.assetform.StCol.value = Result(4)
document.assetform.EndCol.value = Result(5)
document.assetform.Process.Disabled = False
End Sub
'***************************************************************************
Sub Process_Click()
   Dim FirstRow, LastRow, FirstCol, LastCol, RowRange, ColRange, AcctCnt 
   Dim wants, Fnd, i, j, colno, temp, WrkSheetNames, AcctSelection, ColVals, BudgetVals
   Dim SheetAccts, SheetFacts, Cols, range,accounts(),after,logentry,msa, StoAfter, StoResult
  
   Set iassetForm=document.assetform
   Set dataForm=document.assetdata
   error = save_form_Data(0)
   if error = "1" then exit Sub
   VM = Chr(253)                                  'validate.js screws up these values
   SVM = Chr(252)
'   on error resume next
   dataForm.validated.value = "1"
   wsheet = dataForm.Worksheet.value
   StoAfter = dataForm.after.value
   Set ExcelSheet = ExcelBook.Worksheets(wsheet)
   ExcelSheet.Range("B1").ClearComments              ' Save the Current Worksheet Preferences'
   ExcelSheet.Range("B1").AddComment StoAfter
   ExcelBook.Save
   FirstRow = iassetform.StRow.value
   LastRow = iassetform.EndRow.value
   RowRange = (LastRow - FirstRow) + 1
   Colno = iassetform.AcctCol.value
   FirstCol = iassetform.StCol.value
   LastCol = iassetform.EndCol.value
   ColRange = Asc(LastCol) - Asc(FirstCol)
'   Redim Accounts(RowRange-1)
   Redim AcctVals(RowRange-1)
   ReDim ColVals(ColRange)
   AcctCnt = 0

   For i = FirstRow to LastRow
   		If ExcelSheet.Cells(i,Colno).value <> "" Then
			ReDim Preserve Accounts(AcctCnt)
			Accounts(AcctCnt) = ExcelSheet.Cells(i,Colno).Value
			For j = 0 to ColRange
				ColVals(j) = ExcelSheet.Cells(i,Chr(j + Asc(FirstCol))).value
			Next
			AcctVals(AcctCnt) = Join(ColVals,SVM)
   			AcctCnt = AcctCnt + 1
		End If
   Next
   AcctSelection = Join(Accounts,VM)
   BudgetVals = Join(AcctVals,VM)
   logentry = dataform.logentry.value
   after = iassetform.FinYear.value & AM & AcctSelection & AM & BudgetVals
   Msgbox logentry & vbCrLf & after & vbCrLf & document.assetdata.d3needed.value & vbCrLf & iassetForm.Reference.value
   temp = UpdBudgets(logentry,after,document.assetdata.d3needed.value,iassetForm.Reference.value)
   MsgBox temp
   document.assetform.Process.disabled = True
  
End Sub
'*************************************************************************
Sub UnloadSheet
On Error Resume Next
ExcelBook.Close 1           ' The '1' Forces the Close ie it does not prompt "Do you want to Save Changes ...."
Set Excel = Nothing
End Sub
'****************************************************************************'
</script>
</HEAD>

<BODY onload='DisableButtons()' onunload='UnloadSheet()'>

<FORM ACTION="/prospect/asp/BudgetLoad.asp" METHOD="POST" NAME="assetdata"  ENCTYPE="multipart/form-data">
<input type="hidden" name="before" value="">
<input type="hidden" name="after" value="">
<input type="hidden" name="validated" value="">
<input type="hidden" name="sentence" value="<%=sentence%>">
<input type="hidden" name="reportname" value="<%=Request.Querystring("reportname")%>">
<input type="hidden" name="template" value="<%=Request.Querystring("template")%>">
<input type="hidden" name="logentry" value="<%=Session("logentry")%>">
<input type="hidden" name="path" value="/prospect_site/budget/">
<input type="hidden" name="AttachColumnId" value="Attachment">
<input type="hidden" name="file" value="">
<input type="hidden" name="trans_rec" value="">
<input type="hidden" name="d3needed" value="<%=Session("d3needed")%>">
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>
<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=4><%=Request.Querystring("reportname")%>
<TR>
<TD CLASS="mm"><B>EXCEL Workbook Name</B>
<TD><input type="file" name="Attachment" align="LEFT" size="50%" onpropertychange=ShowWrkBkList(document)>
<TR>
<TD CLASS="mm"><B>WorkSheet Name</B>
<TD>
<SELECT name="WorkSheet" onchange='GetPrefs(document.assetdata.WorkSheet.value)'>
<OPTION Value="">

</SELECT>
</TABLE>
</FORM>

<FORM METHOD="POST" NAME="assetform">
<input type="hidden" name="file" value="">
<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">

<TR>
<TD CLASS="mm"><B>Accounting Year</B>
<TD><select name="1,0,0,Financial Year,,MD0" ID="FinYear" width="10">
<%
response.write(years)
%>
</select>

<TR>
<TD CLASS="mm"><B>Accounts Column</B>
<TD><input type="Text" name="C2,0,0,Accounts Column,,@A@B@C@D@E@F@G@H@I@J@K@L@M@N@O@P@Q@R@S@T@U@V@W@X@Y@Z" ID="AcctCol" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Start Row</B>
<TD><input type="Text" name="C3,0,0,Start Row,,MD0" ID="StRow" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>End Row</B>
<TD><input type="Text" name="C4,0,0,End Row,,MD0" ID="EndRow" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Start Column for Budgets</B>
<TD><input type="Text" name="C5,0,0,Start Column for Budgets,,@A@B@C@D@E@F@G@H@I@J@K@L@M@N@O@P@Q@R@S@T@U@V@W@X@Y@Z" ID="StCol" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>End Column for Budgets</B>
<TD><input type="Text" name="C6,0,0,End Column for Budgets,,@A@B@C@D@E@F@G@H@I@J@K@L@M@N@O@P@Q@R@S@T@U@V@W@X@Y@Z" ID="EndCol" align="LEFT" size="10" maxlength="10">

<TR>
<TD CLASS="mm"><B>Reference</B>
<TD><input type="Text" name="C7,0,0,Reference" ID="Reference" align="LEFT" size="55" maxlength="10">

</TABLE>

<TABLE align="center">
<TR>
<TH align=CENTER>
<input type="button" name="Process" value="Process" width="2100" height="700" onclick='Process_Click()'>
<TH align=CENTER>
<input type="button" name="Clear" value="Clear" width="2100" height="700" onclick='Clear_Click()'>


</TABLE>

</FORM>


</BODY>
</HTML>

