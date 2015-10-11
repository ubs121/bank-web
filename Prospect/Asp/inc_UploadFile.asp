<SCRIPT RUNAT=SERVER LANGUAGE=VBSCRIPT>
'*************************************************************************
Function SaveUpload(Fields,Path,AttachColumnId)

  Dim OutFolder,SaveFileName,Field,FullPath

  OutFolder = Server.MapPath(Path)
  
  For Each Field In Fields.Items
    SaveFileName = Empty

    if Lcase(Field.Name) = LCase(AttachColumnID) then     
   
        If Field.FileName <> "" Then 
           'SaveFileName = Field.Name & "\" & Field.FileName
            SaveFileName =  Field.FileName
        End If

        If Not IsEmpty(SaveFileName) Then
           FullPath=OutFolder & "\" & SaveFileName
           SaveFileName=Field.Value.SaveAs(FullPath)
        End If
    Exit For
    End if
  Next

SaveUpload= SaveFileName 
End Function
'*************************************************************************
Function LogF(ByVal F)
	If "" & F = "" Then F = "-" Else F = "" & F
	F = replace(F, vbCrLf, "%13%10")
	F = replace(F, ",", "%2C")
	LogF = F
End Function
'*************************************************************************
Function LogFn(ByVal F)
  If "" & F = "" Then LogFn = "-" Else LogFn = formatnumber(F, 0)
End Function
'************************************************************************************
Function GetUpload(ReturnPage,ErrorMessage)
  Dim Result, Head, Binary,ContentType, PosB, Boundary, Length, PosE
  Dim NewPage 
     
  Set Result = Nothing

  ContentType = Request.ServerVariables("HTTP_Content_Type")

    If LCase(Left(ContentType, 19)) = "multipart/form-data" Then 
       PosB = InStr(LCase(ContentType), "boundary=") 
       If PosB > 0 Then Boundary = Mid(ContentType, PosB + 9) 
       Length = CLng(Request.ServerVariables("HTTP_Content_Length")) 
       If Length > 0 And Boundary <> "" Then 
       Boundary = "--" & Boundary
       Binary = Request.BinaryRead(Length) 
       Set Result = SeparateFields(Binary, Boundary)
       Binary = Empty
      Else
        Err.Raise 10, "GetUpload", "Zero length request ."
      End If
    Else
      Err.Raise 11, "GetUpload", "No file sent."
    End If
  Set GetUpload = Result
End Function

'****************************************************************************************

Function SeparateFields(Binary, Boundary)
  Dim PosOpenBoundary, PosCloseBoundary, PosEndOfHeader, isLastBoundary
  Dim Fields
  Boundary = StringToBinary(Boundary)

  PosOpenBoundary = InStrB(Binary, Boundary)
  PosCloseBoundary = InStrB(PosOpenBoundary + LenB(Boundary), Binary, Boundary, 0)

  Set Fields = CreateObject("Scripting.Dictionary")
  Do While (PosOpenBoundary > 0 And PosCloseBoundary > 0 And Not isLastBoundary)

    Dim HeaderContent, FieldContent, bFieldContent
    Dim Content_Disposition, FormFieldName, SourceFileName, Content_Type
    Dim Field, TwoCharsAfterEndBoundary

    PosEndOfHeader = InStrB(PosOpenBoundary + Len(Boundary), Binary, StringToBinary(vbCrLf + vbCrLf))
    HeaderContent = MidB(Binary, PosOpenBoundary + LenB(Boundary) + 2, PosEndOfHeader - PosOpenBoundary - LenB(Boundary) - 2)
    bFieldContent = MidB(Binary, (PosEndOfHeader + 4), PosCloseBoundary - (PosEndOfHeader + 4) - 2)

    GetHeadFields BinaryToString(HeaderContent), Content_Disposition, FormFieldName, SourceFileName, Content_Type

    Set Field = CreateUploadField()
    Set FieldContent = CreateBinaryData()
    FieldContent.ByteArray = bFieldContent
    FieldContent.Length = LenB(bFieldContent)

    Field.Name = FormFieldName
    Field.ContentDisposition = Content_Disposition
    Field.FilePath = SourceFileName
    Field.FileName = GetFileName(SourceFileName)
    'response.write("filename=" & Field.Filename & "<BR>")

    Field.ContentType = Content_Type
    Field.Length = FieldContent.Length

    Set Field.Value = FieldContent
'    response.write(FieldContent.String & "<BR>")
    Fields.Add FormFieldName, Field

    TwoCharsAfterEndBoundary = BinaryToString(MidB(Binary, PosCloseBoundary + LenB(Boundary), 2))
    isLastBoundary = TwoCharsAfterEndBoundary = "--"

    If Not isLastBoundary Then 
      PosOpenBoundary = PosCloseBoundary
      PosCloseBoundary = InStrB(PosOpenBoundary + LenB(Boundary), Binary, Boundary)
    End If
  Loop
  Set SeparateFields = Fields
End Function

'********************************************************************************
Function GetHeadFields(ByVal Head, Content_Disposition, Name, FileName, Content_Type)

'  response.write("head=" & Head & "<BR>")
 
  Content_Disposition = LTrim(SeparateField(Head, "content-disposition:", ";"))
  Name = (SeparateField(Head, "name=", ";")) 
  If Left(Name, 1) = """" Then Name = Mid(Name, 2, Len(Name) - 2)
  FileName = (SeparateField(Head, "filename=", ";"))
  If Left(FileName, 1) = """" Then FileName = Mid(FileName, 2, Len(FileName) - 2)
  Content_Type = LTrim(SeparateField(Head, "content-type:", ";"))

'  response.write("sourcefile=" & FileName & "<BR>")

End Function
'*****************************************************************************
Function SeparateField(From, ByVal sStart, ByVal sEnd)
  Dim PosB, PosE, sFrom
  sFrom = LCase(From)
  PosB = InStr(sFrom, sStart)
  If PosB > 0 Then
    PosB = PosB + Len(sStart)
    PosE = InStr(PosB, sFrom, sEnd)
    If PosE = 0 Then PosE = InStr(PosB, sFrom, vbCrLf)
    If PosE = 0 Then PosE = Len(sFrom) + 1
    SeparateField = Mid(From, PosB, PosE - PosB)
  Else
    SeparateField = Empty
  End If
End Function
'*****************************************************************************
Function GetFileName(FullPath)
  Dim Pos, PosF
  PosF = 0
  For Pos = Len(FullPath) To 1 Step -1
    Select Case Mid(FullPath, Pos, 1)
      Case "/", "\": PosF = Pos + 1: Pos = 0
    End Select
  Next
  If PosF = 0 Then PosF = 1
  GetFileName = Mid(FullPath, PosF)
End Function
'*****************************************************************************
Function BinaryToString(Binary)
  dim cl1, cl2, cl3, pl1, pl2, pl3
	Dim L', nullchar
	cl1 = 1
	cl2 = 1
	cl3 = 1
  L = LenB(Binary)
  
	Do While cl1<=L
		pl3 = pl3 & Chr(AscB(MidB(Binary,cl1,1)))
	  cl1 = cl1 + 1
	  cl3 = cl3 + 1
		if cl3>300 then
			pl2 = pl2 & pl3
			pl3 = ""
			cl3 = 1
  	  cl2 = cl2 + 1
		  if cl2>200 then
			  pl1 = pl1 & pl2
			  pl2 = ""
			  cl2 = 1
      End If
		End If
	Loop
	BinaryToString = pl1 & pl2 & pl3
End Function
'*****************************************************************************
Function BinaryToStringold(Binary)
  Dim I, S
  For I = 1 To LenB(Binary)
    S = S & Chr(AscB(MidB(Binary, I, 1)))
  Next
  BinaryToString = S
End Function
'*****************************************************************************
Function StringToBinary(String)
  Dim I, B
  For I=1 to len(String)
    B = B & ChrB(Asc(Mid(String,I,1)))
  Next
  StringToBinary = B
End Function
'*****************************************************************************
Function vbsSaveAs(FullFilePath, ByteArray,ReturnPage)
	Dim FS, TextStream,OriginalFileName,ctr
    Dim TempFileName,NewFileName,FileExtension,FileData
    Dim CKAstart,CKAend,CurrentNumber

    CKAstart="$~": CKAend="~"
    CurrentNumber=1
    'files will be named as follows: $~1~FILENAME,$~2~FILENAME,... $~99~FILENAME 

      Set FS = CreateObject("Scripting.FileSystemObject")
      FileData= checkFileExtension(FullFilePath,ByteArray,ReturnPage)
      OriginalFileName= GetFileName(FullFilePath)
      NewFileName=CKAstart  &  CurrentNumber & CKAend & OriginalFilename
      TempFileName = Replace(FullFilePath, OriginalFileName, NewFileName, 1, -1, vbTextCompare)

   Do while FS.FileExists(TempFileName)
       CurrentNumber=CurrentNumber + 1
       NewFileName="$~" & CurrentNumber & "~" & OriginalFileName
       TempFileName = Replace(FullFilePath, OriginalFileName, NewFileName, 1, -1, vbTextCompare)
   Loop    
  Set TextStream = FS.CreateTextFile(TempFileName)
		TextStream.Write FileData
  TextStream.Close
  vbsSaveAs=GetFileName(TempFileName) 
End Function
'*****************************************************************************
Function checkFileExtension(FileName,ByteArray,ReturnPage)
 Dim Page,FileExtension,extension,ctr,BadExtension,ErrorMessage,pos,FileTypes,FileData,FileSize
 Dim AllowedExts(7),Abort
 Abort=0

 AllowedExts(0)="txt"
 AllowedExts(1)="bmp"
 AllowedExts(2)="jpg"
 AllowedExts(3)="doc"
 AllowedExts(4)="xls"
 AllowedExts(5)="gif"
 AllowedExts(6)="zip"
 AllowedExts(7)="htm"

  BadExtension=1

  FileName = Replace(FileName, ".ini", ".txt", 1, -1, vbTextCompare)
  FileName = Replace(FileName, ".log", ".txt", 1, -1, vbTextCompare)

  pos=Instr(FileName,".")
  if pos then     
    FileExtension=SPLIT(FileName,".")
    extension=FileExtension(1)
  
    For ctr=0 To 7
        If Lcase(extension)=AllowedExts(ctr) then
           BadExtension=0
           Exit For
       End If  
    Next
   extension= "(*." & extension & ")"
  else
   extension="(No File Extension)"
  end if

 
 If BadExtension then
    ErrorMessage= "Files of Type " & extension & " cannot be uploaded"
    FileTypes="Permissible File Types: Text(.txt), Bitmaps(.bmp), Jpegs(.jpg), MS Word Docs(.doc), MS Excel(.xls), Gifs(.gif)"
    Abort=1
 End if

 FileData= BinaryToString(ByteArray)
 FileSize=len(FileData)

 If FileSize=0 then
    ErrorMessage="File Does Not Exist or is Empty"
    FileTypes="" 
    Abort=1
 End if

  If Abort then 
    Page = "/prospect/reports/"  & template & "/" & ReturnPage & ".asp?erroruploadfile=" &  Server.URLEncode(ErrorMessage) & "&filetypes=" & Server.URLEncode(FileTypes)
    'response.write("Page=" & Page)
    'response.end
     Response.Redirect Page 
  End if

 checkFileExtension=FileData

End Function
'*****************************************************************************
</SCRIPT>



<SCRIPT RUNAT=SERVER LANGUAGE=JSCRIPT>
//'*****************************************************************************
function CreateUploadField(){ return new uf_Init() }
//'*****************************************************************************
function uf_Init(){
  this.Name = null
  this.ContentDisposition = null
  this.FileName = null
  this.FilePath = null
  this.ContentType = null
  this.Value = null
  this.Length = null
}
//'*****************************************************************************
function CreateBinaryData(){ return new bin_Init() }
//'*****************************************************************************
function bin_Init(){
	this.ByteArray = null
	this.Length = null
	this.String = jsBinaryToString
	this.SaveAs = jsSaveAs
}
//'*****************************************************************************
function jsBinaryToString(){return BinaryToString(this.ByteArray)};
//'*****************************************************************************
function jsSaveAs(FileName){return vbsSaveAs(FileName, this.ByteArray,ReturnPage)}
//'*****************************************************************************
</SCRIPT>
