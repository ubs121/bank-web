VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "loans"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Option Compare Text


Public Function ta_loans_audit(logentry As String, parms As String) As String

' TA3565 HIRE PURCHASE LEDGER AUDIT
Dim nn As Integer, kk As Long, total_items As Long, mylist() As String, pick_cnt As Long
Dim Id As String, hrec As String, database As String, interest As Currency, mult As Integer
Dim Gl_Pcpl As String, Gl_Int As String, Hpbal As Currency, pcpl As Currency, Hpint As Currency
Dim Client_No As String, starti As Integer, report As String, rct As Integer, temp As String
Dim sentence As String, Client_Rec As String, Max As Integer
Dim Tot_Bal As Currency, pt_line As String, final_date As String
Dim Tot_Gl As Currency, I As Integer, Glbal As Currency, Stot As Currency, Gl, zz, Cd
Dim Xtra_Val, Xtra_Code, Totxtra_Val, Xgl_Code, Max_Ctl, Ii, Cred_Ctl
Dim Ctl_Group, Ctl_Class, Ctl_Sclass, Jj, Tact, T_Group, T_Class
Dim T_Sclass, xx, T_Type, Pos
Dim tot_unpaid As Currency, tot_paid As Currency
     
     database = Pick.extract(logentry, 2, 0, 0)
     
     If d3.d3_readstr(database, temp, "DICT TRANS.J", "@LOANS") <> 0 Then
        ta_loans_audit = Chr(8) & "Setup loan control parameters"
        Exit Function
     End If
     Gl_Pcpl = Pick.extract(temp, 1, 0, 0)
     Gl_Int = Pick.extract(temp, 2, 0, 0)
     Hpbal = 0: Hpint = 0
     report = "": rct = 0
     
   tot_unpaid = 0: tot_paid = 0
   sentence = "SSELECT LOANS"
   total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0) - 1
   GoSub 250
   
   For kk = 0 To total_items
     Id = mylist(kk)
110  If d3.d3_readstr(database, hrec, "LOANS", Id) <> 0 Then GoTo 190
     final_date = Pick.extract(hrec, 4, 0, 0)
     If final_date = "" Then
        tot_unpaid = tot_unpaid + 1
     Else
        tot_paid = tot_paid + 1 'fully paid out
        If d3.d3_readstr(database, hrec, "TD.FOLLOWUP", Id) <> 0 Then
           pt_line = "LOANS " & Id & " will be finalised " & Pick.oconv(final_date, "D2") & ".  Cancel direct debit authority after this date"
           GoSub 250
        End If
        GoTo 190
     End If
     Client_No = Pick.extract(hrec, 1, 0, 0)
     If d3.d3_readstr(database, Client_Rec, "CLIENT", Client_No) <> 0 Then
        pt_line = "LOANS " & Id & " client " & Client_No & " does not exist"
        GoSub 250
     End If
     Max = Pick.dcount(Pick.extract(hrec, 12, 0, 0), Chr(253))
     starti = 0
     For nn = Max To 1 Step -1 ' calculate principal and interest still to be invoiced
        If Pick.extract(hrec, 16, nn, 0) <> "" Then starti = nn: GoTo 115
     Next nn
115  starti = starti + 1
     pcpl = 0: interest = 0
     For nn = starti To Max
        If Pick.extract(hrec, 16, nn, 0) = "" Then
           If Pick.extract(hrec, 12, nn, 0) <> "" Then
              pcpl = pcpl + Pick.extractcur(hrec, 13, nn, 0)
              interest = interest + Pick.extractcur(hrec, 14, nn, 0)
           End If
        End If
     Next nn
     Hpbal = Hpbal + pcpl
     Hpint = Hpint + interest
190:
   Next kk
    
   GoSub 250
   pt_line = tot_unpaid & " unpaid loans": GoSub 250
   pt_line = tot_paid & " paid loans": GoSub 250
   
         GoSub 250
        Tot_Bal = 0
        Tot_Gl = 0
           If d3.d3_readstr(database, temp, "GEN.L", Gl_Pcpl) <> 0 Then temp = ""
           Glbal = Pick.extractcur(temp, 4, 0, 0)
           Glbal = -Glbal
           pt_line = "Total of unpaid LOANS balances " & Space(15) & " = " & Right(Space(16) & Pick.oconv(CStr(Hpbal), "MD2"), 16) & Space(2) & "Account " & Left(Gl_Pcpl & Space(11), 11) & " = " & Right(Space(16) & Pick.oconv(CStr(Glbal), "MD2"), 16)
           If Glbal <> Hpbal Then
              pt_line = pt_line & Space(5) & "ERROR " & Right(Space(11) & Pick.oconv(CStr(Hpbal - Glbal), "MD2"), 11)
           End If
           GoSub 250
           pt_line = "Total of unpaid interest to be earned " & Space(15) & " = " & Right(Space(15) & Pick.oconv(CStr(Hpint), "MD2"), 15)
           GoSub 250
           GoSub 250
           Tot_Bal = Tot_Bal + Hpbal
           Tot_Gl = Tot_Gl + Glbal
212     GoSub 250
        'GoSub 500     ' LOOK FOR TRANSACTIONS IN TRANS_J
'        If Xtra_Val <> "" Then
'          GoSub 250
'          pt_line = Left(("Total value still to be processed to General Ledger in transaction journal is ") & Space(96), 96) & Right(Space(16) & Pick.oconv(-Totxtra_Val, "MD2"), 16)
'          GoSub 250
'          For I = 1 To Max_Ctl
'             Stot = 0
'             Gl = Pick.extract(Xgl_Code, 1, I, 0)
'             GoSub 250
'             pt_line = Left(("Total value still to be processed for Account " & Gl & " is ") & Space(60), 60)
'             zz = 0
'             For Kk = 1 To 999
'                Cd = Pick.extract(Xtra_Code, 1, Kk, 0)
'                If Cd = "" Then GoTo 214
'                If Pick.extract(Xtra_Val, 1, I, Kk) = 0 Then GoTo 213
'                If zz = 0 Then
'                   pt_line = Left((pt_line & Cd & " " & Pick.extract(Trans_Info, 3, Cd, 0)) & Space(80), 80) & Right(Space(16) & oconv(Pick.extract(-Xtra_Val, 1, I, Kk), "MD2"), 16)
'                   zz = 1
'                Else
'                   pt_line = Space(60) & Left((Cd & " " & Pick.extract(Trans_Info, 3, Cd, 0)) & Space(20), 20) & Right(Space(16) & oconv(Pick.extract(-Xtra_Val, 1, I, Kk), "MD2"), 16)
'                End If
'                GoSub 250
'                Stot = Stot + (Pick.extract(-Xtra_Val, 1, I, Kk))
'213          Next Kk
'214          If Pick.extract(Xtra_Val, 1, I, 0) = 0 Then
'                GoTo 215
'             Else
'                pt_line = Space(87) & "---------" & Right(Space() & Pick.oconv(Stot, "MD2")): GoSub 250
'             End If
'215       Next I
'        End If
        ta_loans_audit = report
        Exit Function

250  rct = rct + 1
     report = Pick.replace(report, rct, 0, 0, pt_line)
     pt_line = ""
     Return
'
' S/R 500: ROUTINE TO CHECK "TRANS.J" FOR UNPROCESSED TRANSACTIONS
'
'500  SELECT TRANS_J_DATA
'     Xtra_Val = "": Xtra_Code = "": Totxtra_Val = 0
'     Xgl_Code = Gl_Pcpl
'     Max_Ctl = ccount(Gl_Pcpl, Chr(253)) + 1
'510  READNEXT TID ELSE RETURN
'     If d3.d3_readstr(trec, "TRANS.J", TID) <> 0 Then GoTo 510
'     For Ii = 1 To Max_Ctl
'       Cred_Ctl = Pick.extract(Gl_Pcpl, 1, Ii, 0)
'       If InStr(Pick.extract(trec, 3, 0, 0), Cred_Ctl) Then
'         Ctl_Group = field(Cred_Ctl, "_", 1)
'         Ctl_Class = field(Cred_Ctl, "_", 2)
'         Ctl_Sclass = field(Cred_Ctl, "_", 3)
'         For Jj = 1 To 999
'           Tact = Pick.extract(trec, 3, Jj, 0)
'           If Tact = "" Then GoTo 560
'           T_Group = field(Tact, "_", 1)
'           If Ctl_Group <> "" Then
'             If Cred_Ctl <> Tact Then GoTo 550
'           Else
'             T_Class = field(Tact, "_", 2)
'             T_Sclass = field(Tact, "_", 3)
'             If T_Class <> Ctl_Class Or T_Sclass <> Ctl_Sclass Then GoTo 550
'           End If
'           LOCATE(CRED_CTL,XGL_CODE,1,1,0,XX,"") ELSE XX = 0
'           T_Type = Pick.extract(trec, 1, Jj, 0)
'           If T_Type < 50 Then mult = 1 Else mult = -1
'520        LOCATE(T_TYPE,XTRA_CODE,1,1,0,POS,"") ELSE POS = ""
'           If Pos = "" Then
'              Xtra_Code = insert(Xtra_Code, 1, -1, 0, T_Type)
'              GoTo 520
'           End If
'           Xtra_Val = Pick.replace(Xtra_Val, 1, Xx, Pos, Pick.extract(Xtra_Val, 1, Xx, Pos) + Pick.extract(mult * trec, 4, Jj, 0))
'           Totxtra_Val = Pick.extract(Totxtra_Val + mult * trec, 4, Jj, 0)
'550      Next Jj
'       End If
'560  Next Ii
'     GoTo 510    ' LOOP TILL SELECT LIST EXHAUSTED

End Function

Public Function ta_loans_update(logentry As String, tbl_name As String, Id As String, the_rec As String, old_rec As String, action As String) As String

Dim wterr As String, writeerror As Boolean

Dim LoanRec() As String, database As String
Dim IntFreePays As Integer, IntPays As Integer
Dim I As Integer, relate As String, total_repay As Currency, diff As Currency
Dim PayDate As Date, DateString As String
Dim strInterval As String, number_interest_pays As Integer
Dim Monthly As Double, IntFreePaid As Double
Dim int_rate As Double, repay As Double, save_repay As Double, paid_after_free As Double
Dim still_to_pay As Double, total_interest As Double, J As Integer
Dim interest_on_this  As Double, interest_on_this_one_period As Double
Dim each_int() As String, k As Integer, clrec As String, tdrec As String

ta_loans_update = "0" 'this means all was okay
database = Pick.extract(logentry, 2, 0, 0)

If Pick.extract(the_rec, 16, 0, 0) <> "" Then
   If action = "D" Then
      ta_loans_update = Chr(8) & "Cannot delete a loan after invoices have been processed"
      Exit Function
   End If
   tdrec = old_rec 'start with old record - allow change of narrative,last payment date and amount
   tdrec = Pick.replace(tdrec, 4, 0, 0, Pick.extract(the_rec, 4, 0, 0))
   tdrec = Pick.replace(tdrec, 5, 0, 0, Pick.extract(the_rec, 5, 0, 0))
   tdrec = Pick.replace(tdrec, 7, 0, 0, Pick.extract(the_rec, 7, 0, 0))
   the_rec = tdrec
   GoTo updating_entry
End If
   
If action = "D" Then
   writeerror = d3.d3_delete(database, tbl_name, Id)
   Exit Function
End If

' attr1 is debtor
' attr3 is assess

    int_rate = Pick.extractcur(the_rec, 9, 0, 0) / 10000
    
    LoanRec = Split(the_rec, Chr(254), , vbBinaryCompare)
    If UBound(LoanRec) < 17 Then ReDim Preserve LoanRec(17)
    If d3.d3_readstr(database, clrec, "client", LoanRec(0)) <> 0 Then clrec = ""
    If d3.d3_readstr(database, tdrec, "tdebtor", LoanRec(0)) <> 0 Then tdrec = ""
    If clrec = "" Or tdrec = "" Or Pick.extract(clrec, 10, 0, 0) = "" Or Pick.extract(clrec, 28, 0, 0) <> "" Then
       ta_loans_update = Chr(8) & LoanRec(0) & " is not a valid debtor"
       Exit Function
    End If
    If d3.d3_readstr(database, relate, "DICT TRANS.J", "@LOANS", 6) <> 0 Then relate = ""
    If relate <> Pick.extract(tdrec, 23, 0, 0) Then
       ta_loans_update = Chr(8) & LoanRec(0) & " has relationship code " & Pick.extract(tdrec, 23, 0, 0) & " but must be " & relate
       Exit Function
    End If
    If d3.d3_readstr(database, tdrec, "property", LoanRec(2)) <> 0 Then tdrec = ""
    If tdrec = "" Then
       ta_loans_update = Chr(8) & LoanRec(2) & " is not a valid property assessment"
       Exit Function
    End If
                         
    If LoanRec(11) = "" Then
       ta_loans_update = Chr(8) & "Do not have a first payment date"
       Exit Function
    Else
       PayDate = Pick.date_pick_to_vb(Pick.extract(LoanRec(11), 1, 1, 0))
    End If
    If LoanRec(7) > LoanRec(5) Then
       ta_loans_update = Chr(8) & "Interest free years cannot exceed loan term years"
       Exit Function
    End If
    IntPays = LoanRec(1) * LoanRec(5) ' Pays per year times term of loan years
    IntFreePays = LoanRec(1) * LoanRec(7) ' Pays per year times years int free
    Select Case LoanRec(1)
       Case "12": strInterval = "m"
       Case "4": strInterval = "q"
       Case "1": strInterval = "yyyy"
       Case Else:
          ta_loans_update = Chr(8) & "Only support 1,4 or 12 payments per year"
          Exit Function ' don't have a 1st payment date
    End Select
    
'FIRST ATTEMPT
    repay = LoanRec(9) / IntPays / 100
    save_repay = repay
    number_interest_pays = LoanRec(1) * (LoanRec(5) - LoanRec(7))
iterate:
    ReDim eachint(0)
    paid_after_free = repay * IntFreePays
    still_to_pay = LoanRec(9) / 100 - paid_after_free
    total_interest = 0
    For J = 1 To number_interest_pays
       interest_on_this = still_to_pay * int_rate
       interest_on_this_one_period = interest_on_this / LoanRec(1)
       total_interest = total_interest + interest_on_this_one_period
       ReDim Preserve eachint(J): eachint(J) = interest_on_this_one_period
       still_to_pay = still_to_pay - repay
    Next J
    repay = LoanRec(9) / IntPays / 100 + total_interest / IntPays
    If Abs(repay - save_repay) > 0.001 Then save_repay = repay: GoTo iterate
    repay = Int(repay * 100 + 0.5) / 100
    For J = 1 To UBound(eachint)
       eachint(J) = Int(eachint(J) * 100 + 0.5) / 100
    Next J
    
    LoanRec(11) = "": total_repay = 0
    For I = 1 To IntPays
        If Pick.date_vb_to_pick(CStr(PayDate), DateString, 0) Then
            LoanRec(11) = Pick.replace(LoanRec(11), 1, I, 0, DateString)
            If I <= IntFreePays Then
               LoanRec(12) = Pick.replace(LoanRec(12), 1, I, 0, CStr(repay * 100)) 'pcpl
               LoanRec(13) = Pick.replace(LoanRec(13), 1, I, 0, 0) 'interest
            Else
               k = I - IntFreePays
               LoanRec(12) = Pick.replace(LoanRec(12), 1, I, 0, CStr(repay * 100 - eachint(k) * 100)) 'pcpl
               LoanRec(13) = Pick.replace(LoanRec(13), 1, I, 0, CStr(eachint(k) * 100)) 'interest
            End If
            LoanRec(14) = Pick.replace(LoanRec(14), 1, I, 0, CStr(repay * 100)) 'total repay
            total_repay = total_repay + repay - eachint(k)  'add up total principal
        End If
        PayDate = DateAdd(strInterval, 1, PayDate)
    Next I
    If total_repay <> LoanRec(9) Then
       diff = LoanRec(9) - total_repay * 100
       If diff <> 0 Then
          LoanRec(12) = Pick.replace(LoanRec(12), 1, IntPays, 0, Pick.extractcur(LoanRec(12), 1, IntPays, 0) + diff)
          LoanRec(13) = Pick.replace(LoanRec(13), 1, IntPays, 0, Pick.extractcur(LoanRec(13), 1, IntPays, 0) - diff)
       End If
    End If
    LoanRec(17) = LoanRec(9) 'set amount to settle to original amount of loan
    the_rec = Join(LoanRec, Chr(254))
updating_entry:
    wterr = d3.d3_writestr(database, tbl_name, Id, the_rec)
    If wterr = "0" Then
       ta_loans_update = "0" & Chr(253) & Id
    Else
       ta_loans_update = wterr & Chr(253) & Id & Chr(253) & "Write to " & tbl_name & " item " & Id & " failed." & wterr
    End If

End Function


Public Function ta_loans_debtor(logentry As String, tbl_name As String, Id As String, the_rec As String, old_rec As String, action As String) As String

Dim wterr As String, writeerror As Boolean, rderr As Integer
Dim relation As String, temp As String, adding As Integer
Dim td_rec As String, prev_rec As String, Client_No As String, database As String

ta_loans_debtor = "0" 'this means all was okay
database = Pick.extract(logentry, 2, 0, 0)

If action = "D" Then
   ta_loans_debtor = Chr(8) & "Cannot delete a debtor"
   'writeerror = d3.d3_delete(database, tbl_name, id)
   Exit Function
End If
If action = "W" Then
   prev_rec = old_rec
   Client_No = Id
   adding = 0
   GoTo updating
End If

prev_rec = ""

the_rec = Pick.replace(the_rec, 10, 0, 0, "1") ' flag as debtor

td_rec = ""
If d3.d3_readstr(database, relation, "DICT TRANS.J", "@LOANS", 6) <> 0 Then relation = ""
td_rec = Pick.replace(td_rec, 23, 0, 0, relation) 'this is the relationship code being used for these debtors
td_rec = Pick.replace(td_rec, 3, 0, 0, "0") 'set balance to 0

next_client_no:
If Id = "=" Then Client_No = sr_number(database, 0) Else Client_No = Id

If d3.d3_readstr(database, prev_rec, "CLIENT", Client_No) = 0 Then
   ta_loans_debtor = Chr(8) & "Client " & Client_No & " already exists"
   If Id = "=" Then GoTo next_client_no
   Exit Function
End If
prev_rec = ""
adding = 1

updating:
temp = SR3D_WRITE(logentry, Client_No, the_rec, 0, 1, 4, td_rec, adding, prev_rec, 1)
If temp = "0" Then
   ta_loans_debtor = "0" & Chr(253) & Client_No
Else
   ta_loans_debtor = temp
End If

End Function
Public Function ta_loans_invoice(logentry As String, sentence As String, parms As String) As String

' GENERATE INVOICES FOR LOANS (WASTE WATER)

Dim nn As Integer, kk As Long, total_items As Long, mylist() As String, pick_cnt As Long
Dim Id As String, hrec As String, database As String, wterr As Integer, tj_tno As String
Dim ICODE As String, Tax_Code As String, Gl_Pcpl As String, Gl_Int As String, Pos As Integer
Dim inv_Date As Integer, Ldate As Integer, NO_BATCH As String, Wantpr As String, Max As Integer
Dim starti As Integer, INVNO As Currency, invkey As String, value As String, pcpl As String, interest As Currency, Numi As String, Narr As String
Dim IREC As String, Ddebit_Flag As String, Dd_Err As String, Direct_Debit_Rec As String, Dd_Amt As String, Trans_Cnt As Integer
Dim trans_key As String, Dd_Trec As String, Dd_Brec As String, temp As String, Client_No As String
Dim duedate As Integer

     database = Pick.extract(logentry, 2, 0, 0)
     temp = d3.execute_tcl(logentry, "WHO", "")
     tj_tno = Right("000" & Pick.field(temp, " ", 1), 3)
     
     If d3.d3_readstr(database, temp, "DICT TRANS.J", "@LOANS") <> 0 Then
        ta_loans_invoice = Chr(8) & "Setup loan control parameters"
        Exit Function
     End If
     ICODE = Pick.extract(temp, 4, 0, 0)
     Tax_Code = Pick.extract(temp, 3, 0, 0)
     Gl_Pcpl = Pick.extract(temp, 1, 0, 0)
     Gl_Int = Pick.extract(temp, 2, 0, 0)
     
     inv_Date = Pick.extractint(parms, 1, 0, 0)
     Ldate = Pick.extractint(parms, 2, 0, 0)
     NO_BATCH = Pick.extract(parms, 3, 0, 0)
     Wantpr = Pick.extract(parms, 4, 0, 0)
'
     sentence = "SSELECT LOANS"

   total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0) - 1

   For kk = 0 To total_items
     Id = mylist(kk)
110  If d3.d3_readstr(database, hrec, "LOANS", Id) <> 0 Then GoTo 190
     If Pick.extract(hrec, 4, 0, 0) <> "" Then GoTo 190 'loan paid off
'$INSERT I.LOG.UPDATE '|LOANS|':ID 110 HREC
     Max = Pick.dcount(Pick.extract(hrec, 12, 0, 0), Chr(253))
     starti = 0
     For nn = Max To 1 Step -1
        If Pick.extract(hrec, 16, nn, 0) <> "" Then starti = nn: GoTo 115
     Next nn
115  starti = starti + 1
     For nn = starti To Max
        If Pick.extract(hrec, 16, nn, 0) = "" Then
           duedate = Pick.extractint(hrec, 12, nn, 0)
           If duedate <= inv_Date And Pick.extract(hrec, 12, nn, 0) <> "" Then
              GoSub 170
              GoTo 190
           End If
        End If
     Next nn
190:
   Next kk
   ta_loans_invoice = NO_BATCH
   Exit Function
'
' Raise invoice
'
170  If d3.d3_readstr(database, temp, "DICT INVOICE", "@" & ICODE & "NO") <> 0 Then temp = "0"
'$INSERT I.LOG.UPDATE 'DICT|INVOICE|@':ICODE:'NO' 170 INVNO
     If IsNumeric(temp) Then INVNO = CCur(temp) Else INVNO = 0
175: INVNO = INVNO + 1
     wterr = d3.d3_writestr(database, "DICT INVOICE", "@" & ICODE & "NO", CStr(INVNO))
     invkey = ICODE & INVNO
'
     value = Pick.extract(hrec, 15, nn, 0)
     pcpl = Pick.extract(hrec, 13, nn, 0)
     interest = Pick.extractcur(hrec, 14, nn, 0)
     Client_No = Pick.extract(hrec, 1, 0, 0)

     Numi = "Instalment-" & nn
     If nn = Max Then Numi = Numi & " (last!)"
     Narr = "Loan " & Id & " " & Numi
     IREC = ""
     IREC = Pick.replace(IREC, 3, 0, 0, Client_No)
     IREC = Pick.replace(IREC, 7, 0, 0, tj_tno & Timer())
     IREC = Pick.replace(IREC, 8, 0, 0, value)
     IREC = Pick.replace(IREC, 9, 0, 0, 2)
     IREC = Pick.replace(IREC, 10, 1, 0, Gl_Pcpl)
     IREC = Pick.replace(IREC, 12, 1, 0, Narr)
     IREC = Pick.replace(IREC, 13, 1, 0, 1)
     IREC = Pick.replace(IREC, 15, 1, 0, pcpl)
     IREC = Pick.replace(IREC, 16, 1, 0, Tax_Code)
     IREC = Pick.replace(IREC, 17, 1, 0, 0)
     If interest <> 0 Then
        IREC = Pick.replace(IREC, 10, 2, 0, Gl_Int)
        IREC = Pick.replace(IREC, 12, 2, 0, Narr)
        IREC = Pick.replace(IREC, 13, 2, 0, 1)
        IREC = Pick.replace(IREC, 15, 2, 0, CStr(interest))
        IREC = Pick.replace(IREC, 16, 2, 0, Tax_Code)
        IREC = Pick.replace(IREC, 17, 2, 0, 0)
     End If
     IREC = Pick.replace(IREC, 20, 0, 0, CStr(duedate))
     IREC = Pick.replace(IREC, 21, 0, 0, CStr(Ldate))
     IREC = Pick.replace(IREC, 22, 0, 0, 3)
     IREC = Pick.replace(IREC, 26, 0, 0, Narr)
     IREC = Pick.replace(IREC, 30, 0, 0, NO_BATCH)
     
     If SR_INV_BATCH(database, invkey, ICODE, NO_BATCH, IREC) <> 0 Then GoTo 170 'check invoice number is okay and add to batch item if it is
     
     Ddebit_Flag = 1
     Dd_Err = ""
     If d3.d3_readstr(database, Direct_Debit_Rec, "DIRECT.DEBIT", Client_No) <> 0 Then
        Direct_Debit_Rec = ""
        Dd_Err = "Direct Debit not set up "
        Ddebit_Flag = 0
     End If

     If Ddebit_Flag Then
        Dd_Amt = value
        If Pick.extract(Direct_Debit_Rec, 19, 0, 0) = "" Then
           Dd_Err = "Not on Direct Debit "
           Ddebit_Flag = 0
        End If
        If duedate >= Pick.extractint(Direct_Debit_Rec, 21, 0, 0) And Pick.extract(Direct_Debit_Rec, 21, 0, 0) <> "" Then
           Dd_Err = Dd_Err & "Terminated "
           Ddebit_Flag = 0
        End If
        If Pick.extract(Direct_Debit_Rec, 26, 0, 0) <> "" Then
           Dd_Err = Dd_Err & "Stopped "
           Ddebit_Flag = 0
        End If
        If Pick.extract(Direct_Debit_Rec, 27, 0, 0) <> "" Then
           Dd_Err = Dd_Err & "Amount overide "
           Dd_Amt = Pick.extract(Direct_Debit_Rec, 27, 0, 0)
        End If
        If Pick.extract(Direct_Debit_Rec, 28, 0, 0) = "" Then
           Dd_Err = Dd_Err & "Awaiting Bank"
           Ddebit_Flag = 0
        End If
     End If
     trans_key = ""
     If Ddebit_Flag Then
        Trans_Cnt = 0
290     Trans_Cnt = Trans_Cnt + 1
        trans_key = CStr(duedate) & "." & Trans_Cnt
        If Pick.locate(trans_key, Direct_Debit_Rec, 9, 1, 0, Pos, "AR") = 0 Then
           Direct_Debit_Rec = Pick.insert(Direct_Debit_Rec, 9, Pos, 0, trans_key)
           GoTo 295
        End If
        GoTo 290
295     Dd_Trec = ""
        Dd_Trec = Pick.replace(Dd_Trec, 9, 0, 0, Dd_Amt)
        Dd_Trec = Pick.replace(Dd_Trec, 11, 0, 0, ICODE)
        trans_key = Client_No & "*" & trans_key
        wterr = d3.d3_writestr(database, "DD.TRANS", trans_key, Dd_Trec)
        wterr = d3.d3_writestr(database, "DIRECT.DEBIT", Client_No, Direct_Debit_Rec)
        If d3.d3_readstr(database, Dd_Brec, "DD.BATCH", CStr(duedate)) <> 0 Then Dd_Brec = ""
        Dd_Brec = Pick.insert(Dd_Brec, -1, 0, 0, trans_key)
        wterr = d3.d3_writestr(database, "DD.BATCH", CStr(duedate), Dd_Brec)
'     Else
'        Release DIRECT_DEBIT_DATA, client_no
     End If
     
     IREC = Pick.replace(IREC, 66, 0, 0, trans_key)
     IREC = Pick.replace(IREC, 67, 0, 0, Dd_Err)
     wterr = d3.d3_writestr(database, "INV.BATCH", invkey, IREC)
     
     If nn = Max Then
        hrec = Pick.replace(hrec, 4, nn, 0, CStr(duedate))
        hrec = Pick.replace(hrec, 7, nn, 0, value)
     End If
     hrec = Pick.replace(hrec, 16, nn, 0, invkey)
     If trans_key <> "" Then hrec = Pick.replace(hrec, 19, nn, 0, trans_key)
     hrec = Pick.replace(hrec, 18, 0, 0, Pick.extractcur(hrec, 18, 0, 0) - pcpl) 'subtract pcpl from amount to settle
     
     wterr = d3.d3_writestr(database, "LOANS", Id, hrec)
     
 '    If Lc = 0 Or Lc = 50 Then
 '       Pc = Pc + 1
 '       Printer.Print  ERASE; Left(("Direct Debit Invoice Report as at " & TIMEICONV(FORMAT$(NOW,"DD MMM YY"),"D2")) & Space(120),120); "Page & "; PC
 '       Printer.Print
 '       Printer.Print "Account Name Bank Branch Amount Notes"
 '       Printer.Print "------- ------------------------------ -------------------- -------------------- ---------- ----------------------------"
 '       Lc = 0
 '    End If
 '    Lc = Lc + 1
 '    Printer.Print Left(client_no & Space(7), 7); " "; oconv(client_no, "TCLIENT:X::1") & "  " & oconv(pick.extract(Direct_Debit_Rec, 17, 0, 0), "TDP_BANK:X::1"); "L#20" & "  " & pick.extract(Direct_Debit_Rec, 18, 0, 0); "L#20" & "  " & oconv(Dd_Amt, "MD2"); "R#10" & "  " & Dd_Err
 '    Printer.Print ER; OFF
'
     If Wantpr = "Y" Then
        wterr = d3.d3_writestr(database, "PR.INV", invkey, "")
     End If
     Return
     
End Function


Public Function sr_number(database As String, prop As Integer) As String

Dim in_value As String, uprop As Integer, Client_No As Currency, wterr As String
'
' get and update @NUMBER in DICT CLIENT with next number
'
      If d3.d3_readstr(database, in_value, "DICT CLIENT", "@NUMBER") <> 0 Then in_value = "1"
'$INSERT I.LOG.UPDATE 'DICT|CLIENT|@NUMBER' 300 IN.VALUE
      uprop = prop + 1: If prop = 3 Then uprop = 1
      Client_No = Pick.extractcur(in_value, uprop, 0, 0) + 1
      in_value = Pick.replace(in_value, uprop, 0, 0, CStr(Client_No))
      wterr = d3.d3_writestr(database, "DICT CLIENT", "@NUMBER", in_value)
      sr_number = CStr(Client_No)
      
End Function


Public Function SR3D_WRITE(logentry As String, Client_No As String, Client_Rec As String, prop As Integer, SPaC As Integer, EPC As Integer, td_rec As String, adding As Integer, old_rec As String, DEBTOR As Integer) As String

Dim Test As String, I As Integer, Has_Pr_Owner As Integer, rderr As Integer
Dim in_value As String, database As String
Dim Own_Occ As Integer
Dim Alpha_Rec As String, wterr As String, Ans As String, temp As String, logamend As Integer, credlog As Integer

      database = Pick.extract(logentry, 2, 0, 0)
      If UBound(g_trans_info_array) = 0 Then
         g_trans_info_array(0) = "TRANS.INFO"
         rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
      End If
      If UBound(g_trans_info_array) < 104 Then ReDim Preserve g_trans_info_array(104)
      temp = Mid(g_trans_info_array(53), 11, 1)
      If IsNumeric(temp) Then logamend = CInt(temp) Else logamend = 0
      temp = Mid(g_trans_info_array(104), 11, 1)
      If IsNumeric(temp) Then credlog = CInt(temp) Else credlog = 0
      
      SR3D_WRITE = "0" ' means all okay
      
      Has_Pr_Owner = 1
      If d3.d3_openfile(database, "PR.OWNER", "", "O") = 1 Then Has_Pr_Owner = 0

      If adding = 0 Then GoTo 270

250   If d3.d3_readstr(database, Alpha_Rec, "CLIENT", Client_No) = 0 Then
         'Release CLIENT_DATA, CLIENT_NO
         SR3D_WRITE = Chr(8) & Client_No & " already used !. Try again."
         Exit Function
      End If

'$INSERT I.LOG.ADD '|CLIENT|':CLIENT.NO 250
' into here if updating after change
270   Test = Pick.extract(Client_Rec, 5, 1, 0)
      If Test = "" Then
        For I = 2 To 5
           Client_Rec = Pick.delet(Client_Rec, I, 1, 0)
        Next I
      End If
      Test = Pick.extract(Client_Rec, 5, 2, 0)
      If Test = "" Then
        For I = 2 To 5
           Client_Rec = Pick.replace(Client_Rec, I, 0, 0, Pick.extract(Client_Rec, I, 1, 0)) 'else have null 2nd values
        Next I
      End If
      wterr = d3.d3_writestr(database, "CLIENT", Client_No, Client_Rec)
'
' update ALPHA name index
'
320  Call SR_ALPHA(database, Client_No, old_rec, Client_Rec, SPaC, EPC, DEBTOR)
     If adding = 0 Then GoTo 620
'
' ==== update debtor record ====
'
500   If prop = 2 Then GoTo 620
      If prop = 5 Then GoTo 620  ' library borrower
      If d3.d3_readstr(database, Ans, "TDEBTOR", Client_No) = 0 Then
         SR3D_WRITE = Chr(8) & "Debtor " & Client_No & " already exists ???"
         Exit Function
      End If
'$INSERT I.LOG.ADD '|TDEBTOR|':CLIENT.NO 500
      wterr = d3.d3_writestr(database, "TDEBTOR", Client_No, td_rec)
'
620  If d3.d3_openfile(database, "CLIENT.CHANGES", "", "O") = 0 Then 'sr7000 only if client_changes file exists
        Call SR7000(logentry, old_rec, Client_Rec, Client_No)
     End If
     If adding Then GoTo 630

     Own_Occ = 0
     If Pick.extractint(Client_Rec, 10, 0, 0) = 1 Or (Pick.extractint(Client_Rec, 10, 0, 0) = 2 And (Pick.extract(Client_Rec, 35, 0, 0) <> "" Or Pick.extract(Client_Rec, 36, 0, 0) <> "" Or Pick.extract(Client_Rec, 37, 0, 0) <> "" Or Pick.extract(Client_Rec, 29, 0, 0) <> "")) Then Own_Occ = 1
'
     If logamend Then
        If Own_Occ Then
           Call SR1608(logentry, "C", Client_No, old_rec, Client_Rec, "")
        End If
     End If
'
'     If CREDLOG And Pick.extract(CLIENT_REC, 10, 0, 0) = "" Then
'       Call SR101(RR_LOG_DICT, B4_LOG_DICT, TNO, Prog, LOG_ENTRY, account, operator, LOGS_DICT, LOGS_DATA, CLIENT_NO, OLD_REC, CLIENT_REC, "CLIENT") '*DONOTALTER**
'     End If
'**
630:
'630  If Has_Pr_Owner Then
'        Call SR_ROOT("PR_OWNER", A_CODE, FILE_ROOT, ENDIFING_OUT)
'        If ENDIFING_OUT Then Stop
'        Direction = "N": The_Key = CLIENT_NO
'640     KEY(DIRECTION,FILE_ROOT,THE_KEY,TRID) ELSE GOTO 645
'        If d3.d3_readstr(TR_REC, "PR.OWNER", TRID) <> 0 Then GoTo 640
'        If Pick.extract(TR_REC, 2, 0, 0) <> CLIENT_NO Then GoTo 645
'        If Pick.extract(Trans_Info, 133, 0, 0) + 0 Then Owner = 37 Else Owner = 35
'        Pclrec = "": Pclrec = Pick.replace(Pclrec, Owner, 0, 0, CLIENT_NO)
'        Call SR16_PR_OWNER(CLIENT_DATA, PR_OWNER_DATA, Pick.extract(TR_REC, 1, 0, 0), Pclrec, "", Owner)
'     End If
'645  NULL
'$INSERT I.QU

End Function
Public Function SR_INV_BATCH(database As String, INVNO As String, ICODE As String, NO_BATCH As String, IREC As String) As Integer

Dim Batches_Rec As String, bpos As Integer
'
' Update @BATCHES item in DICT INV.BATCH
'
220  If d3.d3_readstr(database, Batches_Rec, "INV.BATCH", INVNO) = 0 Then
        SR_INV_BATCH = 1
        Exit Function
     End If
     SR_INV_BATCH = 0
'$INSERT I.LOG.ADD '|INV.BATCH|':INVNO 220
'
     If d3.d3_readstr(database, Batches_Rec, "DICT INV.BATCH", "@BATCHES") <> 0 Then Batches_Rec = "X"
'$INSERT I.LOG.UPDATE 'DICT|INV.BATCH|':'@BATCHES' 6100 BATCHES.REC
     If Pick.locate(NO_BATCH, Batches_Rec, 2, 1, 0, bpos, "") = 0 Then
        Batches_Rec = Pick.insert(Batches_Rec, 2, bpos, 0, NO_BATCH)
        Batches_Rec = Pick.insert(Batches_Rec, 3, bpos, 0, 0)
        Batches_Rec = Pick.insert(Batches_Rec, 4, bpos, 0, 0)
        Batches_Rec = Pick.insert(Batches_Rec, 5, bpos, 0, 0)
        Batches_Rec = Pick.insert(Batches_Rec, 6, bpos, 0, Pick.extract(IREC, 21, 0, 0))
        Batches_Rec = Pick.insert(Batches_Rec, 7, bpos, 0, 0)
     End If
     Batches_Rec = Pick.replace(Batches_Rec, 4, bpos, 0, CStr(Pick.extractcur(Batches_Rec, 4, bpos, 0) + Pick.extractcur(IREC, 8, 0, 0)))
     Batches_Rec = Pick.replace(Batches_Rec, 7, bpos, 0, CStr(Pick.extractcur(Batches_Rec, 7, bpos, 0) + 1))
     bpos = d3.d3_writestr(database, "DICT INV.BATCH", "@BATCHES", Batches_Rec)

End Function

Public Function SR_ALPHA(database As String, Client_No As String, Client_Rec As String, NEWREC As String, HFROM As Integer, HTO As Integer, DEBTOR As Integer) As String

Dim Flags As String, Old_Nameinit As String, New_Nameinit As String, Old_Post As String
Dim Old_Addr As String, New_Post As String, New_Addr As String, Old_St_Name As String, New_St_Name As String, Sort_Addr As String
Dim Street_Num As String, Flat_Num As String, Aaa As Integer, Old_Addr_Id As String, New_Addr_Id As String
Dim Index_Id As String, Alpha_Rec As String, Inz As Integer, Alpha_Client As String, Id As String, Xaddr As String, Xaddr_Init As String
Dim writeerror As Boolean, wterr As String, K_CL As String, max_inz As Integer
'
' Update alpha index
' DEBTOR=1 if debtor, 0 if creditor
'
'     No_Addr = Pick.extract(Trans_Info, 67, 0, 0)
'     No_Addr = Mid$(No_Addr, 2, 1) + 0
'
     SR_ALPHA = ""
     
     If DEBTOR Then
        Flags = 2: Flags = Pick.replace(Flags, 1, 3, 0, 1): Flags = Pick.replace(Flags, 1, 4, 0, 2): Flags = Pick.replace(Flags, 1, 5, 0, 4): Flags = Pick.replace(Flags, 1, 6, 0, 0)
        Old_Nameinit = Pick.extract(Client_Rec, 1, 1, 0) & Chr(253) & Pick.extract(Client_Rec, 6, 1, 0)
        New_Nameinit = Pick.extract(NEWREC, 1, 1, 0) & Chr(253) & Pick.extract(NEWREC, 6, 1, 0)
        Call SR500(database, New_Nameinit, "DRINDEX", Client_No, Old_Nameinit, Flags)
     Else
        Flags = 2: Flags = Pick.replace(Flags, 1, 3, 0, 1): Flags = Pick.replace(Flags, 1, 4, 0, 1)
        Call SR500(database, Pick.extract(NEWREC, 1, 0, 0), "CRINDEX", Client_No, Pick.extract(Client_Rec, 1, 0, 0), Flags)
        Return
     End If
'
' for debtors, check if address is still the same
'
'      If No_Addr Then GoTo 600
'
      If Pick.extract(Client_Rec, 5, 2, 0) = "" Then
         If Pick.extract(Client_Rec, 5, 1, 0) <> "" Then Old_Post = Pick.extract(Client_Rec, 5, 1, 0) Else Old_Post = ""
         Old_Addr = Pick.extract(Client_Rec, 2, 1, 0)
      Else
         Old_Post = Pick.extract(Client_Rec, 5, 2, 0)
         Old_Addr = Pick.extract(Client_Rec, 2, 2, 0)
      End If
      If Pick.extract(NEWREC, 5, 2, 0) = "" Then
         If Pick.extract(NEWREC, 5, 1, 0) <> "" Then New_Post = Pick.extract(NEWREC, 5, 1, 0) Else New_Post = ""
         New_Addr = Pick.extract(NEWREC, 2, 1, 0)
      Else
         New_Post = Pick.extract(NEWREC, 5, 2, 0)
         New_Addr = Pick.extract(NEWREC, 2, 2, 0)
      End If
      If Old_Addr = New_Addr And Old_Post = New_Post Then GoTo 600
      Old_St_Name = Pick.trimm(Old_Addr)
      If IsNumeric(Mid$(Old_St_Name, 1, 1)) Then Old_St_Name = Mid$(Old_St_Name, InStr(Old_St_Name, " ") + 1, 99)
      If Old_St_Name = "" Then Old_St_Name = Pick.trimm(Old_Addr)
      New_St_Name = Pick.trimm(Pick.extract(NEWREC, 2, 0, 0))
      Sort_Addr = New_St_Name
      If IsNumeric(Mid$(New_St_Name, 1, 1)) Then
         Street_Num = Pick.field(New_St_Name, " ", 1)
         New_St_Name = Mid$(New_St_Name, InStr(New_St_Name, " ") + 1, 99)
         Flat_Num = Pick.field(Street_Num, "/", 1)
         If Flat_Num = Street_Num Then Flat_Num = "" Else Street_Num = Pick.field(Street_Num, "/", 2)
         If Pick.match(Street_Num, "1N0N") = 0 Then
            For Aaa = 2 To 99
               If Pick.match(Mid$(Street_Num, Aaa, 1), "1N") = 0 Then
                  Street_Num = Mid$(Street_Num, 1, Aaa - 1)
                  GoTo 535
               End If
            Next Aaa
         End If
535      Sort_Addr = New_St_Name & Right(Space(8) & ("00000000" & Street_Num), 8) & Right(Space(8) & ("00000000" & Flat_Num), 8)
      End If
      If New_St_Name = "" Then New_St_Name = Pick.trimm(New_Addr): Sort_Addr = New_St_Name
      Old_Addr_Id = Mid$(Old_Post, HFROM, HTO) & Left(Old_St_Name & Space(30), 4)
      New_Addr_Id = Mid$(New_Post, HFROM, HTO) & Left(New_St_Name & Space(30), 4)
'
' delete old entry in address index
'
      If Pick.trimm(Old_Addr_Id) = "" Then Inz = 1: GoTo 545
540   If d3.d3_readstr(database, Alpha_Rec, "DICT ALPHA", Old_Addr_Id) <> 0 Then Index_Id = Old_Addr_Id: GoTo 1020
'$INSERT I.LOG.UPDATE 'DICT|ALPHA|':OLD.ADDR.ID 540 ALPHA.REC
      If Pick.locate(Client_No, Alpha_Rec, 1, 1, 0, Inz, "") = 0 Then GoTo 542
      Alpha_Rec = Pick.delet(Alpha_Rec, 1, Inz, 0)
'
' add new entry into address index
'
542   Inz = 1
      If Old_Addr_Id <> New_Addr_Id Then
         If Alpha_Rec = "" Then
            writeerror = d3.d3_delete(database, "DICT ALPHA", Old_Addr_Id)
         Else
            wterr = d3.d3_writestr(database, "DICT ALPHA", Old_Addr_Id, Alpha_Rec)
         End If
545      Alpha_Rec = ""
         If Pick.trimm(New_Addr_Id) = "" Then GoTo 600
550      If d3.d3_readstr(database, Alpha_Rec, "DICT ALPHA", New_Addr_Id) <> 0 Then
'$INSERT I.LOG.ADD 'DICT|ALPHA|':NEW.ADDR.ID 550
            GoTo 565
         End If
'$INSERT I.LOG.UPDATE 'DICT|ALPHA|':NEW.ADDR.ID 550 ALPHA.REC
      End If
      max_inz = Pick.dcount(Pick.extract(Alpha_Rec, 1, 0, 0), Chr(253))
      For Inz = 11 To max_inz Step 10
         If Pick.extract(Alpha_Rec, 1, Inz, 0) = "" Then GoTo 555
         GoSub 1200
         If Sort_Addr <= Xaddr_Init Then
555         Inz = Inz - 10
            GoTo 560
         End If
      Next Inz
      Inz = 1
'
560   If Pick.extract(Alpha_Rec, 1, Inz, 0) = "" Then GoTo 565
      GoSub 1200
      If Xaddr_Init <= Sort_Addr Then Inz = Inz + 1: GoTo 560
565   Alpha_Rec = Pick.insert(Alpha_Rec, 1, Inz, 0, Client_No)
      wterr = d3.d3_writestr(database, "DICT ALPHA", New_Addr_Id, Alpha_Rec)
600   Exit Function ' to calling program
'
' s/r 1200: routine to read CLIENT record from index file and format etc
'           address
1200  Alpha_Client = Pick.extract(Alpha_Rec, 1, Inz, 0)
      If d3.d3_readstr(database, K_CL, "CLIENT", Alpha_Client) <> 0 Then
        Index_Id = New_Addr_Id
1020    SR_ALPHA = Chr(8) & "ALPHA index file corrupted at id = " & Index_Id
        Exit Function
      End If
      If Pick.extract(K_CL, 5, 2, 0) = "" Then
         Xaddr = Pick.extract(K_CL, 2, 1, 0)
      Else
         Xaddr = Pick.extract(K_CL, 2, 2, 0)
      End If
      Xaddr = Pick.trimm(Xaddr)
      If IsNumeric(Mid$(Xaddr, 1, 1)) Then
         Xaddr_Init = Mid$(Xaddr, InStr(Xaddr, " ") + 1, 99)
         Street_Num = Pick.field(Xaddr, " ", 1)
         Flat_Num = Pick.field(Street_Num, "/", 1)
         If Flat_Num = Street_Num Then Flat_Num = "" Else Street_Num = Pick.field(Street_Num, "/", 2)
         If Pick.match(Street_Num, "1N0N") = 0 Then
            For Aaa = 2 To 99
               If Pick.match(Mid$(Street_Num, Aaa, 1), "1N") = 0 Then
                  Street_Num = Mid$(Street_Num, 1, Aaa - 1)
                  GoTo 1220
               End If
            Next Aaa
         End If
1220     Xaddr_Init = Xaddr_Init & Right(Space(8) & ("00000000" & Street_Num), 8) & Right(Space(8) & ("00000000" & Flat_Num), 8)
      Else
         Xaddr_Init = Xaddr
      End If
      If Mid$(Xaddr, InStr(Xaddr, " ") + 1, 99) = "" Then Xaddr_Init = Xaddr
      Return

End Function

Public Function SR500(database As String, NEW_NAME As String, fname As String, Id As String, USE_NAME As String, Flags As String)

Dim KEYLEN As Integer, Rec As String, wterr As String, writeerror As Boolean
Dim What As Integer, Nodots As Integer, Namesort As Integer, Nosymbol, Asis As Integer
Dim Name As String, Inits As String, Symbols As String, I As Integer, kk As Integer, Key As String, adding As Integer
Dim Ss As Integer, Acct As String, J As Integer, Shortkey As String, nn As Integer
'
' Maintain index by all words (separated by spaces) in 'name'
'
' FLAGS<1,1> = 0 for add new
'              1 for delete
'              2 for delete then add NEW.NAME
' FLAGS<1,2> = if contains bar symbol twice then means is LOGID
'              being passed. MUST BE setup in calling program as
'              bar FILENAME bar and TARRLOG will convert in calling
'              program to bar FILENUMBER bar using RR.LOG 'F'
'              ELSE if bar symbol not there twice will mean no
'              restart logging required
'              Quiesce must be done in calling program
' FLAGS<1,3> = 1 means ids are not g/l or job/l and hence do not need to
'              sort on group.class.sub.class in a special way
' FLAGS<1,4> = N means item ids kept in order by 'name' passed
'                and stored as m/v in attr 1 with names as m/v in
'                attr 2
'                Normally items ids only stored as attributes
'              The N is mostly 1 but maybe 2 or more to indicate that
'              is sorted to greater depths ans uses attrs 3 onwards
'              eg DRINDEX for name (attr2) and initials (attr3) will pass
'              N=2 to indicate 2 levels of sort (by name by initials)
'              In this case, NAME must NOT be m/valued as the
'              second m.value will be the datum for the second level sort
'              i.e. the initials (this applies to USE.NAME & NEW.NAME)
' FLAGS<1,7> - if 1 means use name as is and do not do any shorter keys
'
     What = Pick.extractint(Flags, 1, 1, 0)
     'Logid = Pick.extract(FLAGS, 1, 2, 0)
     Nodots = Pick.extractint(Flags, 1, 3, 0)
     Namesort = Pick.extractint(Flags, 1, 4, 0)
     KEYLEN = Pick.extractint(Flags, 1, 5, 0)
     Nosymbol = Pick.extract(Flags, 1, 6, 0)
     Asis = Pick.extractint(Flags, 1, 7, 0)
     If KEYLEN = 0 Then KEYLEN = 3
     Name = USE_NAME
'
80   If Namesort >= 2 Then
        Inits = Pick.extract(Name, 1, 2, 0): Name = Pick.extract(Name, 1, 1, 0)
     Else
        If Asis = 0 Then Call Pick.sr_change(Name, Chr(253), " ")
     End If
     If Nosymbol = 0 Then
        Symbols = "/-()&""'.,"
        For I = 1 To Len(Symbols)
           Name = replace(Name, Mid$(Symbols, I, 1), " ")
        Next I
     End If
     Name = UCase(Pick.trimm(Name))
'
     If What <> 0 Then GoTo 200
'
' ADD TO INDEX
'
     For kk = 1 To 9999
        Key = Pick.field(Name, " ", kk)
        If Key = "" Then Exit Function '*TO CALLING PROGRAM**
        If Asis = 0 Then Key = Left(Key & Space(KEYLEN), KEYLEN)
        adding = 0
110     If d3.d3_readstr(database, Rec, fname, Key) <> 0 Then GoTo 115
'        IF WANT.RR THEN
'$INSERT I.LOG.UPDATE LOGID:KEY 110 REC
'        END
        GoTo 120
115     Rec = "": adding = 1
'        IF WANT.RR THEN
'$INSERT I.LOG.ADD LOGID:KEY 110
'        END
'
120     If Nodots Then
           Select Case Namesort
              Case 1
                 If Pick.locate(Id, Rec, 1, 1, 0, I, "") = 0 Then
                    If Pick.locate(Name, Rec, 2, 1, 0, I, "AL") = 0 Then
                    End If
                    Rec = Pick.insert(Rec, 1, I, 0, Id): Rec = Pick.insert(Rec, 2, I, 0, Name)
                    GoTo 160
                 End If
              Case 2
                 If Pick.locate(Id, Rec, 1, 1, 0, I, "") = 0 Then
                    If Pick.locate(Name, Rec, 2, 1, 0, I, "AL") = 0 Then
125                    Rec = Pick.insert(Rec, 1, I, 0, Id): Rec = Pick.insert(Rec, 2, I, 0, Name): Rec = Pick.insert(Rec, 3, I, 0, Inits)
                       GoTo 160
                    End If
                    If Inits <= Pick.extract(Rec, 3, I, 0) Then GoTo 125
                    For Ss = I + 1 To Pick.dcount(Pick.extract(Rec, 3, 0, 0), Chr(253)) + 1
                       If Pick.extract(Rec, 1, Ss, 0) = "" Then I = Ss: GoTo 125
                       If Name <> Pick.extract(Rec, 2, Ss, 0) Then I = Ss: GoTo 125
                       If Inits <= Pick.extract(Rec, 3, Ss, 0) Then I = Ss: GoTo 125
                    Next Ss
                    GoTo 160
                 End If
              Case Else
                 If Pick.locate(Id, Rec, 1, 0, 0, I, "AL") = 0 Then
                    Rec = Pick.insert(Rec, I, 0, 0, Id)
                    GoTo 160
                 End If
           End Select
128        'Release GLINDEX_DATA, Key
           GoTo 190
        End If
'
        For I = 1 To 9999
           Acct = Pick.extract(Rec, I, 0, 0)
           If Acct = "" Then GoTo 150
           If Pick.field(Id, ".", 1) < Pick.field(Acct, ".", 1) Then GoTo 150
           If Pick.field(Id, ".", 1) > Pick.field(Acct, ".", 1) Then GoTo 140
           If Pick.field(Id, ".", 2) < Pick.field(Acct, ".", 2) Then GoTo 150
           If Pick.field(Id, ".", 2) > Pick.field(Acct, ".", 2) Then GoTo 140
           If Pick.field(Id, ".", 3) < Pick.field(Acct, ".", 3) Then GoTo 150
           If Pick.field(Id, ".", 3) > Pick.field(Acct, ".", 3) Then GoTo 140
           GoTo 128 ' Same account again
140     Next I
150     Rec = Pick.insert(Rec, I, 0, 0, Id)
160     wterr = d3.d3_writestr(database, fname, Key, Rec)
        If adding And Asis = 0 Then
           For J = KEYLEN - 1 To 1 Step -1
              Shortkey = Mid$(Key, 1, J)
170           If d3.d3_readstr(database, Rec, fname, Shortkey) <> 0 Then Rec = ""
'              IF WANT.RR THEN
'$INSERT I.LOG.UPDATE LOGID:SHORTKEY 170 REC
'              END
              If Pick.locate(Key, Rec, 1, 0, 0, I, "AL") = 0 Then
                 Rec = Pick.insert(Rec, I, 0, 0, Key)
                 wterr = d3.d3_writestr(database, fname, Shortkey, Rec)
                 GoTo 185
              End If
              'Release GLINDEX_DATA, Shortkey
185        Next J
           If d3.d3_readstr(database, Rec, fname, "FIRSTLETTERS") <> 0 Then Rec = ""
'           IF WANT.RR THEN
'$INSERT I.LOG.UPDATE LOGID:'FIRSTLETTERS' 170 REC
'           END
           Shortkey = Mid$(Key, 1, 1)
           If Pick.locate(Shortkey, Rec, 1, 0, 0, I, "AL") = 0 Then
              Rec = Pick.insert(Rec, I, 0, 0, Shortkey)
              wterr = d3.d3_writestr(database, fname, "FIRSTLETTERS", Rec)
              GoTo 190
           End If
           'Release GLINDEX_DATA, "FIRSTLETTERS"
        End If
190  Next kk
'
' DELETE FROM INDEX
'
200  For kk = 1 To 9999
        Key = Pick.field(Name, " ", kk)
        If Key = "" Then GoTo 300
        If Asis = 0 Then Key = Left(Key & Space(KEYLEN), KEYLEN)
210     If d3.d3_readstr(database, Rec, fname, Key) <> 0 Then Rec = ""
'        IF WANT.RR THEN
'$INSERT I.LOG.DELETE LOGID:KEY 210 REC
'        END
        If Namesort Then
           If Pick.locate(Id, Rec, 1, 1, 0, I, "") = 0 Then GoTo 290
           For nn = 1 To Namesort + 1
              Rec = Pick.delet(Rec, nn, I, 0)
           Next nn
        Else
           If Pick.locate(Id, Rec, 1, 0, 0, I, "") = 0 Then GoTo 290
           Rec = Pick.delet(Rec, I, 0, 0)
        End If
290     If Rec = "" Then
           writeerror = d3.d3_delete(database, fname, Key)
        Else
           wterr = d3.d3_writestr(database, fname, Key, Rec)
        End If
     Next kk
300  If What = 2 Then What = 0: Name = NEW_NAME: GoTo 80

End Function

Private Sub Class_Initialize()

ReDim g_trans_info_array(0)
Dim temp As String, myfile As String


g_drive = "c:" 'mco 16sep00 till next one - trying to find which drive to use
temp = Left(g_template_file, Len(g_template_file) - 1) ' remove last /
try_again:
    myfile = Dir(g_drive & temp, vbDirectory)
    If myfile <> "template" Then
       Select Case g_drive
         Case "c:": g_drive = "e:": GoTo try_again
         Case "e:": g_drive = "f:": GoTo try_again
         Case Else: g_drive = "c:"
     End Select
    End If 'mco 16sep00
    
End Sub



Public Sub SR1608(logentry As String, File As String, Ident As String, Rec As String, Nrec As String, Narr As String)

Dim No_Batches As String, No_Logging As String, Comment As Integer, Nomayvote As Integer, Max As Integer, temp As String
Dim Ans As String, Bar As String, Cc As String, Rate_Tag As Integer, Val_Done As Integer, Changed As Integer, Done_Elect As Integer, Attr As Integer
Dim I As Integer, Usei As Integer, J As Integer, Id As String, Ct As Integer, Brec As String
Dim tno As String, Prog As String, OPERATOR As String, kk As Integer, MAXKK As Integer, wterr As String
Dim database As String
'
' RECORD IN CHANGES FILE ANY UPDATES MADE TO DATA
'
     database = Pick.extract(logentry, 2, 0, 0)
     temp = d3.execute_tcl(logentry, "WHO", "")
     tno = Pick.field(temp, " ", 1)
     
     No_Batches = Pick.extract(Ident, 1, 3, 0)
     No_Logging = Pick.extract(Ident, 1, 4, 0)
     Comment = Pick.extractint(Ident, 1, 2, 0)
     If Nrec = Rec And Comment = 0 Then Exit Sub
'
     Ident = Pick.extract(Ident, 1, 1, 0)
     temp = Mid$(Pick.extract(g_trans_info_array(53), 1, 0, 0), 1, 1)
     If IsNumeric(temp) Then Nomayvote = CInt(temp) Else Nomayvote = 0
' CHAR 11 1=LOGAMEND 2=LOGAMEND WITH NO BATCHES
     If No_Batches = "" Then No_Batches = Mid$(Pick.extract(g_trans_info_array(53), 1, 0, 0), 11, 1)
     Max = Pick.dcount(Rec, Chr(254))
     Bar = "|"
     If Max < Pick.dcount(Nrec, Chr(254)) Then Max = Pick.dcount(Nrec, Chr(254))
     Cc = Pick.ICONV(Format$(Now, "DD MMM YY"), "D2")
     Cc = Pick.replace(Cc, 2, 0, 0, Pick.field(Timer(), ".", 1))
     Cc = Pick.replace(Cc, 3, 0, 0, tno)
     Cc = Pick.replace(Cc, 4, 0, 0, Pick.extract(logentry, 3, 0, 0)) 'username
     Cc = Pick.replace(Cc, 5, 0, 0, "PROSPECT") 'was PROG
     Cc = Pick.replace(Cc, 6, 0, 0, Narr)
     Cc = Pick.replace(Cc, 7, 0, 0, "")
     Rate_Tag = 0
     Val_Done = 0
     Changed = 0: Done_Elect = 0
     Attr = 6
     For I = 1 To Max
        If (Pick.extract(Rec, I, 0, 0) <> Pick.extract(Nrec, I, 0, 0)) Or (File = "P" And I = 29 And Rate_Tag) Then
           If File = "P" Then
' DGM CHANGED FOR INTERIM              IF I=16 OR I=17 THEN GOTO 10
              If I = 16 Then GoTo 10
              If I = 15 Then Val_Done = 1
              If I = 19 Then
                 If Val_Done = 0 Then Usei = 15: GoSub 20: Val_Done = 1
                 If Pick.extract(Rec, 29, 0, 0) <> "" Or Pick.extract(Nrec, 29, 0, 0) <> "" Then
                    Rate_Tag = 1: GoTo 10
                 End If
              End If
              If I = 29 And Rate_Tag = 0 Then
                 If Val_Done = 0 Then Usei = 15: GoSub 20: Val_Done = 1
                 Rate_Tag = 1
              End If
           End If
           Changed = 1
           If File = "C" Then
              If I = 32 Or I = 33 Or I = 34 Or I = 36 Or I = 38 Then
                 If Done_Elect Then GoTo 10
                 Usei = 36: GoSub 20
                 Usei = 38: GoSub 20
                 Usei = 34: GoSub 20
                 Usei = 32: GoSub 20
                 If Nomayvote = 0 Then Usei = 33: GoSub 20
                 Done_Elect = 1
                 GoTo 10
              End If
           End If
           Usei = I
           GoSub 20
        End If
10   Next I
     GoTo 30
'
20   Cc = Pick.insert(Cc, 7, -1, 0, CStr(Usei))
     Attr = Attr + 2
     Cc = Pick.replace(Cc, Attr, 0, 0, Usei & Chr(253) & Pick.extract(Rec, Usei, 0, 0))
     If Rate_Tag And Usei = 29 Then
        MAXKK = Pick.dcount(Pick.extract(Rec, 19, 0, 0), Chr(253))
        For kk = 2 To MAXKK
           Cc = Pick.replace(Cc, Attr, kk, 2, Pick.extract(Rec, 19, kk - 1, 0))
        Next kk
     End If
     Cc = Pick.replace(Cc, Attr + 1, 0, 0, Usei & Chr(253) & Pick.extract(Nrec, Usei, 0, 0))
     If Rate_Tag And Usei = 29 Then
        MAXKK = Pick.dcount(Pick.extract(Nrec, 19, 0, 0), Chr(253))
        For kk = 2 To MAXKK
           Cc = Pick.replace(Cc, Attr + 1, kk, 2, Pick.extract(Nrec, 19, kk - 1, 0))
        Next kk
     End If
     Return
'
30   If Changed = 0 And Not (Comment) Then Return
'
40   Id = File & Bar & Ident
50   If d3.d3_readstr(database, Ans, "CHANGES", Id) <> 0 Then Ans = ""
     If No_Logging = "0" Then
'$INSERT I.LOG.UPDATE '|CHANGES|':ID 50 ANS
     End If
     Ct = Pick.extractint(Ans, 2, 0, 0)
     Ct = Ct + 1
     Ans = Pick.replace(Ans, 2, 0, 0, CStr(Ct))
     Ans = Pick.replace(Ans, 1, 0, 0, "9999")
     wterr = d3.d3_writestr(database, "CHANGES", Id, Ans)
'
8    Id = File & Bar & Ident & Bar & Ct
100  If d3.d3_readstr(database, Ans, "CHANGES", Id) <> 0 Then GoTo 105
     'Release CHANGES_DATA, Id
     GoTo 40
105
     If No_Logging = "0" Then
'$INSERT I.LOG.ADD '|CHANGES|':ID 100
     End If
     wterr = d3.d3_writestr(database, "CHANGES", Id, Cc)
'
     If No_Batches = "2" Then Exit Sub ' TA1681
     If d3.d3_readstr(database, Brec, "CH.BATCH", Pick.extract(OPERATOR, 1, 0, 0)) <> 0 Then Brec = 0
     Brec = Pick.insert(Brec, -1, 0, 0, Id)
     Brec = Pick.replace(Brec, 1, 0, 0, 0)
     wterr = d3.d3_writestr(database, "CH.BATCH", Pick.extract(OPERATOR, 1, 0, 0), Brec)

End Sub

Public Function ta696(logentry As String, sentence As String, parms As String) As String
' TA696 - Print Debtor Statements
Dim Svm As String, Vm As String, Am As String, temp As String, fname As String
Dim Eom As String, Drxref As Integer, No_Eom_Date As Integer, No_Zero As Integer
Dim Curr_Amt As Currency, Current As Currency, Words As String
Dim Std_Msg As String, Ans As String
Dim Mth_End As Integer, loan_no As String
Dim Dte As String, Refs As String, Narr As String
Dim Dr_Amt As String, Cr_Amt As String, Tbal As String, Line_Bal As Currency, Client_No As String, Client_Rec As String
Dim Full_Name As String, Adr1 As String, Adr2 As String, Postcode As String, Adr3 As String, Email As String, Tr_Next_Ovf As Integer
Dim Tr_Next_Pos As Integer, Eom0_Val As Currency, Odue_Bal As Currency
Dim Last_St_Date As Integer, reprint As Integer, Ovf_No As Integer, Save_reprint As Integer
Dim Upd_reprint As Integer, Days0 As Currency, Days30 As Currency, Days60 As Currency
Dim Days90 As Currency, Odue_Msg_Flag As Integer, Dr_Tot  As Currency, Cr_Tot As Currency, Tr_Date As String, tr_date_int As Integer, Fut_Bal As Currency
Dim Balfwd, First_Balfwd As Integer, Tr_Ref As String, Tr_Desc As String, Tr_Narr As String, Next_Ovfno As Integer, Tr_Stdate As String
Dim Tr_Xref, Tr_Xdate As String, Xtop As Integer, Trxd As Integer, Cr_Stdate As String, Cra As Currency
Dim Dra As Currency, Oamt As Currency
Dim Cr_Rec As String, Jj As Integer, Ovf_Key As String, Cr_No_Trans As Integer
Dim Cr_Tdate As String, Cr_Type As String, Cr_Tref As String, Cr_Tamt As String, Cr_Xref As String, Cr_Xamt As String, Cr_Ldate As String
Dim Cr_Xdate As String, Cr_Bcdate As String, Cr_Tpaid As String, Cr_Narr As String, Cr_Cust_Ref As String, Tran As String
Dim Cr_Ovfno As Integer, Cr_Cur_Bal As Currency, Cr_Unalloc As Currency
Dim Oflow As String
Dim mth As Integer, Odue_Date As Integer, Pr_Today As Integer
Dim database As String, rderr, mylist() As String, pick_cnt As Long, total_items As Long, kk As Long
Dim Ii As Integer, fnum As Integer, tr_amt As Currency
Dim tr_type As Integer, tr_bal As Currency, tr_xamt As String
Dim loans_rec As String, loans As Byte, F1 As Integer, loan_full As Currency, loan_balance As Currency, loan_credits As String, loan_credits_dates As String

    Mth_End = Pick.extractint(parms, 2, 0, 0)
    Pr_Today = Pick.extractint(parms, 3, 0, 0)
    sentence = replace(sentence, Chr(254), """", , , vbBinaryCompare)
    loans = 0
    If LCase(Pick.field(sentence, " ", 2)) = "loans" Then loans = 1
    
    database = Pick.extract(logentry, 2, 0, 0)
    
    If UBound(g_trans_info_array) = 0 Then
       g_trans_info_array(0) = "TRANS.INFO"
       rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
    End If
    If UBound(g_trans_info_array) < 125 Then ReDim Preserve g_trans_info_array(125) '
    Svm = Chr(252): Vm = Chr(253): Am = Chr(254)
    Eom = g_trans_info_array(9) & Vm & g_trans_info_array(8) & Vm & g_trans_info_array(7) & Vm & g_trans_info_array(33)
    temp = Mid$(g_trans_info_array(62), 1, 1)
    If IsNumeric(temp) Then Drxref = CInt(temp) Else Drxref = 0
    No_Eom_Date = Pick.extractint(g_trans_info_array(64), 1, 2, 0)
    No_Zero = Pick.extractint(g_trans_info_array(64), 1, 3, 0)
    Curr_Amt = 0: Current = 0
    If d3.d3_readstr(database, Std_Msg, "DICT TRANS.J", "@STM_MSG") <> 0 Then Std_Msg = ""
    If No_Eom_Date Or loans Then
        mth = 0
        Odue_Date = Mth_End
    Else
        If Pick.locate(CStr(Mth_End), Eom, 1, 1, 0, mth, "AR") = 0 Then
            ta696 = Chr(8) & "Invalid End of Month Date"
            Exit Function
        End If
        Odue_Date = Pick.extractint(Eom, 1, mth - 1, 0)
    End If
    If Drxref <> 1 Then
        Pr_Today = 99999
    End If
    
    fnum = FreeFile
    If loans Then
      fname = g_drive & "\prospect_site\mergefiles\ta696loans.txt"
    Else
      fname = g_drive & "\prospect_site\mergefiles\ta696.txt"
    End If
    Open fname For Output Access Write As #fnum
    Write #fnum, "mth.end", "client.no", "full.name", "adr1", "adr2", "adr3", "t_action.dates", "t_action.refs", "t_action.type", "dr.amt", "cr.amt", "line.bal", "tot.bal", "dr.tot", "cr.tot", "odue.bal", "odue.date", "balfwd", "days30", "days60", "days90", "current", "std.msg", "loan_full", "loan_credits", "loan_credits_dates", "loan_balance", "loan_number", "email"
    
    Dte = "": Refs = "": Narr = "": Dr_Amt = "": Cr_Amt = ""
    Tbal = "": Line_Bal = 0: Narr = "": Current = 0: Curr_Amt = 0
    total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0)
    For kk = 0 To total_items - 1
        Client_No = mylist(kk)
        If loans Then
            loan_no = Client_No
            If d3.d3_readstr(database, loans_rec, "LOANS", loan_no) <> 0 Then GoTo 214
            If Pick.extract(loans_rec, 4, 0, 0) <> "" Then
               If Pick.extractint(loans_rec, 4, 0, 0) <= Pick.extractint(loans_rec, 17, 0, 0) Then GoTo 214
            End If
            loan_full = 0
            For F1 = 1 To Pick.dcount(Pick.extract(loans_rec, 15, 0, 0), Chr(253))
                loan_full = loan_full + Pick.extractcur(loans_rec, 15, F1, 0)
            Next F1
            loan_balance = loan_full
            Client_No = Pick.extract(loans_rec, 1, 0, 0)
        End If
        If d3.d3_readstr(database, Client_Rec, "CLIENT", Client_No) <> 0 Then Client_Rec = ""
        Full_Name = Pick.trimm(Pick.extract(Client_Rec, 8, 0, 0) & " " & Pick.extract(Client_Rec, 6, 0, 0) & " " & Pick.extract(Client_Rec, 1, 1, 0))
        Adr1 = Pick.extract(Client_Rec, 2, 1, 0)
        Adr2 = Pick.extract(Client_Rec, 3, 1, 0)
        Postcode = Pick.extract(Client_Rec, 5, 1, 0)
        If Postcode = "0" Or Postcode = "9999" Then Postcode = ""
        Adr3 = Pick.trimm(Pick.extract(Client_Rec, 4, 1, 0) & " " & Postcode)
        Email = Pick.extract(Client_Rec, 9, 4, 0)
        If d3.d3_readstr(database, Cr_Rec, "TDEBTOR", Client_No) <> 0 Then
            ta696 = Chr(8) & "Debtor " & Client_No & " details do not exist"
            GoTo 214
        End If
        If Pick.extract(Cr_Rec, 84, 0, 0) = "Y" Then GoTo 214
        Cr_Ovfno = Pick.extractint(Cr_Rec, 27, 0, 0)
        Cr_Cur_Bal = Pick.extractcur(Cr_Rec, 3, 0, 0)
        Cr_Unalloc = Pick.extractcur(Cr_Rec, 22, 0, 0)
        If Cr_Ovfno Then
            Ovf_No = 1
            GoSub 6777
        End If
        Tr_Next_Ovf = Ovf_No
        Tr_Next_Pos = 0
        Eom0_Val = 0
        Odue_Bal = 0
        Last_St_Date = Pick.extractint(Cr_Rec, 5, 1, 0)
        If Last_St_Date = Mth_End Then
            reprint = 1
        Else
            reprint = 0
        End If
        Save_reprint = reprint
        Upd_reprint = 0
        Odue_Msg_Flag = 0
        Dr_Tot = 0: Cr_Tot = 0
        Dte = "": Refs = "": Narr = "": Dr_Amt = "": Cr_Amt = "": Tbal = "": Line_Bal = 0:
204     Tr_Date = Pick.extract(Cr_Rec, 40, 1, 0)
        Fut_Bal = 0
        If Tr_Date <> "" Then
           Balfwd = 1
           If Tr_Date = "0" Then First_Balfwd = 1 Else First_Balfwd = 0
        Else
           Balfwd = 0: First_Balfwd = 0
        End If
        If reprint And Balfwd Then
           Tr_Date = Pick.extract(Cr_Rec, 40, 2, 0)
           If Tr_Date = "0" Then First_Balfwd = 1
        End If
        If Balfwd And First_Balfwd = 0 And Tr_Date <> "0" Then
           Tr_Ref = "BAL/FWD"
           Tr_Desc = "": Tr_Narr = ""
           If reprint Then tr_amt = Pick.extract(Cr_Rec, 39, 2, 0) Else tr_amt = Pick.extract(Cr_Rec, 39, 1, 0)
           If tr_amt < 0 Then tr_type = 25 Else tr_type = 50
           tr_bal = tr_amt
           Refs = Tr_Ref
           Tbal = Format(tr_bal / 100, "currency")
           Line_Bal = tr_bal
           Curr_Amt = tr_bal
           tr_xamt = ""
           If reprint = 0 Then Tr_Stdate = "" Else Tr_Stdate = Mth_End
        End If
210     If Tr_Next_Ovf <> Ovf_No Then
           Next_Ovfno = Tr_Next_Ovf
           GoSub 6666
        End If
        For Tr_Next_Pos = Tr_Next_Pos + 1 To Cr_No_Trans
           tr_type = Pick.extractint(Cr_Type, 1, Tr_Next_Pos, 0)
           tr_amt = Pick.extractcur(Cr_Tamt, 1, Tr_Next_Pos, 0)
           Tr_Date = Pick.extract(Cr_Tdate, 1, Tr_Next_Pos, 0)
           tr_date_int = Pick.extractint(Cr_Tdate, 1, Tr_Next_Pos, 0)
           If loans Then
               If tr_type < 50 Then
                   loan_credits = loan_credits & vbLf & Format(tr_amt / -100, "Currency")
                   loan_credits_dates = loan_credits_dates & vbLf & Pick.oconv(Tr_Date, "D2")
                   loan_balance = loan_balance + tr_amt
               End If
               GoTo 220
           End If
           Tr_Desc = Pick.extract(g_trans_info_array(3), 1, tr_type, 0)
           If Tr_Desc = "" Then Tr_Desc = tr_type
           Tr_Ref = Pick.extract(Cr_Tref, 1, Tr_Next_Pos, 0)
           'tr_cust_ref = Pick.extract(Cr_Cust_Ref, 1, Tr_Next_Pos, 0)
           tr_bal = tr_amt - Pick.extractcur(Cr_Tpaid, 1, Tr_Next_Pos, 0)
           Tr_Narr = Pick.extract(Cr_Narr, 1, Tr_Next_Pos, 0)
           Tr_Stdate = Pick.extract(Cr_Stdate, 1, Tr_Next_Pos, 1)
           Tr_Xref = Pick.extract(Cr_Xref, 1, Tr_Next_Pos, 0)
           tr_xamt = Pick.extract(Cr_Xamt, 1, Tr_Next_Pos, 0)
           Tr_Xdate = Pick.extract(Cr_Xdate, 1, Tr_Next_Pos, 0)
           If Drxref And Tr_Xdate <> "" And tr_type >= 50 Then
              Xtop = Pick.dcount(Tr_Xdate, Svm)
              For Ii = 1 To Xtop
                 Trxd = Pick.field(Pick.extract(Tr_Xdate, 1, 1, Ii), "/", 1)
                 If Trxd > Pr_Today Then
                    tr_bal = tr_bal + Pick.extractcur(tr_xamt, 1, 1, Ii)
                 End If
              Next Ii
           End If
           If Tr_Stdate = "" Or (reprint And Tr_Stdate = CStr(Mth_End)) Then
              If tr_date_int <= Odue_Date Then
                 Odue_Msg_Flag = 1
              End If
           End If
           If tr_date_int > Mth_End Then Fut_Bal = Fut_Bal + tr_amt: GoTo 219
           If tr_type < 50 And tr_date_int > Pr_Today Then
                Fut_Bal = Fut_Bal + tr_amt
                GoTo 219
           End If
           If reprint Then
              If Tr_Stdate = CStr(Mth_End) Then GoTo 213
              If Tr_Stdate = "" Then reprint = 0  ' print new trans on reprint
           End If
           If Tr_Stdate <> "" Then
              If First_Balfwd = 0 Then
                 If Balfwd Then GoTo 219
                 If Mid$(Tr_Stdate, 1, 1) <> "0" Then
                    If tr_bal = 0 Then GoTo 219
                 End If
              End If
           End If
           If tr_bal <> 0 Then Ans = "0" & Mth_End & Svm & tr_bal Else Ans = Mth_End
           If Balfwd Then Ans = Mth_End
           Cr_Stdate = Pick.replace(Cr_Stdate, 1, Tr_Next_Pos, 0, Ans)
213        If No_Zero And tr_bal = 0 Then GoTo 219
           GoSub 215
219        reprint = Save_reprint  ' restore reprint indicator (in case altered)
220     Next Tr_Next_Pos
        If Ovf_No Then           ' access next overflow/master, as reqd
           Next_Ovfno = Ovf_No + 1
           GoSub 6666
           Tr_Next_Pos = 0
           Tr_Next_Ovf = Ovf_No
           GoTo 210
        End If
        If Upd_reprint Then reprint = 0  ' force update, even if statement started as reprint
        Next_Ovfno = 0
        GoSub 6666
        If loans Then
            loans_rec = Pick.replace(loans_rec, 17, 0, 0, CStr(Mth_End))
            rderr = d3.d3_writestr(database, "LOANS", loan_no, loans_rec)
            GoTo 221
        End If
        If reprint = 0 Then
            If Balfwd Then
                If Upd_reprint Then  ' over-ride last statement balance only
                    Cr_Rec = Pick.replace(Cr_Rec, 39, 1, 0, Cr_Cur_Bal - Fut_Bal)
                    Cr_Rec = Pick.replace(Cr_Rec, 40, 1, 0, CStr(Mth_End))
                Else         ' standard statement print
                    Cr_Rec = Pick.insert(Cr_Rec, 39, 1, 0, Cr_Cur_Bal - Fut_Bal)
                    Cr_Rec = Pick.delet(Cr_Rec, 39, 3, 0)
                    Cr_Rec = Pick.insert(Cr_Rec, 40, 1, 0, CStr(Mth_End))
                    Cr_Rec = Pick.delet(Cr_Rec, 40, 3, 0)
                End If
            End If
            Cr_Rec = Pick.replace(Cr_Rec, 4, 0, 0, Cr_Cur_Bal & Vm & Pick.extract(Cr_Rec, 4, 1, 0))
            Cr_Rec = Pick.replace(Cr_Rec, 5, 0, 0, Mth_End & Vm & Pick.extract(Cr_Rec, 5, 1, 0))
        End If
        If reprint = 0 Then
           rderr = d3.d3_writestr(database, "TDEBTOR_DATA", Client_No, Cr_Rec)
        End If
        If Balfwd Then
           Odue_Bal = Odue_Bal - Eom0_Val
        End If
        Ans = ""
        Days0 = Pick.extractcur(Cr_Rec, 6, 0, 0)
        Days30 = Pick.extractcur(Cr_Rec, 7, 0, 0)
        Days60 = Pick.extractcur(Cr_Rec, 8, 0, 0)
        Days90 = Pick.extractcur(Cr_Rec, 9, 0, 0) + Pick.extractcur(Cr_Rec, 10, 0, 0)

221     Write #fnum, Pick.oconv(CStr(Mth_End), "D2"), Client_No, Full_Name, Adr1, Adr2, Adr3, Dte, Refs, Narr, Dr_Amt, Cr_Amt, Tbal, Curr_Amt, Format(Dr_Tot / 100, "currency"), Format(Cr_Tot / 100, "currency"), Format(Odue_Bal / 100, "currency"), Pick.oconv(CStr(Odue_Date), "D2"), Format(Days0 / 100, "currency"), Format(Days30 / 100, "currency"), Format(Days60 / 100, "currency"), Format(Days90 / 100, "currency"), Format(Current / 100, "currency"), Std_Msg, Format(loan_full / 100, "Currency"), loan_credits, loan_credits_dates, Format(loan_balance / 100, "Currency"), loan_no, 'always end with a comma
        If kk = total_items - 1 Then
           Print #fnum, """" & Email & """", ' this is to stop a null record being at end of file
        Else
           Write #fnum, Email
        End If
214 Next kk
    Close #fnum
    ta696 = total_items & " statements written to " & fname & ". (" & sentence & ")"
    Exit Function

215 If reprint = 0 And Save_reprint Then Upd_reprint = 1
    Ans = ""
    If tr_type < 50 Then
       Cra = tr_bal
       Current = Current + tr_bal
       Dra = 0
       Cr_Tot = Cr_Tot + tr_bal
    Else
       Dra = tr_bal
       Current = Current + tr_bal
       Cra = 0
       Dr_Tot = Dr_Tot + tr_bal
    End If
    Curr_Amt = Curr_Amt + tr_bal
    Line_Bal = Line_Bal + tr_bal
    If Refs = "" Then
       Refs = Tr_Ref
       Narr = Tr_Desc
       Dte = Pick.oconv(Tr_Date, "D2")
       Dr_Amt = Format(Dra / 100, "currency")
       Cr_Amt = Format(Cra / 100, "currency")
       Tbal = Format(Line_Bal / 100, "currency")
    Else
       Narr = Narr & vbLf & Tr_Desc
       Dte = Dte & vbLf & Pick.oconv(Tr_Date, "D2")
       Refs = Refs & vbLf & Tr_Ref
       Dr_Amt = Dr_Amt & vbLf & Format(Dra / 100, "currency")
       Cr_Amt = Cr_Amt & vbLf & Format(Cra / 100, "currency")
       Tbal = Tbal & vbLf & Format(Line_Bal / 100, "currency")
    End If
217 If Balfwd Then
       If First_Balfwd Then Oamt = tr_bal Else Oamt = tr_amt
       Odue_Bal = Odue_Bal + Oamt
       If tr_date_int > Odue_Date Then Eom0_Val = Eom0_Val + tr_bal
    Else
       If tr_date_int <= Odue_Date Then Odue_Bal = Odue_Bal + tr_bal Else Eom0_Val = Eom0_Val + tr_bal
    End If
    Return

6666 If Not loans Then
         Tran = Pick.replace(Tran, 1, 0, 0, CStr(Cr_No_Trans)) ' file overflow that has been update
         Tran = Pick.replace(Tran, 5, 0, 0, CStr(Cr_Tdate))
         Tran = Pick.replace(Tran, 2, 0, 0, CStr(Cr_Type))
         Tran = Pick.replace(Tran, 3, 0, 0, CStr(Cr_Tref))
         Tran = Pick.replace(Tran, 4, 0, 0, CStr(Cr_Tamt))
         Tran = Pick.replace(Tran, 9, 0, 0, CStr(Cr_Xref))
         Tran = Pick.replace(Tran, 10, 0, 0, CStr(Cr_Xamt))
         Tran = Pick.replace(Tran, 11, 0, 0, CStr(Cr_Ldate))
         Tran = Pick.replace(Tran, 12, 0, 0, CStr(Cr_Xdate))
         Tran = Pick.replace(Tran, 13, 0, 0, CStr(Cr_Stdate))
         Tran = Pick.replace(Tran, 14, 0, 0, CStr(Cr_Bcdate))
         Tran = Pick.replace(Tran, 6, 0, 0, CStr(Cr_Tpaid))
         Tran = Pick.replace(Tran, 7, 0, 0, CStr(Cr_Narr))
         Tran = Pick.replace(Tran, 8, 0, 0, CStr(Cr_Cust_Ref))
         If (reprint And Upd_reprint = 0) Then
            'Release TD_OFLOW_DATA, Ovf_Key
         Else
            rderr = d3.d3_writestr(database, "TD_OFLOW", Ovf_Key, Tran)
         End If
     End If
     Ovf_No = Next_Ovfno
     If Next_Ovfno > Cr_Ovfno Then Ovf_No = 0
     If Ovf_No <> 0 Then GoSub 6777
     Return

6777 Ovf_Key = Ovf_No & "*" & Client_No
     If d3.d3_readstr(database, Tran, "TD.OFLOW", Ovf_Key) <> 0 Then Tran = ""
     Cr_No_Trans = Pick.extractint(Tran, 1, 0, 0)
     Cr_Tdate = Pick.extract(Tran, 5, 0, 0)
     Cr_Type = Pick.extract(Tran, 2, 0, 0)
     Cr_Tref = Pick.extract(Tran, 3, 0, 0)
     Cr_Tamt = Pick.extract(Tran, 4, 0, 0)
     Cr_Xref = Pick.extract(Tran, 9, 0, 0)
     Cr_Xamt = Pick.extract(Tran, 10, 0, 0)
     Cr_Ldate = Pick.extract(Tran, 11, 0, 0)
     Cr_Xdate = Pick.extract(Tran, 12, 0, 0)
     Cr_Stdate = Pick.extract(Tran, 13, 0, 0)
     Cr_Bcdate = Pick.extract(Tran, 14, 0, 0)
     Cr_Tpaid = Pick.extract(Tran, 6, 0, 0)
     Cr_Narr = Pick.extract(Tran, 7, 0, 0)
     Cr_Cust_Ref = Pick.extract(Tran, 8, 0, 0)
     Return
     
End Function
Public Sub SR7000(logentry As String, OLDCL As String, Client_Rec As String, Client_No As String)

Dim Use_Borr As Integer, Name As String, Prop_Nos As String, Num_Props_Owned As Integer, F1 As Integer, Tref As String
Dim Num_Props_Occed As Integer, Dog_Nos As String, Oldname As String, Newaddr1 As String, Pos As Integer, Newaddr2 As String
Dim Oldaddr1 As String, Oldaddr2 As String, Oldphone As String, Newphone As String, Borr_No As String, Debt As String, Cred As String
Dim Rec As String, Changeid As String, wterr As String, database As String, dummy As String

     database = Pick.extract(logentry, 2, 0, 0)

     Use_Borr = 0
     'OPEN "","LB_BORROWER" TO LB_BORR_DATA ELSE USE_BORR = 0
     Name = Pick.extract(Client_Rec, 1, 0, 0) & ", " & Pick.extract(Client_Rec, 8, 0, 0) & " " & Pick.extract(Client_Rec, 7, 0, 0)
     Prop_Nos = ""
     If Pick.extractint(Client_Rec, 28, 0, 0) = 1 Then ' PROPERTY CLIENT
        GoTo 999
     Else
        Num_Props_Owned = Pick.dcount(Pick.extract(Client_Rec, 29, 0, 0), Chr(253))
        For F1 = 1 To Num_Props_Owned
           Tref = Pick.extract(Client_Rec, 29, F1, 0)
           If Pick.locate(Tref, Prop_Nos, 1, 1, 0, Pos, "") = 0 Then
              Prop_Nos = Pick.insert(Prop_Nos, 1, Pos, 0, Tref)
           End If
        Next F1
        Num_Props_Occed = Pick.dcount(Pick.extract(Client_Rec, 31, 0, 0), Chr(253))
        For F1 = 1 To Num_Props_Occed
           Tref = Pick.extract(Client_Rec, 31, F1, 0)
           If Pick.locate(Tref, Prop_Nos, 1, 1, 0, Pos, "") = 0 Then
              Prop_Nos = Pick.insert(Prop_Nos, 1, Pos, 0, Tref)
           End If
        Next F1
        Dog_Nos = Pick.extract(Client_Rec, 45, 0, 0)
        Oldname = Pick.extract(OLDCL, 1, 0, 0) & ", " & Pick.extract(OLDCL, 8, 0, 0) & " " & Pick.extract(OLDCL, 7, 0, 0)
     End If 'WCC
     Newaddr1 = Pick.trimm(Pick.extract(Client_Rec, 2, 1, 0)) & ", " & Pick.trimm(Pick.extract(Client_Rec, 3, 1, 0)) & ", " & Pick.trimm(Pick.extract(Client_Rec, 4, 1, 0)) & ", " & Pick.trimm(Pick.extract(Client_Rec, 5, 1, 0))
     If Newaddr1 = ", , , " Then Newaddr1 = ""
     Pos = InStr(Newaddr1, ", , "): If Pos Then Newaddr1 = Mid$(Newaddr1, 1, Pos + 1) & Mid$(Newaddr1, Pos + 4, 999)
     Pos = InStr(Newaddr1, ", , "): If Pos Then Newaddr1 = Mid$(Newaddr1, 1, Pos + 1) & Mid$(Newaddr1, Pos + 4, 999)
     If Mid$(Newaddr1, 1, 2) = ", " Then Newaddr1 = Mid$(Newaddr1, 3, 999)
'
     Newaddr2 = Pick.trimm(Pick.extract(Client_Rec, 2, 2, 0)) & ", " & Pick.trimm(Pick.extract(Client_Rec, 3, 2, 0)) & ", " & Pick.trimm(Pick.extract(Client_Rec, 4, 2, 0)) & ", " & Pick.trimm(Pick.extract(Client_Rec, 5, 2, 0))
     If Newaddr2 = ", , , " Then Newaddr2 = ""
     Pos = InStr(Newaddr2, ", , "): If Pos Then Newaddr2 = Mid$(Newaddr2, 1, Pos + 1) & Mid$(Newaddr2, Pos + 4, 999)
     Pos = InStr(Newaddr2, ", , "): If Pos Then Newaddr2 = Mid$(Newaddr2, 1, Pos + 1) & Mid$(Newaddr2, Pos + 4, 999)
     If Mid$(Newaddr2, 1, 2) = ", " Then Newaddr2 = Mid$(Newaddr2, 3, 999)
'
     Oldaddr1 = Pick.trimm(Pick.extract(OLDCL, 2, 1, 0)) & ", " & Pick.trimm(Pick.extract(OLDCL, 3, 1, 0)) & ", " & Pick.trimm(Pick.extract(OLDCL, 4, 1, 0)) & ", " & Pick.trimm(Pick.extract(OLDCL, 5, 1, 0))
     If Oldaddr1 = ", , , " Then Oldaddr1 = ""
     Pos = InStr(Oldaddr1, ", , "): If Pos Then Oldaddr1 = Mid$(Oldaddr1, 1, Pos + 1) & Mid$(Oldaddr1, Pos + 4, 999)
     Pos = InStr(Oldaddr1, ", , "): If Pos Then Oldaddr1 = Mid$(Oldaddr1, 1, Pos + 1) & Mid$(Oldaddr1, Pos + 4, 999)
     If Mid$(Oldaddr1, 1, 2) = ", " Then Oldaddr1 = Mid$(Oldaddr1, 3, 999)
'
     Oldaddr2 = Pick.trimm(Pick.extract(OLDCL, 2, 2, 0)) & ", " & Pick.trimm(Pick.extract(OLDCL, 3, 2, 0)) & ", " & Pick.trimm(Pick.extract(OLDCL, 4, 2, 0)) & ", " & Pick.trimm(Pick.extract(OLDCL, 5, 2, 0))
     If Oldaddr2 = ", , , " Then Oldaddr2 = ""
     Pos = InStr(Oldaddr2, ", , "): If Pos Then Oldaddr2 = Mid$(Oldaddr2, 1, Pos + 1) & Mid$(Oldaddr2, Pos + 4, 999)
     Pos = InStr(Oldaddr2, ", , "): If Pos Then Oldaddr2 = Mid$(Oldaddr2, 1, Pos + 1) & Mid$(Oldaddr2, Pos + 4, 999)
     If Mid$(Oldaddr2, 1, 2) = ", " Then Oldaddr2 = Mid$(Oldaddr2, 3, 999)
'
     If Oldaddr2 = "" Then Oldaddr2 = Oldaddr1: Oldaddr1 = ""
     If Newaddr2 = "" Then Newaddr2 = Newaddr1: Newaddr1 = ""
'
     Oldphone = "": Newphone = ""
     If Pick.extract(OLDCL, 9, 1, 0) <> "" Then Oldphone = "Work - " & Pick.extract(OLDCL, 9, 1, 0)
     If Pick.extract(OLDCL, 9, 2, 0) <> "" Then
        If Oldphone = "" Then
           Oldphone = "Home - " & Pick.extract(OLDCL, 9, 2, 0)
        Else
           Oldphone = Oldphone & ", Home - " & Pick.extract(OLDCL, 9, 2, 0)
        End If
     End If
     If Pick.extract(Client_Rec, 9, 1, 0) <> "" Then Newphone = "Work - " & Pick.extract(Client_Rec, 9, 1, 0)
     If Pick.extract(Client_Rec, 9, 2, 0) <> "" Then
        If Newphone = "" Then
           Newphone = "Home - " & Pick.extract(Client_Rec, 9, 2, 0)
        Else
           Newphone = Newphone & ", Home - " & Pick.extract(Client_Rec, 9, 2, 0)
        End If
     End If
     If Oldphone <> "" Then Oldphone = "Phone(s)  &  " & Oldphone
     If Newphone <> "" Then Newphone = "Phone(s)  &  " & Newphone
'
     Borr_No = ""
     If Use_Borr Then
        'READV BORR_NO FROM LB_BORR_DATA,CLIENT_NO,13 ELSE BORR_NO = ""
     End If
     Debt = "1"
     Cred = "1"
     If d3.d3_readstr(database, dummy, "TDEBTOR", Client_No, 1) <> 0 Then Debt = ""
     If d3.d3_readstr(database, dummy, "CREDITOR", Client_No, 1) <> 0 Then Cred = ""
     Rec = Pick.extract(logentry, 3, 0, 0) & Chr(254) & Client_No & Chr(254) & Oldname & Chr(253) & Oldaddr2
     If Oldaddr1 <> "" Then Rec = Rec & Chr(253) & "(M) " & Oldaddr1
     If Oldphone <> "" Then Rec = Rec & Chr(253) & Oldphone
     Rec = Rec & Chr(254) & Name & Chr(253) & Newaddr2
     If Newaddr1 <> "" Then Rec = Rec & Chr(253) & "(M) " & Newaddr1
     If Newphone <> "" Then Rec = Rec & Chr(253) & Newphone
     Rec = Rec & Chr(254) & Dog_Nos & Chr(254) & Borr_No & Chr(254) & Prop_Nos & Chr(254) & "PROSPECT"
'
     Changeid = ""
'
' ANIMALS
'
     If Dog_Nos <> "" And (Pick.extract(Newaddr2, 1, 1, 0) <> Pick.extract(Oldaddr2, 1, 1, 0)) Then
        Changeid = Pick.ICONV(Format$(Now, "DD MMM YY"), "D2") & "*" & Pick.field(Timer(), ".", 1) & "*" & database & "*ANIMALS"
        wterr = d3.d3_writestr(database, "CLIENT.CHANGES", Changeid, Rec)
     End If
'
' RATES
'
     If Pick.extract(Client_Rec, 29, 0, 0) <> "" Or Pick.extract(Client_Rec, 31, 0, 0) <> "" Then
        Changeid = Pick.ICONV(Format$(Now, "DD MMM YY"), "D2") & "*" & Pick.field(Timer(), ".", 1) & "*" & database & "*RATES"
        wterr = d3.d3_writestr(database, "CLIENT.CHANGES", Changeid, Rec)
     End If
'
' DEBTORS
'
     If Pick.extract(Client_Rec, 10, 0, 0) + 0 > 0 Then
        If Borr_No <> "" Then 'LIBRARY DEBTOR
           Changeid = Pick.ICONV(Format$(Now, "DD MMM YY"), "D2") & "*" & Pick.field(Timer(), ".", 1) & "*" & database & "*LIBRARY"
           wterr = d3.d3_writestr(database, "CLIENT.CHANGES", Changeid, Rec)
        End If
        If Debt <> "" Then ' DEBTOR
           Changeid = Pick.ICONV(Format$(Now, "DD MMM YY"), "D2") & "*" & Pick.field(Timer(), ".", 1) & "*" & database & "*DEBTOR"
           wterr = d3.d3_writestr(database, "CLIENT.CHANGES", Changeid, Rec)
        End If
        If Changeid = "" Then
           Changeid = Pick.ICONV(Format$(Now, "DD MMM YY"), "D2") & "*" & Pick.field(Timer(), ".", 1) & "*" & database & "*UNATTACHED"
           wterr = d3.d3_writestr(database, "CLIENT.CHANGES", Changeid, Rec)
        End If
     Else
        If Cred <> "" Then
           Changeid = Pick.ICONV(Format$(Now, "DD MMM YY"), "D2") & "*" & Pick.field(Timer(), ".", 1) & "*" & database & "*CRED"
           wterr = d3.d3_writestr(database, "CLIENT.CHANGES", Changeid, Rec)
        End If
     End If
999  Exit Sub

End Sub




Public Function print_invoices(logentry As String, docname As String, max_lines As Integer)
' TA2492 - Invoices to go to DOS for Mail Merge
Dim Apbar_Ctl As String, INV_NO  As String, aa As Integer, Bar_Code, Key_Line, Words As String
Dim Max, Tot_Net_Amt, Tot_Gross_Amt
Dim Tot_Gst, Invoice_Total, Mlev, Bon_Row, Mlev_Which, Sel, Ct
Dim Line_Cnt, St_Words As String, Tot_Tx, Cori As String, Inv_Rec As String, Client_No As String
Dim Use_Client_No As String, Crn As String, Client_Rec As String, Name As String, Addr1 As String, Addr2 As String, Addr3 As String
Dim Inv_Dte As String, Date_Due, Amount As String, Pr_Amt As String, Inv, Dte, Cust_Order, Mulnarr
Dim Tgst, Tqty, Tnet_Price, Tgross_Price, Tprod, Tnet_Ln_Amt As String, Tgross_Ln_Amt As String
Dim St_Tot_Gst As String, St_Tot_Net_Amt As String, St_Tot_Gross_Amt As String, Nolines, J As Integer, Narr As String
Dim Prod As String, Qty As String, Net_Price As String, Gross_Price As String, Net_Ln_Amt As String, Gross_Ln_Amt As String
Dim Gst As String, Maxln As Integer, kk As Integer, Ii As Integer, Inv_Amt, Maxpages, Jj As Integer
Dim Page, Bar_Tab As String, Apx

Dim total_items As Long, sentence As String, mylist() As String, pick_cnt As Long
Dim database As String, nn As Integer
Dim xx As Integer

xx = 13 'CR

database = Pick.extract(logentry, 2, 0, 0)
'
     If d3.d3_readstr(database, Apbar_Ctl, "DICT TRANS.J", "@APBAR_CTL") <> 0 Then Apbar_Ctl = ""
     Bar_Code = "": Key_Line = ""
     'WORDS=""name","client_no","addr1","addr2","addr3","cust_order","inv_date","inv_no","inv_amt","details","product","qty","net_unit_price","gross_unit_price","net_amt","gross_amt","gst","total_net_amt","total_gross_amt","total_gst","invoice_total","date_due","crn","barcode","keyline","page""
'
'13   Cl$ = Cl: Msg$ = "How many lines of description per page ? "
     Tot_Net_Amt = "": Tot_Gross_Amt = "": Tot_Gst = "": Invoice_Total = ""
'
'
     Ct = 0
     Line_Cnt = 0
     St_Words = ""

   sentence = "SSELECT PR_INV BY @TYPE BY @INVNO"
   total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0) - 1
   
   For kk = 0 To total_items
     INV_NO = mylist(kk)
315  Ct = Ct + 1
     Tot_Tx = 0: Invoice_Total = 0
     If d3.d3_readstr(database, Cori, "PR.INV", INV_NO, 2) <> 0 Then Cori = ""
     If Cori = "C" Then
        If d3.d3_readstr(database, Inv_Rec, "CREDIT", INV_NO) <> 0 Then Inv_Rec = "": GoTo 780
      Else
        If d3.d3_readstr(database, Inv_Rec, "INVOICE", INV_NO) <> 0 Then
           If d3.d3_readstr(database, Inv_Rec, "INV.BATCH", INV_NO) <> 0 Then Inv_Rec = "": GoTo 780
        End If
     End If
     Bar_Code = "": Key_Line = ""
     Client_No = Pick.extract(Inv_Rec, 3, 0, 0)
     Use_Client_No = Client_No
     Call SR1685_CHK(0, Use_Client_No)
     Crn = Mid$(Pick.extract(Use_Client_No, 2, 0, 0), 2, 7)
     If d3.d3_readstr(database, Client_Rec, "CLIENT", Client_No) <> 0 Then Client_Rec = ""
     Name = Pick.extract(Client_Rec, 8, 0, 0) & " " & Pick.extract(Client_Rec, 6, 0, 0) & " " & Pick.extract(Client_Rec, 1, 0, 0)
     Name = Pick.trimm(Name)
     Addr1 = Pick.extract(Client_Rec, 2, 1, 0)
     Addr2 = Pick.extract(Client_Rec, 3, 1, 0)
     Addr3 = Pick.extract(Client_Rec, 4, 1, 0) & " " & Pick.extract(Client_Rec, 5, 1, 0)
     Addr3 = Pick.trimm(Addr3)
     Inv_Dte = Pick.extract(Inv_Rec, 20, 0, 0)
     Date_Due = Pick.oconv(Pick.extract(Inv_Rec, 36, 0, 0), "D2")
     Inv_Dte = Pick.oconv(Inv_Dte, "D2")
'    INV.DTE = INV.DTE[1,2]:INV.DTE[4,3]:INV.DTE[8,2]
     Amount = Pick.extract(Inv_Rec, 8, 0, 0)
     Pr_Amt = Pick.oconv(Amount, "MD2")
     Inv = INV_NO
     Dte = Inv_Dte
     If Pick.extract(Inv_Rec, 12, 0, 0) = "" Then aa = 26 Else aa = 12
     Cust_Order = Pick.extract(Inv_Rec, 4, 0, 0)
     Mulnarr = "": Tgst = "": Tqty = "": Tnet_Price = "": Tgross_Price = "": Tprod = ""
     Tnet_Ln_Amt = "": Tgross_Ln_Amt = ""
     St_Tot_Gst = "": St_Tot_Net_Amt = "": St_Tot_Gross_Amt = ""
'
     Nolines = Pick.extract(Inv_Rec, 9, 0, 0)
     For J = 1 To Nolines
        Narr = Pick.extract(Inv_Rec, aa, J, 0)
        Prod = Pick.extract(Inv_Rec, 10, J, 0)
        Qty = Pick.extract(Inv_Rec, 13, J, 0)
        Net_Price = Pick.extract(Inv_Rec, 15, J, 0)
        Gross_Price = Pick.extract(Inv_Rec, 65, J, 0)
        Net_Ln_Amt = Qty * Net_Price
        Gross_Ln_Amt = Net_Ln_Amt + Pick.extractcur(Inv_Rec, 17, J, 0)
        Gst = Pick.extract(Inv_Rec, 17, J, 0)
'
        St_Tot_Net_Amt = St_Tot_Net_Amt + Net_Ln_Amt
        St_Tot_Gross_Amt = St_Tot_Gross_Amt + Gross_Ln_Amt
        St_Tot_Gst = St_Tot_Gst + Gst
'
        Net_Ln_Amt = Right(Space(10) & Pick.oconv(Net_Ln_Amt, "MD2"), 10)
        Gross_Ln_Amt = Right(Space(10) & Pick.oconv(Gross_Ln_Amt, "MD2"), 10)
        Net_Price = Right(Space(10) & Pick.oconv(Net_Price, "MD2"), 10)
        Gross_Price = Right(Space(10) & Gross_Price, 10)
        Gst = Right(Space(10) & Pick.oconv(Gst, "MD2"), 10)
'
        Maxln = Pick.dcount(Narr, Chr(252))
        For nn = Maxln To 1 Step -1
           If Pick.extract(Narr, 1, 1, nn) = "" Then Narr = Pick.delet(Narr, 1, 1, nn): Maxln = Maxln - 1
        Next nn
        If Maxln = 0 Then Maxln = 1
        For Ii = 1 To Maxln
105        If Mulnarr = "" And Tprod = "" Then
              Mulnarr = Pick.extract(Narr, 1, 1, Ii)
              Tprod = Prod
              Tnet_Price = Net_Price
              Tgross_Price = Gross_Price
              Tnet_Ln_Amt = Net_Ln_Amt
              Tgross_Ln_Amt = Gross_Ln_Amt
              Tgst = Gst
              Tqty = Qty
              Line_Cnt = Line_Cnt + 1
           Else
              If Maxln = max_lines = 0 Then
                 If Line_Cnt + Maxln - Ii = max_lines Then
                    Invoice_Total = "Continued"
                    GoSub 1000
                    Line_Cnt = 0: Mulnarr = "": Tqty = "": Tnet_Price = "": Tgst = "": Tprod = ""
                    Tgross_Price = "": Net_Ln_Amt = "": Tgross_Ln_Amt = ""
                    Gst = "": Inv_Amt = "": Invoice_Total = ""
                    GoTo 105
                 End If
              End If
              Mulnarr = Mulnarr & Chr(xx) & Pick.extract(Narr, 1, 1, Ii)
              If Ii = 1 Then
                 Tprod = Tprod & Chr(xx) & Prod
                 Tnet_Price = Tnet_Price & Chr(xx) & Net_Price
                 Tgross_Price = Tgross_Price & Chr(xx) & Gross_Price
                 Tnet_Ln_Amt = Tnet_Ln_Amt & Chr(xx) & Net_Ln_Amt
                 Tgross_Ln_Amt = Tgross_Ln_Amt & Chr(xx) & Gross_Ln_Amt
                 Tgst = Tgst & Chr(xx) & Gst
                 Tqty = Tqty & Chr(xx) & Qty
                 Line_Cnt = Line_Cnt + 1
              Else
                 Tprod = Tprod & Chr(xx)
                 Tnet_Price = Tnet_Price & Chr(xx)
                 Tgross_Price = Tgross_Price & Chr(xx)
                 Tnet_Ln_Amt = Tnet_Ln_Amt & Chr(xx)
                 Tgross_Ln_Amt = Tgross_Ln_Amt & Chr(xx)
                 Tgst = Tgst & Chr(xx)
                 Tqty = Tqty & Chr(xx)
                 Line_Cnt = Line_Cnt + 1
              End If
              GoSub 900
           End If
           GoSub 900
        Next Ii
        GoSub 900
150  Next J
'
780  '???Delete PR_INV_DATA, INV_NO
     If Inv_Rec = "" Then
        If Ct = 1 Then Ct = 0 Else Ct = Ct - 1
        GoTo 310
     End If
'
     Maxpages = Pick.dcount(St_Words, Chr(254))
     For Jj = 1 To Maxpages
        Page = Jj & " of " & Maxpages + 1
        Words = Pick.insert(Words, -1, 0, 0, Pick.extract(St_Words, Jj, 0, 0) & ","" & PAGE & """)
     Next Jj
     St_Words = ""
     Tot_Gst = Right(Space(10) & Pick.oconv(St_Tot_Gst, "MD2"), 10)
     Tot_Net_Amt = Right(Space(10) & Pick.oconv(St_Tot_Net_Amt, "MD2"), 10)
     Tot_Gross_Amt = Right(Space(10) & Pick.oconv(St_Tot_Gross_Amt, "MD2"), 10)
     Invoice_Total = Right(Space(10) & Pick.oconv(Pick.extract(Inv_Rec, 8, 0, 0), "MD2"), 10)
     Page = Maxpages + 1 & " of " & Maxpages + 1
     If Pick.extract(Apbar_Ctl, 3, 3, 0) <> "" Then GoSub 1200    ' Write barcode
     GoSub 1100
     Line_Cnt = 0: Mulnarr = "": Tqty = "": Tnet_Price = "": Tgst = "": Tprod = ""
     Tgross_Price = "": Net_Ln_Amt = "": Tgross_Ln_Amt = ""
310:
  Next kk

  If Ct Then
     print_invoices = Words
  Else
     print_invoices = "No invoices produced!"
  End If
  Exit Function

'**************************
' S/R 900 Check page length
'**************************
900  If Line_Cnt = max_lines Then
        Invoice_Total = "Continued"
        GoSub 1000
        Line_Cnt = 0: Mulnarr = "": Tqty = "": Tnet_Price = "": Tgst = "": Tprod = ""
        Tgross_Price = "": Net_Ln_Amt = "": Tgross_Ln_Amt = ""
        Gst = "": Inv_Amt = "": Invoice_Total = ""
     End If
     Return
'************************
' S/R 1000 - Write a page
'************************
1000    St_Words = Pick.insert(St_Words, -1, 0, 0, """ & NAME & "","" & CLIENT_NO & "","" & ADDR1 & "","" & ADDR2 & "","" & ADDR3 & "","" & CUST_ORDER & "","" & DTE & "","" & INV & "","" & PR_AMT & "","" & MULNARR & "","" & TPROD & "","" & TQTY & "","" & TNET_PRICE & "","" & TGROSS_PRICE & "","" & TNET_LN_AMT & "","" & TGROSS_LN_AMT & "","" & TGST & "","" & TOT_NET_AMT & "","" & TOT_GROSS_AMT & "","" & TOT_GST & "","" & INVOICE_TOTAL & "","" & DATE_DUE & "","" & CRN & "","" & BAR_CODE & "","" & KEY_LINE & """)
        Return
'***************************
' S/R 1100 - Write last page
'***************************
1100    Words = Pick.insert(Words, -1, 0, 0, """ & NAME & "","" & CLIENT_NO & "","" & ADDR1 & "","" & ADDR2 & "","" & ADDR3 & "","" & CUST_ORDER & "","" & DTE & "","" & INV & "","" & PR_AMT & "","" & MULNARR & "","" & TPROD & "","" & TQTY & "","" & TNET_PRICE & "","" & TGROSS_PRICE & "","" & TNET_LN_AMT & "","" & TGROSS_LN_AMT & "","" & TGST & "","" & TOT_NET_AMT & "","" & TOT_GROSS_AMT & "","" & TOT_GST & "","" & INVOICE_TOTAL & "","" & DATE_DUE & "","" & CRN & "","" & BAR_CODE & "","" & KEY_LINE & "","" & PAGE & """)
        Return
'*******************
' S/R 1200 - Barcode
'*******************
1200  Bar_Code = "": Key_Line = ""
      Bar_Tab = Client_No & Chr(253) & Amount
      Apx = 3
      '???Call SR_APBAR(Apbar_Ctl, Apx, Bar_Tab, Bar_Code, Key_Line)
      Return

End Function



Public Sub SR1685_CHK(CODE, Client_No)

Dim Mods10, Len_Cl, Numeric_Field, Total, Ii, Result, Remainder
Dim Chk_Digit
'
' Calculate check digit for usercode
'
     Mods10 = "12121212121212121212"
     Len_Cl = Len(Client_No)
     Numeric_Field = String$(6 - Len_Cl, "0") & Client_No
     Total = 0
     For Ii = 1 To Len(Numeric_Field)
       Result = Mid$(Numeric_Field, Ii, 1) * Mid$(Mods10, Ii, 1)
       If Result > 9 Then Result = Mid$(Result, 1, 1) + Mid$(Result, 2, 1)
       Total = Total + Result
     Next Ii
     Remainder = Total Mod 10 'REM(TOTAL,10)
     If Remainder <> 0 Then
        Chk_Digit = 10 - Remainder
     Else
        Chk_Digit = 0
     End If
     Client_No = Pick.replace(Client_No, 2, 0, 0, Numeric_Field & Chk_Digit)

End Sub
