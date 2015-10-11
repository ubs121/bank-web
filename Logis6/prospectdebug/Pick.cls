VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Pick"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Compare Text
Option Explicit

Function ccount(PASSVAR As String, FINDCHAR As String, binary_or_text As Integer) As Integer

Dim NXPOSN As Long, cnt As Long, posn As Long

NXPOSN = 1: cnt = 0
NXT:
   posn = InStr(NXPOSN, PASSVAR, FINDCHAR, binary_or_text)
   If posn Then cnt = cnt + 1: NXPOSN = posn + 1: GoTo NXT
ccount = cnt
End Function


Function delet(sdummy As String, attr As Integer, value As Integer, svm As Integer) As String
'
' implementation of PICK DELETE function
'
Dim new_delim As String, s1 As String, I As Long, eos As Long, soe As Long
Dim s2 As String

Dim G_DELIM(3) As Integer
Dim sbit(3) As String
Dim ebit(3) As String
Dim g_delimiters(3) As String
' Initialise delimiters that will be in received PICK data
  g_delimiters(1) = Chr$(254)      ' ^
  g_delimiters(2) = Chr$(253)          ' ]
  g_delimiters(3) = Chr$(252)       ' \

new_delim = g_delimiters(1)

    If IsNull(sdummy) Then delet = "": Exit Function
    s1 = sdummy
    G_DELIM(1) = attr: G_DELIM(2) = value: G_DELIM(3) = svm
    
    For I = 1 To 3
       eos = 0: soe = Len(s1) + 1
       If G_DELIM(I) = 0 Then GoTo DELETE_900
       new_delim = g_delimiters(I)
       If (G_DELIM(I) <> 1) Then
DELETE_100:
          eos = Index(s1, g_delimiters(I), G_DELIM(I) - 1)
          If eos = 0 Then
             s1 = s1 & g_delimiters(I)
             GoTo DELETE_100
          End If
       Else
          eos = 0
       End If
       soe = InStr(eos + 1, s1, g_delimiters(I), 0) 'mc binary 16/4/96
       If soe = 0 Then soe = Len(s1) + 1
    
DELETE_900:
       If eos = 0 Then sbit(I) = "" Else sbit(I) = Mid$(s1, 1, eos)
       ebit(I) = Mid$(s1, soe)
       s1 = Mid$(s1, eos + 1, soe - 1 - eos)
    Next I
    s1 = sbit(1) & sbit(2) & sbit(3)
    s2 = ebit(3) & ebit(2) & ebit(1)
    If new_delim = Right(s1, 1) Then
       s1 = Left(s1, Len(s1) - 1)
    Else
       If new_delim = Mid(s2, 1, 1) Then s2 = Right(s2, Len(s2) - 1)
    End If
    delet = s1 & s2
    
End Function


Function field(PASSVAR As String, delim As String, posn As Integer) As String

Dim s1 As String, field_startcol As Long, field_endcol As Long

    s1 = PASSVAR
    If posn = 0 Then
       Exit Function
    End If
    If (posn <> 1) Then
       field_startcol = Index(s1, delim, posn - 1) + 1
       If field_startcol = 1 Then
          field_endcol = Len(s1) + 1: field_startcol = field_endcol
          s1 = "": GoTo fieldend
       End If
    Else
       field_startcol = 1
    End If
    field_endcol = InStr(field_startcol, s1, delim, 0)
    If field_endcol <> 0 Then
       If field_endcol <> field_startcol Then
          s1 = Mid$(s1, field_startcol, field_endcol - field_startcol)
       Else
          s1 = "": GoTo fieldend
       End If
    Else
       s1 = Mid$(s1, field_startcol)
    End If
fieldend:
    field = s1
End Function

Function ICONV(datum As String, Mask As String) As String
   Select Case Mask
      Case "MD2"
         If IsNumeric(datum) Then
            ICONV = datum * 100
         Else
            ICONV = datum
         End If
      Case "D2"
         If IsDate(datum) Then
            ICONV = DateDiff("d", "31 dec 67", datum)
         Else
            ICONV = ""
         End If
   End Select
End Function


Function locate(id As String, rec As String, attr As Integer, valm As Integer, SVAL As Integer, posn As Integer, SEQN As String) As String

Dim max As Long, I As Integer, cmp As String, finish  As Long 'mc23jun99
Dim g_delimiters(3) As String, tempcur1 As Currency, tempcur2 As Currency 'mc 23jun99
' Initialise delimiters that will be in received PICK data
  g_delimiters(1) = Chr$(254)      ' ^
  g_delimiters(2) = Chr$(253)          ' ]
  g_delimiters(3) = Chr$(252)       ' \

locate = 0
If valm = 0 Then
   max = dcount(rec, g_delimiters(1))
   For I = 1 To max
      cmp = extract(rec, I, 0, 0)
      GoSub LOCATE_950: If finish = 1 Then GoTo LOCATE_900
   Next I
   posn = max + 1: GoTo LOCATE_900
End If
If SVAL = 0 Then
   max = dcount(extract(rec, attr, 0, 0), g_delimiters(2))
   For I = 1 To max
      cmp = extract(rec, attr, I, 0)
      GoSub LOCATE_950: If finish = 1 Then GoTo LOCATE_900
   Next I
   posn = max + 1: GoTo LOCATE_900
End If
max = dcount(extract(rec, attr, valm, 0), g_delimiters(3))
For I = 1 To max
   cmp = extract(rec, attr, valm, I)
   GoSub LOCATE_950: If finish = 1 Then GoTo LOCATE_900
Next I
posn = max + 1: GoTo LOCATE_900

LOCATE_900: Exit Function

LOCATE_950:
      finish = 0
      If id = cmp Then
         posn = I: locate = 1: GoTo LOCATE_959
      End If
      Select Case SEQN
         Case "AL": If cmp > id Then posn = I: GoTo LOCATE_959
         Case "DL": If cmp < id Then posn = I: GoTo LOCATE_959
         Case "AR"
            If IsNumeric(cmp) Then tempcur1 = CCur(cmp) Else tempcur1 = 0 'mc 23jun99
            If IsNumeric(id) Then tempcur2 = CCur(id) Else tempcur2 = 0 'mc 23jun99
            If tempcur1 > tempcur2 Then posn = I: GoTo LOCATE_959 'mc 23jun99
         Case "DR"
            If IsNumeric(cmp) Then tempcur1 = CCur(cmp) Else tempcur1 = 0 'mc 23jun99
            If IsNumeric(id) Then tempcur2 = CCur(id) Else tempcur2 = 0 'mc 23jun99
            If tempcur1 < tempcur2 Then posn = I: GoTo LOCATE_959 'mc 23jun99
      End Select
      Return
LOCATE_959: finish = 1: Return

End Function

Function match(strng As String, Mask As String) As Integer
' 1) Call function SepMask to get a pre-determing pattern from Mask (combinations o matchstring)
'                         pre-determing patterns in Pick
'                         na - accept only "n" alphabetic characters
'                         mn - accept only "m" numeric characters
'                         nx - accept "n" any characters
'                         'literal' - accepts any literal string enclosed in quotes
'                         A length sepcification of 0 allows  a length of zero or more of following
'                         match operator
' 2) test a string and determin if it matches a pre-determining pattern

Dim typ As String, maskpos As Integer, strpos As Integer, length As Integer, res, I As Integer
Dim s1 As String

  typ = " "
  maskpos = 1
  strpos = 1
  res = SepMask(Mask, maskpos, length, typ)
  Do While res = 1
    If length = 0 Then
      Select Case typ
      Case "a"
        I = strpos
        Do While Mid(strng, I, 1) Like "[a-z]"
          I = I + 1
          If I > Len(strng) Then
            Exit Do
          End If
        Loop
        strpos = I
      Case "n"
        I = strpos
        Do While Mid(strng, I, 1) Like "#"
          I = I + 1
          If I > Len(strng) Then
            Exit Do
          End If
        Loop
        strpos = I
      Case "x"
        match = True
        Exit Function
      End Select

    Else
      If (strpos + length - 1) > Len(strng) Then
        match = False
        Exit Function
      End If

      Select Case typ
      Case "a"
        For I = strpos To length + strpos - 1
            s1 = Mid(strng, I, 1)
            If Not (s1 Like "[a-z]") Then
                match = False
                Exit Function
            End If
        Next
        strpos = strpos + length
      Case "n"
        For I = strpos To length + strpos - 1
            s1 = Mid(strng, I, 1)
            If Not (s1 Like "#") Then
                match = False
                Exit Function
            End If
        Next
        strpos = strpos + length
      Case "x"
        strpos = strpos + length
      Case "l"
        If Mid(strng, strpos, length) = Mid(Mask, maskpos - (length + 1), length) Then
          strpos = strpos + length
        Else
          match = False
          Exit Function
        End If
      End Select
    End If
    res = SepMask(Mask, maskpos, length, typ)
  Loop
  If res = 0 And strpos = Len(strng) + 1 Then
    match = True
  Else
    match = False
  End If
End Function

Function oconv(datum As String, Mask As String) As String

Dim temp, new_datum As String, len_datum As Integer, I As Integer, ch As String
Dim decs As Integer

   Select Case Mask
      Case "D2"
         If IsNumeric(datum) Then
            oconv = Format(datum + 24837, "d mmm yy")
         Else
            oconv = datum
         End If
      Case "MD2", "MD2$", "MD2$,", "MD2,", "MD4"
         If IsNumeric(datum) Then
            decs = CInt(Mid(Mask, 3, 1))
            temp = datum / (10 ^ decs)
            If Mid(Mask, 4, 1) = "$" Then
               If Mid(Mask, 5, 1) = "," Then
                  oconv = FormatCurrency(temp, decs, , , vbTrue)
               Else
                  oconv = FormatCurrency(temp, decs, , , vbFalse)
               End If
            Else
               If Mid(Mask, 4, 1) = "," Then
                  oconv = FormatNumber(temp, decs, , , vbTrue)
               Else
                  oconv = FormatNumber(temp, decs, , , vbFalse)
               End If
            End If
         End If
      Case "MCU"
         If InStr(1, datum, Chr(254), 0) <> 0 Or InStr(1, datum, Chr(253), 0) <> 0 Or InStr(1, datum, Chr(252), 0) <> 0 Then 'mc binary 16/4/96
            new_datum = "": len_datum = Len(datum)
            For I = 1 To len_datum
               ch = Mid$(datum, I, 1)
               If Asc(ch) > 96 And Asc(ch) < 123 Then
                  new_datum = new_datum & Chr$(Asc(ch) - 32)
               Else
                  new_datum = new_datum & ch
               End If
            Next I
            oconv = new_datum
         Else
            oconv = UCase(datum)
         End If
      Case Else
         oconv = datum
   End Select

End Function


Function replace(sdummy As String, attr As Integer, value As Integer, svm As Integer, srepl As String) As String
'
' Description:  This function replaces data in a given string
'               (implementation of PICK replace function)
'
Dim G_DELIM(3) As Integer
Dim sbit(3) As String
Dim ebit(3) As String
Dim s1 As String, I As Integer, eos As Long, soe As Long
Dim g_delimiters(3) As String
' Initialise delimiters that will be in received PICK data
  g_delimiters(1) = Chr$(254)      ' ^
  g_delimiters(2) = Chr$(253)          ' ]
  g_delimiters(3) = Chr$(252)       ' \

    If IsNull(sdummy) Then s1 = "" Else s1 = sdummy
    G_DELIM(1) = attr: G_DELIM(2) = value: G_DELIM(3) = svm
    
    For I = 1 To 3
       eos = 0: soe = Len(s1) + 1
       If G_DELIM(I) = 0 Then GoTo replace_900
       If (G_DELIM(I) <> 1) Then
replace_100:
          eos = Index(s1, g_delimiters(I), G_DELIM(I) - 1)
          If eos = 0 Then
             s1 = s1 & g_delimiters(I)
             GoTo replace_100
          End If
       Else
          eos = 0
       End If
       soe = InStr(eos + 1, s1, g_delimiters(I), 0) 'mc binary 16/4/96
       If soe = 0 Then soe = Len(s1) + 1
    
replace_900:
       If eos = 0 Then sbit(I) = "" Else sbit(I) = Mid$(s1, 1, eos)
       ebit(I) = Mid$(s1, soe)
       s1 = Mid$(s1, eos + 1, soe - 1 - eos)
    Next I
    s1 = sbit(1) & sbit(2) & sbit(3) & srepl & ebit(3) & ebit(2) & ebit(1)
    replace = s1
End Function

'
'Purpose:              1) Seperate Mask string by match syntax in Pick
'                         na - accept only "n" alphabetic characters
'                         mn - accept only "m" numeric characters
'                         nx - accept "n" any characters
'                         'literal' - accepts any literal string enclosed in quotes
'                         A length sepcification of 0 allows  a length of zero or more of following
'                         match operator
'                      2)parameters return values:
'                        Mask - matchstring
'                        MaskPos - current position in Mask
'                        length  - the length of the match operator string
'                        typ - a  alphabetic characters
'                            - n  numeric characters
'                            - x  any characters
'                            - l  literal
'                      3) SepMask function return values:
'                         0 - reach to end of Mask string
'                         1 - continue to check Mask string
'                         2 - Mask string syntax is incorrect
'
'
Private Function SepMask(ByVal Mask, maskpos As Integer, length As Integer, typ As String)

Dim m1 As String

    If maskpos > Len(Mask) Then
      SepMask = 0
      Exit Function
    End If

    m1 = Mid(Mask, maskpos, 1)
    Select Case m1
    Case "1" To "9"
      length = val(Right(Mask, Len(Mask) - maskpos + 1))
      maskpos = maskpos + Len(str(length)) - 1
      typ = Mid(Mask, maskpos, 1)
      If typ <> "a" And typ <> "n" And typ <> "x" Then
        SepMask = 2
      Else
        SepMask = 1
      End If
      maskpos = maskpos + 1
    Case "0"
      length = 0
      maskpos = maskpos + 1
      typ = Mid(Mask, maskpos, 1)
      If typ <> "a" And typ <> "n" And typ <> "x" Then
        SepMask = 2
      Else
        SepMask = 1
      End If
      maskpos = maskpos + 1
    Case "'"
      maskpos = maskpos + 1
      length = 0
      While Mid(Mask, maskpos + length, 1) <> "'"
        length = length + 1
        If (maskpos + length) > Len(Mask) Then
          SepMask = 2
          Exit Function
        End If
      Wend
      maskpos = maskpos + length + 1
      typ = "l"
      SepMask = 1
    Case Else
      SepMask = 2
    End Select
End Function



'***************************************
'modified to long

Function insert(sdummy As String, attr As Integer, the_vm As Integer, svm As Integer, srepl As String) As String
'  INSERT data in a given string (implementation of PICK insert function)

Dim G_DELIM(3) As Integer
Dim sbit(3) As String
Dim new_delim As String, s1 As String, ct_added As Long, I  As Integer
Dim eos As Long, soe As Long, s2 As String
Dim g_delimiters(3) As String
' Initialise delimiters that will be in received PICK data
  g_delimiters(1) = Chr$(254)      ' ^
  g_delimiters(2) = Chr$(253)          ' ]
  g_delimiters(3) = Chr$(252)       ' \

new_delim = g_delimiters(1)

    s1 = sdummy
    If attr = -1 Then
       G_DELIM(1) = dcount(sdummy, g_delimiters(1)) + 1
       G_DELIM(2) = 0 'mc 5jun99
       G_DELIM(3) = 0 'mc 5jun99
    Else
       G_DELIM(1) = attr
       If the_vm = -1 Then
          G_DELIM(2) = dcount(extract(sdummy, attr, 0, 0), g_delimiters(2)) + 1
          G_DELIM(3) = 0 'mc 5jun99
       Else
          G_DELIM(2) = the_vm
          If svm = -1 Then
             G_DELIM(3) = dcount(extract(sdummy, attr, the_vm, 0), g_delimiters(3)) + 1
          Else
             G_DELIM(3) = svm
          End If
       End If
    End If

    ct_added = 0

    For I = 1 To 3
       eos = 0: soe = Len(s1) + 1
       If G_DELIM(I) = 0 Then GoTo INSERT_900
       new_delim = g_delimiters(I)
       If (G_DELIM(I) <> 1) Then
INSERT_100:
          eos = Index(s1, g_delimiters(I), G_DELIM(I) - 1)
          If eos = 0 Then
             s1 = s1 & g_delimiters(I)
             ct_added = ct_added + 1
             GoTo INSERT_100
          End If
       Else
          eos = 0
       End If
       soe = InStr(eos + 1, s1, g_delimiters(I), 0) 'mc binary 16/4/96
       If soe = 0 Then soe = Len(s1) + 1
    
INSERT_900:
       If eos = 0 Then sbit(I) = "" Else sbit(I) = Mid$(s1, 1, eos)
       s1 = Mid$(s1, eos + 1, soe - 1 - eos)
    Next I
    s1 = sbit(1) & sbit(2) & sbit(3)
    ct_added = Len(s1) - ct_added
    s1 = s1 & srepl
    If ct_added < 1 Then
       s2 = sdummy
       'aze 10/10/97 comment out and change code to below, because
       'there was a bug if sdummy has at least one atrribute mark
       'Chr$(254) and nothing in the attribute 1, you insert data into
       'attribute 1, value1 , the insert function gave extra value
       'mark Chr$(253)
       'If s2 <> "" Then s1 = s1 & new_delim
       If s2 <> "" Then
          If Asc(Mid$(s2, 1)) <= Asc(new_delim) Then s1 = s1 & new_delim
       End If
    Else
       s2 = Mid$(sdummy, ct_added + 1)
       If s2 <> "" Then
          If Asc(s2) <= Asc(new_delim) Then s1 = s1 & new_delim
       End If
    End If
    insert = s1 & s2
End Function

Function dcount(PASSVAR As String, FINDCHAR As String) As Long

' Use to count how many attrs, values, subvalues in string

Dim NXPOSN As Long, cnt As Long, posn As Long
'tim 03/02/00 all integers are now longs.

If PASSVAR = "" Then dcount = 0: Exit Function


NXPOSN = 1: cnt = 0
DCOUNT1:
   posn = InStr(NXPOSN, PASSVAR, FINDCHAR, 0) 'mc binary 16/4/96 all uses better with binary
   If posn Then cnt = cnt + 1: NXPOSN = posn + 1: GoTo DCOUNT1
dcount = cnt + 1

End Function
Function extract(PickString As String, attr As Integer, value As Integer, svm As Integer) As String

 Dim Attributes As Variant, Values As Variant, SubValues As Variant

 On Error GoTo ThisErr

 Attributes = Split(PickString, Chr(254), attr + 1, vbBinaryCompare)
 extract = Attributes(attr - 1)
 If value > 0 Then
    Values = Split(extract, Chr(253), value + 1, vbBinaryCompare)
    extract = Values(value - 1)
    If svm > 0 Then
       SubValues = Split(extract, Chr(252), svm + 1, vbBinaryCompare)
       extract = SubValues(svm - 1)
    End If
 End If
Exit Function

ThisErr:
extract = ""
End Function

Function Index(SWORD As String, sWord1 As String, ByVal nC As Integer) As Long


'  This function searches through a given string
' for the occurence of the string specified by sWord1
'
'               Returns: 0 if not found
'                        position number if found
Dim npos As Long

    Do
        npos = InStr(npos + 1, SWORD, sWord1, 0) 'mc binary 17/4/96 all uses were not alphabetic
        nC = nC - 1
    Loop Until ((nC = 0) Or (npos = 0))
    Index = npos

End Function

Sub sr_change(datum As String, OLD As String, newdatum As String)

Dim spos As Long, posn As Long

spos = 1
SR_CHANGE_1:
posn = InStr(spos, datum, OLD, 0) 'mc binary 17/4/96 all uses were not alphabetic
If posn <> 0 Then
   datum = Left$(datum, posn - 1) & newdatum & Right$(datum, Len(datum) - posn - Len(OLD) + 1)
   spos = posn + Len(newdatum)
   GoTo SR_CHANGE_1
End If

End Sub


'***************************************8
Function trimm(SWORD As String) As String

Dim s1 As String, len_s1 As Long, I As Long

s1 = Trim(SWORD)
' now may have spaces in middle of words
len_s1 = Len(s1)
For I = len_s1 To 2 Step -1
   If Mid(s1, I, 1) = " " And Mid(s1, I - 1, 1) = " " Then
      s1 = Left(s1, I - 1) & Mid(s1, I + 1)
   End If
Next I

trimm = s1

End Function



Public Sub sr_chone(datum As String, OLD As String, newdatum As String)

Dim posn As Long

posn = InStr(1, datum, OLD, 0)
If posn <> 0 Then
   datum = Left$(datum, posn - 1) & newdatum & Right$(datum, Len(datum) - posn - Len(OLD) + 1)
End If

End Sub

Function read_dos(the_file As String, the_max As Integer, does_not_exist As Boolean) As String

Dim the_rec As String, filenum As Integer, var As String

    does_not_exist = False
    On Error GoTo get_scroll_keys_exit

    filenum = FreeFile
    Open the_file For Input Access Read As #filenum
    Line Input #filenum, the_rec
    Do While Not Eof(filenum) ' Check for end of file.
       Line Input #filenum, var
       the_rec = the_rec & Chr(254) & var
    Loop
    Close #filenum
    'the_rec = Mid(the_rec, 2)
    the_max = dcount(the_rec, Chr(254))
    read_dos = the_rec

Exit Function

get_scroll_keys_exit:
    Close #filenum
    does_not_exist = True: read_dos = "": the_max = 0
    Exit Function

End Function


Function date_pick_to_vb(Days)
    
' convert PICK date to a standard date format
On Error GoTo date_pick_to_vb_error

date_pick_to_vb = DateAdd("d", Days, "31/12/67")
Exit Function

date_pick_to_vb_error:
date_pick_to_vb = ""
Exit Function

End Function

Public Function time_pick_to_vb(seconds)
    
' convert PICK time to a standard time format
On Error GoTo time_pick_to_vb_error

time_pick_to_vb = Format(DateAdd("s", seconds, "0"), "short time")
Exit Function

time_pick_to_vb_error:
time_pick_to_vb = ""
Exit Function

End Function

Function date_vb_to_pick(dte As String, pick_date As Variant, how As Integer) As Integer

' convert entered date to a pick internal format date

date_vb_to_pick = True

If Not IsDate(dte) Then
   date_vb_to_pick = False
   Exit Function
End If
If how <> 2 And how <> 3 Then '0=winsock pick, 1=d3, 2=pc, 3=pc and pick
   pick_date = DateDiff("d", "31/12/67", CVar(dte)) 'mco 5/6/97 remove cint as is variant
Else
   pick_date = CVar(CDate(dte))
End If

End Function

Sub sr_611(inword As String, conversion, creating As Integer, spc_, keep_wild As Integer, found_wild As Integer)
'
' Remove Punctuation from INWORD
' If date (ie conversion begins with D), leave as is
' conversion is -2 change Punctuation into "_"  added by amy

Dim seq_ch As Integer
Dim zz As Integer
Dim num_chars As Integer
Dim ch As String
Dim new_word

     found_wild = False
     If keep_wild Then
        If InStr(1, inword, "*", 0) Then found_wild = True
        If InStr(1, inword, "?", 0) Then found_wild = True
        If InStr(1, inword, "#", 0) Then found_wild = True
        If InStr(1, inword, "<", 0) Then found_wild = True
        If InStr(1, inword, ">", 0) Then found_wild = True
        'If InStr(1,inword, "=",0) Then found_wild = True
     End If
     If inword = "" Then Exit Sub
     If conversion = "nothing" Then Exit Sub
     If conversion = "-1" Then
        If Index(inword, ".", 2) <> 0 Then
           inword = field(inword, ".", 1) & "." & field(inword, ".", 2)
        End If
        Exit Sub ' no conversion wanted
     End If
     If creating Then
      Select Case conversion
        Case ".1"
           inword = field(inword, ".", 1): Exit Sub
        Case ".2"
           inword = field(inword, ".", 2): Exit Sub
        Case ".3"
           inword = field(inword, ".", 3): Exit Sub
      End Select
     End If

     If Left(conversion, 1) = "D" Then
        inword = Format(inword, "d/m/yyyy")
        Exit Sub
     End If
     new_word = ""
     num_chars = Len(inword)
     For zz = 1 To num_chars
        ch = Mid$(inword, zz, 1)
        seq_ch = Asc(ch)
        Select Case seq_ch
           Case 65 To 90:    new_word = new_word & ch  '32 is space
           Case 48 To 57:    new_word = new_word & ch
           Case 97 To 122:   new_word = new_word & ch 'Chr(SEQ_CH - 32)
           Case Else:
              If keep_wild And (seq_ch = 42 Or seq_ch = 63 Or seq_ch = 35 Or ch = "=" Or ch = "<" Or ch = ">") Then '* ? # resp
                 new_word = new_word & ch
              Else
                 If new_word <> "" And Right(new_word, 1) <> " " Then
                    new_word = new_word & spc_
                 End If
              End If
        End Select
     Next zz
     inword = new_word
End Sub


Public Function ini_read(the_file As String, the_string As String, read_file As String) As String

Dim X As Long
Dim temp As String

temp = String(250, " ")
X = GetPrivateProfileString(the_file, the_string, "", temp, 250, read_file)
ini_read = Left(temp, X)

End Function

Function time_vb_to_pick(tme As String, pick_time As Variant, how As Integer) As Integer
' tim 8/12/99
' convert entered time to a pick internal format time

time_vb_to_pick = True

If Not IsDate(tme) Then
   time_vb_to_pick = False
   Exit Function
End If

If how <> 2 And how <> 3 Then '0=winsock pick, 1=d3, 2=pc, 3=pc and pick
              pick_time = DateDiff("s", 0, tme)
           Else
              pick_time = CVar(CDate(tme))
End If

End Function

Public Function extractint(PickString As String, attr As Integer, value As Integer, svm As Integer, Optional wantnum As Integer = 0) As Integer

Dim temp As String

temp = extract(PickString, attr, value, svm)
If IsNumeric(temp) Then extractint = CInt(temp) Else extractint = 0

End Function

Public Function extractcur(PickString As String, attr As Integer, value As Integer, svm As Integer, Optional wantnum As Integer = 0) As Currency

Dim temp As String

temp = extract(PickString, attr, value, svm)
If IsNumeric(temp) Then extractcur = CCur(temp) Else extractcur = 0

End Function

