VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ckaiis"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
Option Compare Text

Private d3 As New d3
Private pick As New pick

Private g_trans_info_array() As String


Public Function Prosprt(logentry As String, sentence As String)

Dim logarray() As String, No_Lines As Long, i As Long, pline As String, HoldNo As String, Reply As String
Dim Io As String, Dio As String, PagStr As String, ParStr As String, hdr1 As String, hdr2 As String
Dim am As String, vm As String, PB As String, temp As String
Dim lines, textfile, fso

am = Chr$(254)
vm = Chr$(253)
PB = Chr(12)
PagStr = "\page "
ParStr = "\par "
Prosprt = d3.rtf_open(logentry, fso, textfile)

HoldNo = sentence
logarray = Split(logentry, am)

If d3.d3_readstr(logarray(1), Io, "PROSPOOL", HoldNo) <> 0 Then
   textfile.WriteLine ("PROSPOOL file is missing in account " & logarray(1) & " OR no report was generated")
   GoTo nofile_error
End If
temp = d3.d3_delete("Logis", "PROSPOOL", HoldNo)
lines = Split(Io, am, , vbBinaryCompare)
No_Lines = UBound(lines)

For i = 0 To No_Lines
    pline = lines(i)
    If Left(pline, 1) = PB Then pline = PagStr + Mid(pline, 2)
    pline = pline & ParStr
    textfile.WriteLine (pline)
Next i

nofile_error:
   textfile.WriteLine ("}")
   textfile.Close
   Set textfile = Nothing
   Set fso = Nothing
   
End Function


Public Function RSBuildSearch(logentry As String, sentence As String, xtra As String, PageSize As String, PhysicalPath As String, template_path As String, NewTemplates As String)
  
 Dim fso, file, database As String
 Dim AllLines As String, textline As String, the_drive As String
 Dim pos As Integer, temp As String, i As Integer
 Dim title As String, templatetouse As String, filetouse As String, hds As String, tds As String, dms As String
 Dim srchlist As String, tblName As String, srchcols() As String, name_wanted As String
 
   Set fso = New Scripting.FileSystemObject
   If fso.FileExists(PhysicalPath) Then
      Set file = fso.OpenTextFile(PhysicalPath)
      Do While Not file.AtEndOfStream
       textline = file.ReadLine
       pos = InStr(textline, "=")
       If pos <> 0 Then temp = Left(textline, pos - 1) Else temp = ""
       Select Case temp
          Case "templatetouse": templatetouse = Mid(textline, pos + 1)
          Case "filetouse": filetouse = Mid(textline, pos + 1)
          Case "title": title = Mid(textline, pos + 1)
          Case "hds": hds = Mid(textline, pos + 1)
          Case "tds": tds = Mid(textline, pos + 1)
          Case "dms": dms = Mid(textline, pos + 1)
          Case "srchlist": srchlist = Mid(textline, pos + 1)
       End Select
      Loop
      file.Close
   End If
  dms = Replace(dms, "@@PICKFILE@@", filetouse)
  the_drive = Left(PhysicalPath, InStr(PhysicalPath, "\prospect\") - 1)
  filetouse = Replace(filetouse, "@@PATH@@", the_drive) 'for .mdb access so is path independent
   
  'If Left(sentence, 1) = "?" Then
     temp = sentence 'Mid(sentence, 2)
     If temp = "" Then temp = " "
     'xtra = ""
     'pos = InStr(temp, "?")
     'If pos <> 0 Then
     '   xtra = Left(temp, pos - 1)
     '   temp = Mid(temp, pos + 1): If temp = "" Then temp = " "
     'End If
     Select Case templatetouse
      Case "client"
        name_wanted = " with @@drindex|client|name|4|0|0|1@@ = """ & temp
        If xtra <> "" Then
           If xtra = "loans" Then
              database = pick.extract(logentry, 2, 0, 0)
              If d3.d3_readstr(database, xtra, "DICT TRANS.J", "@LOANS", 6) <> 0 Then xtra = ""
           End If
           If xtra <> "" Then
              If xtra = "creditor" Then
                 xtra = " with no a10 and "
                 name_wanted = " with @@crindex|client|name|3|0|0|1@@ = """ & temp
              Else
                 xtra = " with relate = """ & xtra & """ and "
              End If
           End If
        End If
        sentence = "sselect client " & xtra & name_wanted & "]"" by name by given"
      Case "contract"                                                       'sv 21 jan 02
        tblName = templatetouse
        sentence = "sselect " & tblName & " with a0 = """ & temp & "]"" "     'sv 21 jan 02
      Case "SearchJAccount", "maint"
        pos = InStrRev(filetouse, "\")
        tblName = Mid(filetouse, pos + 1)
        If srchlist <> "" Then
            srchcols = Split(srchlist, ",")
            temp = "sselect " & tblName & " with " & srchcols(0) & " = '[" & sentence & "]'"
            If UBound(srchcols) > 0 Then
            For i = 1 To UBound(srchcols)
                temp = temp & " or " & srchcols(i) & " = '[" & sentence & "]'"
            Next
            End If
            sentence = temp
        End If
      Case "gen.l", "job.l"                     'sv 05 feb 02
            temp = "sselect " & filetouse & " with a2 = """ & temp & "]"" "
            sentence = temp
      Case "stock"                              'sv 05 feb 02
            temp = "sselect " & filetouse & " with a1 = """ & temp & "]"" "
            sentence = temp
      Case Else
        If Left(temp, 1) = "," Then
           temp = Mid(temp, 2): If temp = "" Then temp = " "
           sentence = "sselect property with road = """ & temp & "]"" "
        Else
           sentence = "sselect property with @@drindex|client|oname|4|29|0|1@@ = """ & temp & "]"" by oname"
        End If
     End Select
 '       Case "road"
 '          If templatetouse = "client" Then
 '             sentence = "sselect client with stname = """ & temp & "]"" "
 '          Else
 '             sentence = "sselect property with road = """ & temp & "]"" "
 '          End If
 '       Case "assessment": sentence = "sselect property with a0 = """ & temp & "]"" "
 '    End Select
 
 '       Else
 '           sentence = "sselect " & tblName
 '       End If
 'End If
 
'RSBuildSearch = logentry

 RSBuildSearch = making_html(template_path, logentry, filetouse, sentence, templatetouse, "1", PageSize, "0", "", "", 0, "", title, hds, tds, dms, "", "", NewTemplates, 1)
 
End Function

Public Function RSSelectCount(logentry As String, sentence As String, SingleItem As Variant) As String

Dim ids() As String
Dim NotNeeded As Long

   RSSelectCount = CStr(d3.d3_select(logentry, sentence, ids(), NotNeeded, 0, 0))
   If RSSelectCount = "1" Then SingleItem = ids(0) Else SingleItem = ""
   
End Function


Public Function making_html(template_path As String, logentry As String, the_file As String, sentence As String, stemplate As String, Page As String, passed_page_size As String, Optional want_excel As String = "0", Optional user As String = "", Optional where_is_prospect As String = "", Optional code_attr As Integer = 0, Optional client_id As String = "", Optional title As String = "", Optional hds As String = "", Optional tds As String = "", Optional dms As String = "", Optional particular As String = "", Optional excel_name As String = "", Optional NewTemplates As String = "", Optional always_table As Integer = 0)
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' PURPOSE:
'   Produce HTML for page. Mostly produces tables but is also capable of doing single items
'
' INPUTS:
'   the_file        :   Name of pick file to use (eg gen.l)
'   sentence        :   Select sentence to retrieve data
'   stemplate  :   Name of the template file to use
'   page            :   Page number to show
'   passed_page_size:   Number of items to show on each page
'
' PROCESS:
'   trec        :   HTML for table, built up by make_html_table
'   max         :   Position of ".mdb" in 'sentence'. Reused to count number of lines in a template but this ** NEVER USED **
'   temp        :   Various temporary strings, usually to build select sentences
'   temp2       :   Various temporary strings, usually to build select sentences
'   table_lne   :   One row of the table
'   tradd       :   TR tag to use for each additional row in the table
'   mylist()    :   Results of select sentence as passed to d3_select (Item id's)
'   num_items   :   Counter to loop through totals. Reused to loop through # of rows (items) to put on page
'   upper_bound :   No. of items returned from select sentence getting data for current page
'   page_size   :   Integer value of 'passed_page_size' if > 0. Defaults to 20.
'   total_pages :   'total_items' divided by 'page_size' plus 1 if a partial page is needed
'   partial_page:   Remainder of 'total_items' divided by 'page_size'
'   start       :   1 if first page, otherwise first item number to show on current page
'   page_needed :   Integer value of 'page'
'   pick_cnt    :   Number of items returned by d3_select (-ve)
'   total_items :   Number of items returned by d3_select
'   loop_size   :   Number of items to put on the page
'   how         :   0 for normal page, 1 if using MS ACCESS
'   dbname      :   ACCCESS database name, stripped from 'sentence'
'   table_name  :   ACCCESS table name, stripped from 'sentence'
'   the_tds()   :   All the <TD> tags in the table row, stripped from the template by make_tds
'   first_time  :   TRUE if making the first table row, so we know to initialise vars etc
'   nn          :   Counter (from 1 to 3). Used with save_totals and page_save_totals
'   numcols     :   Number of columns (TD's) in the table row, returned by make_tds
'   all_items_needed    :   True if all items will fit on one page
'   page_upper_limit    :   Last item number to show on this page
'   page_lower_limit    :   First item number to show on this page
'   grand       :
'   ub_totals   :
'   col_convs() :
'   totals()    :
'   previous()  :
'   check()     :
'   nvpos()     :
'   save_totals()       :
'   page_totals()       :
'   page_previous()     :
'   page_save_totals()  :
'   add_to_total()      :
'   send_back_to_prospect   :   Results of call to make_page
'   tcounter    :   Index for arrays containing template names and contents
'
' OUTPUTS:
'   make_html   :   HTML text sent back to the ASP page
'
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim trec As String, grand As String, ub_totals As Integer 'mc 14jul99
Dim max As Integer, tempobj As Object, the_drive As String
Dim temp As String, temp2 As String, props As String, pids As String
Dim id As String
Const allow_cols As Integer = 40
Dim table_lne As String
Dim want As String
Dim table_id As String
Dim tradd As String
Dim send_back_to_prospect As String
Static mylist() As String, uselist() As String 'mc 29sep00
Dim num_items As Integer
Dim upper_bound As Long
Dim page_size As Integer
Dim total_pages As Integer
Dim partial_page As Integer
Dim start As Long
Dim page_needed As Integer

Dim last_page As Boolean
Dim all_items_needed As Boolean
Dim next_item As Boolean

Dim pick_cnt As Long
Dim total_items As Long
Dim page_upper_limit As Long
Dim page_lower_limit As Long
Dim loop_size As Long
Dim how As Integer
Dim Jj As Integer, maxp As Integer, pid As String, posn As Integer
Dim dbname As String, table_name As String
Dim the_tds() As String
Static first_time As Boolean
Static totals() As Currency
Static save_totals() As Currency
Static page_totals() As Currency
Static page_previous() As String
Static page_save_totals() As Currency
Dim Nn As Integer, Msg As String
Static col_convs() As String
Dim numcols As Integer, add_to_total() As Integer, check() As Boolean, nvpos() As Integer
Static previous() As String

Dim tcount As Long, finding As String
Dim flds() As String, tarr() As String
Dim s_start As Integer, s_end As Integer, eq_or_ne As String
Dim nvs() As String, wants() As String
Dim t1() As String, t2() As String
Dim database As String
Dim hdsarray() As String, dmsarray() As String, fattr As Integer, tattr As Integer, usehds As String
Dim mthends() As String, part_hds As String, the_year As String, rderr As Integer, mongol As Integer

     database = pick.extract(logentry, 2, 0, 0)
     the_drive = Left(template_path, InStr(template_path, "\prospect\") - 1) & "/"
     If Right(stemplate, 8) = "mongolia" Then mongol = 1 Else mongol = 0
     
     hdsarray = Split(hds, "|")
     dmsarray = Split(dms, "|")
     usehds = ""
     For Jj = 0 To UBound(hdsarray)
        If InStr(pick.field(dmsarray(Jj), ",", 1), "-") <> 0 And Left(dmsarray(Jj), 1) <> "-" Then
           part_hds = pick.field(hdsarray(Jj), " ", 1) & " "
           fattr = pick.field(dmsarray(Jj), "-", 1)
           tattr = pick.field(dmsarray(Jj), "-", 2)
           ReDim mthends(0): mthends(0) = "YEAR"
           rderr = d3.d3_readmat("", mthends(), the_drive & "ckashare\gen_l\gen_l.mdb\CurrentYear")
           the_year = mthends(1)
           ReDim mthends(0): mthends(0) = the_year
           rderr = d3.d3_readmat("", mthends(), the_drive & "ckashare\gen_l\gen_l.mdb\monthends")
           If UBound(mthends) < 12 Then ReDim Preserve mthends(12)
           For posn = fattr To tattr
              usehds = usehds & "<TH>" & part_hds & mthends(posn - fattr + 1)
           Next posn
        Else
           usehds = usehds & "<TH>" & hdsarray(Jj)
        End If
     Next Jj
     '"<TH>" & Replace(hds, "|", "<TH>")
     
     If IsNumeric(Left(sentence, 1)) Then
        total_items = CLng(pick.field(sentence, ",", 1))
        sentence = Mid(sentence, pick.Index(sentence, ",", 1) + 1)
        how = 0 'mc 28apr99
        max = InStr(1, the_file, ".mdb\", 0) 'mc 28apr99
        If max <> 0 Then 'mc 28apr99
           how = 1 'mc 28apr99
           dbname = Left(the_file, max + 3) 'mco 28apr99
           dbname = Mid(dbname, InStr(the_file, " ") + 1) 'mco 28apr99
        End If 'mc 28apr99
        GoTo aaaa
     End If
     
     first_time = True
     'Added RGM 5Oct99 as totals and previous are used before they have any value
     'ReDim totals(ub_totals): ReDim previous(numcols)
     ReDim page_totals(allow_cols, 0):  ReDim page_save_totals(3, allow_cols, 0) 'allow for 3 breaks, allow_cols columns
     max = InStr(the_file, ".mdb\") ' select * from filename
     If max <> 0 Then
        'get something like
        'sselect d:ckashare\pools\pools.mdb\sw_pool with a0 = "1"
        ' so want to make into a sql sentence
        dbname = Left(the_file, max + 3) 'mco 28apr99
        dbname = Mid(dbname, InStr(the_file, " ") + 1) 'mco 28apr99
        table_name = Mid(the_file, max + 5): table_name = pick.field(table_name, " ", 1) 'mco 28apr99
        max = pick.Index(sentence, " ", 2)
        If max <> 0 Then
           temp = Mid(sentence, max)
           'Doesn't look like the below works! Commented out for now...
           Call pick.sr_chone(temp, " by ", " orderby ")
           temp = Replace(temp, " by ", " , ") 'replace all other ' by ' with ','
           Call pick.sr_chone(temp, " orderby ", " order by ")
           'temp = replace(temp, """", "'") ' double quotes to single quotes
           temp = Replace(temp, " a0 ", " id ") 'not all fields being handled - just do a0 for now
           Call pick.sr_chone(temp, " with ", " where ")
           temp = Replace(temp, " with ", " ")
           Call pick.sr_change(temp, """", "'") ' double quotes to single quotes
           Call pick.sr_change(temp, "= '[", "like '*")  'mco 10jan00 till next one
           Call pick.sr_change(temp, "]'", "*'")
make_html_next_dsnd:
           max = pick.Index(temp, "by-dsnd", 1)
           If max <> 0 Then
              For Nn = max + 8 To Len(temp)
                 If Mid(temp, Nn, 1) = " " Then Exit For
              Next Nn
              temp = Left(temp, Nn) & " DESC " & Mid(temp, Nn + 1)
              If InStr(temp, " order by ") = 0 Then
                 temp = Left(temp, max - 1) & " ORDER BY " & Mid(temp, max + 7)
              Else
                 temp = Left(temp, max - 1) & "," & Mid(temp, max + 7)
              End If
              GoTo make_html_next_dsnd 'mco 10jan00
           End If
        Else
           temp = ""
        End If
        sentence = "select * from " & table_name & temp
        If InStr(1, sentence, "!", 0) <> 0 Then
           Call pick.sr_change(sentence, "!", " ")
           Call pick.sr_chone(sentence, "where ", "")
        End If
        
        'sentence = "select * from orkh inner join nationality on orkh.nationality = nationality.code where nationality.description = ""mongolian"""
        total_items = d3.msa_select(dbname, sentence, mylist(), pick_cnt, 0, 0)
        If pick_cnt = -1 Then total_items = -1
        how = 1
     Else  'sselect filename
        If Right(the_file, 1) = "\" Then
           max = pick.ccount(the_file, "\", 0) 'have select c:\d3_cka\letter\ etc
           temp2 = pick.field(the_file, "\", max)
           max = pick.Index(sentence, " ", 2)
           If max = 0 Then temp = "" Else temp = Mid(sentence, max)
           sentence = pick.field(sentence, " ", 1) & " " & temp2 & temp
        End If
        how = pick.Index(sentence, "@@", 2) ' of form select tdebtor with @@drindex|client|name@@ = "coll]" and then maybe AND WITH or BY A0 or nothing else
        If how <> 0 Then
           eq_or_ne = pick.field(Mid(sentence, how + 2), " ", 2)
           If eq_or_ne <> "=" And eq_or_ne <> "#" Then GoTo slow_way
           s_start = pick.Index(sentence, "@@", 1) - 7: s_end = how + pick.Index(Mid(sentence, how), """", 2)
           temp = pick.field(sentence, "@", 3)
           finding = pick.field(Mid(sentence, how), """", 2)
           If pick.Index(finding, "[", 1) <> 0 Then 'must use standard pick sentence if want this
              temp2 = ""
slow_way:
              If pick.Index(pick.field(temp, "|", 3), "]", 1) <> 0 Then temp2 = "" 'already have ] so do not need one added if go slow needed
              pid = Mid(sentence, pick.Index(sentence, "@", 4) + 1)
              If temp2 <> "" Then
                 pid = Left(pid, pick.Index(pid, """", 2) - 1) & temp2 & Mid(pid, pick.Index(pid, """", 2))
              End If
              sentence = pick.field(sentence, "@", 1) & pick.field(temp, "|", 3) & pid
           Else
              finding = Replace(finding, "]", "")
              flds = Split(temp, "|", -1, vbBinaryCompare)
              ReDim Preserve flds(7)
              temp2 = sr501(database, flds(0), flds(1), finding, "", 1, 1, CInt(flds(3)), CInt(flds(5)), 0)
              If temp2 = Chr(8) Then temp2 = "]": GoTo slow_way ' too many found ie > 32000 length string
              Select Case flds(4)
                 Case "1": temp2 = Replace(temp2, Chr(254), "''") 'glindex jlindex
                 Case "29", "45", "31"
                    temp2 = pick.extract(temp2, 1, 0, 0)
                    tarr = Split(temp2, Chr(253), -1, vbBinaryCompare)
                    If temp2 = "" Then total_items = -1 Else total_items = UBound(tarr) 'pick.DCount(temp2, Chr(253))
                    pids = ""
                    For how = 0 To total_items
                       temp = tarr(how) 'pick.extract(temp2, 1, how, 0)
                       If d3.d3_readstr(database, props, "client", temp, CInt(flds(4)), 0, 0) <> 0 Then props = ""
                       maxp = pick.DCount(props, Chr(253)) 'or animal ids attr 45
                       For Jj = 1 To maxp
                          pid = pick.extract(props, 1, Jj, 0)
                          If pick.locate(pid, pids, 1, 1, 0, posn, "") = 0 Then
                             pids = pick.Insert(pids, 1, -1, 0, pid)
                          End If
                       Next Jj
                    Next how
                    temp2 = pids
                    temp2 = Replace(temp2, Chr(253), "''")
                 Case Else
                    temp2 = pick.extract(temp2, 1, 0, 0) 'crindex drindex
                    temp2 = Replace(temp2, Chr(253), "''")
              End Select
              If flds(7) <> "" Then 'transaction files not using ids
                 eq_or_ne = " with " & flds(7) & " = "
                 temp2 = " """ & Replace(temp2, "'", """") & """"
              Else
                 If Right(Left(sentence, s_start), 4) = "and " Then s_start = s_start - 4 'mc 09apr01 change " and" to "and "
                 If eq_or_ne = "=" Then eq_or_ne = "" Else eq_or_ne = " " & eq_or_ne
                 temp2 = " '" & temp2 & "'"
              End If
              sentence = Left(sentence, s_start) & Mid(sentence, s_end) & eq_or_ne & temp2
           End If
        End If
        
        how = 0
        total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0)
     End If
     
'***************************************
    If total_items <= 0 Then 'will get -1 if error in msa_select
       If total_items < 0 Then 'mc 31mar00
          making_html = Chr(8) & "=" & dbname & "=" & sentence 'mc 31mar00
       Else 'mc 31mar00
          making_html = "" 'mc 31mar00
       End If 'mc 31mar00
       Exit Function
    End If
'****************************************
   If total_items = 1 And always_table <> 1 Then
        'Only build a single item page if this is _not_ a transaction template!
        If Right(stemplate, Len(stemplate) - 2) <> "_trans" Then
            trec = make_html_item(template_path, logentry, CStr(how), the_file, mylist(0), stemplate)
            making_html = "<a href=""/prospect/asp/menu.asp""><IMG SRC=""/prospect/images/default/explorer/start_up.gif"" BORDER=0 WIDTH=30 HEIGHT=22 ALT=""Prospect Explorer""></a>" & trec
            Exit Function
        End If
   End If
'****************************************
aaaa:
   If IsNumeric(passed_page_size) Then
      page_size = CInt(passed_page_size)
      If page_size <= 0 Then page_size = 20
   Else
      page_size = 20
   End If
   
   page_needed = CInt(Page)
   If page_needed > 1 Then start = (CLng(page_needed) - 1) * page_size Else start = 1
   If start > total_items Then 'allow for bad page
      start = 1
      page_needed = 1
      Page = 1
   End If
'*******************************************
  If total_items > page_size * 1.6 Then
     partial_page = total_items Mod page_size
     total_pages = total_items \ page_size
     If partial_page Then total_pages = total_pages + 1
     If Page > total_pages Then Page = 1
     all_items_needed = False
  Else
     partial_page = 0
     total_pages = 1
     all_items_needed = True
  End If
'********************************************************
     dms = Replace(dms, "@@PICKFILE@@", the_file)
     t1 = Split(tds, "|")
     t2 = Split(dms, "|")
     If UBound(t1) <> UBound(t2) Then
        If UBound(t1) > UBound(t2) Then ReDim Preserve t2(UBound(t1)) Else ReDim Preserve t1(UBound(t2))
     End If
     table_lne = "": tradd = "<TR CLASS=""mm"">"
     For Nn = 0 To UBound(t2)
        table_lne = table_lne & t1(Nn) & "|" & t2(Nn) & "|"
     Next Nn
     Call make_tds(table_lne, the_tds(), numcols, add_to_total(), check(), nvpos(), ub_totals, nvs(), wants())
'********************************************************
     If first_time Then
        ReDim totals(ub_totals)
        ReDim col_convs(numcols)
        ReDim previous(numcols): ReDim page_previous(allow_cols, 1): ReDim save_totals(3, allow_cols)
        first_time = False
     End If
     
     If page_needed = 1 Then page_lower_limit = start Else page_lower_limit = start + 1
     page_upper_limit = page_lower_limit + page_size - 1

     If UBound(page_totals, 2) < page_needed Then
        For num_items = 1 To UBound(totals)
           totals(num_items) = 0 '???
        Next num_items
        For num_items = 1 To UBound(previous)
            previous(num_items) = Chr(8)   'mc 22jul99 'so can know when first time
            page_previous(num_items, 1) = Chr(8)
        Next num_items  'mc 22jul99
     Else
        For num_items = 1 To UBound(totals)
           totals(num_items) = page_totals(num_items, page_needed)
           previous(num_items) = page_previous(num_items, page_needed)
           For Nn = 1 To 3
              save_totals(Nn, num_items) = page_save_totals(Nn, num_items, page_needed)
           Next Nn
        Next num_items
     End If
'********************************************
     If total_pages = page_needed Then
        If partial_page Then page_upper_limit = (page_lower_limit + partial_page) - 1
     End If
     If all_items_needed Then page_upper_limit = total_items

     loop_size = page_upper_limit - page_lower_limit 'mc 29sep00
     ReDim uselist(loop_size) 'mc 29sep00
     For tcount = page_lower_limit - 1 To page_upper_limit - 1 'mc 29sep00
        uselist(tcount - (page_lower_limit - 1)) = mylist(tcount) 'mc 29sep00
     Next tcount 'mc 29sep00
     
     trec = tradd
     If want_excel = "1" Or want_excel = "2" Then 'mco 9dec00 add print option
        Call make_html_table(logentry, mylist(), CLng(page_lower_limit + num_items), numcols, the_file, trec, -1, tradd, 1, the_tds(), totals(), save_totals(), col_convs(), add_to_total(), check(), nvpos(), previous(), nvs(), wants(), loop_size, excel_name, code_attr, client_id, usehds, want_excel, , mongol) 'mc 9dec00
     Else
        Call make_html_table(logentry, uselist(), CLng(page_lower_limit + num_items), numcols, the_file, trec, -1, tradd, 1, the_tds(), totals(), save_totals(), col_convs(), add_to_total(), check(), nvpos(), previous(), nvs(), wants(), -1, "", code_attr, client_id, , , , mongol) 'mc 9oct00
     End If
     
     If UBound(page_totals, 2) < page_needed + 1 Then
        ReDim Preserve page_totals(allow_cols, page_needed + 1)
        ReDim Preserve page_previous(allow_cols, page_needed + 1)
        ReDim page_save_totals(3, allow_cols, page_needed + 1)
        For num_items = 1 To UBound(totals)
           page_totals(num_items, page_needed + 1) = totals(num_items)
           page_previous(num_items, page_needed + 1) = previous(num_items)
           For Nn = 1 To 3
              page_save_totals(Nn, num_items, page_needed + 1) = save_totals(Nn, num_items)
           Next Nn
        Next num_items
     End If
     If page_upper_limit = total_items Then
        For num_items = 1 To numcols
           If add_to_total(num_items) Then GoTo total_required
        Next num_items
        GoTo no_total_required
total_required:
        For num_items = 1 To UBound(totals) 'mc 14jul99
           totals(num_items) = page_totals(num_items, page_needed + 1)
        Next num_items
        For num_items = 1 To numcols
           If check(num_items) Then
              grand = previous(num_items) & " SUB-TOTALS"
              previous(num_items) = Chr(8) 'mc 04sep01
              Call make_totals(total_items + 1, grand, totals(), save_totals(), num_items, trec, tradd, the_tds(), add_to_total(), col_convs())
           End If
        Next num_items
        Call make_totals(0, "TOTALS", totals(), save_totals(), 0, trec, tradd, the_tds(), add_to_total(), col_convs())
     End If
no_total_required:

     trec = "<TABLE align=center cellspacing=1 cellpadding=1 border=1 WIDTH=95%><TR CLASS=top>" & usehds & trec & "</TABLE>"
     
     Select Case want_excel
        Case "1", "2"
           If want_excel = "1" Then
              temp2 = "Excel Workbook"
           Else
              temp2 = "Document file"
           End If
           temp2 = "<P align=center>" & temp2 & " is called <A HREF=""" & excel_name & """>" & excel_name & "</A><P>"
        Case Else
           temp2 = ""
     End Select
     
     Select Case Left(particular, 1)
        Case "1": 'budget worksheet loaded
           Set tempobj = CreateObject("cka_gl.gl")
           Call tempobj.sr_workbook(the_drive, excel_name, "A")
           Set tempobj = Nothing
     End Select
     
     send_back_to_prospect = make_page(Page, total_pages, total_items, trec, page_size, sentence, the_file, stemplate, temp2, title, hds, tds, dms, code_attr, NewTemplates)
     making_html = send_back_to_prospect
     
     Exit Function

End Function

Public Function make_html_what(logentry As String, how As Integer, id As String, datum_id As String, what_to_do As String, want As String, wantarr() As String, the_file As String, the_rec() As String, conversion As String, html_link As String, job_l As Integer, lines() As String, upto_j As Integer) As String 'mc 4jan02

Dim attr As Integer, val As Integer, SVAL As Integer, fname As String
Dim maxvm As Integer, j As Integer, summing As Currency, operator As String, datum_op As String 'mc 21may99
Dim prefix As String, template As String, file As String, cr_dr As String
Dim pos As Integer, datum As String, datum_id_converted As String
Dim temp As String, temp2 As String, vm_datum As String, vv As Integer, maxvals As Integer
Dim temparr() As String, rderr As Integer, cq As String, code As String, database As String
Dim fattr As Integer, tattr As Integer, oo As Integer 'mc 4jan02

database = pick.extract(logentry, 2, 0, 0)

Select Case what_to_do
                  Case "-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
                     Select Case wantarr(0)
                        Case "0"
                           attr = 0: datum = id
                        Case "-1"
                           attr = -1: datum = the_rec(0)
                           For vv = 1 To UBound(the_rec)
                              datum = datum & Chr(254) & the_rec(vv)
                           Next vv
                           pos = pick.Index(want, ",", 4)
                           If pos <> 0 Then
                              conversion = Mid(want, pos + 1)
                              If conversion <> "" Then GoTo what_conversion
                           End If
                        Case Else
                           datum = ""
                           If InStr(wantarr(0), "-") = 0 Then
                              attr = CInt(wantarr(0))
                              If UBound(the_rec) >= attr Then datum = the_rec(attr)
                           Else
                              fattr = CInt(pick.field(wantarr(0), "-", 1))
                              tattr = CInt(pick.field(wantarr(0), "-", 2))
Dim the_year As String, year_rec() As String, year_file As String, year_using As String, curr_year As Integer, year_mdb As String
                              the_year = pick.field(wantarr(0), "-", 3)
                              If Left(the_year, 1) = "+" Then the_year = "-" & Mid(the_year, 2)
                              If the_year <> "" Then
                                 For attr = Len(the_file) To 1 Step -1
                                     If Mid(the_file, attr, 1) = "\" Then
                                        year_mdb = Left(the_file, attr)
                                        year_file = Mid(the_file, attr + 1)
                                        Exit For
                                     End If
                                 Next attr
                                 ReDim year_rec(0): year_rec(0) = "YEAR"
                                 rderr = d3.d3_readmat("", year_rec(), year_mdb & "currentyear")
                                 curr_year = Right(year_rec(1), 2)
                                 
                                 year_using = Right(year_file, 2)
                                 If Not IsNumeric(year_using) Then year_using = curr_year
                                 year_using = Right(CInt(year_using) - CInt(the_year) + 100, 2) 'subtract 1 year allow for 00
                                 If year_using = curr_year Then year_using = "" Else year_using = "_" & year_using
                                 year_file = year_mdb & "gen_l" & year_using
                                 ReDim year_rec(0): year_rec(0) = the_rec(0)
                                 rderr = d3.d3_readmat(database, year_rec(), year_file)
                              Else
                                 year_rec = the_rec
                              End If
                              If UBound(year_rec) < tattr Then ReDim Preserve year_rec(tattr)
                              For attr = fattr To tattr
                                 temp = year_rec(attr)
                                 If IsNumeric(temp) Then temp = FormatCurrency(temp, 2)
                                 datum = datum & temp & Chr(254)
                              Next attr
                              make_html_what = Left(datum, Len(datum) - 1) 'remove last chr(254)
                              Exit Function
                           End If
                           temp = wantarr(1)
                           summing = 0: operator = "" 'mc 21may99
                           Select Case Left(temp, 1) 'mc 21may99
                            Case "L", "S"  'mc 21may99
                              val = CInt(pick.DCount(datum, Chr$(253)))
                              If temp = "SUM" Then summing = 1 'mc 21may99 till next one
                              If temp = "SUMA" Then summing = 3
                            Case "-", "+", "*", "/"
                              val = 0
                              operator = Left(temp, 1)
                              temp = Mid(temp, 2)
                              If Left(temp, 3) = "SUM" Then summing = 2: temp = Mid(temp, 4)
                              If Left(temp, 3) = "VAL" Then val = Mid(temp, 4, 3): temp = Mid(temp, 7) 'expect eg *VAL00314 - means val3 attr 14
                              If IsNumeric(temp) Then attr = CInt(temp) 'mc21may99
                            Case "V", "W" 'mc 26oct00 - see ifiling.htm want value marks
                                    'mc 03oct01 - see igen_l_grp want to select a file and return as values
                              If temp = "V" Then make_html_what = datum: Exit Function
                              temp2 = Left(temp, 1)
                              temp = Mid(temp, 2) 'sselect c:\ckashare\gen_l\gen_l.mdb\gl_rtype rtype ! where account = '' order by rtype
                              temp = Replace(temp, "''", "'" & id & "'")
                              temp = Replace(temp, "}", ",")
                              If temp2 = "V" Then 'binput.asp only - cannot use this in tables eg search .txt items
                                 cq = get_ids(logentry, temp, "", Chr(253), "")
                                 If UBound(the_rec) < attr Then ReDim Preserve the_rec(attr)
                                 the_rec(attr) = cq
                              Else 'see debtors invoices_mdb.txt
                                 cq = d3.msa_select_str(wantarr(2), temp, 2, "", "<TR><TD>")
                              End If
                              make_html_what = cq
                              Exit Function
                            Case Else
                              If IsNumeric(temp) Then val = CInt(temp) Else val = 0
                           End Select
                           If IsNumeric(wantarr(2)) Then SVAL = CInt(wantarr(2)) Else SVAL = 0
                           datum = make_html_what_datum(summing, val, SVAL, datum, want) 'mc 21may99 till next one
                           If operator <> "" Then
                              If UBound(the_rec) < attr Then datum_op = "" Else datum_op = the_rec(attr)
                              If summing = 2 Then
                                 summing = 1
                                 val = CInt(pick.DCount(datum_op, Chr$(253)))
                              Else
                                 summing = 0
                              End If
                              datum_op = make_html_what_datum(summing, val, SVAL, datum_op, want)
                              If Not IsNumeric(datum) Then datum = "0"
                              If Not IsNumeric(datum_op) Then datum_op = "0"
                              Select Case operator
                                 Case "+": datum = CStr(CCur(datum) + CCur(datum_op))
                                 Case "*": datum = CStr(CCur(datum) * CCur(datum_op))
                                 Case "-": datum = CStr(CCur(datum) - CCur(datum_op))
                                 Case "/": datum = CStr(CCur(datum) / CCur(datum_op))
                              End Select
                           End If
                     End Select
                     pos = pick.Index(want, ",", 4)
                     conversion = ""
                     If pos <> 0 Then
                       conversion = Mid(want, pos + 1)
what_conversion:
                       datum_id = datum 'before converted ie jobxxx.xxx.xxx becomes xxx.xxx.xxx
                       prefix = pick.field(conversion, ",", 1)
                       conversion = Mid(conversion, InStr(conversion, ",") + 1)
                       If conversion = "OPTION" Then 'mco 4jan02
                          temp = "<option value=""" & datum & """>" 'mco 4jan02
                          For oo = upto_j + 1 To UBound(lines) 'mco 4jan02
                             maxvm = InStr(lines(oo), temp) 'mco 4jan02
                             If maxvm <> 0 Then 'mco 4jan02
                                datum = Mid(lines(oo), maxvm + Len(temp)) 'mco 4jan02
                                datum = pick.field(datum, "<", 1) 'mco 4jan02
                             End If 'mco 4jan02
                          Next oo 'mco 4jan02
                       Else 'mco 4jan02
                          If conversion <> "mongol" Then 'mco 13dec01 as mongol chars can be chr(254/253/252)
                             If attr = -1 Then
                                temp = d3.conv_out(database, "", how, conversion, datum)
                             Else
                                maxvm = pick.DCount(datum, Chr$(253))
                                temp = ""
                                For vv = 1 To maxvm
                                   vm_datum = pick.extract(datum, 1, vv, 0)
                                   temp2 = d3.conv_out(database, "", how, conversion, prefix & vm_datum)
                                   If vv = 1 Then temp = temp2 Else temp = temp & "<br> " & temp2
                                Next vv
                             End If
                             datum = temp
                          End If 'mco 13dec01
                        End If 'mco 4jan02
                     Else
                     ' this code added as when use qselect drindex the a1 returned has a vm and rubbish data
                        If attr = 0 Then datum = pick.extract(datum, 1, 1, 0) Else datum = Replace(datum, Chr(253), "<BR>") 'mc 29sep00
                     End If
                     make_html_what = datum
                  Case "@"
                        attr = CInt(wantarr(2))
                        fname = wantarr(5)
                        html_link = wantarr(1)
                        Select Case attr
                        Case 0
                           datum_id = id
                        Case -5 'used in general ledger transactions.txt - do not know whether client or employee in attr 5
                           fname = "EMPLOYEE"
                           Select Case the_rec(1) 'id is in attr1 so add 1 to all wanted
                            Case "23", "76", "37", "62", "48", "73", "41", "66"
                              fname = "PROPERTY": temp = ";2;3;4;5" 'assessment
                            Case "42", "67", "40", "65"
                              temp = ";1;6" 'employee
                            Case Else
                              If InStr(the_rec(6), "EMP-") <> 0 And InStr(the_rec(6), "TS-") <> 0 Then
                                 temp = ";1;6" 'employee
                              Else
                                 fname = "CLIENT": temp = ";1;6" 'client
                              End If
                           End Select
                           datum_id = the_rec(5)
                           want = want & ",0,0,,,T" & fname & temp
                           html_link = Replace(html_link, "##", fname, , , vbBinaryCompare)
                        Case Else
                           temp = wantarr(3)
                           If temp = "LAST" Then
                              If UBound(the_rec) < attr Then temp = "" Else temp = the_rec(attr)
                              val = CInt(pick.DCount(temp, Chr$(253)))
                           Else
                              If IsNumeric(temp) Then val = CInt(temp) Else val = 0
                           End If
                           If IsNumeric(wantarr(4)) Then SVAL = CInt(wantarr(4)) Else SVAL = 0
                           If UBound(the_rec) < attr Then datum_id = "" Else datum_id = the_rec(attr)
                           datum_id = pick.extract(datum_id, 1, val, SVAL)
                           If job_l = 1 Then
                              code = pick.extract(the_rec(2), 1, val, SVAL)
                              Select Case code
                                 Case "Supplier Invoice": template = "cr_inv": file = "cr.inv": cr_dr = "creditor"
                                 Case "Supplier Credit": template = "cr_credit": file = "cr.credit": cr_dr = "creditor"
                                 Case "Journal CR", "Journal DR": template = "journal": file = "journal": cr_dr = "creditor"
                                 Case "Purchase Order": template = "purchase": file = "purchase": cr_dr = "creditor"
                                 Case "Goods Inward": template = "goodsin": file = "goodsin": cr_dr = "creditor"
                                 Case "Invoice": template = "invoice": file = "invoice": cr_dr = "tdebtor"
                                 Case "Credit": template = "credit": file = "credit": cr_dr = "tdebtor"
                                 Case "Timesheet": template = "timesheets": file = "time.sheets": cr_dr = "employee"
                                 Case "Issue": template = "issue": file = "issue": cr_dr = "stock"
                                 Case "Return": template = "returns": file = "returns": cr_dr = "stock"
                              End Select
                              If Left(code, 6) = "Cheque" Then
                                 cq = Mid(code, 8)
                                 If cq = "1" Then cq = ""
                                 template = "chq_rec": file = "chq.rec" & cq: cr_dr = "client"
                              End If
                              html_link = Replace(html_link, "???", file)
                              html_link = Replace(html_link, "!!!", template)
                              html_link = Replace(html_link, "%%%", cr_dr)
                           End If
                           'If attr = 7 Then MsgBox attr & "=" & job_l & "=" & pick.extract(the_rec(2), 1, val, SVAL) & "=" & html_link
                           datum_id = Replace(datum_id, Chr(252), "<BR>", , , vbBinaryCompare) 'for narrative
                           If fname = "OWNERS" Then
                              ReDim temparr(0): temparr(0) = datum_id
                              rderr = d3.d3_readmat(database, temparr(), "client", 35, 1, 0)
                              datum_id = temparr(1)
                           End If
                        End Select

                        pos = pick.Index(want, ",", 6)
                        datum_id_converted = datum_id
                        conversion = ""
                        If pos <> 0 Then
                           conversion = Mid(want, pos + 1)
                           prefix = pick.field(conversion, ",", 1)
                           conversion = Mid(conversion, InStr(conversion, ",") + 1)
                           datum_id_converted = d3.conv_out(database, "", how, conversion, prefix & datum_id)
                           If Left(conversion, 1) = "G" Then
                              temp = pick.field(conversion, "~", 1) 'just do the group extract
                              datum_id = d3.conv_group(database, datum_id, temp)
                           End If
                        End If
                        make_html_what = datum_id_converted
             Case "<"
                        temp = id
                        temp = Mid(temp, 1, 8)
                        Call pick.sr_611(temp, "", False, "_", False, 0)
                        temp = Trim(temp)
                        make_html_what = Replace(want, "@@IMAGE@@", temp)
             End Select
End Function

Public Function make_html_item(template_path As String, logentry As String, how As String, the_file As String, use_id As String, stemplate As String, Optional action As String = "3", Optional report_sentence As String = "", Optional search As String = "", Optional trans_file As String = "", Optional no_update_delete As String = "0", Optional mainfile As String = "", Optional subfile As String = "", Optional printdoc As String = "", Optional mergefile As String = "", Optional docname As String = "", Optional defaulting As String = "") As String

Dim row As Integer, Nn As Integer, Cc As Integer, posted_form As String, defaults() As String, dd As Integer
Static before As String
Static no_update As String                  'sv 8 Mar 02
Dim max As Integer, j As Integer, lne As String, temp As String, want As String
Dim have_link As Boolean, what_to_do As String, datum As String
Dim pos_bar As Long, pos_bar2 As Long, rderr As Integer
Dim pos As Integer, number_values As Integer, ub_totals As Integer
Dim filenum As Integer, item_rec As String, datum_id As String
Dim datum_values As String, html_link As String, conversion As String
Dim exists As Boolean, fname As String, iname As String
Dim table_lne As String, tradd As String
Dim insert_pos As Integer, k As Integer
Dim Use_rec() As String, use_file As String
Dim save_rec() As String, tempc As String
Dim input_field As Integer
Dim select_field As Integer
Dim lneA As String
Dim lneB As String
Dim the_tds() As String
Dim gIds_sentence As String
Dim testcol As Integer, islist As Boolean
Dim Banks As String, max_banks As Integer
Dim totals() As Currency, col_convs() As String, save_totals() As Currency
Dim if_is_on As Integer, loop_lines() As String, Jj As Integer, loopnum As Integer, kk As Integer
Dim sr_is_on As Boolean
Dim startj As Integer, endj As Integer
Dim pick_cnt As Long, num_items As Long, loop_size As Long
Dim total_items As Long, mylist() As String, dbname As String, selfilename As String 'mc 1jun99
Dim idcnt As Integer, navbar As Boolean, numcols As Integer, numrows As Integer, add_to_total() As Integer
Dim check() As Boolean, nvpos() As Integer
Dim previous() As String, item_not_found As String
Dim IREC As String 'mc 04aug99
Dim prefix As String 'mco 21oct00
Dim Sze As Integer, what As String, Default As String, attr As Integer
Dim lines() As String
Dim nvs() As String, wants() As String, wantarr() As String
Dim database As String, the_drive As String
Dim ctr As Integer, Head_Var As String, Howbig As Long, ExcelFileName As String, DQ As String, Paras() As String
Dim tempobj As Object, job_l As Integer, txt_id As String
Dim transrec As String, Trans_rec() As String, mongol As Integer, tbl_name As String, workpath As String
Dim sfile As String

     database = pick.extract(logentry, 2, 0, 0)
        
     idcnt = 0
     make_html_item = ""
     DQ = Chr(34)
     
     temp = Replace(template_path, "prospect", "prospect_site") 'try for prospect_site first
     exists = d3.ReadDosFile(temp & "\" & stemplate & ".htm", item_rec) 'mco 13feb02
     If Not (exists) Then
        exists = d3.ReadDosFile(template_path & "\" & stemplate & ".htm", item_rec) 'mco 13feb02
     End If
     If Right(stemplate, 8) = "mongolia" Then mongol = 1 Else mongol = 0
     
     If Not (exists) Then
        exists = d3.ReadDosFile(template_path & "\" & "template.htm", item_rec) 'mco 13feb02
        If Not (exists) Then
           'If it still doesn't exist then display an error msg
           make_html_item = "<B><FONT SIZE=+1>Template File Error</FONT></B><BR><HR SIZE=1><P><table width= ""100%"" cellspacing=""3"" border=""2""><th align=""CENTER"" colspan=""2"" valign=""MIDDLE"" bgcolor=""goldenrod"">Error Details <TR><TD class = ""mm"">Template File Required<TD>" & template_path & "\" & stemplate & ".htm. Please contact CKA.</table>"  'mco 16sep00
           Exit Function
        End If
        Call default_item(database, item_rec, the_file, stemplate, True)
     End If
     
     the_drive = Left(template_path, InStr(template_path, "\prospect\") - 1)
     item_rec = Replace(item_rec, "@@PATH@@", the_drive) 'for .mdb access so is path independent
          
     ReDim Use_rec(0): Use_rec(0) = use_id
     
     If the_file = "chq.rec" Then
        If UBound(g_trans_info_array) = 0 Then
           g_trans_info_array(0) = "TRANS.INFO"
           rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
        End If
        If UBound(g_trans_info_array) < 31 Then temp = "" Else temp = g_trans_info_array(31)
        If temp <> "" Then
           Banks = g_trans_info_array(4) & Chr(253) & g_trans_info_array(31)
           max_banks = pick.DCount(Banks, Chr(253))
           For j = 1 To max_banks
               If j <> 1 Then the_file = "chq.rec" & CStr(j)
               rderr = d3.d3_readmat(database, Use_rec(), the_file)
               If rderr = 0 And UBound(Use_rec) > 0 Then Exit For
               'need to check client and amount - same chq no may be in two different banks !!
'069               IF PASS.CLIENT # '' THEN
'070                  LOCATE PASS.CLIENT IN CHQREC<7,1> SETTING CX ELSE GOTO 105
'71                End
'072               IF PASS.GLDATE # '' THEN
'073                  IF PASS.GLDATE # CHQREC<3> THEN GOTO 105
'74                End
           Next j
           'chq not found at all !!
        End If
     Else
        If the_file = "" Or Left(the_file, 1) = Chr(8) Then
           rderr = 0
        Else
           rderr = d3.d3_readmat(database, Use_rec(), the_file)
        End If
     End If
     
     item_not_found = ""
     If use_id = Chr(8) Then
        use_id = ""
     Else
        If rderr <> 0 Then
           item_not_found = Chr(8)
           If the_file = "loans" Then
              If d3.d3_readstr(database, lne, "DICT TRANS.J", "@LOANS", 5) <> 0 Then lne = ""
              ReDim Use_rec(9): Use_rec(9) = lne 'interest rate
           End If
           If mainfile <> "" Then 'not on batch file, but maybe on mainfile when adding new one
              rderr = d3.d3_readmat(database, Use_rec(), mainfile)
              If rderr = 0 Then
                item_not_found = "": no_update_delete = "9"        'mco 1mar02 cannot add,update,delete from main file
              Else
                If no_update <> "" Then no_update_delete = no_update
              End If
           End If
           If rderr <> 0 Then
              defaults = Split(defaulting, ",")
              For dd = 0 To UBound(defaults)
                 If UBound(Use_rec) < defaults(dd) Then ReDim Preserve Use_rec(defaults(dd))
                 Use_rec(defaults(dd)) = pick.field(before, Chr(8), CInt(defaults(dd)))
              Next dd
           End If
        Else
            no_update_delete = no_update            'sv 8 Mar 02
        End If
     End If
     
     lines = Split(item_rec, vbCrLf, -1, vbBinaryCompare)
     If lines(0) = "@@NAVBAR@@" Then navbar = True: lines(0) = "" Else navbar = False
     max = UBound(lines)
     startj = 0: endj = max
make_html_after_loop:
     if_is_on = 0: loopnum = 0: sr_is_on = False
     job_l = 0
     For j = startj To endj
         lne = lines(j)
                
         If Left(lne, 7) = "||IFEND" Then
            If if_is_on > 0 Then if_is_on = if_is_on - 1
            lne = ""
            GoTo make_html_lne
         End If
         
         If if_is_on <> 0 Then
            If Left(lne, 7) = "||SREND" Then
               job_l = 0
               If sr_is_on Then GoTo item_restore
            End If
            If Left(lne, 4) = "||IF" Then if_is_on = if_is_on + 1
            lne = "": GoTo make_html_lne
         End If

         If Left(lne, 4) = "||IF" Then
           temp = pick.field(lne, ",", 2)
           If Left(temp, 1) = "S" Then
             If pick.Index(Use_rec(0), ".", 2) = 0 Then if_is_on = 1 Else if_is_on = 0
           Else
             If temp = "?" Then 'this to allow site specific  - set session("newzealand") = "wdc" and added to logentry<8> in login_check.asp 'mco 08dec01
                If pick.extract(logentry, 8, 0, 0) = pick.field(lne, ",", 3) Then 'mco 08dec01
                   If pick.field(lne, ",", 4) = "" Then if_is_on = 0 Else if_is_on = 1
                Else
'                   If pick.field(lne, ",", 4) = "#" Then if_is_on = 1 Else if_is_on = 0
                   If pick.field(lne, ",", 4) = "#" Then if_is_on = 0 Else if_is_on = 1 'DG 20/04/01
                End If
             Else
                If Left(temp, 1) = "P" Then 'mc22jul99 till next one
                   k = CInt(Mid(temp, 2)) '||IF,P2,=,sselect asset by locn by group
                   datum = pick.field(the_file, Chr(8), k + 1) 'have chr(8) parm1 chr(8) parm2 - so is k+1
                Else
                   k = CInt(temp)
                   If UBound(Use_rec) < k Then datum = "" Else datum = Use_rec(k)
                End If
                temp = pick.field(lne, ",", 3)
                lne = Mid(lne, pick.Index(lne, ",", 3) + 1)  'mc22jul99
                Select Case temp
                   Case "=": If lne = datum Then if_is_on = 0 Else if_is_on = 1
                   Case "#": If lne <> datum Then if_is_on = 0 Else if_is_on = 1
                 End Select
             End If
           End If
           lne = ""
           GoTo make_html_lne
         End If

        If Left(lne, 6) = "||LOOP" Then
           temp = Mid(lne, 7)
           If IsNumeric(temp) Then
              loopnum = CInt(temp)
           Else
              Set tempobj = CreateObject("cka_ta16.ta16")
              loopnum = tempobj.sr16_catnum(database)
              Set tempobj = Nothing
           End If
           lines(j) = ""
           For Jj = j + 1 To max - 1
              lne = lines(Jj)
              If Left(lne, 9) = "||LOOPEND" Then lines(Jj) = "": Exit For
              ReDim Preserve loop_lines(Jj - j): loop_lines(Jj - j) = lne
              lines(Jj) = ""
           Next Jj
           For Jj = 1 To loopnum
              For kk = 1 To UBound(loop_lines)
                 lne = loop_lines(kk)
                 Call pick.sr_change(lne, "&&LOOP&&", CStr(Jj))
                 k = pick.Index(lne, "&&sr16_catdesc", 1)
                 If k <> 0 Then
                    lne = Left(lne, k - 1)
                    Set tempobj = CreateObject("cka_ta16.ta16")
                    tempc = tempobj.sr16_catdesc(database, Jj)
                    Set tempobj = Nothing
                    lne = lne & tempc
                 End If
                 GoSub make_html_loop_line
              Next kk
           Next Jj
           startj = j: endj = max - 1: GoTo make_html_after_loop
        End If
       
make_html_loop_line:
           
        If Left(lne, 7) = "||SREND" Then
item_restore: 'mc 2jun99
            ReDim Use_rec(UBound(save_rec))
            For k = 0 To UBound(save_rec)
               Use_rec(k) = save_rec(k)
            Next k
            lne = ""
            sr_is_on = False
            GoTo make_html_lne
        End If
        
        If Left(lne, 8) = "||OPTION" Then
           lne = Mid(lne, 11)
           what = pick.field(lne, "|", 1)
           Default = "": Sze = -1
           If what = "SSELECT" Then '||OPTIONS|SSELECT|location by a0|4|1;0
              Sze = 2 'minimum size
              If IsNumeric(pick.field(lne, "|", 3)) Then
                 attr = CInt(pick.field(lne, "|", 3))
                 If UBound(Use_rec) >= attr Then
                    Sze = pick.DCount(Use_rec(attr), Chr(253))
                    If Sze < 2 Then Sze = 2
                    Default = Use_rec(attr)
                 End If
              End If
           End If
           
           lne = Mid(lne, Len(what) + 2)
           lne = make_options(logentry, what, lne, Default)
           If Sze <> -1 Then
              If InStr(lines(j - 1), "@@SIZE@@") <> 0 Then
                 Call pick.sr_chone(lines(j - 1), "@@SIZE@@", CStr(Sze))
              End If
           End If
           GoTo make_html_lne
        End If
        If Left(lne, 7) = "||EXCEL" Then
           Call make_excel(Use_rec(), lne)
           GoTo make_html_lne
        End If

         If Left(lne, 4) = "||SR" Then
            sr_is_on = True
            ReDim save_rec(UBound(Use_rec))
            For k = 0 To UBound(Use_rec)
               save_rec(k) = Use_rec(k)
            Next k
            Select Case pick.field(Mid(lne, 5), ",", 1)
               Case "sr_gen_l_month_values"
                  Set tempobj = CreateObject("cka_gl.gl")
                  Call tempobj.sr_gen_l_month_values(the_file, use_id, Use_rec())
                  Set tempobj = Nothing
               Case "sr16_val"
                  Set tempobj = CreateObject("cka_ta16.ta16")
                  Call tempobj.SR16_VAL(database, save_rec(), Use_rec())
                  Set tempobj = Nothing
               Case "sr16_cat"
                  Set tempobj = CreateObject("cka_ta16.ta16")
                  Call tempobj.sr16_cat(database, Use_rec())
                  Set tempobj = Nothing
               Case "sr1600"
                  Set tempobj = CreateObject("cka_ta16.ta16")
                  Call tempobj.sr1600(database, Use_rec(), lne)
                  Set tempobj = Nothing
               Case "ta1642" 'mco 16sep00 ??? discount date (last temp in call) not correct
                  temp = Mid(the_file, 2)
                  If Not IsDate(temp) Then temp = Date
                  Set tempobj = CreateObject("cka_ta16.ta16")
                  Call tempobj.ta1642(the_drive, logentry, Use_rec(), temp, use_id, pick.field(Mid(lne, 5), ",", 2))
                  Set tempobj = Nothing
               Case "sr1694"
                  temp = Mid(the_file, 2)
                  If Not IsDate(temp) Then temp = Date
                  Set tempobj = CreateObject("cka_ta16.ta16")
                  Call tempobj.sr1694(logentry, Use_rec(), temp, use_id, pick.field(Mid(lne, 5), ",", 2)) 'if passed null will do all props owned by first owner of this property
                  Set tempobj = Nothing
               Case "sr1607"
                  Set tempobj = CreateObject("cka_ta16.ta16")
                  Call tempobj.SR1607(database, Use_rec())
                  Set tempobj = Nothing
               Case "sr1625_ins"
                  temp = Mid(the_file, 2)
                  If Not IsDate(temp) Then temp = Date
                  Set tempobj = CreateObject("cka_ta16.ta16")
                  Call tempobj.SR1625_INS(logentry, Use_rec(), temp)
                  Set tempobj = Nothing
               Case "sr1629"
                  Set tempobj = CreateObject("cka_ta16.ta16")
                  Call tempobj.SR1629(database, Use_rec())
                  Set tempobj = Nothing
               Case "sr1651"
                  Paras() = Split(the_file, Chr(254), , vbBinaryCompare)
                  the_file = ""
                  Set tempobj = CreateObject("cka_ta16.ta16")
                  Call tempobj.SR1651(logentry, Paras(0), CInt(Paras(1)), CInt(Paras(2)), CInt(Paras(3)), CInt(Paras(4)), CInt(Paras(5)), Paras(6), ExcelFileName, Howbig, Use_rec())
                  Set tempobj = Nothing
                  If Howbig = 1 Then
                    make_html_item = "<a href=" & DQ & "/prospect_site/excel/" & ExcelFileName & DQ & " target=" & DQ & "/prospect_site/excel/" & ExcelFileName & DQ & " name=" & DQ & "Excel File" & DQ & ">Excel File:" & ExcelFileName & "</a>"
                    Exit Function
                  End If
               Case "sr1665"
                  Paras() = Split(the_file, Chr(254))
                  the_file = ""
                  Set tempobj = CreateObject("cka_ta16.ta16")
                  Call tempobj.SR1665(logentry, Paras(0), Paras(1), Paras(2), Paras(3), ExcelFileName, Howbig, Use_rec())
                  Set tempobj = Nothing
               Case "sr1680a"
                  Paras() = Split(the_file, Chr(254))
                  the_file = ""
                  Set tempobj = CreateObject("cka_ta16.ta16")
                  Call tempobj.SR1680A(logentry, Paras(0), Paras(1), Paras(2), Paras(3), "", Use_rec())
                  Set tempobj = Nothing
               Case "sr1680b"
                  Paras() = Split(the_file, Chr(254))
                  Select Case Paras(3)
                  Case "2"
                    Head_Var = "Zone"
                  Case "3"
                    Head_Var = "Rate <BR> Category"
                  Case "4"
                    Head_Var = "Ward"
                  Case Else
                    Head_Var = "Assesment"
                  End Select
                  For ctr = 0 To UBound(lines)
                    lines(ctr) = Replace(lines(ctr), "@@VAR01@@", Head_Var)
                  Next ctr
                  the_file = ""
                  Set tempobj = CreateObject("cka_ta16.ta16")
                  Call tempobj.SR1680B(logentry, Paras(0), Paras(1), Paras(2), Paras(3), Paras(4), Paras(5), Paras(6), ExcelFileName, Howbig, Use_rec())
                  Set tempobj = Nothing
                  If Howbig > 100 Then
                    make_html_item = "<a href=" & DQ & "/prospect_site/excel/" & ExcelFileName & DQ & " target=" & DQ & "/prospect_site/excel/" & ExcelFileName & DQ & " name=" & DQ & "Excel File" & DQ & ">Excel File:" & ExcelFileName & "</a>"
                    Exit Function
                  End If
               Case "sr1695_ins"
                  temp = Mid(the_file, 2)
                  If Not IsDate(temp) Then temp = Date
                  Set tempobj = CreateObject("cka_ta16.ta16")
                  Call tempobj.SR1695_INS(logentry, Use_rec(), temp)
                  Set tempobj = Nothing
               Case "sr_extended_database"
                  Call sr_extended_database(database, Use_rec(), Mid(lne, InStr(lne, ",") + 1))
               Case "sr5310a"
                  Call sr5310a(database, Use_rec())
               Case "sr5305a"
                  Call sr5305a(database, Use_rec())
               Case "TA2829"
                  ExcelFileName = ""
                  Call TA2829(logentry, Use_rec(), Mid(the_file, 2), ExcelFileName)
                  If ExcelFileName <> "" Then
                      If Left(ExcelFileName, 6) = "Error:" Then
                          make_html_item = ExcelFileName
                      Else
                          make_html_item = "<a href=" & DQ & "/prospect_site/excel/" & ExcelFileName & DQ & " target=" & DQ & "/prospect_site/excel/" & ExcelFileName & DQ & " name=" & DQ & "Excel File" & DQ & ">Excel File:&nbsp;" & ExcelFileName & "</a>"
                      End If
                      Exit Function
                  End If
               Case "TA3131"
                  Set tempobj = CreateObject("cka_ta31.ta31")
                  Call tempobj.ta3131(logentry, Use_rec(), Mid(the_file, 2))
                  Set tempobj = Nothing
               Case "TA3133"
                  Set tempobj = CreateObject("cka_ta31.ta31")
                  Call tempobj.ta3133(logentry, Use_rec(), Mid(the_file, 2))
                  Set tempobj = Nothing
               Case "TA3148"
                  Set tempobj = CreateObject("cka_ta31.ta31")
                  Call tempobj.ta3148(logentry, Use_rec(), Mid(the_file, 2))
                  Set tempobj = Nothing
               Case "TA3148A"
                  Set tempobj = CreateObject("cka_ta31.ta31")
                  Call tempobj.ta3148a(logentry, Use_rec(), Mid(the_file, 2))
                  Set tempobj = Nothing
               Case "srjob_cs"
                  Call srjob_cs(logentry, Use_rec())
               Case "srjob_trans"
                  Call srjob_trans(database, Use_rec())
                  job_l = 1
               'Case "srjob_journals"
               '   Call srjob_journals(database, Use_rec())
               'Case "srjob_crinvs"
               '   Call srjob_crinvs(database, Use_rec())
               Case "srjob_scs"
                  Call srjob_scs(logentry, Use_rec())
               Case "sr313" 'mc 17oct00
                  Call SR313(database, use_id, Use_rec()) 'mc 12oct00 - the_file has depnum chr(8) dosfilename
               'Case "sr305"
               '   Call SR305(logentry, use_id)
               Case Else
                  fname = pick.field(Mid(lne, 5), ",", 1)
                  iname = pick.field(Mid(lne, 5), ",", 2)
                  If iname = "" Then iname = use_id
                  ReDim Use_rec(0): Use_rec(0) = iname
                  rderr = d3.d3_readmat(database, Use_rec(), fname)
            End Select
            lne = ""
            GoTo make_html_lne
        End If
        
        If Left(lne, 7) = "||MAYBE" Then 'mc 20apr01 till next one
'||MAYBE,sselect loans with a3 = "|0|",<TH><A HREF="/prospect/asp/buildsel.asp?fn=loans&tn=loans&title=Waste Water Loans&item=a3&ref=|0|">Loans</A>
           temp = pick.field(lne, ",", 2)
           temp = Replace(temp, "|0|", use_id)
           If d3.d3_select_str(logentry, temp) = "" Then lne = "" Else lne = Replace(Mid(lne, pick.Index(lne, ",", 2) + 1), "|0|", use_id)
           GoTo make_html_lne
        End If 'mc 20apr01
        
         islist = False
         pos = pick.Index(lne, "||TABLE", 1)
         If pos = 0 Then
            pos = pick.Index(lne, "||ALIST", 1)
            If pos = 0 Then GoTo make_html_next_bar 'no list or table in this template
            islist = True
         End If
   
         table_lne = Mid(lne, pos + 10)
         table_lne = pick.extract(table_lne, 1, 0, 0)
         If islist Then
            tradd = pick.field(table_lne, "|", 1)
         Else
            tradd = "<" & pick.field(table_lne, "<", 2)
         End If
         table_lne = Mid(table_lne, Len(tradd) + 1)
         
         temp = Mid(lne, pos + 7, 3) 'mc 2jun99 to next one
         If temp = "SEL" Then
            gIds_sentence = lines(j + 1)
            lines(j + 1) = ""
            gIds_sentence = Replace(gIds_sentence, "|0|", use_id)
         Else
            gIds_sentence = ""
            If islist Then
               tradd = Mid(lne, pos + 7, 6) 'mc 19may99
               number_values = 0
               testcol = 1
            Else
               If Left(temp, 1) = "A" Then
                  temp = Mid(temp, 2)
                  If CInt(temp) > UBound(Use_rec) Then
                     number_values = 0
                  Else
                     number_values = pick.DCount(Use_rec(CInt(temp)), Chr(253))
                  End If
               Else
                  number_values = CInt(Mid(lne, pos + 7, 3)) 'mc 19may99
               End If
               testcol = 1
               If Left(tradd, 1) = "!" Then
                  testcol = CInt(Mid(tradd, 2, 2)) 'have !02 means test on column 2 for null
                  tradd = Mid(tradd, 4)
               End If
            End If 'mc 6may99
         End If
         lne = "" 'mc 6may99
         Call make_tds(table_lne, the_tds(), numcols, add_to_total(), check(), nvpos(), ub_totals, nvs(), wants())
         ReDim totals(ub_totals): ReDim save_totals(3, 20) 'mc 14jul99
         ReDim col_convs(numcols): ReDim previous(numcols)
         For num_items = 1 To UBound(previous) 'mc 22jul99
            previous(num_items) = Chr(8)   'mc 22jul99 'so can know when first time
         Next num_items  'mc 22jul99
         If gIds_sentence <> "" Then
            dbname = pick.field(gIds_sentence, ",", 1)
            selfilename = pick.field(gIds_sentence, ",", 2)
            gIds_sentence = Mid(gIds_sentence, pick.Index(gIds_sentence, ",", 2) + 1)
            If dbname <> "" Then
               total_items = d3.msa_select(dbname, gIds_sentence, mylist(), pick_cnt, 0, 0)
            Else
               total_items = d3.d3_select(logentry, gIds_sentence, mylist(), pick_cnt, 0, 0)
            End If
            loop_size = total_items - 1 'mc 23jun99
            lne = tradd 'mc 26may99 "<TR>"
            If loop_size > -1 Then Call make_html_table(logentry, mylist(), num_items + 1, numcols, selfilename, lne, -1, tradd, 1, the_tds(), totals(), save_totals(), col_convs(), add_to_total(), check(), nvpos(), previous(), nvs(), wants(), -1, "", , , , , , mongol)
         Else
            Call make_html_table(logentry, Use_rec(), 1, numcols, the_file, lne, number_values, tradd, testcol, the_tds(), totals(), save_totals(), col_convs(), add_to_total(), check(), nvpos(), previous(), nvs(), wants(), -1, "", 0, "", "", "0", job_l, mongol)
         End If
         GoTo make_html_lne
        
make_html_next_bar:
         pos_bar = pick.Index(lne, "|", 1)
         
         If pos_bar <> 0 Then
             want = pick.field(lne, "|", 2)
             
             what_to_do = Left(want, 1)
                         
             If what_to_do = "" Then GoTo make_html_lne
             wantarr = Split(want, ",", -1, vbBinaryCompare)
             ReDim Preserve wantarr(5)
             datum = make_html_what(logentry, CInt(how), use_id, datum_id, what_to_do, want, wantarr(), the_file, Use_rec(), conversion, html_link, 0, lines(), j) 'mc 4jan02
             
             Select Case what_to_do
                  Case "-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
                        
                        select_field = InStr(lne, "id=""sselect") ' sr14june99
                        If select_field > 0 Then
                          idcnt = idcnt + 1
                          If idcnt Mod 2 Then
                          lneA = Right(lne, Len(lne) - (select_field + 3))
                          gIds_sentence = pick.field(lneA, ",", 1)
                          lne = lne & get_ids(logentry, gIds_sentence, "<OPTION VALUE=""", vbLf & "<OPTION VALUE=""", """>")
                          End If
                                                
                        End If
                         
again:
                          If pick.Index(datum, Chr$(254) & Chr$(254), 1) Then
                             datum = Replace(datum, Chr$(254) & Chr$(254), Chr$(254), , , vbBinaryCompare) ' remove null attrs
                             GoTo again
                          End If
                          datum = Replace(datum, Chr$(254), "<BR>", , , vbBinaryCompare) 'mc for MEMO.STATS
                          pos_bar2 = pick.Index(lne, "|", 2)
                          If pos_bar2 = 0 Then pos_bar2 = pos_bar + 1 ' in case leave off second |
                          lne = Left(lne, pos_bar - 1) & datum & Mid(lne, pos_bar2 + 1)
                   Case Else: GoTo make_html_lne 'this can occur if the id or any data has a | in it eg filing
             End Select
             GoTo make_html_next_bar
          End If
make_html_lne:
          If loopnum <> 0 Then
             lines(j - 1) = lines(j - 1) & vbCrLf & lne
             Return
          Else
             lines(j) = lne
          End If
    Next j

     If action = "4" Or action = "5" Then
        datum = lines(0)
        If Left(datum, 7) = "@@INPUT" Then
           If Mid(datum, 8, 1) = "@" Then
              txt_id = "input_controls.txt"
              datum = Mid(datum, 10)
           Else
              txt_id = "input_controls" & Mid(datum, 8, 1) & ".txt"
              datum = Mid(datum, 11)
           End If
           exists = d3.ReadDosFile(template_path & "\" & txt_id, IREC) 'mco 13feb02
           exists = d3.ReadDosFile(template_path & "\input_posted_form.txt", posted_form) 'mco 6mar02
           posted_form = Replace(posted_form, "@@FILE@@", the_file) 'mc 10apr00
           posted_form = Replace(posted_form, "@@TEMPLATE@@", stemplate) 'mc 10apr00
           posted_form = Replace(posted_form, "@@PREFIX@@", prefix) 'mc 21oct00
           posted_form = Replace(posted_form, "@@SEARCH@@", search) 'mc 21oct00
           posted_form = Replace(posted_form, "@@TRANSFILE@@", trans_file)
           posted_form = Replace(posted_form, "@@no_update_delete@@", no_update_delete)
           posted_form = Replace(posted_form, "@@mainfile@@", mainfile)
           posted_form = Replace(posted_form, "@@subfile@@", subfile)
           posted_form = Replace(posted_form, "@@defaulting@@", defaulting)
           posted_form = Replace(posted_form, "@@printdoc@@", printdoc)
           posted_form = Replace(posted_form, "@@mergefile@@", mergefile)
           posted_form = Replace(posted_form, "@@docname@@", docname)
       
            If no_update = "" Then no_update = no_update_delete
        End If

        If Left(datum, 1) = "=" Then 'mc 21oct00
           prefix = pick.field(datum, "=", 2) 'mc 21oct00
           datum = Mid(datum, Len(prefix) + 3) 'mc 21oct00
           temp = Replace(IREC, "|0|", Mid(use_id, Len(prefix) + 1)) 'mc 210ct00
           posted_form = Replace(posted_form, "|0|", Mid(use_id, Len(prefix) + 1))
        Else 'mc 210ct00
           temp = Replace(IREC, "|0|", use_id) 'mc 210ct00
           posted_form = Replace(posted_form, "|0|", use_id)
           If Left(datum, 6) = "&GLLEV" Then
              txt_id = Right(the_file, 1)
              workpath = Left(the_file, (InStr(1, the_file, ".mdb", vbBinaryCompare) + 3))
              tbl_name = workpath & "\Levels"
              If d3.d3_readstr("", transrec, tbl_name, txt_id) = 0 Then
                 datum = pick.extract(transrec, 1, 0, 0)
              End If
           End If
        End If 'mc 21oct00
        temp = Replace(temp, "@@FILEHEAD@@", datum) 'mc 10apr00
        lines(0) = temp
     End If
    
     item_rec = Join(lines, vbCrLf)
    
If no_update_delete = "9" And subfile <> "" Then                'sv 15 mar 02
    sfile = subfile                                             'sv 15 mar 02
ElseIf trans_file <> "" And no_update_delete <> "9" Then        'sv 15 mar 02
    sfile = trans_file                                          'sv 15 mar 02
End If                                                          'sv 15 mar 02

If sfile <> "" Then
    pos = InStr(1, sfile, ".mdb", 1)
    If pos <> 0 Then
        dbname = Left(sfile, pos + 3)
        sfile = Mid(sfile, pos + 5)
        total_items = d3.msa_select(dbname, "Select * from " & sfile & " where id = '" & use_id & "'", Trans_rec(), pick_cnt, 0, 0, 1, , Chr(9))
        transrec = Join(Trans_rec, Chr(8))        'sv 3 jan 02
    Else
        total_items = d3.d3_readstr(database, transrec, trans_file, use_id) 'sv 3 jan 02
        numcols = pick.DCount(transrec, Chr(254))
        numrows = pick.DCount(pick.extract(transrec, 1, 0, 0), Chr(253))
        row = 0                                              'sv 3 jan 02
        For Nn = 1 To numrows                                'sv 3 jan 02
            ReDim Preserve Trans_rec(row)                     'sv 3 jan 02
            Trans_rec(row) = pick.extract(transrec, 1, Nn, 0) 'sv 3 jan 02
            For Cc = 2 To numcols                       'sv 3 jan 02
                Trans_rec(row) = Trans_rec(row) & Chr(9) & pick.extract(transrec, Cc, row + 1, 0) 'sv 3 jan 02
            Next Cc                  'sv 3 jan 02
            row = row + 1            'sv 3 jan 02
        Next Nn                     'sv 3 jan 02
    End If
    transrec = Join(Trans_rec, Chr(8))        'sv 3 jan 02
Else
    transrec = ""
End If

     If action = "4" Or action = "5" Then
        If UBound(Use_rec) > 0 Then
           before = Use_rec(1)
           For k = 2 To UBound(Use_rec)
              before = before & Chr(8) & Use_rec(k) 'mc 02feb02
           Next k
        Else
           before = "" 'make before image of record to pass back
        End If
        posted_form = Replace(posted_form, "@@BEFORE@@", before)
        posted_form = Replace(posted_form, "@@PREFIX@@", prefix)
        posted_form = Replace(posted_form, "@@TRANSREC@@", transrec) 'sv 3 jan 02
        item_rec = posted_form & item_rec
     End If
     
     item_rec = Replace(item_rec, "@@PICKFILE@@", the_file) 'gen.l can have year suffixed
     If (the_file = "" And use_id = "") Or action = "4" Or action = "5" Then
        If ExcelFileName = "" Then
            make_html_item = item_not_found & item_rec
        Else
            make_html_item = item_not_found & item_rec & "<BR>" & vbCrLf & "<a href=" & DQ & "/prospect_site/excel/" & ExcelFileName & DQ & " target=" & DQ & "/prospect_site/excel/" & ExcelFileName & DQ & " name=" & DQ & "Excel File" & DQ & ">Excel File:" & ExcelFileName & "</a>"
        End If
     Else
        If action = "6" Then
           make_html_item = item_not_found & item_rec  'eft_mail
        Else
           make_html_item = item_not_found & make_body(1, navbar) & item_rec  'mc 04aug99
        End If
     End If
     
End Function

Public Sub make_html_table(logentry As String, uselist() As String, value_count As Long, numcols As Integer, the_file As String, Crec As String, number_values As Integer, tradd As String, testcol As Integer, the_tds() As String, totals() As Currency, save_totals() As Currency, col_convs() As String, add_to_total() As Integer, check() As Boolean, nvpos() As Integer, previous() As String, nvs() As String, wants() As String, use_excel As Long, excel_name As String, Optional code_attr As Integer = 0, Optional client_id As String = "", Optional usehds As String = "", Optional want_excel As String = "0", Optional job_l As Integer = 0, Optional mongol As Integer = 0)

'   value_count :   Number of rows to put on the page
'   numcols     :   Number of columns (or rather |...| pairs) in the table row
'   the_file    :   Name of pick file to use (eg gen.l)
'   the_rec()   :   Attribute data for each item
'   crec        :   Full contents of template file
'   number_values   :
'   tradd       :   TR tag to use for each additional row in the table
'   testcol     :
'   the_tds()   :   All the <TD> tags in the table row, stripped from the template by make_tds
'   totals()    :
'   save_totals()       :
'   col_convs() :
'   add_to_total()      :
'   check()     :
'   nvpos()     :
'   previous()  :

Dim kk As Integer, want As String, what_to_do As String, datum As String
Dim conversion As String, html_link As String, datum_id_converted As String
Dim temp As String, maxvals As Integer, vv As Integer, temp2 As String, datum_id As String
Dim found_something As Boolean, Ww As Integer, Yr As Integer, yrstr As String
Dim xtra_for_link As String, nv As String, nv_adj As Integer, nv_temp As String
Dim the_td As String, temp_sep As String, linkid As String, the_drive As String
Dim the_td_pos As Integer, rderr As Integer, newrow As String
Dim maxk As Integer, the_val As Integer, dte As String
Dim use_trans_info() As String, Mm As Integer, pos As Integer
Dim linkfile As String, linktemplate As String, attr As Integer
Dim Tt As Integer, grand As String  'mc6jul99
Dim tempcur As Currency, temparr() As String, addvals() As String
Dim the_rest As Integer, temp3 As String, prefix As String
Dim expos As Integer
Dim Sheet As String
'Dim Excel As Excel.Application
'Dim ExcelBook As Excel.Workbook
'Dim ExcelSheet As Excel.WorkSheet

Dim the_rec() As String, num_items As Long 'mc 29sep00
Dim wantarr() As String
Dim g_dates() As String
ReDim g_dates(10, 0)
Dim want_excel_name As String

Dim fso, textfile, database As String, dummy() As String 'mc 4jan02

     database = pick.extract(logentry, 2, 0, 0)
     want_excel_name = excel_name
     
     If number_values <> -1 Then
        ReDim the_rec(UBound(uselist))
        For num_items = 0 To UBound(uselist)
            the_rec(num_items) = uselist(num_items)
        Next num_items
        GoTo make_html_table_next_value 'mc 29sep00
     End If
     
     Select Case want_excel
      Case "1"
        excel_name = d3.rtf_open(logentry, fso, textfile, ".asp", "", False, want_excel_name)
        temp = "<TABLE cellspacing=1 cellpadding=1 border=1 WIDTH=95%><TR CLASS=""top"">" & usehds
        textfile.WriteLine (temp)
      Case "2"
        excel_name = d3.rtf_open(logentry, fso, textfile, ".rtf", "", False, want_excel_name)
        textfile.WriteLine (Replace(usehds, "<TH>", vbTab) & "\par ")
      'Case "1?"
      '  On Error GoTo Err_Excelopen
      '  Set Excel = New Excel.Application
      '  If want_excel <> "1" Then
      '     Crec = Crec & "Excel failed to load. " & want_excel
      '     On Error GoTo 0
      '     Exit Sub
      '  End If
      '  Set ExcelBook = Excel.Workbooks.Add
      '  Set ExcelSheet = Excel.Worksheets.Add
      '  temparr = Split(hds, "|")
      '  ReDim Preserve temparr(numcols)
      '  For Kk = 0 To numcols
      '     ExcelSheet.Application.Cells(1, Kk + 1).Value = temparr(Kk)
      '  Next Kk
      '  'ExcelSheet.Application.Visible = True
      '  On Error GoTo 0
     End Select
     
     For num_items = 0 To UBound(uselist) 'mc 29sep00
        ReDim the_rec(0) 'mc 29sep00
        the_rec(0) = uselist(num_items) 'mc 29sep00
        rderr = d3.d3_readmat(database, the_rec(), the_file) 'mc 29sep00
        If InStr(1, uselist(num_items), Chr(253), vbBinaryCompare) <> 0 Then 'exploding sort on td.oflow
           temp = pick.field(uselist(num_items), Chr(253), 2)
           the_val = val("&H" & temp) 'convert hex to decimal
           For kk = 1 To UBound(the_rec)
              the_rec(kk) = pick.extract(the_rec(kk), 1, the_val, 0)
           Next kk
        End If
        GoSub make_html_table_next_value 'mc 29sep00
     Next num_items 'mc 29sep00
     
     Select Case want_excel
      Case "1"
         textfile.WriteLine ("</TABLE>")
         textfile.WriteLine ("</BODY>")
         textfile.WriteLine ("</HTML>")
         Set textfile = Nothing
         Set fso = Nothing
      Case "2"
        textfile.WriteLine ("}")
        textfile.Close
        Set textfile = Nothing
        Set fso = Nothing
      'Case "1?"
      '  On Error Resume Next
      '  ExcelSheet.Application.Columns.AutoFit
      '  ExcelSheet.Application.Rows.AutoFit
      '  ExcelSheet.Application.Rows.VerticalAlignment = xlTop 'this in case have multiple lines on some cells
      '  For Kk = 1 To numcols
      '     If InStr(the_tds(Kk), "right") Then
      '        ExcelSheet.Application.Columns(Chr(96 + Kk)).HorizontalAlignment = xlRight
      '     End If
      '  Next Kk
      '  ExcelSheet.SaveAs filename:=excel_name, FileFormat:=xlExcel9795
      '  ExcelSheet.Application.Quit
      '  Set ExcelSheet = Nothing
      '  On Error GoTo 0
     End Select
     Exit Sub
             
make_html_table_next_value:
     found_something = False
     newrow = tradd
              
     For kk = 1 To numcols
         want = wants(kk)
         wantarr = Split(want, ",", -1, vbBinaryCompare)
         ReDim Preserve wantarr(5)

         nv = nvs(kk)
         If number_values <> -1 Then
            If Left(nv, 2) = "NT" Or Left(nv, 2) = "NV" Then
               nv_temp = Mid(nv, 3)
               If IsNumeric(nv_temp) Then nv_adj = CInt(nv_temp) Else nv_adj = 0
               wantarr(nvpos(kk) - 1) = CStr(value_count + nv_adj)
            Else
               If Left(nv, 1) = "N" Then
                  If nv = "NB" Then nv = "N"
                  nv_temp = Mid(nv, 2)
                  nv_adj = 0
                  If InStr(1, "*+/-", Left(nv_temp, 1), 0) <> 0 And nv_temp <> "" Then
                     nv_temp = Left(nv_temp, 1) & "VAL" & Format(value_count, "000") & Mid(nv_temp, 2)
                  Else
                     If IsNumeric(nv_temp) Then nv_adj = CInt(nv_temp)
                     nv_temp = CStr(value_count + nv_adj)
                  End If
                  wantarr(nvpos(kk) - 1) = nv_temp
               End If
            End If
        Else
           If Left(nv, 2) = "NT" Or Left(nv, 2) = "NV" Then
               wantarr(nvpos(kk) - 1) = "0" 'mco 21aug01 allowing for adding m/values below
           End If
        End If
                
         what_to_do = Left(wantarr(0), 1)
          
         If Left(wantarr(0), 5) = "TYEAR" Then 'mc13may99 until next one
            If UBound(g_trans_info_array) = 0 Then
               g_trans_info_array(0) = "TRANS.INFO"
               rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
            End If
            Yr = 0: yrstr = ""
            If Left(the_file, 3) = "GEN" Then
                  conversion = Right(the_file, 2)
                  If IsNumeric(conversion) Then 'is year eg 98 97
                     yrstr = conversion
                     If UBound(g_trans_info_array) >= 140 Then
                        For vv = pick.DCount(g_trans_info_array(140), Chr(253)) To 2 Step -1
                           If yrstr = pick.extract(g_trans_info_array(140), 1, vv, 0) Then
                              Yr = pick.DCount(g_trans_info_array(140), Chr(253)) - vv + 1
                              Exit For
                           End If
                      Next vv
                  End If
               End If
            End If
            If g_dates(Yr, 0) = "" Then
               If yrstr <> "" Then
                  ReDim use_trans_info(0): use_trans_info(0) = "TRANS.INFO." & yrstr
                  rderr = d3.d3_readmat(database, use_trans_info(), "DICT TRANS.J")
                  If UBound(use_trans_info) < 33 Then datum = use_trans_info(0) & " does not exist in DICT TRANS.J": GoTo trans_info_error
               Else
                  ReDim use_trans_info(UBound(g_trans_info_array))
                  For Ww = 1 To UBound(g_trans_info_array)
                     use_trans_info(Ww) = g_trans_info_array(Ww)
                  Next Ww
               End If
               If UBound(g_dates, 2) < 25 Then ReDim Preserve g_dates(10, 25)
               g_dates(Yr, 0) = use_trans_info(0)
               Ww = 0
               For vv = 12 To 1 Step -1
                  Ww = Ww + 1
                  dte = pick.date_pick_to_vb(val(pick.extract(use_trans_info(33), 1, vv, 0)))
                  g_dates(Yr, Ww) = Day(dte) & "/" & Month(dte) & "/" & Year(dte)
               Next vv
               Ww = Ww + 1
               dte = pick.date_pick_to_vb(val(use_trans_info(7)))
               g_dates(Yr, Ww) = Day(dte) & "/" & Month(dte) & "/" & Year(dte)
               For vv = pick.DCount(use_trans_info(8), Chr(253)) To 1 Step -1
                  Ww = Ww + 1
                  dte = pick.date_pick_to_vb(val(pick.extract(use_trans_info(8), 1, vv, 0)))
                  g_dates(Yr, Ww) = Day(dte) & "/" & Month(dte) & "/" & Year(dte)
               Next vv
               For vv = pick.DCount(use_trans_info(9), Chr(253)) To 1 Step -1
                  Ww = Ww + 1
                  If UBound(g_dates, 2) < Ww Then ReDim Preserve g_dates(10, Ww)
                  dte = pick.date_pick_to_vb(val(pick.extract(use_trans_info(9), 1, vv, 0)))
                  g_dates(Yr, Ww) = Day(dte) & "/" & Month(dte) & "/" & Year(dte)
               Next vv
            End If
            conversion = Mid(wantarr(0), 6)
            If conversion = "" Or Not (IsNumeric(conversion)) Then Ww = 24 Else Ww = 24 - CInt(conversion) * 12
            datum = g_dates(Yr, Ww + 1 - value_count) '12=this year, 24=last year etc
trans_info_error:
            conversion = ""  'mc13may99
         Else
            datum = make_html_what(logentry, 0, the_rec(0), datum_id, what_to_do, want, wantarr(), the_file, the_rec(), conversion, html_link, job_l, dummy(), 0) 'mc 4jan02
            If Left(the_file, 7) = "chq.rec" Then
               If InStr(conversion, ">") <> 0 Then
                  If Left(datum, 1) = "-" Then datum = ""
               Else
                  If InStr(conversion, "<") <> 0 Then
                     If Left(datum, 1) <> "-" Then datum = "" Else datum = Mid(datum, 2)
                  End If
               End If
            End If
         End If
         
         If datum <> "" And kk = testcol Then found_something = True
         
         If check(kk) Then 'mc 6jul99 till next one
           If previous(kk) <> Chr(8) Then 'mc 22jul99
               If datum <> previous(kk) Then grand = previous(kk) & " SUB-TOTALS": GoSub make_totals
           End If
           previous(kk) = datum 'mc 22jul99
         End If 'mc 6jul99
         
         If add_to_total(kk) <> 0 And found_something Then
            'and found_something added 19may99
            'this is tricky, when doing all values then the last time into this loop all values are being
            'returned null and hence conv_out is not called EXCEPT for the A conversion
            'which will then pick up values from previous row and last two columns which may not be the
            'columns we are adding - LOAN.HTM revealed error
            col_convs(kk) = conversion 'mc 19may99
            If datum <> "" Then
               addvals = Split(datum, "<BR>") 'a table entry may have m/v - these are converted to <BR> - see debtors invoice.txt
               For vv = 0 To UBound(addvals)
                  If IsNumeric(Trim(addvals(vv))) Then totals(kk) = totals(kk) + CCur(Trim(addvals(vv))) 'mc 21aug01
               Next vv
            End If
         End If
         
         If add_to_total(kk) = 2 Then
            datum = CStr(totals(kk)) 'mc 20may99
            If InStr(1, conversion, "MD2", 0) <> 0 Then
                datum = Format(datum, "#.00") 'mc 10jul99
            Else
                If InStr(1, conversion, "dec2", 0) <> 0 Then datum = FormatCurrency(datum, 2)
            End If
         End If
         
         the_td = the_tds(kk)
                
        Select Case what_to_do
              Case "-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
                 If InStr(wantarr(0), "-") <> 0 And what_to_do <> "-" Then
                    temp = ""
                    maxvals = pick.DCount(datum, Chr(254))
                    For vv = 1 To maxvals
                       temp = temp & the_td & pick.extract(datum, vv, 0, 0)
                    Next vv
                 Else
                   If wantarr(5) = "mongol" Or mongol Then 'mco 13dec01
                    temp = the_td & datum 'mco 13dec01
                   Else 'mco 13dec01
                    temparr = Split(datum, Chr(253), -1, vbBinaryCompare)
                    maxvals = UBound(temparr)
                    If maxvals = 0 Then
                       temp = the_td & datum
                    Else
                       temp = ""
                       For vv = 0 To maxvals
                            If temparr(vv) <> "" Then
                               If temp = "" Then
                                  temp = temparr(vv)
                               Else
                                  temp = temp & "</li><li>" & temparr(vv)
                               End If
                            End If
                        Next vv
                        If InStr(temp, "</li><li>") Then temp = "<li>" & temp & "</li>"
                        temp = the_td & temp
                    End If
                   End If 'mco 13dec01
                End If
             Case "T" 'trans_info_this_year
                temp = the_td & datum
             Case "@"
                 xtra_for_link = wantarr(0)
                 xtra_for_link = pick.field(xtra_for_link, "!", 2)
                   
                'rgm 17mar00  If we are looking at 1st attr in creditor/debtor search then ignore the 2nd multivalue (item count returned from by-exp search)
                If (the_file = "creditor" Or the_file = "tdebtor") And Right(wantarr(0), 2) = ",0" Then
                    maxvals = 1
                Else
                    'Count the number of multivalues in this attr. Allows for item id's in multivalues
                    maxvals = pick.DCount(datum, Chr$(253))
                    If the_file = "daily.cash" Then maxvals = pick.DCount(datum, Chr$(254))
                End If
                   
                 temp2 = "": nv_temp = html_link
                 For vv = 1 To maxvals
                    datum_id_converted = pick.extract(datum, 1, vv, 0) 'datum
                    linkid = pick.extract(datum_id, 1, vv, 0) 'datum_id
                    html_link = nv_temp
                    If InStr(html_link, "@@FILE@@") Then
                      If Left(linkid, 3) = "JOB" Then
                         html_link = Replace(html_link, "@@FILE@@", "JOB.L")
                         html_link = Replace(html_link, "@@TEMPLATE@@", "JOB_L")
                      Else
                         If pick.Index(linkid, ".", 2) <> 0 Then
                            html_link = Replace(html_link, "@@FILE@@", "GEN.L")
                            html_link = Replace(html_link, "@@TEMPLATE@@", "GEN_L")
                         Else
                            html_link = Replace(html_link, "@@FILE@@", "CLIENT")
                            html_link = Replace(html_link, "@@TEMPLATE@@", "CLIENT")
                         End If
                      End If
                    End If
                    
                    expos = InStr(1, html_link, "fn=@@", 0)
                    If expos <> 0 Then
                       temp3 = Mid(html_link, expos + 5)
                       If Left(temp3, 4) = "PATH" Then              'sv 20 feb 02
                            pos = InStr(the_file, "\")              'sv 20 feb 02
                            If pos <> 0 Then the_drive = Left(the_file, pos - 1): html_link = Replace(html_link, "@@PATH@@", the_drive)     'sv 20 feb 02
                       Else
                       If Left(temp3, 3) = "&#8" Then temp = Left(temp3, 3): temp3 = Mid(temp3, 4): the_rest = 3 Else temp = "": the_rest = 0
                            attr = CInt(pick.field(temp3, "&", 1)) 'have fn=@@1&tn=@@1&item=a1&ref=,1,N,1,|
                            the_rest = the_rest + Len(CStr(attr)) + 5
                            If attr = 0 Then temp = temp & the_rec(attr) Else temp = temp & pick.extract(the_rec(attr), 1, CInt(value_count), 0)
                            html_link = Left(html_link, expos + 2) & temp & Mid(html_link, expos + the_rest)
                       End If
                    End If
                    
                    'expos = InStr(1, html_link, "fn=@@", 0)
                    'If expos <> 0 Then
                    '   temp3 = Mid(html_link, expos + 5)
                    '   If Left(temp3, 3) = "&#8" Then temp = Left(temp3, 3): temp3 = Mid(temp3, 4): the_rest = 3 Else temp = "": the_rest = 0
                    '   attr = CInt(pick.field(temp3, "&", 1)) 'have fn=@@1&tn=@@1&item=a1&ref=,1,N,1,|
                    '   the_rest = the_rest + Len(CStr(attr)) + 5
                    '   If attr = 0 Then temp = temp & the_rec(attr) Else temp = temp & pick.extract(the_rec(attr), 1, CInt(value_count), 0)
                    '   html_link = Left(html_link, expos + 2) & temp & Mid(html_link, expos + the_rest)
                    'End If
                    
                    expos = InStr(1, html_link, "&parameter=", 0)
                    If expos <> 0 Then
                       temp3 = Mid(html_link, expos + 11)
                       attr = CInt(pick.field(temp3, "&", 1)) '|@,/prospect/asp/bi.asp?fn=&#8&tn=property_install_one&parameter=10&item=,1,N,1|
                       the_rest = Len(attr) + 11
                       If attr = 0 Then temp = the_rec(attr) Else temp = pick.extract(the_rec(attr), 1, CInt(value_count), 0)
                       html_link = Left(html_link, expos + 10) & temp & Mid(html_link, expos + the_rest)
                    End If
                    
                    expos = InStr(1, html_link, "tn=@@", 0)
                    If expos <> 0 Then
                       temp = pick.field(Mid(html_link, expos + 5), "&", 1)
                       If IsNumeric(temp) Then 'have tn=@@ for links to transaction files - see below with linktemplate
                          attr = CInt(temp) 'have fn=@@1&tn=@@1&item=a1&ref=,1,N,1,|
                          If attr = 0 Then temp = the_rec(attr) Else temp = pick.extract(the_rec(attr), 1, CInt(value_count), 0)
                          html_link = Left(html_link, expos + 2) & temp & Mid(html_link, expos + 6)
                       End If
                    End If
                    
                    attr = InStr(1, html_link, "item=@@", 0)
                    If attr = 0 Then
                       attr = InStr(1, html_link, "sn=@@", 0) 'mc 6oct00 allow for sn= fn= tn=
                       If attr <> 0 Then attr = attr + 2
                    Else
                       attr = attr + 4
                    End If
                    If attr <> 0 Then
                       linkid = Left(html_link, attr)
                       temp_sep = pick.field(Mid(html_link, attr + 3), ",", 1) 'have item=@@2;*, ... where * is separator
                       If pick.field(temp_sep, ";", 1) = "N" Then 'special for daily.cash
                          html_link = linkid
                          datum_id_converted = the_rec(vv)
                          linkid = "D" & the_rec(vv) & "D"
                       Else
                          attr = CInt(pick.field(temp_sep, ";", 1))
                          temp_sep = pick.field(temp_sep, ";", 2)
                          html_link = linkid
                          If attr = 0 Then linkid = the_rec(attr) Else linkid = pick.extract(the_rec(attr), 1, CInt(value_count), 0)
                          If temp_sep <> "" Then
                             If Left(temp_sep, 1) = "R" Then
                                linkid = the_rec(0) & Mid(temp_sep, 2) & linkid
                             Else
                                linkid = linkid & temp_sep & the_rec(0)
                             End If
                          End If
                          If Right(linkid, 1) = "=" Then linkid = linkid & pick.extract(datum_id, 1, vv, 0) 'datum_id for where have ?sn=...&hn=,
                       End If
                    End If
                    If code_attr <> 0 Then 'see buildsel.asp
                       linkfile = "": linktemplate = ""
                       Select Case the_rec(code_attr)
                       Case "25", "50"
                          linkfile = "cr.inv": linktemplate = "cr_inv"
                          If the_file = "cr_trans" Then
                             linkid = client_id & "*" & datum_id_converted
                          Else
                             If the_file = "gl_trans" And Left(the_rec(6), 2) = "SI" Then
                                If InStr(html_link, "@@") <> 0 Then linkid = the_rec(5) & "*" & the_rec(9)
                             Else
                                If InStr(1, datum_id, "*", 0) = 0 Then
                                   linkfile = "invoice": linktemplate = linkfile
                                   If the_file = "gl_trans" Then linkid = pick.field(linkid, " ", 2)
                                End If
                             End If
                          End If
                       Case "46", "71"
                          linkfile = "goodsin": linktemplate = "goodsin"
                          linkid = datum_id_converted
                       Case "18", "81"
                          linkfile = "purchase": linktemplate = "purchase"
                          If UBound(the_rec) >= 9 Then
                             linkid = the_rec(9) 'purchase order number
                          Else
                             linkid = pick.field(the_rec(6), " ", 2) 'purchase order number
                          End If
                       Case "19", "80"
                          linkfile = "invoice": linktemplate = "invoice"
                          linkid = pick.field(datum_id_converted, "*", 1)
                       Case "47", "72"
                          linkfile = "goodsret": linktemplate = "goodsret"
                          linkid = datum_id_converted
                       Case "28", "53"
                          linkfile = "cr.credit": linktemplate = "cr_credit"
                          If the_file = "cr_trans" Then
                             linkid = client_id & "*" & datum_id_converted
                          Else
                             If the_file = "gl_trans" And Left(the_rec(6), 2) = "SC" Then
                                If InStr(html_link, "@@") <> 0 Then linkid = the_rec(5) & "*" & the_rec(9)
                             Else
                                If InStr(1, datum_id, "*", 0) = 0 Then linkfile = "credit": linktemplate = linkfile
                             End If
                          End If
                       Case "73", "48"
                          linkfile = "rates": linktemplate = "rates"
                          linkid = datum_id_converted & "*" & client_id
                       Case "30", "55", "27", "52", "51", "26"
                          linkfile = "chq.rec": linktemplate = "chq_rec"
                          If code_attr = 1 Then 'gen.l has CHQ NNN - NARRATIVE
                             linkid = pick.field(datum_id, " ", 2)
                             If linkid = "" Then linkid = datum_id 'field 9 reference just has chq number
                          End If
                       Case "29", "54": linkfile = "issue": linktemplate = linkfile
                       Case "43", "68": linkfile = "returns": linktemplate = linkfile
                       Case "33", "58"
                          linkfile = "journal": linktemplate = linkfile
                          If the_file = "gl_trans" Then linkid = pick.field(the_rec(6), " ", 1)
                       Case "31", "56"
                          If InStr(1, datum_id, "*", 0) = 0 Then
                             linkfile = "dict cash": linktemplate = "cash_deposit"
                          Else
                             linkfile = "cash": linktemplate = linkfile
                             Mm = InStr(datum_id, " DEP ") 'eg S KIRUPANANTHER DEP 2408001 * REC 0220 * REIMBURSE
                             If Mm <> 0 Then
                                linkid = Mid(datum_id, Mm + 5)
                                linkid = pick.field(linkid, " ", 1) & "*" & pick.field(linkid, " ", 4)
                             End If
                          End If
                       Case "64":   linkfile = "plans"  'RGM 18Oct99  64 = building licence
                                    linktemplate = "plans"
                                    'Strip the BL from the front of the item id
                                    linkid = Right(linkid, Len(linkid) - 2)
                                    'There may be a * in the item id, if so remove it
                                    If InStr(linkid, "*") Then
                                        linkid = Left(linkid, InStr(linkid, "*") - 1)
                                    End If
                       Case "39":   linkfile = "plans"  'RGM 18Oct99  39 = building licence cancel
                                    linktemplate = "plans"
                                    'If x*y then creditor, otherwise debtor
                                    If InStr(linkid, "*") Then
                                        'Strip the BL from the front of the item id
                                        linkid = Right(linkid, Len(linkid) - 2)
                                        linkid = Left(linkid, InStr(linkid, "*") - 1)
                                    Else
                                        linkid = Right(linkid, Len(linkid) - 2)
                                        'Remove everything after the "-" to make link
                                        linkid = Left(linkid, InStr(linkid, "-") - 1)
                                    End If
                                    If InStr(linkid, "-CANCEL") Then
                                        'Remove the '-cancel' from the end of the item id
                                        linkid = Left(linkid, Len(linkid) - 7)
                                    End If
                       Case "60":   linkfile = "cash"  'RGM 21Oct99  60 = returned cheque
                                    linktemplate = "cash"
                                    linkid = Right(linkid, Len(linkid) - 1)
                       Case "22", "76", "77", "37", "23", "62": 'RGM 21Oct99  22 = rates charge fix, 76 = rates penalty, 77 = fix charge, 37 = rates rebate
                                    linkfile = "rates"
                                    linktemplate = "rates"
                                    If the_file = "gl_trans" Then
                                       linkid = pick.field(linkid, " ", 1) & "*" & the_rec(5)
                                    Else
                                       linkid = linkid & "*" & client_id
                                    End If
                       Case "21":   linkfile = "cr.inv" 'RGM 25Oct99  21 = recurring creditor invoice
                                    linktemplate = "cr_inv"
                                    linkid = client_id & "*" & linkid
                       Case "36", "61":   linkfile = "chq.rec" 'RGM 25Oct99  36 and 61 = stopped cheque
                                    linktemplate = "chq_rec"
                                    'Strip the S from front of ID number
                                    If the_file = "gl_trans" Then
                                       linkid = pick.field(linkid, " ", 1)
                                    Else
                                       linkid = Right(linkid, Len(linkid) - 1)
                                    End If
                       End Select
                       html_link = Replace(html_link, the_file, linkfile)
                       html_link = Replace(html_link, "@@", linktemplate)
                       If linkfile <> "" Then
                          temp = "<A HREF=""" & html_link & linkid & """" & xtra_for_link & ">" & datum_id_converted & "</a>"
                       Else
                          temp = datum_id_converted
                      End If
                    Else
                       If html_link = "#" Then
                          'empty link used to invoke jscript function
                          prefix = Mid(the_td, InStr(UCase(the_td), "<TD>") + 4)            'sv 05 feb 02
                          temp = "<A HREF=""" & html_link & linkid & """" & " onClick=""GetData('" & prefix & linkid & "')"">" & datum_id_converted & "</a>"    'sv 05 feb 02
                          'temp = "<A HREF=""" & html_link & linkid & """" & " onClick=""GetData('" & linkid & "')"">" & datum_id_converted & "</a>"
                       Else
                           temp = "<A HREF=""" & html_link & linkid & """" & xtra_for_link & ">" & datum_id_converted & "</a>"
                       End If
                    End If
                    
                    ' the_td &
                    If temp2 = "" Then
                       temp2 = temp
                    Else
                        temp2 = temp2 & "</li><li>" & temp
                    End If
                  Next vv
                  If InStr(temp2, "</li><li>") Then temp2 = "<li>" & temp2 & "</li>"
                  temp = the_td & temp2

              Case "<"
                  temp = datum
                  temp = the_td & temp
         End Select

         Select Case want_excel
          Case "0", "1"
             newrow = newrow & temp
             If Right(temp, 1) = ">" Then newrow = newrow & "&nbsp;"
          Case "2"  'print
            If num_items <= use_excel Then newrow = newrow & temp
            temp = Mid(temp, InStr(temp, ">") + 1)
            temp = Replace(temp, "<li>", "")
            If Right(temp, 5) = "</li>" Then temp = Left(temp, Len(temp) - 5)
            temp = Replace(temp, "</li>", vbLf)
            'If want_excel = "1" Then
            '   ExcelSheet.Application.Cells(num_items + 2, Kk).value = temp 'row 1 is for headings
            'Else
            textfile.WriteLine (vbTab & temp)
            If kk = numcols Then textfile.WriteLine ("\par ")
            'End If
         End Select
     Next kk
     If found_something Then
        If Left(the_tds(numcols), 4) = "</I>" Then newrow = newrow & "</I>"
        If use_excel = -1 Or num_items <= use_excel Then
           Crec = Crec & newrow
        End If
        If want_excel = "1" Then
           textfile.WriteLine (Replace(newrow, "&nbsp;", "") & vbCrLf) 'mco 10dec01
        End If
     Else
        If number_values = 0 Then GoTo table_exit
     End If
     
     If number_values <> -1 Then
        value_count = value_count + 1
        If value_count <= number_values Or number_values = 0 Then GoTo make_html_table_next_value
     End If
     
table_exit:
     If number_values <> -1 Then grand = "TOTALS": GoSub make_totals: Exit Sub 'mc 29sep00
     Return 'mc 29sep00
     
'totals and sub-totals
make_totals:
Call make_totals(value_count, grand, totals(), save_totals(), kk, Crec, tradd, the_tds(), add_to_total(), col_convs())
Return

Err_Excelopen:
   want_excel = Err & "-" & Error(Err)
   Resume Next
  
End Sub
Public Sub Class_Initialize()

ReDim g_trans_info_array(0)

End Sub

Public Function get_ids(logentry As String, sentence As String, start As String, separator As String, suffix As String, Optional sumonly As String = "0") As String
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' PURPOSE:
'   Return item id's for items in pick that match the select sentence
'
' AUTHOR:   MCO
' DATE:     unknown
' LAST MOD: 28 Apr 99
' MODS BY:  MCO
'
' INPUTS:
'   sentence    :   Select sentence to retrieve data
'   start       :   Starting HTML text for the combo box
'   separator   :   HTML text to put between (at the start of) each id
'   suffix      :   HTML text to put at the end of each item id
'
' PROCESS:
'   the_ids     :   String containing HTML for combo box
'   mylist()    :   Item id's returned from the select sentence OR access query
'   id          :   Current item id taken from mylist()
'   total_items :   Number of items returned from select / query
'   j           :   Loop counter
'   pick_cnt    :   -No. of items returned (Same as total_items but negative)
'   dbname      :   ACCESS database name
'   field_name  :   ACCESS name of field to retrieve
'   table_name  :   ACCESS table name
'   newsent     :   ACCESS query sentence
'
' OUTPUTS:
'   get_ids     :   Set to final value of the_ids (combo box HTML)
'
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim the_ids As String
Dim mylist() As String
Dim id As String, idlink As String, total_items As Long, j As Long, pick_cnt As Long
Dim is_msa As Integer, dbname As String, field_name As String, table_name As String, newsent As String 'mco 28apr99

is_msa = InStr(sentence, ".mdb\") 'mco 28apr99 - all to next mco28apr99
If is_msa <> 0 Then ' select * from filename
   ' sentence is sselect c:\ckashare\orkh\orkh.mdb\nationality a1,a2|order by xx
   dbname = Left(sentence, is_msa + 3)
   dbname = Mid(dbname, 9) 'remove the sselect
   field_name = pick.field(sentence, " ", 3)
   table_name = Mid(sentence, is_msa + 5): table_name = pick.field(table_name, " ", 1)
   newsent = "select " & field_name & " from " & table_name
   newsent = newsent & pick.field(sentence, "!", 2) 'mco 3oct01 'order by xxx must use ! as | used in templates
   total_items = d3.msa_select(dbname, newsent, mylist(), pick_cnt, 0, 0, 0, CInt(sumonly))
Else  'sselect filename
   newsent = sentence
   total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0, 0, CInt(sumonly)) 'mc 14aug00
End If

If total_items <= 0 Then ReDim mylist(0): mylist(0) = newsent
For j = 0 To total_items - 1
   If InStr(mylist(j), Chr(8)) <> 0 Then
      id = Mid(mylist(j), InStr(mylist(j), Chr(8)) + 1)
      Call pick.sr_change(id, Chr(8), ",")
      If Right(id, 1) = "," Then id = Left(id, Len(id) - 1)
      idlink = pick.field(mylist(j), Chr(8), 1)
   Else
      id = mylist(j)
      idlink = id
   End If
   If j = 0 Then
      the_ids = start & idlink & suffix
   Else
      the_ids = the_ids & separator & idlink & suffix 'the value for link
   End If
   If suffix <> "" Then
      the_ids = the_ids & id 'the value displayed
   End If
Next j

get_ids = the_ids
   
End Function
Public Sub Class_Terminate()

End Sub

Public Function check_user_password(database As String, op_name As String, op_passwd As String) As String
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' PURPOSE:
'   Check user name and password on d3 users file
'   Password is in attr 7 in iconv(password,"UC") format
'
' AUTHOR:   MCO
' DATE:     unknown
' LAST MOD: unknown
' MODS BY:  unknown
'
' INPUTS:
'   op_name     :   Username as entered by user
'   op_passwd   :   Password as entered by user
'
' PROCESS:
'   passwd      :   Password read from database
'   rderr       :   Numerical result code for d3_readstr
'                   0 = success, username found
'
' OUTPUTS:
'   check_user_password :   Result of d3_readstr
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim passwd As String, rderr As Integer

check_user_password = ""
rderr = d3.d3_readstr(database, passwd, "dm,users,", op_name, 7, 0, 0)
If rderr <> 0 Then check_user_password = "Invalid user name": Exit Function
If passwd <> d3.conv_password(op_passwd) Then check_user_password = "Invalid password"
Exit Function

'    This subroutine generates/encrypts-decrypts passwords
'    Enter s/r with operator name in op_name
'    Exit s/r with operator password in op_passwd

'Dim encrypt As String, T1 As String, T2 As String, T3 As String
'Dim x As Integer, length As Integer, c As String, y As Integer, i As Integer
'Dim NEW_PASSWD As String, ii As Integer, char_seq As Integer
'Dim T999 As String

'     encrypt = pick.extract(op_passwd, 1, 2, 0) '' 1=encrypt, 0=decrypt
'     op_passwd = pick.extract(op_passwd, 1, 1, 0)
'
'     rderr = d3.d3_readstr(database,T999, "DICT OPSEC", "t999")
'
'     T1 = pick.extract(T999, 1, 0, 0)
'     T2 = pick.extract(T999, 2, 0, 0)
'     T3 = pick.extract(T999, 3, 1, 0)
'
'     If T3 = "0" Then   '' ===== system generated passwords =====
'        Dim Q(4) As String
'        x = pick.Index(op_name, " ", 1)
'        length = x - 1
'        x = x + 1
'        c = Mid(op_name, x, 1)
'        x = pick.Index(T1, c, 1)
'        c = Mid(op_name, 3, 1)
'        y = pick.Index(T1, c, 1)
'        length = length + x + y
'        If length > 37 Then length = length - 37
'        Q(4) = Mid(T2, length, 1)
'        length = length + (y * x)
'        For i = 1 To 999
'           If length < 37 Then GoTo 20
'           If length > 37 Then length = length - 37
'        Next i
'20:      Q(1) = Mid(T2, length, 1)
'        x = pick.Index(T1, Q(1), 1)
'        x = x + y + length
'        For i = 1 To 999
'           If x < 37 Then GoTo 30
'           If x > 37 Then x = x - 37
'        Next i
'30:      Q(3) = Mid(T2, x, 1)
'        x = x + length
'        If x > 37 Then x = x - 37
'        Q(2) = Mid(T2, x, 1)
'        op_passwd = Q(1) & Q(2) & Q(3) & Q(4)
''
 '    Else     ';' ===== operator specified passwords =====
''
 '       op_passwd = d3.d3_readstr(database,op_passwd, "DICT OPSEC", 6, 0, 0)
 '       length = Len(op_passwd)
 '       NEW_PASSWD = ""
 '       If encrypt = "1" Then
 '          For ii = 1 To length
 '             char_seq = Asc(Mid(op_passwd, ii, 1)) + 100 + CInt(T3)
 '             NEW_PASSWD = NEW_PASSWD & Chr(char_seq)
 '          Next ii
 '       Else
 '          For ii = 1 To length
 '             char_seq = Asc(Mid(op_passwd, ii, 1)) - 100 - CInt(T3)
 '             NEW_PASSWD = NEW_PASSWD & Chr(char_seq)
 '          Next ii
 '       End If
 '       op_passwd = NEW_PASSWD
 '    End If
'
End Function
Public Function make_html_what_datum(summing As Currency, val As Integer, SVAL As Integer, datum As String, want As String) As String

Dim vv As Integer, temp As String, svm As Integer

     If summing = 1 Or summing = 3 Then
        If summing = 3 Then svm = 1 Else svm = 0
        summing = 0
        For vv = 1 To val
             temp = pick.extract(datum, 1, vv, 0)
             If IsNumeric(temp) Then summing = summing + CCur(temp)
        Next vv
        If svm = 1 And val <> 0 Then summing = CCur(Int(summing / val))
        datum = CStr(summing)
    Else
        datum = pick.extract(datum, 1, val, SVAL)
        If SVAL = 0 And InStr(1, datum, Chr(252), 0) <> 0 And InStr(1, want, "mongol", 0) = 0 Then
           For vv = Len(datum) To 1 Step -1
              If Mid(datum, vv, 1) <> Chr(252) Then Exit For
              datum = Left(datum, Len(datum) - 1)
           Next vv
           Call pick.sr_change(datum, Chr(252), Chr(253)) 'so that MD2 etc will get converted in cka_d3, later change to <br>
        End If
    End If
    make_html_what_datum = datum
                           
End Function

Public Sub make_tds(table_lne As String, the_tds() As String, numcols As Integer, add_to_total() As Integer, check() As Boolean, nvpos() As Integer, ub_totals As Integer, nvs() As String, wants() As String)
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' PURPOSE:
'   Strip all TD tags from the table line, and set up arrays for totals
'
' CALLED BY:
'   ckaiis.make_html
'
' AUTHOR:   MCO
'
' INPUTS:
'   table_lne   :   String from the template for the table row with placeholders for pick data etc
'   the_tds()   :   All of the TD tags from the table row
'   numcols     :   ** INPUT VALUE IRRELEVANT **
'   add_to_total()  :   ** INPUT VALUE IRRELEVANT **
'   check()     :   ** INPUT VALUE IRRELEVANT **
'   nvpos()     :   ** INPUT VALUE IRRELEVANT **
'   ub_totals   :   ** INPUT VALUE IRRELEVANT **
'
' PROCESS:
'   k           :   Counts from 2 to 99 step 2 (allowing up to 50 columns???)
'   want        :   Everything between the sets of | chars in template line (ie. What to put in that column)
'   what_to_do  :   The 1,1,1 part stripped from the above
'   the_td      :   The TD tag stripped from the table line
'   the_td_pos  :   Where to look for the TD (depends on what is found in what_to_do)
'   nv          :   The next value for what to do
'
' OUTPUTS:
'   numcols     :   The number of |...| pairs in the line (NOT  columns! - can have more than one thing in a column)
'   add_to_total()  :   Empty array of (numcols) elements
'   check()     :   Array of (numcols) binary elements, set to TRUE if NB found in that |...| pair
'   nvpos()     :   The position in the line to find the start of each 1,1,1 part in the |...| pair
'   ub_totals   :   Set to value of numcols if column contains a NT or NV
'
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim k As Integer, want As String, what_to_do As String, the_td As String, the_td_pos As Integer
Dim nv As String

   numcols = 0: ub_totals = 0 'mco 18oct00 if more than on table on a page and first had totals but second did not, then second got totals - this fixes problem
   For k = 2 To 99 Step 2
      
        want = pick.field(table_lne, "|", k) 'Get everything up to the next | character
         
        what_to_do = Left(want, 1)
        If what_to_do = "" Then Exit For
        numcols = numcols + 1
        
        ReDim Preserve wants(numcols): wants(numcols) = want 'mco 14nov00
                
        ReDim Preserve add_to_total(numcols)
        ReDim Preserve check(numcols)
        ReDim Preserve nvpos(numcols)
        add_to_total(numcols) = 0: check(numcols) = False
        If what_to_do = "@" Then nvpos(numcols) = 4 Else nvpos(numcols) = 2
        nv = pick.field(want, ",", nvpos(numcols))
        'If there is not an N in the first position, check the second and third
        If Left(nv, 1) <> "N" Then
           nvpos(numcols) = nvpos(numcols) + 1
           nv = pick.field(want, ",", nvpos(numcols))
           If Left(nv, 1) <> "N" Then
              nvpos(numcols) = nvpos(numcols) - 2
              nv = pick.field(want, ",", nvpos(numcols))
           End If
        End If
        Select Case Left(nv, 2)
           Case "NB":  check(numcols) = True
           Case "NT": add_to_total(numcols) = 1: ub_totals = numcols 'mc 14jul99
           Case "NV": add_to_total(numcols) = 2: ub_totals = numcols 'mc 14jul99
        End Select

        If k <> 2 Then
           the_td = Mid(table_lne, pick.Index(table_lne, "|", k - 2) + 1)
        Else
           the_td = pick.field(table_lne, "|", 1)
           If Len(the_td) <> 0 Then
              the_td_pos = InStr(the_td, "<td")
              If the_td_pos > 0 Then the_td = Right(the_td, Len(the_td) - (the_td_pos - 1))
           End If
        End If
                 
        the_td = pick.field(the_td, "|", 1)
        ReDim Preserve the_tds(numcols): the_tds(numcols) = the_td
        
        ReDim Preserve nvs(numcols): nvs(numcols) = pick.field(wants(numcols), ",", nvpos(numcols)) 'mco 14nov00
        
   Next k
     
End Sub


Public Sub default_item(database As String, save_item_rec As String, the_file As String, stemplate As String, item As Boolean)

Dim Use_rec() As String, j As Integer, conv As String, fname As String, pfx As String, max As Integer
Dim rderr As Integer, more As String, attr As String, val As String, SVAL As String, fld As String, morehead As String
Dim lne As String, k As Integer, xattr As String, svms() As String

     max = pick.ccount(stemplate, "_", 0)
     ReDim Use_rec(0): Use_rec(0) = "@D|" & the_file & "|" & pick.field(stemplate, "_", max + 1)
     rderr = d3.d3_readmat(database, Use_rec(), "SCROLL.KEYS")
     If rderr <> 0 Then
        ReDim Preserve Use_rec(1)
        Use_rec(1) = "a1" & Chr(252) & Chr(252) & "1"
        If item Then
           save_item_rec = Replace(save_item_rec, "@@MESSAGE@@", "template " & stemplate & " missing - using this as default" & Use_rec(0))
        Else
           save_item_rec = Replace(save_item_rec, "@@MESSAGE@@", "template " & stemplate & "_table missing - using this as default")
        End If
     Else
        save_item_rec = Replace(save_item_rec, "@@MESSAGE@@", "")
     End If
     
     save_item_rec = Replace(save_item_rec, "@@MISSINGHEAD@@", the_file) 'mc 24aug00 + all pick.sr_change altered to use replace in this procedure
        
     If item Then
        save_item_rec = Replace(save_item_rec, "@@MISSINGFILE@@", the_file)
     Else
        save_item_rec = Replace(save_item_rec, "@@MISSINGFILE@@", the_file)
        save_item_rec = Replace(save_item_rec, "@@MISSINGTEMPLATE@@", stemplate)
     End If
'item adding
'<TR>
'<TD CLASS="mm">
'<B>A4</B><TD> |4,0,0|
'table adding
'<TH>A0
'and
'<TD>|1,0,0|<TD>|2,0,0|
     
     more = ""
     morehead = "<TH>Id" & vbCrLf
     max = UBound(Use_rec)
     If Not (item) And max > 10 Then max = 10
     For j = 2 To max
        svms = Split(Use_rec(j), Chr(252), -1, vbBinaryCompare)
        ReDim Preserve svms(36)
        attr = svms(2)
        If attr = "done" Then GoTo miss_j
        'If attr = "" Or attr = "0" Then GoTo miss_j
        val = svms(3)
        If val = "" Then val = "0"
        SVAL = svms(4)
        If SVAL = "" Then SVAL = "0"
        lne = svms(36)
        pfx = svms(6)
        xattr = svms(35)
        If xattr = "" Or xattr = "0" Then xattr = "1"
        fname = svms(5): If fname <> "" Then fname = "T" & fname & ";" & xattr
        conv = svms(8)
        If fname <> "" Then fname = fname & "~" & conv Else fname = conv
        fld = svms(0)
        If item Then
           more = more & "<TR>" & vbCrLf & "<TD CLASS=""mm"">" & "<B>" & fld & "</B><TD>"
           If attr <> "" Then more = more & "|" & attr & "," & val & "," & SVAL & ",," & pfx & "," & fname & "|"
           For k = j + 1 To max
              If Left(pick.extract(Use_rec(k), 1, 1, 37), 1) = "P" Then Exit For
              If pick.extract(Use_rec(k), 1, 1, 37) = lne Then
                 attr = pick.extract(Use_rec(k), 1, 1, 3)
                 Use_rec(k) = pick.Replace(Use_rec(k), 1, 1, 3, "done") 'so will get ignored n j loop
                 val = pick.extract(Use_rec(k), 1, 1, 4)
                 If val = "" Then val = "0"
                 SVAL = pick.extract(Use_rec(k), 1, 1, 5)
                 If SVAL = "" Then SVAL = "0"
                 pfx = pick.extract(Use_rec(k), 1, 1, 7)
                 xattr = pick.extract(Use_rec(k), 1, 1, 36)
                 If xattr = "" Or xattr = "0" Then xattr = "1"
                 fname = pick.extract(Use_rec(k), 1, 1, 6): If fname <> "" Then fname = "T" & fname & ";" & xattr
                 conv = pick.extract(Use_rec(k), 1, 1, 9)
                 If fname <> "" Then fname = fname & "~" & conv Else fname = conv
                 fld = pick.extract(Use_rec(k), 1, 1, 1)
                 more = more & "<TD CLASS=""mm""><B>" & fld & "</B><TD>"
                 If attr <> "" Then more = more & "|" & attr & "," & val & "," & SVAL & ",," & pfx & "," & fname & "|"
              End If
miss_k:
           Next k
           more = more & vbCrLf
        Else
           morehead = morehead & "<TH>" & fld & vbCrLf
           more = more & "<TD>|" & attr & "," & val & "," & SVAL & ",," & pfx & "," & fname & "|"
        End If
miss_j:
     Next j
     save_item_rec = Replace(save_item_rec, "@@MORE@@", more)
     If Not (item) Then
        save_item_rec = Replace(save_item_rec, "@@MOREHEAD@@", morehead)
     End If


End Sub


Public Function make_body(one As Boolean, nav As Boolean) As String
Dim navbar As String 'sr 10/12/00

If one Then
   If nav Then navbar = "load_Navbar(0);" Else navbar = ""
   make_body = "<BODY onLoad=""available_width=document.body.clientWidth;available_height=document.body.clientHeight;" & navbar & "pop_up();setupinputbox();"">" & vbCrLf
Else
    If nav Then
      'don't want body tags included
     Else
       make_body = "<BODY onLoad=""preLoad_slider(1);"">" & vbCrLf
     End If
End If

End Function

Public Sub make_totals(value_count As Long, grand As String, totals() As Currency, save_totals() As Currency, kk As Integer, Crec As String, tradd As String, the_tds() As String, add_to_total() As Integer, col_convs() As String)

'totals and sub-totals
Static subcount As Long
Dim Tt As Integer, temp2 As String, tempcur As Currency, conversion As String, temp As String
Dim temp3 As String, posn As Integer, posn2 As Integer

make_totals:
     If value_count = subcount + 1 Or value_count = 2 Then
        If grand = "TOTALS" Then Exit Sub
        GoSub save_totals
        subcount = value_count
        Exit Sub
     End If
     subcount = value_count
     
     If UBound(totals) > 0 Then
        temp2 = "<TD CLASS=""total"">"
        If Left(the_tds(2), 4) = "</I>" Then temp2 = temp2 & "<I class=""input"">"
        Crec = Crec & tradd & temp2 & grand  'Altered rgm 15jul99: start from 2 as td contents not needed just to write "totals"
        For Tt = 2 To UBound(totals)
           If add_to_total(Tt) = 1 Then '<> 0 Then
              temp2 = the_tds(Tt) 'mc 26may99
              posn = pick.Index(temp2, ">", 2) 'mco 19apr01 to next
              If posn = 0 Then
                 posn = pick.Index(temp2, ">", 1)
              End If
              If posn = 0 Then
                 temp2 = "<TD CLASS=""totals"">" 'should never occur
              Else
                 temp2 = Left(temp2, posn - 1) & " CLASS=""totals"">" & Mid(temp2, posn + 1)
              End If 'mco 19apr01
              conversion = col_convs(Tt)
              tempcur = totals(Tt)
              If grand <> "TOTALS" Then tempcur = tempcur - save_totals(kk, Tt)
              Select Case conversion
                 Case "MD2", "MD2>0", "MD2<0": temp = Format(tempcur, "#.00")
                 Case "dec2"
                    If IsNumeric(tempcur) Then temp = FormatCurrency(tempcur, 2)
                 Case Else
                    If Left(conversion, 1) = "A" Or pick.Index(conversion, "MD2", 1) <> 0 Then temp = Format(tempcur, "#.00") Else temp = CStr(tempcur) 'mc 10jul99
              End Select
              
              temp = temp2 & temp 'mc 26may99
           Else
              temp = "<TD CLASS=""totempty"">&nbsp;" 'Td contents unnecessary if nothing to show
           End If
           Crec = Crec & temp
        Next Tt
       
        Crec = Crec & tradd  'Adds extra TR to end of table - remove unless needed for subtotals
        If Left(the_tds(UBound(totals)), 4) = "</I>" Then Crec = Crec & "</I>" 'mco 19apr01
     End If
 
     If grand <> "TOTALS" Then GoSub save_totals
     Exit Sub
     
'save totals
save_totals:
    For Tt = 1 To UBound(totals)
        save_totals(kk, Tt) = totals(Tt)
    Next Tt
    Return
End Sub
Public Function make_options(logentry As String, what As String, lne As String, Optional Default As String = "", Optional d3needed As String = "yes", Optional template_path As String = "", Optional raw As String = "") As String

Dim kk As Integer, Jj As Integer, max As Integer, temp As String, attr As Integer, val As Integer
Dim max_kk As Integer, want As String, Fdate As Integer, TDATE As Integer
Dim min_kk As Integer, Ii As Long
Dim total_items As Long, sentence As String, mylist() As String, pick_cnt As Long, fname As String, rec As String, pfx As String 'mc 04aug99
Dim rd() As String, dbname As String 'mc08jan00
Dim bank_acct As String, Name As String, years As String
Dim database As String, dirs() As String
Dim FullPath As String
'Dim Excel As Excel.Application
'Dim ExcelBook As Excel.Workbook
Dim wshnetwork, oPrinters, am As String, vm As String, svm As String
Dim the_drive As String, txt_name As String, filename As String
Dim textfile, fso, yrid As String, rderr, Yr_Rec As String, LastDay As String
Dim f_months(), the_cnt As Integer, f_month_one As Integer, CurrYr

     am = Chr(254): vm = Chr(253): svm = Chr(252)
     database = pick.extract(logentry, 2, 0, 0)
     
     want = ""
     
     txt_name = lne
     Call pick.sr_611(txt_name, "", 0, "", 0, 0)
     filename = d3.rtf_open(logentry, fso, textfile, ".txt", txt_name, True)
'     If d3.ReadDosFile(filename, temp) Then
'        make_options = temp
'        Exit Function
'     End If
     
     Select Case what
     Case "MEASSET", "MEASSETREAL"
         If UBound(g_trans_info_array) = 0 Then
             g_trans_info_array(0) = "TRANS.INFO"
             kk = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
         End If
         If UBound(g_trans_info_array) < 34 Then ReDim Preserve g_trans_info_array(34)
         If what = "MEASSET" Then
            Fdate = -1: TDATE = 32000
         Else
            temp = pick.extract(g_trans_info_array(34), 1, 9, 0)
            If IsNumeric(temp) Then Fdate = CInt(temp) Else Fdate = -1
            temp = pick.extract(g_trans_info_array(34), 1, 10, 0)
            If IsNumeric(temp) Then TDATE = CInt(temp) Else TDATE = 32000 'Y2055 problem
         End If
         
         Jj = pick.date_vb_to_pick(Date, temp, 0)
         If what <> "MEASSET" And CInt(temp) > TDATE Then temp = CStr(TDATE)
         Jj = pick.locate(temp, g_trans_info_array(8), 1, 1, 0, kk, "AR")
         
         max = pick.DCount(lne, "|")
         want = "<OPTION VALUE=""" & Default & """>" & Default
         For Jj = max To 1 Step -1
            temp = pick.field(lne, "|", Jj)
            If IsNumeric(temp) Then
               attr = CInt(temp): val = 0
            Else
               attr = CInt(pick.field(temp, ",", 1))
               val = CInt(pick.field(temp, ",", 2))
            End If
            max_kk = pick.DCount(g_trans_info_array(attr), vm): min_kk = 1
            If val <> 0 Then max_kk = val: min_kk = val
            For kk = max_kk To min_kk Step -1
               temp = pick.extract(g_trans_info_array(attr), 1, kk, 0)
               If CInt(temp) < Fdate Or CInt(temp) > TDATE Then GoTo next_kk
               temp = pick.date_pick_to_vb(temp)
               temp = Day(temp) & "/" & Month(temp) & "/" & Right(Year(temp), 2)
               If temp <> Default Then
                  want = want & "<OPTION VALUE=""" & temp & """>" & temp
               End If
next_kk:
            Next kk
'<OPTION VALUE="WESTPAC"> WESTPAC
next_jj:
            Next Jj
            make_options = want
            lne = want
     Case "DIR"

            FullPath = lne
            
            lne = ""
            want = Dir(FullPath, vbDirectory) ' Get first file name
            ReDim dirs(0)
            Do While want <> ""
               If InStr(want, ".") = 0 Then 'directory
                  dirs(UBound(dirs)) = want
                  ReDim Preserve dirs(UBound(dirs) + 1)
               Else
                  If Left(want, 1) <> "." Then lne = lne & "<OPTION VALUE=""" & dirs(Jj) & "/" & want & """>" & want
               End If
               want = Dir
            Loop
            For Jj = 0 To UBound(dirs) - 1
               want = Dir(FullPath & dirs(Jj) & "\", 0)   ' Get first file name
               Do While want <> ""
                  If Left(want, 1) <> "." Then 'do not want . and ..
                     lne = lne & "<OPTION VALUE=""" & dirs(Jj) & "/" & want & """>" & want
                     want = Dir
                  End If
               Loop
            Next Jj
            make_options = lne
      Case "SSELECT" 'mc 04 aug99 till next one
      '||OPTIONS|SSELECT|client by a1 with a28 # "1"|2|client|1
         fname = pick.field(lne, "|", 3)
         attr = CInt(pick.field(lne, "|", 4))
         pfx = pick.field(lne, "|", 5)
         If Default <> "" Then
            For Jj = 1 To pick.DCount(Default, vm)
               temp = pick.extract(Default, 1, Jj, 0)
               kk = d3.d3_readstr(database, rec, fname, pfx & temp, attr, 0, 0) 'convert code to description
               Default = pick.Replace(Default, 1, Jj, 0, rec & vbTab & "(" & temp & ")")
            Next Jj
         End If
         Jj = InStr(fname, ".mdb\") 'mc 08jan00 till next one
         If Jj <> 0 Then ' select * from filename
            ' sentence is c:\ckashare\slog\slog.mdb\slog by name
            dbname = Left(fname, Jj + 3)
            sentence = "select " & "*" & " from " & pick.field(lne, "|", 1)
            total_items = d3.msa_select(dbname, sentence, mylist(), pick_cnt, 0, 0)
         Else
            sentence = "sselect " & pick.field(lne, "|", 1)
            total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0)
         End If 'mc 08jan00
         want = ""
         For Ii = 1 To total_items 'UBound(mylist) 'mco 10aug00
            temp = mylist(Ii - 1) 'mco 10aug00
            If attr <> 0 Then
               kk = d3.d3_readstr(database, rec, fname, temp, attr, 0, 0) 'convert code to description
               temp = Mid(temp, Len(pfx) + 1)
               If rec = "" Then rec = temp
               temp = rec & vbTab & "(" & temp & ")"
            End If
            want = want & "<OPTION VALUE=""" & temp & """>" & temp
         Next Ii
         lne = want
make_options_default:
         For kk = 1 To pick.DCount(Default, vm)
            temp = pick.extract(Default, 1, kk, 0)
            lne = Replace(lne, "<OPTION VALUE=""" & temp & """>" & temp, "")
         Next kk
         lne = "<OPTION VALUE=""" & """>" & lne
         For kk = pick.DCount(Default, vm) To 1 Step -1
            temp = pick.extract(Default, 1, kk, 0)
            lne = "<OPTION VALUE=""" & temp & """>" & temp & lne
         Next kk
         make_options = lne
     Case "BANKS"
         If UBound(g_trans_info_array) = 0 Then
             g_trans_info_array(0) = "TRANS.INFO"
             kk = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
         End If
         If UBound(g_trans_info_array) < 31 Then ReDim Preserve g_trans_info_array(31)
         
         bank_acct = g_trans_info_array(4)
         max = pick.DCount(g_trans_info_array(31), vm)
         If raw <> "" Then 'just want the banks and descs for search radio buttons
            If max <> 0 Then bank_acct = bank_acct & vm & g_trans_info_array(31)
            max = pick.DCount(bank_acct, vm)
            lne = "" 'mco 26dec01
            For kk = max To 1 Step -1
               TDATE = d3.d3_readstr(database, Name, "GEN.L", pick.extract(bank_acct, 1, kk, 1), 2, 1)
               If kk <> max Then lne = lne & "," 'mco 26dec01
               lne = lne & Name 'mco 26dec01
               'mco 26dec01 bank_acct = pick.Replace(bank_acct, 1, kk, 2, Name)
            Next kk
            make_options = lne 'mco 26dec01 bank_acct
            Exit Function
         End If
         
         kk = d3.d3_readstr(database, Name, "GEN.L", bank_acct)
         lne = "<OPTION VALUE=""1"">" & pick.extract(Name, 2, 1, 0)
         For kk = 1 To max
            bank_acct = pick.extract(g_trans_info_array(31), 1, kk, 0)
            TDATE = d3.d3_readstr(database, Name, "GEN.L", bank_acct)
            lne = lne & "<OPTION VALUE=""" & (kk + 1) & """>" & pick.extract(Name, 2, 1, 0)
         Next kk
         make_options = lne
     Case "DRCONTS"
         kk = d3.d3_readstr(database, Name, "DICT TDEBTOR", lne)
         lne = "<OPTION VALUE=""" & """>"
         max = pick.DCount(Name, am)
         For kk = 1 To max
            bank_acct = pick.extract(Name, kk, 0, 0)
            If CStr(kk - 1) = Default Then
               lne = "<OPTION VALUE=""" & (kk - 1) & """>" & bank_acct & lne
            Else
               lne = lne & "<OPTION VALUE=""" & (kk - 1) & """>" & bank_acct
            End If
         Next kk
         make_options = lne
     'Case "SHEETS"
     '   On Error GoTo Err_Excelopen
     '   Set Excel = New Excel.Application
     '   Set ExcelBook = Excel.Workbooks.Open(lne)
     '   lne = "<OPTION VALUE=""" & """>"
     '   For Kk = 1 To ExcelBook.Worksheets.Count
     '       lne = lne & "<OPTION VALUE=""" & ExcelBook.Worksheets(Kk).Name & """>" & ExcelBook.Worksheets(Kk).Name
     '   Next Kk
     '   ExcelBook.Close
     '   Set ExcelBook = Nothing
     '   make_options = lne
     '   On Error GoTo 0
     Case "PRINTERS"
        On Error GoTo Err_printers
        lne = "<OPTION VALUE=""" & """>"
        Set wshnetwork = CreateObject("Wscript.Network")
        Set oPrinters = wshnetwork.EnumPrinterConnections
        lne = "<OPTION VALUE=""" & """>"
        For kk = 0 To oPrinters.Count - 1 Step 2
           lne = lne & "<OPTION VALUE=""" & oPrinters.item(kk) & "=" & oPrinters.item(kk + 1) & """>" & oPrinters.item(kk)
        Next kk
        Set oPrinters = Nothing
        Set wshnetwork = Nothing
        make_options = lne
        On Error GoTo 0
     Case "PRINTERSNUM"
        On Error GoTo Err_printers
        lne = "<OPTION VALUE=""" & """>"
        Dim x As Printer
        kk = 0
        For Each x In Printers
          lne = lne & "<OPTION VALUE=""" & kk & """>" & x.DeviceName
          kk = kk + 1
        Next
        make_options = lne
        On Error GoTo 0
     Case "TRCODES"
         kk = d3.d3_readstr(database, Name, "DICT TRANS.J", "TRANS.INFO", 3)
         lne = "<OPTION VALUE=""" & """>"
         max = pick.DCount(Name, vm)
         For kk = 1 To max
            bank_acct = pick.extract(Name, 1, kk, 0)
            If bank_acct <> "" Then
               If kk < 50 Then want = " (credit)" Else want = " (debit)"
               If CStr(kk) = Default Then
                  lne = "<OPTION VALUE=""" & kk & """>" & bank_acct & want & lne
               Else
                  lne = lne & "<OPTION VALUE=""" & kk & """>" & bank_acct & want
               End If
            End If
         Next kk
         make_options = lne
     Case "GLYEARS"
        If d3needed = "no" Then
           the_drive = Left(template_path, InStr(template_path, "\prospect\") - 1) & "/"
           years = d3.gl_years(the_drive & "\ckashare\gen_l\gen_l.mdb")
        Else
           kk = d3.d3_readstr(database, years, "DICT TRANS.J", "TRANS.INFO", 140)
           years = pick.delet(years, 1, 1, 0)
        End If
        If raw <> "" Then make_options = years: Exit Function
        lne = "<OPTION VALUE=""" & """>Current"
        max = pick.DCount(years, vm)
        For kk = max To 1 Step -1
           bank_acct = pick.extract(years, 1, kk, 0)
           lne = lne & "<OPTION VALUE=""" & bank_acct & """>" & bank_acct
        Next kk
        If Default <> "" Then
           temp = "<OPTION VALUE=""" & Default & """>" & Default
           lne = temp & Replace(lne, temp, "")
        End If
        make_options = lne
     Case "GLYEARSMONTHS"             'This Option only for Access G/L
        the_drive = Left(template_path, InStr(template_path, "\prospect\") - 1)
        years = d3.gl_years(the_drive & "\ckashare\gen_l\gen_l.mdb")
        If raw <> "" Then make_options = years: Exit Function
        lne = "<OPTION VALUE=""" & """>Current"
        max = pick.DCount(years, vm)
        For kk = max To 1 Step -1
           bank_acct = pick.extract(years, 1, kk, 0)
           lne = lne & "<OPTION VALUE=""" & bank_acct & """>" & bank_acct
        Next kk
        If Default <> "" Then
           temp = "<OPTION VALUE=""" & Default & """>" & Default
           lne = temp & Replace(lne, temp, "")
        End If

        rderr = d3.d3_readstr("", Yr_Rec, the_drive & "\ckashare\gen_l\gen_l.mdb\CurrentYear", "YEAR")
        yrid = pick.extract(Yr_Rec, 1, 0, 0)
        rderr = d3.d3_readstr("", Yr_Rec, the_drive & "\ckashare\gen_l\gen_l.mdb\monthends", yrid)
        Yr_Rec = Replace(Yr_Rec, am, svm)
        lne = lne & am & "Current" & svm & Yr_Rec
        For kk = max To 1 Step -1
            yrid = pick.extract(years, 1, kk, 0)
            Yr_Rec = ""
            rderr = d3.d3_readstr("", Yr_Rec, the_drive & "\ckashare\gen_l\gen_l.mdb\monthends", yrid)
            Yr_Rec = Replace(Yr_Rec, am, svm)
            lne = lne & vm & yrid & svm & Yr_Rec
        Next kk
        make_options = lne
     Case "GLMONTHENDS"
        If UBound(g_trans_info_array) = 0 Then
            g_trans_info_array(0) = "TRANS.INFO"
            kk = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
        End If
        f_month_one = -1
        the_cnt = 0
        max = pick.DCount(g_trans_info_array(9), vm)
        If max > 11 Then
            For kk = max - 10 To max
                If IsNumeric(pick.extract(g_trans_info_array(9), 1, kk, 0)) Then
                    the_cnt = the_cnt + 1
                    ReDim Preserve f_months(the_cnt)
                    f_months(the_cnt) = CVar(pick.extract(g_trans_info_array(9), 1, kk, 0)) + 24837
                End If
            Next kk
        End If
        max = pick.DCount(g_trans_info_array(8), vm)
        For kk = 1 To max
            If IsNumeric(pick.extract(g_trans_info_array(8), 1, kk, 0)) Then
                the_cnt = the_cnt + 1
                If kk = 2 Then f_month_one = the_cnt
                ReDim Preserve f_months(the_cnt)
                f_months(the_cnt) = CVar(pick.extract(g_trans_info_array(8), 1, kk, 0)) + 24837
            End If
        Next kk
        If IsNumeric(g_trans_info_array(7)) Then
            the_cnt = the_cnt + 1
            ReDim Preserve f_months(the_cnt)
            f_months(the_cnt) = CVar(g_trans_info_array(7)) + 24837
        End If
        max = pick.DCount(g_trans_info_array(33), vm)
        For kk = 1 To max
            If IsNumeric(pick.extract(g_trans_info_array(33), 1, kk, 0)) Then
                the_cnt = the_cnt + 1
                ReDim Preserve f_months(the_cnt)
                f_months(the_cnt) = CVar(pick.extract(g_trans_info_array(33), 1, kk, 0)) + 24837
            End If
        Next kk
'        For k = f_month_one To UBound(f_months)
'            DropDowns.AddItem Format(CDate(f_months(k)), "medium date"), k - f_month_one 'aze 30/7/97,Index of item start from 0, so need change k - f_month_one + 1(VB_EXCEL) to k - f_month_one
'        Next k
        For kk = f_month_one To UBound(f_months)
           bank_acct = Format(CDate(f_months(kk)), "medium date")
           lne = lne & "<OPTION VALUE=""" & bank_acct & """>" & bank_acct
        Next kk
        make_options = lne
     Case "GLBUDGETYEARS"

        If d3needed = "no" Then
           the_drive = Left(template_path, InStr(template_path, "\prospect\") - 1) & "/"
           years = d3.gl_years(the_drive & "\ckashare\gen_l\gen_l.mdb")
           rderr = d3.d3_readstr("", Yr_Rec, the_drive & "\ckashare\gen_l\gen_l.mdb\CurrentYear", "YEAR")
           CurrYr = pick.extract(Yr_Rec, 1, 0, 0)
           max = pick.DCount(years, vm)
           For kk = max To 1 Step -1
              If pick.extract(years, 1, kk, 0) <= CurrYr Then
                years = pick.delet(years, 1, kk, 0)
              End If
           Next kk
        Else
           kk = d3.d3_readstr(database, LastDay, "DICT TRANS.J", "TRANS.INFO", 7)
           CurrYr = Right(Format(CLng(LastDay) + 24837, "d mmm yyyy"), 4)
           years = CStr(CurrYr + 1) & vm & CStr(CurrYr + 2) & vm & CStr(CurrYr + 3) & vm & CStr(CurrYr + 4) & vm & CStr(CurrYr + 5)
        End If
        If raw <> "" Then make_options = years: Exit Function
        lne = ""
        max = pick.DCount(years, vm)
        For kk = 1 To max
           bank_acct = pick.extract(years, 1, kk, 0)
           lne = lne & "<OPTION VALUE=""" & bank_acct & """>" & bank_acct
        Next kk
        If Default <> "" Then
           temp = "<OPTION VALUE=""" & Default & """>" & Default
           lne = temp & Replace(lne, temp, "")
        End If
        make_options = lne
     Case "GENEX"
        Set fso = New Scripting.FileSystemObject
        the_drive = Left(template_path, InStr(template_path, "\prospect\") - 1) & "/"
        filename = the_drive & "\prospect\genexoptions.txt"
        lne = ""
        If fso.FileExists(filename) Then
            Set textfile = fso.OpenTextFile(filename)
            Do While Not textfile.AtEndOfStream
                temp = textfile.ReadLine
                lne = lne & am & temp
            Loop
            textfile.Close
        End If
        make_options = lne
     End Select
   
     filename = d3.rtf_open(logentry, fso, textfile, ".txt", txt_name)
     textfile.WriteLine (lne)
     textfile.Close
     Set textfile = Nothing
     Set fso = Nothing
   
     Exit Function
     
Err_Excelopen:
     make_options = "Error in excel - " & lne
     Exit Function
Err_printers:
     make_options = "Error in printer control wscript.network - " & lne
     Exit Function
     
End Function
Public Sub excel_read(nrec() As String)

Dim x As Object
Dim F_Excelapp As Object
Dim Sheet As String, j As Integer

     On Error GoTo Err_Excelopen
     Set x = CreateObject("Excel.Sheet")
     Set F_Excelapp = x.Application
     F_Excelapp.Visible = False
     'F_Excelapp.WindowState = xlMinimized
     'g_drive not defined - excel_read not used Sheet = g_drive & "\prospect\test.xls" 'usersheet 'mco 15sep00
     F_Excelapp.Workbooks.Open filename:=Sheet
     
     For j = 1 To F_Excelapp.Worksheets.Count
         ReDim Preserve nrec(j)
         nrec(j) = F_Excelapp.Worksheets(j).Name
     Next j
     Exit Sub

Err_Excelopen:
     Exit Sub

End Sub

Public Sub make_excel(nrec() As String, trec As String)

Dim excelapp As Object
Dim j As Integer, Sheet As String, row As Integer, Col As Integer, Txt As String
Dim colcnt As Integer, rowcnt As Integer

     ReDim Preserve nrec(2)
     On Error GoTo Err_Excelopen
     Set excelapp = CreateObject("Excel.Sheet")
     excelapp.Application.Visible = False
     excelapp.Application.Workbooks.Open filename:=nrec(0)
     
     trec = ""
     For j = 1 To excelapp.Worksheets.Count
         nrec(1) = pick.Replace(nrec(1), 1, j, 0, nrec(0))
         Sheet = excelapp.Application.Worksheets(j).Name
         nrec(2) = pick.Replace(nrec(2), 1, j, 0, Sheet)
         trec = trec & vbCrLf & "<TABLE cellspacing=1 cellpadding=1 border=1 WIDTH=95%><TR CLASS=""mm""><TD COLSPAN=""" & Chr(8) & """>" & Sheet
         rowcnt = 0
         For row = 1 To 30000
             colcnt = 0
             trec = trec & "<TR>"
             For Col = 1 To 30000
                Txt = excelapp.Application.Worksheets(Sheet).Cells(row, Col)
                If Txt = "" Then
                   colcnt = colcnt + 1
                   If colcnt >= 10 Then colcnt = 0: trec = Left(trec, Len(trec) - 40): Exit For
                Else
                   colcnt = 0
                End If
                trec = trec & "<TD>" & Txt
             Next Col
             If row = 1 Then Call pick.sr_change(trec, Chr(8), CStr(Col - 11))
             If Col = 10 Then 'so got nothing
                rowcnt = rowcnt + 1
                If rowcnt >= 10 Then trec = Left(trec, Len(trec) - 40): Exit For
             Else
                rowcnt = 0
             End If
         Next row
         trec = trec & "</TABLE>"
     Next j
     excelapp.Application.Workbooks.Close
     excelapp.Application.Quit
     Set excelapp = Nothing
     Exit Sub

Err_Excelopen:
     trec = Err & " -  " & Error(Err)
     Exit Sub

End Sub
Public Function make_page(Page As String, total_pages As Integer, total_items As Long, Crec As String, page_size As Integer, sentence As String, the_file As String, use_file As String, where_is_prospect As String, title As String, hds As String, tds As String, dms As String, code_attr As Integer, NewTemplates As String) As String

Dim ok As Boolean, pos1 As Integer, pos2 As Integer, rderr As String
Dim summary_top As String, summary_bot As String, newpage As String
Dim page_template As String, buttons As String
Dim labels_top As String
Dim buttons_top As String

Dim Templates, TemplateContents As String, filename As String, cnt As Integer
Dim NewPageTemplate As String, NewLabelsTop As String
Dim NewButtonsTop As String, SwapTemplates As Boolean

Call pick.sr_change(sentence, Chr(34), Chr(254))

page_template = "<FORM name =""page_number"" action=""\prospect\asp\next_page.asp""  method=""POST"" Onsubmit=""check()"">"
page_template = page_template & "<input type=hidden name=""page_size"" value=""@@PAGESIZE@@"">"
page_template = page_template & "<input type=hidden name=""page"" value=""@@PAGE@@"">"
page_template = page_template & "<input type=hidden name=""total_pages"" value=""@@TOTALPAGES@@"">"
page_template = page_template & "<input type=hidden name=""total_items"" value=""@@TOTALITEMS@@"">"
page_template = page_template & "<input type=hidden name=""pickfile"" value=""@@PICKFILE@@"">"
page_template = page_template & "<input type=hidden name=""template"" value=""@@TEMPLATE@@"">"
page_template = page_template & "<input type=hidden name=""sentence"" value=""@@SENTENCE@@"">"
page_template = page_template & "<input type=hidden name=""buttons"" value=""@@BUTTONS@@"">"
page_template = page_template & "<input type=hidden name=""want_excel"" value=""0"">"
page_template = page_template & "<input type=hidden name=""title"" value=""@@TITLE@@"">"
page_template = page_template & "<input type=hidden name=""hds"" value=""@@HDS@@"">"
page_template = page_template & "<input type=hidden name=""tds"" value=""@@TDS@@"">"
page_template = page_template & "<input type=hidden name=""dms"" value=""@@DMS@@"">"
page_template = page_template & "<input type=hidden name=""codeattr"" value=""@@CODEATTR@@"">"
page_template = page_template & "@@SUMMARYTABLETOP@@"
page_template = page_template & "@@CREC@@"
page_template = page_template & "@@SUMMARYTABLEBOT@@"
page_template = page_template & "</FORM>"
labels_top = "<TABLE align=center cellspacing=1 border=1 width=95%><TR class=top><TH><a href=""/prospect/asp/menu.asp""><IMG SRC=""/prospect/images/default/explorer/start_up.gif"" BORDER=0 WIDTH=30 HEIGHT=22 ALT=""Prospect Explorer""></a><TH NOWRAP>@@TABLETITLE@@<TH width=40>Items<TH width=40><INPUT TYPE=Text NAME=""TPagesLb1"" READONLY SIZE=5><TH width=30><INPUT TYPE=button name=""TExcel"" value=""Excel""><TH width=30><INPUT TYPE=button name=""TPrint"" value=""Print""></TABLE>"
buttons_top = "<TABLE align=center cellspacing=1 border=1 width=95%><TR class=top><TH><a href=""/prospect/asp/menu.asp""><IMG SRC=""/prospect/images/default/explorer/start_up.gif"" BORDER=0 HEIGHT=22 ALT=""Prospect Explorer""></a><th nowrap>@@TABLETITLE@@<th align=center nowrap>Items<INPUT align=center TYPE=text NAME=""TItems"" size=5 READONLY><th align=center nowrap>Pages<INPUT align=center TYPE=text NAME=""TPages"" size=5 READONLY><th align=centre nowrap><INPUT TYPE=button NAME=""TFirstPage"" Value=""&lt&lt""><INPUT TYPE=button NAME=""TPrevPage"" Value=""&lt""><INPUT TYPE=text NAME=""TPageNum"" size=5 value="""" Onchange=""update(1)""><INPUT TYPE=button NAME=""TNextPage"" Value=""&gt""><INPUT TYPE=button NAME=""TLastPage"" Value=""&gt&gt""><INPUT TYPE=Submit NAME=""TSubmit"" value=""Go""><th align=center><INPUT align=center TYPE=button name=""TExcel"" value=""Excel""><th align=center><INPUT align=center TYPE=button name=""TPrint"" value=""Print""></TABLE>"

If NewTemplates <> "" Then
   NewPageTemplate = "<input type=hidden name=""page_size"" value=""@@PAGESIZE@@"">"
   NewPageTemplate = NewPageTemplate & "<input type=hidden name=""page_num"" value=""@@PAGE@@"">"
   NewPageTemplate = NewPageTemplate & "<input type=hidden name=""total_pages"" value=""@@TOTALPAGES@@"">"
   NewPageTemplate = NewPageTemplate & "<input type=hidden name=""total_items"" value=""@@TOTALITEMS@@"">"
   NewPageTemplate = NewPageTemplate & "<input type=hidden name=""pickfile"" value=""@@PICKFILE@@"">"
   NewPageTemplate = NewPageTemplate & "<input type=hidden name=""template"" value=""@@TEMPLATE@@"">"
   NewPageTemplate = NewPageTemplate & "<input type=hidden name=""sentence"" value=""@@SENTENCE@@"">"
   NewPageTemplate = NewPageTemplate & "<input type=hidden name=""buttons"" value=""@@BUTTONS@@"">"
   NewPageTemplate = NewPageTemplate & "<input type=hidden name=""want_excel"" value=""0"">"
   NewPageTemplate = NewPageTemplate & "<input type=hidden name=""title"" value=""@@TITLE@@"">"
   NewPageTemplate = NewPageTemplate & "<input type=hidden name=""hds"" value=""@@HDS@@"">"
   NewPageTemplate = NewPageTemplate & "<input type=hidden name=""tds"" value=""@@TDS@@"">"
   NewPageTemplate = NewPageTemplate & "<input type=hidden name=""dms"" value=""@@DMS@@"">"
   NewPageTemplate = NewPageTemplate & "@@SUMMARYTABLETOP@@"
   NewPageTemplate = NewPageTemplate & "@@CREC@@"
   NewPageTemplate = NewPageTemplate & "@@SUMMARYTABLEBOT@@"

   NewLabelsTop = "<TABLE align=center WIDTH=95%><TR class=top><TD align=center><B>@@TABLETITLE@@</B><TD align=center>Items&nbsp;<INPUT TYPE=Text NAME=""TPagesLb1"" READONLY SIZE=5><TD align=center><INPUT TYPE=button value=""Sql"" Onclick=""toggle_sql_sentence(document.page_details,document.all.sql);""></TABLE>"
   
   NewButtonsTop = "<TABLE align=center WIDTH=95%>"
   NewButtonsTop = NewButtonsTop & "<TR class=top><TD><B>@@TABLETITLE@@</B>"
   NewButtonsTop = NewButtonsTop & "<TD>Items&nbsp;<INPUT TYPE=Text NAME=""TItems"" SIZE=5 READONLY>"
   NewButtonsTop = NewButtonsTop & "<TD align=center>Pages&nbsp;<INPUT TYPE=Text NAME=""TPages"" SIZE=5 READONLY>"
   NewButtonsTop = NewButtonsTop & "<TD align=center nowrap><INPUT TYPE=button NAME=""TFirstPage"" Value=""&lt&lt"" Onclick=""FirstPage(document.page_details)"">"
   NewButtonsTop = NewButtonsTop & "<INPUT TYPE=button NAME=""TPrevPage""  Value=""&lt"" Onclick=""PrevPage(document.page_details)"">"
   NewButtonsTop = NewButtonsTop & "<INPUT TYPE=Text NAME=""TPageNum"" SIZE=5 MAXLENGTH=5 Onchange=""update(document.page_details,1,this.value)"">"
   NewButtonsTop = NewButtonsTop & "<INPUT TYPE=button NAME=""TNextPage""  Value=""&gt"" Onclick=""NextPage(document.page_details)"">"
   NewButtonsTop = NewButtonsTop & "<INPUT TYPE=button NAME=""TLastPage""  Value=""&gt&gt"" Onclick=""LastPage(document.page_details)"">"
   NewButtonsTop = NewButtonsTop & "<TD nowrap align=center><INPUT TYPE=button NAME=""TSubmit""   value=""Go"" Onclick='check(document.page_details,this.name);'>"
   NewButtonsTop = NewButtonsTop & "<INPUT TYPE=button value=""Sql"" Onclick=""toggle_sql_sentence(document.page_details,document.all.sql);"">"
   NewButtonsTop = NewButtonsTop & "</TABLE>"
   SwapTemplates = True
End If
 
   Call AssignLabels(SwapTemplates, total_pages, total_items, newpage, summary_top, summary_bot, buttons, page_template, labels_top, buttons_top, NewPageTemplate, NewLabelsTop, NewButtonsTop)
    
    Crec = Replace(Crec, "@@" & title & "@@", "")
    summary_top = Replace(summary_top, "@@TABLETITLE@@", title)
    summary_bot = Replace(summary_bot, "@@TABLETITLE@@", title)
    newpage = Replace(newpage, "@@SUMMARYTABLETOP@@", summary_top)
    newpage = Replace(newpage, "@@SUMMARYTABLEBOT@@", summary_bot)
    newpage = Replace(newpage, "@@CREC@@", where_is_prospect & Crec)
    newpage = Replace(newpage, "@@TOTALPAGES@@", CStr(total_pages))
    newpage = Replace(newpage, "@@TOTALITEMS@@", CStr(total_items))
    newpage = Replace(newpage, "@@PAGESIZE@@", CStr(page_size))
    newpage = Replace(newpage, "@@PAGE@@", CStr(Page))
    newpage = Replace(newpage, "@@PICKFILE@@", the_file)
    newpage = Replace(newpage, "@@TEMPLATE@@", use_file)
    newpage = Replace(newpage, "@@SENTENCE@@", CStr(total_items) & "," & sentence)
    newpage = Replace(newpage, "@@BUTTONS@@", buttons)
    newpage = Replace(newpage, "@@TITLE@@", title)
    newpage = Replace(newpage, "@@TDS@@", tds)
    newpage = Replace(newpage, "@@HDS@@", hds)
    newpage = Replace(newpage, "@@DMS@@", dms)
    newpage = Replace(newpage, "@@CODEATTR@@", code_attr)

  make_page = make_body(0, SwapTemplates) & newpage
 
End Function
Private Sub AssignLabels(SwapTemplates As Boolean, total_pages As Integer, total_items As Long, newpage As String, summary_top As String, summary_bot As String, buttons As String, page_template As String, labels_top As String, buttons_top As String, NewPageTemplate As String, NewLabelsTop As String, NewButtonsTop As String)

Dim Btop As String, BBot As String, LTop As String, LBot As String

If SwapTemplates = True Then
   newpage = NewPageTemplate
   Btop = NewButtonsTop
   BBot = Replace(Btop, "NAME=""T", "NAME=""B")
   LTop = NewLabelsTop
   LBot = Replace(LTop, "NAME=""T", "NAME=""B")
Else
   newpage = page_template
   Btop = buttons_top
   BBot = Replace(buttons_top, "NAME=""T", "NAME=""B")
   LTop = labels_top
   LBot = Replace(labels_top, "NAME=""T", "NAME=""B")
End If

If total_pages > 1 Then
  summary_top = Btop
  summary_bot = BBot
  buttons = "all"
 Else
  summary_top = LTop
  If total_items > 17 Then summary_bot = LBot Else summary_bot = ""
  buttons = ""
End If

End Sub




Public Sub sr_extended_database(database As String, nrec() As String, prop_only As String)

Dim Use_rec() As String, j As Integer, fname As String, k As Integer, title As String
Dim rderr As Integer, cnt As Integer, template As String, tds As String, label As String
Dim frec() As String, M As Integer
Dim vms() As String
Dim client_id As String, client_attr As String, clvals As String
     ReDim Use_rec(0): Use_rec(0) = "@FILES"
     rderr = d3.d3_readmat(database, Use_rec(), "DICT PCODES")
     
     client_id = nrec(0)
     
     ReDim nrec(5)
     cnt = 0
     For j = 1 To UBound(Use_rec)
        vms = Split(Use_rec(j), Chr(253), -1, vbBinaryCompare)
        ReDim Preserve vms(4)
        fname = vms(0)
        client_attr = vms(4)
        If prop_only = "1" Then
           If client_attr = "" Then GoTo ignore
           If Not (IsNumeric(client_attr)) Then GoTo ignore
           If d3.d3_readstr(database, clvals, "CLIENT", client_id, CInt(client_attr)) <> 0 Then clvals = ""
           If clvals = "" Then GoTo ignore
           clvals = Replace(clvals, Chr(253), "<BR>")
        End If
        cnt = cnt + 1
        nrec(1) = pick.Replace(nrec(1), 1, cnt, 0, fname) 'filename
        ReDim frec(0): frec(0) = "@DS|" & fname
        rderr = d3.d3_readmat(database, frec(), "SCROLL.KEYS")
        For k = 1 To UBound(frec)
           If k <> 1 Then
              cnt = cnt + 1
              If prop_only = "1" Then
                 nrec(1) = pick.Replace(nrec(1), 1, cnt, 0, fname)
              Else
                 nrec(1) = pick.Replace(nrec(1), 1, cnt, 0, " ")
              End If
           End If
           nrec(5) = pick.Replace(nrec(5), 1, cnt, 0, fname)
           title = pick.extract(frec(k), 1, 2, 0)
           title = Replace(title, "\", "")
           title = Replace(title, "/", "")
           title = Replace(title, "'", "")
           title = Replace(title, """", "")
           title = UCase(title)
           nrec(2) = pick.Replace(nrec(2), 1, cnt, 0, title)
           template = pick.extract(frec(k), 1, 1, 0)
           template = Mid(template, 4)
           template = Replace(template, "|", "_")
           template = Replace(template, ".", "_")
           nrec(3) = pick.Replace(nrec(3), 1, cnt, 0, template)
           If prop_only = "1" Then nrec(4) = pick.Replace(nrec(4), 1, cnt, 0, clvals)
        Next k
ignore:
     Next j

End Sub



Public Sub sr5310a(database As String, nrec() As String)

Dim posn As Integer, max As Integer, i As Integer, job_code As String, xpos As Integer
Dim next_serv_date As String, next_hk As Currency, next_hk_date As Currency, already_used As Integer
Dim tref As String, jpos As Integer, non_periodic As Integer
Dim jrec() As String, Srec() As String, card_no As String, card_rec As String, comp As String
Dim nz As Integer, reading_msg As Integer, more_odos As Currency
Dim more_days As Currency
Dim temp As String, last_odos As Currency, no_of_dates As Integer
Dim past_date As String, last_date As String, past_odos As String, odos_used As String
Dim Days_Used As Currency, odos_per_day As Currency
Dim temp1 As String, temp2 As String

' job card display
        nz = 0
        ReDim jrec(0): jrec(0) = nrec(0)
        posn = d3.d3_readmat(database, jrec(), "JOB.L")
        If UBound(jrec) < 56 Then ReDim Preserve jrec(56)
        no_of_dates = pick.DCount(jrec(54), Chr(253))
        If no_of_dates <= 1 Then reading_msg = 1 Else reading_msg = 0
        temp = pick.extract(jrec(55), 1, 1, 0)
        If IsNumeric(temp) Then last_odos = CCur(temp) Else last_odos = 0
        If reading_msg = 0 Then
           If no_of_dates > 10 Then no_of_dates = 10
           last_date = pick.extract(jrec(54), 1, 1, 0)
           past_date = pick.extract(jrec(54), 1, no_of_dates, 0)
           past_odos = pick.extract(jrec(55), 1, no_of_dates, 0)
           If IsNumeric(last_date) And IsNumeric(past_date) Then
              Days_Used = last_date - past_date
           Else
              reading_msg = 1: GoTo 180
           End If
           If Not IsNumeric(past_odos) Then reading_msg = 1: GoTo 180
           odos_used = last_odos - CCur(past_odos)
           If Days_Used <= 0 Or odos_used <= 0 Then
              reading_msg = 1
           Else
              odos_per_day = odos_used / Days_Used
           End If
        End If
180:
        ReDim Srec(0): Srec(0) = nrec(56)
        If Srec(0) = "" Then Exit Sub
        posn = d3.d3_readmat(database, Srec(), "SERVICE")
        If UBound(Srec) = 0 Then Exit Sub
        If UBound(Srec) < 7 Then ReDim Preserve Srec(7)
        
        posn = d3.d3_readmat(database, nrec(), "SERVICE.JOB")
        ReDim Preserve nrec(22)
        max = pick.DCount(nrec(4), Chr(253))
        For i = max To 1 Step -1
            job_code = pick.extract(nrec(4), 1, i, 0)
            If pick.extract(nrec(5), 1, i, 0) = "" Then nrec(5) = pick.Replace(nrec(5), 1, i, 0, "Unknown")
            xpos = i
            GoSub 4500
            If non_periodic Then
               nrec(21) = pick.Replace(nrec(21), 1, i, 0, "Non periodic service")
            Else
               If reading_msg <> 0 Then
                  If next_hk = 0 Then temp = "" Else temp = CStr(next_hk)
                  nrec(21) = pick.Replace(nrec(21), 1, i, 0, pick.trimm(temp & " " & "nohistory"))
               Else
                  If next_hk_date <> 0 Then nrec(21) = pick.Replace(nrec(21), 1, i, 0, next_hk & " " & pick.date_pick_to_vb(val(next_hk_date)))
               End If
            End If
            nrec(20) = pick.Replace(nrec(20), 1, i, 0, next_serv_date)
            card_no = pick.extract(nrec(13), 1, i, 0)
            If d3.d3_readstr(database, card_rec, "JOB.CARD", card_no) <> 0 Then card_rec = ""
            posn = pick.locate(job_code, card_rec, 3, 1, 0, jpos, "")
            If posn = 0 Then jpos = 0
            comp = pick.extract(card_rec, 15, jpos, 0)
            If comp = "" Then comp = "Y"
            nrec(22) = pick.Replace(nrec(22), 1, i, 0, comp)
            If nz = 0 And IsNumeric(pick.extract(nrec(3), 1, i, 0)) Then
               nrec(1) = pick.Replace(nrec(1), 1, i, 0, pick.extract(nrec(3), 1, i, 0))
            Else
               If pick.extract(nrec(1), 1, i, 0) <> "" Then nrec(1) = pick.Replace(nrec(1), 1, i, 0, pick.date_pick_to_vb(val(pick.extract(nrec(1), 1, i, 0))))
            End If
            If pick.extract(nrec(13), 1, i, 0) = "" Then nrec(13) = pick.Replace(nrec(13), 1, i, 0, " ")
1050:    Next i
          Exit Sub
        
'*************************************************************
' Calculate details of next service and present overide option
'*************************************************************
4500:

     next_serv_date = ""
     next_hk = 0
     next_hk_date = 0
     already_used = 0
     tref = pick.extract(nrec(4), 1, xpos, 0)
     posn = pick.locate(tref, nrec(4), 1, 1, 0, jpos, "")
     If posn = 0 Then jpos = 0
     If jpos <> 0 Then
        If jpos < xpos Then already_used = 1
     End If
     non_periodic = 0
     posn = pick.locate(tref, Srec(4), 1, 1, 0, jpos, "")
     If posn = 0 Then
        non_periodic = 1
        GoTo 4600
     End If
     If already_used = 1 Then GoTo 4600
     
    'Altered 1Oct99 RGM as was causing type mismatch when null returned
    'If IsNumeric(pick.extract(srec(6), 1, jpos, 0)) Then  'And IsNumeric(pick.extract(nrec(6), 1, xpos, 0)) Then
    '    next_serv_date = CStr(CCur(pick.extract(nrec(6), 1, xpos, 0)) + CCur(pick.extract(srec(6), 1, jpos, 0)))
    'Else
    '   next_serv_date = ""
    'End If
     
    temp1 = pick.extract(Srec(6), 1, jpos, 0)
    temp2 = pick.extract(nrec(6), 1, xpos, 0)
    
     If IsNumeric(temp1) And IsNumeric(temp2) Then
        next_serv_date = CStr(CCur(temp2) + CCur(temp1))
     Else
        next_serv_date = ""
     End If
     If IsNumeric(pick.extract(Srec(7), 1, jpos, 0)) And IsNumeric(pick.extract(nrec(7), 1, xpos, 0)) Then
        next_hk = CCur(pick.extract(nrec(7), 1, xpos, 0)) + CCur(pick.extract(Srec(7), 1, jpos, 0))
        If reading_msg = 0 And non_periodic = 0 Then
           more_odos = next_hk - last_odos
           more_days = Int(more_odos / odos_per_day)
           next_hk_date = last_date + more_days
        End If
     End If
     If next_serv_date = "" Then next_hk = 0: next_hk_date = 0
4600:  Return

End Sub

Public Sub srjob_cs(logentry As String, nrec() As String)
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' PURPOSE:
'   Access data needed for job ledger component summary
'
' AUTHOR:   RGM
' DATE:     1 Sept 99
' LAST MOD: 10 Sept 99
' MODS BY:  RGM
'
' INPUTS:
'   nrec()  :   Current item ID as nrec(0)
'
' PROCESS:
'   mylist()    :   Item ID's for all items matching select sentence
'   job_rec()   :   All attribute data for current item
'   pick_cnt    :   No. of items returned (-ve)
'   job_???     :   Attributes we are interested in, extracted from job_rec()
'   i           :   Loop counter
'
' OUTPUTS:
'   nrec()  :   Relevant attribute data for all matched items as m/values
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim i As Integer
Dim mylist() As String, job_rec As String, job_id As String, job_desc As String, job_budg As String, job_bal As String, job_comm As String
Dim pick_cnt As Long, total_items As Long
Dim database As String, cnt As Integer

     database = pick.extract(logentry, 2, 0, 0)
     
    'Select the items that we want for the component summary
    total_items = d3.d3_select(logentry, "sselect job.l by a0 with a0 =" & Chr(34) & nrec(0) & ".]" & Chr(34), mylist(), pick_cnt, 0, 0)
    
    'Set nrec to the number of values to pass back
    ReDim Preserve nrec(5)
    
    cnt = 0
    For i = 0 To total_items - 1
      job_id = mylist(i)
      If pick.Index(job_id, ".", 2) = 0 Then
        cnt = cnt + 1
        If d3.d3_readstr(database, job_rec, "job.l", job_id) <> 0 Then job_rec = ""
                        
        job_desc = pick.extract(job_rec, 2, 0, 0)
        job_budg = pick.extract(job_rec, 24, 0, 0)
        job_bal = pick.extract(job_rec, 3, 0, 0)
        job_comm = pick.extract(job_rec, 27, 0, 0)
        
        'Add the data to the record to be passed back
        nrec(1) = pick.Replace(nrec(1), 1, cnt, 0, job_id)
        nrec(2) = pick.Replace(nrec(2), 1, cnt, 0, job_desc)
        nrec(3) = pick.Replace(nrec(3), 1, cnt, 0, job_budg)
        nrec(4) = pick.Replace(nrec(4), 1, cnt, 0, job_bal)
        nrec(5) = pick.Replace(nrec(5), 1, cnt, 0, job_comm)
      End If
    Next i
                               
End Sub
Public Sub srjob_scs(logentry As String, nrec() As String)
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' PURPOSE:
'   Access data needed for job ledger subcomponent summary
'
' AUTHOR:   RGM
' DATE:     8 Sept 99
' LAST MOD: 10 Sept 99
' MODS BY:  RGM
'
' INPUTS:
'   nrec()  :   Current item ID as nrec(0)
'
' PROCESS:
'   mylist()    :   Item ID's for all items matching select sentence
'   mycount     :   Number of items in mylist()
'   job_rec()   :   All attribute data for current item
'   jobnum      :   First part of item id up to "."
'   classnum    :   Second part of item id
'   pick_cnt    :   No. of items returned (-ve)
'   job_???     :   Attributes we are interested in, extracted from job_rec()
'   i           :   Loop counter
'
' OUTPUTS:
'   nrec()  :   Relevant attribute data for all matched items as m/values
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


Dim i As Integer
Dim mylist() As String, job_rec As String, job_id As String, job_desc As String, job_budg As String, job_bal As String, job_comm As String, job_bhrs As String, job_acthrs As String, jobnum As String, classnum As String
Dim pick_cnt As Long, total_items As Long
Dim database As String

     database = pick.extract(logentry, 2, 0, 0)
     
    'Split the item id into job and class numbers
    jobnum = Left(nrec(0), InStr(nrec(0), ".") - 1)
    classnum = Right(nrec(0), Len(nrec(0)) - InStr(nrec(0), "."))
    
    'Select the items that we want for the component summary
    total_items = d3.d3_select(logentry, "sselect job.l by a0 with a0 =" & Chr(34) & jobnum & "." & classnum & ".]" & Chr(34), mylist(), pick_cnt, 0, 0)
    
    'Set nrec to the number of values to pass back
    ReDim Preserve nrec(7)
    
    For i = 0 To total_items - 1
        job_id = mylist(i)
        If d3.d3_readstr(database, job_rec, "job.l", job_id) <> 0 Then job_rec = ""
        job_desc = pick.extract(job_rec, 2, 0, 0)
        job_budg = pick.extract(job_rec, 24, 0, 0)
        job_bal = pick.extract(job_rec, 4, 0, 0)
        job_comm = pick.extract(job_rec, 27, 0, 0)
        job_bhrs = pick.extract(job_rec, 25, 0, 0)
        job_acthrs = pick.extract(job_rec, 26, 0, 0)
        
        'Add the data to the record to be passed back, using multivalue i + 1 as i starts at 0
        nrec(1) = pick.Replace(nrec(1), 1, i + 1, 0, job_id)
        nrec(2) = pick.Replace(nrec(2), 1, i + 1, 0, job_desc)
        nrec(3) = pick.Replace(nrec(3), 1, i + 1, 0, job_budg)
        nrec(4) = pick.Replace(nrec(4), 1, i + 1, 0, job_bal)
        nrec(5) = pick.Replace(nrec(5), 1, i + 1, 0, job_comm)
        nrec(6) = pick.Replace(nrec(6), 1, i + 1, 0, job_bhrs)
        nrec(7) = pick.Replace(nrec(7), 1, i + 1, 0, job_acthrs)
    Next
                               
End Sub
Public Function srscroll(database As String, rec As String, Key As String) As String

' This is a very basic initial implementation of the SRSCROLL routine. It is DISPLAY ONLY and
' generates a HTML table from 'rec' according to the parameters set up in 'Key', which will normally
' be an item read from SCROLL.KEYS

Dim RString As String, Keyatt As String, ColAtt() As Integer, ColJust() As String, ColStart() As Integer
Dim Coldata As String, Colconv() As String, Colstr As String, AlignStr As String, Head As String
Dim NoLines As Integer, NoDefs As Integer, i As Integer, j As Integer, k As Integer
Dim am As String, vm As String, svm As String, DQ As String

am = Chr(254): vm = Chr(253): svm = Chr(252): DQ = Chr(34)

NoDefs = pick.ccount(Key, am, 0)
Keyatt = pick.extract(Key, 1, 0, 0)
NoLines = pick.ccount(pick.extract(rec, CStr(Keyatt), 0, 0), vm, 0) + 1
RString = "<table cellpadding=1 cellspacing=1 border=1 width=60% align=center>"
RString = RString & vbCr & vbLf & "<TR class=" & DQ & "emphasis" & DQ & ">" & vbCr & vbLf
ReDim ColAtt(NoDefs + 1)
ReDim ColJust(NoDefs + 1)
ReDim ColStart(NoDefs + 1)
ReDim Colconv(NoDefs + 1)

For i = 2 To NoDefs + 1
    ColAtt(i - 1) = pick.extract(Key, i, 1, 0)
    ColJust(i - 1) = pick.extract(Key, i, 6, 0)
    ColStart(i - 1) = CInt(pick.extract(Key, i, 5, 0))
    Colconv(i - 1) = pick.extract(Key, i, 10, 0)
    Head = pick.extract(Key, i, 9, 0)
    Head = Replace(Head, "|", "<BR>")
    RString = RString & "<TD align=" & DQ & "center" & DQ & ">" & Head
Next i
For i = 1 To NoLines
    RString = RString & vbCr & vbLf & "<TR class=" & DQ & "plain" & DQ & ">" & vbCr & vbLf
    For j = 1 To NoDefs
        Coldata = pick.extract(rec, ColAtt(j), i, 0)
        If Colconv(j) <> "" Then Coldata = pick.oconv(Coldata, Colconv(j))
        If ColJust(j) = "L" Then
            AlignStr = "left"
        Else
            AlignStr = "right"
        End If
        If Coldata = "" Then Coldata = "&nbsp;"
        Colstr = "<TD align=" & DQ & AlignStr & DQ & ">" & Coldata & vbCr & vbLf
        RString = RString & Colstr
    Next j
Next i
srscroll = RString

End Function
Public Sub sr5305a(database As String, nrec() As String)

Dim i As Integer, Maxi As Integer, jrec() As String, parts_list As String
Dim rderr As Integer, stock_rec As String, s_id As String, s_desc As String, s_no As String
Dim client_rec As String, s_name As String

     ReDim jrec(0): jrec(0) = nrec(0)
     rderr = d3.d3_readmat(database, jrec(), "JOB.L")
     If UBound(jrec) < 57 Then parts_list = "" Else parts_list = jrec(57)
        
     ReDim Preserve nrec(4)
     
     Maxi = pick.DCount(pick.extract(parts_list, 1, 0, 0), Chr(253))
     For i = 1 To Maxi
        s_id = pick.extract(parts_list, 1, i, 1)
        If d3.d3_readstr(database, stock_rec, "STOCK", s_id) <> 0 Then stock_rec = ""
        s_desc = pick.extract(stock_rec, 1, 1, 0)
        s_no = pick.extract(stock_rec, 16, 1, 0)
        If Left(s_id, 1) = "*" Then
           s_desc = pick.extract(parts_list, 1, i, 2)
           s_no = pick.extract(parts_list, 1, i, 3)
        End If
        If d3.d3_readstr(database, client_rec, "CLIENT", s_no) <> 0 Then client_rec = ""
        s_name = pick.extract(client_rec, 1, 0, 0)
        nrec(1) = pick.Replace(nrec(1), 1, i, 0, s_id)
        nrec(2) = pick.Replace(nrec(2), 1, i, 0, s_desc)
        nrec(3) = pick.Replace(nrec(3), 1, i, 0, s_no)
        nrec(4) = pick.Replace(nrec(4), 1, i, 0, s_name)
     Next i

End Sub


Public Function readstr(database As String, tbl_name As String, id As String, Optional attr As String = "-1", Optional vm As String = "0", Optional svm As String = "0", Optional delimiter As String = "") As String

Dim result As Integer, rd As String

result = d3.d3_readstr(database, rd, tbl_name, id, CInt(attr), CInt(vm), CInt(svm), delimiter)
If result <> 0 Then readstr = Chr(8) Else readstr = rd

End Function



Public Function conv_validate(the_drive As String, database As String, how As String, conversion As String, fld_dt As String, tfile As String, v7 As String, v36 As String, max_length As String, Optional language As String = "English") As String

' NOT USED
' USED TO BE USED FROM VAILDATE.JS

'Dim converted As String, errmsg As String, internal_datum As String
'Dim temp As String


'converted = d3.conv_in(database, "", CInt(how), conversion, fld_dt, errmsg, internal_datum, tfile, v7, v36, CInt(max_length), , temp & "\prospect\language.ini")

'If errmsg <> "" Then
'   conv_validate = Chr(8) & errmsg
'Else
'   conv_validate = internal_datum
'End If

End Function

Public Function sr501(database As String, fileindex As String, filename As String, ACCT_NO As String, want As String, get_all As Integer, Namesort As Integer, KEYLEN As Integer, Optional notnullattr As Integer = 0, Optional Nosymbol As Integer = 0) As String

' Like SR.HELP except have an index file to speed access up
'
' PASS.ID<1,5> (GET.ALL) = 1 means want ids passed back (am separator)
' notnullattr set to attr <> 0 will mean only want those items with this attr not null
' PASS.ID<1,17> set to 1 if when enter short key (less than length of
'               index, will show possible keys and then continue
'               search, rather than just charge on ahead and get all
'               ids to display - which can be rather a lot

'     acct_no = pick.extract(pass_id, 1, 1, 0): attr = pick.extract(pass_id, 1, 2, 0): onlyone = pick.extract(pass_id, 1, 3, 0): ALLOW_CREATE = pick.extract(pass_id, 1, 4, 0): If attr = "" Then attr = 2
'     GET_ALL = pick.extract(pass_id, 1, 5, 0): LINENUM = pick.extract(pass_id, 1, 6, 0): If LINENUM = "" Then LINENUM = 6
'     NODOTS = pick.extract(pass_id, 1, 7, 0): NODESC = pick.extract(pass_id, 1, 8, 0): NAMESORT = pick.extract(pass_id, 1, 9, 0)
Dim Symbols As String, already As Integer, orig_acct_no As String, orig_lentest As Integer
Dim lentest As Integer, lev As String, Key As String, rec As String, maxid As Integer, i As Integer
Dim ids As String, j As Integer, max As Integer, nid As String, Jj As Integer, nme As String
Dim pos As Integer, id As String, IREC As String, dd As Integer
Dim nrec As String, Name As String, attr As Integer
Dim firstletters As String, Ac As String, grec As String, fx As Integer

     already = 0
22   If Mid$(ACCT_NO, 1, 1) = "?" Then
        ACCT_NO = Mid$(ACCT_NO, 2, 99)
     End If
     If Nosymbol = 0 Then
        Symbols = "/-()&"" & ""_,"
        For i = 1 To Len(Symbols)
           ACCT_NO = Replace(ACCT_NO, Mid$(Symbols, i, 1), " ")
        Next i
     End If
     orig_acct_no = UCase(ACCT_NO)
     orig_lentest = Len(orig_acct_no)
     ACCT_NO = pick.field(ACCT_NO, " ", 1)
     lentest = Len(ACCT_NO)
     lev = want
     want = ""
     ACCT_NO = UCase(ACCT_NO)
     Select Case lentest
        Case Is > 0 '>=KEYLEN
           Key = Left(ACCT_NO & "          ", KEYLEN)
           If d3.d3_readstr(database, rec, fileindex, Key) <> 0 Then rec = ""
           If rec = "" And lentest < KEYLEN Then GoTo 23
           GoTo 5
23         If d3.d3_readstr(database, ids, fileindex, ACCT_NO) <> 0 Then ids = ""
26         maxid = pick.DCount(ids, Chr(254))
           rec = ""
           For i = 1 To maxid
              id = pick.extract(ids, i, 0, 0)
              If d3.d3_readstr(database, IREC, fileindex, id) <> 0 Then IREC = ""
              If rec = "" Then
                 rec = IREC
              Else
                 If IREC <> "" Then
                    If Namesort Then
                       max = pick.DCount(pick.extract(IREC, 1, 0, 0), Chr(253))
                       For j = 1 To max
                          nid = pick.extract(IREC, 1, j, 0)
                          Jj = pick.locate(nid, rec, 1, 1, 0, pos, "")
                          If Jj = 0 Then
                             nme = pick.extract(IREC, 2, j, 0)
                             Jj = pick.locate(nme, rec, 2, 1, 0, pos, "")
                             rec = pick.Insert(rec, 1, pos, 0, nid)
                             rec = pick.Insert(rec, 2, pos, 0, nme)
                             If Namesort = 2 Then rec = pick.Insert(rec, 3, pos, 0, pick.extract(IREC, 3, j, 0))
                          End If
                       Next j
                    Else
                       rec = pick.Insert(rec, -1, 0, 0, IREC)
                    End If
                 End If
              End If
              If Len(rec) > 5000 Then want = Chr(8): GoTo 80
           Next i
        Case Else
           If d3.d3_readstr(database, firstletters, fileindex, "FIRSTLETTERS") <> 0 Then firstletters = ""
           max = pick.DCount(firstletters, Chr(254))
           ids = ""
           For i = 1 To max
              id = pick.extract(firstletters, i, 0, 0)
              If d3.d3_readstr(database, rec, fileindex, id) <> 0 Then rec = ""
              If ids = "" Then
                 ids = rec
              Else
                 If rec <> "" Then ids = pick.Insert(ids, -1, 0, 0, rec)
              End If
           Next i
           GoTo 26
     End Select
'
5    If Namesort Then
        If orig_lentest <= KEYLEN And orig_acct_no = ACCT_NO Then nrec = rec: rec = "": GoTo 42
        max = pick.DCount(pick.extract(rec, 1, 0, 0), Chr(253))
        For i = max To 1 Step -1
           Name = pick.extract(rec, 2, i, 0)
           If InStr(Name, orig_acct_no) = 0 Then
              For dd = 1 To Namesort + 1
                 rec = pick.delet(rec, dd, i, 0)
              Next dd
           End If
        Next i
        nrec = rec: rec = "": GoTo 42
     Else
        max = pick.DCount(rec, Chr(254))
     End If
     nrec = ""
     For i = 1 To max
        Ac = pick.extract(rec, i, 0, 0)
        If lev <> "" Then
           If lev = 2 Then
              If pick.Index(Ac, "_", 2) = 0 Then GoTo 40
           Else
              If pick.Index(Ac, "_", 2) Then GoTo 40
              If lev = 1 Then
                 If pick.field(Ac, "_", 2) = 0 Then GoTo 40
              Else
                 If pick.field(Ac, "_", 2) <> 0 Then GoTo 40
              End If
           End If
        End If
        If attr = 0 And notnullattr = 0 Then
           Name = Ac
        Else
           If d3.d3_readstr(database, grec, filename, Ac) <> 0 Then GoTo 40
           If notnullattr <> 0 Then
              If pick.extract(grec, notnullattr, 0, 0) = "" Then GoTo 40
           End If
           If attr = 0 Then Name = Ac Else Name = pick.extract(grec, attr, 0, 0)
        End If
        Name = pick.trimm(pick.extract(Name, 1, 1, 0) & " " & pick.extract(Name, 1, 2, 0) & " " & pick.extract(Name, 1, 3, 0)): Name = UCase(Name)
        If InStr(Name, orig_acct_no) = 0 Then GoTo 40
        If get_all = 1 Then
           Jj = pick.locate(Ac, nrec, 1, 1, 0, fx, "AL")
           If j = 0 Then
              nrec = pick.Insert(nrec, fx, 0, 0, Ac)
           End If
        Else
'           If NODESC Then
'              NAMEPOS = InStr(AC, " ")
'              If NAMEPOS Then name = Mid$(trimm(AC, NAMEPOS + 1, 999)): AC = field(AC, " ", 1) Else name = ""
'           End If
'           LOCATE(AC,NREC,1,1,0,FX,"AL") ELSE
'              name = Mid$(name, 1, 69 - Len(AC))
'              nrec = pick.insert(nrec, 1, FX, 0, AC)
'              If Len(name) > 60 Then name = Mid$(name, 1, 60)
'              nrec = pick.insert(nrec, 2, FX, 0, name)
'           End If
        End If
        If Len(nrec) > 5000 Then nrec = Chr(8): GoTo 80
40   Next i
'
42   If get_all Then want = nrec: GoTo 80
'
'     max = ccount(pick.extract(nrec, 1, 0, 0), Chr(253)) + 1: If pick.extract(nrec, 1, 0, 0) = "" Then max = 0
'
'     If max = 0 Then WANT = "": GoTo 80
'
'     WANT = ""
'45   FILE_DESC = "": FILE_DESC = pick.Replace(FILE_DESC, 1, 2, 0, attr): FILE_DESC = pick.Replace(FILE_DESC, 1, 7, 0, 1)
'     FILE_DESC = pick.Replace(FILE_DESC, 1, 4, 0, ALLOW_CREATE)
'     IF NREC<>"" THEN FILE_DESC=PICK.REPLACE(FILE_DESC,1,3,0,1 ELSE FILE_DESC=PICK.REPLACE(FILE_DESC,1,3,0,0))
'     If onlyone = 0 Then FILE_DESC = pick.Replace(FILE_DESC, 1, 11, 0, 1)
'     FILE_DESC = pick.Replace(FILE_DESC, 1, 12, 0, NODOTS)
'     Call SR_HELP(LINENUM, GEN_L_DATA, nrec, FILE_DESC, WANT)
     
80   sr501 = want

End Function



Public Sub SR313(database As String, deposits As String, nrec() As String)
     'Sub SR313(deposits, optn, SELECTION,  OPTS, FLAGS)
'
' Display / print deposit details as given by parameters
'
'
' FLAGS<2> = FROM.DATE if more than one deposit
' FLAGS<3> = TO.DATE if more than one deposit
' FLAGS<4> = DMSG from TA312 for report heading
' FLAGS<5> = 1 if only EFT receipts
' FLAGS<6> = only this EFT Card code

Dim selection As String, i As Integer, dlen As Integer, dep_no As String, dep_id As String
Dim dep_rcpts As String, rcpt As String, cash_key As String, csh As String
Dim tot_amt As Currency, canc_tot As Currency, no_rcpts As Integer
Dim hi As Integer, r As Integer, depdte As String, canc As String, amount As String
Dim sct As Integer, bbc As String, nar As String
Dim eftcnt As Integer, idr As String, rpost As Integer
Dim max As Integer, j As Integer, k As Integer, maxk As Integer
Dim only_eft As String, temp As String, change As String
Dim Acct As String, nme As String, clrec As String
Dim payee_amt As String, payee As String, notices As String, Banks As String

selection = "1"

'     from_date = oconv(extract(FLAGS, 2, 0, 0), "D2")
'     to_date = oconv(extract(FLAGS, 3, 0, 0), "D2")
'     DMSG = extract(FLAGS, 4, 0, 0)
'     only_eft = "0" 'extract(FLAGS, 5, 0, 0)
'     ONLY_THIS = extract(FLAGS, 6, 0, 0)
'
     ReDim nrec(18)
     sct = 0
'     Select Case SELECTION
'        Case SELECTION = 2
'           SMSG = "Receipts processed between " & from_date & " and " & to_date
'        Case SELECTION = 3
'           SMSG = "Receipts with a general ledger date from " & from_date & " to " & to_date
'           If ONLY_EFT Then
'              If ONLY_THIS <> "" Then
'                 SMSG = "EFT " & ONLY_THIS & " " & SMSG
'              Else
'                 SMSG = "EFT " & SMSG
'              End If
'           End If
'        Case SELECTION = 4
'           SMSG = "Police receipts processed for " & ACCOUNT & " from " & from_date & " to " & to_date
'       Case 1: SMSG = ""
'     End Select
'
22   dlen = pick.DCount(deposits, Chr(254))
'     GRAND_TOT = 0: GRAND_CANC = 0
     For i = 1 To dlen
        dep_id = pick.extract(deposits, i, 0, 0)
        If d3.d3_readstr(database, dep_rcpts, "DICT CASH", dep_id) <> 0 Then dep_rcpts = ""
        tot_amt = 0: canc_tot = 0
        temp = pick.extract(dep_rcpts, 1, 1, 0)
        If IsNumeric(temp) Then no_rcpts = CInt(temp) + 1 Else no_rcpts = 0
        depdte = pick.extract(dep_rcpts, 1, 4, 0)
        'If depdte = "" Then DDTE = Space(15) Else DDTE = "dated " & oconv(depdte, "D2")
        If i = 1 Then
           If selection = 1 Or selection = 5 Then
              'SMSG=("Cash Receipts for Deposit &  " & DEP_NO & " " & DDTE)"L<>52" & "as at " & TIMEICONV(FORMAT$(NOW,"DD MMM YY"),"D2")
              'UHEAD = UHEAD & SMSG
              'Screen = "": Screen = Pick.replace(Screen, 2, 0, 0, SMSG)
           End If
        End If
        If selection <> "1" And selection <> "4" Then
           sct = sct + 1
           'nrec(1) = Pick.replace(nrec(1), 1, sct, 0, "Deposit " & dep_no & " " & DDTE): nrec = Pick.replace(nrec, 1, sct, 2, 1)
        End If
        If selection = "5" Then hi = 2 Else hi = no_rcpts
        For r = 2 To hi
           If selection = "5" Then
              'RCPT = RCPT_NO
           Else
              rcpt = pick.extract(dep_rcpts, r, 1, 0)
           End If
           cash_key = Mid(dep_id, 2, Len(dep_id) - 2) & "*" & rcpt
65         If d3.d3_readstr(database, csh, "CASH", cash_key) <> 0 Then
              csh = ""
              csh = pick.Replace(csh, 9, 0, 0, "receipt missing from file")
           End If
           If pick.extract(csh, 5, 0, 0) = "" Then
              canc = ""
           Else
              canc = "C "
              temp = pick.extract(csh, 3, 0, 0)
              If IsNumeric(temp) Then canc_tot = canc_tot + CCur(temp)
           End If
           eftcnt = 0
           If selection <> 4 Then
              If pick.extract(csh, 1, 0, 0) = "" Then idr = pick.extract(csh, 2, 1, 0) Else idr = pick.extract(csh, 1, 0, 0) & " - " & pick.extract(csh, 2, 1, 0)
              amount = pick.extract(csh, 3, 0, 0)
              If pick.extract(csh, 4, 2, 0) <> "" Then amount = pick.extract(csh, 4, 1, 2)
              sct = sct + 1
              nrec(1) = pick.Replace(nrec(1), 1, sct, 0, canc & rcpt)
              nrec(2) = pick.Replace(nrec(2), 1, sct, 0, amount)
              nrec(3) = pick.Replace(nrec(3), 1, sct, 0, idr)
              temp = pick.extract(csh, 3, 0, 0)
              If IsNumeric(temp) Then
                 tot_amt = tot_amt + CCur(temp)
                 'grand_tot = grand_tot + CCur(temp)
              End If
           End If
           
           GoSub 3900 'bbc & overwrite (2) & (3)
           nar = pick.extract(csh, 9, 0, 0)
           nar = Replace(nar, Chr(253), Chr(252), , , vbBinaryCompare)
           nrec(5) = pick.Replace(nrec(5), 1, sct, 0, nar)
           notices = pick.extract(csh, 21, 0, 0)
           notices = Replace(notices, Chr(253), Chr(252), , , vbBinaryCompare)
           nrec(13) = pick.Replace(nrec(13), 1, sct, 0, notices)
  
           If pick.extract(csh, 4, 0, 0) <> "T" And pick.extract(csh, 4, 0, 0) <> "I" Then
              If pick.extract(csh, 29, 1, 0) <> "" Then
                 change = pick.extract(csh, 29, 2, 0)
                 If change = "" Then
                    change = pick.extract(csh, 29, 1, 0)
                    temp = pick.extract(csh, 3, 1, 0)
                    If IsNumeric(change) Then
                       If IsNumeric(temp) Then
                          change = CStr(CCur(change) - CCur(temp))
                       End If
                    Else
                       If IsNumeric(temp) Then change = CStr(-CCur(temp)) Else change = "0"
                    End If
                 End If
                 nrec(10) = pick.Replace(nrec(10), 1, sct, 0, change)
              End If
           End If
  
           If pick.extract(csh, 18, 0, 0) <> "" Then
              Banks = pick.extract(csh, 18, 0, 0)
              Banks = Replace(Banks, Chr(253), Chr(252), , , vbBinaryCompare)
              nrec(11) = pick.Replace(nrec(11), 1, sct, 0, Banks) 'bank accts
              Banks = pick.extract(csh, 19, 0, 0)
              Banks = Replace(Banks, Chr(253), Chr(252), , , vbBinaryCompare)
              nrec(12) = pick.Replace(nrec(12), 1, sct, 0, Banks) 'bank amts
           End If
                   
           rpost = pick.DCount(pick.extract(csh, 11, 0, 0), Chr(253))
           For j = 1 To rpost
              If selection = "5" Then
'                 GoSub 3900
'                 SVCNT = Pick.dcount(pick.extract(csh, 13, j, 0), Chr(252))
'                 For L = 1 To SVCNT
'                    If pick.extract(csh, 13, j, L) = "" Then
'                       If Index(pick.extract(csh, 11, j, L), "_", 2) Then
'                          nrec = Pick.replace(nrec, 4, sct, 0, pick.extract(csh, 11, j, L))
'                       Else
'                         nrec = Pick.replace(nrec, 4, sct, 0, pick.extract(csh, 11, j, L) & "unalloc")
'                       End If
'                       nrec = Pick.replace(nrec, 5, sct, 0, pick.extract(csh, 12, j, L))
'                    Else
'                       nrec = Pick.replace(nrec, 4, sct, 0, pick.extract(csh, 13, j, L))
'                       nrec = Pick.replace(nrec, 5, sct, 0, pick.extract(csh, 14, j, L))
'                    End If
'                    nrec = Pick.replace(nrec, 6, sct, 0, pick.extract(csh, 15, j, L))
'                    If pick.extract(nrec, 2, sct, 0) = "" Then nrec = Pick.replace(nrec, 2, sct, 0, "")
'                 Next L
              Else
                 If selection = "4" Then
'                    If Mid$(pick.extract(csh, 9, j, 0), 1, 3) = "POL" And canc = "" Then
'                       nrec = Pick.replace(nrec, 1, sct, 0, cash_key & "/" & j)
'                       nrec = Pick.replace(nrec, 2, sct, 0, pick.extract(csh, 2, 1, 0))
'                       nrec = Pick.replace(nrec, 3, sct, 0, pick.extract(csh, 9, j, 0))
'                       nrec = Pick.replace(nrec, 4, sct, 0, pick.extract(csh, 12, j, 0))
'                       GRAND_TOT = GRAND_TOT + pick.extract(csh, 12, j, 0)
'                    End If
                 Else
'                    If only_eft <> "0" Then
'                       PAYEE_AMT = pick.extract(csh, 4, j, 2)
'                       If PAYEE_AMT = "" Then PAYEE_AMT = pick.extract(csh, 12, j, 0)
'                       If PAYEE_AMT = "" Then PAYEE_AMT = pick.extract(csh, 3, 0, 0)
'                       If Mid$(pick.extract(csh, 4, 1, 1), 1, 3) <> "EFT" Then GoTo 235
'                       If ONLY_THIS <> "" Then
'                          DELM = Mid$(pick.extract(csh, 4, j, 1), 4, 1)
'                          cc = field(pick.extract(csh, 4, j, 1), DELM, 2)
'                          If cc <> ONLY_THIS Then
'235                          tot_amt = tot_amt - PAYEE_AMT
'                             GRAND_TOT = GRAND_TOT - PAYEE_AMT
'                             GoTo 250
'                          End If
'                       End If
'                       eftcnt = eftcnt + 1
'                    End If
                    'nar = Pick.extract(csh, 9, j, 0)
                    'If Pick.extract(csh, 23, j, 0) = "P" And Pick.extract(csh, 21, j, 0) <> "" Then
                    '   nrec(5) = Pick.replace(nrec(5), 1, sct, 0, Mid$(nar, 1, 15) & " " & Pick.extract(csh, 21, j, 0))
                    'Else
                    '   nrec(5) = Pick.replace(nrec(5), 1, sct, 0, nar)
                    'End If
                    Acct = pick.extract(csh, 11, j, 0)
                    If Acct = "" Then
                       nme = "": GoTo 245
                    End If
                    If InStr(Acct, ".") Then
                       If Mid$(Acct, 1, 3) = "JOB" Then
                          Acct = Mid$(Acct, 4, 99)
                          If d3.d3_readstr(database, nme, "JOB.L", Acct, 2) <> 0 Then nme = "account does not exist"
                       Else
                          If d3.d3_readstr(database, nme, "GEN.L", Acct, 2) <> 0 Then nme = "account does not exist"
                       End If
                    Else
                       If d3.d3_readstr(database, clrec, "CLIENT", Acct) <> 0 Then clrec = "account does not exist"
                       nme = pick.extract(clrec, 1, 0, 0): If nme = "" Then nme = pick.extract(clrec, 2, 0, 0)
                    End If
245                 nrec(6) = pick.Replace(nrec(6), 1, sct, j, pick.extract(csh, 12, j, 0))
                    nrec(7) = pick.Replace(nrec(7), 1, sct, j, pick.extract(csh, 11, j, 0))
                    nrec(8) = pick.Replace(nrec(8), 1, sct, j, nme)
                    nrec(9) = pick.Replace(nrec(9), 1, sct, j, pick.extract(csh, 27, j, 0)) 'rebate
                    nrec(14) = pick.Replace(nrec(14), 1, sct, j, pick.extract(csh, 23, j, 0)) 'code used
                    nrec(15) = pick.Replace(nrec(15), 1, sct, j, pick.extract(csh, 30, j, 0)) 'payment suggestion chosen
                    nrec(16) = pick.Replace(nrec(16), 1, sct, j, Replace(pick.extract(csh, 13, j, 0), Chr(252), "<br>", , , vbBinaryCompare)) 'svm reference
                    nar = ""
                    maxk = pick.DCount(pick.extract(csh, 13, j, 0), Chr(252))
                    For k = 1 To maxk
                       temp = pick.extract(csh, 14, j, k)
                       If IsNumeric(temp) Then temp = Format(temp / 100, "#.00") Else temp = ""
                       If k = 1 Then nar = temp Else nar = nar & "<br>" & temp
                    Next k
                    nrec(17) = pick.Replace(nrec(17), 1, sct, j, nar)
                    For k = 1 To maxk
                       temp = pick.extract(csh, 15, j, k)
                       temp = pick.date_pick_to_vb(temp)
                       If k = 1 Then nar = temp Else nar = nar & "<br>" & temp
                    Next k
                    nrec(18) = pick.Replace(nrec(18), 1, sct, j, nar)
                 End If
              End If
250        Next j
            If only_eft <> "0" And eftcnt = 0 Then
               sct = sct + 1
               nrec(1) = pick.Replace(nrec(1), 1, sct, 0, ""): nrec(2) = pick.Replace(nrec(2), 1, sct, 0, ""): nrec(3) = pick.Replace(nrec(3), 1, sct, 0, "")
               sct = sct - 1
            End If
        Next r
        If selection <> "4" And selection <> "5" Then
           sct = sct + 1
           nrec(1) = pick.Replace(nrec(1), 1, sct, 0, " ")
           nrec(2) = pick.Replace(nrec(2), 1, sct, 0, CStr(tot_amt - canc_tot))
           nrec(3) = pick.Replace(nrec(3), 1, sct, 0, "Total receipts")
           If canc_tot <> 0 Then
              sct = sct + 1
              nrec(1) = pick.Replace(nrec(1), 1, sct, 0, " ")
              nrec(2) = pick.Replace(nrec(2), 1, sct, 0, CStr(canc_tot))
              nrec(3) = pick.Replace(nrec(3), 1, sct, 0, "Cancelled (receipts with C in front of receipt number)")
              sct = sct + 1
              nrec(1) = pick.Replace(nrec(1), 1, sct, 0, " ")
              nrec(2) = pick.Replace(nrec(2), 1, sct, 0, CStr(tot_amt))
              nrec(3) = pick.Replace(nrec(3), 1, sct, 0, "Total of ALL receipts")
           End If
        End If
     Next i
     If selection <> "1" And selection <> "5" Then
'        If selection = "4" Then
'           sct = sct + 1
'           nrec = Pick.replace(nrec, 1, sct, 0, "")
'           'nrec = Pick.replace(nrec, 2, sct, 0, "Total for " & ST_SCT - 2 & " receipts")
'           nrec = Pick.replace(nrec, 4, sct, 0, GRAND_TOT)
'        Else
'           sct = sct + 1
'           nrec = Pick.replace(nrec, 1, sct, 0, "")
'           nrec = Pick.replace(nrec, 2, sct, 0, GRAND_TOT - GRAND_CANC)
'           nrec = Pick.replace(nrec, 3, sct, 0, "Grand total receipts")
'           If GRAND_CANC <> 0 Then
'              nrec = Pick.replace(nrec, 1, sct, 0, "")
'              nrec = Pick.replace(nrec, 2, sct, 0, GRAND_CANC)
'              nrec = Pick.replace(nrec, 3, sct, 0, "Cancelled (receipts with C in front of receipt number)")
'              nrec = Pick.replace(nrec, 1, sct, 0, "")
'              nrec = Pick.replace(nrec, 2, sct, 0, GRAND_TOT)
'              nrec = Pick.replace(nrec, 3, sct, 0, "Grand total of ALL receipts")
'           End If
'        End If
     End If
599  Exit Sub
'
3900 rpost = pick.DCount(pick.extract(csh, 4, 0, 0), Chr(253))
     If rpost = 0 Then rpost = 1
     For j = 1 To rpost
        If pick.extract(csh, 4, j, 0) <> "" Or j = 1 Then
           If pick.extract(csh, 4, j, 1) = "" Then bbc = "CASH" Else bbc = pick.extract(csh, 4, j, 1)
           nrec(4) = pick.Replace(nrec(4), 1, sct, j, bbc)
           payee_amt = pick.extract(csh, 4, j, 2)
           If payee_amt = "" Then payee_amt = pick.extract(csh, 3, 0, 0)
           nrec(2) = pick.Replace(nrec(2), 1, sct, 0, payee_amt)
           payee = pick.extract(csh, 4, j, 3)
           If payee = "" Then payee = pick.extract(csh, 2, 1, 0)
           nrec(3) = pick.Replace(nrec(3), 1, sct, 0, payee)
        End If
     Next j
     Return

End Sub


Public Function SR305(logentry As String, Parms As String)

' print banking schedule

Dim NumReceipts As Integer, Onto_2nd_Line As Integer, Sub_Eft As Integer, Blist_Ct As Integer
Dim pos As Integer, k As Integer, kk As Integer, max As Integer, MaxB As Integer
Dim Line As Long, Test As Integer, i As Integer, Rptr As Integer
Dim Tot_Cash As Currency, Tot_Chq As Currency, ChqCnt As Integer, Tot_Eft As Currency, Stot_Eft As Currency

Dim strTemp As String, wshnetwork
Dim account As String, Cphead As String, REP_HEAD As String, Rep_Head2 As String
Dim Bank_Amts As String, Banks As String, CData As String
Dim No_Bank_Lists As Integer, Eft_Bank As String
Dim chq As String, Receipt As String
Dim BankName As String, Sp As String, Name As String, Name2 As String, Bk As String, Pbk As String
Dim rderr As Integer, all_rec As String, usa As String, want_ptr As String
Dim ptr_remote As String, ptr_local As String
Dim Msg As String, Bank_Dep_Number As String, database As String, deposits As String

Dim columnar As Boolean: columnar = True
Dim f_cols() As String, f_col_tabs(), j As Integer, total_len As Integer
Dim tempobj As Object

Msg = ""
On Error GoTo ThisErr

     database = pick.extract(logentry, 2, 0, 0)
     
     deposits = pick.extract(Parms, 1, 0, 0)
     want_ptr = Trim(pick.extract(Parms, 2, 0, 0))
     ptr_local = pick.field(want_ptr, "=", 1)
     ptr_remote = pick.field(want_ptr, "=", 2)
     
     On Error GoTo error_ptr
     Set Printer = Printers(CInt(want_ptr))
     On Error GoTo error_printing
     Set tempobj = CreateObject("cka_ta16.ta16")
     Call tempobj.printer_on_off(1, "", 8, vbPRORLandscape)
     
     Bank_Dep_Number = deposits
     rderr = d3.d3_readstr(database, all_rec, "DICT CASH", "D" & Bank_Dep_Number & "D")

     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If
     If UBound(g_trans_info_array) < 106 Then ReDim Preserve g_trans_info_array(106)
     
     strTemp = g_trans_info_array(106)
     If Not IsNumeric(strTemp) Then usa = 0 Else usa = CInt(strTemp)
     
     strTemp = Mid$(g_trans_info_array(40), 2, 1)
     If Not IsNumeric(strTemp) Then Eft_Bank = 0 Else Eft_Bank = CInt(strTemp)
     If Eft_Bank = 0 Then Eft_Bank = 1
           
     'strTemp = Mid$(pick.extract(Numlists, 1, 1, 0), 1, 1)
     'If Not IsNumeric(strTemp) Then No_Bank_Lists = 0 Else No_Bank_Lists = CInt(strTemp)
     No_Bank_Lists = 1
     Rptr = 0
     'strTemp = pick.extract(Numlists, 1, 2, 0)
     'If Not IsNumeric(strTemp) Then Rptr = 0 Else Rptr = CInt(strTemp)
     
     strTemp = pick.extract(all_rec, 1, 1, 0)
     If Not IsNumeric(strTemp) Then NumReceipts = 0 Else NumReceipts = CInt(strTemp)
     
     If usa Then chq = "CHECK" Else chq = "CHEQUE"
     Cphead = Space(Int((132 - Len(pick.extract(account, 1, 1, 1))) / 2)) & pick.extract(account, 1, 1, 1)
      
      For Blist_Ct = 1 To No_Bank_Lists
         REP_HEAD = Msg & "Banking Schedule" & Space(10) & "Deposit " & Bank_Dep_Number & Space(20)
         Rep_Head2 = Left("Drawer" & Space(39), 39) & " " & Left("Bank & Branch" & Space(30), 30) & Space(9) & "Amount" & Space(8) & "Date     " & "Receipt"
         GoSub 2000                     ' print header
         Tot_Cash = 0: Tot_Chq = 0: ChqCnt = 0: Tot_Eft = 0
         Bank_Amts = ""
         Banks = ""
         
         For k = 2 To NumReceipts + 1
            Receipt = pick.extract(all_rec, k, 1, 0)
            Stot_Eft = 0
            If d3.d3_readstr(database, CData, "CASH", Bank_Dep_Number & "*" & Receipt) <> 0 Then
               Call pline("** ERROR ** RECEIPT " & Receipt & " DOES NOT EXIST", "", "", True, False) ' do line feed
               Line = Line + 3
               GoTo 1200
            End If
            
            BankName = pick.extract(CData, 4, 0, 0)
            If Rptr = 0 Then
               If BankName = "" Then
                  If pick.extract(CData, 5, 0, 0) = "" Then Tot_Cash = Tot_Cash + pick.extractcur(CData, 3, 0, 0): GoTo 1100
                  GoTo 1200
               End If
            Else
               If pick.extract(CData, 20, 0, 0) = 1 Then GoTo 1100
            End If
            Sp = Space(5)
            If Line > 48 Then GoSub 2000
            max = pick.DCount(BankName, Chr(253))
            If max <= 1 Then
               If Mid$(BankName, 1, 3) = "EFT" Then
                  If pick.extract(CData, 5, 0, 0) = "" Then Stot_Eft = Stot_Eft + pick.extractcur(CData, 3, 0, 0): GoTo 1100
                  GoTo 1200
               End If
               Name = pick.extract(CData, 4, 1, 3)
               If Name = "" Then Name = pick.extract(CData, 2, 1, 0)
               If pick.extract(CData, 1, 0, 0) <> "" Then Name = Name & " (" & pick.extract(CData, 1, 0, 0) & ")"
               Call pline(Name, f_col_tabs(0), "", False, False)
               Call pline(BankName, f_col_tabs(1), "", False, False)
               Call pline(Format(pick.extractcur(CData, 3, 0, 0) / 100, "currency"), -(f_col_tabs(2) + Printer.TextWidth(f_cols(2))), "", False, False)
               Call pline(pick.oconv(pick.extract(CData, 10, 0, 0), "D2"), f_col_tabs(3), "", False, False)
               If pick.extract(CData, 5, 0, 0) <> "" Then
                  Call pline(Receipt & " CANCELLED " & pick.oconv(pick.extract(CData, 5, 0, 0), "D2"), f_col_tabs(4), "", True, False)
                  Line = Line + 1
                  GoTo 1200
               Else
                  Call pline(Receipt, f_col_tabs(4), "", True, False)
               End If
               Line = Line + 1
               If Rptr Then GoTo 1100
               strTemp = pick.extract(CData, 3, 0, 0)
               If IsNumeric(strTemp) Then Tot_Chq = Tot_Chq + CCur(strTemp)
               ChqCnt = ChqCnt + 1
            Else
               Onto_2nd_Line = 0
               For i = 1 To max
                  If pick.extract(BankName, 1, i, 1) = "" Then
                     If pick.extract(CData, 5, 0, 0) = "" Then Tot_Cash = Tot_Cash + pick.extractcur(BankName, 1, i, 2)
                     GoTo 1080
                  End If
                  If Mid$(pick.extract(BankName, 1, i, 1), 1, 3) = "EFT" Then
                     If pick.extract(CData, 5, 0, 0) = "" Then Stot_Eft = Stot_Eft + pick.extractcur(BankName, 1, i, 2)
                     GoTo 1080
                  End If
                  If Onto_2nd_Line Then
                     Name2 = pick.extract(CData, 4, i, 3)
                     If Name2 = "" Then Name2 = pick.extract(CData, 2, 1, 0)
                     Call pline(Name2, f_col_tabs(0), "", False, False)
                     'Printer.Print Left(Name2 & Space(39), 39) & " "
                  Else
                     Name = pick.extract(CData, 4, i, 3)
                     If Name = "" Then Name = pick.extract(CData, 2, 1, 0)
                     If pick.extract(CData, 1, 0, 0) <> "" Then Name = Name & " (" & pick.extract(CData, 1, 0, 0) & ")"
                     Call pline(Name, f_col_tabs(0), "", False, False)
                     Printer.Print Left(Name & Space(39), 39) & " "
                  End If
                  Call pline(pick.extract(BankName, 1, i, 1), f_col_tabs(1), "", False, False)
                  Call pline(Format(pick.extractcur(BankName, 1, i, 2) / 100, "currency"), -(f_col_tabs(2) + Printer.TextWidth(f_cols(2))), "", False, False)
                  Call pline(pick.oconv(pick.extract(CData, 10, 0, 0), "D2"), f_col_tabs(3), "", False, False)
                  'Printer.Print Left(pick.extract(BankName, 1, I, 1) & Space(30), 30) & Space(5) & Right(Space(10) & Format(pick.extractcur(BankName, 1, I, 2) / 100, "currency"), 10) & Space(5) & Left(pick.oconv(pick.extract(CData, 10, 0, 0), "D2") & Space(12), 12) & Receipt
                  If pick.extract(CData, 5, 0, 0) = "" And Rptr = 0 Then Tot_Chq = Tot_Chq + pick.extractcur(BankName, 1, i, 2): ChqCnt = ChqCnt + 1
                  If i = 1 Then
                     If pick.extract(CData, 5, 0, 0) <> "" Then
                        Call pline(Receipt & " CANCELLED " & pick.oconv(pick.extract(CData, 5, 0, 0), "D2"), f_col_tabs(4), "", True, False)
                        'Printer.Print " CANCELLED " & pick.oconv(pick.extract(CData, 5, 0, 0), "D2")
                     Else
                        Call pline(Receipt, f_col_tabs(4), "", True, False)
                     End If
                  Else
                     Call pline(Receipt, f_col_tabs(4), "", True, False)
                  End If
                  Line = Line + 1
                  Onto_2nd_Line = 1
                  If Line > 48 Then GoSub 2000
1080           Next i
               If pick.extract(CData, 5, 0, 0) <> "" Then GoTo 1200
            End If

1100       Tot_Eft = Tot_Eft + Stot_Eft: Sub_Eft = 1
           If pick.extract(CData, 18, 0, 0) <> "" Then
               For kk = 1 To 999
                  Bk = pick.extract(CData, 18, kk, 0)
                  If Bk = "" Then GoTo 1200
                  If Banks = "" Then
                      Banks = Bk
                      pos = 1
                  Else
                      If pick.locate(Bk, Banks, 1, 1, 0, pos, "AR") = 0 Then
                         Banks = pick.Insert(Banks, 1, pos, 0, Bk)
                         Bank_Amts = pick.Insert(Bank_Amts, 1, pos, 0, "")
                      End If
                  End If
                  
                  Bank_Amts = pick.Replace(Bank_Amts, 1, pos, 0, pick.extractcur(Bank_Amts, 1, pos, 0) + pick.extractcur(CData, 19, kk, 0))
                  If Sub_Eft And Bk = Eft_Bank Then
                     Bank_Amts = pick.Replace(Bank_Amts, 1, pos, 0, pick.extractcur(Bank_Amts, 1, pos, 0) - Stot_Eft)
                     Sub_Eft = 0
                  End If
               Next kk
            End If
1200     Next k

1400     If Rptr Then GoTo 1500
         MaxB = pick.DCount(pick.extract(Banks, 1, 0, 0), Chr(253))
         Test = 9: If Tot_Eft <> 0 Then Test = 11
         If Line + 11 + MaxB > 55 Then GoSub 2000  'WCC
         Call pline(String(1000, " "), -f_col_tabs(4), "", True, True)
         'Printer.Print String(109, "-")
         'Printer.Print Right(Space(72) & ("Total " & chq & " Amount"), 72) & Right(Space(13) & Format(Tot_Chq / 100, "currency"), 13)
         Call pline("Total " & chq & " Amount ", -f_col_tabs(2), "", False, False)
         Call pline(Format(Tot_Chq / 100, "currency"), -(f_col_tabs(2) + Printer.TextWidth(f_cols(2))), "", True, False)
               
         'Printer.Print Right(Space(72) & "Total CASH Amount", 72) & Right(Space(13) & Format(Tot_Cash / 100, "currency"), 13)
         'Printer.Print
         Call pline("Total CASH Amount ", -f_col_tabs(2), "", False, False)
         Call pline(Format(Tot_Cash / 100, "currency"), -(f_col_tabs(2) + Printer.TextWidth(f_cols(2))), "", True, False)
         
         If Tot_Eft <> 0 Then
            Call pline("Total EFT Amount ", -f_col_tabs(2), "", False, False)
            Call pline(Format(Tot_Eft / 100, "currency"), -(f_col_tabs(2) + Printer.TextWidth(f_cols(2))), "", True, False)
            'Printer.Print Right(Space(72) & "Total EFT Amount", 72) & Right(Space(13) & Format(Tot_Eft / 100, "currency"), 13)
            'Printer.Print
         End If
         'Printer.Print Right(Space(72) & "Total DEPOSIT Amount", 72) & Right(Space(13) & Format((Tot_Cash + Tot_Chq + Tot_Eft) / 100, "currency"), 13)
         'Printer.Print
         Call pline("Total DEPOSIT Amount ", -f_col_tabs(2), "", False, False)
         Call pline(Format((Tot_Cash + Tot_Chq + Tot_Eft) / 100, "currency"), -(f_col_tabs(2) + Printer.TextWidth(f_cols(2))), "", True, False)
         Call pline("Total Number of " & chq & "S ", -f_col_tabs(2), "", False, False)
         Call pline(ChqCnt, -(f_col_tabs(2) + Printer.TextWidth(f_cols(2))), "", True, False)
         
         For kk = 1 To MaxB
            Bk = pick.extract(Banks, 1, kk, 0)
            Call SR_31(database, Pbk, Bk, "")
            Call pline("Deposit for Bank Account " & Bk & " " & pick.extract(Pbk, 1, 0, 0) & " ", -f_col_tabs(2), "", False, False)
            Call pline(Format(pick.extractcur(Bank_Amts, 1, kk, 0) / 100, "currency"), -(f_col_tabs(2) + Printer.TextWidth(f_cols(2))), "", True, False)
            If kk = MaxB Then
               Call pline("", "", "", True, False)
               Call pline("", "", "", True, False)
               Call pline("", "", "", True, False)
               Call pline("    Signed _______________________", f_col_tabs(1), "", True, False)
            Else
               Call pline("", "", "", True, False)
            End If
            
         Next kk
1500  Next Blist_Ct
      Call tempobj.printer_on_off(0)
      Set tempobj = Nothing
      If IsNumeric(want_ptr) Then
    
      Else
         wshnetwork.RemovePrinterConnection ptr_remote
         Set wshnetwork = Nothing
      End If
      Exit Function

' s/r 2000:  print deposit heading
2000 Call tempobj.printer_on_off(1, "", -2) 'increase font size for headings

     Call pline(Cphead, "", "", True, False) ' do line feed
     Call pline("", "", "", True, False) ' do line feed
     Call pline(REP_HEAD & "as at " & Now, "", "", True, False) ' do line feed
     Call pline("", "", "", True, False) ' do line feed
     
     ReDim f_cols(4)
     f_cols(0) = Left("Drawer" & Space(39), 39)
     f_cols(1) = Left("Bank & Branch" & Space(30), 30)
     f_cols(2) = "Amount    "
     f_cols(3) = "Date     "
     f_cols(4) = "Receipt"
     If Not set_tabs(f_cols(), f_col_tabs()) Then Return
     total_len = 0
     For j = 0 To UBound(f_cols)
        Call pline(f_cols(j), f_col_tabs(j), "", False, True) 'last true means underline
        total_len = total_len + Len(f_cols(j))
     Next j
     Call pline("", "", "", True, False) ' do line feed
     
     Call tempobj.printer_on_off(1, "", -1) 'reset font size for details

     Line = 0
     Return
     
Exit Function

ThisErr:
Printer.Print Err.Description
Exit Function

error_ptr:
   SR305 = Chr(8) & Err & " - " & Error(Err) & " - cannot Set Printer"
   Exit Function
error_ptrname:
   SR305 = Chr(8) & Err & " - " & Error(Err) & " - printer name " & want_ptr
   Exit Function
error_printing:
   SR305 = Chr(8) & Err & " - " & Error(Err)
   Exit Function
   
End Function


Public Function sr_make_extended_database(database As String, fname As String, template As String) As String

Dim k As Integer, title As String
Dim rderr As Integer, cnt As Integer, tds As String, label As String
Dim frec() As String, M As Integer, attr As String, srchlist As String, labellist As String, sct As Integer
Dim Crec As String, max As Integer, tkey As String, Srec() As String
Dim fnum As Integer, dms As String
Dim Items As String, tname As String, tcode As String
Dim svms() As String, vms() As String, id_template As String

     ReDim frec(0): frec(0) = "@DS|" & fname
     rderr = d3.d3_readmat(database, frec(), "SCROLL.KEYS")
     For k = 1 To UBound(frec)
        title = pick.extract(frec(k), 1, 2, 0)
        title = Replace(title, "\", "")
        title = Replace(title, "/", "")
        title = Replace(title, "'", "")
        title = Replace(title, """", "")
        title = UCase(title)
        If title = template Then
           tkey = pick.extract(frec(k), 1, 1, 0)
           
           id_template = pick.extract(frec(k), 1, 1, 0)
           id_template = Mid(id_template, 4)
           id_template = Replace(id_template, "|", "_")
           id_template = Replace(id_template, ".", "_")
           
              ReDim Srec(0): Srec(0) = tkey
              rderr = d3.d3_readmat(database, Srec(), "SCROLL.KEYS")
              srchlist = "a0": labellist = pick.extract(Srec(1), 1, 1, 1): sct = 0
              dms = "@,/prospect/asp/bi.asp?fn=" & fname & "&tn=" & id_template & "&item=,0"
              tds = "<TD>"
              Items = ""
              For M = 1 To UBound(Srec)
                 svms = Split(Srec(M), Chr(252), -1, vbBinaryCompare)
                 ReDim Preserve svms(8)
                 attr = svms(2)
                 label = svms(0)
                 If attr <> "0" And attr <> "" And label <> "" Then
                  tname = svms(5)
                  If tname = "" Or tname = "PCODES" Then
                    If InStr(1, srchlist, "A" & attr & ",", vbBinaryCompare) = 0 Then
                       labellist = labellist & "," & label
                       If svms(8) = "MD2" Then 'conversion
                          tds = tds & "|<TD align=right>"
                       Else
                          tds = tds & "|<TD>"
                       End If
                       'sct = sct + 1: If sct > 8 Then Exit For
                       srchlist = srchlist & ",A" & attr
                       If tname = "" Then
                          'srchlist = srchlist & ",A" & attr
                          dms = dms & "|" & attr & ",0,0,,," & svms(8)
                          Items = Items & ","
                       Else
                          'srchlist = srchlist & "," & label
                          tcode = svms(6)
                          dms = dms & "|" & attr & ",0,0,," & tcode & ",T" & tname & ";1" '4,0,0,,@B.,TANIMAL.CODES;1
                          Items = Items & "," & "sselect " & tname & " a0 a1 by a1 with a0 = """ & tcode & "]"""
'itemlist=,,,sselect animal.codes a0 a1 by a1 with a0 = "@B.]"
                       End If
                    End If
                  End If
                 End If
              Next M
'filetouse = TREES
'templatetouse = TREES_1
'srchlist=a0,A15,A9,A11,A12,A13,A17
'srchkey = A0
'labellist=Id,COMMENTS,REPLACE,LANDSCAPE,PRIVATE,NUMBER,DATE PLANT
               Crec = fname & vbCrLf
               Crec = Crec & template & vbCrLf
               Crec = Crec & srchlist & vbCrLf
               Crec = Crec & "A0" & vbCrLf
               Crec = Crec & labellist & vbCrLf
               
               Crec = Crec & title & vbCrLf
               Crec = Crec & Replace(labellist, ",", "|", , , vbBinaryCompare) & vbCrLf
               Crec = Crec & tds & vbCrLf
               Crec = Crec & dms & vbCrLf
               Crec = Crec & Items & vbCrLf
               
               sr_make_extended_database = Crec
               Exit Function
           End If
        Next k
        sr_make_extended_database = ""
End Function

Public Sub SR525(database As String, Narr As String, LEN_DESC As Integer, Mulnarr As String)

Dim Desc As String, Ll As Integer
'*DONOTALTER**
'
' TAKES NARR AND RETURNS MULTI-VALUE ARRAY WITH LINES OF LENGTH GIVEN
' WITH LINES BROKEN ON SPACES BETWEEN WORDS WHERE POSSIBLE
'
     Desc = Narr
     Mulnarr = ""
10   For Ll = LEN_DESC + 1 To 1 Step -1
        If pick.trimm(Mid$(Desc, Ll, 1)) = "" Then
           Mulnarr = pick.Insert(Mulnarr, 1, -1, 0, Mid$(Desc, 1, Ll - 1) & Space(LEN_DESC - Len(Mid$(Desc, 1, Ll - 1))))
           Desc = Mid$(Desc, Ll + 1, Len(Desc))
           If Desc = "" Then Exit Sub Else GoTo 10
        End If
     Next Ll
     Mulnarr = pick.Insert(Mulnarr, 1, -1, 0, Mid$(Desc, 1, LEN_DESC) & Space(LEN_DESC - Len(Mid$(Desc, 1, LEN_DESC))))
     Desc = Mid$(Desc, LEN_DESC + 1, Len(Desc))
     GoTo 10

End Sub

Public Function get_dropdown(logentry As String, sentence As String, dbname As String) As String

Dim the_ids As String
Dim mylist() As String, k As Long, pick_cnt As Long, total_items As Long

If dbname <> "" Then ' select * from filename
   total_items = d3.msa_select(dbname, sentence, mylist(), pick_cnt, 0, 0, 1, 0)
   the_ids = ""
   For k = 0 To total_items - 1
      the_ids = the_ids & "<OPTION VALUE=""" & mylist(k) & """>" & mylist(k)
   Next k
   get_dropdown = the_ids
Else  'sselect filename
   get_dropdown = d3.d3_select_str(logentry, sentence)
End If
   
End Function
Public Function bankit_read(database As String, Parms As String, IniPath As String) As String

Dim filenumber As Integer, var As String, rderr As Integer
Dim deprec As String, cash_rec As String, client_rec As String, recpt_amt As String
Dim Trans_Type As String, Client_No As String, today_date As String
Dim def_gl As String, no_rcpts As Integer, totamt As Currency
Dim client_name As String, Key As String, dummy() As String, dummy2() As String
Dim temp As String, depnum As String, numchars As Integer, var_test As String

Dim f_banknum As String
Dim f_how As Integer: f_how = 0
Dim f_the_file As String
Dim f_code(2) As Integer
Dim f_trans As Integer
Dim f_assess(2) As Integer
Dim f_amount(2) As Integer
Dim f_which_debtors As String
Dim f_pr_bank As String  'the bank account number in logis
Dim f_ini_name As String
Dim f_the_bank As String 'the bank supplying the file - automatically detected from banks.ini

  f_the_file = pick.extract(Parms, 1, 0, 0) 'name of DOS file to read
  f_banknum = pick.extract(Parms, 2, 0, 0) 'the bank account number in logis
  If f_banknum = "" Then f_pr_bank = 1 Else f_pr_bank = f_banknum
  depnum = pick.extract(Parms, 3, 0, 0) 'deposit number
  
  f_ini_name = IniPath
  
  If depnum = "" Then bankit_read = Chr(8) & "Must have a deposit number": Exit Function
  If Not (pick.Match(depnum, "1n0n")) Then bankit_read = Chr(8) & "Deposit number must be numeric": Exit Function
  
  rderr = d3.d3_readstr(database, deprec, "CHQ.REC" & f_banknum, "D" & depnum & "D")
  If rderr = 0 Then bankit_read = Chr(8) & "Deposit D" & depnum & "D already exists on file CHQ.REC" & f_banknum: Exit Function
  rderr = d3.d3_readstr(database, deprec, "DICT CASH", "D" & depnum & "D")
  If rderr = 0 Then bankit_read = Chr(8) & "Deposit D" & depnum & "D already exists on file CASH": Exit Function
    
   deprec = "": no_rcpts = 0
   rderr = pick.date_vb_to_pick(CStr(Date), today_date, f_how) 'convert todays date to pick format date
   If UBound(g_trans_info_array) = 0 Then
      g_trans_info_array(0) = "TRANS.INFO"
      rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
   End If
   If UBound(g_trans_info_array) < 22 Then temp = "" Else temp = g_trans_info_array(22)
   def_gl = pick.extract(temp, 1, 2, 0)
   
    '???Call pick.ini_put("cash", "bank_dos_file_name", f_the_file, g_drive & "/prospect/" & "cka.ini")
    On Error GoTo ErrHandler
    filenumber = FreeFile
    Open f_the_file For Input Access Read As #filenumber
    Line Input #filenumber, var
    Close #filenumber
    
    temp = pick.ini_read("which_bank", "test", f_ini_name)
    If IsNumeric(pick.field(temp, ",", 2)) Then
       numchars = CInt(pick.field(temp, ",", 2))
    Else
       GoTo bad_read
    End If
test_one_fewer:
    var_test = Mid(var, CInt(pick.field(temp, ",", 1)), numchars)
    f_the_bank = pick.ini_read("which_bank", var_test, f_ini_name)
    If f_the_bank = "" Then
       numchars = numchars - 1
       If numchars > 0 Then GoTo test_one_fewer
       bankit_read = Chr(8) & "File does not match any known format": Exit Function
    End If
    
    f_trans = pick.ini_read(f_the_bank, "trans", f_ini_name)
        
    temp = pick.ini_read(f_the_bank, "assess", f_ini_name)
    f_assess(1) = CInt(pick.field(temp, ",", 1))
    f_assess(2) = CInt(pick.field(temp, ",", 2))
    temp = pick.ini_read(f_the_bank, "amount", f_ini_name)
    f_amount(1) = CInt(pick.field(temp, ",", 1))
    f_amount(2) = CInt(pick.field(temp, ",", 2))
    
    temp = pick.ini_read(f_the_bank, "code", f_ini_name)
    f_code(1) = CInt(pick.field(temp, ",", 1))
    f_code(2) = CInt(pick.field(temp, ",", 2))
        
    f_which_debtors = pick.ini_read("which_debtors", "1", f_ini_name)

 ''''''''''''''''''''''''''''''''''''
   filenumber = FreeFile
   Open f_the_file For Input Access Read As #filenumber
   Do While Not EOF(filenumber) ' Check for end of file.
       Line Input #filenumber, var
       GoSub process_cash_rec
       'guage_text.Caption = no_rcpts & "-" & var
   Loop
   Close #filenumber
   rderr = d3.d3_writestr(database, "DICT CASH", "D" & depnum & "D", deprec)
   If d3.d3_readstr(database, deprec, "DICT CASH", "C.CONTROL") <> 0 Then deprec = ""
   deprec = pick.Insert(deprec, -1, 0, 0, depnum)
   rderr = d3.d3_writestr(database, "DICT CASH", "C.CONTROL", deprec)
   bankit_read = "Receipts from " & f_the_bank & vbCrLf & no_rcpts & " receipts.  Total " & Format(totamt / 100, "currency")
   Exit Function

process_cash_rec:
     If f_code(1) = 0 Then
        Trans_Type = pick.field(var, ",", f_code(2))
     Else
        Trans_Type = Mid(var, f_code(1), f_code(2))
     End If
     Select Case Trans_Type
        Case f_trans 'westpac transaction (1) or aust post file header (1) or aust post transaction (5)
           If f_assess(1) = 0 Then
              Client_No = pick.field(var, ",", f_assess(2))
           Else 'mc 13sep99
              Select Case f_assess(1)
                 Case -1   'mc 13sep99
                    Client_No = pick.field(var, ",", f_assess(2)) 'mc 13sep99
                    Client_No = Left(Client_No, Len(Client_No) - 1) 'mc 13sep99
                 Case -3 'mc 13oct99 bankwest has BILL PAYMENT nnnn 001
                    Client_No = pick.field(var, ",", f_assess(2)) 'mc 13oct99
                    Client_No = pick.field(Client_No, " ", 3) 'mc 13oct99
                 Case Else 'mc 13sep99
                    Client_No = Mid(var, f_assess(1), f_assess(2))
              End Select 'mc 13sep99
           End If
           If f_amount(1) = 0 Then
              recpt_amt = pick.field(var, ",", f_amount(2))
           Else
              recpt_amt = Mid(var, f_amount(1), f_amount(2))
           End If
process_remove_lead_zero:
           If Left(Client_No, 1) = "0" Then Client_No = Mid(Client_No, 2): GoTo process_remove_lead_zero
process_remove_lead_zero_two:
           If Left(recpt_amt, 1) = "0" Then recpt_amt = Mid(recpt_amt, 2): GoTo process_remove_lead_zero_two
           Call pick.sr_change(recpt_amt, ".", "") 'mco 12sep99
           Call pick.sr_change(recpt_amt, "-", "") 'mco 12sep99
           
           cash_rec = ""
           If d3.d3_readstr(database, client_rec, "CLIENT", Client_No) <> 0 Then client_rec = ""
           If client_rec = "" Then
              client_rec = Client_No & " invalid"
              Client_No = ""
           Else
              If f_which_debtors <> "all" Then
                 If pick.extract(client_rec, 28, 0, 0) <> "1" Then client_rec = Client_No & " invalid": Client_No = ""
              Else
                 If pick.extract(client_rec, 10, 0, 0) <> "1" Then client_rec = Client_No & " not a debtor": Client_No = ""
              End If
           End If
           If pick.extract(client_rec, 28, 0, 0) = "1" Then
              client_name = ""
           Else
              client_name = pick.trimm(pick.extract(client_rec, 6, 0, 0) & " " & pick.extract(client_rec, 1, 0, 0))
           End If
           cash_rec = pick.Replace(cash_rec, 1, 0, 0, Client_No)
           cash_rec = pick.Replace(cash_rec, 2, 0, 0, client_name)
           cash_rec = pick.Replace(cash_rec, 3, 0, 0, recpt_amt)
           cash_rec = pick.Replace(cash_rec, 4, 0, 0, "T")
           cash_rec = pick.Replace(cash_rec, 10, 0, 0, today_date)
           If def_gl <> "" Then
              If Client_No = "" Then
                 cash_rec = pick.Replace(cash_rec, 11, 0, 0, def_gl)
                 cash_rec = pick.Replace(cash_rec, 12, 0, 0, recpt_amt)
              End If
           End If
           cash_rec = pick.Replace(cash_rec, 18, 0, 0, f_pr_bank)
           cash_rec = pick.Replace(cash_rec, 19, 0, 0, recpt_amt)
           no_rcpts = no_rcpts + 1
           Key = depnum & "*" & no_rcpts
           rderr = d3.d3_writestr(database, "CASH", Key, cash_rec)
           deprec = pick.Replace(deprec, 1, 0, 0, CStr(no_rcpts))
           deprec = pick.Insert(deprec, -1, 0, 0, CStr(no_rcpts))
           totamt = totamt + CCur(recpt_amt)
     End Select
     Return
     
ErrHandler:
    bankit_read = Chr(8) & Err & " " & Error(Err) & " " & f_the_file
    Exit Function
bad_read:
    bankit_read = Chr(8) & "Bad read of -" & temp & "- from ""which_bank"" ""test"" " & f_ini_name
    Exit Function
End Function
Public Function Check_Month_Ends(logentry As String, MEDate As String) As String

' Returns a "1" if MEDate is a Valid Month End Date (AS Defined on TRANS.J)

Dim logarray() As String, Trans_Info As String, Trans_Array() As String
Dim Mends As String, Valid As String, ChkDate As String
Dim attr As Integer, valm As Integer, SVAL As Integer, posn As Integer, SEQN As String
Dim am As String, vm As String, svm As String
am = Chr(254): vm = Chr(253): svm = Chr(252)

logarray = Split(logentry, Chr(254))
If d3.d3_readstr(logarray(1), Trans_Info, "DICT TRANS.J", "TRANS.INFO") <> 0 Then Trans_Info = ""
Trans_Array = Split(Trans_Info, am)
Mends = Trans_Array(9) & vm & Trans_Array(8) & vm & Trans_Array(7) & vm & Trans_Array(34)
Mends = pick.delet(Mends, 1, 1, 0)
ChkDate = pick.ICONV(MEDate, "D2")
Valid = pick.locate(ChkDate, Mends, 1, 1, SVAL, posn, SEQN)
Check_Month_Ends = Valid

End Function

Public Function eft_mail(template_path As String, logentry As String, Params As String, Eft_Drop As String) As String

' TA291 - Print (Lenghty) Remittance Advice forms
'Dim cka_mail As Object
'Set cka_mail = CreateObject("CKA_mail.mail")

Dim temp As String, tr_chq_iss As String, Discflag As Integer, chq As String
Dim chqform As String, remit_format As String, Pps_Flg As String, bankac As String
Dim hmsg As String, tape_ref As String, f_banknum As String
Dim request_numbers() As String, Ii As Integer, request As String
Dim table_index As Integer, cnt As Integer, id As String, the_rec As String ', table_bookmark, myset As Recordset, sortby As String
Dim Msg As String, Msg2 As String
Dim clno As String, fax As String, email As String, contact As String
Dim client_rec As String, tr_ct As Integer, max_tr_ct As Integer, totnum As Long
Dim Refs As String, Desc As String, dtes As String, Amts As String, discs As String, pps As String
Dim tref As String, tramt As String, trdisc As String, trpps As String, chq_req As String
Dim new_item As String, path_name As String
Dim subject As String, notes As String, mail_err As String
Dim mail_cnts(1 To 4) As Integer, usecnt As Integer
Dim clname As String, capt As String
Dim database As String, EmailFrom As String
Dim mail_errors As String, pick_cnt As Long

     database = pick.extract(logentry, 2, 0, 0)
     f_banknum = pick.extract(Params, 1, 0, 0): If f_banknum = "1" Then f_banknum = ""
     tape_ref = pick.extract(Params, 2, 0, 0)
     EmailFrom = pick.extract(Params, 3, 0, 0)
     
     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        Ii = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
        If UBound(g_trans_info_array) < 113 Then ReDim Preserve g_trans_info_array(113)
     End If
     
     mail_errors = ""
     tr_chq_iss = "52"   '* chq issue
'
     temp = pick.extract(g_trans_info_array(38), 1, 2, 0)
     If IsNumeric(temp) Then Discflag = CInt(temp) Else Discflag = 0
     temp = pick.extract(g_trans_info_array(38), 1, 2, 0)
     If temp = "1" Then chq = "check" Else chq = "cheque"
     'HMSG=SPACE(10) & 'Remittance Advice for ' & CHQ & ' number '
     chqform = pick.extract(g_trans_info_array(84), 1, 1, 0)
     remit_format = pick.extract(g_trans_info_array(84), 1, 4, 0)
     temp = pick.extract(g_trans_info_array(113), 1, 1, 0)
     If IsNumeric(temp) Then Pps_Flg = CInt(temp) Else Pps_Flg = 0
     bankac = Mid(g_trans_info_array(49), 5, 1)
     
     hmsg = ""
     If tape_ref <> "" Then
        If d3.d3_readstr(database, temp, "CHQ.REC" & f_banknum, tape_ref & ".1") <> 0 Then
        'rderr = PICKRD(f_cur_dbno, "CHQ.REC" & f_banknum & chr(254) & tape_ref & ".1", f_how, temp, 0)
           eft_mail = tape_ref & "is not a valid tape reference on CHQ.REC" & f_banknum: Exit Function
        End If
        hmsg = "Transfer Advice Form for '"
        cnt = 9999
        GoTo 95
     End If
     
     ReDim request_numbers(0)
     mail_cnts(1) = 0: mail_cnts(2) = 0: mail_cnts(3) = 0: mail_cnts(4) = 0
'     table_index = -1: cnt = -1

     cnt = d3.d3_select(logentry, "sselect " & "CHQ.REM.ADVICE" & f_banknum, request_numbers(), pick_cnt, 0, 0)

     If cnt < 0 Then
        eft_mail = "There are no remittance advices to be printed"
        Exit Function
     End If
     cnt = cnt - 1
 
95   For Ii = 0 To cnt
          If tape_ref = "" Then
             request = request_numbers(Ii)
             If request = "" Then Exit For
             capt = (Ii + 1) & " of " & (cnt + 1) & " advice " & request
          Else
             request = tape_ref & "." & (Ii + 1)
             capt = (Ii + 1) & " advice " & request
          End If
          
          If d3.d3_readstr(database, chq_req, "CHQ.REC" & f_banknum, request) <> 0 Then
             If tape_ref = "" Then
                mail_cnts(3) = mail_cnts(3) + 1
                GoTo 105
             End If
             Exit For
          End If
          contact = "": fax = "": email = "": clname = ""
          clno = pick.extract(chq_req, 5, 0, 0)
          If clno <> "" Then
             If d3.d3_readstr(database, client_rec, "CLIENT", clno) <> 0 Then client_rec = ""
             'rderr = PICKRD(f_cur_dbno, "CLIENT" & chr(254) & clno, f_how, client_rec, 0)
             clname = pick.extract(client_rec, 1, 0, 0)
             contact = pick.extract(client_rec, 25, 0, 0)
             'fax = pick.extract(client_rec, 9, 3, 0)
             email = pick.extract(client_rec, 9, 4, 0)
          End If
          
          new_item = make_html_item(template_path, logentry, "0", "CHQ.REC", request, "chq_remit", "6")
          new_item = "<HTML><HEAD></HEAD><BODY>" & new_item
          
          path_name = Eft_Drop & "\" & request & ".htm"
          If make_html_write(path_name, new_item) <> "" Then
             mail_cnts(3) = mail_cnts(3) + 1
             GoTo 105
          End If
          subject = "Remittance Advice for payment " & request & ". "
          If contact <> "" Then subject = subject & "   Attention: " & contact
          If email <> "" Then
             'mail_err = cka_mail.SendMail(subject, notes, subject & ".htm", path_name, email)
             mail_err = SendEmail(EmailFrom, email, "", "", subject, new_item, "", "") 'path_name, request & ".htm")
             If mail_err = "" Then
                mail_cnts(1) = mail_cnts(1) + 1
             Else
                mail_cnts(3) = mail_cnts(3) + 1
             End If
             GoTo 105
          Else
            usecnt = 4 'Else usecnt = 2
            mail_cnts(usecnt) = mail_cnts(usecnt) + 1
          End If
          
105:  Next Ii

      notes = "Mailing completed"
      notes = notes & Chr(254) & mail_cnts(1) & vbTab & " emailed"
      'notes = notes & chr(254) & mail_cnts(2) & vbTab & " faxed"
      notes = notes & Chr(254) & mail_cnts(3) & vbTab & " had errors - not sent"
      notes = notes & Chr(254) & mail_cnts(4) & vbTab & " had no address - needs re-send"
      notes = notes & Chr(254) & mail_cnts(1) + mail_cnts(2) + mail_cnts(3) + mail_cnts(4) & vbTab & " total"
      eft_mail = notes & Chr(254) & mail_errors
          'Set cka_mail = Nothing

End Function
Public Function SendEmail(eFrom, eTo, eCc, eBCc, eSubject, eBody, eAttachment, eAttachmentName) As String

 Dim EmailSend As Object

On Error GoTo ThisErr
 
     Set EmailSend = CreateObject("CDONTS.NewMail")
      EmailSend.From = eFrom
      EmailSend.To = eTo
      EmailSend.BCC = eFrom
      If eCc <> "" Then EmailSend.Cc = eCc
      If eBCc <> "" Then EmailSend.BCC = eBCc
      EmailSend.subject = eSubject
      EmailSend.bodyformat = 0 'CdoBodyFormatHTML
      EmailSend.mailformat = 0
      EmailSend.Body = eBody
      If eAttachment <> "" Then EmailSend.AttachFile eAttachment, eAttachmentName
      EmailSend.Send
     Set EmailSend = Nothing

Exit Function
ThisErr:
 SendEmail = Err.Description & Chr(255) & Err.Number
End Function


Public Function make_html_write(the_Path As String, item_rec As String) As String

Dim filenum As Integer
     
     filenum = FreeFile
     On Error GoTo make_html_write_error
     Open the_Path For Output Access Write As #filenum
     Print #filenum, item_rec
     Close filenum
     make_html_write = ""
     Exit Function
     
make_html_write_error:
     make_html_write = Err & " " & Error$(Err) & vbLf & the_Path
     Exit Function
     
End Function

Public Function make_html_text(html_page As String) As String

Dim nrec As String, pos As Integer, max As Integer, j As Integer

nrec = html_page

pos = InStr(nrec, "<TR>")
If pos <> 0 Then nrec = Mid(nrec, pos + 4)
pos = InStr(nrec, "<P>")
If pos <> 0 Then nrec = Mid(nrec, pos + 3)

Call pick.sr_change(nrec, vbCrLf, Chr(254))
max = pick.DCount(nrec, Chr(254))
For j = max To 1 Step -1
   If Left(pick.extract(nrec, j, 0, 0), 3) = "<tr" Then
      nrec = pick.Replace(nrec, j, 0, 0, "")
   Else
      If Left(pick.extract(nrec, j, 0, 0), 3) = "<ta" Or Left(pick.extract(nrec, j, 0, 0), 3) = "<HR" Or Left(pick.extract(nrec, j, 0, 0), 5) = "<font" Then
         nrec = pick.delet(nrec, j, 0, 0)
      Else
         pos = InStr(pick.extract(nrec, j, 0, 0), "<a")
         If pos <> 0 Then
            nrec = pick.Replace(nrec, j, 0, 0, Left(pick.extract(nrec, j, 0, 0), pos - 1))
         End If
      End If
   End If
Next j
Call pick.sr_change(nrec, Chr(254), vbCrLf)

Call pick.sr_change(nrec, "</tr>", "")
Call pick.sr_change(nrec, vbCrLf & "<TD>", vbTab)
Call pick.sr_change(nrec, vbCrLf & "<TD ALIGN = ""RIGHT"">", vbTab)
Call pick.sr_change(nrec, "<td>", vbTab)
Call pick.sr_change(nrec, "</TD>", "")
Call pick.sr_change(nrec, "</P>", "")
Call pick.sr_change(nrec, "<P>", "")
Call pick.sr_change(nrec, "<BR>", "")
Call pick.sr_change(nrec, vbCrLf & "<th>", vbTab)
Call pick.sr_change(nrec, vbCrLf & "<TH>", vbTab)
Call pick.sr_change(nrec, "<B>", "")
Call pick.sr_change(nrec, "</B>", "")
Call pick.sr_change(nrec, "&nbsp;", "")
Call pick.sr_change(nrec, "</TABLE>", "")
Call pick.sr_change(nrec, "<hr>", "")
Call pick.sr_change(nrec, "<HR>", "")

make_html_text = nrec

End Function











Public Sub SR_HRS(action As Integer, Oflag As Integer, Inp_Hrs As String, Out_Hrs As String, errmsg As String)

Dim max As Integer, Mm As Integer, temp As String
Dim Ihrs As String, Sign As Integer, Hrs As Integer, Mins As Integer
Dim Len_Min As Integer, Ninp_Hrs As String, Nn As Integer, Ohrs As String
'
' This routine will handle the display (or input validation) of
' hours in either of two formats:
'   a)  Hours only  (including fractional hours)  ["OFLAG"=1]
'   b)  Hours and minutes                         ["OFLAG"=0]
'
'  If ACTION = 0, the routine validates INP.HRS is in the correct
'    format (according to OFLAG being set) and sets up OUT.HRS
'    with decimal hours (in ICONV format), setting ERRMSG if an
'    error is detected.
'* Note- On input validation, routine will returen INP.HRS in
'        OCONV('MD2') format (for subsequent re-display)
'  If ACTION = 1, the routine converts INP.HRS to OUT.HRS in
'    the required format ready for display. (INP.HRS is assumed
'    to be in decimal hours ["MD2"] format)
'
'
    max = pick.DCount(Inp_Hrs, ","): Out_Hrs = "": errmsg = ""
    For Mm = 1 To max
       If pick.field(Inp_Hrs, ",", Mm) < 0 Then Sign = -1 Else Sign = 1
       If action Then               ' set OUT_HRS for display
         Ihrs = pick.field(Inp_Hrs, ",", Mm)
         GoSub 100                  ' convert hours to display format
         If Out_Hrs = "" Then Out_Hrs = Ohrs Else Out_Hrs = Out_Hrs & "," & Ohrs
       Else                     ' validate input of INP_HRS
         If IsNumeric(pick.field(Inp_Hrs, ",", Mm)) = 0 Then GoTo 10
         temp = pick.field(Inp_Hrs, ",", Mm)
         If IsNumeric(temp) Then Hrs = CInt(temp) Else Hrs = 0
         Ihrs = pick.ICONV(CStr(Hrs), "MD2")
         If CStr(Hrs) <> pick.oconv(Ihrs, "MD2") Then
10         If Oflag Then
              errmsg = "Invalid hours format (e_g_  2_5 = two and half hours)"
           Else
20            errmsg = "Invalid hours format (e_g_  2_10 = two hours and ten minutes)"
           End If
           Return        ' with error
         End If
'
         If Oflag = 0 Then          ' validate hours and minutes
           Mins = pick.field(pick.field(Inp_Hrs, ",", Mm), "_", 2)
           Len_Min = Len(Mins)
           If Len_Min And Len_Min <> 2 Then GoTo 20
           If Mins > 59 Then GoTo 20
           Hrs = pick.field(pick.field(Inp_Hrs, ",", Mm), "_", 1)
           Mins = pick.oconv(pick.ICONV(CStr(Mins / 60), "MD2"), "MD2")
           Ihrs = pick.ICONV(Hrs + Sign * Mins, "MD2")
         End If
         If Out_Hrs = "" Then Out_Hrs = Ihrs Else Out_Hrs = Out_Hrs & "," & Ihrs
         GoSub 100                  ' re-convert hours to display format
         Ninp_Hrs = ""
         For Nn = 1 To max
            If Nn = Mm Then
               If Ninp_Hrs = "" Then Ninp_Hrs = Ohrs Else Ninp_Hrs = Ninp_Hrs & "," & Ohrs
            Else
               If Ninp_Hrs = "" Then Ninp_Hrs = pick.field(Inp_Hrs, ",", Nn) Else Ninp_Hrs = Ninp_Hrs & "," & pick.field(Inp_Hrs, ",", Nn)
            End If
         Next Nn
         Inp_Hrs = Ninp_Hrs
       End If
    Next Mm
    Return
'
' s/r 100:   Convert hours to required display format
'
100  Hrs = pick.oconv(Ihrs, "MD2")
     If Oflag = 0 Then
        Mins = pick.field(CStr(Hrs), ".", 2)
        Hrs = pick.field(CStr(Hrs), ".", 1)
        Ohrs = pick.oconv(pick.ICONV(Hrs + Sign * pick.oconv(Mins * 60, "MD24"), "MD2"), "MD2")
     Else
        Ohrs = Hrs
     End If
     Return

End Sub




Public Function RSGetWorkSheets(ExcelFile As String, delimiter As String) As String

Dim cnt As Integer, max As Integer, ThisList$
Dim Excel, ExcelBook

    On Error GoTo ThisErr
        
    Set Excel = New Excel.Application
    Set ExcelBook = Excel.Workbooks.Open(ExcelFile)
    max = ExcelBook.Worksheets.Count
        For cnt = 1 To max
            ThisList = ThisList & ExcelBook.Worksheets(cnt).Name
            If cnt < max Then ThisList = ThisList & delimiter
        Next
        ExcelBook.Close
        Set ExcelBook = Nothing
        Set Excel = Nothing
        RSGetWorkSheets = ThisList
 Exit Function
     
ThisErr:
     RSGetWorkSheets = Err.Description & Chr(254)
 
End Function
Public Sub TA2829(logentry As String, Use_rec() As String, Parms As String, Optional ExcelFileName As String = "")
' TA2829 - Employee Pay History Summary - pays in a given period
Dim Oflag As Integer, temp As String, GCOL(8) As Currency, Sul As String
Dim start_date As String, end_date As String, LCNT As Integer
Dim Emp_No As String, Payroll_Dates As String, First As Integer, Payroll_Dates_Len As Integer
Dim Start_Pos As Integer, End_Pos As Integer, DCOL() As Currency, Date_Pos As Integer, Pdate As String, Pp_Trans_Key As String
Dim Pt_Line As String, Gcolct As Integer, emp_rec As String, trans As String
Dim Emp_Name As String, Pay_Mtd As String, Interim As String
Dim Aline As String, Bline As String, Cline As String, Dline As String
Dim Tot1 As Currency
Dim Tot3 As Currency, Tot4 As Currency, Max_Adj As Integer, Adj As Integer, code As String, Adj_Det As String, Hours_This As Currency, Hours_Ytd As Currency
Dim Gross_This As Currency, Gross_Ytd As Currency, Tot_Ytd_Hrs As Currency, Tot_Ytd_Gross As Currency, Ot_Codes As String
Dim Ot_Amt As String, Ot_Hrs As String, Max_M As Integer, M As Integer, Time_Code As String, Max_N As Integer, N As Integer, pos As Integer, Tot_Hrs As Currency
Dim Tot_Gross As Currency, Trans_Pay_Rate As Currency, Out_Pdate As String, Max_Ii As Integer, Ii As Integer, Oh1 As Currency
Dim Oa1 As Currency, Oh2 As Currency, Oa2 As Currency, Max_Pp As Integer, Pp As Integer, Max_Qq As Integer, Qq As Integer, Allow_This_Tot As Currency
Dim Max_All As Integer, All As Integer, Allow_This As Currency, Allow_Ytd As Currency, Adj_Ytd As Currency, Adj_Code As String, Detail As String
Dim Out_Hrs1 As String, Adj_Hrs As Currency, Adj_Hrs_Ytd As Currency, Adj_This As Currency, Max_Ad As Integer, Ad As Integer, Adj_Cd As String
Dim Tot_Ded As Currency, Tot_Ytd_Ded As Currency, Tax_Total As Currency, Ded_Code As String, Ded_Ytd As Currency, Tot_Deducts As Currency
Dim Tot_Emp As Currency, Emp_Ytd As Currency, Max_I As Integer, i As Integer, Ded_This As Currency, Ded_Io As String, Dtype As String, Ddesc As String
Dim Cr_This As Currency, Cr_Ytd As Currency, Max_K As Integer, k As Integer, Pia As Currency, Net_Tot As Currency, Net_Ytd_Tot As Currency
Dim Ykey As String, C_Gross As Currency, C_Ytd_Gross As Currency, C_Ded As Currency, C_Ytd_Ded As Currency, C_Net As Currency, C_Ytd_Net As Currency
Dim Cd, Indx, Othrs As Currency, Otamts As Currency, Desc As String, pick_cnt As Long
Dim total_items As Long, kk As Integer, mylist() As String, ctls As String, database As String
Dim Iipos As Integer, Iiposc As Integer, Iiposd As Integer
Dim Pay_Rate As String, Ot_Rate As String
Dim errmsg As String
Dim want_excel As Integer, max_output As Integer
Dim sentence As String, user As String
Dim Excel As Excel.Application
Dim ExcelBook As Excel.Workbook
Dim ExcelSheet As Excel.WorkSheet
'
    database = pick.extract(logentry, 2, 0, 0)

    ReDim Use_rec(20) As String
    start_date = pick.extract(Parms, 1, 0, 0)
    end_date = pick.extract(Parms, 2, 0, 0)
    want_excel = pick.extractint(Parms, 3, 0, 0)
    max_output = pick.extractint(Parms, 4, 0, 0)
    sentence = pick.extract(Parms, 5, 0, 0)
    user = pick.extract(Parms, 6, 0, 0)
    If want_excel <> "1" Then
        If start_date <> "" And end_date <> "" Then
            Use_rec(19) = "2829 Employee pays for period: " & start_date & " to " & end_date & "  (" & sentence & ")"
        Else
            If start_date = "" And end_date = "" Then
                Use_rec(19) = "2829 Employee pays for period: ALL  (" & sentence & ")"
            Else
                If start_date = "" Then
                    Use_rec(19) = "2829 Employee pays for period: UP TO " & end_date & "  (" & sentence & ")"
                Else
                    Use_rec(19) = "2829 Employee pays for period: FROM " & start_date & "  (" & sentence & ")"
                End If
            End If
        End If
    End If
    LCNT = 1
    If Not pick.date_vb_to_pick(start_date, start_date, 0) Then start_date = "0"
    If Not pick.date_vb_to_pick(end_date, end_date, 0) Then end_date = "99999"

    If d3.d3_readstr(database, ctls, "DICT PP.CONTROL", "@OPTIONS") <> 0 Then
        If want_excel = "1" Then
            ExcelFileName = "Error: @OPTIONS not set up in DICT PP.CONTROL !! "
        Else
            Use_rec(20) = "@OPTIONS not set up in DICT PP.CONTROL !! "
        End If
        Exit Sub
    End If
    Oflag = pick.extractcur(ctls, 32, 0, 0)
'
    total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0)
    If total_items = 0 Then
        If want_excel = "1" Then
            ExcelFileName = "Error: No matches found for selection criteria"
        Else
            Use_rec(20) = "No matches found for selection criteria"
        End If
        Exit Sub
    End If

    For kk = 0 To total_items - 1
        DoEvents
        If max_output > 0 And want_excel <> "1" Then
            If LCNT > max_output Then
                Use_rec(20) = "Output truncated due to volume - please use the 'Excel' option."
                Exit For
            End If
        End If
        Emp_No = mylist(kk)
        If kk > 0 And LCNT > 1 And (kk Mod 50) = 0 Then
            If Left(ExcelBook.Name, 4) = "Book" Then
                ExcelBook.SaveAs filename:="C:\prospect_site\excel\" & ExcelFileName
            Else
                ExcelBook.Save
            End If
        End If
        If d3.d3_readstr(database, Payroll_Dates, "PP.PAY", Emp_No, 32) = 0 Then
            First = 1
            If Payroll_Dates = "" Then GoTo 490
            Payroll_Dates_Len = pick.DCount(Payroll_Dates, Chr(253))
            If pick.locate(start_date, Payroll_Dates, 1, 1, 0, Start_Pos, "DR") = 0 Then
                If Start_Pos = 1 Then
                    GoTo 490
                Else
                    Start_Pos = Start_Pos - 1
                End If
            End If
            If pick.locate(end_date, Payroll_Dates, 1, 1, 0, End_Pos, "DR") = 0 Then
                If End_Pos > Payroll_Dates_Len Then
                    GoTo 490
                End If
            End If
            If d3.d3_readstr(database, emp_rec, "EMPLOYEE", Emp_No) = 0 Then
                ReDim DCOL(8)
                For Date_Pos = Start_Pos To End_Pos Step -1
                    Pdate = pick.extract(Payroll_Dates, 1, Date_Pos, 0)
                    Pp_Trans_Key = Emp_No & "*" & Pdate
                    If d3.d3_readstr(database, trans, "PP.TRANS", Pp_Trans_Key) = 0 Then
                        GoSub 2000
                    End If
                Next Date_Pos
                If First = 0 Then
                    If want_excel = "1" Then
                        ExcelSheet.Cells(LCNT + 1, 2) = "Employee Totals"
                        ExcelSheet.Cells(LCNT + 1, 7) = Format(DCOL(1), "0.00")
                        ExcelSheet.Cells(LCNT + 1, 10) = Format(DCOL(2), "0.00")
                        For Gcolct = 3 To 8
                            ExcelSheet.Cells(LCNT + 1, Gcolct + 10) = Format(DCOL(Gcolct), "0.00")
                        Next Gcolct
                    Else
                        Use_rec(1) = pick.Insert(Use_rec(1), 1, LCNT, 0, " ")
                        Use_rec(2) = pick.Insert(Use_rec(2), 1, LCNT, 0, "Employee Totals")
                        Use_rec(3) = pick.Insert(Use_rec(3), 1, LCNT, 0, "")
                        Use_rec(4) = pick.Insert(Use_rec(4), 1, LCNT, 0, "")
                        Use_rec(5) = pick.Insert(Use_rec(5), 1, LCNT, 0, "")
                        Use_rec(6) = pick.Insert(Use_rec(6), 1, LCNT, 0, "")
                        Use_rec(7) = pick.Insert(Use_rec(7), 1, LCNT, 0, Format(DCOL(1), "0.00"))
                        Use_rec(8) = pick.Insert(Use_rec(8), 1, LCNT, 0, "")
                        Use_rec(9) = pick.Insert(Use_rec(9), 1, LCNT, 0, "")
                        Use_rec(10) = pick.Insert(Use_rec(10), 1, LCNT, 0, Format(DCOL(2), "0.00"))
                        Use_rec(11) = pick.Insert(Use_rec(11), 1, LCNT, 0, "")
                        Use_rec(12) = pick.Insert(Use_rec(12), 1, LCNT, 0, "")
                        For Gcolct = 3 To 8
                            Use_rec(Gcolct + 10) = pick.Insert(Use_rec(Gcolct + 10), 1, LCNT, 0, Format(DCOL(Gcolct), "0.00"))
                        Next Gcolct
                    End If
                    LCNT = LCNT + 1
                    For Gcolct = 1 To 8
                        GCOL(Gcolct) = GCOL(Gcolct) + DCOL(Gcolct)
                    Next Gcolct
                End If
            End If
        End If
490 Next kk         ' 490
'
    If Use_rec(20) = "" And LCNT > 1 Then              ' not truncated output so show totals
        If want_excel = "1" Then
            ExcelSheet.Cells(LCNT + 1, 2) = "Grand Totals"
            ExcelSheet.Cells(LCNT + 1, 7) = Format(GCOL(1), "0.00")
            ExcelSheet.Cells(LCNT + 1, 10) = Format(GCOL(2), "0.00")
            For Gcolct = 3 To 8
                ExcelSheet.Cells(LCNT + 1, Gcolct + 10) = Format(GCOL(Gcolct), "0.00")
            Next Gcolct
        Else
            Use_rec(1) = pick.Insert(Use_rec(1), 1, LCNT, 0, " ")
            Use_rec(2) = pick.Insert(Use_rec(2), 1, LCNT, 0, "Grand Totals")
            Use_rec(3) = pick.Insert(Use_rec(3), 1, LCNT, 0, "")
            Use_rec(4) = pick.Insert(Use_rec(4), 1, LCNT, 0, "")
            Use_rec(5) = pick.Insert(Use_rec(5), 1, LCNT, 0, "")
            Use_rec(6) = pick.Insert(Use_rec(6), 1, LCNT, 0, "")
            Use_rec(7) = pick.Insert(Use_rec(7), 1, LCNT, 0, Format(GCOL(1), "0.00"))
            Use_rec(8) = pick.Insert(Use_rec(8), 1, LCNT, 0, "")
            Use_rec(9) = pick.Insert(Use_rec(9), 1, LCNT, 0, "")
            Use_rec(10) = pick.Insert(Use_rec(10), 1, LCNT, 0, Format(GCOL(2), "0.00"))
            Use_rec(11) = pick.Insert(Use_rec(11), 1, LCNT, 0, "")
            Use_rec(12) = pick.Insert(Use_rec(12), 1, LCNT, 0, "")
            For Gcolct = 3 To 8
                Use_rec(Gcolct + 10) = pick.Insert(Use_rec(Gcolct + 10), 1, LCNT, 0, Format(GCOL(Gcolct), "0.00"))
            Next Gcolct
        End If
    End If
    If want_excel = "1" Then
        If LCNT = 1 Then
            ExcelFileName = "Error: No records found for pay period."
        Else
            ExcelSheet.Application.Columns.AutoFit
            ExcelSheet.Application.Rows.AutoFit
            If ExcelSheet.Columns("B").ColumnWidth > 90 Then
                ExcelSheet.Columns("B").ColumnWidth = 25
            End If
            ExcelSheet.Columns("C").ColumnWidth = 1
            ExcelSheet.Columns("E").NumberFormat = "0.00"
            ExcelSheet.Columns("F").NumberFormat = "0.0000"
            ExcelSheet.Columns("G").NumberFormat = "0.00"
            ExcelSheet.Columns("H").NumberFormat = "0.00"
            ExcelSheet.Columns("I").NumberFormat = "0.0000"
            ExcelSheet.Columns("L").NumberFormat = "0.00"
            ExcelSheet.Columns("M").NumberFormat = "0.00"
            ExcelSheet.Columns("N").NumberFormat = "0.00"
            ExcelSheet.Columns("O").NumberFormat = "0.00"
            ExcelSheet.Columns("P").NumberFormat = "0.00"
            ExcelSheet.Columns("Q").NumberFormat = "0.00"
            ExcelSheet.Columns("R").NumberFormat = "0.00"
            If Left(ExcelBook.Name, 4) = "Book" Then
                ExcelBook.SaveAs filename:="C:\prospect_site\excel\" & ExcelFileName
            Else
                ExcelBook.Save
            End If
            ExcelBook.Close SaveChanges:=True
            Excel.Quit
            Set ExcelSheet = Nothing
            Set ExcelBook = Nothing
            Set Excel = Nothing
        End If
    End If
    Exit Sub
'
'*** Processing PP.TRANS entry
'
2000
    Aline = ""
    Bline = ""
    Cline = ""
    Dline = ""
    Tot1 = 0
    Tot3 = 0
    Tot4 = 0
    If First Then
        First = 0
        Emp_Name = pick.extract(trans, 1, 0, 0)
        Pay_Mtd = pick.extract(emp_rec, 41, 0, 0)
    End If
    If pick.extract(trans, 36, 0, 0) <> "" Then Interim = "I" Else Interim = ""
'
'**  Subtracting adjustments( included in Gross ) to get actual Gross
    Max_Adj = pick.DCount(pick.extract(trans, 51, 0, 0), Chr(253))
    For Adj = 1 To Max_Adj
        code = pick.extract(trans, 51, Adj, 0)
        If d3.d3_readstr(database, Adj_Det, "PP.ADJUST", code) <> 0 Then Adj_Det = ""
        If pick.extract(Adj_Det, 7, 0, 0) = "H" Then
            Tot1 = Tot1 + (pick.extractcur(trans, 52, Adj, 1) / 100) ' TOT1 = sumof YTD adj. hrs. this pay
            Tot4 = Tot4 + (pick.extractcur(trans, 52, Adj, 2) / 100) ' TOT4 = sumof YTD adj. hrs.year-to-date
        End If
        Tot3 = Tot3 + (pick.extractcur(trans, 53, Adj, 2) / 100)   '    TOT3 = sumof YTD adj. amounts year-to-date
    Next Adj
    Hours_This = (pick.extractcur(trans, 29, 1, 0) / 100) - Tot1
    Hours_Ytd = (pick.extractcur(trans, 29, 2, 0) / 100) - Tot4
    Gross_This = pick.extractcur(trans, 4, 1, 0) / 100
    Gross_Ytd = (pick.extractcur(trans, 5, 0, 0) / 100) - Tot3
    Tot_Ytd_Hrs = Hours_Ytd
    Tot_Ytd_Gross = Gross_Ytd
    Ot_Codes = pick.extract(trans, 12, 0, 0)
    Ot_Amt = pick.extract(trans, 13, 0, 0)
    Ot_Hrs = pick.extract(trans, 32, 0, 0)
    
    Max_Ii = pick.DCount(pick.extract(Ot_Codes, 1, 0, 0), Chr(253))
    For Ii = 1 To Max_Ii
        Oa1 = pick.extractcur(Ot_Amt, 1, Ii, 1) / 100
        Ot_Amt = pick.Replace(Ot_Amt, 1, Ii, 1, pick.extractcur(Ot_Amt, 1, Ii, 1) / 100)
        Ot_Amt = pick.Replace(Ot_Amt, 1, Ii, 2, pick.extractcur(Ot_Amt, 1, Ii, 2) / 100)
        Ot_Hrs = pick.Replace(Ot_Hrs, 1, Ii, 1, pick.extractcur(Ot_Hrs, 1, Ii, 1) / 100)
        Ot_Hrs = pick.Replace(Ot_Hrs, 1, Ii, 2, pick.extractcur(Ot_Hrs, 1, Ii, 2) / 100)
    Next Ii
'
'****  Special rates  *****
     'If Pick.extract(trans, 55, 0, 0) <> "" Then
    Max_M = pick.DCount(pick.extract(trans, 55, 0, 0), Chr(253))
    For M = 1 To Max_M
        Time_Code = pick.extract(trans, 55, M, 0)
        Max_N = pick.DCount(pick.extract(trans, 56, M, 0), Chr(252))
        For N = 1 To Max_N
            Select Case Time_Code
                Case "1.00"
                    Gross_This = Gross_This - (pick.extractcur(trans, 58, M, N) / 100)
                    Hours_This = Hours_This - (pick.extractcur(trans, 57, M, N) / 100)
                 Case Else
                    If pick.locate(Time_Code, Ot_Codes, 1, 1, 0, pos, "") = 0 Then pos = 0
                    If pos = 0 Then
                        Use_rec(LCNT) = "CANT locate " & Time_Code & " IN " & Ot_Codes
                    Else
                        Ot_Amt = pick.Replace(Ot_Amt, 1, pos, 1, pick.extractcur(Ot_Amt, 1, pos, 1) - (pick.extractcur(trans, 58, M, N) / 100))
                        Ot_Hrs = pick.Replace(Ot_Hrs, 1, pos, 1, pick.extractcur(Ot_Hrs, 1, pos, 1) - (pick.extractcur(trans, 57, M, N) / 100))
                    End If
            End Select
        Next N
    Next M
     'End If
    Tot_Hrs = Hours_This
    Tot_Gross = Gross_This
    Trans_Pay_Rate = pick.extractcur(trans, 35, 0, 0) / 10000
    'Out_Hrs1 = CStr(Hours_This) ' SR_HRS 1, Oflag, CStr(Hours_This), Out_Hrs1, errmsg
    Out_Pdate = pick.oconv(Pdate, "D2")
    Out_Pdate = Format(Pdate + 24837, "ddmmmyy")
'    Out_Pdate = Mid$(Out_Pdate, 1, 2) & Mid$(Out_Pdate, 4, 3) & Mid$(Out_Pdate, 8, 2)
    DCOL(1) = DCOL(1) + Gross_This
'
    Iipos = 0
    Max_Ii = pick.DCount(pick.extract(Ot_Codes, 1, 0, 0), Chr(253))
    For Ii = 1 To Max_Ii
        Oa1 = pick.extractcur(Ot_Amt, 1, Ii, 1)
        Oh2 = pick.extractcur(Ot_Hrs, 1, Ii, 2)
        Oa2 = pick.extractcur(Ot_Amt, 1, Ii, 2)
        Oh1 = pick.extractcur(Ot_Hrs, 1, Ii, 1)
        If Oa1 <> 0 Or Oh1 <> 0 Then
            Ot_Rate = ""
            If Trans_Pay_Rate <> 0 Then
                    Ot_Rate = pick.extractcur(Ot_Codes, 1, Ii, 0) * Trans_Pay_Rate
            End If
            Iipos = Iipos + 1
            Bline = pick.Insert(Bline, 1, Iipos, 0, Format(Oh1, "0.00"))
            Bline = pick.Insert(Bline, 2, Iipos, 0, Format(Ot_Rate, "0.0000"))
            Bline = pick.Insert(Bline, 3, Iipos, 0, Format(Oa1, "0.00"))
            DCOL(2) = DCOL(2) + Oa1
        End If
        Tot_Ytd_Hrs = Tot_Ytd_Hrs + Oh2
        Tot_Gross = Tot_Gross + Oa1
        Tot_Ytd_Gross = Tot_Ytd_Gross + Oa2
    Next Ii
'
    Iiposc = 0
    Max_Pp = pick.DCount(pick.extract(trans, 55, 0, 0), Chr(253))
    For Pp = 1 To Max_Pp
        Max_Qq = pick.DCount(pick.extract(trans, 56, Pp, 0), Chr(252))
        For Qq = 1 To Max_Qq
            Oa1 = pick.extractcur(trans, 58, Pp, Qq) / 100
            Oh1 = pick.extractcur(trans, 57, Pp, Qq) / 100
            If Oh1 <> 0 Or Oa1 <> 0 Then
                Ot_Rate = pick.extractcur(trans, 55, Pp, Qq)
                Ot_Rate = CCur(Ot_Rate) * pick.extractcur(trans, 55, Pp, 0)
                If pick.extract(trans, 55, Pp, 0) = "1.00" Then
                    Iiposc = Iiposc + 1
                    Cline = pick.Insert(Cline, 1, Iiposc, 0, Format(Oh1, "0.00"))
                    Cline = pick.Insert(Cline, 2, Iiposc, 0, Format(Ot_Rate, "0.0000"))
                    Cline = pick.Insert(Cline, 3, Iiposc, 0, Format(Oa1, "0.00"))
                    DCOL(1) = DCOL(1) + Oa1
                Else
                    Iipos = Iipos + 1
                    Bline = pick.Insert(Bline, 1, Iipos, 0, Format(Oh1, "0.00"))
                    Bline = pick.Insert(Bline, 2, Iipos, 0, Format(Ot_Rate, "0.0000"))
                    Bline = pick.Insert(Bline, 3, Iipos, 0, Format(Oa1, "0.00"))
                    DCOL(2) = DCOL(2) + Oa1
                End If
            End If
            Tot_Gross = Tot_Gross + Oa1
        Next Qq
    Next Pp
'
'****  Allowances  *****
    Allow_This_Tot = 0
    Max_All = pick.DCount(pick.extract(trans, 8, 0, 0), Chr(253))
    For All = 1 To Max_All
        Allow_This = pick.extractcur(trans, 10, All, 1) / 100
        Allow_This_Tot = Allow_This_Tot + Allow_This
        Allow_Ytd = pick.extractcur(trans, 9, All, 2) / 100
        If Allow_This <> 0 Or Allow_Ytd <> 0 Then
            Tot_Gross = Tot_Gross + Allow_This
            Tot_Ytd_Gross = Tot_Ytd_Gross + Allow_Ytd
        End If
    Next All
'
'****  Adjustments  (Included in Gross) *****
    Adj_Ytd = 0
    Iiposd = 0
    Max_Adj = pick.DCount(pick.extract(trans, 51, 0, 0), Chr(253))
    For Adj = 1 To Max_Adj
        Adj_Code = pick.extract(trans, 51, Adj, 0)
        If d3.d3_readstr(database, Adj_Det, "PP.ADJUST", Adj_Code) <> 0 Then Adj_Det = ""
        Detail = pick.extract(Adj_Det, 1, 0, 0)
'        Out_Hrs1 = ""
        If pick.extract(Adj_Det, 7, 0, 0) <> "D" Then
            Adj_Hrs = pick.extractcur(trans, 52, Adj, 1) / 100
            Adj_Hrs_Ytd = pick.extractcur(trans, 52, Adj, 2) / 100
            'SR_HRS 1, Oflag, Adj_Hrs, Out_Hrs1, errmsg
            Tot_Ytd_Hrs = Tot_Ytd_Hrs + Adj_Hrs_Ytd
        End If
        Adj_This = pick.extractcur(trans, 53, Adj, 1) / 100
        If (pick.extract(Adj_Det, 7, 0, 0) = "H" Or _
            pick.extract(Adj_Det, 7, 0, 0) = "X") And _
            Adj_This <> 0 Then
            Iiposd = Iiposd + 1
            Dline = pick.Insert(Dline, 1, Iiposd, 0, Detail)
            Dline = pick.Insert(Dline, 2, Iiposd, 0, Format(Adj_Hrs, "0.00"))
            Dline = pick.Insert(Dline, 3, Iiposd, 0, Format(Adj_This, "0.00"))
            DCOL(3) = DCOL(3) + Adj_This
        Else
            Allow_This_Tot = Allow_This_Tot + Adj_This
        End If
        Adj_Ytd = pick.extractcur(trans, 53, Adj, 2) / 100
        Tot_Gross = Tot_Gross + Adj_This
        Tot_Ytd_Gross = Tot_Ytd_Gross + Adj_Ytd
    Next Adj
'
'**** Adjustments (NOT included in gross) *****
    Max_Ad = pick.DCount(pick.extract(trans, 15, 0, 0), Chr(253))
    For Ad = 1 To Max_Ad
        Adj_Cd = pick.extract(trans, 15, Ad, 0)
        If d3.d3_readstr(database, Adj_Det, "PP.ADJUST", Adj_Cd) <> 0 Then Adj_Det = ""
        If pick.extract(Adj_Det, 2, 0, 0) = "O" Then
            Adj = Adj + 1
            temp = pick.extractcur(trans, 16, Ad, 1)
            Adj_This = pick.extractcur(trans, 16, Ad, 1) / 100
            Allow_This_Tot = Allow_This_Tot + Adj_This
            Adj_Ytd = pick.extractcur(trans, 16, Adj, 2) / 100
            Tot_Gross = Tot_Gross + Adj_This
            Tot_Ytd_Gross = Tot_Ytd_Gross + Adj_Ytd
        End If
    Next Ad
'
'****  Tax  *****
    Tot_Ded = pick.extractcur(trans, 7, 1, 0) / 100
    Tot_Ytd_Ded = pick.extractcur(trans, 7, 2, 0) / 100
    Tax_Total = Tot_Ded + (pick.extractcur(trans, 7, 4, 0) / 100)
'
'****  Deductions  *****
    Ded_Code = ""
    Ded_Ytd = 0
    Tot_Deducts = 0
    Tot_Emp = 0
    Emp_Ytd = 0
    Max_I = pick.DCount(pick.extract(trans, 18, 0, 0), Chr(253))
    For i = 1 To Max_I
        Ded_Code = pick.extract(trans, 18, i, 0)
        Ded_This = pick.extractcur(trans, 19, i, 1) / 100
        Ded_Ytd = pick.extractcur(trans, 19, i, 2) / 100
        If Ded_This <> 0 Or Ded_Ytd <> 0 Then
            If d3.d3_readstr(database, Ded_Io, "PP.DEDUCT", Ded_Code) <> 0 Then Ded_Io = ""
            Dtype = pick.extract(Ded_Io, 2, 0, 0)
            Ddesc = pick.extract(Ded_Io, 1, 0, 0)
            Select Case Dtype
                Case "C"           ' employer contribution
                    Tot_Emp = Tot_Emp + Ded_This
                    Emp_Ytd = Emp_Ytd + Ded_Ytd
                Case Dtype = "S"           ' salary sacrifice
                    Iiposd = Iiposd + 1
                    Dline = pick.Insert(Dline, 1, Iiposd, 0, Ddesc)
                    Dline = pick.Insert(Dline, 2, Iiposd, 0, "")
                    Dline = pick.Insert(Dline, 3, Iiposd, 0, Format(Ded_This, "0.00"))
                    DCOL(3) = DCOL(3) - Ded_This
                    Tot_Gross = Tot_Gross - Ded_This
                    Tot_Ytd_Gross = Tot_Ytd_Gross - Ded_Ytd
                Case Else                     ' type D, employee deductions
                    Tot_Deducts = Tot_Deducts + Ded_This
                    Tot_Ded = Tot_Ded + Ded_This
                    Tot_Ytd_Ded = Tot_Ytd_Ded + Ded_Ytd
            End Select
        End If
    Next i
'
'****  Accounts creditted  *****
    Cr_This = 0
    Cr_Ytd = 0
    Max_K = pick.DCount(pick.extract(trans, 20, 0, 0), Chr(253))
    For k = 1 To Max_K
        Cr_This = Cr_This + pick.extractcur(trans, 21, k, 1) / 100
        Cr_Ytd = Cr_Ytd + pick.extractcur(trans, 21, k, 2) / 100
    Next k
    Tot_Deducts = Tot_Deducts + Cr_This
    Tot_Ded = Tot_Ded + Cr_This
    Tot_Ytd_Ded = Tot_Ytd_Ded + Cr_Ytd
    Pia = pick.extractcur(trans, 25, 2, 0) / 100
    Pia = Pia + pick.extractcur(trans, 48, 2, 0) / 100
'
    Max_K = pick.DCount(pick.extract(trans, 39, 0, 0), Chr(253))
    For k = 1 To Max_K
        Pia = Pia + pick.extractcur(trans, 40, k, 2) / 100
    Next k
    If Pia <> 0 Then
        Tot_Ded = Tot_Ded + Pia
        Tot_Deducts = Tot_Deducts + Pia
    End If
'
'****  Net pay  *****
    Net_Tot = pick.extractcur(trans, 24, 1, 0) / 100
    Net_Ytd_Tot = pick.extractcur(trans, 24, 2, 1) / 100
    
    DCOL(4) = DCOL(4) + Allow_This_Tot
    DCOL(5) = DCOL(5) + Tot_Gross
    DCOL(6) = DCOL(6) + Tax_Total
    DCOL(7) = DCOL(7) + Tot_Deducts
    DCOL(8) = DCOL(8) + Net_Tot
    
    If want_excel = "1" And LCNT = 1 Then
        On Error GoTo Err_Excelopen
        Set Excel = New Excel.Application
        Excel.Visible = False
        Set ExcelBook = Excel.Workbooks.Add
        Set ExcelSheet = ExcelBook.Worksheets(1)
        On Error GoTo 0
        ExcelFileName = user & "_employee_" & Format(Date, "ddmmmyy") & "_" & Replace(CStr(Timer), ".", "") & ".xls"
        ExcelSheet.Cells(1, 2) = "Employee"
        ExcelSheet.Cells(1, 4) = "Pay Date"
        ExcelSheet.Cells(1, 5) = "Ordinary Hours"
        ExcelSheet.Cells(1, 6) = "Ordinary Rate"
        ExcelSheet.Cells(1, 7) = "Ordinary Wages"
        ExcelSheet.Cells(1, 8) = "Overtime Hours"
        ExcelSheet.Cells(1, 9) = "Overtime Rate"
        ExcelSheet.Cells(1, 10) = "Overtime Wages"
        ExcelSheet.Cells(1, 11) = "Other Description"
        ExcelSheet.Cells(1, 12) = "Other Hours"
        ExcelSheet.Cells(1, 13) = "Other Wages"
        ExcelSheet.Cells(1, 14) = "Adj's/ Allow's"
        ExcelSheet.Cells(1, 15) = "Gross Wages"
        ExcelSheet.Cells(1, 16) = "Tax"
        ExcelSheet.Cells(1, 17) = "Deductions"
        ExcelSheet.Cells(1, 18) = "Net"
        For k = 1 To 18
            ExcelSheet.Cells(1, k).HorizontalAlignment = xlCenter
            ExcelSheet.Cells(1, k).Font.Bold = True
        Next k
    End If
    
    Max_K = Iipos + Iiposc
    If Iiposd > Max_K Then Max_K = Iiposd
    If Max_K = 0 Then Max_K = 1
    For k = 1 To Max_K
        If want_excel = "1" Then
            ExcelSheet.Cells(LCNT + 1, 1) = Emp_No
            ExcelSheet.Cells(LCNT + 1, 2) = Emp_Name
            ExcelSheet.Cells(LCNT + 1, 3) = Interim
            ExcelSheet.Cells(LCNT + 1, 4) = Out_Pdate
            ExcelSheet.Cells(LCNT + 1, 5) = Format(Hours_This, "0.00")
            ExcelSheet.Cells(LCNT + 1, 6) = Format(Trans_Pay_Rate, "0.0000")
            ExcelSheet.Cells(LCNT + 1, 7) = Format(Gross_This, "0.00")
            ExcelSheet.Cells(LCNT + 1, 14) = Format(Allow_This_Tot, "0.00")
            ExcelSheet.Cells(LCNT + 1, 15) = Format(Tot_Gross, "0.00")
            ExcelSheet.Cells(LCNT + 1, 16) = Format(Tax_Total, "0.00")
            ExcelSheet.Cells(LCNT + 1, 17) = Format(Tot_Deducts, "0.00")
            ExcelSheet.Cells(LCNT + 1, 18) = Format(Net_Tot, "0.00")
        Else
            Use_rec(1) = pick.Insert(Use_rec(1), 1, LCNT, 0, Emp_No)
            Use_rec(2) = pick.Insert(Use_rec(2), 1, LCNT, 0, Emp_Name)
            Use_rec(3) = pick.Insert(Use_rec(3), 1, LCNT, 0, Interim)
            Use_rec(4) = pick.Insert(Use_rec(4), 1, LCNT, 0, Out_Pdate)
            Use_rec(5) = pick.Insert(Use_rec(5), 1, LCNT, 0, Format(Hours_This, "0.00"))
            Use_rec(6) = pick.Insert(Use_rec(6), 1, LCNT, 0, Format(Trans_Pay_Rate, "0.0000"))
            Use_rec(7) = pick.Insert(Use_rec(7), 1, LCNT, 0, Format(Gross_This, "0.00"))
            Use_rec(14) = pick.Insert(Use_rec(14), 1, LCNT, 0, Format(Allow_This_Tot, "0.00"))
            Use_rec(15) = pick.Insert(Use_rec(15), 1, LCNT, 0, Format(Tot_Gross, "0.00"))
            Use_rec(16) = pick.Insert(Use_rec(16), 1, LCNT, 0, Format(Tax_Total, "0.00"))
            Use_rec(17) = pick.Insert(Use_rec(17), 1, LCNT, 0, Format(Tot_Deducts, "0.00"))
            Use_rec(18) = pick.Insert(Use_rec(18), 1, LCNT, 0, Format(Net_Tot, "0.00"))
        End If
        If k > Iiposc Then
            If k > Iipos Then
                If want_excel <> "1" Then
                    Use_rec(8) = pick.Insert(Use_rec(8), 1, LCNT, 0, "")
                    Use_rec(9) = pick.Insert(Use_rec(9), 1, LCNT, 0, "")
                    Use_rec(10) = pick.Insert(Use_rec(10), 1, LCNT, 0, "")
                End If
            Else
                If want_excel = "1" Then
                    ExcelSheet.Cells(LCNT + 1, 8) = pick.extract(Bline, 1, k, 0)
                    ExcelSheet.Cells(LCNT + 1, 9) = pick.extract(Bline, 2, k, 0)
                    ExcelSheet.Cells(LCNT + 1, 10) = pick.extract(Bline, 3, k, 0)
                Else
                    Use_rec(8) = pick.Insert(Use_rec(8), 1, LCNT, 0, pick.extract(Bline, 1, k, 0))
                    Use_rec(9) = pick.Insert(Use_rec(9), 1, LCNT, 0, pick.extract(Bline, 2, k, 0))
                    Use_rec(10) = pick.Insert(Use_rec(10), 1, LCNT, 0, pick.extract(Bline, 3, k, 0))
                End If
            End If
        Else
            If want_excel = "1" Then
                ExcelSheet.Cells(LCNT + 1, 8) = pick.extract(Cline, 1, k, 0)
                ExcelSheet.Cells(LCNT + 1, 9) = pick.extract(Cline, 2, k, 0)
                ExcelSheet.Cells(LCNT + 1, 10) = pick.extract(Cline, 3, k, 0)
            Else
                Use_rec(8) = pick.Insert(Use_rec(8), 1, LCNT, 0, pick.extract(Cline, 1, k, 0))
                Use_rec(9) = pick.Insert(Use_rec(9), 1, LCNT, 0, pick.extract(Cline, 2, k, 0))
                Use_rec(10) = pick.Insert(Use_rec(10), 1, LCNT, 0, pick.extract(Cline, 3, k, 0))
            End If
        End If
        If k > Iiposd Then
            If want_excel <> "1" Then
                Use_rec(11) = pick.Insert(Use_rec(11), 1, LCNT, 0, "")
                Use_rec(12) = pick.Insert(Use_rec(12), 1, LCNT, 0, "")
                Use_rec(13) = pick.Insert(Use_rec(13), 1, LCNT, 0, "")
            End If
        Else
            If want_excel = "1" Then
                ExcelSheet.Cells(LCNT + 1, 11) = pick.extract(Dline, 1, k, 0)
                ExcelSheet.Cells(LCNT + 1, 12) = pick.extract(Dline, 2, k, 0)
                ExcelSheet.Cells(LCNT + 1, 13) = pick.extract(Dline, 3, k, 0)
            Else
                Use_rec(11) = pick.Insert(Use_rec(11), 1, LCNT, 0, pick.extract(Dline, 1, k, 0))
                Use_rec(12) = pick.Insert(Use_rec(12), 1, LCNT, 0, pick.extract(Dline, 2, k, 0))
                Use_rec(13) = pick.Insert(Use_rec(13), 1, LCNT, 0, pick.extract(Dline, 3, k, 0))
            End If
        End If
        LCNT = LCNT + 1
    Next k
'
    If (Tot_Gross - Tot_Ded) <> Net_Tot Then
        temp = "#### ERROR - Total GROSS (" & Tot_Gross & ") less Total DEDUCTIONS (" & _
            Tot_Ded & ") not equal to Total NET (" & Net_Tot & ") ####"
        If want_excel = "1" Then
            ExcelSheet.Cells(LCNT + 1, 2) = temp
        Else
            Use_rec(1) = pick.Insert(Use_rec(1), 1, LCNT, 0, " ")
            Use_rec(2) = pick.Insert(Use_rec(2), 1, LCNT, 0, temp)
            For k = 3 To 18
                Use_rec(k) = pick.Insert(Use_rec(k), 1, LCNT, 0, "")
            Next k
        End If
        LCNT = LCNT + 1
    End If
    If (Tot_Ytd_Gross - Tot_Ytd_Ded) <> Net_Ytd_Tot Then
        temp = "#### ERROR - Total YTD Gross (" & Tot_Ytd_Gross & ") less Total YTD Deductions (" & _
            Tot_Ytd_Ded & ") not equal to Total YTD Net (" & Net_Ytd_Tot & ") ####"
        If want_excel = "1" Then
            ExcelSheet.Cells(LCNT + 1, 2) = temp
        Else
            Use_rec(1) = pick.Insert(Use_rec(1), 1, LCNT, 0, " ")
            Use_rec(2) = pick.Insert(Use_rec(2), 1, LCNT, 0, temp)
            For k = 3 To 18
                Use_rec(k) = pick.Insert(Use_rec(k), 1, LCNT, 0, "")
            Next k
        End If
        LCNT = LCNT + 1
    End If
    Return
    
Err_Excelopen:
    ExcelFileName = "Error: " & Err.Number & "<BR>" & Err.Description
    Exit Sub

End Sub
Public Function RSGetWorksheetPrefs(PrefsFile$, ExcelFile$, WorkSheet$) As String
  
   Dim FileContents$, Prefs, PrefLines, cnt As Integer
   
   On Error GoTo ThisErr

   RSGetWorksheetPrefs = ""

   If d3.ReadDosFile(PrefsFile, FileContents) Then
     PrefLines = Split(FileContents, vbCrLf)
     For cnt = 0 To UBound(PrefLines)
      If PrefLines(cnt) <> "" Then
         Prefs = Split(PrefLines(cnt), Chr(254))
         If UCase(Prefs(0)) = UCase(ExcelFile) And UCase(Prefs(2)) = UCase(WorkSheet) Then
            RSGetWorksheetPrefs = CStr(PrefLines(cnt))
            Exit For
         End If
      End If
     Next
   Else
      Err.Raise vbError + 500, , "File Not Found: " & PrefsFile
   End If

Exit Function


ThisErr:
     RSGetWorksheetPrefs = Err.Description & Chr(253)

End Function



Public Function RSSetWorksheetPrefs(PrefsFile$, ExcelFile$, WorkSheet$, NewPrefs$) As String
  
   Dim FileContents$, Prefs, PrefLines, NewContents$
   Dim fso As FileSystemObject, textfile As TextStream
   Dim LineNum As Integer, cnt As Integer

   On Error GoTo ThisErr
   
   Set fso = New Scripting.FileSystemObject
   LineNum = -1
       
   If d3.ReadDosFile(PrefsFile, FileContents) Then
     PrefLines = Split(FileContents, vbCrLf)
     For cnt = 0 To UBound(PrefLines)
      If PrefLines(cnt) <> "" Then
         Prefs = Split(PrefLines(cnt), Chr(254))
         If UCase(Prefs(0)) = UCase(ExcelFile) And UCase(Prefs(2)) = UCase(WorkSheet) Then
            LineNum = cnt
            Exit For
         End If
      End If
     Next
     If LineNum > -1 Then
        Set textfile = fso.OpenTextFile(PrefsFile, ForWriting, False)
        PrefLines(LineNum) = NewPrefs
        NewContents = Join(PrefLines, vbCrLf)
        textfile.Write NewContents
        textfile.Close
     Else
        Set textfile = fso.OpenTextFile(PrefsFile, ForAppending, False)
        textfile.WriteLine NewPrefs
        textfile.Close
     End If
   Else
      Set textfile = fso.OpenTextFile(PrefsFile, ForWriting, True)
      textfile.WriteLine NewPrefs
      textfile.Close
   End If
  
   
Exit Function


ThisErr:
     RSSetWorksheetPrefs = Err.Description & Chr(254)

End Function

Public Function TestLocks() As String

Dim item$, PickFile$, NextDebtorNum$, NewDebtorNum$
'Dim ATNumber As New clsD3DynamicArray
'Dim ReadStatus As FileStatus
Dim MaxTime As Integer, cnt As Integer

MaxTime = 25 'raise error if item locked for 5 secs or more

item = "@NUMBER"
PickFile = "DICT CLIENT"

      'ReadStatus = ITEM_ISLOCKED
      'Do While ReadStatus = ITEM_ISLOCKED
         'ReadStatus = d3.d3_openfile("logis", PickFile, Item, "RU", ATNumber) 'lock item
      '   If ReadStatus = ITEM_ISLOCKED Then
      '      Call d3.d3_Pause(0.2)  'Poll file,item  5x/sec for release
      '   End If
      '   cnt = cnt + 1
      '   If cnt = MaxTime Then Err.Raise vbObjectError + 550, "ckaiis.ThisFunctionName", "Item " & item & " is locked"
      'Loop

   'If ReadStatus = SUCCESS Then
      'NextDebtorNum = ATNumber.brExtractStr(1)
      NewDebtorNum = CLng(NextDebtorNum) + 1
      'Call ATNumber.brReplaceStr(NewDebtorNum, 1)
      'ReadStatus = d3.d3_openfile("logis", PickFile, Item, "W", ATNumber)
'item lock automatically released with write
   'End If

 TestLocks = NewDebtorNum

End Function



Private Function set_tabs(f_cols() As String, f_col_tabs()) As Integer

Dim adjust As Integer, col_count  As Integer, j As Integer
Dim test_tab_head, test_tab_line
Dim use_tot_width, have_a_mline As Integer
Dim adjust_mline
Dim pwidth, testwidth

     set_tabs = True
     'use_tot_width = tot_width * 0.95
' want toprint down page
'     If Not (columnar) Then
'        ReDim f_col_tabs(3): f_col_tabs(1) = 0: f_col_tabs(2) = 0: f_col_tabs(3) = use_tot_width
'        col_count = 0
'        For j = 0 To f_grid_cols
'           If List1.Selected(j) Then
'              col_count = col_count + 1
'              ReDim Preserve f_col_wanted(col_count)
'              GoSub set_tabs_col
'              If test_tab_head > f_col_tabs(2) Then f_col_tabs(2) = test_tab_head
'           End If
'        Next j
'        GoTo set_tabs_exit
'     End If

' want columnar format
     have_a_mline = False
     adjust = 10: adjust_mline = 10
     
c_ok_tabs:
     'col_count = 0
     ReDim Preserve f_col_tabs(0): f_col_tabs(0) = 0

    Printer.ScaleWidth = 132
    pwidth = Printer.ScaleWidth
    testwidth = 1 'Printer.TextWidth("W")
    'MsgBox pwidth & "=" & testwidth & "=" & pwidth / testwidth
     
     For j = 0 To UBound(f_cols) - 1

           'col_count = col_count + 1
           ReDim Preserve f_col_tabs(j + 1)
           test_tab_line = (Len(f_cols(j)) + 1)  'testwidth * pwidth /
           'MsgBox pwidth & "=" & testwidth & "=" & Len(f_cols(j))
           'End
           'MsgBox String(Len(f_cols(j)) + 1, "W") & "=" & test_tab_line & "=" & Printer.Width
           'End
           'GoSub set_tabs_col
                     
'           If f_col_info(j, 4) = "4" Then 'mline flag
'              test_tab_line = test_tab_line * adjust_mline / 10
'              have_a_mline = True
'           Else
              'If test_tab_line > 791 Then ' do not make small widths too small
              '   If Left(f_col_info(f_col_wanted(col_count) - 1, 3), 1) <> "D" And Left(f_col_info(f_col_wanted(col_count) - 1, 3), 2) <> "MD" Then
              '      If has_a_space Then test_tab_line = test_tab_line * adjust / 10
              '   End If
              'End If
'           End If
           
           'If test_tab_head > test_tab_line Then test_tab_line = test_tab_head

           f_col_tabs(j + 1) = f_col_tabs(j) + test_tab_line
           'MsgBox f_col_tabs(j + 1) & "=" & f_cols(j) & "=" & j
           'If f_col_tabs(col_count + 1) > use_tot_width Then
           '   If f_font_headings_increase > 0 Then
           '      f_font_headings_increase = f_font_headings_increase - 1
           '      GoTo c_ok_tabs
           '   End If
           '   If Not have_a_mline Then
           '      adjust_mline = 0.2
           '   Else
           '      If adjust_mline = 1 Then adjust_mline = 0.2: GoTo c_ok_tabs
           '   End If
           '   If adjust_mline = 0.2 Then
           '      If adjust > 1 Then adjust = adjust - 1: GoTo c_ok_tabs
           '      Screen.MousePointer = 0
           '      MsgBox "Cannot fit requested data across page." & Chr(10) & Chr(10) & "Remove some columns OR try a smaller font size or font type"
           '      set_tabs = False
           '      Exit Function
           '   End If
           '   adjust_mline = adjust_mline - 1
           '   If adjust_mline = 5 Then use_tot_width = tot_width * 0.98
           '   GoTo c_ok_tabs
           'End If

     Next j

set_tabs_exit:
     Exit Function

' get column heading details
set_tabs_col:
     'Call pset_font(True) 'mc 23/5/96 make headings only as large as needed
     'test_tab_head = Printer.TextWidth(f_col_headers(j + 1) & "W") 'mc 23/5/96
     'test_tab_line = Printer.TextWidth(String(Len(f_cols(j)) + 1, "W"))
     'Call pset_font(False) 'mc 23/5/96
     Return

End Function


Private Sub pline(pvar, px, py, plfeed As Integer, pfont As Integer)

Dim temp

       If pfont Then Printer.FontUnderline = True
       If py <> "" Then
          Printer.CurrentY = py
       End If
       If px <> "" Then
          If px >= 0 Then
             Printer.CurrentX = px
          Else
             temp = -px - Printer.TextWidth(pvar)
             If temp < 0 Then temp = 0
             Printer.CurrentX = temp
          End If
       End If
       Printer.Print pvar;
       If plfeed Then Printer.Print
       If pfont Then Printer.FontUnderline = False
    
End Sub



Public Sub SR_31(database As String, Name As String, Parms, Invalid)

Dim Glacct As String
'
' Get description for bank account number passed
'
     Invalid = 0: Name = ""
     If Parms <> "" And pick.Match(CStr(Parms), "1N0N") = 0 Then
8       Invalid = "Invalid bank account number " & Parms
        Exit Sub
     End If
     If Parms = 0 Then GoTo 8
     If Parms = 1 Or Parms = "" Then
        Glacct = g_trans_info_array(4)
     Else
        Glacct = pick.extract(g_trans_info_array(31), 1, CInt(Parms) - 1, 0)
     End If
     If Glacct = "" Then GoTo 8
     If d3.d3_readstr(database, Name, "GEN.L", Glacct) <> 0 Then Name = "": Name = pick.Replace(Name, 2, 0, 0, "?missing?"): Invalid = "GL account " & Glacct & " is missing"
     Name = pick.extract(Name, 2, 1, 0)
     Name = pick.Replace(Name, 2, 0, 0, Glacct)

End Sub


Public Sub srjob_journals(database As String, nrec() As String, Gl As String, Rect As Integer)

'Sub SR1520A_JL(RELATED, FIXSC, IS_LMSC, GL, JOURNAL_DATA, end_date, PRNTHEAD, ST_DTE, OPBAL, OPBAL_FLG, BAL, SOY, LCNT, LINES, CONTINUE_MSG, PCTR, REP_HEAD, IMRET, acct_no, ACCT_NAME, HDMTS, MTH_ENDS, MTH_BALS,  attrs)

Dim Donecr As Integer, i As Integer, Att As Integer
Dim Purno As String, pur As String, Prdte As Integer, Amnt As Currency, tempcur As Currency
Dim Ll As Integer, Ac As String, Cde As String
Dim Use_Amt As Currency, Narr As String

' Journals for Job Accounts

     Donecr = 0
594  For i = 1 To 999
        If Donecr Then Att = 58 Else Att = 57
        Purno = pick.extract(Gl, Att, i, 0)
        If Purno = "" Then GoTo 699
        If d3.d3_readstr(database, pur, "JOURNAL", Purno) <> 0 Then GoTo 697
        Prdte = pick.extractint(pur, 7, 0, 0)
        'If end_date <> "" Then
        '   If Prdte > end_date Then GoTo 691
        'End If
        Amnt = 0
        For Ll = 1 To 999
           Ac = pick.extract(pur, 3, Ll, 0)
           If Ac = "" Then GoTo 693
           If Ac <> "JOB" & nrec(0) Then GoTo 690
           If Donecr Then
              If pick.extractint(pur, 1, Ll, 0) >= 50 Then GoTo 690
           Else
              If pick.extractint(pur, 1, Ll, 0) < 50 Then GoTo 690
           End If
           If pick.extractint(pur, 1, Ll, 0) < 50 Then tempcur = pick.extractcur(pur, 4, Ll, 0) Else tempcur = pick.extractcur(pur, 2, Ll, 0)
           If Donecr Then tempcur = -tempcur
           Amnt = Amnt + tempcur
690     Next Ll
693     'If Prdte < ST_DTE And ST_DTE <> "" Then OPBAL = OPBAL + Amnt / 100: GoTo 691
        'If OPBAL_FLG Then GoTo 691
        'BAL = BAL + Amnt / 100
        'If UPDATE = 4 Then LDTE = Prdte: GoSub 7777
        'If SOY Then GoTo 691
        Narr = Mid$(pick.extract(pur, 6, 1, 0), InStr(pick.extract(pur, 6, 1, 0), " - ") + 3, 99)
        If Donecr Then Cde = "Journal CR" Else Cde = "Journal DR"
        If InStr(pick.extract(pur, 6, 0, 0), Chr(253)) = 0 Then
           Rect = Rect + 1
           nrec(1) = pick.Replace(nrec(1), 1, Rect, 0, CStr(Prdte))
           nrec(2) = pick.Replace(nrec(2), 1, Rect, 0, Cde)
           nrec(3) = pick.Replace(nrec(3), 1, Rect, 0, CStr(Amnt))
           nrec(7) = pick.Replace(nrec(7), 1, Rect, 0, Purno)
           nrec(9) = pick.Replace(nrec(9), 1, Rect, 0, Narr)
           GoTo 691
        End If
        For Ll = 1 To 999
           Ac = pick.extract(pur, 3, Ll, 0)
           If Ac = "" Then GoTo 691
           If Ac <> "JOB" & nrec(0) Then GoTo 691
           If Donecr Then
              If pick.extractint(pur, 1, Ll, 0) >= 50 Then GoTo 691
              Use_Amt = -pick.extractcur(pur, 4, Ll, 0)
           Else
              If pick.extractint(pur, 1, Ll, 0) < 50 Then GoTo 691
              Use_Amt = pick.extractcur(pur, 2, Ll, 0)
           End If
           Narr = Mid$(pick.extract(pur, 6, Ll, 0), InStr(pick.extract(pur, 6, Ll, 0), " - ") + 3, 99)
           Rect = Rect + 1
           nrec(1) = pick.Replace(nrec(1), 1, Rect, 0, CStr(Prdte))
           nrec(2) = pick.Replace(nrec(2), 1, Rect, 0, Cde)
           nrec(3) = pick.Replace(nrec(3), 1, Rect, 0, CStr(Use_Amt))
           nrec(7) = pick.Replace(nrec(7), 1, Rect, 0, Purno)
           nrec(9) = pick.Replace(nrec(9), 1, Rect, 0, Narr)
691     Next Ll
697  Next i
699  If Donecr = 0 Then Donecr = 1:  GoTo 594
     Exit Sub
'
'999  If PRNTHEAD Then
'        CALL SR1520A_HD (LCNT,LINES,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,PRNTHEAD,ACCT_NO,ACCT_NAME,IS_LMSC,HDMTS,FIXSC,RELATED,ERASE,SCREEN,TNO,OPERATOR,UPDATE)
'        If IMRET Then Return
'     End If
'     CALL SR1520_Printer.Print  (LCNT,LINES,PT_LINE,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,ERASE,SCREEN,TNO,OPERATOR,UPDATE): RETURN
'7777 LOCATE(LDTE,MTH_ENDIFS,1,1,0,LPOS,"AR") ELSE NULL
'     MTH_BALS = pick.Replace(MTH_BALS, 1, LPOS, 0, pick.extract(MTH_BALS, 1, LPOS, 0) + Amnt)
'     Return

End Sub


Public Sub srjob_crinvs(database As String, nrec() As String, Gl As String, Rect As Integer)

'SUB SR1520A_SI (RELATED,FIXSC,IS_LMSC,GL,WORKORD,PURCHASE_DATA,CR_INV_DATA,CR_CREDIT_DATA,CLIENT_DATA,ENDIF_DATE,PRNTHEAD,ST_DTE,OPBAL,OPBAL_FLG,UPDATE,BAL,SOY,LCNT,LINES,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,ACCT_NO,ACCT_NAME,HDMTS,MTH_ENDIFS,MTH_BALS,ERASE,SCREEN,TNO,OPERATOR,ATR,INTREQ,REC,RECT,ORDER,TOT_QTY)

Dim Extra_Disc As Integer, Donecr As Integer, i As Integer, Att As Integer, Purno As String
Dim Prdte As Integer, Amnt As Currency, Ll As Integer, Ans As Currency
Dim Cde As String, Pt_Line, Supply As String, Name As String, Numb As String, Col12 As Integer
Dim Poogi As String, pur As String, qty As Integer

     'Nz = pick.extract(Trans_Info, 133, 0, 0) + 0: Library = pick.extract(Trans_Info, 132, 0, 0) + 0
     Extra_Disc = 0 'pick.extract(Trans_Info, 38, 5, 0)
292  Donecr = 0
294  For i = 1 To 999
        If Donecr Then Att = 54 Else Att = 6
        Purno = pick.extract(Gl, Att, i, 0)
        If Purno = "" Then GoTo 399
        If Donecr Then
           If d3.d3_readstr(database, pur, "CR.CREDIT", Purno) <> 0 Then GoTo 397
        Else
           If d3.d3_readstr(database, pur, "CR.INV", Purno) <> 0 Then GoTo 397
        End If
        Prdte = pick.extractint(pur, 20, 0, 0) '21=ledger date
        'If END_DATE <> "" Then
        '   If Prdte > END_DATE Then GoTo 397
        'End If
        Amnt = 0
        For Ll = 1 To pick.extractint(pur, 9, 0, 0)
           'If InStr(pick.extract(pur, 10, Ll, 0), "_") Then 'WCC
              If pick.extract(pur, 10, Ll, 0) <> "JOB" & nrec(0) Then GoTo 390
           'Else  'WCC
           '   If Library And Nz Then  'WCC
           '      READV STAFF_JOB FROM STAFF_DATA,PICK.EXTRACT(PUR,35,LL,0),7 ELSE GOTO 0390  'WCC
           '   Else
           '      GoTo 390
           '   End If
           '   If InStr(ACCT_NO, STAFF_JOB) = 0 Or STAFF_JOB = "" Then GoTo 390 'WCC
           'End If 'WCC
           Ans = pick.extractcur(pur, 14, Ll, 0)
           'If Extra_Disc Then Ans = Ans + pick.extract( pur, 19, Ll, 0) + 0
           If Donecr Then Ans = -Ans
           Amnt = Amnt + Ans
390     Next Ll
        'If Prdte < ST_DTE And ST_DTE <> "" Then Opbal = Opbal + Amnt / 100: GoTo 397
        'If OPBAL_FLG Then GoTo 397
        'If Update = 3 And Upd Then
        '   Gl = pick.delet(Gl, Att, I, 0)
        '   I = I - 1
        'End If
        'Bal = Bal + Amnt / 100
        'If Update = 4 Then LDTE = pick.extract(pur, 21, 0, 0): GoSub 7777
        'If SOY Then GoTo 397
        If Donecr Then Cde = "Supplier Credit" Else Cde = "Supplier Invoice" 'these tested for in make_html_what
        Supply = pick.field(Purno, "*", 1)
        If d3.d3_readstr(database, Name, "CLIENT", Supply, 1) <> 0 Then Name = ""
        Numb = Mid$(Purno, InStr(Purno, "*") + 1, 99)
        'PT_LINE= PT_LINE & Right(Space(6) & SUPPLY,6) & " " & NAME SZ & " " & Left(NUMB & Space(10),10)
        'Save_Pono = ""
        Col12 = 1
        For Ll = 1 To pick.extract(pur, 9, 0, 0)
           'If InStr(pick.extract(pur, 10, Ll, 0), ".") Then
              If pick.extract(pur, 10, Ll, 0) <> "JOB" & nrec(0) Then GoTo 391
           'Else  'WCC
              'If Library And Nz Then  'WCC
              '   READV STAFF_JOB FROM STAFF_DATA,PICK.EXTRACT(PUR,35,LL,0),7 ELSE GOTO 391  'WCC
              'Else
              '   GoTo 391
              'End If
              'If InStr(ACCT_NO, STAFF_JOB) = 0 Or STAFF_JOB = "" Then GoTo 391 'WCC
           'End If 'WCC
           qty = pick.extractint(pur, 13, Ll, 0)
           If Donecr Then qty = -qty
           'If WORKORD Then
           '   If pick.extract(pur, 12, Ll, 2) <> "" Then
                 'PT_LINE= PT_LINE & Left(PICK.EXTRACT(PUR,12,LL,1) & Space(10),10) & " " & PICK.EXTRACT(PUR,12,LL,2) SZ
           '   Else
                  '  PT_LINE=PT_LINE & SPACE(11) & PICK.EXTRACT(PUR,12,LL,1) SZ
           '   End If
           'Else
              'PT_LINE=PT_LINE & SPACE(11) & PICK.EXTRACT(PUR,12,LL,1) SZ
           'End If
           Poogi = pick.extract(pur, 5, Ll, 0) ': Useord = 1
           'If Poogi <> "" Then Save_Pono = Poogi
           If Poogi = "" Then Poogi = pick.extract(pur, 6, Ll, 0) ': Useord = 0
           'If INTREQ And Useord Then
           '   READV IREQ FROM PURCHASE_DATA,POOGI,5 ELSE IREQ=""
           '   Pt_Line = Pt_Line & Left(Ireq & Space(7), 7)
           'End If
           Rect = Rect + 1
           If Col12 = 1 Then
              nrec(1) = pick.Replace(nrec(1), 1, Rect, 0, CStr(Prdte))
              nrec(2) = pick.Replace(nrec(2), 1, Rect, 0, Cde)
              Col12 = 1
           Else
              nrec(1) = pick.Replace(nrec(1), 1, Rect, 0, " ")
           End If
           nrec(3) = pick.Replace(nrec(3), 1, Rect, 0, pick.extract(pur, 14, Ll, 0))
           'If Extra_Disc Then NREC(X) = pick.Replace(NREC(X), 3, Rect, 0, pick.extract(NREC(X), 3, Rect, pick.extract(0) + pur, 19, Ll) + 0)
           nrec(5) = pick.Replace(nrec(5), 1, Rect, 0, Supply)
           nrec(6) = pick.Replace(nrec(6), 1, Rect, 0, Name)
           If Donecr Then nrec(3) = pick.Replace(nrec(3), 1, Rect, 0, -pick.extractcur(nrec(3), 1, Rect, 0))
           nrec(7) = pick.Replace(nrec(7), 1, Rect, 0, Purno)
           nrec(8) = pick.Replace(nrec(8), 1, Rect, 0, CStr(qty))
           nrec(9) = pick.Replace(nrec(9), 1, Rect, 0, pick.extract(pur, 12, Ll, 0))
           nrec(10) = pick.Replace(nrec(10), 1, Rect, 0, Poogi)
391     Next Ll
397  Next i
399  If Donecr = 0 Then Donecr = 1: GoTo 294
     Exit Sub
'
'999  If PRNTHEAD Then
'        CALL SR1520A_HD (LCNT,LINES,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,PRNTHEAD,ACCT_NO,ACCT_NAME,IS_LMSC,HDMTS,FIXSC,RELATED,ERASE,SCREEN,TNO,OPERATOR,UPDATE)
'        If IMRET Then Return
'     End If
'     CALL SR1520_Printer.Print  (LCNT,LINES,PT_LINE,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,ERASE,SCREEN,TNO,OPERATOR,UPDATE): RETURN
'
'7777 LOCATE(LDTE,MTH_ENDIFS,1,1,0,LPOS,"AR") ELSE NULL
'     Mth_Bals = pick.Replace(Mth_Bals, 1, LPOS, 0, pick.extract(Mth_Bals, 1, LPOS, 0) + Amnt)
'     Return

End Sub

Public Sub srjob_trans(database As String, nrec() As String)

Dim jlrec As String, Rect As Integer, id As String

     id = nrec(0)
     ReDim nrec(14) 'clear all elements to null
     nrec(0) = id
     
     If d3.d3_readstr(database, jlrec, "JOB.L", id) <> 0 Then Exit Sub
     
     Rect = 0
     Call srjob_ts(database, nrec(), jlrec, Rect)
     Call srjob_purchase(database, nrec(), jlrec, Rect)
     Call srjob_goods(database, nrec(), jlrec, Rect)
     Call srjob_crinvs(database, nrec(), jlrec, Rect)
     Call srjob_issue(database, nrec(), jlrec, Rect)
     Call srjob_journals(database, nrec(), jlrec, Rect)
     Call srjob_chq(database, nrec(), jlrec, Rect)
     Call srjob_invoice(database, nrec(), jlrec, Rect)
     
End Sub
Public Sub srjob_purchase(database As String, nrec() As String, Gl As String, Rect As Integer)

'SUB SR1520A_PO (RELATED,FIXSC,IS_LMSC,GL,WORKORD,PURCHASE_DATA,GOODSIN_DATA,CR_INV_DATA,CLIENT_DATA,RUN_COMMIT,ENDIF_DATE,PRNTHEAD,ST_DTE,OPCOM,OPBAL_FLG,UPDATE,BAL,SOY,LCNT,LINES,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,nrec(0),ACCT_NAME,HDMTS,ERASE,SCREEN,TNO,OPERATOR,ATR,NOGI,INTREQ,REC,RECT,ORDER,TOT_QTY)
Dim i As Integer, Purno As String, pur As String, Prdte As Integer, Amnt As Currency
Dim Ll As Integer, Cde As String, Ans As Currency, cnt, Gg As Integer, Yy As Integer, Zz As Integer
Dim Nogi, Nmr, Ggg As Integer, Out As Currency, Opcom, Run_Commit As Currency
Dim Supply As String, Name As String, Col12 As Integer, Lll
Dim Dsc, end_date As Integer, gi As String

     end_date = 0
     For i = 1 To 9999
        Purno = pick.extract(Gl, 9, i, 0)
        If Purno = "" Then GoTo 192
        If d3.d3_readstr(database, pur, "PURCHASE", Purno) <> 0 Then GoTo 199
        Prdte = pick.extractint(pur, 20, 0, 0)
        'If END_DATE <> "" Then
        '   If Prdte > END_DATE Then GoTo 199
        '   If pick.extract(pur, 32, 0, 0) <> "" And pick.extract(pur, 32, 0, 0) <= END_DATE Then GoTo 199
        'Else
           If pick.extract(pur, 32, 0, 0) <> "" Then GoTo 199
        'End If
        Amnt = 0
        For Ll = 1 To pick.extractint(pur, 9, 0, 0)
           Cde = pick.extract(pur, 10, Ll, 0)
           'If pick.extract(Trans_Info, 132, 0, 0) + 0 = 0 And InStr(Cde, ".") Then 'WCC - Don"t test if LIBRARY and its a book
              If Cde <> "JOB" & nrec(0) Then GoTo 190 'WCC
           'End If 'WCC
           If end_date <> 0 Then
              Ans = 0
              cnt = pick.DCount(pick.extract(pur, 33, 0, 0), Chr(253))
              If pick.extract(pur, 33, 0, 0) <> "" Then
                 For Gg = 1 To cnt
                    Yy = 2: Zz = 4
                    If Nogi = 0 Then
                       If d3.d3_readstr(database, gi, "GOODSIN", pick.extract(pur, 33, Gg, 0)) <> 0 Then
                          If d3.d3_readstr(database, gi, "CR.INV", pick.extract(pur, 33, Gg, 0)) <> 0 Then GoTo 160
                          Yy = 5: Zz = 23
                       End If
                    Else
                       If d3.d3_readstr(database, gi, "CR.INV", pick.extract(pur, 33, Gg, 0)) <> 0 Then GoTo 160
                       Yy = 5: Zz = 23
                    End If
                    If pick.extract(gi, 20, 0, 0) > end_date Then GoTo 160
'    IF GI<32>>=END.DATE THEN GOTO 00190
'    LOCATE CDE IN GI<10,1> SETTING POS ELSE POS=0
'    IF POS=0 THEN GOTO 00190
'    ANS=ANS+GI<13,POS>
                    Nmr = pick.DCount(pick.extract(gi, 10, 0, 0), Chr(253))
                    For Ggg = 1 To Nmr
                       If pick.extract(gi, 10, Ggg, 0) <> Cde Then GoTo 10190
                       If pick.extract(gi, Yy, Ggg, 0) <> Purno Then GoTo 10190
                       If pick.extract(gi, Zz, Ggg, 0) <> Ll Then GoTo 10190
                       Ans = pick.extract(Ans + gi, 13, Ggg, 0)
10190               Next Ggg
160              Next Gg
              End If
              Ans = pick.extractcur(pur, 13, Ll, 0) - Ans
           Else
              Ans = pick.extractcur(pur, 13, Ll, 0) - pick.extractcur(pur, 26, Ll, 0)
           End If
           If Ans = 0 Then
              Out = pick.extractcur(pur, 13, Ll, 0) * pick.extractcur(pur, 14, Ll, 0) - pick.extractcur(pur, 27, Ll, 0)
              If Out <= 0 Then GoTo 190
              Amnt = Amnt + Out
           Else
              Amnt = Amnt + Ans * pick.extractcur(pur, 14, Ll, 0)
           End If
190     Next Ll
        'If Prdte < ST_DTE And ST_DTE <> "" Then Opcom = Opcom + Amnt / 100: GoTo 199
        'If OPBAL_FLG Then GoTo 192
        Run_Commit = Run_Commit + Amnt / 100
        'If SOY Then GoTo 191
        Supply = pick.extract(pur, 3, 0, 0)
        If d3.d3_readstr(database, Name, "CLIENT", Supply, 1) <> 0 Then Name = ""
        Col12 = 1
        For Ll = 1 To pick.extract(pur, 9, 0, 0)
           Cde = pick.extract(pur, 10, Ll, 0)
           'If pick.extract(Trans_Info, 132, 0, 0) + 0 = 0 And InStr(Cde, "_") Then 'WCC - Don"t test if LIBRARY and its a book
              If Cde <> "JOB" & nrec(0) Then GoTo 191 'WCC
           'End If 'WCC
           If end_date <> 0 Then
              Ans = 0
              cnt = pick.DCount(pick.extract(pur, 33, 0, 0), Chr(253))
              If pick.extract(pur, 33, 0, 0) <> "" Then
                 For Gg = 1 To cnt
                    Yy = 2: Zz = 4
                    If Nogi = 0 Then
                       If d3.d3_readstr(database, gi, "GOODSIN", pick.extract(pur, 33, Gg, 0)) <> 0 Then
                          If d3.d3_readstr(database, gi, "CR.INV", pick.extract(pur, 33, Gg, 0)) <> 0 Then GoTo 195
                          Yy = 5: Zz = 23
                       End If
                    Else
                       If d3.d3_readstr(database, gi, "CR.INV", pick.extract(pur, 33, Gg, 0)) <> 0 Then GoTo 195
                       Yy = 5: Zz = 23
                    End If
                    If pick.extract(gi, 20, 0, 0) > end_date Then GoTo 195
'    IF GI<32>>=END.DATE THEN GOTO 0195
'    LOCATE CDE IN GI<10,1> SETTING POS ELSE POS=0
'    IF POS=0 THEN GOTO 0195
'    ANS=ANS+GI<13,POS>
                    Nmr = pick.DCount(pick.extract(gi, 10, 0, 0), Chr(253))
                    For Ggg = 1 To Nmr
                       If pick.extract(gi, 10, Ggg, 0) <> Cde Then GoTo 10195
                       If pick.extract(gi, Yy, Ggg, 0) <> Purno Then GoTo 10195
                       If pick.extract(gi, Zz, Ggg, 0) <> Ll Then GoTo 10195
                       Ans = pick.extract(Ans + gi, 13, Ggg, 0)
10195               Next Ggg
195              Next Gg
              End If
              Ans = pick.extract(pur, 13, Ll, 0) - Ans
           Else
              Ans = pick.extractcur(pur, 13, Ll, 0) - pick.extractcur(pur, 26, Ll, 0)
           End If
           'Tot_Qty = Tot_Qty + Ans
'           IF ANS=0 THEN GOTO 191
           Out = pick.extractcur(pur, 13, Ll, 0) * pick.extractcur(pur, 14, Ll, 0) - pick.extractcur(pur, 27, Ll, 0)
'           IF OUT<=0 THEN GOTO 191
           'If INTREQ And Pord And Ll = 1 Then Pt_Line = Pt_Line & Space(8) & Left(pick.extract(pur, 5, 0, 0) & Space(7), 7)
           Rect = Rect + 1
           If Col12 Then
              nrec(1) = pick.Replace(nrec(1), 1, Rect, 0, CStr(Prdte))
              nrec(2) = pick.Replace(nrec(2), 1, Rect, 0, "Purchase Order")
              Col12 = 1
           End If
           nrec(4) = pick.Replace(nrec(4), 1, Rect, 0, CStr(Out))
           nrec(5) = pick.Replace(nrec(5), 1, Rect, 0, Supply)
           nrec(6) = pick.Replace(nrec(6), 1, Rect, 0, Name)
           nrec(7) = pick.Replace(nrec(7), 1, Rect, 0, Purno)
           nrec(8) = pick.Replace(nrec(8), 1, Rect, 0, CStr(Ans))
           nrec(9) = pick.Replace(nrec(9), 1, Rect, 0, pick.extract(pur, 12, Ll, 0))
           nrec(10) = pick.Replace(nrec(10), 1, Rect, 0, pick.extract(pur, 5, 0, 0))
191     Next Ll

199  Next i
192  Exit Sub
'
'999  If PRNTHEAD Then
'        CALL SR1520A_HD (LCNT,LINES,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,PRNTHEAD,ACCT_NO,ACCT_NAME,IS_LMSC,HDMTS,FIXSC,RELATED,ERASE,SCREEN,TNO,OPERATOR,UPDATE)
'        If IMRET Then Return
'     End If
'     CALL SR1520_Printer.Print  (LCNT,LINES,PT_LINE,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,ERASE,SCREEN,TNO,OPERATOR,UPDATE): RETURN

End Sub


Public Sub srjob_goods(database As String, nrec() As String, Gl As String, Rect As Integer)
'SUB SR1520A_GOODS (PROG,GL,GOODSIN_DATA,CR_INV_DATA,PURCHASE_DATA,CLIENT_DATA,end_date,nrec(0),ATR,ST_DTE,OPBAL,OPBAL_FLG,UPDATE,SOY,PORD,WORKORD,INTREQ,RX,LCNT,LINES,T$,CONT_MSG,PCTR,RPHEAD,ERASE,SCREEN,TNO,OPERATOR,MTH_ENDIFS,MTH_BALS,BAL,PTHEAD,ACCT_NAME,HDMTS,IS_LMSC,REC,RECT,ORDER,TOT_QTY)
Dim i As Integer, Purno As String, Gdsin As String, Prdte As Integer, Amnt As Currency
Dim Ll As Integer, Cde As String, Ans As Currency, cnt As Integer
Dim Gg As Integer, Nmr, Ggg As Integer, Tot_Qty As Currency, Bal, UPDATE, Use_Date, Pt_Line
Dim Supply As String, Name As String, Numb, Save_Pono, Col12 As Integer, Out As Currency, Ireq
Dim rec, Lll As Integer, Dsc, end_date As Integer, pur As String, inv As String
'
' Calculates the GOODSIN section *
'
     end_date = 0
192  For i = 1 To 9999
       Purno = pick.extract(Gl, 5, i, 0)
       If Purno = "" Then Exit Sub
       Gdsin = pick.field(Purno, "*", 2)
       If d3.d3_readstr(database, pur, "GOODSIN", Purno) <> 0 Then GoTo 291
       Prdte = pick.extractint(pur, 20, 0, 0)
       'If end_date <> "" Then
       '  If Prdte > end_date Then GoTo 291
       '  If pick.extract(pur, 32, 0, 0) <> "" And pick.extract(pur, 33, 0, 0) = "" Then GoTo 291
       'Else
         If pick.extract(pur, 32, 0, 0) <> "" Then GoTo 291
       'End If
       Amnt = 0
       For Ll = 1 To pick.extractint(pur, 9, 0, 0)
         Cde = pick.extract(pur, 10, Ll, 0)
         If Cde <> "JOB" & nrec(0) Then GoTo 260
         If end_date <> 0 Then
           Ans = 0
           cnt = pick.DCount(pick.extract(pur, 33, 0, 0), Chr(253))
           If pick.extract(pur, 33, 0, 0) <> "" Then
             For Gg = 1 To cnt
               If d3.d3_readstr(database, inv, "CR.INV", pick.extract(pur, 33, Gg, 0)) <> 0 Then GoTo 290
               If pick.extract(inv, 20, 0, 0) > end_date Then GoTo 290
               Nmr = pick.DCount(pick.extract(inv, 10, 0, 0), Chr(253))
               For Ggg = 1 To Nmr
                 If pick.extract(inv, 10, Ggg, 0) <> Cde Then GoTo 10290
                 If pick.extract(inv, 6, Ggg, 0) <> Gdsin Then GoTo 10290
                 If pick.extract(inv, 23, Ggg, 0) <> Ll Then GoTo 10290
                 Ans = Ans + pick.extractcur(inv, 13, Ggg, 0)
10290          Next Ggg
290          Next Gg
           End If
           Ans = pick.extractcur(pur, 13, Ll, 0) - Ans
         Else
           Ans = pick.extractcur(pur, 13, Ll, 0) - pick.extractcur(pur, 26, Ll, 0)
         End If
         Tot_Qty = Tot_Qty + Ans
         Amnt = Amnt + Ans * pick.extractcur(pur, 15, Ll, 0)
260    Next Ll
       'If Prdte < ST_DTE And ST_DTE <> "" Then Opbal = Opbal + Amnt / 100: GoTo 291
       'If OPBAL_FLG Then Return
       Bal = Bal + Amnt / 100
       'If Update = 4 Then LDTE = pick.extract(pur, 21, 0, 0): GoSub 7777
       'If SOY Then GoTo 291
       Supply = pick.field(Purno, "*", 1)
       If d3.d3_readstr(database, Name, "CLIENT", Supply, 1) <> 0 Then Name = ""
       Save_Pono = ""
       Col12 = 1
       For Ll = 1 To pick.extract(pur, 9, 0, 0)
         Cde = pick.extract(pur, 10, Ll, 0)
         If Cde <> "JOB" & nrec(0) Then GoTo 288
         If end_date <> 0 Then
           Ans = 0
           cnt = pick.DCount(pick.extract(pur, 33, 0, 0), Chr(253))
           If pick.extract(pur, 33, 0, 0) <> "" Then
             For Gg = 1 To cnt
               If d3.d3_readstr(database, inv, "CR.INV", pick.extract(pur, 33, Gg, 0)) <> 0 Then GoTo 295
               If pick.extract(inv, 20, 0, 0) > end_date Then GoTo 295
               Nmr = pick.DCount(pick.extract(inv, 10, 0, 0), Chr(253))
               For Ggg = 1 To Nmr
                 If pick.extract(inv, 10, Ggg, 0) <> Cde Then GoTo 10295
                 If pick.extract(inv, 6, Ggg, 0) <> Gdsin Then GoTo 10295
                 If pick.extract(inv, 23, Ggg, 0) <> Ll Then GoTo 10295
                 Ans = pick.extract(Ans + inv, 13, Ggg, 0)
10295          Next Ggg
295          Next Gg
           End If
           Ans = pick.extractcur(pur, 13, Ll, 0) - Ans
         Else
           Ans = pick.extractcur(pur, 13, Ll, 0) - pick.extractcur(pur, 26, Ll, 0)
         End If
         If Ans = 0 Then GoTo 288
         Out = Ans * pick.extractcur(pur, 15, Ll, 0)
         If pick.extract(pur, 2, Ll, 0) <> "" Then Save_Pono = pick.extract(pur, 2, Ll, 0)
         'If INTREQ Then
         '  READV IREQ FROM PURCHASE_DATA,PICK.EXTRACT(PUR,2,LL,0),5 ELSE IREQ=""
         '  Pt_Line = Pt_Line & Left(Ireq & Space(7), 7)
         'End If
         Rect = Rect + 1
         If Col12 Then
            nrec(1) = pick.Replace(nrec(1), 1, Rect, 0, CStr(Prdte))
            nrec(2) = pick.Replace(nrec(2), 1, Rect, 0, "Goods Inward")
            Col12 = 1
         End If
         nrec(3) = pick.Replace(nrec(3), 1, Rect, 0, CStr(Out))
         nrec(5) = pick.Replace(nrec(5), 1, Rect, 0, Supply)
         nrec(6) = pick.Replace(nrec(6), 1, Rect, 0, Name)
         nrec(7) = pick.Replace(nrec(7), 1, Rect, 0, Purno)
         nrec(8) = pick.Replace(nrec(8), 1, Rect, 0, CStr(Ans))
         nrec(9) = pick.Replace(nrec(9), 1, Rect, 0, pick.extract(pur, 12, Ll, 1))
         nrec(10) = pick.Replace(nrec(10), 1, Rect, 0, pick.extract(pur, 2, Ll, 0))
288    Next Ll
291  Next i
     Exit Sub
'
'999  If PTHEAD And Update = 0 Then
'        CALL SR1520A_HD (LCNT,LINES,PORD,T$,CONT_MSG,PCTR,RPHEAD,RX,PTHEAD,nrec(0),ACCT_NAME,IS_LMSC,HDMTS,FIXSC,RELATED,ERASE,SCREEN,TNO,OPERATOR,UPDATE)
'        If RX Then Return
'     End If
'     CALL SR1520_Printer.Print  (LCNT,LINES,PT_LINE,PORD,T$,CONT_MSG,PCTR,RPHEAD,RX,ERASE,SCREEN,TNO,OPERATOR,UPDATE): RETURN
'
'7777 LOCATE(LDTE,MTH_ENDIFS,1,1,0,LPOS,"AR") ELSE NULL
'     Mth_Bals = pick.replace(Mth_Bals, 1, LPOS, 0, pick.extract(Mth_Bals, 1, LPOS, 0) + Amnt)
'     Return

End Sub
Public Sub srjob_invoice(database As String, nrec() As String, Gl As String, Rect As Integer)

'SUB SR1520A_IN (RELATED,FIXSC,IS_LMSC,GL,INVOICE_DATA,CREDIT_DATA,CLIENT_DATA,end_date,PRNTHEAD,ST_DTE,OPBAL,OPBAL_FLG,UPDATE,BAL,SOY,LCNT,LINES,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,nrec(0),ACCT_NAME,HDMTS,MTH_ENDIFS,MTH_BALS,ERASE,SCREEN,TNO,OPERATOR,ATR,REC,RECT,ORDER)

Dim Donecr As Integer, i As Integer, Att As Integer, Purno As String, Prdte As Integer, Amnt As Currency, Ll As Integer
Dim Supply As String, Name As String, end_date As Integer, pur As String, Ac As String
Dim Cde As String, Ans As Currency

     Donecr = 0
     end_date = 0
794  For i = 1 To 999
        If Donecr Then Att = 63 Else Att = 62
        Purno = pick.extract(Gl, Att, i, 0)
        If Purno = "" Then GoTo 892
        If Donecr Then
           If d3.d3_readstr(database, pur, "CREDIT", Purno) <> 0 Then GoTo 891
        Else
           If d3.d3_readstr(database, pur, "INVOICE", Purno) <> 0 Then GoTo 891
        End If
        Prdte = pick.extractint(pur, 20, 0, 0)
        If end_date <> 0 Then
           If Prdte > end_date Then GoTo 891
        End If
        If InStr(pick.extract(pur, 10, 0, 0), "JOB") = 0 Then Amnt = pick.extract(pur, 8, 0, 0): GoTo 890
        Amnt = 0
        For Ll = 1 To 999
           Ac = pick.extract(pur, 10, Ll, 0)
           If Ac = "" Then GoTo 890
           If Ac <> "JOB" & nrec(0) Then GoTo 888
           If pick.extractcur(pur, 13, Ll, 0) = 0 Then pur = pick.Replace(pur, 13, Ll, 0, 1)
           Ans = pick.extract(pur, 15, Ll, 0) * pick.extract(pur, 13, Ll, 0)
           Amnt = Amnt + Ans
888     Next Ll
890     If Donecr = 0 Then Amnt = -Amnt
        'If Prdte < ST_DTE And ST_DTE <> "" Then Opbal = Opbal + Amnt / 100: GoTo 891
        'If OPBAL_FLG Then GoTo 892
        'If Update = 3 And Upd Then
        '   Gl = pick.delet(Gl, Att, I, 0)
        '   I = I - 1
        'End If
        'Bal = Bal + Amnt / 100: If Update = 4 Then LDTE = pick.extract(pur, 21, 0, 0): GoSub 7777
        'If SOY Then GoTo 891
        Supply = pick.extract(pur, 3, 0, 0)
        If d3.d3_readstr(database, Name, "CLIENT", Supply, 1) <> 0 Then Name = ""
        If Donecr Then Cde = "Credit" Else Cde = "Invoice"
        Rect = Rect + 1
        nrec(1) = pick.Replace(nrec(1), 1, Rect, 0, CStr(Prdte))
        nrec(2) = pick.Replace(nrec(2), 1, Rect, 0, Cde)
        nrec(3) = pick.Replace(nrec(3), 1, Rect, 0, CStr(Amnt))
        nrec(5) = pick.Replace(nrec(5), 1, Rect, 0, Supply)
        nrec(6) = pick.Replace(nrec(6), 1, Rect, 0, Name)
        nrec(7) = pick.Replace(nrec(7), 1, Rect, 0, Purno)
        nrec(9) = pick.Replace(nrec(9), 1, Rect, 0, pick.extract(pur, 26, 0, 0))
891  Next i
892  If Donecr = 0 Then Donecr = 1:  GoTo 794
     Exit Sub
'
'999  If PRNTHEAD Then
'        CALL SR1520A_HD (LCNT,LINES,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,PRNTHEAD,nrec(0),ACCT_NAME,IS_LMSC,HDMTS,FIXSC,RELATED,ERASE,SCREEN,TNO,OPERATOR,UPDATE)
'        If IMRET Then Return
'     End If
'     CALL SR1520_Printer.Print  (LCNT,LINES,PT_LINE,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,ERASE,SCREEN,TNO,OPERATOR,UPDATE): RETURN
'
'7777 LOCATE(LDTE,MTH_ENDIFS,1,1,0,LPOS,"AR") ELSE NULL
'     Mth_Bals = pick.replace(Mth_Bals, 1, LPOS, 0, pick.extract(Mth_Bals, 1, LPOS, 0) + Amnt)
'     Return

End Sub


Public Sub srjob_ts(database As String, nrec() As String, Gl As String, Rect As Integer)

' PROCESS TIME.SHEETS

'Sub SR1520A_TS(Related, Fixsc, Is_Lmsc, Gl, TIME_SHEETS_DATA, end_date, PRNTHEAD, Bals, SETOP, ST_DTE, Hrs, HRS1_5, HRS2_0, Opbal, OPBAL_FLG, Update, Bal, EMPLOYEE_DATA, Havemach, MACHINE_DATA, JOB_L_DATA, SUMMONLY, LCNT, LINES, Pord, T$, CONTINUE_MSG, PCTR, REP_HEAD, IMRET, nrec(0), ACCT_NAME, HDMTS, MTH_ENDIFS, Mth_Bals, Mth_Hrs, Mth_Mhrs, Mth_Rhrs, Toth, Tothm, Tothr, SCREEN, Rec, RECT, Order, SCLASS)
Dim nz As Integer, Iore As String, sclass As String, sub_class As String, Hr_Km As Integer, Mfac As Integer, Ismach As Integer
Dim mrate As Currency, IS_LMSC As Integer, related As String, rderr As Integer, temp As String, scv As String
Dim mterials As String, stock As String, labour As String, machine As String, income As String, kmrec As String
Dim Ans As String, accts As String, amount As Currency
Dim i As Integer, Purno As String, pur As String, Prdte As Integer, end_date As Integer
Dim Amnt As Currency, Amts As String, H  As Currency, H1_5 As Currency, H2_0 As Currency, Ll As Integer, Supply As String, Ans2 As Integer, Sign As Integer
Dim Hour As Currency, Xrate As Currency, FIXSC, Bals As String, Hrs1_5 As Currency, Hrs2_0 As Currency
Dim Hrs, Job_Or_Plant As String
Dim Name As String, Emp As String, Emp_Name As String, Ename As String, Xx
Dim Yy, Testdate, Jname, Tth, Tothr, Tothm, Toth, Mth_Bals
Dim Mth_Rhrs, Mth_Mhrs, Mth_Hrs, Notok

    end_date = 0
    If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If
     If UBound(g_trans_info_array) < 133 Then temp = "" Else temp = g_trans_info_array(133)
     If IsNumeric(g_trans_info_array(133)) Then nz = CInt(g_trans_info_array(133)) Else nz = 0
     
     If d3.d3_readstr(database, sclass, "DICT JOB.L", "@SUBCLASS") <> 0 Then sclass = ""

'
' following variables MUST have chr(253) at start and end of list
'
     sub_class = pick.field(nrec(0), ".", 3)
     
     scv = Chr(253) & sub_class & Chr(253)
     mterials = Chr(253) & pick.extract(sclass, 2, 0, 0) & Chr(253) & pick.extract(sclass, 9, 0, 0) & Chr(253)
     stock = Chr(253) & pick.extract(sclass, 4, 0, 0) & Chr(253)
     labour = Chr(253) & pick.extract(sclass, 1, 0, 0) & Chr(253) & pick.extract(sclass, 5, 0, 0) & Chr(253) & pick.extract(sclass, 6, 0, 0) & Chr(253) & pick.extract(sclass, 7, 0, 0) & Chr(253)
     machine = Chr(253) & pick.extract(sclass, 3, 0, 0) & Chr(253) & pick.extract(sclass, 8, 0, 0) & Chr(253)
     income = Chr(253) & pick.extract(sclass, 16, 0, 0) & Chr(253)
     kmrec = Chr(253) & pick.extract(sclass, 20, 0, 0) & Chr(253)
'
     If pick.extract(sclass, 16, 0, 0) <> "" Then machine = machine & Chr(253) & pick.extract(sclass, 16, 0, 0) & Chr(253)
     If pick.extract(sclass, 17, 0, 0) <> "" Then machine = machine & Chr(253) & pick.field(pick.extract(sclass, 17, 0, 0), "_", 2) & Chr(253)
     If pick.extract(sclass, 18, 0, 0) <> "" Then machine = machine & Chr(253) & pick.field(pick.extract(sclass, 18, 0, 0), "_", 2) & Chr(253)
     'If pick.extract(sclass, 20, 0, 0) = "" Then USE_KMS = 0 Else USE_KMS = 1
     related = pick.extract(sclass, 10, 0, 0)
     If InStr(income, scv) <> 0 Then IS_LMSC = 5: GoTo 8
     If InStr(labour, scv) <> 0 Then IS_LMSC = 1: GoTo 8
     If InStr(kmrec, scv) <> 0 Then IS_LMSC = 10: GoTo 8
     If InStr(machine, scv) <> 0 Then IS_LMSC = 2: GoTo 8
     If InStr(mterials, scv) <> 0 Then IS_LMSC = 4: GoTo 8
     If InStr(stock, scv) <> 0 Then IS_LMSC = 3: GoTo 8
     IS_LMSC = 0
              
8:   Iore = pick.extract(Gl, 10, 0, 0)
     Hr_Km = 26
     Mfac = 100
     If IS_LMSC = 2 Or IS_LMSC = 10 Then
        Ismach = 1
        If IS_LMSC = 10 Then Hr_Km = 27: Mfac = 1
     Else
        Ismach = 0
     End If
     If related = "" Or FIXSC Then
        accts = nrec(0)
     Else
        If pick.extract(related, 1, 1, 0) = sub_class And IS_LMSC = 1 Then
           accts = nrec(0) & Chr(253) & Mid$(nrec(0), 1, pick.Index(nrec(0), ".", 2)) & pick.extract(related, 1, 2, 0) & Chr(253) & Mid$(nrec(0), 1, pick.Index(nrec(0), ".", 2)) & pick.extract(related, 1, 3, 0)
        Else
           accts = nrec(0)
        End If
     End If
     For i = 1 To 9999
        Purno = pick.extract(Gl, 7, i, 0)
        If Purno = "" Then GoTo 592
        If d3.d3_readstr(database, pur, "TIME.SHEETS", Purno) <> 0 Then GoTo 591
        Prdte = CInt(pick.field(Purno, "*", 2))
        If Prdte > end_date And end_date <> 0 Then GoTo 591
        Amnt = 0: Amts = "": H = 0: H1_5 = 0: H2_0 = 0
        For Ll = 1 To 999
           Ans = pick.extract(pur, 10, Ll, 0)
           If Ans = "" Then GoTo 588
           If Iore = "I" Then
              Supply = pick.extract(pur, 14, Ll, 0): GoSub 8000: If Notok Then GoTo 590
              Ans2 = 1: Sign = -1
           Else
              If pick.locate(Ans, accts, 1, 1, 0, Ans2, "") = 0 Then GoTo 590
              Sign = 1
           End If
           amount = pick.extractcur(pur, 11, Ll, 0)
           If Ismach Then
              Hour = pick.extractint(pur, Hr_Km, Ll, 0)
              If Hour = 0 Then Hour = pick.extractcur(pur, 12, Ll, 0)
              Xrate = 1
           Else
              If IS_LMSC = 10 Then
                 Hour = pick.extract(pur, 27, Ll, 0)
                 Xrate = 1
              Else
                 Hour = pick.extractcur(pur, 12, Ll, 0)
                 Xrate = pick.extractcur(pur, 13, Ll, 0)
              End If
           End If
'           IF HOUR < 0 THEN ANS=-ANS
           amount = Sign * amount
           If Ans2 <> 1 And related <> "" And FIXSC = 0 Then Hour = 0
           Amnt = Amnt + amount
           Amts = pick.Replace(Amts, 1, Ans2, 0, pick.extractcur(Amts, 1, Ans2, 0) + amount)
           Bals = pick.Replace(Bals, 1, Ans2, 0, pick.extractcur(Bals, 1, Ans2, 0) + amount)
           'If SETOP And Prdte < ST_DTE Then GoTo 590
           Select Case Xrate
              Case 1.5: H1_5 = H1_5 + Hour: Hrs1_5 = Hrs1_5 + Hour
              Case Is = 2: H2_0 = H2_0 + Hour: Hrs2_0 = Hrs2_0 + Hour
              Case Else: H = H + Hour: Hrs = Hrs + Hour
           End Select
590     Next Ll
588     'If Prdte < ST_DTE And ST_DTE <> "" Then Opbal = Opbal + Amnt / 100: GoTo 591
        'If OPBAL_FLG Then GoTo 592
        'If Update = "3" And Upd Then
        '   Gl = pick.delet(Gl, 7, I, 0)
        '   I = I - 1
        'End If
        'Bal = Bal + Amnt / 100: If Update = 4 Or Update = 3 Then LDTE = Prdte: GoSub 7777
        'If SUMMONLY Then GoTo 591
        If Ismach Then
           For Ll = 1 To 999
              Ans = pick.extract(pur, 10, Ll, 0)
              If Ans = "" Then GoTo 591
              Supply = pick.extract(pur, 14, Ll, 0)
              If Iore = "I" Then
                 GoSub 8000: If Notok Then GoTo 585
                 Job_Or_Plant = pick.field(Ans, ".", 1)
                 If d3.d3_readstr(database, Name, "JOB.L", Job_Or_Plant, 2) <> 0 Then Name = ""
                 Job_Or_Plant = Job_Or_Plant & "." & pick.field(Ans, ".", 2)
              Else
                 If Ans <> nrec(0) Then GoTo 585
                 If pick.trimm(Supply) = "" Then GoTo 585
                 If d3.d3_readstr(database, Name, "JOB.L", Supply, 2) <> 0 Then Name = ""
                 Job_Or_Plant = Supply
              End If
              Name = pick.extract(Name, 1, 1, 0)
              If Ismach Then
                 Hour = pick.extractint(pur, Hr_Km, Ll, 0)
                 If Hour = 0 Then Hour = pick.extractcur(pur, 12, Ll, 0)
                 Xrate = 1
              Else
                 If IS_LMSC = 10 Then
                    Hour = pick.extractint(pur, 27, Ll, 0)
                    Xrate = 1
                 Else
                    Hour = pick.extractcur(pur, 12, Ll, 0)
                    Xrate = pick.extractcur(pur, 13, Ll, 0)
                 End If
              End If
              If Hour = 0 Then mrate = 0 Else mrate = pick.extractcur(pur, 11, Ll, 0) / Hour
              Emp = pick.field(Purno, "*", 1)
              If d3.d3_readstr(database, Emp_Name, "EMPLOYEE", Emp) <> 0 Then Emp_Name = ""
              Ename = pick.trimm(pick.extract(Emp_Name, 1, 0, 0) & " " & pick.extract(Emp_Name, 6, 0, 0))
              Rect = Rect + 1
575           nrec(1) = pick.Replace(nrec(1), 1, Rect, 0, CStr(Prdte))
              nrec(2) = pick.Replace(nrec(2), 1, Rect, 0, "TimeSheet")
              nrec(3) = pick.Replace(nrec(3), 1, Rect, 0, pick.extract(pur, 11, Ll, 0))
              nrec(5) = pick.Replace(nrec(5), 1, Rect, 0, Emp)
              nrec(6) = pick.Replace(nrec(6), 1, Rect, 0, Ename)
              nrec(7) = pick.Replace(nrec(7), 1, Rect, 0, Purno)
              nrec(8) = pick.Replace(nrec(8), 1, Rect, 0, CStr(Hour))
              
              nrec(11) = pick.Replace(nrec(11), 1, Rect, 0, CStr(mrate * Mfac))
              nrec(13) = pick.Replace(nrec(13), 1, Rect, 0, Job_Or_Plant)
              nrec(14) = pick.Replace(nrec(14), 1, Rect, 0, Name)
585        Next Ll
        Else
           Supply = pick.field(Purno, "*", 1)
           If d3.d3_readstr(database, Name, "EMPLOYEE", Supply) <> 0 Then Name = ""
           Name = pick.trimm(pick.extract(Name, 1, 0, 0) & " " & pick.extract(Name, 6, 0, 0))
           Rect = Rect + 1
           nrec(1) = pick.Replace(nrec(1), 1, Rect, 0, CStr(Prdte))
           nrec(2) = pick.Replace(nrec(2), 1, Rect, 0, "TimeSheet")
           nrec(3) = pick.Replace(nrec(3), 1, Rect, 0, CStr(Amnt))
           nrec(5) = pick.Replace(nrec(5), 1, Rect, 0, Supply)
           nrec(6) = pick.Replace(nrec(6), 1, Rect, 0, Name)
           nrec(7) = pick.Replace(nrec(7), 1, Rect, 0, Purno)
           nrec(8) = pick.Replace(nrec(8), 1, Rect, 0, CStr(H))
           nrec(11) = pick.Replace(nrec(11), 1, Rect, 0, CStr(H1_5))
           nrec(12) = pick.Replace(nrec(12), 1, Rect, 0, CStr(H2_0))
        End If
591  Next i
592  If IS_LMSC = 10 Then Hrs = 0: Hrs1_5 = 0: Hrs2_0 = 0
     Exit Sub
'
'999  If PRNTHEAD Then
'        CALL SR1520A_HD (LCNT,LINES,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,PRNTHEAD,nrec(0),ACCT_NAME,IS_LMSC & CHR(253) & IORE,HDMTS,FIXSC,RELATED,ERASE,SCREEN,TNO,OPERATOR,UPDATE)
'        If IMRET Then Return
'     End If
'     CALL SR1520_Printer.Print  (LCNT,LINES,PT_LINE,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,ERASE,SCREEN,TNO,OPERATOR,UPDATE): RETURN
'
'7777 Tth = H + H1_5 + H2_0
'     If Update = 3 Then
'        If Ismach Then
'           If Iore = "I" Then
'              Tothr = Tothr + Tth
'           Else
'              Tothm = Tothm + Tth
'           End If
'        Else
'           Toth = Toth + Tth
'        End If
'        Return
'     End If
'     LOCATE(LDTE,MTH_ENDIFS,1,1,0,LPOS,"AR") ELSE NULL
'     Mth_Bals = pick.replace(Mth_Bals, 1, LPOS, 0, pick.extract(Mth_Bals, 1, LPOS, 0) + Amnt)
'     If Tth <> 0 Then
'        If Ismach Then
'           If Iore = "I" Then
'              Mth_Rhrs = pick.replace(Mth_Rhrs, 1, LPOS, 0, pick.extract(Mth_Rhrs, 1, LPOS, 0) + Tth)
'           Else
'              Mth_Mhrs = pick.replace(Mth_Mhrs, 1, LPOS, 0, pick.extract(Mth_Mhrs, 1, LPOS, 0) + Tth)
'           End If
'        Else
'           Mth_Hrs = pick.replace(Mth_Hrs, 1, LPOS, 0, pick.extract(Mth_Hrs, 1, LPOS, 0) + Tth)
'        End If
'     End If
'     Return
'
' Check whether income account is okay
'
8000 Notok = 0
     If Supply <> pick.field(nrec(0), ".", 1) Then Notok = 1: Return
     If pick.field(Ans, ".", 3) <> sub_class Then
        If nz Then
           If sub_class = pick.extract(sclass, 19, 1, 0) And Iore = "I" Then Return 'using 13 for plant income
        End If
        Notok = 1: Return
     End If
     Return

End Sub


Public Sub srjob_issue(database As String, nrec() As String, Gl As String, Rect As Integer)
'SUB SR1520A_IS (RELATED,FIXSC,IS_LMSC,GL,WORKORD,JOB_L_DATA,RETURNS_DATA,ISSUE_DATA,STOCK_DATA,RUN_COMMIT,end_date,PRNTHEAD,ST_DTE,OPBAL,OPBAL_FLG,UPDATE,BAL,SUMMONLY,LCNT,LINES,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,ACCT_NO,ACCT_NAME,HDMTS,MTH_ENDIFS,MTH_BALS,ERASE,SCREEN,TNO,OPERATOR,REC,RECT,ORDER)
Dim Donecr As Integer, Glcl, Ests, Eqs, Ereqs, Ecs
Dim Tot_Qty, i As Integer, Purno As String, Maxv, Ans As Currency, Prdte As Integer, end_date As Integer
Dim Amnt As Currency, Ll As Integer, Jac, Bal, Cde As String, pur As String
Dim Col12 As Integer, Amt As Currency, Sno As String, Name As String, Xx, Yy, Testdate
Dim Summonly, Run_Commit
'
' ISSUES / RETURNS PROCESSING FOR TA1520A
'
     end_date = 0
     Donecr = 0
     'If Pord And WORKORD And IS_LMSC = 3 Then
     '   If d3.d3_readstr(Glcl, "JOB.L", Mid$(nrec(0), 1, Index(nrec(0), ".", 2) - 1)) <> 0 Then Glcl = ""
     '   Ests = Pick.extract(Glcl, 46, 0, 0): Eqs = Pick.extract(Glcl, 47, 0, 0): Ereqs = Pick.extract(Glcl, 35, 0, 0): Ecs = Pick.extract(Glcl, 36, 0, 0)
     'End If
694  Tot_Qty = 0
     For i = 1 To 999
        If Donecr Then Purno = pick.extract(Gl, 61, i, 0) Else Purno = pick.extract(Gl, 60, i, 0)
        If Purno = "" Then GoTo 860
        If Donecr Then
         If d3.d3_readstr(database, pur, "RETURNS", Purno) <> 0 Then GoTo 791
        Else
         If d3.d3_readstr(database, pur, "ISSUE", Purno) <> 0 Then GoTo 791
        End If
        Maxv = pick.DCount(pick.extract(pur, 1, 0, 0), Chr(253))
        Ans = pick.DCount(pick.extract(pur, 4, 0, 0), Chr(253))
        If Maxv < Ans Then Maxv = Ans
        Prdte = pick.extractint(pur, 2, 0, 0)
        'If Prdte > end_date And end_date <> 0 Then GoTo 791
        Amnt = 0
        For Ll = 1 To Maxv
           Jac = pick.extract(pur, 1, Ll, 0): If Jac = "" Then Jac = pick.extract(pur, 1, 1, 0)
           If Jac <> "JOB" & nrec(0) Then GoTo 698
           Ans = pick.extractcur(pur, 8, Ll, 0) + pick.extractcur(pur, 12, Ll, 0)
           If Donecr Then Ans = -Ans
           Amnt = Amnt + Ans
698     Next Ll
        'If Prdte < ST_DTE And ST_DTE <> "" Then Opbal = Opbal + Amnt / 100: GoTo 791
        'If OPBAL_FLG Then GoTo 860
        'If Update = 3 Then
        '   If Donecr Then
        '      Gl = Pick.delet(Gl, 61, I, 0)
        '   Else
        '      Gl = Pick.delet(Gl, 60, I, 0)
        '   End If
        '   I = I - 1
        'End If
        Bal = Bal + Amnt / 100
        'If Update = 4 Then LDTE = Prdte: GoSub 7777
        If Donecr Then Cde = "Return" Else Cde = "Issue"
        Col12 = 1
        For Ll = 1 To Maxv
           Jac = pick.extract(pur, 1, Ll, 0)
           If Jac = "" Then Jac = pick.extract(pur, 1, 1, 0)
           If Jac <> "JOB" & nrec(0) Then GoTo 789
           Ans = pick.extractcur(pur, 5, Ll, 0)
           Amt = pick.extractcur(pur, 8, Ll, 0) + pick.extractcur(pur, 12, Ll, 0)
           If Donecr Then Amt = -Amt: Ans = -Ans
           Sno = pick.extract(pur, 4, Ll, 0): If Sno = "" Then Sno = pick.extract(pur, 4, 1, 0)
           If d3.d3_readstr(database, Name, "STOCK", Sno, 1) <> 0 Then Name = ""

           Rect = Rect + 1
575        If Col12 Then
              nrec(1) = pick.Replace(nrec(1), 1, Rect, 0, CStr(Prdte))
              nrec(2) = pick.Replace(nrec(2), 1, Rect, 0, Cde)
              Col12 = 1
           End If
           nrec(3) = pick.Replace(nrec(3), 1, Rect, 0, CStr(Amt))
           nrec(7) = pick.Replace(nrec(7), 1, Rect, 0, Purno)
           nrec(8) = pick.Replace(nrec(8), 1, Rect, 0, CStr(Ans))
           nrec(5) = pick.Replace(nrec(5), 1, Rect, 0, Sno)
           nrec(6) = pick.Replace(nrec(6), 1, Rect, 0, Name)
           
           'If Pord And WORKORD And IS_LMSC = 3 And Donecr = 0 Then
           '   LOCATE(SNO,ESTS,1,1,0,EP,"") ELSE GOTO 788
           '   Pt_Line = Pt_Line & " " & Pick.extract(Ereqs, 1, EP, 0)
           '   Ans = Pick.extract(Ereqs, 1, EP, 0)
           '   Ecs = Pick.delet(Ecs, 1, EP, 0)
           '   Ests = Pick.delet(Ests, 1, EP, 0)
           '   Ereqs = Pick.delet(Ereqs, 1, EP, 0)
           '   Eqs = Pick.delet(Eqs, 1, EP, 0)
           'End If
788
789     Next Ll
791  Next i
860  'If Tot_Qty <> 0 Then
     '   PT_LINE= SPACE(44) & Right(Space() & TOT_QTY/100,)
     'End If
     If Donecr = 0 Then
       'If Pord And WORKORD And IS_LMSC = 3 Then
       '   Run_Commit = 0
       '   For I = 1 To 999
       '    Sno = Pick.extract(Ests, 1, I, 0)
       '    If Sno = "" Then GoTo 893
       '    Run_Commit = Run_Commit + Pick.extractcur(Ecs, 1, I, 0) * Pick.extractcur(Eqs, 1, I, 0)
       '    If Summonly = 0 Then
       '       READV NAME FROM STOCK_DATA,SNO,1 ELSE NAME=""
       '       Pt_Line = Space(24) & Right(Space(12) & Pick.extract(Ecs, 1, I, Pick.extract(0) * Eqs, 1, I), 12) & " " & Left(Pick.extract(Ereqs, 1, I, 0) & Space(10), 10) & Right(Space(8) & Pick.extract(Eqs, 1, I, 0), 8) & " " & Left((Sno & " " & Pick.extract(Name, 1, 1, 1)) & Space(46), 46)
       '       GoSub 999: If IMRET Then Return
       '    End If
       '   Next I
       'End If
893    Donecr = 1: GoTo 694
     End If
     Exit Sub
'
'999  If PRNTHEAD Then
'        CALL SR1520A_HD (LCNT,LINES,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,PRNTHEAD,ACCT_NO,ACCT_NAME,IS_LMSC,HDMTS,FIXSC,RELATED,ERASE,SCREEN,TNO,OPERATOR,UPDATE)
'        If IMRET Then Return
'     End If
'     CALL SR1520_Printer.Print  (LCNT,LINES,PT_LINE,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,ERASE,SCREEN,TNO,OPERATOR,UPDATE): RETURN
'7777 LOCATE(LDTE,MTH_ENDIFS,1,1,0,LPOS,"AR") ELSE NULL
'     Mth_Bals = Pick.replace(Mth_Bals, 1, LPOS, 0, Pick.extract(Mth_Bals, 1, LPOS, 0) + Amnt)
'     Return

End Sub

Public Sub srjob_chq(database As String, nrec() As String, Gl As String, Rect As Integer)
'SUB SR1520A_CQ (RELATED,FIXSC,IS_LMSC,GL,MAXCHQ,MAT CHQ_REC_DATA,CLIENT_DATA,end_date,PRNTHEAD,ST_DTE,OPBAL,OPBAL_FLG,UPDATE,BAL,SOY,LCNT,LINES,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,ACCT_NO,ACCT_NAME,HDMTS,MTH_ENDIFS,MTH_BALS,ERASE,SCREEN,TNO,OPERATOR,ATR,REC,RECT,ATTRS)

Dim i As Integer, Purno As String, Ccq As Integer, Found As Integer, Prdte As Integer, Amnt As Currency
Dim Ll As Integer, Ac As String, Ans As Currency, Bal As Currency, Cde As String, fname As String, pur As String
Dim end_date As Integer, maxchq As Integer, rderr As Integer

     end_date = 0
     
     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If
     If UBound(g_trans_info_array) < 133 Then ReDim Preserve g_trans_info_array(133)
     maxchq = pick.DCount(g_trans_info_array(31), Chr(253)) + 1
     
     For i = 1 To 999
        Purno = pick.extract(Gl, 64, i, 0)
        If Purno = "" Then GoTo 992
        For Ccq = 1 To maxchq
           fname = "CHQ.REC"
           If Ccq <> 1 Then fname = fname & Ccq
           If d3.d3_readstr(database, pur, fname, Purno) <> 0 Then GoTo 192
           If pick.extract(pur, 1, 0, 0) = "I" Or pick.extract(pur, 1, 0, 0) = "N" Then GoTo 192
           If pick.locate("JOB" & nrec(0), pur, 7, 1, 0, Found, "") = 0 Then GoTo 192
           GoTo 892
192     Next Ccq
        GoTo 991
892     Prdte = pick.extractint(pur, 3, 0, 0)
        'If end_date <> "" Then
        '   If Prdte = "" Then GoTo 192
        '   If Prdte > end_date Then GoTo 991
        '   If Pick.extract(pur, 1, 0, 0) = "S" And Pick.extract(pur, 4, 0, 0) <= end_date Then GoTo 192
        'Else
           If pick.extract(pur, 1, 0, 0) = "S" Then GoTo 192
        'End If
        Amnt = 0
        For Ll = 1 To 999
           Ac = pick.extract(pur, 7, Ll, 0)
           If Ac = "" And Amnt <> 0 Then GoTo 990
           If Ac = "" And Amnt = 0 Then GoTo 192
           If Ac <> "JOB" & nrec(0) Then GoTo 893
           Ans = pick.extractcur(pur, 8, Ll, 0)
           Amnt = Amnt + Ans
893     Next Ll
990     'If Prdte < ST_DTE And ST_DTE <> "" Then Opbal = Opbal + Amnt / 100: GoTo 991
        'If OPBAL_FLG Then GoTo 992
        'If Update = 3 And Upd Then
        '   Gl = Pick.delet(Gl, 64, I, 0)
        '   I = I - 1
        'End If
        Bal = Bal + Amnt / 100
        'If Update = 4 Then LDTE = Prdte: GoSub 7777
        'If SOY Then GoTo 991
        Cde = "Cheque " & Ccq
        Rect = Rect + 1
        nrec(1) = pick.Replace(nrec(1), 1, Rect, 0, CStr(Prdte))
        nrec(2) = pick.Replace(nrec(2), 1, Rect, 0, Cde)
        nrec(3) = pick.Replace(nrec(3), 1, Rect, 0, CStr(Amnt))
        nrec(7) = pick.Replace(nrec(7), 1, Rect, 0, Purno)
        nrec(9) = pick.Replace(nrec(9), 1, Rect, 0, pick.extract(pur, 6, 0, 0))
991  Next i
992  Exit Sub
'
'999  If PRNTHEAD Then
'        CALL SR1520A_HD (LCNT,LINES,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,PRNTHEAD,ACCT_NO,ACCT_NAME,IS_LMSC,HDMTS,FIXSC,RELATED,ERASE,SCREEN,TNO,OPERATOR,UPDATE)
'        If IMRET Then Return
'     End If
'     CALL SR1520_Printer.Print  (LCNT,LINES,PT_LINE,PORD,T$,CONTINUE_MSG,PCTR,REP_HEAD,IMRET,ERASE,SCREEN,TNO,OPERATOR,UPDATE): RETURN
'
'7777 LOCATE(LDTE,MTH_ENDIFS,1,1,0,LPOS,"AR") ELSE NULL
'     Mth_Bals = Pick.replace(Mth_Bals, 1, LPOS, 0, Pick.extract(Mth_Bals, 1, LPOS, 0) + Amnt)
'     Return

End Sub



Public Function get_array(logentry As String, sentence As String, OutArray)
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' PURPOSE:
'   Return item id's for items in pick that match the select sentence
'
' INPUTS:
'   sentence    :   Select sentence to retrieve data
'   start       :   Starting HTML text for the combo box
'   separator   :   HTML text to put between (at the start of) each id
'   suffix      :   HTML text to put at the end of each item id
'
' PROCESS:
'   the_ids     :   String containing HTML for combo box
'   mylist()    :   Item id's returned from the select sentence OR access query
'   id          :   Current item id taken from mylist()
'   total_items :   Number of items returned from select / query
'   j           :   Loop counter
'   pick_cnt    :   -No. of items returned (Same as total_items but negative)
'   dbname      :   ACCESS database name
'   field_name  :   ACCESS name of field to retrieve
'   table_name  :   ACCESS table name
'   newsent     :   ACCESS query sentence
'
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Dim the_ids As String, usedrop As Integer
Dim mylist() As String
Dim id As String, idlink As String, total_items As Long, j As Long, pick_cnt As Long
Dim is_msa As Integer, dbname As String, field_name As String, table_name As String, newsent As String 'mco 28apr99

is_msa = InStr(sentence, ".mdb\") 'mco 28apr99 - all to next mco28apr99
If is_msa <> 0 Then ' select * from filename
   ' sentence is sselect c:\ckashare\orkh\orkh.mdb\nationality a1,a2|order by xx
   dbname = Left(sentence, is_msa + 3)
   dbname = Mid(dbname, 9) 'remove the sselect
   field_name = pick.field(sentence, " ", 3)
   table_name = Mid(sentence, is_msa + 5): table_name = pick.field(table_name, " ", 1)
   newsent = "select " & field_name & " from " & table_name
   newsent = newsent & pick.field(sentence, "!", 2) 'mco 3oct01 'order by xxx must use ! as | used in templates
   total_items = d3.msa_select_var(dbname, newsent, OutArray)
   get_array = "0"
   Exit Function
Else  'sselect filename
   newsent = sentence
   total_items = d3.d3_select_var(logentry, sentence, OutArray)
End If

'If total_items <= 0 Then ReDim mylist(0): mylist(0) = newsent
get_array = "0" 'mylist
'ReDim OutArray(UBound(mylist))
'For j = 0 To UBound(mylist)
'    OutArray(j) = mylist(j)
'Next j

End Function

