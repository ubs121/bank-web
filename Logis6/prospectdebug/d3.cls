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
Attribute VB_Exposed = False
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
Private Pick As New Pick
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


Public Function reading_pick(database As String, rd As clsD3DynamicArray, PickFile As String, Id As String) As Integer
 
    reading_pick = d3_openfile(database, PickFile, Id, "R", rd)
    Exit Function
   
End Function
Public Function d3_openfile(database As String, PickFile As String, Id As String, What As String, Optional rd As clsD3DynamicArray) As Integer

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
   
   Select Case What
      Case "RU": Set rd = Tmp.brReadU(Id) 'lock item
      Case "RE": Call Tmp.brRelease(Id) 'release item lock
      Case "R": Set rd = Tmp.brRead(Id)
      Case "W": Call Tmp.brWrite(rd, Id)
      Case "D": Call Tmp.brDelete(Id)
      Case "O": 'just seeing if file exists
   End Select
   
   If Not DictOpenFiles.Exists(usefile) Then
      logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 3, database, -1, Mydatabase)
   End If
  
   d3_openfile = 0
   Exit Function

ThisErr:
   d3_openfile = 1
   
   Select Case What
      Case "R": Set rd = New clsD3DynamicArray: rd.brCString = ""
      Case "W":
      Case "D":
   End Select
   Exit Function
 
'   Select Case Err.Number 'Trap Item/File Level Errors
'        Case d3SrvErr_Access:
'            d3_openfile = ITEM_NOTFOUND
'        Case d3SrvErr_Lock:
'            d3_openfile = ITEM_ISLOCKED
'        Case d3SrvErr_BadF:
'            d3_openfile = FILE_NOTOPENED
'        Case d3SrvErr_Missing:
'            d3_openfile = FILE_NOTFOUND
'        Case Else:
'            d3_openfile = ERROR_UNKNOWN
'    End Select



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


Public Function d3_delete(database As String, tbl_name As String, Id As String) As String

Dim rderr As Integer, rd() As String

    If InStr(tbl_name, ".mdb\") <> 0 Then ' ms access file
       ReDim rd(0): rd(0) = Id
       d3_delete = writing_msaccess(rd(), tbl_name, "D")
    Else 'd3 file
       rderr = d3_openfile(database, tbl_name, Id, "D")
       d3_delete = CStr(rderr)
    End If
    
    Exit Function
       
End Function
Public Function d3_writedyn(database As String, PickFile As String, Id As String, rd As clsD3DynamicArray) As Integer

  d3_writedyn = d3_openfile(database, PickFile, Id, "W", rd)
  Exit Function

End Function

Function d3_readdyn(database As String, rd As clsD3DynamicArray, tbl_name As String, Id As String, Optional Attr As Integer = -1, Optional Vm As Integer = 0, Optional Svm As Integer = 0) As Integer

Dim rderr As Integer

    rderr = reading_pick(database, rd, tbl_name, Id)
    If rderr <> 0 Then d3_readdyn = rderr: Exit Function
    
    If Not Attr Then ' attr = -1
       rd = rd.brExtract(Attr, Vm, Svm)
   End If
   d3_readdyn = 0
   Exit Function
    
End Function

Public Sub d3_subroutine(sub_name As String, cnt As Integer)

Dim Max As Integer

If UBound(g_d3rulemodule_names) = 0 Then
   cnt = 0
Else
   Max = UBound(g_d3rulemodule_names)
   For cnt = 1 To Max
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

Public Function d3_readmat(database As String, rd() As String, tbl_name As String, Optional Attr As Integer = -1, Optional Vm As Integer = 0, Optional Svm As Integer = 0) As Integer

Dim rderr As Integer, Id As String
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
    
    If Not Attr Then ' attr = -1
       ReDim Preserve rd(1)
       rd(1) = rd3.brExtractStr(Attr, Vm, Svm)
    Else
       numcols = rd3.brDCount(Chr(254))
       ReDim Preserve rd(numcols)
       For nx = 1 To numcols
          rd(nx) = rd3.brExtractStr(nx)
       Next nx
    End If
    d3_readmat = 0
        
End Function
Public Function d3_readstr(database As String, rd As String, tbl_name As String, Id As String, Optional Attr As Integer = -1, Optional Vm As Integer = 0, Optional Svm As Integer = 0) As Integer

Dim rderr As Integer
Dim rd3 As clsD3DynamicArray
Dim rda() As String 'mc 08jan00 till next one
Dim J As Integer

    If InStr(tbl_name, ".mdb\") <> 0 Or Left(tbl_name, 4) = "sql," Then ' ms access file
       ReDim rda(0): rda(0) = Id
       If Left(tbl_name, 4) = "sql," Then
          rderr = reading_sql(rda(), tbl_name)
       Else
          rderr = reading_msaccess(rda(), tbl_name)
       End If
       If rderr <> 0 Then d3_readstr = rderr: Exit Function
       If Not Attr Then
          rd = rda(Attr)
          rd = Pick.extract(rd, 1, Vm, Svm)
       Else
          If UBound(rda) > 0 Then rd = rda(1) Else rd = "" 'mc 13aug01
          For J = 2 To UBound(rda) 'mc 13aug01
             rd = rd & Chr(254) & rda(J)
          Next J
       End If
       d3_readstr = 0
       Exit Function
    Else 'd3 file
       rderr = reading_pick(database, rd3, tbl_name, Id)
       If rderr <> 0 Then d3_readstr = rderr: Exit Function
       If Attr <> -1 Then ' attr = -1
          rd = rd3.brExtractStr(Attr, Vm, Svm)
       Else
          'Turn d3 string into vb string
          rd = rd3.brCString
       End If
       d3_readstr = 0
    End If 'mc 08jan00
    
End Function

Public Function d3_select(logentry As String, sentence As String, MyIds() As String, pick_cnt As Long, start As Long, finish As Long, Optional dropdown As Integer = 0, Optional sumonly As Integer = 0) As Long

Dim num_items As Long, Id As String, cnt As Long, tot As Currency
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

num_items = 0: Id = "": cnt = 0

logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 1, logentry)
If logon <> "" Then
   d3_select = 1 '-1
   pick_cnt = -1
   ReDim MyIds(0): MyIds(0) = "Error in vme " & logentry & " - " & logon
   Exit Function
End If
vme_done = True
Set mylist = d3vme.brOpenSelectList(sentence)

tot = 0

Do While mylist.brReadNext(Id)
     num_items = num_items + 1
     If dropdown = 1 And cnt Mod 2 <> 0 Then num_items = num_items - 1
     
     If use_start_finish Then
        If num_items >= start And num_items <= finish Then within_range = True
        If num_items > finish Then Exit Do
     End If
     
     If within_range Or use_start_finish = False Then
        If sumonly Then
           If IsNumeric(Id) Then tot = tot + CCur(Id)
        Else
           If dropdown = 0 Then
              ReDim Preserve MyIds(cnt)
              MyIds(cnt) = Id
           Else
              If cnt Mod 2 = 0 Then
                 ReDim Preserve MyIds(cnt / 2)
                 MyIds(cnt / 2) = Id
              Else
                 MyIds((cnt - 1) / 2) = MyIds((cnt - 1) / 2) & Chr(8) & Id
              End If
           End If
        End If
        cnt = cnt + 1
     End If
Loop

If sumonly Then ReDim MyIds(0): MyIds(0) = CStr(tot): num_items = 1
d3_select = num_items
pick_cnt = mylist.brCount
logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)
Exit Function

d3_select_error:
d3_select = 1
pick_cnt = -1
ReDim MyIds(0): MyIds(0) = "Error in d3_select " & sentence
If vme_done Then logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)
Exit Function

End Function
Public Function conv_translate(database As String, use_conversion As String, converted As String) As String

Dim fname As String, use_how As Integer
Dim temp As String, rd() As String 'mc 28apr99
Dim temp2 As String, Max As Integer, want_space As String, temp3 As String
Dim temp4 As String, Attr As String, Vm As Integer, I As Integer, Svm As Integer
Dim temparr() As String, temparr2() As String, rderr As Integer
Dim tempd3 As clsD3DynamicArray, vv As Integer

     fname = Mid(Pick.field(use_conversion, ";", 1), 2)
     use_how = 0
     Select Case fname
        Case "ACCOUNTDESC"
           If Left(converted, 3) = "JOB" Then
              fname = "JOB.L": use_conversion = use_conversion & ";2": converted = Mid(converted, 4)
           Else
              If Pick.Index(converted, ".", 2) <> 0 Then fname = "GEN.L": use_conversion = use_conversion & ";2" Else fname = "CLIENT": use_conversion = use_conversion & ";1"
           End If
        Case "STOCKDESC"
           If Left(converted, 3) = "JOB" Then
              fname = "JOB.L": use_conversion = use_conversion & ";2": converted = Mid(converted, 4)
           Else
              If Pick.Index(converted, ".", 2) <> 0 Then fname = "GEN.L": use_conversion = use_conversion & ";2" Else fname = "STOCK": use_conversion = use_conversion & ";1"
           End If
         Case "OWNERNAME"
           ReDim rd(0): rd(0) = converted 'mc 28apr99
           rderr = d3_readmat(database, rd(), "CLIENT", 35, 1)  'mc 28apr99
           If rderr <> 0 Then conv_translate = "": Exit Function 'mc 28apr99
           temp = rd(1) 'mc 28apr99 pick.extract(temp, 35, 1, 0)
           If temp <> "" Then
              temp2 = temp
              rderr = d3_readstr(database, temp, "CLIENT", temp2)
              temp = Pick.trimm(Pick.extract(temp, 8, 0, 0) & " " & Pick.extract(temp, 7, 0, 0) & " " & Pick.extract(temp, 1, 0, 0))
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
           temp2 = Pick.trimm(tempd3.brExtractStr(2, I, 0) & " " & tempd3.brExtractStr(3, I, 0) & " " & tempd3.brExtractStr(4, I, 0) & " " & tempd3.brExtractStr(5, I, 0))
           conv_translate = temp2
           Exit Function
        Case "EMPCLIENT"
           fname = "EMPLOYEE": use_conversion = use_conversion & ";1"
           Select Case Pick.extract(converted, 2, 0, 0) 'id is in attr1 so add 1 to all wanted
              Case "42", "67", "40", "65"
              Case Else
                 temp3 = Pick.extract(converted, 7, 0, 0)
                 If InStr(temp3, "EMP-") <> 0 And InStr(temp3, "TS-") <> 0 Then
                 Else
                    fname = "CLIENT": use_conversion = use_conversion & ";1"
                 End If
           End Select
           converted = Pick.extract(converted, 6, 1, 0)
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
        Max = UBound(temparr)
        temp2 = "": want_space = ""
        For I = 1 To Max
           temp3 = temparr(I)
           temparr2 = Split(temp3, ",", -1, vbBinaryCompare)
           ReDim Preserve temparr2(2)
           Attr = temparr2(0)
           If Attr = "-1" Then 'mc 11may99 to next
              For vv = 1 To UBound(rd)
                   temp2 = temp2 & Chr(254) & rd(vv)
              Next vv
              If temp2 <> "" Then temp2 = Mid(temp2, 2)
              Exit For
           End If 'mc 11may99
           If Left(Attr, 1) = "C" Then
             temp2 = temp2 & want_space & Mid(Attr, 2)
             want_space = ""
           Else
              If UBound(rd) < CInt(Attr) Then temp4 = "" Else temp4 = rd(CInt(Attr))
              If temparr2(1) = "LAST" Then
                 Vm = Pick.dcount(temp4, Chr(253)) 'mc 6may99
              Else
                 If IsNumeric(temparr2(1)) Then Vm = CInt(temparr2(1)) Else Vm = 1
              End If
              If IsNumeric(temparr2(2)) Then Svm = CInt(temparr2(2)) Else Svm = 0
              temp4 = Pick.extract(temp4, 1, Vm, Svm)
              If Svm = 0 Then temp4 = replace(temp4, Chr(252), " ")
              temp2 = temp2 & want_space & temp4
              want_space = " "
           End If
        Next I
     End If
     conv_translate = temp2
  
End Function

Function conv_in(database As String, ByVal cur_module As String, how As Integer, conversion As String, fld_dt As String, errmsg As String, internal_datum, tfile As String, v7 As String, v36 As String, max_length As Integer, Optional language As String = "English", Optional language_file As String = "c:\ckashare\cka\language.ini") As String

' Display Date Or Amount If field value is date or amount

Dim max_lth, I, temp As String, RdError As Integer, Max As Integer, dec_places As Integer
Dim Attr As Integer, val1 As Integer, val2 As Integer
Dim Vfdate As Integer, Vtdate As Integer
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
                errmsg = Pick.ini_read(language, "35", language_file)
                Call Pick.sr_chone(errmsg, "1", fld_dt)
                Exit Function
             End If
           End If
           Attr = Pick.date_vb_to_pick(fld_dt, internal_datum, how)
           If Mid(conversion, 3, 1) = "," Then 'validate on trans.info
              If g_trans_info = "" Then  'mc 29apr99
                 RdError = d3_readstr(database, g_trans_info, "DICT TRANS.J", "TRANS.INFO") 'mc 04may99
                 If RdError <> 0 Or g_trans_info = "" Then errmsg = "trans_info not set up in program": Exit Function  'mc 04may99
              End If  'mc 29apr99
              Attr = CInt(Pick.field(conversion, ",", 2))
              If Attr = 0 Then  'mc 29apr99 till next mc 29apr99
                 If InStr(Chr(253) & Pick.extract(g_trans_info, 8, 0, 0) & Chr(253) & Pick.extract(g_trans_info, 7, 0, 0) & Chr(253), Chr(253) & internal_datum & Chr(253)) = 0 Then
                    errmsg = fld_dt & " (" & internal_datum & ")" & " must be one of " & Pick.extract(g_trans_info, 8, 0, 0) & Chr(253) & Pick.extract(g_trans_info, 7, 0, 0)
                    Exit Function
                 End If
                 GoTo conv_in_end_select
              End If 'mc 29apr99
              val1 = CInt(Pick.field(conversion, ",", 3))
              val2 = CInt(Pick.field(conversion, ",", 4))
              If how <> 2 Then
                 Vfdate = CInt(Pick.extract(g_trans_info, Attr, val1, 0))
                 Vtdate = CInt(Pick.extract(g_trans_info, Attr, val2, 0))
                 If Attr <> 0 Then
                    If CInt(internal_datum) > Vtdate Or CInt(internal_datum) < Vfdate Then
                       errmsg = Pick.ini_read(language, "34", language_file)
                       Call Pick.sr_chone(errmsg, "3", Pick.date_pick_to_vb(Vtdate))
                       Call Pick.sr_chone(errmsg, "2", Pick.date_pick_to_vb(Vfdate))
                       Call Pick.sr_chone(errmsg, "1", fld_dt)
                       Exit Function
                    End If
                 End If
              Else
                 vfdate_pc = CDate(Pick.extract(g_trans_info, Attr, val1, 0))
                 vtdate_pc = CDate(Pick.extract(g_trans_info, Attr, val2, 0))
                 If Attr <> 0 Then
                    If DateDiff("d", vfdate_pc, fld_dt) < 0 Or DateDiff("d", vtdate_pc, fld_dt) > 0 Then
                       errmsg = Pick.ini_read(language, "34", language_file)
                       Call Pick.sr_chone(errmsg, "3", CStr(vtdate_pc))
                       Call Pick.sr_chone(errmsg, "2", CStr(vfdate_pc))
                       Call Pick.sr_chone(errmsg, "1", fld_dt)
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
          Call Pick.sr_change(fld_dt, "$", "")
          Call Pick.sr_change(fld_dt, ",", "")
          fld_dt = Pick.trimm(fld_dt)
          If Not IsNumeric(CVar(fld_dt)) Then
md_error:
             errmsg = Pick.ini_read(language, "39", language_file)
             Call Pick.sr_chone(errmsg, "1", CStr(dec_places))
             Exit Function
          End If
          If dec_places = 0 Then
             If Pick.Index(fld_dt, ".", 1) <> 0 Then GoTo md_error
             internal_datum = CStr(CVar(fld_dt))
          Else
             If Len(Pick.field(fld_dt, ".", 2)) > dec_places Then GoTo md_error
             internal_datum = CStr(CVar(fld_dt) * (10 ^ dec_places))
          End If
          If Pick.Index(conversion, ">", 1) <> 0 Then
             If internal_datum <= CInt(Mid(conversion, 5, 1)) Then
                errmsg = Pick.ini_read(language, "40", language_file)
                Call Pick.sr_chone(errmsg, "1", Mid(conversion, 5, 1))
                Call Pick.sr_chone(errmsg, "2", ">")
                Exit Function
             End If
          End If
          If Pick.Index(conversion, "<", 1) <> 0 Then
             If internal_datum >= CInt(Mid(conversion, 5, 1)) Then
                errmsg = Pick.ini_read(language, "40", language_file)
                Call Pick.sr_chone(errmsg, "1", Mid(conversion, 5, 1))
                Call Pick.sr_chone(errmsg, "2", "<")
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
          If Not (Pick.match(fld_dt, conversion)) Then
             errmsg = fld_dt & " must match a pattern of " & conversion
             Exit Function
          End If
          internal_datum = fld_dt
        Case "NUMERIC"
          If Not IsNumeric(fld_dt) Then
             errmsg = Pick.ini_read(language, "64", language_file)
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
              If Pick.Index(fld_dt, ".", 2) = 0 Then
                 errmsg = Pick.ini_read(language, "38", language_file)
                 Call Pick.sr_chone(errmsg, "1", fld_dt)
                 Exit Function
              End If
       Case Else
          If Left(conversion, 2) = "<>" Then
             Max = Len(conversion)
             For I = 3 To Max
                  If Pick.Index(fld_dt, Mid(conversion, I, 1), 1) <> 0 Then
                     errmsg = Pick.ini_read(language, "36", language_file)
                     Call Pick.sr_chone(errmsg, "2", """ " & Mid(conversion, I, 1) & """")
                     Call Pick.sr_chone(errmsg, "1", fld_dt)
                     Exit Function
                  End If
              Next I
          End If
          
          If Left(conversion, 1) = "@" Then ' form @,y,y2, then find ,y, in string, last , needed - , can be anything
             temp = Mid(conversion, 2, 1)
             If InStr(conversion, temp & fld_dt & temp) = 0 Then '?oktext
                errmsg = Pick.ini_read(language, "41", language_file)
                Call Pick.sr_chone(errmsg, "1", Mid(conversion, 3, Len(conversion) - 3))
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

Dim J As Integer, Max As Integer, temp As String, I As Integer
Dim dec_places As Integer, temp3 As String
Dim use_conversion As String, converted As String, number_conversions As Integer
Dim separator As String, test_conversion As String
Dim the_format As String, tempint As Integer
Dim RdError As Integer, temparr() As String, temparr2() As String
Dim tempobj As Object

Static last_one As String
Static penultimate As String

separator = "~"

'xyzIf Form2.f_cur_oitemid = "HTML_PROSPECT" Then separator = "~" Else separator = "|"

  number_conversions = Pick.dcount(conversion, separator)
  converted = fld_dt
  For J = 1 To number_conversions

    use_conversion = Pick.field(conversion, separator, J): test_conversion = use_conversion
    
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
              Max = UBound(temparr)
              For I = 0 To Max
                 If IsNumeric(temparr(I)) Then
                    temp = Pick.date_pick_to_vb(val(temparr(I)))
                    temparr(I) = Day(temp) & "/" & Month(temp) & "/" & Right(Year(temp), 2)
                 End If
              Next I
              converted = Join(temparr, Chr(253))
           End If
        End If
    Case "DT"
        converted = Day(Now) & "/" & Month(Now) & "/" & Right(Year(Now), 4) 'Date$
    Case "DTP"
        temp = Pick.date_vb_to_pick(Day(Now) & "/" & Month(Now) & "/" & Right(Year(Now), 4), converted, 0)
    Case "MT"
        If fld_dt <> "" Then
           If how <> 2 Then
              Max = Pick.dcount(converted, Chr(253))
              temp = ""
              For I = 1 To Max
                 temp3 = Pick.extract(converted, 1, I, 0)
                 If temp3 <> "" Then temp = Pick.replace(temp, 1, I, 0, Pick.time_pick_to_vb(val(temp3)))
              Next I
              converted = temp
           End If
        End If
    Case "dec2": If IsNumeric(converted) Then converted = FormatCurrency(converted, 2)
    Case "MD2", "MD0", "MD1", "MD3", "MD4", "MD2>0", "MD0>0", "MD1>0", "MD3>0", "MD4>0", "MD2<0" 'mc 23may99
       dec_places = CInt(Mid(use_conversion, 3, 1))
       If dec_places = 0 Then the_format = "#0" Else the_format = "#0." & String(dec_places, "0") & "##"
       If converted <> "" Then
          Max = Pick.dcount(converted, Chr(253))
          temp = ""
          For I = 1 To Max
             temp3 = Pick.extract(converted, 1, I, 0)
             If IsNumeric(temp3) Then 'mc 9jun99
                temp3 = Format$(val(temp3) / (10 ^ dec_places), the_format)
             End If
             temp = Pick.replace(temp, 1, I, 0, temp3)
          Next I
          converted = temp
       End If
    Case "MAIL_ADDRESS", "RES_ADDRESS"
        I = 1: fld_dt = Pick.delet(fld_dt, 1, 0, 0) 'remove id added mc 6may99
        If Left(use_conversion, 1) = "R" Then
           temp = Pick.extract(fld_dt, 5, 2, 0)
           If temp = "" Then I = 1 Else I = 2
        End If
        temp = Pick.trimm(Pick.extract(fld_dt, 2, I, 0) & " " & Pick.extract(fld_dt, 3, I, 0) & " " & Pick.extract(fld_dt, 4, I, 0) & " " & Pick.extract(fld_dt, 5, I, 0))
        converted = temp
    Case "STREET_NO"
        If IsNumeric(Left(fld_dt, 1)) Then temp = Pick.field(fld_dt, " ", 1) Else temp = ""
        converted = temp
    Case "STREET_NAME"
        If IsNumeric(Left(fld_dt, 1)) Then temp = Mid(fld_dt, Pick.Index(fld_dt, " ", 1) + 1) Else temp = fld_dt
        converted = temp
    Case "OWNERS35", "OWNERS37", "OWNERS36" ',NAME", "OWNERS,ADDRESS"
       converted = ""
       temp3 = Mid(test_conversion, 7) 'mco 28mar01
       tempint = CInt(temp3)
       If d3_readstr(database, temp, "client", fld_dt, tempint, 0, 0) = 0 Then
          temparr = Split(temp, Chr(253), -1, vbBinaryCompare)
          Max = UBound(temparr)
          For I = 0 To Max
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
             temp = Pick.date_pick_to_vb(val(converted))
          Else
             temp = converted
          End If
          temp = DateDiff("m", temp, Now)
          converted = Int(val(temp) / 12) & "yrs" & (val(temp) Mod 12) & "mths"
        End If
    Case ".1"
       converted = Pick.field(converted, ".", 1)
    Case ".2"
       converted = Pick.field(converted, ".", 2)
    Case ".3"
       converted = Pick.field(converted, ".", 3)
    Case "Last inspected"
       'xyzconverted = last_inspected(cur_module, cur_dbno, converted, 1, 2, "")  'attr1 has pool_id, attr 2 has date - sort on this so can get first only
    Case "Last complied"
       'xyzconverted = last_inspected(cur_module, cur_dbno, converted, 1, 7, "")  'attr1 has pool_id, attr 2 has date - sort on this so can get first only
    Case "loanbal" 'note fld_dt has the id in 'attr' 1 so 2 means attr1 and 19 means attr18 in the read item
        If d3_readstr(database, temp, "tdebtor", Pick.extract(fld_dt, 2, 0, 0), 3) <> 0 Then temp = "0"
        converted = CStr(CCur(temp) + Pick.extractcur(fld_dt, 19, 0, 0))
    Case Else
       If Left(test_conversion, 2) = "sr" Then
          Set tempobj = CreateObject("cka_ta31.ta31")
          converted = tempobj.sr(database, use_conversion, converted)
          Set tempobj = Nothing
'         converted = sr(database, use_conversion, converted)
       End If
    End Select
next_j:

  Next J
    
penultimate = last_one
last_one = converted
conv_out = converted

End Function


Public Function d3_writemat(database As String, tbl_name As String, rd() As String) As String

Dim numcols As Long, nx As Long, wterr As Boolean
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
       wterr = d3_writedyn(database, tbl_name, rd(0), rd3)
       d3_writemat = CStr(wterr)
       Exit Function
    End If
    
d3_writemat_failed:
    d3_writemat = "2"
    Exit Function
    
End Function


Public Function d3_subcall(subnum As Integer, the_answer As Variant) As String

Dim Result As Boolean
Dim d3Environment As clsD3Environment, d3domain As clsD3NetDomain, d3vme As clsD3VirtualMachine, logentry As String
Dim logon As String
Dim d3rulecatalog As clsD3RuleCatalog

logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 4, logentry, -1, d3rulecatalog)
If logon <> "" Then Exit Function

Result = g_d3rulemodules(subnum).brCall(the_answer)
d3_subcall = CStr(the_answer)

logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)

End Function


Public Function msa_select(database_name As String, sentence As String, MyIds() As String, pick_cnt As Long, start As Long, finish As Long, Optional dropdown As Integer = 0, Optional sumonly As Integer = 0) As Long

Dim num_items As Long, Id As String, cnt As Long, J As Integer
Dim myset As Recordset
Dim use_start_finish As Boolean
Dim within_range As Boolean
Dim dbs As database

If start = 0 And finish = 0 Then
   use_start_finish = False
Else
   use_start_finish = True
End If

   num_items = 0: Id = "": cnt = 0
   On Error GoTo msa_select_open_error
   
   Set dbs = OpenDatabase(database_name)
   
   On Error GoTo msa_select_error
   Set myset = dbs.OpenRecordset(sentence, dbOpenSnapshot)
   If myset.BOF And myset.Eof Then
      myset.Close
      dbs.Close
      msa_select = 0
      pick_cnt = 0
      Exit Function
   End If
 
myset.MoveLast
pick_cnt = myset.RecordCount

myset.MoveFirst
Do While Not (myset.Eof)
     num_items = num_items + 1
      
     If use_start_finish Then
        If num_items >= start And num_items <= finish Then within_range = True
        If num_items > finish Then Exit Do
     End If
     
     If within_range Or use_start_finish = False Then
        ReDim Preserve MyIds(cnt)
        If IsNull(myset(0)) Then MyIds(cnt) = "" Else MyIds(cnt) = myset(0) 'mco 11sep01
        If dropdown = 1 Then
           For J = 1 To myset.Fields.Count - 1
              MyIds(cnt) = MyIds(cnt) & Chr(8)
              If Not (IsNull(myset(J))) Then MyIds(cnt) = MyIds(cnt) & myset(J)
           Next J
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
     ReDim MyIds(0): MyIds(0) = Err & " -  " & Error(Err) & " - " & sentence
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
        
    'On Error GoTo reading_open_failed
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
      'On Error GoTo msaccess_index_error
      For nx = 0 To defs.Indexes.Count - 1
         If defs.Indexes(nx).Primary = True Then
            the_table.Index = defs.Indexes(nx).Name
            g_index(maxtb) = nx
            Exit For
         End If
      Next nx
      'On Error GoTo reading_msaccess_failed
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
             'Select Case the_table(nx).Type
                'Case dbText
                '   wth = the_table(nx).Size
                '   If wth <> 0 Then the_table(nx) = Left(rd(nx), wth)
                'Case dbBoolean
                '   If rd(nx) = "Y" Then rd(nx) = True Else rd(nx) = False
                'Case dbDate
                '   rd(nx) = Day(the_table(nx)) & "/" & Month(the_table(nx)) & "/" & Year(the_table(nx))
                'Case Else
                   rd(nx) = CStr(the_table(nx))
             'End Select
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
Dim J As Integer, Result As String, use_conversion As String, converted As String

Result = ""
For J = 1 To 999
    use_conversion = Pick.field(conversion, ";", J)
    If use_conversion = "" Then Exit For
    Select Case Left(use_conversion, 1)
    Case "G"
       converted = Pick.extract(original, 1, 0, 0)
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
          I = Pick.Index(converted, sepchar, fld2)
          If I <> 0 Then
             converted = Left(converted, I - 1)
          End If
       Else
          I = Pick.Index(converted, sepchar, fld1)
          If I = 0 Then
             converted = ""
          Else
             converted = Mid(converted, I + 1)
             I = Pick.Index(converted, sepchar, fld2)
             If I <> 0 Then
                converted = Left(converted, I - 1)
             End If
          End If
       End If
       Result = Result & converted
   Case "C"
      Result = Result & Mid(use_conversion, 2)
   Case "T"
      Call Pick.sr_change(use_conversion, ":", ";")
      Result = Result & conv_translate(database, use_conversion, original)
   Case Else
      If IsNumeric(use_conversion) Then
         fld1 = CInt(use_conversion) + 1 'id is in attr 1
         Result = Result & Pick.extract(original, fld1, 0, 0)
      End If
   End Select
Next J
conv_group = Result
       
End Function

Public Function conv_arithmetic(converted As String, use_conversion As String, last_one As String, penultimate As String) As String

'do arithmetic on values eg A*-1 - multiply by -1 - needed for all general ledger values

Dim fld1 As Currency, What As String, fld2 As Currency, OPERATOR As String

     OPERATOR = Mid(use_conversion, 2, 1)
     What = Mid(use_conversion, 3)

     If What = "V" Then
        converted = last_one
        If IsNumeric(penultimate) Then fld1 = CCur(penultimate) Else fld1 = 0
     Else
        fld1 = CCur(What)
     End If
     If IsNumeric(converted) Then fld2 = CCur(converted) Else fld2 = 0
        
Select Case OPERATOR
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

Dim Attr As Integer, rderr As Integer, rd() As String, temp As Currency, temp2 As String

If use_conversion = "BU" Then 'total budget wanted
   ReDim rd(0): rd(0) = converted
   rderr = d3_readmat(database, rd(), "GEN.L")
   If UBound(rd) < 8 Then conv_balances = "0": Exit Function
   If rd(7) = "A" Then
      temp2 = Pick.extract(rd(8), 1, 1, 0)
      If IsNumeric(temp2) Then temp = CCur(temp2) * -1 Else temp = 0
      conv_balances = CStr(temp)
      Exit Function
   End If
   temp = 0
   For Attr = 1 To 12
      temp2 = Pick.extract(rd(8), 1, Attr, 0)
      If IsNumeric(temp2) Then temp = temp - CCur(temp2)
   Next Attr
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
   temp2 = Pick.extract(converted, 4, 0, 0) '4 not 3 as id is in 1
   Attr = 1
   If IsNumeric(temp2) Then
      If CInt(temp2) >= 50 Then Attr = -1
   End If
   rderr = CInt(Mid(use_conversion, 4)) + 1 'id is in attr 1
   temp2 = Pick.extract(converted, rderr, 0, 0)
   If IsNumeric(temp2) Then temp = CCur(temp2) Else temp = 0
   temp = Attr * temp
   conv_balances = CStr(temp)
   Exit Function
End If 'mc 10jul99

If Pick.Index(converted, ".", 2) Then Attr = 4 Else Attr = 3
use_conversion = "TGEN.L;" & Attr

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
    Do While Not Eof(filenum) ' Check for end of file.
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

Public Function ReadDosFile(filename As String, FileContents As String) As Boolean

 Dim fso, ThisRead
  
 On Error GoTo ThisErr
 
 Set fso = New Scripting.FileSystemObject

        FileContents = ""
        Set ThisRead = fso.OpenTextFile(filename, ForReading, False)
        FileContents = ThisRead.ReadAll
        ThisRead.Close
        ReadDosFile = True
        
Exit Function
ThisErr:
  ReadDosFile = False
  
End Function

Function read_dos_str(the_file As String, does_not_exist As Boolean) As String

Dim the_rec As String, filenum As Integer, var As String

    does_not_exist = False
    On Error GoTo read_dos_str

    filenum = FreeFile
    Open the_file For Input Access Read As #filenum
    Line Input #filenum, the_rec
    Do While Not Eof(filenum) ' Check for end of file.
       Line Input #filenum, var
       the_rec = the_rec & vbCrLf & var
    Loop
    Close #filenum
    read_dos_str = the_rec

Exit Function

read_dos_str:
    Close #filenum
    does_not_exist = True: read_dos_str = ""
    Exit Function

End Function

Public Function writing_msaccess(rd() As String, tbl_name As String, Optional deleting As String = "") As String

Dim table_index As Integer, numcols As Integer, nx As Integer
Dim database_name As String, fname As String, Max As Integer, wth
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
             Case dbBoolean
                If rd(nx) = "Y" Then rd(nx) = True Else rd(nx) = False
             'Case dbDate 'cannot work as maybe time
             '   the_table(nx) = Day(rd(nx)) & "/" & Month(rd(nx)) & "/" & Year(rd(nx))
             Case Else
                the_table(nx) = rd(nx)
          End Select
       End If
    Next nx
    Max = the_table.Fields.Count - 1
    For nx = numcols + 1 To Max
       the_table(nx) = Null
    Next nx
    the_table.UPDATE
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

Dim Id As String, mylist As clsD3SelectList, MyIds As String
Dim pos1 As Integer, pos2 As Integer, pos3 As Integer, pos4 As Integer
Dim d3Environment As clsD3Environment, d3domain As clsD3NetDomain, d3vme As clsD3VirtualMachine
Dim logon As String, vme_done As Boolean, cnt As Integer, Pos As Integer, default_found As Integer

vme_done = False
On Error GoTo d3_select_str_error

logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 1, logentry)
If logon <> "" Then
   d3_select_str = "Error in vme " & logentry & " - " & logon
   Exit Function
End If
Set mylist = d3vme.brOpenSelectList(sentence)

If dropdown = 1 Then MyIds = "<OPTION VALUE="""">" Else MyIds = ""
cnt = 0: default_found = 0
Do While mylist.brReadNext(Id)
   If dropdown = 0 Then
      MyIds = MyIds & "<OPTION VALUE=""" & Id & """>" & Id  'the value for link
   Else
      If cnt Mod 2 = 0 Then
         If Left(Id, 1) = "@" Or extended <> "" Then
            Pos = InStr(Id, ".")
            If Pos <> 0 Then Id = Mid(Id, Pos + 1)
         End If
         If default = Id Then
            default_found = 1
         Else
            MyIds = MyIds & "<OPTION VALUE=""" & Id & """>" 'the id
         End If
      Else
         If default_found = 1 Then
            MyIds = "<OPTION VALUE=""" & default & """>" & Id & MyIds
            default_found = 0
         Else
            MyIds = MyIds & Id 'the value
         End If
      End If
      cnt = cnt + 1
   End If
Loop

d3_select_str = MyIds
logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)
Exit Function

d3_select_str_error:
   d3_select_str = "Error in d3_select_str " & sentence
   If vme_done Then logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)
   Exit Function

End Function

Public Function msa_select_str(database_name As String, sentence As String, Optional dropdown As Integer = 0, Optional default As String = "", Optional separator As String = "<BR>") As String

Dim Id As String
Dim myset As Recordset, the_id As String
Dim dbs As database, MyIds As String
Dim datum As String, kk As Integer

   'On Error GoTo msa_select_open_error
   
   Id = database_name
   If Right(Id, 1) = "\" Then Id = Left(Id, Len(Id) - 1)
   Set dbs = OpenDatabase(Id)
   
   'On Error GoTo msa_select_str_error
   
   Set myset = dbs.OpenRecordset(sentence, dbOpenSnapshot)
   If myset.BOF And myset.Eof Then
      myset.Close
      dbs.Close
      msa_select_str = ""
      Exit Function
   End If
 
   If dropdown = 1 Then MyIds = "<OPTION VALUE="""">" Else MyIds = ""
   
   myset.MoveFirst
   Do While Not (myset.Eof)
      If IsNull(myset(0)) Then the_id = "" Else the_id = myset(0)
      If dropdown = 1 Then
         datum = "<OPTION VALUE=""" & the_id & """>" & myset(1)
      Else
         datum = the_id
         For kk = 1 To myset.Fields.Count - 1
            datum = datum & " " & myset(kk)
         Next kk
         If MyIds <> "" Then datum = separator & datum
      End If
      If default = myset(0) And default <> "" Then
         MyIds = datum & MyIds
      Else
        MyIds = MyIds & datum
      End If
      myset.MoveNext
   Loop

   msa_select_str = MyIds
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


Public Function d3_writestr(database As String, tbl_name As String, Id As String, rd As String) As String

Dim numcols As Long, nx As Long, wterr As Integer
Dim rd3 As New clsD3DynamicArray, Wt() As String, J As Integer, Max As Integer
   
    If InStr(tbl_name, ".mdb\") <> 0 Then ' ms access file
       Max = Pick.dcount(rd, Chr(254))
       ReDim Wt(Max)
       Wt(0) = Id
       For J = 1 To Max
          Wt(J) = Pick.extract(rd, J, 0, 0)
       Next J
       d3_writestr = writing_msaccess(Wt(), tbl_name)
    Else 'd3 file
       rd3.brCString = rd
       wterr = d3_writedyn(database, tbl_name, Id, rd3)
       d3_writestr = CStr(wterr)
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
Dim sql As String, Key As String
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

    Key = the_rset.Fields(0).Name
    sql = "SELECT * FROM " & tbl_name & " WHERE (((" & Key & ")=" & rd(0) & "))"
    Set the_rset = cnn1.Execute(sql)
    If the_rset.BOF And the_rset.Eof Then reading_sql = 1: GoTo sql_exit
   
    numcols = the_rset.Fields.Count - 1
    ReDim Preserve rd(numcols)
    On Error GoTo must_be_null 'this done as getting strange error 'Invalid use of null'
                               'when put in msgbox to see errot, it did not occur ???
                               'this technique will work on all error data anyway
    For nx = 0 To numcols
       rd(nx) = the_rset.Fields.item(nx).value
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

   username = Pick.extract(logentry, 3, 0, 0)
   Select Case suffix
      Case ".rtf": docpath = Pick.extract(logentry, 5, 0, 0)
      Case ".asp", ".htm": docpath = Pick.extract(logentry, 6, 0, 0)
      Case ".txt": docpath = "": docfilename = Pick.extract(logentry, 7, 0, 0) & "_" & username & "_" & keyname & suffix: If name_only Then GoTo name_only
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
     hdr1 = replace(hdr1, "\", "/")
     rtf_open = hdr1

End Function
Public Function gl_years(dbname As String) As String

Dim dbs As database, years As String
Dim posn As Integer, Pos As Integer
Dim Jj As Integer, tablename As String

      Set dbs = OpenDatabase(dbname)
      years = ""
      For Jj = 0 To dbs.TableDefs.Count - 1
         tablename = dbs.TableDefs(Jj).Name
         If Left(tablename, 6) = "gen_l_" Then
            tablename = Right(tablename, 2)
            If Left(tablename, 1) = "9" Then tablename = "19" & tablename Else tablename = "20" & tablename
            posn = Pick.locate(tablename, years, 1, 1, 0, Pos, "AR")
            years = Pick.insert(years, 1, Pos, 0, tablename)
         End If
      Next Jj
      dbs.Close
      gl_years = years
           
End Function


Public Function d3_select_var(logentry As String, sentence As String, MyIds, pick_cnt As Long, start As Long, finish As Long, Optional dropdown As Integer = 0, Optional sumonly As Integer = 0) As Long

Dim num_items As Long, Id As String, cnt As Long, tot As Currency
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

'On Error GoTo d3_select_error

num_items = 0: Id = "": cnt = 0

logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 1, logentry)
If logon <> "" Then
   d3_select_var = 1 '-1
   pick_cnt = -1
   ReDim MyIds(0): MyIds(0) = "Error in vme " & logentry & " - " & logon
   Exit Function
End If
vme_done = True
Set mylist = d3vme.brOpenSelectList(sentence)

tot = 0

Do While mylist.brReadNext(Id)

     num_items = num_items + 1
     If dropdown = 1 And cnt Mod 2 <> 0 Then num_items = num_items - 1
     
     If use_start_finish Then
        If num_items >= start And num_items <= finish Then within_range = True
        If num_items > finish Then Exit Do
     End If
     
     If within_range Or use_start_finish = False Then
        If sumonly Then
           If IsNumeric(Id) Then tot = tot + CCur(Id)
        Else
           If dropdown = 0 Then
              ReDim Preserve MyIds(cnt)
              MyIds(cnt) = Id
           Else
              If cnt Mod 2 = 0 Then
                 ReDim Preserve MyIds(cnt / 2)
                 MyIds(cnt / 2) = Id
              Else
                 MyIds((cnt - 1) / 2) = MyIds((cnt - 1) / 2) & Chr(8) & Id
              End If
           End If
        End If
        cnt = cnt + 1
     End If
Loop

If sumonly Then ReDim MyIds(0): MyIds(0) = tot: num_items = 1
d3_select_var = num_items
pick_cnt = mylist.brCount
logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)
Exit Function

d3_select_error:
d3_select_var = 1
pick_cnt = -1
ReDim MyIds(0): MyIds(0) = "Error in d3_select_var " & sentence
If vme_done Then logon = d3_vme_on_off(d3Environment, d3domain, d3vme, 0)
Exit Function

End Function
Public Function msa_select_var(database_name As String, sentence As String, MyIds, pick_cnt As Long, start As Long, finish As Long, Optional dropdown As Integer = 0, Optional sumonly As Integer = 0) As Long

Dim num_items As Long, Id As String, cnt As Long, J As Integer
Dim myset As Recordset
Dim use_start_finish As Boolean
Dim within_range As Boolean
Dim dbs As database

If start = 0 And finish = 0 Then
   use_start_finish = False
Else
   use_start_finish = True
End If

   num_items = 0: Id = "": cnt = 0
   On Error GoTo msa_select_open_error
   
   Set dbs = OpenDatabase(database_name)
   
   On Error GoTo msa_select_error
   Set myset = dbs.OpenRecordset(sentence, dbOpenSnapshot)
   If myset.BOF And myset.Eof Then
      myset.Close
      dbs.Close
      msa_select_var = 0
      pick_cnt = 0
      Exit Function
   End If
 
myset.MoveLast
pick_cnt = myset.RecordCount

myset.MoveFirst
Do While Not (myset.Eof)
     num_items = num_items + 1
      
     If use_start_finish Then
        If num_items >= start And num_items <= finish Then within_range = True
        If num_items > finish Then Exit Do
     End If
     
     If within_range Or use_start_finish = False Then
        ReDim Preserve MyIds(cnt)
        If IsNull(myset(0)) Then MyIds(cnt) = "" Else MyIds(cnt) = myset(0) 'mco 11sep01
        If dropdown = 1 Then
           For J = 1 To myset.Fields.Count - 1
              MyIds(cnt) = MyIds(cnt) & Chr(8)
              If Not (IsNull(myset(J))) Then MyIds(cnt) = MyIds(cnt) & myset(J)
           Next J
        End If
        cnt = cnt + 1
     End If
     
     myset.MoveNext
Loop

     msa_select_var = num_items

     myset.Close
     dbs.Close
     Exit Function

msa_select_error:
     dbs.Close
msa_select_open_error:
     msa_select_var = 1
     pick_cnt = -1
     ReDim MyIds(0): MyIds(0) = Err & " -  " & Error(Err) & " - " & sentence
     Exit Function

End Function
