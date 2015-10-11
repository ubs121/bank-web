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
'GenexOpts = PickLin.make_options(session("logentry"),"GENEX","",cstr(yrtouse),Session("d3needed"),Server.MapPath("\prospect\template\"),"")
%>
<TITLE>Print Invoice in WORD</TITLE>
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
'**************************************************************************'
Function ShowWrkBkList(Document)

Dim FSI, i, the_file, the_rec, Infile, Ts, Pos1, Pos2,NLen,WrkBookName
Dim  WrkSheetName(), WrkSheetVal(), temp, NoOpts, WSN, WSV, FileMessage
excel_name = Document.assetdata.Attachment.value
If IsObject(Excel) Then Set Excel = Nothing
Set Excel = CreateObject("Excel.Application")
Set ExcelBook = Excel.Workbooks.Open(excel_name)
Document.assetdata.sheetpath.value = excel_name
End Function

'*************************************************************************
Sub Process_Click()

dim word_name

Word_name = "c:\ckashare\debtors\invoice_SP.doc"
If IsObject(Word) Then Set Word = Nothing
Set Word = CreateObject("Word.Application")
Word.Documents.Open(Word_name)
Word.Visible = true
Word.Documents.Open(Word_name)
Word.Application.PrintOut
Word.Application.Quit

End Sub
'*************************************************************************'
</SCRIPT>

</HEAD>

<BODY onunload='UnloadSheet()'>

<FORM ACTION="/prospect/asp/GenexLoad.asp" METHOD="POST" NAME="assetdata" ENCTYPE="multipart/form-data" >
<input type="hidden" name="logentry" value="<%=Session("logentry")%>">
<input type="hidden" name="before" value="">
<input type="hidden" name="after" value="">
<input type="hidden" name="reportname" value="<%=Request.Querystring("reportname")%>">
<input type="hidden" name="AttachColumnId" value="Attachment">
<input TYPE="hidden" NAME="MonthEnds" VALUE="<%=monthends%>">
<input TYPE="hidden" NAME="StoResult" VALUE="<%=result%>">
<input type="hidden" name="sheetpath" value="">
<TABLE WIDTH="100%" border="1" cellspacing="1" cellpadding="1"> 
<TR CLASS="top">
<TH colspan=4><%=Request.Querystring("reportname")%>
<TR>
</TABLE>
<TABLE WIDTH="100%" border="1" cellspacing="1" cellpadding="1"> 

<TD CLASS="mm"><B>For month ending </B>
<TD>
<select class="smallsel" name="MonthEnding">
<%
response.write(monthdates)
%>
</select>

</TABLE>
<BR>
</FORM>
<FORM ACTION="/prospect/asp/GenexLoad.asp" METHOD="POST" NAME="assetform">

<TABLE align="center">

<TR>
<TR>
<TH align=CENTER>
<input type="button" name="Process" value="Process" width="2100" height="700" onclick='Process_Click()'>
<TH align=CENTER>
<input type="button" name="Clear" value="Clear" width="2100" height="700" onclick='Clear_Click()'></TABLE>

</FORM>

</BODY>
</HTML>

