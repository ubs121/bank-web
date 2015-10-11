<% 
response.expires = 0 
response.addHeader "pragma", "no-cache"
response.cachecontrol = "public"

PathToUse= Session("imagePath")
StyleToUse= Session("userStyle")
response.write(StyleToUse)

filetouse = replace(Request.Querystring("fn"),"@@PATH@@",session("the_drive"))
%>
<HTML>
<HEAD>
<%
Dim result,cnt,temp,pos,wtable,vbstuff,DQ,CRLF
Dim logentry,what,lne,ReportSets
DQ = chr(34)
CRLF = Chr(13) & Chr(10)
Set gl_dll=Server.CreateObject("cka_gl.gl")
temp=gl_dll.gl_lev_table(Cstr(filetouse),"Levels")
wtable = Split(temp,chr(8))
result = wtable(0)
temp = result
NoLevs = 0
Pos = Instr(temp,"<TR>")
Do while Pos <> 0
	If (pos+4) > len(temp) then
		temp = ""
	Else
		temp = Mid(Temp,Pos+4)
	End If
	Pos = Instr(temp,"<TR>")
	NoLevs = NoLevs + 1
Loop

vbStuff = "Dim LevDescs(8)" & CRLF
For i = 1 to Ubound(wtable)
	vbStuff = vbStuff & "LevDescs(" & Cstr(i) & ") = " & DQ & wtable(i) & DQ & CRLF
Next
temp=gl_dll.gl_lev_table(Cstr(filetouse),"ReportSets")
Set gl_dll=Nothing
If temp <> "" then
	wtable = Split(temp,chr(8))
	temp = Replace(wtable(0),DQ,"'")
	ReportSets = Replace(temp,CRLF,"")
Else
	ReportSets = ""
End If
%>
<TITLE>General Ledger Account Maintenance</TITLE>
<SCRIPT LANGUAGE="JavaScript">
 //******************************************************************
  function ValidateAccount(TableName,Account)
 {
//     var passparams, params;
  
//  passparams=document.all("after");
//  params=passparams.value;
  {
//  alert(logentry)
//  alert(params)
  
     while (RSAspProxyApplet.readyState != 4) {}
     ASPpage = RSGetASPObject("/prospect/asp/DllCalls.asp");
     co=ASPpage.ValidateAccount(TableName,Account);
     newlist=co.return_value;
//	 alert(newlist)
	 return newlist
  }
 }

//*******************************************************************
  function UpdateAccount(TableName,Accno,Before,After,action)
 {
//     var passparams, params;
  
//  passparams=document.all("after");
//  params=passparams.value;
  {
//  alert(After)
//  alert(params)
  
     while (RSAspProxyApplet.readyState != 4) {}
     ASPpage = RSGetASPObject("/prospect/asp/DllCalls.asp");
     co=ASPpage.UpdateAccount(TableName,Accno,Before,After,action);
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
Dim iassetForm, dataForm,AM,VM,SVM,DQ,CrLf,AccLev

AM = chr(254)
VM = chr(253)
SVM = chr(252)
DQ = Chr(34)
CrLf = Chr(13) & Chr(10)
BS = Chr(8)
'**************************************************************************'
Sub DisableSels
On Error Resume Next
document.all.LevInput2.Disabled = True
document.all.LevInput3.Disabled = True
document.all.LevInput4.Disabled = True
document.all.LevInput5.Disabled = True
document.all.LevInput6.Disabled = True
document.all.LevInput7.Disabled = True
document.all.LevInput8.Disabled = True
End Sub
'**************************************************************************'
Sub BuildNo(Lev)
On Error Resume Next
Dim i,htmlStr,Accno,LVals(8)
Lvals(1) = document.all.LevInput1.value
Lvals(2) = document.all.LevInput2.value
Lvals(3) = document.all.LevInput3.value
Lvals(4) = document.all.LevInput4.value
Lvals(5) = document.all.LevInput5.value
Lvals(6) = document.all.LevInput6.value
Lvals(7) = document.all.LevInput7.value
Lvals(8) = document.all.LevInput8.value
i = 1
Do While Lvals(i) <> "" and i < 9
	If i = 1 Then Accno = Lvals(1) Else Accno = Accno & "." & Lvals(i)
	i = i + 1
Loop
Do While i < 9
Select Case i
	Case 1
		document.all.LevInput2.value = ""
	Case 2
		document.all.LevInput3.value = ""
	Case 3
		document.all.LevInput4.value = ""
	Case 4
		document.all.LevInput5.value = ""
	Case 5
		document.all.LevInput6.value = ""
	Case 6
		document.all.LevInput7.value = ""
	Case 7
		document.all.LevInput8.value = ""
End Select
i = i + 1
Loop
document.all.AccountInput.value = Accno
Select Case Lev
	Case 1
		document.all.LevInput2.Disabled = False
	Case 2
		document.all.LevInput3.Disabled = False
	Case 3
		document.all.LevInput4.Disabled = False
	Case 4
		document.all.LevInput5.Disabled = False
	Case 5
		document.all.LevInput6.Disabled = False
	Case 6
		document.all.LevInput7.Disabled = False
	Case 7
		document.all.LevInput8.Disabled = False
End Select

End Sub 
'*************************************************************************'
Sub Query_Click
Dim Accno,Valid,TableName,Lev,temp,Cnt,Pos,htmlStr,tpStr
<%=vbStuff%>
On Error Resume Next
document.all.add.disabled = True
document.all.update.disabled = True
TableName = document.assetdata.stofiletouse.value
Accno = document.all.AccountInput.value
Valid = ValidateAccount(TableName,Accno)
ClearSels
If Left(Valid,2) = "OK" Then
	If Instr(Accno,".") = 0 Then
		document.all.LevInput1.value = Accno
		AccLev = 1
	Else
		temp = Accno
		Pos = Instr(temp,".")
		Lev = Left(temp,pos-1)
		Cnt = 1
		Do While Lev <> ""
			Select Case Cnt
			Case 1
				document.all.LevInput1.value = Lev
			Case 2
				document.all.LevInput2.value = Lev
				document.all.LevInput2.Disabled = False
			Case 3
				document.all.LevInput3.value = Lev
				document.all.LevInput3.Disabled = False
			Case 4
				document.all.LevInput4.value = Lev
				document.all.LevInput4.Disabled = False
			Case 5
				document.all.LevInput5.value = Lev
				document.all.LevInput5.Disabled = False
			Case 6
				document.all.LevInput6.value = Lev
				document.all.LevInput6.Disabled = False
			Case 7
				document.all.LevInput7.value = Lev
				document.all.LevInput7.Disabled = False
			Case 8
				document.all.LevInput8.value = Lev
				document.all.LevInput8.Disabled = False
			End Select
			If Pos <> 0 Then
				temp = mid(temp,Pos+1)
			Else
				temp = ""
			End If
			If temp = "" then
				Lev = ""
			Else
				Pos = Instr(temp,".")
				If Pos = 0 then
					Lev = temp
				Else
					Lev = Left(temp,Pos-1)
				End If
			End If
			Cnt = Cnt + 1
		Loop
		AccLev = Cnt - 1
	End If
	htmlStr = "<TABLE width=95% align=center border=1 cellspacing=1 cellpadding=1 columns=2>"
	testlev  = document.all.stoNoLevs.value
	If Cint(AccLev) = Cint(testlev) then
		htmlstr = htmlStr & "<TR>" & CrLf & "<TD>Account Type (A)sset,(L)iability,(I)ncome,(E)xpenditure,(O)wners' Equity"
'		htmlStr = htmlStr & "<TD><input type=" & DQ & "text" & DQ & " id=" & DQ & "AccountType" & DQ & ">" & CrLf
		htmlStr = htmlStr & "<TD> <select style=" & DQ & "WIDTH: 100%" & DQ & " Id=" & DQ & "AccountType" & DQ & "><OPTION VALUE=" & DQ & "A" & DQ & ">Asset<OPTION VALUE=" & DQ & "L" & DQ & ">Liability<OPTION VALUE=" & DQ & "I" & DQ & ">Income<OPTION VALUE=" & DQ & "E" & DQ & ">Expenditure<OPTION VALUE=" & DQ & "O" & DQ & ">Owner's Equity</select>" & CrLf
	End If
	If Cint(AccLev) > 1 Then
		htmlStr = htmlStr & "<TR><TD>Add to Description" & CrLf & "<TD><input type=" & DQ & "text" &  " length=" & DQ & "100%" & DQ & " id=" & DQ & "AddDesc" & DQ & ">" & CrLf
	End If
	htmlStr = htmlStr & "<TR><TD>Date Closed" & CrLf & "<TD><input type=" & DQ & "text" & DQ & " id=" & DQ & "ClosedDate" & DQ & ">" & CrLf
'	htmlStr = htmlStr & "<TR>" & CrLf & "<TD>Attracts GST ?" & CrLf
'	htmlStr = htmlStr & "<TD><input type=" & DQ &"checkbox" & DQ & " name=" & DQ & "GST" & DQ &  ">" & CrLf
	If AccLev > 1 And Mid(Valid,3,1) = 0 Then
		htmlStr = htmlStr & "<TR>" & CrLf & "<TD>Create Parent Levels if Missing ?" & CrLf
		htmlStr = htmlStr & "<TD><input type=" & DQ &"checkbox" & DQ & " name=" & DQ & "Parent" & DQ &  ">" & CrLf
	End If
	If Cint(AccLev) < Cint(testlev) And Mid(Valid,3,1) = 0 Then
		Select Case AccLev
		Case 1
			tpstr = document.all.LevInput1.outerHTML
			tpstr = Replace(tpStr,"LevInput1","TempInput")
		Case 2
			tpstr = document.all.LevInput2.outerHTML
			tpstr = Replace(tpStr,"LevInput2","TempInput")
		Case 3
			tpstr = document.all.LevInput3.outerHTML
			tpstr = Replace(tpStr,"LevInput3","TempInput")
		Case 4
			tpstr = document.all.LevInput4.outerHTML
			tpstr = Replace(tpStr,"LevInput4","TempInput")
		Case 5
			tpstr = document.all.LevInput5.outerHTML
			tpstr = Replace(tpStr,"LevInput5","TempInput")
		Case 6
			tpstr = document.all.LevInput6.outerHTML
			tpstr = Replace(tpStr,"LevInput6","TempInput")
		Case 7
			tpstr = document.all.LevInput7.outerHTML
			tpstr = Replace(tpStr,"LevInput7","TempInput")
		End Select
		htmlStr = htmlStr & "<TR><TD>" & LevDescs(AccLev) &" to Be Used As Template" & CrLf & "<TD>" & tpstr & "</TD>" & CrLf
	End If
	htmlStr = htmlStr & "<%=ReportSets%>"
	htmlStr = htmlStr & "</table>"
	document.all.expanding.innerHTML = htmlStr
	If Mid(Valid,3,1) = 0 then
		document.all.add.disabled = False
		If Cint(AccLev) < Cint(testlev) Then document.all.TempInput.value = ""
	Else
		OldRec = Split(Mid(Valid,4),BS)
		If Cint(AccLev) = Cint(testlev) then
			document.all.AccountType.value = OldRec(11)
		End If
		pos = Instr(OldRec(1),"~")
		If pos <> 0 Then
			document.all.AddDesc.value = Mid(OldRec(1),pos+1)
		End If
		document.all.ClosedDate.value = OldRec(12)
		document.all.Setinput1.value = OldRec(18)
		document.all.Setinput2.value = OldRec(19)
		document.all.Setinput3.value = OldRec(20)
		document.all.Setinput4.value = OldRec(21)
		document.all.Setinput5.value = OldRec(22)
		document.all.Setinput6.value = OldRec(23)
'		If OldRec(13) = "Y" Then
'			document.all.GST.checked = True
'		End If
		document.all.update.disabled = False
		document.assetdata.before.value = Accno & BS & Mid(Valid,4)
	End If 
Else
	Msgbox Valid
End If	

End Sub
'**********************************************************************
Sub ClearSels
On Error Resume Next
document.all.LevInput1.value = ""
document.all.LevInput2.value = ""
document.all.LevInput3.value = ""
document.all.LevInput4.value = ""
document.all.LevInput5.value = ""
document.all.LevInput6.value = ""
document.all.LevInput7.value = ""
document.all.LevInput8.value = ""
End Sub
'**********************************************************************'
Sub Clear_Click
ClearSels
document.all.AccountInput.value = ""
document.all.expanding.innerHTML = ""
document.all.add.disabled = True
document.all.update.disabled = True
On Error Resume Next
document.all.LevInput2.disabled = True
document.all.LevInput3.disabled = True
document.all.LevInput4.disabled = True
document.all.LevInput5.disabled = True
document.all.LevInput6.disabled = True
document.all.LevInput7.disabled = True
document.all.LevInput8.disabled = True
End Sub
'**********************************************************************'
Sub Add_Click
Dim Accno,AType,CDate,TableName,Before,after,action,GstVal,ParentVal
Dim Setval1,Setval2,Setval3,Setval4,Setval5,Setval6,MoreDesc
If AccLev = Cint(document.all.stoNoLevs.value) then
	AType = document.all.AccountType.value
	If AType = "" or Instr("ALIEO",AType) = 0 Then
		MsgBox "Account Type Must be A,L,I,E or O"
		Exit Sub
	End If
Else
	AType = ""
End If
CDate = document.all.ClosedDate.value
If CDate <> "" and Not(Isdate(CDate)) Then
	MsgBox "Invalid Closed Date"
	Exit Sub
End If
TableName = document.assetdata.stofiletouse.value
Accno = document.all.AccountInput.value
Before = "before"
On Error Resume Next
ParentVal = ""
GstVal = ""
TempInputVal = ""
Setval1 = ""
Setval2 = ""
Setval3 = ""
Setval4 = ""
Setval5 = ""
Setval6 = ""
MoreDesc = ""
'If document.all.GST.Checked = True Then
'	GstVal = "Y"
'Else
'	GstVal = "N"
'End If
If document.all.Parent.Checked = True Then
	ParentVal = "Y"
Else
	ParentVal = "N"
End If
If document.all.TempInput.value <> "" Then TempInputVal = document.all.TempInput.value
If document.all.Setinput1.value <> "" then Setval1 = document.all.Setinput1.value
If document.all.Setinput2.value <> "" then Setval2 = document.all.Setinput2.value
If document.all.Setinput3.value <> "" then Setval3 = document.all.Setinput3.value
If document.all.Setinput4.value <> "" then Setval4 = document.all.Setinput4.value
If document.all.Setinput5.value <> "" then Setval5 = document.all.Setinput5.value
If document.all.Setinput6.value <> "" then Setval6 = document.all.Setinput6.value
If Cint(AccLev) > 1 And document.all.AddDesc.value <> "" Then
	MoreDesc = document.all.AddDesc.value
End If
After = Accno & BS & AType & BS & document.all.ClosedDate.value & BS & GstVal & BS & ParentVal & BS & TempInputVal
After = After & BS & Setval1 & BS & Setval2 & BS & Setval3 & BS & Setval4 & BS & Setval5 & BS & Setval6 & BS & MoreDesc
action = "A"
Msg = UpdateAccount(TableName,Accno,Before,After,action)
If Msg = "0" then
	MsgBox "Account Created"
	Query_Click
Else
	Msgbox Msg & "=" & after & "=" & tablename
End If
End Sub
'********************************************************************
Sub Update_Click
Dim Accno,AType,CDate,TableName,Before,after,action,GstVal,ParentVal
Dim Setval1,Setval2,Setval3,Setval4,Setval5,Setval6,MoreDesc
If AccLev = Cint(document.all.stoNoLevs.value) then
	AType = document.all.AccountType.value
	If AType = "" or Instr("ALIEO",AType) = 0 Then
		MsgBox "Account Type Must be A,L,I,E or O"
		Exit Sub
	End If
Else
	AType = ""
End If
CDate = document.all.ClosedDate.value
If CDate <> "" and Not(Isdate(CDate)) Then
	MsgBox "Invalid Closed Date"
	Exit Sub
End If
TableName = document.assetdata.stofiletouse.value
Accno = document.all.AccountInput.value
Before = document.assetdata.before.value
Setval1 = ""
Setval2 = ""
Setval3 = ""
Setval4 = ""
Setval5 = ""
Setval6 = ""
MoreDesc = ""
'If document.all.GST.Checked = True Then
'	GstVal = "Y"
'Else
'	GstVal = "N"
'End If
On Error Resume Next
'If document.all.Parent.Checked = True Then
'	ParentVal = "Y"
'Else
'	ParentVal = "N"
'End If
If document.all.Setinput1.value <> "" then Setval1 = document.all.Setinput1.value
If document.all.Setinput2.value <> "" then Setval2 = document.all.Setinput2.value
If document.all.Setinput3.value <> "" then Setval3 = document.all.Setinput3.value
If document.all.Setinput4.value <> "" then Setval4 = document.all.Setinput4.value
If document.all.Setinput5.value <> "" then Setval5 = document.all.Setinput5.value
If document.all.Setinput6.value <> "" then Setval6 = document.all.Setinput6.value
If Cint(AccLev) > 1 And document.all.AddDesc.value <> "" Then
	MoreDesc = document.all.AddDesc.value
End If
After = Accno & BS & AType & BS & document.all.ClosedDate.value & BS & GstVal & BS & ParentVal & BS
After = After & BS & Setval1 & BS & Setval2 & BS & Setval3 & BS & Setval4 & BS & Setval5 & BS & Setval6 & BS & MoreDesc
action = "W"
Msg = UpdateAccount(TableName,Accno,Before,After,action)
If Msg = "0" then
	MsgBox "Account Updated"
Else
	Msgbox Msg
End If
End Sub
</SCRIPT>

</HEAD>

<BODY onload='DisableSels()'>
<TD WIDTH="5%">
        <A href="/prospect/asp/menu.asp"><IMG
SRC="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="30"
HEIGHT="22" ALT="Prospect Explorer"></A>

<FORM ACTION="/prospect/asp/GenexLoad.asp" METHOD="POST" NAME="assetdata" ENCTYPE="multipart/form-data" >
<DIV id="Test" STYLE="position: visibility: visible;">
<input type="hidden" name="logentry" value="<%=Session("logentry")%>">
<input type="hidden" name="before" value="">
<input type="hidden" name="after" value="">
<input type="hidden" name="stofiletouse" value="<%=filetouse%>">
<input type="hidden" name="stoNoLevs" value="<%=NoLevs%>">


<TABLE WIDTH="100%" border="1" cellspacing="1" cellpadding="1"> 
<TR CLASS="top">
<TH colspan=4>General Ledger Account Maintenance
<TR>
</TABLE>
<DIV align=center>
<table width="95%" border="1" cellspacing="1" cellpadding="1" name="LevelTable">
<TR CLASS="top">
<th width="30%" colspan="1">Level</th>
<th width="69%" colspan="1">Selection</th>
<%
response.write(result)
%>

</table>
<BR>
Account Number <input type="text" id="AccountInput">
<BR>
</Div>
</FORM>
<FORM ACTION="/prospect/asp/GenexLoad.asp" METHOD="POST" NAME="assetform">
<INPUT id=select10 name=select10 value="" type="hidden">
<INPUT id=select11 name=select11 value="" type="hidden">
<%'this is where the expandable table goes - written to in Buildno%>
<I id=expanding></I>

<TABLE align="center">

<TR>
<TR>
<TH align=CENTER>
<input type="button" name="Query" value="Query" width="2100" height="700" onclick='Query_Click()'>
<TH align=CENTER>
<input type="button" name="Add" value="Add" width="2100" height="700" onclick='Add_Click()' disabled="True">
<TH align=CENTER>
<input type="button" name="Update" value="Update" width="2100" height="700" onclick='Update_Click()' disabled="True">
<TH align=CENTER>
<input type="button" name="Clear" value="Clear" width="2100" height="700" onclick='Clear_Click()'>
</TABLE>

</FORM>

</BODY>
</HTML>

