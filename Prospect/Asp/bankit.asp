<%
 OPTION EXPLICIT
 response.buffer=true
 Server.ScriptTimeout = 200

 Dim UploadResult,Upload,Field,Path,UploadFileName,UploadFolder
 Dim AttachColumnId,Template,ReturnPage,StyleToUse,PathTouse,After,Sentence
 Dim DepositNumber,BankAccount,SizeLimit
 Dim AttachmentPath,Page,ReportPage,result,ErrorMessage,pos,IniPath

 AttachmentPath=Server.MapPath("/prospect_site/BankIt") 
 IniPath=Server.MapPath("/prospect") 
 UploadFileName=""
 
 If Request.ServerVariables("REQUEST_METHOD") = "POST" Then 
    Set Upload = GetUpload(ReturnPage,ErrorMessage)
    call GetFormDetails(Upload,AttachColumnId)
  
   If Err = 0 AND ErrorMessage="" Then
      UploadResult = SaveUpload(Upload,Path,AttachColumnId)
      UploadFileName=UploadResult 
      After=AttachmentPath & "\" & UploadFileName & chr(254) & BankAccount & chr(254) & DepositNumber
      'response.write("After=" & After)
      'response.write("IniPath=" & IniPath)
      ' response.end
      result= PickLin.bankit_read(session("database"), cstr(after),cstr(IniPath) & "\banks.ini" )
      pos=Instr(result,chr(8))
      if pos then
         ErrorMessage=result
         DepositNumber=""
      Else
        DepositNumber="D" & DepositNumber & "D"
      end if
    Else
      if ErrorMessage="" then 
         UploadResult = "Error : " & Err.Description
         ErrorMessage=Err.Description
      end if
    End If
  
     ReportPage = "/prospect/reports/" & template & "/" & ReturnPage & ".asp?sentence=" & sentence & "&reportname=" & ReturnPage & "&template=" & template & "&result=" & Server.urlencode(result) & "&erroruploadfile=" &  Server.URLEncode(ErrorMessage) & "&DepositNumber=" & DepositNumber
     'response.write("<BR>" & ReportPage)
     'response.end
     Response.Redirect ReportPage 
 End if

 Upload = Empty
  
'**************************************************************************************************************
Function GetFormDetails(Upload,AttachColumnID)

 Dim Field,Data
 
  FOR EACH Field IN Upload.Items
        if Lcase(Field.Name) <> LCase(AttachColumnID) then     
            Data=BinaryToString(Field.Value.ByteArray)
'            response.write("Field.Name=" & Field.Name & ":  " & Data & "<BR>")

            Select Case Field.Name
	            Case "reportname":ReturnPage=BinaryToString(Field.Value.ByteArray)
    	        Case "template":Template=BinaryToString(Field.Value.ByteArray)
        	    Case "path":Path=BinaryToString(Field.Value.ByteArray)
            	Case "sentence":Sentence=BinaryToString(Field.Value.ByteArray)
         	    Case "AttachColumnId":AttachColumnId=BinaryToString(Field.Value.ByteArray)
            	Case "DepositNumber":DepositNumber=BinaryToString(Field.Value.ByteArray)
           	    Case "BankAccount":BankAccount=BinaryToString(Field.Value.ByteArray)
            End Select
        end if
  Next

  'response.end
End Function
'**************************************************************************************************************
%>
<!--#INCLUDE FILE="inc_UploadFile.asp"-->
<HTML>
<HEAD>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
%>
</HEAD>
</BODY>
</HTML>
