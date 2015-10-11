<% 
response.expires = 0 
response.addHeader "pragma", "no-cache"
response.cachecontrol = "public"
%>
<HTML>
<HEAD>
<%
Dim result, DDOptions

StyleToUse=Session("userStyle")
response.write(StyleToUse)

%>
<TITLE>General Ledger Reporting to Excel</TITLE>
<SCRIPT LANGUAGE="JavaScript">
 //*******************************************************************
  function GetExcelData(logentry,params,msa)
 {
//     var passparams, params;
  
//  passparams=document.all("after");
//  params=passparams.value;
  {
//  alert(logentry)
//  alert(params)
  
     while (RSAspProxyApplet.readyState != 4) {}
     ASPpage = RSGetASPObject("/prospect/asp/DllCalls.asp");
     co=ASPpage.GetExcelData(logentry,params);
     newlist=co.return_value;
//	 alert(newlist)
	 return newlist
  }
 }

//*******************************************************************
 </SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/rs.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">RSEnableRemoteScripting("/prospect/java");</SCRIPT>
<SCRIPT LANGUAGE="JavaScript1.2" SRC="/prospect/jscript/clear.js"></SCRIPT>
<SCRIPT LANGUAGE="VBSCRIPT">
'**************************************************************************'
Dim Excel,ExcelBook,Wsheet,excel_name, xlNormal,SelCnt
Dim iassetForm, dataForm,AM,VM,SVM,DoAll,DQ,DDOptions,ColSelections,ColIds()
Dim CRLF,TAB,BS

DoAll = 0 
xlnormal = -4143
AM = chr(254)
VM = chr(253)
SVM = chr(252)
DQ = Chr(34)
BS = Chr(8)
TAB = Chr(9)
CRLF = Chr(13) & Chr(10)
'**************************************************************************'
Function ShowWrkBkList(Document)

Dim FSI, i, the_file, the_rec, Infile, Ts, Pos1, Pos2,NLen,WrkBookName
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
PopulateSheetName WrkSheetName, WrkSheetVal, NoOpts
Document.assetdata.sheetpath.value = excel_name
Wsheet = document.assetdata.WorkSheetName.value
GetPrefs(Wsheet)
End Function
'**************************************************************************'

Sub Updatesheet()
Dim Result,i,WrkBookName, Paras
Dim  WrkSheetName, WrkSheetVal, temp, NoOpts, WSN, WSV, FileMessageMyCell, X
Dim  Row, Cols, CellVal, StoAfter, StoResult, NoRows,NoCols,FSO,Lev,Colours(8)

Colours(1) = 37
Colours(2) = 34
Colours(3) = 35
Colours(4) = 36
'Msgbox "Here!"
If IsObject(Excel) Then Set Excel = Nothing
Set Excel = CreateObject("Excel.Application")
Set ExcelBook = Excel.Workbooks.Add
'Excel.Application.Visible = True
'Exit Sub
Paras = Split(document.assetdata.StoResult.value,BS)
Result = Paras(0)
'Msgbox "Paras(1) = " & Paras(1)
Set FSO = CreateObject("Scripting.FileSystemObject")
Set My_File = FSO.CreateTextFile("C:\temp\testjunk","True")
My_File.Write(Result)
My_File.Close
Set FSO = Nothing
Wsheet = "sheet1"
Set ExcelSheet = ExcelBook.WorkSheets(Wsheet)
Conn = "TEXT;C:\Temp\testjunk"
Dest = "Range(" & DQ & "A1" & DQ & ")"
With Excelsheet.QueryTables.Add("TEXT;C:\Temp\testjunk.",ExcelSheet.Range("A1"))
	.Name = "testjunk."
    .FieldNames = True
    .RowNumbers = False
    .FillAdjacentFormulas = False
    .PreserveFormatting = True
    .RefreshOnFileOpen = False
    .RefreshStyle = 1 'xlInsertDeleteCells
    .SavePassword = False
    .SaveData = True
    .AdjustColumnWidth = False
    .RefreshPeriod = 0
    .TextFilePromptOnRefresh = False
    .TextFilePlatform = 2 'xlwindows
    .TextFileStartRow = 1
    .TextFileParseType = 1 'xlDelimited
    .TextFileTextQualifier = -4142 'xlTextQualifierDoubleQuote
    .TextFileConsecutiveDelimiter = False
    .TextFileTabDelimiter = True
    .TextFileSemicolonDelimiter = False
    .TextFileCommaDelimiter = False
    .TextFileSpaceDelimiter = False
    .TextFileColumnDataTypes = Array(2, 9, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, _
     1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 _
     , 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
    .Refresh False
End With
'Excel.Application.Visible = True
With Excelsheet.Outline
    .AutomaticStyles = False
    .SummaryRow = 0
    .SummaryColumn = -4131
End With
Grps = Split(Paras(1),CRLF)
For i = 0 to Ubound(Grps)
	If Grps(i) <> "" Then
		temp = Split(Grps(i),TAB)
		If Cint(temp(0)) <> Cint(temp(1)) Then
			If Cint(temp(1)) = 0 Then temp(1) = temp(0)
    		Excelsheet.Rows(temp(0) & ":" & temp(1)).Group
			Row = temp(0) - 1
		Else
			Row = temp(1)
		End If
		Lev = temp(2)
		Loc = "A" & Row & ":B" & Row
		Shade = Colours(Lev)
		Excelsheet.Range(Loc).Select
		With Excel.Selection.Interior
    		.ColorIndex = Shade
    		.Pattern = 1
		End With
	End If
Next
Excelsheet.Columns("A:A").EntireColumn.AutoFit
Excelsheet.Columns("B:B").EntireColumn.AutoFit
Excelsheet.Rows("1:1").Select
Excel.Selection.RowHeight = 15.75
With Excel.Selection.Interior
    .ColorIndex = 7
    .Pattern = 1
End With
Excel.Selection.Font.ColorIndex = 2
Excel.Selection.Font.Bold = True
Excelsheet.Range("C2").Select
Excel.ActiveWindow.FreezePanes = True
Excelsheet.Columns("D:K").Select
Excel.Selection.Columns.Group
Excelsheet.Range("C2").Select
'ExcelSheet.Outline.ShowLevels 
'Excel.Activesheet.RowLevels =1
Excel.Application.Visible = True
End Sub
'***************************************************************************'
Sub UnloadSheet
On Error Resume Next
ExcelBook.Close 1           ' The '1' Forces the Close ie it does not prompt "Do you want to Save Changes ...."
Set Excel = Nothing
End Sub
'****************************************************************************'
Sub Process_Click()

   Dim wants, Fnd, i,colno, temp, WrkSheetNames, AcctSelection, ColSelection(52), FactSelection, Facts 
   Dim SheetAccts, SheetFacts, Cols, range,lastrow,accounts,after,logentry,msa, StoAfter, StoResult


   Set dataForm=document.assetdata


'   Set ExcelSheet = ExcelBook.Worksheets(wsheet)
  
   logentry = document.assetdata.logentry.value
   temp = GetExcelData("<%=Session("the_drive")%>",after,msa)
'   MsgBox "temp = " & temp
   document.assetdata.StoResult.value = temp
   Updatesheet
   DoAll = 0
 End Sub
'*************************************************************************
</SCRIPT>

</HEAD>

<BODY>

<FORM ACTION="/prospect/asp/GenexLoad.asp" METHOD="POST" NAME="assetdata" ENCTYPE="multipart/form-data" >
<input type="hidden" name="logentry" value="<%=Session("logentry")%>">
<input type="hidden" name="before" value="">
<input type="hidden" name="after" value="">
<input type="hidden" name="reportname" value="<%=Request.Querystring("reportname")%>">
<input type="hidden" name="AttachColumnId" value="Attachment">
<input TYPE="hidden" NAME="MonthEnds" VALUE="<%=monthends%>">
<input TYPE="hidden" NAME="StoResult" VALUE="<%=result%>">
<input TYPE="hidden" NAME="GenexOpts" VALUE="<%=GenexOpts%>">
<input type="hidden" name="sheetpath" value="">
<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>
<TABLE align="center" border="1" cellspacing="1" cellpadding="1"> 
<TR CLASS="top">
<TH colspan=4>Excel Explorer
<TR>
</TABLE>
 


<TABLE align="center">
<TR>
<TH align=CENTER>
<input type="button" name="Process" value="Process" width="2100" height="700" onclick='Process_Click()'>
</TABLE>

</FORM>

</BODY>
</HTML>

