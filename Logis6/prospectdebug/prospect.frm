VERSION 5.00
Begin VB.Form debug 
   Caption         =   " dll_debug"
   ClientHeight    =   7965
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   10530
   LinkTopic       =   "Form1"
   ScaleHeight     =   7965
   ScaleWidth      =   10530
   StartUpPosition =   2  'CenterScreen
   WindowState     =   2  'Maximized
   Begin VB.CheckBox Check1 
      Caption         =   "return pick item"
      Height          =   255
      Left            =   8520
      TabIndex        =   15
      Top             =   960
      Width           =   1575
   End
   Begin VB.TextBox Text1 
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   8.25
         Charset         =   204
         Weight          =   400
         Underline       =   -1  'True
         Italic          =   -1  'True
         Strikethrough   =   -1  'True
      EndProperty
      Height          =   315
      Left            =   3375
      TabIndex        =   13
      Top             =   1440
      Width           =   1995
   End
   Begin VB.ComboBox Combo2 
      Height          =   315
      Left            =   3375
      TabIndex        =   12
      Top             =   945
      Width           =   1995
   End
   Begin VB.ComboBox Combo1 
      Height          =   315
      Left            =   3330
      TabIndex        =   7
      Top             =   450
      Width           =   6675
   End
   Begin VB.Frame Frame1 
      Caption         =   " want"
      Height          =   600
      Left            =   5880
      TabIndex        =   3
      Top             =   1440
      Width           =   4410
      Begin VB.OptionButton Option1 
         Caption         =   "item"
         Height          =   150
         Left            =   3645
         TabIndex        =   11
         Top             =   240
         Width           =   735
      End
      Begin VB.OptionButton Option5 
         Caption         =   "combo"
         Height          =   240
         Left            =   2655
         TabIndex        =   6
         Top             =   225
         Width           =   825
      End
      Begin VB.OptionButton Option4 
         Caption         =   "table "
         Height          =   240
         Left            =   1710
         TabIndex        =   5
         Top             =   225
         Width           =   915
      End
      Begin VB.OptionButton Option3 
         Caption         =   "raw"
         Height          =   240
         Left            =   855
         TabIndex        =   4
         Top             =   225
         Width           =   600
      End
   End
   Begin VB.TextBox textpick 
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   5625
      Left            =   1080
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   2
      Top             =   2115
      Width           =   9660
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Submit"
      Height          =   375
      Left            =   270
      TabIndex        =   1
      Top             =   1440
      Width           =   1215
   End
   Begin VB.Label Label2 
      Caption         =   "Template File"
      Height          =   240
      Left            =   2025
      TabIndex        =   14
      Top             =   1485
      Width           =   1185
   End
   Begin VB.Label Label7 
      Caption         =   "getlist secs:"
      Height          =   240
      Left            =   6165
      TabIndex        =   10
      Top             =   945
      Width           =   870
   End
   Begin VB.Label Label4 
      BorderStyle     =   1  'Fixed Single
      Caption         =   "0"
      Height          =   285
      Left            =   7110
      TabIndex        =   9
      Top             =   945
      Width           =   1155
   End
   Begin VB.Label Label3 
      Caption         =   "Select Pick File"
      Height          =   240
      Left            =   2025
      TabIndex        =   8
      Top             =   945
      Width           =   1185
   End
   Begin VB.Label label1 
      Caption         =   "Select Access Query String "
      Height          =   300
      Left            =   1170
      TabIndex        =   0
      Top             =   495
      Width           =   2010
   End
End
Attribute VB_Name = "debug"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Public template_file As String
Public ta31 As New ta31
Public ckaiis As New ckaiis
Public ta16 As New ta16
Public Gl As New Gl
Public loans As New loans




Private Sub Form_Load()
Dim Msg As String
Dim server_name As String
Dim account_name As String

server_name = "cka1"
'account_name = "ckaa"
'account_name = "logis.demo"
account_name = "clare"

Msg = "" 'd3.d3_initialize(server_name, account_name, "dm", "", "", -1)


Text1.Text = "animal" '"property_settlement"
Check1.Enabled = False
Combo1.AddItem "sselect animal"
Combo1.AddItem "sselect sw.pool"
Combo1.AddItem "sselect slog"
Combo1.AddItem "sselect slog.archive"
Combo1.AddItem "sselect rbins"
Combo1.AddItem "sselect client"
Combo1.AddItem "sselect animal with a0 = 1] by ao"
Combo1.AddItem "sselect sw.pool with a0 = ""300"" by a0"
Combo1.ListIndex = 0
Option4.value = True

Combo2.AddItem "animal"
Combo2.AddItem "property"
Combo2.AddItem "slog"
Combo2.AddItem "slog.archive"
Combo2.AddItem "rbins"
Combo2.AddItem "client"
Combo2.AddItem "plans"
Combo2.ListIndex = 0
End Sub
Private Sub Command1_Click()
Dim Rec() As String, max As Integer, kk As Integer, wrec() As String
Dim database As String, Cde As String, username As String
Dim lines() As String, Acct As String, useamt As Currency
Dim wterr As String, mdb_name As String, trans_rec() As String
Dim mthends() As String, dte As String
Dim the_mth As Integer, thisyr As String, suffix As String
Dim year_rec() As String

'database = Pick.extract(logentry, 2, 0, 0)
'username = Pick.extract(logentry, 3, 0, 0)
kk = InStr(tbl_name, ".mdb\")
mdb_name = Left(tbl_name, kk + 3)

issue = "0" 'this means all was okay

If action = "D" Or action = "W" Then
  issue = Chr(8) & "Cannot alter or delete a processed issue"
  Exit Sub
End If

'action = "W" - updating existing item
'action = "A" - adding new item
   
   'Call get_month_ends(mdb_name, mthends(), year_rec())
   
   Rec = Split(the_rec, Chr(8))
   'dte = Rec(0) 'date of issue
   
   lines = Split(transrec, Chr(8))
   max = UBound(lines)
   MsgBox lines
   Exit Sub
   If DateDiff("d", dte, year_rec(2)) > 0 Or DateDiff("d", year_rec(3), dte) > 0 Then
        issue = "issue date " & dte & " must be between " & year_rec(2) & " and " & year_rec(3)
        Exit Sub
   End If
   
  ' Call get_the_mth(dte, mthends(), year_rec(1), the_mth, thisyr, suffix)
    
   For kk = 0 To max Step 3
      Acct = lines(kk)
      If Acct <> "" Then
      ReDim wrec(5)
      wrec(1) = Id
      wrec(2) = CStr(kk / 3 + 1)  'line count
      If IsNumeric(lines(kk + 2)) Then useamt = lines(kk + 2) Else useamt = 0
      If useamt <> 0 Then Cde = "58": GoSub posting 'debit
      'If IsNumeric(lines(kk + 3)) Then useamt = -lines(kk + 3) Else useamt = 0
      'If useamt <> 0 Then Cde = "33": GoSub posting 'credit
      GoTo after_posting

posting:
      wrec(3) = Cde
      wrec(4) = Acct  'account
      wrec(5) = CStr(useamt)
      'wrec(6) = lines(kk + 4)  'narrative
      wrec(0) = Id & "_" & CStr(kk / 3 + 1)
      wterr = d3.d3_writemat(database, mdb_name & "\issue_batch_lines", wrec())

      ReDim trans_rec(22)
      trans_rec(0) = Id & "." & CStr(kk / 3 + 1)
      trans_rec(1) = Cde
      trans_rec(3) = Acct 'account
      trans_rec(4) = CStr(useamt)
      'trans_rec(6) = lines(kk + 4)  'narrative
      trans_rec(16) = username  'user
      trans_rec(17) = Id 'Pick.Replace(trans_rec, 17, 0, 0, Id) 'issue id
      'wterr = post_transaction_gl(database, mdb_name, trans_rec(), useamt, Acct, CInt(Cde), dte, the_mth, thisyr, suffix)
      'If wterr <> "0" Then issue = wterr: Exit Function
      Return
after_posting:
    End If
   Next kk

   ReDim wrec(4)
   wrec(0) = Id
   wrec(1) = Acct  'Rec(0) 'date of issue
   wrec(2) = Date ' date entered
   wrec(3) = 200 ' time entered  Sorry, I would be change you later soon. Okey!!!!!!!
   wrec(4) = username ' user
   'wterr = d3.d3_writemat(database, issue_batch, wrec())

   issue = wterr
   


End Sub

Sub sr_glbud(database As String, flag As String, Exclude As String, glfile As String, jobfile As String, AcctNo As String, gldate As String, eoms As String, acmth As Integer, margin As String, Accval As String, rderr As Integer, errmsg As String)

Dim isjob As Integer, chkbud As Integer, fullyr As Integer, emths() As String, Vm As String
Dim fini As Integer, futuredt As Integer, start As Integer, isper As String, jacct As String, ACT As Integer
Dim gl_rec As String, gl_rec2 As String, budg As Integer, glacct As String, committed As Long, max As Integer
Dim I As Integer, VarAmt As Long, xx As Long, er As Integer, wterr As Integer, Pos As Integer

Vm = Chr(253)
isjob = Pick.extract(flag, 1, 1, 0)
chkbud = Pick.extract(flag, 1, 2, 0)
fullyr = Pick.extract(flag, 1, 3, 0)
emths = Split(eoms, Vm)
max = UBound(emths)
fini = 0
For I = 0 To max
    If gldate = emths(I) Then
        fini = I + 1
        Exit For
    End If
Next
'If gldate = Pick.extract(eoms, 1, 1, 0) Then fini = 1
If fini > acmth Then
    futuredt = 1
    start = (acmth * 2) + 1
    fini = fini + acmth
Else
    futuredt = 0
    start = 1
End If
If fullyr Then fini = start + (acmth - 1)
isper = Pick.extractint(margin, 1, 1, 0)
If isper Then
    margin = (Pick.extractint(margin, 1, 2, 0) / 10000) + 1
Else
    margin = Pick.extractint(margin, 1, 2, 0)
End If

If isjob Then
    If chkbud = 3 Then Exit Sub      '* no check on job budget
    jacct = "JOB" & AcctNo
    If jacct = Pick.extract(Exclude, 1, 1, 0) Then Pos = 1 Else Pos = 0
    If Pos = 1 Then Exit Sub
    If chkbud = 5 Then jacct = Pick.field(AcctNo, ".", 1) Else jacct = AcctNo
    gl_rec = ""
    er = d3.d3_readstr(database, gl_rec, "job.l", jacct)
    If er <> 0 Then
        errmsg = "Job Ledger Account" & jacct & "does not exist!"
        Exit Sub
    End If
        
    gl_rec = Pick.replace(gl_rec, 6, 0, 0, 0)
    gl_rec = Pick.replace(gl_rec, 7, 0, 0, "A")
    gl_rec = Pick.replace(gl_rec, 9, 0, 0, Pick.extract(gl_rec, 59, 0, 0))
    gl_rec = Pick.replace(gl_rec, 35, 0, 0, Pick.extract(gl_rec, 89, 0, 0))
    gl_rec = Pick.replace(gl_rec, 8, 1, 0, CInt(Pick.extract(gl_rec, 24, 1, 0) / 100))
    gl_rec = Pick.replace(gl_rec, 8, 2, 0, CInt(Pick.extract(gl_rec, 24, 2, 0) / 100))
    gl_rec = Pick.replace(gl_rec, 8, 3, 0, CInt(Pick.extract(gl_rec, 24, 3, 0) / 100))
    
   If chkbud = 2 Then               '* if no job budget use gl budget
       If futuredt Then
          budg = Pick.extract(gl_rec, 8, 3, 0)
       Else
          budg = Pick.extract(gl_rec, 8, 1, 0)
       End If
       If budg + 0 = 0 Then
            glacct = Pick.extract(gl_rec, 18, 1, 1)
            gl_rec2 = ""
            er = d3.d3_readstr(database, gl_rec2, "gen.l", glacct)
            gl_rec = Pick.replace(gl_rec, 7, 0, 0, Pick.extract(gl_rec2, 7, 0, 0))
            gl_rec = Pick.replace(gl_rec, 8, 0, 0, Pick.extract(gl_rec2, 8, 0, 0))
       End If
    End If
Else
        If chkbud = 4 Then Exit Sub      '* no check on gl budget
        If chkbud = 5 Then glacct = Pick.field(AcctNo, ".", 1) & "." & Pick.field(AcctNo, ".", 2) Else glacct = AcctNo
        If glacct = Pick.extract(Exclude, 1, 1, 0) Then Pos = 1 Else Pos = 0
        If Pos = 1 Then Exit Sub
        gl_rec = ""
        er = d3.d3_readstr(database, gl_rec, "gen.l", glacct)
        If er <> 0 Then
            errmsg = "General Ledger Account" & glacct & "does not exist!"
            Exit Sub
        End If
End If
        
        ACT = 0
        budg = 0
        committed = Pick.extractint(gl_rec, 32, 1, 0)
                               
        If futuredt Then
            For I = 1 To acmth
               committed = committed + Pick.extract(gl_rec, 35, I, 0)
               gl_rec = Pick.replace(gl_rec, 35, I, 0, CStr(committed))
            Next I
        End If
      
        If Pick.extract(gl_rec, 7, 0, 0) = "A" Then
            If futuredt Then
               budg = Pick.extractint(gl_rec, 8, 3, 0)
            Else
               budg = Pick.extractint(gl_rec, 8, 1, 0)
            End If
            For I = start To fini
                ACT = ACT + Pick.extract(gl_rec, 9, I, 0)
                committed = committed + Pick.extract(gl_rec, 35, I, 0)
                gl_rec = Pick.replace(gl_rec, 35, I, 0, CStr(committed))
            Next I
        Else
            For I = start To fini
                ACT = ACT + Pick.extract(gl_rec, 9, I, 0)
                committed = committed + Pick.extract(gl_rec, 35, I, 0)
                budg = budg + Pick.extract(gl_rec, 8, I, 0)
                gl_rec = Pick.replace(gl_rec, 35, I, 0, CStr(committed))
            Next I
        End If

        If isper Then
            VarAmt = Math.Abs(ACT + committed) + Accval
            If VarAmt > Abs(budg * 100) * margin Then
                GoTo 195
            End If
        Else
        
        VarAmt = Abs(ACT + committed) + Accval
        If VarAmt > Math.Abs(budg * 100) + margin Then
195         xx = (VarAmt - Math.Abs(budg * 100)) / 100
            errmsg = "Commitment will exceed budget by " & xx & "!"
            GoTo 200
         End If
        End If
    wterr = d3.d3_writestr(database, "gen.l", AcctNo, gl_rec)
    
Exit Sub

200 rderr = 1

End Sub



Private Sub Combo2_Change()
template_file = Combo2.Text
Text1.Text = Combo2.Text
Text1.Refresh
End Sub

Private Sub Text1_Change()
template_file = Text1.Text
End Sub

Private Sub Option1_Click()
Combo1.Clear
Combo1.AddItem "3334"
Combo1.AddItem "2"
Combo1.AddItem "317"
Combo1.ListIndex = 0
If Option1.value = True Then Check1.Enabled = True

End Sub

Private Sub Option3_Click()
Combo1.Clear
Combo1.AddItem "sselect animal"
Combo1.AddItem "sselect sw.pool"
Combo1.AddItem "sselect slog"
Combo1.AddItem "sselect slog.archive"
Combo1.AddItem "sselect rbins"
Combo1.AddItem "sselect client"
Combo1.AddItem "sselect animal with a0 = 1] by ao"
Combo1.AddItem "sselect sw.pool with a0 = ""300"" by a0"
Combo1.ListIndex = 0
Check1.Enabled = False
Check1.value = 0

End Sub

Private Sub Option4_Click()

Combo1.Clear
Combo1.AddItem "sselect sw.pool"
Combo1.AddItem "sselect slog"
Combo1.AddItem "sselect slog.archive"
Combo1.AddItem "sselect rbins"
Combo1.AddItem "sselect client"
Combo1.AddItem "sselect animal"
Combo1.AddItem "sselect animal with a0 = 1] by ao"
Combo1.AddItem "sselect sw.pool with a0 = ""300"" by a0"
Combo1.ListIndex = 0
Check1.value = 0
Check1.Enabled = False

End Sub

Private Sub Option5_Click()
Combo1.Clear
Combo1.AddItem "sselect sw.pool"
Combo1.AddItem "sselect slog"
Combo1.AddItem "sselect slog.archive"
Combo1.AddItem "sselect rbins"
Combo1.AddItem "sselect client"
Combo1.AddItem "sselect animal"
Combo1.AddItem "sselect animal with a0 = 1] by ao"
Combo1.AddItem "sselect sw.pool with a0 = ""300"" by a0"
Combo1.ListIndex = 0
Check1.value = 0
Check1.Enabled = False

End Sub

