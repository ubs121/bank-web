VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "invest"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
Option Compare Text

Private d3 As New d3
Private pick As New pick

Public Function borrower_update(logentry As String, tbl_name As String, Id As String, the_rec As String, old_rec As String, action As String) As String

Dim Class As String, pos As Integer, rec As String
Dim fname As String, database As String
Dim flds() As String

database = pick.extract(logentry, 2, 0, 0)

borrower_update = "0" 'this means all was okay

If action = "D" Then
   borrower_update = d3.d3_delete(database, tbl_name, Id)
   Exit Function
End If
'action = "W" - updating existing item
'action = "A" - adding new item

' want to check that the CLASS is valid
   
   flds = Split(the_rec, Chr(8))
   Class = flds(3) 'field 4 since starts at 0 pick.extract(the_rec, 4, 0, 0)
   pos = InStr(tbl_name, ".mdb\")
   fname = Left(tbl_name, pos + 4) & "class"
   If d3.d3_readstr("", rec, fname, Class) <> 0 Then
      borrower_update = Chr(8) & Class & " does not exist on file " & fname
      Exit Function
   End If
   
   borrower_update = d3.d3_writestr(database, tbl_name, Id, the_rec, Chr(8))


End Function
Public Function sr_number(database As String, prop As Integer) As String

Dim in_value As String, uprop As Integer, CLIENT_NO As Currency, wterr As String
'
' get and update @NUMBER in DICT CLIENT with next number
'
      If d3.d3_readstr(database, in_value, "DICT CLIENT", "@NUMBER") <> 0 Then in_value = "1"
'$INSERT I.LOG.UPDATE 'DICT|CLIENT|@NUMBER' 300 IN.VALUE
      uprop = prop + 1: If prop = 3 Then uprop = 1
      CLIENT_NO = pick.extractcur(in_value, uprop, 0, 0) + 1
      in_value = pick.Replace(in_value, uprop, 0, 0, CStr(CLIENT_NO))
      wterr = d3.d3_writestr(database, "DICT CLIENT", "@NUMBER", in_value)
      sr_number = CStr(CLIENT_NO)
      
End Function






