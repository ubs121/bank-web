VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "d3"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
Option Compare Text

Private DictOpenFiles As Scripting.Dictionary

Private g_dbnames() As String
Private g_dbs() As database
Private g_tbnames() As String
Private g_tables() As Recordset
Private g_defs() As TableDef
Private g_index() As Integer

Private g_d3rulemodules() As clsD3RuleModule
Private g_d3rulemodule_names() As String
Private pick As New pick
Private g_trans_info As String  'mc 29apr99

Private Const D3ExecuteNoResults = 0 '; // Neither
Private Const D3ExecuteCapturing = 1 '; // Capturing only
Private Const D3ExecuteReturning = 2 '; // Returning only
Private Const D3ExecuteWithBoth = 3  '; // Capturing and Returning

Private Sub Class_Initialize()

Set DictOpenFiles = New Scripting.Dictionary
DictOpenFiles.CompareMode = TextCompare
ReDim g_dbnames(0)
ReDim g_tbnames(0)

End Sub

Private Sub Class_Terminate()

Dim kk As Integer

    DictOpenFiles.RemoveAll
    
    For kk = 1 To UBound(g_dbnames)
       g_dbs(kk).Close
       Set g_dbs(kk) = Nothing
    Next kk

End Sub


Public Function reading_pick(database As String, rd As clsD3DynamicArray, PickFile As String, id As String) As Integer
 
    reading_pick = d3_openfile(database, PickFile, id, "R", rd)
    Exit Function
   
End Function
Public Function d3_openfile(database As String, PickFile As String, id As String, what As String, Optional rd As clsD3DynamicArray) As Integer

Dim usefile As String
Dim d3Environment As clsD3Environment, d3domain As clsD3NetDomain, d3vme As clsD3VirtualMachine
Dim logon As String
Dim Mydatabase As clsD3Database
Dim Tmp As clsD3File

 On Error GoTo ThisErr
 
   If InStr(PickFile, ",") = 0 Then
      If Left(PickFile, 5) = "dict " Then
         usefile = "dict " & database & "," & Mid(PickFile, 6) & ","
      Else
         usefile = database & "," & PickFile & ","
      End If
   Else
      usefile = PickFile
   End If
   
   If DictOpenFiles.Exists(usefile) Then
      Set Tmp = DictOpenFiles(usefile)
   Else
      logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 2, database, -1, Mydatabase)
      If logon <> "" Then GoTo ThisErr
      Set Tmp = Mydatabase.brOpenFile(usefile)
      DictOpenFiles.Add usefile, Tmp
   End If
   
   Select Case what
      Case "RU": Set rd = Tmp.brReadU(id) 'lock item
      Case "RE": Call Tmp.brRelease(id) 'release item lock
      Case "R": Set rd = Tmp.brRead(id)
      Case "W": Call Tmp.brWrite(rd, id)
      Case "D": Call Tmp.brDelete(id)
      Case "O": 'just seeing if file exists
   End Select
   
   If Not DictOpenFiles.Exists(usefile) Then
      logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 3, database, -1, Mydatabase)
   End If
  
   d3_openfile = 0
   Exit Function

ThisErr:
   d3_openfile = 1
   
   Select Case what
      Case "R": Set rd = New clsD3DynamicArray: rd.brCString = ""
   End Select
   Exit Function

End Function
Public Sub d3_Pause(PauseTime)

   Dim start, finish, TotalTime, cnt As Long
   start = Timer
   Do While Timer < start + PauseTime
   cnt = cnt + 1
   Loop
   finish = Timer
   TotalTime = finish - start

End Sub


Public Function d3_delete(database As String, tbl_name As String, id As String) As String

Dim rderr As Integer, rd() As String

    If InStr(tbl_name, ".mdb\") <> 0 Then ' ms access file
       ReDim rd(0): rd(0) = id
       d3_delete = writing_msaccess(rd(), tbl_name, "D")
    Else 'd3 file
       rderr = d3_openfile(database, tbl_name, id, "D")
       d3_delete = CStr(rderr)
    End If
    
    Exit Function
       
End Function
Public Function d3_writedyn(database As String, PickFile As String, id As String, rd As clsD3DynamicArray) As String

Dim wterr As Integer

  wterr = d3_openfile(database, PickFile, id, "W", rd)
  If wterr = 0 Then d3_writedyn = "0" Else d3_writedyn = "1"
  Exit Function

End Function

Function d3_readdyn(database As String, rd As clsD3DynamicArray, tbl_name As String, id As String, Optional attr As Integer = -1, Optional vm As Integer = 0, Optional svm As Integer = 0) As Integer

Dim rderr As Integer

    rderr = reading_pick(database, rd, tbl_name, id)
    If rderr <> 0 Then d3_readdyn = rderr: Exit Function
    
    If Not attr Then ' attr = -1
       rd = rd.brExtract(attr, vm, svm)
   End If
   d3_readdyn = 0
   Exit Function
    
End Function

Public Sub d3_subroutine(sub_name As String, cnt As Integer)

Dim max As Integer

If UBound(g_d3rulemodule_names) = 0 Then
   cnt = 0
Else
   max = UBound(g_d3rulemodule_names)
   For cnt = 1 To max
      If sub_name = g_d3rulemodule_names(cnt) Then Exit Sub
   Next
End If
cnt = cnt + 1

ReDim Preserve g_d3rulemodule_names(cnt)
ReDim Preserve g_d3rulemodules(cnt)
g_d3rulemodule_names(cnt) = sub_name
'Set g_d3rulemodules(cnt) = g_d3rulecatalog.brOpenRuleModule(sub_name, "b-obj", "cka")

End Sub


Public Function d3_initialize(logentry As String) As String

ReDim g_d3rulemodule_names(0)
 
Dim d3Environment As clsD3Environment, d3domain As clsD3NetDomain, d3vme As clsD3VirtualMachine
Dim logon As String

logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 1, logentry)
If logon <> "" Then
   d3_initialize = logon
   Exit Function
End If
logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)

g_trans_info = ""
d3_initialize = ""

End Function

Public Function d3_readmat(database As String, rd() As String, tbl_name As String, Optional attr As Integer = -1, Optional vm As Integer = 0, Optional svm As Integer = 0) As Integer

Dim rderr As Integer, id As String
Dim rd3 As clsD3DynamicArray
Dim numcols As Long, nx As Long

    If InStr(tbl_name, ".mdb\") <> 0 Or Left(tbl_name, 4) = "sql," Then ' ms access file
       If Left(tbl_name, 4) = "sql," Then
          rderr = reading_sql(rd(), tbl_name)
       Else
          rderr = reading_msaccess(rd(), tbl_name)
       End If
       d3_readmat = rderr
       Exit Function
    Else 'd3 file
       If Right(tbl_name, 1) = "\" Then
          d3_readmat = read_dos_mat(rd(), tbl_name)
          Exit Function
       End If
       rderr = reading_pick(database, rd3, tbl_name, rd(0))
       If rderr <> 0 Then d3_readmat = rderr: Exit Function
    End If
    
    If Not attr Then ' attr = -1
       ReDim Preserve rd(1)
       rd(1) = rd3.brExtractStr(attr, vm, svm)
    Else
       numcols = rd3.brDCount(Chr(254))
       ReDim Preserve rd(numcols)
       For nx = 1 To numcols
          rd(nx) = rd3.brExtractStr(nx)
       Next nx
    End If
    d3_readmat = 0
        
End Function
Public Function d3_readstr(database As String, rd As String, tbl_name As String, id As String, Optional attr As Integer = -1, Optional vm As Integer = 0, Optional svm As Integer = 0, Optional delimiter As String = "") As Integer

Dim rderr As Integer
Dim rd3 As clsD3DynamicArray
Dim rda() As String 'mc 08jan00 till next one
Dim j As Integer

    If delimiter = "" Then delimiter = Chr(254)
    
    If InStr(tbl_name, ".mdb\") <> 0 Or Left(tbl_name, 4) = "sql," Then ' ms access file
       ReDim rda(0): rda(0) = id
       If Left(tbl_name, 4) = "sql," Then
          rderr = reading_sql(rda(), tbl_name)
       Else
          rderr = reading_msaccess(rda(), tbl_name)
       End If
       If rderr <> 0 Then d3_readstr = rderr: Exit Function
       If Not attr Then
          rd = rda(attr)
          rd = pick.extract(rd, 1, vm, svm)
       Else
          If UBound(rda) > 0 Then
             rd = rda(1)
             For j = 2 To UBound(rda)
                rd = rd & delimiter & rda(j)
             Next j
          Else
             rd = ""
          End If
       End If
       d3_readstr = 0
       Exit Function
    Else 'd3 file
       rderr = reading_pick(database, rd3, tbl_name, id)
       If rderr <> 0 Then d3_readstr = rderr: Exit Function
       If attr <> -1 Then ' attr = -1
          rd = rd3.brExtractStr(attr, vm, svm)
       Else
          rd = rd3.brCString 'Turn d3 string into vb string
       End If
       If delimiter <> Chr(254) Then rd = Replace(rd, Chr(254), delimiter)
       d3_readstr = 0
    End If

End Function

Public Function d3_select(logentry As String, sentence As String, myids() As String, pick_cnt As Long, start As Long, finish As Long, Optional dropdown As Integer = 0, Optional sumonly As Integer = 0) As Long

Dim num_items As Long, id As String, cnt As Long, tot As Currency
Dim mylist As clsD3SelectList
Dim use_start_finish As Boolean
Dim within_range As Boolean
Dim pos1 As Long, pos2 As Long 'mco 16mar00
Dim d3Environment As clsD3Environment, d3domain As clsD3NetDomain, d3vme As clsD3VirtualMachine
Dim logon As String, vme_done As Boolean

If start = 0 And finish = 0 Then
   use_start_finish = False
Else
   use_start_finish = True
End If
vme_done = False

On Error GoTo d3_select_error

num_items = 0: id = "": cnt = 0

logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 1, logentry)
If logon <> "" Then
   d3_select = 1 '-1
   pick_cnt = -1
   ReDim myids(0): myids(0) = "Error in vme " & logentry & " - " & logon
   Exit Function
End If
vme_done = True
Set mylist = d3vme.brOpenSelectList(sentence)

tot = 0

Do While mylist.brReadNext(id)
     num_items = num_items + 1
     If dropdown = 1 And cnt Mod 2 <> 0 Then num_items = num_items - 1
     
     If use_start_finish Then
        If num_items >= start And num_items <= finish Then within_range = True
        If num_items > finish Then Exit Do
     End If
     
     If within_range Or use_start_finish = False Then
        If sumonly Then
           If IsNumeric(id) Then tot = tot + CCur(id)
        Else
           If dropdown = 0 Then
              ReDim Preserve myids(cnt)
              myids(cnt) = id
           Else
              If cnt Mod 2 = 0 Then
                 ReDim Preserve myids(cnt / 2)
                 myids(cnt / 2) = id
              Else
                 myids((cnt - 1) / 2) = myids((cnt - 1) / 2) & Chr(8) & id
              End If
           End If
        End If
        cnt = cnt + 1
     End If
Loop

If sumonly Then ReDim myids(0): myids(0) = CStr(tot): num_items = 1
d3_select = num_items
pick_cnt = mylist.brCount
logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)
Exit Function

d3_select_error:
d3_select = 1
pick_cnt = -1
ReDim myids(0): myids(0) = "Error in d3_select " & sentence
If vme_done Then logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)
Exit Function

End Function
Public Function conv_translate(database As String, use_conversion As String, converted As String) As String

Dim fname As String, use_how As Integer
Dim temp As String, rd() As String 'mc 28apr99
Dim temp2 As String, max As Integer, want_space As String, temp3 As String
Dim temp4 As String, attr As String, vm As Integer, I As Integer, svm As Integer
Dim temparr() As String, temparr2() As String, rderr As Integer
Dim tempd3 As clsD3DynamicArray, vv As Integer

     fname = Mid(pick.Field(use_conversion, ";", 1), 2)
     use_how = 0
     Select Case fname
        Case "ACCOUNTDESC"
           If Left(converted, 3) = "JOB" Then
              fname = "JOB.L": use_conversion = use_conversion & ";2": converted = Mid(converted, 4)
           Else
              If pick.Index(converted, ".", 2) <> 0 Then fname = "GEN.L": use_conversion = use_conversion & ";2" Else fname = "CLIENT": use_conversion = use_conversion & ";1"
           End If
        Case "STOCKDESC"
           If Left(converted, 3) = "JOB" Then
              fname = "JOB.L": use_conversion = use_conversion & ";2": converted = Mid(converted, 4)
           Else
              If pick.Index(converted, ".", 2) <> 0 Then fname = "GEN.L": use_conversion = use_conversion & ";2" Else fname = "STOCK": use_conversion = use_conversion & ";1"
           End If
         Case "OWNERNAME"
           ReDim rd(0): rd(0) = converted 'mc 28apr99
           rderr = d3_readmat(database, rd(), "CLIENT", 35, 1)  'mc 28apr99
           If rderr <> 0 Then conv_translate = "": Exit Function 'mc 28apr99
           temp = rd(1) 'mc 28apr99 pick.extract(temp, 35, 1, 0)
           If temp <> "" Then
              temp2 = temp
              rderr = d3_readstr(database, temp, "CLIENT", temp2)
              temp = pick.trimm(pick.extract(temp, 8, 0, 0) & " " & pick.extract(temp, 7, 0, 0) & " " & pick.extract(temp, 1, 0, 0))
           End If
           conv_translate = temp
           Exit Function 'mc 28apr99
       Case "MAIL_ADDRESS", "RES_ADDRESS"
           rderr = d3_readdyn(database, tempd3, "CLIENT", converted)
           I = 1
           If Left(fname, 1) = "R" Then
              temp2 = tempd3.brExtractStr(5, 2, 0)
              If temp2 = "" Then I = 1 Else I = 2
           End If
           temp2 = pick.trimm(tempd3.brExtractStr(2, I, 0) & " " & tempd3.brExtractStr(3, I, 0) & " " & tempd3.brExtractStr(4, I, 0) & " " & tempd3.brExtractStr(5, I, 0))
           conv_translate = temp2
           Exit Function
        Case "EMPCLIENT"
           fname = "EMPLOYEE": use_conversion = use_conversion & ";1"
           Select Case pick.extract(converted, 2, 0, 0) 'id is in attr1 so add 1 to all wanted
              Case "42", "67", "40", "65"
              Case Else
                 temp3 = pick.extract(converted, 7, 0, 0)
                 If InStr(temp3, "EMP-") <> 0 And InStr(temp3, "TS-") <> 0 Then
                 Else
                    fname = "CLIENT": use_conversion = use_conversion & ";1"
                 End If
           End Select
           converted = pick.extract(converted, 6, 1, 0)
'        037      PCODES=42:VM:67:VM:40:VM:65
'746                  LOCATE TR.TYPE IN PCODES <1,1> SETTING PP ELSE PP=0
'747                  IF PP OR (INDEX(NARR,'EMP-',1) AND INDEX(NARR,'TS-',1)) OR
'    INDEX(NARR,'PAY',1) THEN FILE=EMPLOYEE.DATA
     End Select
     ReDim rd(0): rd(0) = converted
     rderr = d3_readmat(database, rd(), fname)
     If rderr <> 0 Then
        temp2 = ""
     Else
        temparr = Split(use_conversion, ";", -1, vbBinaryCompare)
        max = UBound(temparr)
        temp2 = "": want_space = ""
        For I = 1 To max
           temp3 = temparr(I)
           temparr2 = Split(temp3, ",", -1, vbBinaryCompare)
           ReDim Preserve temparr2(2)
           attr = temparr2(0)
           If attr = "-1" Then 'mc 11may99 to next
              For vv = 1 To UBound(rd)
                   temp2 = temp2 & Chr(254) & rd(vv)
              Next vv
              If temp2 <> "" Then temp2 = Mid(temp2, 2)
              Exit For
           End If 'mc 11may99
           If Left(attr, 1) = "C" Then
             temp2 = temp2 & want_space & Mid(attr, 2)
             want_space = ""
           Else
              If UBound(rd) < CInt(attr) Then temp4 = "" Else temp4 = rd(CInt(attr))
              If temparr2(1) = "LAST" Then
                 vm = pick.dcount(temp4, Chr(253)) 'mc 6may99
              Else
                 If IsNumeric(temparr2(1)) Then vm = CInt(temparr2(1)) Else vm = 1
              End If
              If IsNumeric(temparr2(2)) Then svm = CInt(temparr2(2)) Else svm = 0
              temp4 = pick.extract(temp4, 1, vm, svm)
              If svm = 0 Then temp4 = Replace(temp4, Chr(252), " ")
              temp2 = temp2 & want_space & temp4
              want_space = " "
           End If
        Next I
     End If
     conv_translate = temp2
  
End Function

Function conv_in(database As String, ByVal cur_module As String, how As Integer, conversion As String, fld_dt As String, errmsg As String, internal_datum, tfile As String, v7 As String, v36 As String, max_length As Integer, Optional language As String = "English", Optional language_file As String = "c:\ckashare\cka\language.ini") As String

' Display Date Or Amount If field value is date or amount

Dim max_lth, I, temp As String, rderror As Integer, max As Integer, dec_places As Integer
Dim attr As Integer, val1 As Integer, val2 As Integer
Dim vfdate As Integer, vtdate As Integer
Dim vfdate_pc As Date, vtdate_pc As Date, temp4 As String, temp5 As String

    If fld_dt = "" Then conv_in = "": internal_datum = "":  Exit Function
    errmsg = ""
    Select Case conversion
       Case "D2", "D4", "D2,34,1,2", "D2,34,3,4", "D2,34,5,6", "D2,34,7,8", "D2,34,9,10", "D2,34,11,12", "D2,0" 'mc 29apr99
          If Not IsDate(fld_dt) Then
             Select Case Len(fld_dt)   'aze 19/2/97 to allow type
             Case 1, 2                 'DD 1 or 2 digits
                  fld_dt = fld_dt & Mid(Date, 3)
             Case 4                    'DDMM 4 digits
                  fld_dt = Mid(fld_dt, 1, 2) & "/" & Mid(fld_dt, 3, 4) & Mid(Date, 6)
             Case 6                    'DDMMYY 6 digits
                  fld_dt = Mid(fld_dt, 1, 2) & "/" & Mid(fld_dt, 3, 2) & "/" & Mid(fld_dt, 5, 2)
             End Select
             If Not IsDate(fld_dt) Then
                errmsg = pick.ini_read(language, "35", language_file)
                Call pick.sr_chone(errmsg, "1", fld_dt)
                Exit Function
             End If
           End If
           attr = pick.date_vb_to_pick(fld_dt, internal_datum, how)
           If Mid(conversion, 3, 1) = "," Then 'validate on trans.info
              If g_trans_info = "" Then  'mc 29apr99
                 rderror = d3_readstr(database, g_trans_info, "DICT TRANS.J", "TRANS.INFO") 'mc 04may99
                 If rderror <> 0 Or g_trans_info = "" Then errmsg = "trans_info not set up in program": Exit Function  'mc 04may99
              End If  'mc 29apr99
              attr = CInt(pick.Field(conversion, ",", 2))
              If attr = 0 Then  'mc 29apr99 till next mc 29apr99
                 If InStr(Chr(253) & pick.extract(g_trans_info, 8, 0, 0) & Chr(253) & pick.extract(g_trans_info, 7, 0, 0) & Chr(253), Chr(253) & internal_datum & Chr(253)) = 0 Then
                    errmsg = fld_dt & " (" & internal_datum & ")" & " must be one of " & pick.extract(g_trans_info, 8, 0, 0) & Chr(253) & pick.extract(g_trans_info, 7, 0, 0)
                    Exit Function
                 End If
                 GoTo conv_in_end_select
              End If 'mc 29apr99
              val1 = CInt(pick.Field(conversion, ",", 3))
              val2 = CInt(pick.Field(conversion, ",", 4))
              If how <> 2 Then
                 vfdate = CInt(pick.extract(g_trans_info, attr, val1, 0))
                 vtdate = CInt(pick.extract(g_trans_info, attr, val2, 0))
                 If attr <> 0 Then
                    If CInt(internal_datum) > vtdate Or CInt(internal_datum) < vfdate Then
                       errmsg = pick.ini_read(language, "34", language_file)
                       Call pick.sr_chone(errmsg, "3", pick.date_pick_to_vb(vtdate))
                       Call pick.sr_chone(errmsg, "2", pick.date_pick_to_vb(vfdate))
                       Call pick.sr_chone(errmsg, "1", fld_dt)
                       Exit Function
                    End If
                 End If
              Else
                 vfdate_pc = CDate(pick.extract(g_trans_info, attr, val1, 0))
                 vtdate_pc = CDate(pick.extract(g_trans_info, attr, val2, 0))
                 If attr <> 0 Then
                    If DateDiff("d", vfdate_pc, fld_dt) < 0 Or DateDiff("d", vtdate_pc, fld_dt) > 0 Then
                       errmsg = pick.ini_read(language, "34", language_file)
                       Call pick.sr_chone(errmsg, "3", CStr(vtdate_pc))
                       Call pick.sr_chone(errmsg, "2", CStr(vfdate_pc))
                       Call pick.sr_chone(errmsg, "1", fld_dt)
                       Exit Function
                    End If
                 End If
              End If
           End If
       Case "MT"
          If Not IsDate(fld_dt) Then
             errmsg = fld_dt & " must be a valid time"
             Exit Function
           End If
           If how <> 2 Then
              internal_datum = DateDiff("s", 0, fld_dt)
           Else
              internal_datum = CDate(fld_dt)
           End If
       Case "MD2", "MD0", "MD1", "MD3", "MD4", "MD2>0", "MD0>0", "MD1>0", "MD3>0", "MD4>0", "MD2<0" 'mc 23may99
          dec_places = CInt(Mid(conversion, 3, 1))
          Call pick.sr_change(fld_dt, "$", "")
          Call pick.sr_change(fld_dt, ",", "")
          fld_dt = pick.trimm(fld_dt)
          If Not IsNumeric(CVar(fld_dt)) Then
md_error:
             errmsg = pick.ini_read(language, "39", language_file)
             Call pick.sr_chone(errmsg, "1", CStr(dec_places))
             Exit Function
          End If
          If dec_places = 0 Then
             If pick.Index(fld_dt, ".", 1) <> 0 Then GoTo md_error
             internal_datum = CStr(CVar(fld_dt))
          Else
             If Len(pick.Field(fld_dt, ".", 2)) > dec_places Then GoTo md_error
             internal_datum = CStr(CVar(fld_dt) * (10 ^ dec_places))
          End If
          If pick.Index(conversion, ">", 1) <> 0 Then
             If internal_datum <= CInt(Mid(conversion, 5, 1)) Then
                errmsg = pick.ini_read(language, "40", language_file)
                Call pick.sr_chone(errmsg, "1", Mid(conversion, 5, 1))
                Call pick.sr_chone(errmsg, "2", ">")
                Exit Function
             End If
          End If
          If pick.Index(conversion, "<", 1) <> 0 Then
             If internal_datum >= CInt(Mid(conversion, 5, 1)) Then
                errmsg = pick.ini_read(language, "40", language_file)
                Call pick.sr_chone(errmsg, "1", Mid(conversion, 5, 1))
                Call pick.sr_chone(errmsg, "2", "<")
                Exit Function
             End If
          End If
       Case "YN", "NY"
          If fld_dt <> "Y" And fld_dt <> "N" And fld_dt <> "" Then
             errmsg = "Must be Y or N or null (=" & Left(conversion, 1) & ")"
             Exit Function
          End If
          internal_datum = fld_dt
       Case "4N", "1N0N"
          If Not (pick.match(fld_dt, conversion)) Then
             errmsg = fld_dt & " must match a pattern of " & conversion
             Exit Function
          End If
          internal_datum = fld_dt
        Case "NUMERIC"
          If Not IsNumeric(fld_dt) Then
             errmsg = pick.ini_read(language, "64", language_file)
             Exit Function
          End If
          internal_datum = fld_dt
       Case "SYNONYM"
         'MsgBox "HERE"
         'If pick.extract(f_rec, 3, 0, 0) <> "" Then
         '      id_entered = pick.extract(f_rec, 3, 0, 0) ' means attr 1 as f_rec has 1=count,2=id read, 3=attr1 of record
         '      Call Put_Code_Description(1, id_entered, True, False, False)
         '      GoTo qury_synonym
         '   End If
        Case "shuudan"
           'If cur_form.get_rda_ubound < 5 Then
shuudan_error:
           '   errmsg = cur_form.get_f_control_record(3).Sub_value1 & " " & pick.ini_read(language, "32", language_file)
           '   Exit Function
           'End If
           'temp4 = cur_form.get_rda(4):  temp5 = cur_form.get_rda(5)
           'If temp4 = "" Or temp5 = "" Then GoTo shuudan_error 'must have customer class and product id
        Case "2dots"
              If pick.Index(fld_dt, ".", 2) = 0 Then
                 errmsg = pick.ini_read(language, "38", language_file)
                 Call pick.sr_chone(errmsg, "1", fld_dt)
                 Exit Function
              End If
       Case Else
          If Left(conversion, 2) = "<>" Then
             max = Len(conversion)
             For I = 3 To max
                  If pick.Index(fld_dt, Mid(conversion, I, 1), 1) <> 0 Then
                     errmsg = pick.ini_read(language, "36", language_file)
                     Call pick.sr_chone(errmsg, "2", """ " & Mid(conversion, I, 1) & """")
                     Call pick.sr_chone(errmsg, "1", fld_dt)
                     Exit Function
                  End If
              Next I
          End If
          
          If Left(conversion, 1) = "@" Then ' form @,y,y2, then find ,y, in string, last , needed - , can be anything
             temp = Mid(conversion, 2, 1)
             If InStr(conversion, temp & fld_dt & temp) = 0 Then '?oktext
                errmsg = pick.ini_read(language, "41", language_file)
                Call pick.sr_chone(errmsg, "1", Mid(conversion, 3, Len(conversion) - 3))
                Exit Function
             End If
          Else
             If how <> 2 Then
                If InStr(fld_dt, "~") <> 0 Or InStr(fld_dt, "}") <> 0 Then '?oktext
                   errmsg = fld_dt & Chr(10) & "contains ~ or } and this is not allowed"
                   Exit Function
                End If
             End If
          End If
          If Left(conversion, 1) = "&" Then 'aze 26/9/97,form &A...X, then
                                            'check each data of this field
                                            'must be one of A...X.
              conversion = Mid(conversion, 2, Len(conversion) - 1)
              For I = 1 To Len(fld_dt)
                  temp = Mid$(fld_dt, I, 1)
                  If InStr(conversion, temp) = 0 Then
                     errmsg = temp & " must be one of " & conversion
                     Exit Function
                  End If
              Next
          End If
          internal_datum = fld_dt
    End Select
    
conv_in_end_select:
    If max_length <> 0 Then
       If Len(fld_dt) > max_length Then
          errmsg = fld_dt & Chr(10) & " exceeds maximum length of " & max_length
          Exit Function
       End If
    End If
    
          
    'mc If tfile <> "" Then
    '   rderror = Get_Description(cur_dbno, tfile, v7, v36, fld_dt, temp)
    '   If rderror <> 0 Then
    '      errmsg = fld_dt & Chr(10) & " does not exist on file " & tfile
    '      Exit Function
    '   End If
    '   conv_in = temp
    '   Exit Function ' /// what if want more to be done
    'End If
    fld_dt = internal_datum
   
   Select Case conversion
       Case ".1", ".2", ".3": conv_in = fld_dt
       Case Else:  conv_in = conv_out(database, cur_module, how, conversion, fld_dt)  'mc aze 16/9/96
    End Select
    
End Function




Function conv_out(database As String, ByVal cur_module As String, ByVal how As Integer, conversion As String, fld_dt As String) As String

Dim j As Integer, max As Integer, temp As String, I As Integer
Dim dec_places As Integer, temp3 As String
Dim use_conversion As String, converted As String, number_conversions As Integer
Dim separator As String, test_conversion As String
Dim the_format As String, tempint As Integer
Dim rderror As Integer, temparr() As String, temparr2() As String
Dim tempobj As Object

Static last_one As String
Static penultimate As String

separator = "~"

'xyzIf Form2.f_cur_oitemid = "HTML_PROSPECT" Then separator = "~" Else separator = "|"

  number_conversions = pick.dcount(conversion, separator)
  converted = fld_dt
  For j = 1 To number_conversions

    use_conversion = pick.Field(conversion, separator, j): test_conversion = use_conversion
    
    Select Case Left(test_conversion, 1)
       Case "T" 'CLIENT;1", "TCLIENT;2,1;3,1;4,1;5,1"
          If converted <> "" Then converted = conv_translate(database, use_conversion, converted)
          GoTo next_j
       Case "G", "C"
          converted = conv_group(database, converted, use_conversion)
          GoTo next_j
       Case "A"
          converted = conv_arithmetic(converted, use_conversion, last_one, penultimate)
          GoTo next_j
       Case "B"
          converted = conv_balances(database, converted, use_conversion, last_one)
          GoTo next_j
    End Select
            
    Select Case test_conversion
    Case "D2X"
       If converted <> "" Then converted = Day(converted) & " " & MonthName(Month(converted), True) & " " & Right(Year(converted), 2)
    Case "D2", "D4", "D2,34,1,2", "D2,34,3,4", "D2,34,5,6", "D2,34,7,8", "D2,34,9,10", "D2,34,11,12", "D2,0" 'mc 29apr99
        If converted <> "" Then
           If how <> 2 Then
              temparr = Split(converted, Chr(253), -1, vbBinaryCompare)
              max = UBound(temparr)
              For I = 0 To max
                 If IsNumeric(temparr(I)) Then
                    temp = pick.date_pick_to_vb(Val(temparr(I)))
                    temparr(I) = Day(temp) & "/" & Month(temp) & "/" & Right(Year(temp), 2)
                 End If
              Next I
              converted = Join(temparr, Chr(253))
           End If
        End If
    Case "DT"
        converted = Day(Now) & "/" & Month(Now) & "/" & Right(Year(Now), 2) 'Date$
    Case "DTP"
        temp = pick.date_vb_to_pick(Day(Now) & "/" & Month(Now) & "/" & Right(Year(Now), 2), converted, 0)
    Case "MT"
        If fld_dt <> "" Then
           If how <> 2 Then
              max = pick.dcount(converted, Chr(253))
              temp = ""
              For I = 1 To max
                 temp3 = pick.extract(converted, 1, I, 0)
                 If temp3 <> "" Then temp = pick.Replace(temp, 1, I, 0, pick.time_pick_to_vb(Val(temp3)))
              Next I
              converted = temp
           End If
        End If
    Case "dec2": If IsNumeric(converted) Then converted = FormatCurrency(converted, 2)
    Case "MD2", "MD0", "MD1", "MD3", "MD4", "MD2>0", "MD0>0", "MD1>0", "MD3>0", "MD4>0", "MD2<0" 'mc 23may99
       dec_places = CInt(Mid(use_conversion, 3, 1))
       If dec_places = 0 Then the_format = "#0" Else the_format = "#0." & String(dec_places, "0") & "##"
       If converted <> "" Then
          max = pick.dcount(converted, Chr(253))
          temp = ""
          For I = 1 To max
             temp3 = pick.extract(converted, 1, I, 0)
             If IsNumeric(temp3) Then 'mc 9jun99
                temp3 = Format$(Val(temp3) / (10 ^ dec_places), the_format)
             End If
             temp = pick.Replace(temp, 1, I, 0, temp3)
          Next I
          converted = temp
       End If
    Case "MAIL_ADDRESS", "RES_ADDRESS"
        I = 1: fld_dt = pick.delet(fld_dt, 1, 0, 0) 'remove id added mc 6may99
        If Left(use_conversion, 1) = "R" Then
           temp = pick.extract(fld_dt, 5, 2, 0)
           If temp = "" Then I = 1 Else I = 2
        End If
        temp = pick.trimm(pick.extract(fld_dt, 2, I, 0) & " " & pick.extract(fld_dt, 3, I, 0) & " " & pick.extract(fld_dt, 4, I, 0) & " " & pick.extract(fld_dt, 5, I, 0))
        converted = temp
    Case "STREET_NO"
        If IsNumeric(Left(fld_dt, 1)) Then temp = pick.Field(fld_dt, " ", 1) Else temp = ""
        converted = temp
    Case "STREET_NAME"
        If IsNumeric(Left(fld_dt, 1)) Then temp = Mid(fld_dt, pick.Index(fld_dt, " ", 1) + 1) Else temp = fld_dt
        converted = temp
    Case "OWNERS35", "OWNERS37", "OWNERS36" ',NAME", "OWNERS,ADDRESS"
       converted = ""
       temp3 = Mid(test_conversion, 7) 'mco 28mar01
       tempint = CInt(temp3)
       If d3_readstr(database, temp, "client", fld_dt, tempint, 0, 0) = 0 Then
          temparr = Split(temp, Chr(253), -1, vbBinaryCompare)
          max = UBound(temparr)
          For I = 0 To max
             If d3_readstr(database, temp3, "client", temparr(I)) <> 0 Then temp3 = temparr(I)
             temparr2 = Split(temp3, Chr(254), 7, vbBinaryCompare)
             ReDim Preserve temparr2(5)
             temp = Trim(temparr2(0) & " " & temparr2(5)) 'attr-1 as array starts at 0
             If converted = "" Then converted = temp Else converted = converted & Chr$(253) & temp
          Next I
       End If
    Case "5"
       If fld_dt <> "" Then
          If how <> 2 Then
             temp = pick.date_pick_to_vb(Val(converted))
          Else
             temp = converted
          End If
          temp = DateDiff("m", temp, Now)
          converted = Int(Val(temp) / 12) & "yrs" & (Val(temp) Mod 12) & "mths"
        End If
    Case ".1"
       converted = pick.Field(converted, ".", 1)
    Case ".2"
       converted = pick.Field(converted, ".", 2)
    Case ".3"
       converted = pick.Field(converted, ".", 3)
    Case "Last inspected"
       'xyzconverted = last_inspected(cur_module, cur_dbno, converted, 1, 2, "")  'attr1 has pool_id, attr 2 has date - sort on this so can get first only
    Case "Last complied"
       'xyzconverted = last_inspected(cur_module, cur_dbno, converted, 1, 7, "")  'attr1 has pool_id, attr 2 has date - sort on this so can get first only
    Case "loanbal" 'note fld_dt has the id in 'attr' 1 so 2 means attr1 and 19 means attr18 in the read item
        If d3_readstr(database, temp, "tdebtor", pick.extract(fld_dt, 2, 0, 0), 3) <> 0 Then temp = "0"
        converted = CStr(CCur(temp) + pick.extractcur(fld_dt, 19, 0, 0))
    Case Else
       If Left(test_conversion, 2) = "sr" Then
          Set tempobj = CreateObject("cka_ta31.ta31")
          converted = tempobj.sr(database, use_conversion, converted)
          Set tempobj = Nothing
'         converted = sr(database, use_conversion, converted)
       End If
    End Select
next_j:

  Next j
    
penultimate = last_one
last_one = converted
conv_out = converted

End Function


Public Function d3_writemat(database As String, tbl_name As String, rd() As String) As String

Dim numcols As Long, nx As Long
Dim rd3 As New clsD3DynamicArray
   
    On Error GoTo d3_writemat_failed

    If InStr(tbl_name, ".mdb\") <> 0 Then ' ms access file
       d3_writemat = writing_msaccess(rd(), tbl_name)
       Exit Function
    Else 'd3 file
       'If Right(tbl_name, 1) = "\" Then
       '   d3_writemat = write_dos_mat(rd(), tbl_name)
       '   Exit Function
       'End If
       numcols = UBound(rd)
       If UBound(rd) = 0 Then
          rd3.brCString = ""
       Else
          rd3.brCString = rd(1)
          For nx = 2 To numcols
             rd3.brCString = rd3.brCString & Chr(254) & rd(nx)
          Next nx
       End If
       d3_writemat = d3_writedyn(database, tbl_name, rd(0), rd3)
       Exit Function
    End If
    
d3_writemat_failed:
    d3_writemat = "2"
    Exit Function
    
End Function


Public Function d3_subcall(subnum As Integer, the_answer As Variant) As String

Dim result As Boolean
Dim d3Environment As clsD3Environment, d3domain As clsD3NetDomain, d3vme As clsD3VirtualMachine, logentry As String
Dim logon As String
Dim d3rulecatalog As clsD3RuleCatalog

logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 4, logentry, -1, d3rulecatalog)
If logon <> "" Then Exit Function

result = g_d3rulemodules(subnum).brCall(the_answer)
d3_subcall = CStr(the_answer)

logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)

End Function


Public Function msa_select(database_name As String, sentence As String, myids() As String, pick_cnt As Long, start As Long, finish As Long, Optional dropdown As Integer = 0, Optional sumonly As Integer = 0, Optional delimiter As String = "") As Long

Dim num_items As Long, cnt As Long, j As Integer
Dim myset As Recordset
Dim use_start_finish As Boolean
Dim within_range As Boolean
Dim dbs As database

If delimiter = "" Then delimiter = Chr(8)

If start = 0 And finish = 0 Then
   use_start_finish = False
Else
   use_start_finish = True
End If

   num_items = 0:  cnt = 0
   On Error GoTo msa_select_open_error
   
   Set dbs = OpenDatabase(database_name)
   
   On Error GoTo msa_select_error
   Set myset = dbs.OpenRecordset(sentence, dbOpenSnapshot)
   If myset.BOF And myset.EOF Then
      myset.Close
      dbs.Close
      msa_select = 0
      pick_cnt = 0
      Exit Function
   End If
 
myset.MoveLast
pick_cnt = myset.RecordCount

myset.MoveFirst
Do While Not (myset.EOF)
     num_items = num_items + 1
      
     If use_start_finish Then
        If num_items >= start And num_items <= finish Then within_range = True
        If num_items > finish Then Exit Do
     End If
     
     If within_range Or use_start_finish = False Then
        ReDim Preserve myids(cnt)
        If IsNull(myset(0)) Then myids(cnt) = "" Else myids(cnt) = myset(0) 'mco 11sep01
        If dropdown = 1 Then
           For j = 1 To myset.Fields.Count - 1
              myids(cnt) = myids(cnt) & delimiter
              If Not (IsNull(myset(j))) Then myids(cnt) = myids(cnt) & myset(j)
           Next j
        End If
        cnt = cnt + 1
     End If
     
     myset.MoveNext
Loop

     msa_select = num_items

     myset.Close
     dbs.Close
     Exit Function

msa_select_error:
     dbs.Close
msa_select_open_error:
     msa_select = 1
     pick_cnt = -1
     ReDim myids(0): myids(0) = Err & " -  " & Error(Err) & " - " & sentence
     Exit Function

End Function
Public Function reading_msaccess(rd() As String, tbl_name As String) As Integer 'mc 08jan00 , id As String) As Integer
'
' retrieve data from database table
'
Dim table_index As Integer, numcols As Integer, nx As Integer
Dim database_name As String, fname As String, kk As Integer
Dim maxdb As Integer, maxtb As Integer
Dim defs As TableDef
Dim dbs As database
Dim the_table As Recordset

    'c:\ckashare\orkh\orkh.mdb\nationality
    nx = InStr(tbl_name, ".mdb\") 'mco 28apr99
    database_name = Left(tbl_name, nx + 3) 'mc 28apr99
    fname = Mid(tbl_name, nx + 5) 'mc 28apr99
        
    On Error GoTo reading_open_failed
    For kk = 1 To UBound(g_dbnames)
       If g_dbnames(kk) = database_name Then
          Set dbs = g_dbs(kk)
          GoTo Found
        End If
    Next kk
    GoTo new_db
Found:
    For kk = 1 To UBound(g_tbnames)
       If g_tbnames(kk) = fname Then
          Set the_table = g_tables(kk)
          Set defs = g_defs(kk)
          the_table.Index = defs.Indexes(g_index(kk)).Name
          GoTo found_all
        End If
    Next kk
    GoTo new_tb
new_db:
    maxdb = UBound(g_dbnames) + 1
    ReDim Preserve g_dbnames(maxdb)
    ReDim Preserve g_dbs(maxdb)
    Set dbs = OpenDatabase(database_name)
    g_dbnames(maxdb) = database_name
    Set g_dbs(maxdb) = dbs
new_tb:
    maxtb = UBound(g_tbnames) + 1
    ReDim Preserve g_tbnames(maxtb)
    ReDim Preserve g_tables(maxtb)
    ReDim Preserve g_defs(maxtb)
    
    Set the_table = dbs.OpenRecordset(fname)
    g_tbnames(maxtb) = fname
    Set g_tables(maxtb) = the_table

    Set defs = dbs.TableDefs(fname)
    Set g_defs(maxtb) = defs
    
    ReDim Preserve g_index(maxtb)

    If defs.Indexes.Count = 1 Then
       the_table.Index = defs.Indexes(0).Name
       g_index(maxtb) = 0
    Else
      On Error GoTo msaccess_index_error
      For nx = 0 To defs.Indexes.Count - 1
         If defs.Indexes(nx).Primary = True Then
            the_table.Index = defs.Indexes(nx).Name
            g_index(maxtb) = nx
            Exit For
         End If
      Next nx
      On Error GoTo reading_msaccess_failed
    End If
    
found_all:
    numcols = the_table.Fields.Count - 1
    ReDim Preserve rd(numcols)
    
    reading_msaccess = 1
        
    the_table.Seek "=", rd(0)
    
    If Not (the_table.NoMatch) Then ' id exists
       reading_msaccess = 0
       For nx = 1 To numcols
          If IsNull(the_table(nx)) Then
             rd(nx) = ""
          Else
             Select Case the_table(nx).Type
                'Case dbText
                '   wth = the_table(nx).Size
                '   If wth <> 0 Then the_table(nx) = Left(rd(nx), wth)
                'Case dbBoolean
                '   If rd(nx) = "Y" Then rd(nx) = True Else rd(nx) = False
                Case dbDate
                   If InStr(the_table(nx), ":") = 0 Then rd(nx) = DateValue(the_table(nx)) Else rd(nx) = the_table(nx)
                Case Else
                   rd(nx) = CStr(the_table(nx))
             End Select
          End If
       Next nx
    End If
    'dbs.Close
    Exit Function
    
reading_msaccess_failed:
    'dbs.Close
reading_open_failed:
    reading_msaccess = 3
    Exit Function
    
msaccess_index_error:
    the_table.Index = defs.Indexes(0).Name
    Resume Next
    
End Function
Public Function conv_group(database As String, original As String, conversion As String) As String

'do pick group extracts eg G*1 G1*1 etc

Dim fld1 As Integer, fld2 As Integer, sepchar As String, I As Integer
Dim j As Integer, result As String, use_conversion As String, converted As String

result = ""
For j = 1 To 999
    use_conversion = pick.Field(conversion, ";", j)
    If use_conversion = "" Then Exit For
    Select Case Left(use_conversion, 1)
    Case "G"
       converted = pick.extract(original, 1, 0, 0)
       If IsNumeric(Mid(use_conversion, 2, 1)) Then
          If IsNumeric(Mid(use_conversion, 3, 1)) Then
             sepchar = Mid(use_conversion, 4, 1)
             fld1 = CInt(Mid(use_conversion, 2, 2)): fld2 = 5
          Else
             sepchar = Mid(use_conversion, 3, 1)
             fld1 = CInt(Mid(use_conversion, 2, 1)): fld2 = 4
          End If
       Else
          fld1 = 0: sepchar = Mid(use_conversion, 2, 1): fld2 = 3
       End If
       fld2 = CInt(Mid(use_conversion, fld2))
       If fld1 = 0 Then
          I = pick.Index(converted, sepchar, fld2)
          If I <> 0 Then
             converted = Left(converted, I - 1)
          End If
       Else
          I = pick.Index(converted, sepchar, fld1)
          If I = 0 Then
             converted = ""
          Else
             converted = Mid(converted, I + 1)
             I = pick.Index(converted, sepchar, fld2)
             If I <> 0 Then
                converted = Left(converted, I - 1)
             End If
          End If
       End If
       result = result & converted
   Case "C"
      result = result & Mid(use_conversion, 2)
   Case "T"
      Call pick.sr_change(use_conversion, ":", ";")
      result = result & conv_translate(database, use_conversion, original)
   Case Else
      If IsNumeric(use_conversion) Then
         fld1 = CInt(use_conversion) + 1 'id is in attr 1
         result = result & pick.extract(original, fld1, 0, 0)
      End If
   End Select
Next j
conv_group = result
       
End Function

Public Function conv_arithmetic(converted As String, use_conversion As String, last_one As String, penultimate As String) As String

'do arithmetic on values eg A*-1 - multiply by -1 - needed for all general ledger values

Dim fld1 As Currency, what As String, fld2 As Currency, operator As String

     operator = Mid(use_conversion, 2, 1)
     what = Mid(use_conversion, 3)

     If what = "V" Then
        converted = last_one
        If IsNumeric(penultimate) Then fld1 = CCur(penultimate) Else fld1 = 0
     Else
        fld1 = CCur(what)
     End If
     If IsNumeric(converted) Then fld2 = CCur(converted) Else fld2 = 0
        
Select Case operator
   Case "*"
      converted = CStr(fld2 * fld1)
   Case "-"
      converted = CStr(fld2 - fld1)
   Case "+"
      converted = CStr(fld2 + fld1)
   Case "/"
      converted = CStr(fld2 / fld1)
End Select

conv_arithmetic = Format(CCur(converted), "#.00")

End Function

Public Function conv_balances(database As String, converted As String, use_conversion As String, Last As String) As String

'get general ledger balance - group/class attr 3 - subclass attr 4

Dim attr As Integer, rderr As Integer, rd() As String, temp As Currency, temp2 As String

If use_conversion = "BU" Then 'total budget wanted
   ReDim rd(0): rd(0) = converted
   rderr = d3_readmat(database, rd(), "GEN.L")
   If UBound(rd) < 8 Then conv_balances = "0": Exit Function
   If rd(7) = "A" Then
      temp2 = pick.extract(rd(8), 1, 1, 0)
      If IsNumeric(temp2) Then temp = CCur(temp2) * -1 Else temp = 0
      conv_balances = CStr(temp)
      Exit Function
   End If
   temp = 0
   For attr = 1 To 12
      temp2 = pick.extract(rd(8), 1, attr, 0)
      If IsNumeric(temp2) Then temp = temp - CCur(temp2)
   Next attr
   conv_balances = CStr(temp)
   Exit Function
End If

If Left(use_conversion, 5) = "BJPER" Then 'Job ledger percentages  RGM July 99
    Dim Count As Integer, limit As Integer

    If converted = "0" Or converted = "0.00" Or Len(converted) < 1 Or Last = "0" Or Last = "0.00" Or Last = ".00" Or Len(Last) < 1 Then
        conv_balances = ""  'Do not try to divide by zero or null
        Exit Function
    End If

    temp = converted / Last  'Values are already available so use them
    If Len(use_conversion) > 5 Then
        temp2 = "#."
        limit = Right(use_conversion, 1) 'Get number appended to conversion
        For Count = 1 To limit
            temp2 = temp2 & "0"
        Next
        conv_balances = Format(temp, temp2)
    Else
        conv_balances = temp
    End If
    Exit Function
End If

If Left(use_conversion, 3) = "BCR" Then 'mc 10jul99 to next one creditor convert debits to negative values
   temp2 = pick.extract(converted, 4, 0, 0) '4 not 3 as id is in 1
   attr = 1
   If IsNumeric(temp2) Then
      If CInt(temp2) >= 50 Then attr = -1
   End If
   rderr = CInt(Mid(use_conversion, 4)) + 1 'id is in attr 1
   temp2 = pick.extract(converted, rderr, 0, 0)
   If IsNumeric(temp2) Then temp = CCur(temp2) Else temp = 0
   temp = attr * temp
   conv_balances = CStr(temp)
   Exit Function
End If 'mc 10jul99

If pick.Index(converted, ".", 2) Then attr = 4 Else attr = 3
use_conversion = "TGEN.L;" & attr

converted = conv_translate(database, use_conversion, converted)
If IsNumeric(converted) Then
   converted = Format(-1 * CCur(converted) / 100, "#.00")
Else
   converted = 0
End If
conv_balances = converted

End Function

Function read_dos_mat(rd() As String, the_file As String) As Integer

Dim filenum As Integer, var As String, cnt As Integer

    read_dos_mat = 1
    On Error GoTo read_dos_mat_exit

    filenum = FreeFile
    Open the_file & rd(0) For Input Access Read As #filenum
    Line Input #filenum, var
    ReDim Preserve rd(1): rd(1) = var: cnt = 1
    Do While Not EOF(filenum) ' Check for end of file.
       Line Input #filenum, var
       cnt = cnt + 1: ReDim Preserve rd(cnt): rd(cnt) = var
    Loop
    Close #filenum
    read_dos_mat = 0

Exit Function

read_dos_mat_exit:
    Close #filenum
    Exit Function

End Function

Public Function ReadDosFile(FileName As String, FileContents As String) As Boolean

 Dim fso, ThisRead
  
 FileContents = ""
        
 On Error GoTo ThisErr
 
 Set fso = New Scripting.FileSystemObject

 Set ThisRead = fso.OpenTextFile(FileName, ForReading, False)
 FileContents = ThisRead.ReadAll
 ThisRead.Close
 ReadDosFile = True
        
 Exit Function

ThisErr:
  ReadDosFile = False
  FileContents = Err & " - " & Error(Err)
  
End Function
Public Function writing_msaccess(rd() As String, tbl_name As String, Optional deleting As String = "") As String

Dim table_index As Integer, numcols As Integer, nx As Integer
Dim database_name As String, fname As String, max As Integer, wth
Dim kk As Integer, maxdb As Integer, maxtb As Integer
Dim defs As TableDef
Dim dbs As database
Dim the_table As Recordset

    On Error GoTo writing_msaccess_failed
    
    'c:\ckashare\orkh\orkh.mdb\nationality
    nx = InStr(tbl_name, ".mdb\")
    database_name = Left(tbl_name, nx + 3)
    fname = Mid(tbl_name, nx + 5)
        
    For kk = 1 To UBound(g_dbnames)
       If g_dbnames(kk) = database_name Then
          Set dbs = g_dbs(kk)
          GoTo Found
        End If
    Next kk
    GoTo new_db
Found:
    For kk = 1 To UBound(g_tbnames)
       If g_tbnames(kk) = fname Then
          Set the_table = g_tables(kk)
          Set defs = g_defs(kk)
          If rd(0) <> "" Then the_table.Index = defs.Indexes(g_index(kk)).Name
          GoTo found_all
        End If
    Next kk
    GoTo new_tb
new_db:
    maxdb = UBound(g_dbnames) + 1
    ReDim Preserve g_dbnames(maxdb)
    ReDim Preserve g_dbs(maxdb)
    Set dbs = OpenDatabase(database_name)
    g_dbnames(maxdb) = database_name
    Set g_dbs(maxdb) = dbs
new_tb:
    maxtb = UBound(g_tbnames) + 1
    ReDim Preserve g_tbnames(maxtb)
    ReDim Preserve g_tables(maxtb)
    ReDim Preserve g_defs(maxtb)
    
    Set the_table = dbs.OpenRecordset(fname)
    g_tbnames(maxtb) = fname
    Set g_tables(maxtb) = the_table

    'For nx = 0 To dbs.TableDefs.Count - 1
    'MsgBox dbs.TableDefs(nx).SourceTableName
    'Next nx
    'For nx = 0 To dbs.TableDefs.Count - 1
    'MsgBox dbs.TableDefs(nx).Name
    'Next nx
    Set defs = dbs.TableDefs(fname)
    Set g_defs(maxtb) = defs
     
    ReDim Preserve g_index(maxtb)

    If rd(0) <> "" Then
       If defs.Indexes.Count = 1 Then
          the_table.Index = defs.Indexes(0).Name
          g_index(maxtb) = 0
       Else
          For nx = 0 To defs.Indexes.Count - 1
             If defs.Indexes(nx).Primary = True Then
                the_table.Index = defs.Indexes(nx).Name
                g_index(maxtb) = nx
                Exit For
             End If
          Next nx
       End If
    End If

found_all:
    If rd(0) <> "" Then
       the_table.Seek "=", rd(0)
       If the_table.NoMatch Then ' id exists
          the_table.AddNew
       Else
          If deleting = "D" Then
             the_table.Delete
             GoTo all_done
          Else
             the_table.Edit
          End If
       End If
       the_table(0) = rd(0)
    Else   ' No Id Supplied - Therefore Auto Numbering
       the_table.AddNew
    End If
    
    numcols = UBound(rd)
    For nx = 1 To numcols
       If rd(nx) = "" Then
          the_table(nx) = Null
       Else
          Select Case the_table(nx).Type
             Case dbText
                wth = the_table(nx).Size
                If wth <> 0 Then the_table(nx) = Left(rd(nx), wth)
             'Case dbBoolean
             '   If rd(nx) = "Y" Then rd(nx) = True Else rd(nx) = False
             Case dbDate 'time will have : in it ?
                If InStr(rd(nx), ":") = 0 Then the_table(nx) = DateValue(rd(nx)) Else the_table(nx) = rd(nx)
             Case Else
                the_table(nx) = rd(nx)
          End Select
       End If
    Next nx
    max = the_table.Fields.Count - 1
    For nx = numcols + 1 To max
       the_table(nx) = Null
    Next nx
    the_table.Update
all_done:
    writing_msaccess = "0"
    On Error GoTo 0
    'dbs.Close
    Exit Function
    
writing_msaccess_failed:
    'dbs.Close
    writing_msaccess = Err & " - " & Error(Err)
    Exit Function

End Function
Public Function write_dos_mat(rd() As String, tbl_name As String) As Integer

write_dos_mat = 1

End Function

Public Function d3_select_str(logentry As String, sentence As String, Optional dropdown As Integer = 0, Optional default As String = "", Optional extended As String = "") As String

Dim id As String, mylist As clsD3SelectList, myids As String
Dim pos1 As Integer, pos2 As Integer, pos3 As Integer, pos4 As Integer
Dim d3Environment As clsD3Environment, d3domain As clsD3NetDomain, d3vme As clsD3VirtualMachine
Dim logon As String, vme_done As Boolean, cnt As Integer, pos As Integer, default_found As Integer

vme_done = False
On Error GoTo d3_select_str_error

logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 1, logentry)
If logon <> "" Then
   d3_select_str = "Error in vme " & logentry & " - " & logon
   Exit Function
End If
Set mylist = d3vme.brOpenSelectList(sentence)

If dropdown = 1 Then myids = "<OPTION VALUE="""">" Else myids = ""
cnt = 0: default_found = 0
Do While mylist.brReadNext(id)
   If dropdown = 0 Then
      myids = myids & "<OPTION VALUE=""" & id & """>" & id  'the value for link
   Else
      If cnt Mod 2 = 0 Then
         If Left(id, 1) = "@" Or extended <> "" Then
            pos = InStr(id, ".")
            If pos <> 0 Then id = Mid(id, pos + 1)
         End If
         If default = id Then
            default_found = 1
         Else
            myids = myids & "<OPTION VALUE=""" & id & """>" 'the id
         End If
      Else
         If default_found = 1 Then
            myids = "<OPTION VALUE=""" & default & """>" & id & myids
            default_found = 0
         Else
            myids = myids & id 'the value
         End If
      End If
      cnt = cnt + 1
   End If
Loop

d3_select_str = myids
logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)
Exit Function

d3_select_str_error:
   d3_select_str = "Error in d3_select_str " & sentence
   If vme_done Then logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)
   Exit Function

End Function

Public Function msa_select_str(database_name As String, sentence As String, Optional dropdown As Integer = 0, Optional default As String = "", Optional separator As String = "<BR>") As String

Dim id As String
Dim myset As Recordset, the_id As String
Dim dbs As database, myids As String
Dim datum As String, kk As Integer, splitter As String

   'On Error GoTo msa_select_open_error
   
   id = database_name
   If Right(id, 1) = "\" Then id = Left(id, Len(id) - 1)
   Set dbs = OpenDatabase(id)
   
   'On Error GoTo msa_select_str_error

   Set myset = dbs.OpenRecordset(sentence, dbOpenSnapshot)
   If myset.BOF And myset.EOF Then
      myset.Close
      dbs.Close
      msa_select_str = ""
      Exit Function
   End If
 
   Select Case dropdown
      Case 1: myids = "<OPTION VALUE="""">": splitter = " "
      Case 2: myids = "<TABLE>": splitter = "<TD>"
      Case Else: myids = "": splitter = " "
   End Select
   
   myset.MoveFirst
   Do While Not (myset.EOF)
      If IsNull(myset(0)) Then
         the_id = ""
      Else
         Select Case myset(0).Type
            Case dbCurrency: the_id = FormatCurrency(myset(0), 2)
            Case dbDate: the_id = DateValue(myset(0))
            Case Else: the_id = myset(0)
         End Select
      End If
      If dropdown = 1 Then
         datum = "<OPTION VALUE=""" & the_id & """>" & myset(1)
      Else
         datum = the_id
         For kk = 1 To myset.Fields.Count - 1
            Select Case myset(kk).Type
               Case dbCurrency: datum = datum & splitter & FormatCurrency(myset(kk), 2)
               Case dbDate: datum = datum & splitter & DateValue(myset(kk))
               Case Else: datum = datum & splitter & myset(kk)
            End Select
         Next kk
         If myids <> "" Then datum = separator & datum
      End If
      If default = myset(0) And default <> "" Then
         myids = datum & myids
      Else
        myids = myids & datum
      End If
      myset.MoveNext
   Loop

   Select Case dropdown
      Case 1:
      Case 2: myids = myids & "</TABLE>"
      Case Else:
   End Select
   
   msa_select_str = myids
   myset.Close
   dbs.Close
   Exit Function

msa_select_str_error:
     dbs.Close
msa_select_open_error:
     msa_select_str = Err & " -  " & Error(Err) & " - " & sentence 'mc 31mar00
     Exit Function

End Function
Public Function execute_tcl(logentry As String, command As String, Passdata As Variant, Optional sign_on As Integer = 1) As String

Dim aTcl As clsD3TclCommand

Dim aCapture As clsD3DynamicArray
Dim X As Long, I As Integer, aReturn As clsD3DynamicArray
Dim d3Environment As clsD3Environment, d3domain As clsD3NetDomain, d3vme As clsD3VirtualMachine
Dim logon As String, who As String
Dim conn() As String '0-server,1-account,2=username,3=user password,4=could be account password but not set in login_check.asp

'mcSet aTcl = g_d3VME.brCreateTclCommand(g_UserID, g_database, g_UserPW)

logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 1, logentry)
If logon <> "" Then
   execute_tcl = "Error in d3_select " & logon
   Exit Function
End If

conn = Split(logentry, Chr(254), -1, vbBinaryCompare)
ReDim Preserve conn(4)
Set aTcl = d3vme.brCreateTclCommand(conn(2), conn(1), conn(3))
Call aTcl.brExecute(D3ExecuteWithBoth, "SP-ASSIGN HS")
If sign_on = 1 Then
   Call aTcl.brExecute(D3ExecuteWithBoth, "who")
   Set aCapture = aTcl.brCapturing
   who = aCapture.brCString
   I = InStr(who, " ")
   who = Left(who, I - 1)
   If IsNumeric(who) Then who = CStr(CInt(who) + 1)
   I = d3_writestr(conn(1), "DICT OPSEC", "T" & who, String(24, "1"))
End If

If IsArray(Passdata) Then
    X = UBound(Passdata)
    For I = 0 To X
        Call aTcl.brData(CStr(Passdata(I)))
    Next I
Else
    If Not (IsEmpty(Passdata)) Then Call aTcl.brData(CStr(Passdata))
End If
Call aTcl.brExecute(D3ExecuteWithBoth, command)

Set aCapture = aTcl.brCapturing
Set aReturn = aTcl.brReturning

execute_tcl = aCapture.brCString

Call d3vme.brCloseTclCommand(aTcl)
Set aCapture = Nothing
Set aReturn = Nothing
Set aTcl = Nothing

logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)

End Function


Public Function d3_writestr(database As String, tbl_name As String, id As String, rd As String, Optional delimiter As String = "") As String

Dim numcols As Long, nx As Long
Dim rd3 As New clsD3DynamicArray, wt() As String, j As Integer, max As Integer
   
    If delimiter = "" Then delimiter = Chr(254)

    If InStr(tbl_name, ".mdb\") <> 0 Then ' ms access file
       rd = id & delimiter & rd
       wt = Split(rd, delimiter, , vbBinaryCompare)
       d3_writestr = writing_msaccess(wt(), tbl_name)
    Else 'd3 file
       If delimiter = Chr(8) Then rd = Replace(rd, Chr(8), Chr(254))
       rd3.brCString = rd
       d3_writestr = d3_writedyn(database, tbl_name, id, rd3)
    End If
    Exit Function
    
End Function


Public Function d3_vme_on_off(d3Environment As clsD3Environment, d3domain As clsD3NetDomain, d3vme As clsD3VirtualMachine, on_off As Integer, Optional logentry As String = "", Optional vsPibNumber As Variant = -1, Optional Mydatabase As clsD3Database, Optional sdatabase As String = "", Optional d3rulecatalog As clsD3RuleCatalog) As String

' on_off 1-start, 0-logoff

Dim conn() As String '0-server,1-account,2=username,3=user password,4=could be account password but not set in login_check.asp

d3_vme_on_off = ""
On Error GoTo vme_error

Select Case on_off
   Case 3
      Call d3domain.brCloseDatabase(Mydatabase)
      GoSub close_env_domain
   Case 2
      GoSub open_env_domain
      Set Mydatabase = d3domain.brOpenDatabase(logentry) 'is database name
   Case 1
      GoSub open_env_domain
      conn = Split(logentry, Chr(254), -1, vbBinaryCompare)
      ReDim Preserve conn(4)
      Set d3vme = d3domain.brOpenVirtualMachine(conn(0), vsPibNumber)
      If Not (d3vme.brLogon(conn(2), conn(1), conn(3), conn(4))) Then
         d3_vme_on_off = "Invalid User Name or Password!" & vbCrLf & vbCrLf & "D3 Server: " & conn(0)
      End If
   Case 0
      Call d3vme.brLogoff
      Call d3domain.brCloseVirtualMachine(d3vme)
      GoSub close_env_domain
   Case 5
      Call d3domain.brCloseRuleCatalog(d3rulecatalog)
      GoSub close_env_domain
   Case 4
       GoSub open_env_domain
       Set d3rulecatalog = d3domain.brOpenRuleCatalog
End Select
On Error GoTo 0
Exit Function

open_env_domain:
   Set d3Environment = New clsD3Environment
   d3Environment.brCasing = True
   d3Environment.brCurrency = "L"
   d3Environment.brDecimal = "~"
   d3Environment.brGrouping = "-"
   d3Environment.brTclFlags = 255
   Set d3domain = d3Environment.brOpenDomain("")
   Return
   
close_env_domain:
   Call d3Environment.brCloseDomain(d3domain)
   Set d3domain = Nothing
   Set d3Environment = Nothing
   Return

vme_error:
   d3_vme_on_off = Err & " " & Error(Err)
   Exit Function
   
End Function
Public Function conv_password(user_input As String) As String

' this routine calculates passwords as per D3 system - eg password program
' simply uses a "UC" conversion
    
    If user_input = "" Then
       conv_password = ""
    Else
       conv_password = "" 'g_d3VME.brIConv(user_input, "UC")
    End If
    
End Function

Public Function d3_file_exists(database As String, PickFile As String) As Integer

    If d3_openfile(database, PickFile, "", "O") = 1 Then d3_file_exists = 0 Else d3_file_exists = 1
    Exit Function
    
End Function

Public Function reading_sql(rd() As String, access_string As String) As Integer
'
' retrieve data from sql server database table
'
Dim cnn1 As ADODB.Connection
Dim the_rset As ADODB.Recordset
Dim sql As String, key As String
Dim nx As Integer, numcols As Integer
Dim server As String, database As String, tbl_name As String, elems() As String

    'On Error GoTo reading_sql_failed
    
'sql,server,database,table

    elems = Split(access_string, ",")
    server = elems(1)
    database = elems(2)
    tbl_name = elems(3)
    
    Set cnn1 = New ADODB.Connection
    cnn1.ConnectionString = "driver={SQL Server};" & "server=" & server & ";uid=;pwd=;database=" & database
    cnn1.ConnectionTimeout = 30
    cnn1.Open
     
    Set the_rset = New ADODB.Recordset
    the_rset.CursorType = adOpenKeyset
    the_rset.LockType = adLockOptimistic
    the_rset.Open tbl_name, cnn1, , , adCmdTable

    key = the_rset.Fields(0).Name
    sql = "SELECT * FROM " & tbl_name & " WHERE (((" & key & ")=" & rd(0) & "))"
    Set the_rset = cnn1.Execute(sql)
    If the_rset.BOF And the_rset.EOF Then reading_sql = 1: GoTo sql_exit
   
    numcols = the_rset.Fields.Count - 1
    ReDim Preserve rd(numcols)
    On Error GoTo must_be_null 'this done as getting strange error 'Invalid use of null'
                               'when put in msgbox to see errot, it did not occur ???
                               'this technique will work on all error data anyway
    For nx = 0 To numcols
       rd(nx) = the_rset.Fields.Item(nx).Value
    Next nx
    On Error GoTo reading_sql_failed
    reading_sql = 0
   
   'varDate = the_rset!hire_date
 '  MsgBox the_rset!account & " - " & the_rset!Description
   'the_rset!hire_date = #1/1/1900#
   'the_rset.Update
   'MsgBox "  Name - Hire Date"
   'MsgBox "  " & the_rset!fname & " " & the_rset!lName & " - " & the_rset!hire_date

   ' Requery Recordset and reset the hire date.
   'the_rset.Requery
   'the_rset!hire_date = varDate
   'the_rset.Update
   'MsgBox "Data after reset"
   'MsgBox "  Name - Hire Date"
   'MsgBox "  " & the_rset!fname & " " & the_rset!lName & " - " & the_rset!hire_date

sql_exit:
    the_rset.Close
    cnn1.Close
    Exit Function

reading_sql_failed:
    cnn1.Close
    reading_sql = 3
    Exit Function
    
must_be_null:
    Resume Next

End Function


Public Function rtf_open(logentry As String, fso, textfile, Optional suffix As String = ".rtf", Optional keyname As String = "", Optional name_only As Boolean = False, Optional want_excel_name As String = "") As String

Dim hdr1 As String, hdr2 As String, fileno As Integer, docfilename As String
Dim username As String, docpath As String, xtra As String

   username = pick.extract(logentry, 3, 0, 0)
   Select Case suffix
      Case ".rtf": docpath = pick.extract(logentry, 5, 0, 0)
      Case ".asp", ".htm": docpath = pick.extract(logentry, 6, 0, 0)
      Case ".txt": docpath = "": docfilename = pick.extract(logentry, 7, 0, 0) & "_" & username & "_" & keyname & suffix: If name_only Then GoTo name_only
   End Select

   Set fso = New Scripting.FileSystemObject
   If docpath <> "" Then
      If want_excel_name <> "" Then
         docfilename = "\" & want_excel_name & suffix
      Else
         fileno = 0
         docfilename = "\" & username & "_" & CStr(fileno) & suffix
         Do While fso.FileExists(docpath & docfilename)
            fileno = fileno + 1
            docfilename = "\" & username & "_" & CStr(fileno) & suffix
         Loop
      End If
   End If

   Set textfile = fso.CreateTextFile(docpath & docfilename, True)
   If docpath = "" Then GoTo name_only

Select Case suffix
   Case ".rtf"
      hdr1 = "{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fmodern\fprq1\fcharset0 Courier New;}{\f1\fswiss\fcharset0 Arial;}}"
      hdr2 = "\viewkind4\uc1\pard\f0\fs18\landscape\paperw16840\paperh11907\margl567\margr567\margt1134\margb1134 "
      textfile.WriteLine (hdr1)
      textfile.WriteLine (hdr2)
   Case ".asp", ".htm"
      textfile.WriteLine ("<%")   'Change HTML header to specify Excel's MIME content type
      textfile.WriteLine ("Response.Buffer = True")
      textfile.WriteLine ("Response.ContentType = ""application/vnd.ms-excel""")
      textfile.WriteLine ("%>")
      textfile.WriteLine ("<HTML>")
      textfile.WriteLine ("<HEAD>")
      textfile.WriteLine ("</HEAD>")
      textfile.WriteLine ("<BODY>")
End Select

name_only:
     hdr1 = docpath & docfilename
     If InStr(hdr1, ":") Then hdr1 = Mid(hdr1, InStr(hdr1, ":") + 1)
     hdr1 = Replace(hdr1, "\", "/")
     rtf_open = hdr1

End Function
Public Function gl_years(dbname As String) As String

Dim dbs As database, years As String
Dim posn As Integer, pos As Integer
Dim jj As Integer, tablename As String

      Set dbs = OpenDatabase(dbname)
      years = ""
      For jj = 0 To dbs.TableDefs.Count - 1
         tablename = dbs.TableDefs(jj).Name
         If Left(tablename, 6) = "gen_l_" Then
            tablename = Right(tablename, 2)
            If Left(tablename, 1) = "9" Then tablename = "19" & tablename Else tablename = "20" & tablename
            posn = pick.locate(tablename, years, 1, 1, 0, pos, "AR")
            years = pick.Insert(years, 1, pos, 0, tablename)
         End If
      Next jj
      dbs.Close
      gl_years = years
           
End Function


Public Function d3_select_var(logentry As String, sentence As String, outarray) As Long

Dim cnt As Long, tot As Currency, id As String, myids() As String
Dim mylist As clsD3SelectList, j As Long
Dim use_start_finish As Boolean
Dim within_range As Boolean
Dim pos1 As Long, pos2 As Long 'mco 16mar00
Dim d3Environment As clsD3Environment, d3domain As clsD3NetDomain, d3vme As clsD3VirtualMachine
Dim logon As String, vme_done As Boolean

vme_done = False

On Error GoTo d3_select_error

cnt = 0

logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 1, logentry)
If logon <> "" Then
   d3_select_var = 1 '-1
   ReDim myids(0): myids(0) = "Error in vme " & logentry & " - " & logon
   GoTo exiting
End If
vme_done = True
Set mylist = d3vme.brOpenSelectList(sentence)

Do While mylist.brReadNext(id)
     ReDim Preserve myids(cnt)
     myids(cnt) = id
     cnt = cnt + 1
Loop

d3_select_var = cnt
logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)

exiting:
ReDim outarray(UBound(myids))
For j = 0 To UBound(myids)
    outarray(j) = myids(j)
Next j

Exit Function

d3_select_error:
d3_select_var = 1
ReDim myids(0): myids(0) = "Error in d3_select_var " & sentence
If vme_done Then logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)
GoTo exiting
Exit Function

End Function






Public Function msa_select_var(database_name As String, sentence As String, myids) As Long

Dim cnt As Long, pick_cnt As Long
Dim myset As Recordset
Dim dbs As database

   cnt = 0
   On Error GoTo msa_select_open_error
   
   Set dbs = OpenDatabase(database_name)
   
   On Error GoTo msa_select_error
   Set myset = dbs.OpenRecordset(sentence, dbOpenSnapshot)
   If myset.BOF And myset.EOF Then
      myset.Close
      dbs.Close
      msa_select_var = 0
      pick_cnt = 0
      Exit Function
   End If
 
myset.MoveLast
pick_cnt = myset.RecordCount
ReDim myids(pick_cnt - 1)

myset.MoveFirst
Do While Not (myset.EOF)
     If IsNull(myset(0)) Then myids(cnt) = "" Else myids(cnt) = myset(0)
     cnt = cnt + 1
     myset.MoveNext
Loop

     msa_select_var = pick_cnt
     myset.Close
     dbs.Close
     Exit Function

msa_select_error:
     dbs.Close
msa_select_open_error:
     msa_select_var = 1
     pick_cnt = -1
     ReDim myids(0): myids(0) = Err & " -  " & Error(Err) & " - " & sentence
     Exit Function

End Function




Public Function reading_msaccess_var(tbl_name As String, id As String, rd) As Integer
'
' retrieve data from database table
'
Dim table_index As Integer, numcols As Integer, nx As Integer
Dim database_name As String, fname As String, kk As Integer
Dim maxdb As Integer, maxtb As Integer
Dim defs As TableDef
Dim dbs As database
Dim the_table As Recordset

    'c:\ckashare\orkh\orkh.mdb\nationality
    nx = InStr(tbl_name, ".mdb\") 'mco 28apr99
    database_name = Left(tbl_name, nx + 3) 'mc 28apr99
    fname = Mid(tbl_name, nx + 5) 'mc 28apr99
        
    On Error GoTo reading_open_failed
    For kk = 1 To UBound(g_dbnames)
       If g_dbnames(kk) = database_name Then
          Set dbs = g_dbs(kk)
          GoTo Found
        End If
    Next kk
    GoTo new_db
Found:
    For kk = 1 To UBound(g_tbnames)
       If g_tbnames(kk) = fname Then
          Set the_table = g_tables(kk)
          Set defs = g_defs(kk)
          the_table.Index = defs.Indexes(g_index(kk)).Name
          GoTo found_all
        End If
    Next kk
    GoTo new_tb
new_db:
    maxdb = UBound(g_dbnames) + 1
    ReDim Preserve g_dbnames(maxdb)
    ReDim Preserve g_dbs(maxdb)
    Set dbs = OpenDatabase(database_name)
    g_dbnames(maxdb) = database_name
    Set g_dbs(maxdb) = dbs
new_tb:
    maxtb = UBound(g_tbnames) + 1
    ReDim Preserve g_tbnames(maxtb)
    ReDim Preserve g_tables(maxtb)
    ReDim Preserve g_defs(maxtb)
    
    Set the_table = dbs.OpenRecordset(fname)
    g_tbnames(maxtb) = fname
    Set g_tables(maxtb) = the_table

    Set defs = dbs.TableDefs(fname)
    Set g_defs(maxtb) = defs
    
    ReDim Preserve g_index(maxtb)

    If defs.Indexes.Count = 1 Then
       the_table.Index = defs.Indexes(0).Name
       g_index(maxtb) = 0
    Else
      On Error GoTo msaccess_index_error
      For nx = 0 To defs.Indexes.Count - 1
         If defs.Indexes(nx).Primary = True Then
            the_table.Index = defs.Indexes(nx).Name
            g_index(maxtb) = nx
            Exit For
         End If
      Next nx
      On Error GoTo reading_msaccess_failed
    End If
    
found_all:
    numcols = the_table.Fields.Count - 1
    ReDim rd(numcols)
    rd(0) = id
    
    reading_msaccess_var = 1
        
    the_table.Seek "=", id
    
    If Not (the_table.NoMatch) Then ' id exists
       reading_msaccess_var = 0
       For nx = 1 To numcols
          If IsNull(the_table(nx)) Then
             rd(nx) = ""
          Else
             Select Case the_table(nx).Type
                'Case dbText
                '   wth = the_table(nx).Size
                '   If wth <> 0 Then the_table(nx) = Left(rd(nx), wth)
                'Case dbBoolean
                '   If rd(nx) = "Y" Then rd(nx) = True Else rd(nx) = False
                Case dbDate
                   rd(nx) = DateValue(the_table(nx)) 'Day(the_table(nx)) & "/" & Month(the_table(nx)) & "/" & Year(the_table(nx))
                Case Else
                   rd(nx) = the_table(nx)
             End Select
          End If
       Next nx
    End If
    'dbs.Close
    Exit Function
    
reading_msaccess_failed:
    'dbs.Close
reading_open_failed:
    reading_msaccess_var = 3
    Exit Function
    
msaccess_index_error:
    the_table.Index = defs.Indexes(0).Name
    Resume Next
    
End Function

Public Function d3_readmat_var(database As String, tbl_name As String, id As String, rd) As Integer

Dim rderr As Integer
Dim rd3 As clsD3DynamicArray
Dim numcols As Long, nx As Long

    If InStr(tbl_name, ".mdb\") <> 0 Or Left(tbl_name, 4) = "sql," Then ' ms access file
       If Left(tbl_name, 4) = "sql," Then
          'rderr = reading_sql(rd(), tbl_name)
       Else
          rderr = reading_msaccess_var(tbl_name, id, rd)
       End If
       d3_readmat_var = rderr
       Exit Function
    End If
    
    If Right(tbl_name, 1) = "\" Then
       'd3_readmat_var = read_dos_mat(rd(), tbl_name)
       Exit Function
    End If
    
    rderr = reading_pick(database, rd3, tbl_name, id)
    If rderr <> 0 Then d3_readmat_var = rderr: Exit Function
    
    numcols = rd3.brDCount(Chr(254))
    ReDim rd(numcols)
    rd(0) = id
    For nx = 1 To numcols
       rd(nx) = CVar(rd3.brExtractStr(nx))
    Next nx

    d3_readmat_var = 0
    
End Function
