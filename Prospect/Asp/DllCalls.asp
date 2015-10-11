<%@ LANGUAGE=VBSCRIPT %>
<!--#INCLUDE FILE="rs.asp"-->
<% RSDispatch %>
<SCRIPT RUNAT=SERVER Language=javascript>
	function Description()
	{ 
      this.GetWorkSheets = Function( 's1','s2','return GetWorkSheets(s1,s2)' );
	  this.GetWorkSheetPrefs = Function( 's1','s2','s3','return GetWorkSheetPrefs(s1,s2,s3)');
	  this.ReadStr = Function( 's1','s2','return ReadStr(s1,s2)' );
	  this.GetSheetData = Function( 's1','s2','return GetSheetData(s1,s2)' );
	  this.GetExcelData = Function( 's1','s2','return GetExcelData(s1,s2)' );
	  this.ValidateAccount = Function( 's1','s2','return ValidateAccount(s1,s2)' );
	  this.UpdBudgets = Function( 's1','s2','s3','s4','return UpdBudgets(s1,s2,s3,s4)' );
	  this.AdoptBudget = Function( 's1','return AdoptBudget(s1)' );
      this.WriteStr = Function( 's1','s2','s3','return WriteStr(s1,s2,s3)');
	  this.BuildString = Function( 's1','s2','return BuildString(s1,s2)' );
      this.SelectCount = Function( 's1','return SelectCount(s1)' );
      this.BuildSearch = Function( 's1','s2','s3','s4','return BuildSearch(s1,s2,s3,s4)' );
	  this.BuildNextPage = Function( 's1','s2','s3','s4','s5','s6','s7','s8','s9','s10','return BuildNextPage(s1,s2,s3,s4,s5,s6,s7,s8,s9,s10)' );
      this.UpdateAccount = Function( 's1','s2','s3','s4','s5','return UpdateAccount(s1,s2,s3,s4,s5)' );	  
 	}
	public_description = new Description();
</SCRIPT>

<SCRIPT RUNAT=SERVER LANGUAGE="VBScript">
'**************************************************
Function ReadStr(file,item)
    ReadStr=PickLin.readstr(Cstr(session("database")),cstr(file), trim(cstr(item)))
End Function
'**************************************************
Function GetSheetData(logentry,Params)
    Dim cka_gl
    Set cka_gl = CreateObject("cka_gl.gl")
    GetSheetData = cka_gl.sr555(Cstr(logentry),Cstr(Params))
    Set cka_gl = Nothing
End Function
'**************************************************
Function GetExcelData(logentry,Params)
    Dim cka_gl
    Set cka_gl = CreateObject("cka_gl.gl")
    GetExcelData = cka_gl.GetExcelData(Cstr(logentry),Cstr(Params))
    Set cka_gl = Nothing
End Function
'**************************************************
Function UpdateAccount(TableName,Accno,Before,After,action)
    Dim cka_gl
    Set cka_gl = CreateObject("cka_gl.gl")
	UpdateAccount = "table = " & TableName & " Item= " & Accno & " Before= " & Before & "after= " & After
    UpdateAccount = cka_gl.gl_account_update(Cstr(TableName),Cstr(Accno),Cstr(Before),Cstr(After),Cstr(action))
    Set cka_gl = Nothing

End Function
'**************************************************
Function ValidateAccount(TableName,Params)
    Dim cka_gl
    Set cka_gl = CreateObject("cka_gl.gl")
    ValidateAccount = cka_gl.validate_account(Cstr(TableName),Cstr(Params))
    Set cka_gl = Nothing 
End Function
'**************************************************
Function UpdBudgets(logentry,Params,d3needed,Reference)
    Dim cka_gl
    Set cka_gl = CreateObject("cka_gl.gl")
    UpdBudgets = cka_gl.load_budgets_from_excel(Cstr(logentry),Cstr(Params),Cstr(d3needed),Cstr(Reference))
    Set cka_gl = Nothing
End Function
'**************************************************
Function AdoptBudget(logentry)

    Dim cka_gl
    Set cka_gl = CreateObject("cka_gl.gl")
    AdoptBudget = cka_gl.AdoptBudget(Cstr(logentry))
    Set cka_gl = Nothing
End Function
'**************************************************
Function WriteStr(file,item,rec)
    
    rec=Cstr(rec)
    rec= Replace(rec, "’", "'")
    rec=Replace(rec, "”", """")
    if instr(file,".mdb!") <> 0 then
       sarr=split(rec,chr(254), -1, vbBinaryCompare)
       for kk=0 to ubound(sarr)
          itemarr=split(sarr(kk),chr(253), -1, vbBinaryCompare)
          WriteStr = d3.d3_writestr(Cstr(session("database")),cstr(replace(file,"!","\")), cstr(itemarr(1)),cstr(itemarr(0))) & "=" & itemarr(0)
       next
    else
       WriteStr = d3.d3_writestr(Cstr(session("database")),file, cstr(item),cstr(rec)) & "=here"
    end if

End Function
'**************************************************
Function BuildString(item,conversion)
   if instr(conversion,"!")<>0 and left(conversion,1)="T" then
      conversion=replace(conversion,"!","\")
   end if
'response.write(conversion & "=" & item)
'response.end
   BuildString=d3.conv_out(Cstr(session("database")),"",0,cstr(conversion),cstr(item))
End Function
'**************************************************
Function SelectCount(sentence)
    SelectCount=PickLin.RSSelectCount(Session("logentry"),cstr(sentence))
End Function
'**************************************************
Function BuildSearch(Sentence,Xtra,PageSize,SearchTemplate)

  Dim PhysicalPath,NewTemplatesPath

   PhysicalPath = Server.MapPath("/prospect/search/" & SearchTemplate)
   NewTemplatesPath = Server.MapPath("/prospect/template/")
   BuildSearch=PickLin.RSBuildSearch(Session("logentry"),Cstr(Sentence),Cstr(xtra),Cstr(PageSize),Cstr(PhysicalPath),Cstr(NewTemplatesPath),"RS")

End Function
'**************************************************
Function BuildNextPage(Filetouse, Sentence, Templatetouse,Page, PageSize,Title, Hds, Tds, Dms,NewTemplates)

    BuildNextPage=PickLin.making_html(Server.MapPath("\prospect\template\"),Session("logentry"),Cstr(Filetouse), Cstr(Sentence), Cstr(Templatetouse), Cstr(Page), Cstr(PageSize), "0", "", "", 0, "", Cstr(Title), Cstr(Hds), Cstr(Tds), Cstr(Dms),"","",Cstr(NewTemplates))

End Function
'**************************************************
Public Function GetWorkSheets(ExcelFile,Delimiter)

    GetWorkSheets=Picklin.RSGetWorkSheets(Cstr(ExcelFile),Cstr(Delimiter))

End Function
'**************************************************
Public Function GetWorkSheetPrefs(PrefsFile,ExcelFile,WorkSheet)

   GetWorkSheetPrefs=Picklin.RSGetWorksheetPrefs(Cstr(PrefsFile), Cstr(ExcelFile), Cstr(WorkSheet))
 
End Function
'**************************************************

</SCRIPT>