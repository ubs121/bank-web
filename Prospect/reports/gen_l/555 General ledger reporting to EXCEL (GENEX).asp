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

Dim temp, years, defyr, defmths,monthdates
monthdates = PickLin.make_options(session("logentry"),"GLMONTHENDS","",cstr(yrtouse),Session("d3needed"),Server.MapPath("\prospect\template\"),"")
'response.write(monthdates)
'response.end
GenexOpts = PickLin.make_options(session("logentry"),"GENEX","",cstr(yrtouse),Session("d3needed"),Server.MapPath("\prospect\template\"),"")
%>
<TITLE>General Ledger Reporting to Excel (GENEX)</TITLE>
<SCRIPT LANGUAGE="JavaScript">
 //*******************************************************************
  function GetSheetData(logentry,params,msa)
 {
//     var passparams, params;
  
//  passparams=document.all("after");
//  params=passparams.value;
  {
//  alert(logentry)
//  alert(params)
  
     while (RSAspProxyApplet.readyState != 4) {}
     ASPpage = RSGetASPObject("/prospect/asp/DllCalls.asp");
     co=ASPpage.GetSheetData(logentry,params);
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

DoAll = 0 
xlnormal = -4143
AM = chr(254)
VM = chr(253)
SVM = chr(252)
DQ = Chr(34)
'**************************************************************************'
Sub DisableButtons
Dim htmlStr,i
document.assetform.Process.Disabled = True
document.assetform.ProcessAll.Disabled = True
DDOptions = Split(document.assetdata.GenexOpts.value, AM)
i = Ubound(DDOptions)
PopulateOptions DDOptions, i
End Sub
'**************************************************************************'
Sub PopulateOptions(arrOptions, intNumber)

Dim objOption, i
Document.assetdata.ValRequired.length = 0
For i = 1 to intNumber
	Set objOption = document.CreateElement("OPTION")
	objOption.Value = i
	objOption.Text = arrOptions(i)
	Document.assetdata.ValRequired.add objOption
	Set objOption = Nothing
Next
End Sub
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
Sub PopulateSheetName(arrOptions, arrVals, intNumber)

Dim objOption, i
Document.assetdata.WorkSheetName.length = 0
For i = 1 to intNumber
	Set objOption = document.CreateElement("OPTION")
	objOption.Value = arrVals(i)
	objOption.Text = arrOptions(i)
	Document.assetdata.WorkSheetName.add objOption
	Set objOption = Nothing
Next
End Sub
'**************************************************************************
Sub GetPrefs(Wsheet)
Dim Result,temp,i,j
Dim Rows, Cols, CellVal, StoAfter, StoResult
Set ExcelSheet = ExcelBook.WorkSheets(Wsheet)
On Error Resume Next
temp = ""
temp = ExcelSheet.Cells(1,"A").Comment.Text
'Msgbox temp
Result = Split(temp,AM)
SelCnt = 0
ReDim ColIds(0)
ReDim ColSelections(0)
For i = 0 to Ubound(Result)
	If Result(i) <> "0"  And Result(i) <> "" Then
		j = Result(i)
	    SelCnt = SelCnt + 1
		Redim Preserve ColIds(SelCnt+1)
		Redim Preserve ColSelections(SelCnt+1)
		ColIds(SelCnt) = chr(65+i)
		ColSelections(SelCnt) = j
	End If
Next
UpdateColVals
document.assetform.Process.Disabled = False
document.assetform.ProcessAll.Disabled = False
End Sub
'*************************************************************************'
Sub UpDateColVals()
Dim i,htmlStr

htmlStr = "<TABLE width=30% align=center border=1 cellspacing=1 cellpadding=1 columns=2>"
htmlStr = htmlStr & "<TR class=top><TH width=" & DQ & "5%" & DQ & " align=left colspan=1>Column</TH><TH width=" & DQ & "25%" & DQ & ">Value</TH>"
htmlStr = htmlStr & "<TR>"
For i = 1 to Ubound(ColSelections)-1
	htmlStr = htmlStr & "<TD>" & ColIds(i) & "</TD>"
	htmlStr = htmlStr & "<TD>" & DDOptions(ColSelections(i)) & "<TR>"
Next
htmlStr = htmlStr & "</TABLE>"
document.all.expanding.innerHTML = htmlStr	

End Sub
'*************************************************************************'
Sub AddField()
Dim temp
temp = Ucase(document.assetdata.ColumnId.value)
If Asc(temp) < 65 or Asc(temp) > 91 Then
	Msgbox "Column Must be in Range A-Z"
	Exit Sub
End If
SelCnt = SelCnt + 1
ReDim Preserve ColSelections(SelCnt+1)
ReDim Preserve ColIds(SelCnt+1)
ColSelections(SelCnt) = document.assetdata.ValRequired.value
ColIds(SelCnt) = temp
UpdateColVals
End Sub
'*************************************************************************'
Sub Updatesheet()
Dim Result,i,WrkBookName, Paras
Dim  WrkSheetName, WrkSheetVal, temp, NoOpts, WSN, WSV, FileMessageMyCell, X
Dim  Rows, Cols, CellVal, StoAfter, StoResult

Result = document.assetdata.StoResult.value
Paras = Split(Result, AM)
WrkSheetName = Split(Paras(0),VM)
excel_name = WrkSheetName(0)

For i = 1 to Ubound(WrkSheetName)
	Wsheet = WrkSheetName(i)
	Rows = Split(Paras(i),VM)
	For j = 0 to Ubound(Rows)
		Cols = Split(Rows(j),SVM)
		For k = 0 to Ubound(Cols)
			CellVal = Cols(k)
			If CellVal <> "" Then
				Set ExcelSheet = ExcelBook.WorkSheets(Wsheet)
				ExcelSheet.Cells(j+1,chr(k+64)).Value = CellVal
			End If
		Next
	Next
Next

Excel.Application.Visible = True
End Sub
'****************************************************************************'
Sub UnloadSheet
On Error Resume Next
ExcelBook.Close 1           ' The '1' Forces the Close ie it does not prompt "Do you want to Save Changes ...."
Set Excel = Nothing
End Sub
'****************************************************************************'
Sub Clear_Click
 Dim cnt
 size=document.assetform.Elements.Length-1
 for cnt = 0 to size
    if document.assetform.Elements(cnt).type <> "" AND document.assetform.Elements(cnt).type <> "button" then document.assetform.Elements(cnt).value=""
 next
 'call LoadDropDowns
 call ChangeTags("I","","")
 ReDim ColSelections(0)
 ReDim ColIds(0)
 SelCnt = 0
End Sub
'*************************************************************************
Sub Process_Click()

   Dim wants, Fnd, i,colno, temp, WrkSheetNames, AcctSelection, ColSelection(52), FactSelection, Facts 
   Dim SheetAccts, SheetFacts, Cols, range,lastrow,accounts,after,logentry,msa, StoAfter, StoResult
   If Not IsNumeric(document.assetdata.Datesrow.value) Then
   		MsgBox "Date Row Must be Numeric"
		Exit Sub
   End If
   Set iassetForm=document.assetform
   Set dataForm=document.assetdata
   on error resume next
   wsheet = dataForm.WorksheetName.value
   Set ExcelSheet = ExcelBook.Worksheets(wsheet)
   ReDim StoAfter(63)                                   'Done to ensure compatibility with Older Style Genex
   For i = 1 to Ubound(ColSelections)-1
   		If ColSelections(i) <> "" And ColSelections <> "0" Then
        	colno = Asc(ColIds(i))-55
   			StoAfter(colno) = ColSelections(i)
		End If
   Next
   dataform.after.value = Join(StoAfter,AM)
   Fnd = 0
   For i = 10 to 62
   		temp = StoAfter(i)
   		If temp <> "0" And temp <> ""  Then
			Fnd = 1
			Exit For
		End If
   Next
   If Fnd <> 1 And DoAll <> 1 Then
   		Msgbox "No Columns Have Been Selected !"
		Exit Sub
   End If
   If Fnd = 1 Then
   		StoResult = StoAfter(10)                   
   		For i = 1 to 51
			StoResult = StoResult & AM & StoAfter(i+10)
   		Next
   		ExcelSheet.Range("A1").ClearComments              ' Save the Current Worksheet Preferences'
   		ExcelSheet.Range("A1").AddComment StoResult
   		ExcelBook.Save
   End If
   If DoAll = 1 Then                                      ' Means "Process All" was clicked
   		For Each wsheet in ExcelBook.Worksheets
   			temp = ""
			On Error Resume Next
			temp = wsheet.Cells(1,"A").Comment.Text
			If temp <> "" Then
				If WrkSheetNames = "" Then
					WrkSheetNames = wsheet.name
				Else
					WrkSheetNames = WrkSheetNames & VM & wsheet.name
				End If
   				wants = Split(AM & temp,AM)
   				Fnd = 0                                    ' Find the Acct Numbers
   				colno = 0
   				Do Until Fnd = 1 Or colno = Ubound(wants)
   	  				colno = colno + 1
	  				If wants(colno) = "1" Then Fnd = "1"
   				Loop
   				If Fnd = "1" Then
      				Set range = wsheet.UsedRange
      				lastrow = range.Rows.Count
      				Redim Accounts(lastRow + 1)
      				For i = 1 to lastrow
	      				Accounts(i-1) = wsheet.Cells(i,Chr(colno+64)).Value
      				Next
					SheetAccts = Join(Accounts,SVM)
				Else
					SheetAccts = VM
				End If
				If AcctSelection = "" Then
      				AcctSelection = SheetAccts
				Else
					AcctSelection = AcctSelection & VM & SheetAccts
				End If
   				Fnd = 0                                     ' Find the Multiply-By Factors
   				colno = 0
   				Do Until Fnd = 1 Or colno = Ubound(wants)
   	  				colno = colno + 1
	  				If wants(colno) = "2" Then Fnd = "1"
   				Loop
   				If Fnd = "1" Then
      				Set range = wsheet.UsedRange
      				lastrow = range.Rows.Count
      				Redim Factors(lastRow + 1)
      				For i = 1 to lastrow
	      				Factors(i-1) = wsheet.Cells(i,Chr(colno+64)).Value
      				Next
					SheetFacts = Join(Factors,SVM)
				Else
					SheetFacts = VM
				End If
				If FactSelection = "" Then
      				FactSelection = SheetFacts
				Else
					FactSelection = FactSelection & VM & SheetFacts
				End If
				For i = 0 to 51
					If ColSelection(i) = "" Then
						ColSelection(i) = wants(i+1)
					Else
						ColSelection(i) = ColSelection(i) & VM & wants(i+1)
					End If
				Next
			End If
   		Next
		Cols = String(10,AM) & Join(ColSelection,AM)
   Else
   		WrkSheetNames = dataform.WorkSheetName.value
		wants = Split(dataForm.after.value,AM)
   		Fnd = 0
   		colno = 9
   		Do Until Fnd = 1 Or colno = Ubound(wants)
   	  		colno = colno + 1
	  		If wants(colno) = "1" Then Fnd = "1"
   		Loop
   		If Fnd = "1" Then
	  		wsheet = dataForm.WorksheetName.value
      		Set ExcelSheet = ExcelBook.Worksheets(wsheet)
      		Set range = ExcelSheet.UsedRange
      		lastrow = range.Rows.Count
      		Redim Accounts(lastRow + 1)
      		For i = 1 to lastrow
	      		Accounts(i-1) = ExcelSheet.Cells(i,Chr(colno+55)).Value
      		Next
      		AcctSelection = Join(Accounts,SVM)
   		End If
   		Fnd = 0
   		colno = 9
   		Do Until Fnd = 1 Or colno = Ubound(wants) 
   	  		colno = colno + 1
	  		If wants(colno) = "2" Then Fnd = "1"
   		Loop
   		If Fnd = "1" Then
	  		wsheet = dataForm.WorksheetName.value
      		Set ExcelSheet = ExcelBook.Worksheets(wsheet)
      		Set range = ExcelSheet.UsedRange
      		lastrow = range.Rows.Count
      		Redim Factors(lastRow + 1)
      		For i = 1 to lastrow
	      		Factors(i-1) = ExcelSheet.Cells(i,Chr(colno+55)).Value
      		Next
      		FactSelection = Join(Factors,SVM)
   		End If
		Cols = dataForm.after.value
   End If
   after = AM & WrkSheetNames & AM & FactSelection & AM & dataform.MonthEnding.value & AM & dataform.Datesrow.value & AM & AcctSelection & Cols
'  Msgbox "after = " & after
'   logentry = AM & "logis" & AM & "dm" & AM & ""
   logentry = document.assetdata.logentry.value
'   Msgbox "logentry = " & logentry
'   Exit Sub
   temp = GetSheetData(logentry,after,msa)
'   MsgBox "temp = " & temp
   document.assetdata.StoResult.value = temp
   Updatesheet
   DoAll = 0
   document.assetform.Process.disabled = True
   document.assetform.ProcessAll.disabled = True    
End Sub
'*************************************************************************
Sub ProcessAll_Click()
DoAll = 1
Process_Click
End Sub
'*************************************************************************'
</SCRIPT>

</HEAD>

<BODY onload='DisableButtons()' onunload='UnloadSheet()'>

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
<TABLE WIDTH="100%" border="1" cellspacing="1" cellpadding="1"> 
<TR CLASS="top">
<TH colspan=4><%=Request.Querystring("reportname")%>
<TR>
</TABLE>
<TABLE WIDTH="100%" border="1" cellspacing="1" cellpadding="1"> 

 <TD CLASS="mm"><B>Select Excel Work-Book:</B>
 <TD><input class="smalltxt" type="file" name="Attachment" value="" align="LEFT" size="50" onpropertychange=ShowWrkBkList(document)>
 
<TD CLASS="mm"><B>WorkSheet</B>
<select name="WorkSheetName" width="50" onchange='GetPrefs(document.assetdata.WorkSheetName.value)'>
</select>
</TABLE>
<TABLE WIDTH="100%" border="1" cellspacing="1" cellpadding="1">

<TD CLASS="mm"><B>For month ending </B>
<TD>
<select class="smallsel" name="MonthEnding">
<%
response.write(monthdates)
%>
</select>

<TD CLASS="mm"><B>Dates row</B>
<TD><input type="Text" class="smalltxt" name="Datesrow" value="<%=DatesRow%>" align="LEFT">

</TABLE>
<TABLE WIDTH="100%" border="1" cellspacing="1" cellpadding="1"> 


<TD CLASS="mm"><B>Column</B><TD>
<TD><input type="Text" class="smalltxt" name="ColumnId" align="LEFT">
<TD CLASS="mm"><B>Column Data</B><TD>
<TD>
<select class="smallsel" name="ValRequired">
</select>
<TD>
<input type="button" name="AddColumn" value="Add Column" width="2100" height="700" onClick="AddField()">
</TABLE>
<BR>
</FORM>
<FORM ACTION="/prospect/asp/GenexLoad.asp" METHOD="POST" NAME="assetform">

<%'this is where the expandable table goes - written to in UpdateColVals%>
<I id=expanding></I>

<TABLE align="center">

<TR>
<!--#include virtual= "/prospect/asp/inc_Genex_buttons.asp"-->
</TABLE>

</FORM>

</BODY>
</HTML>

