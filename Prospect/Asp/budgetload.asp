<%
 OPTION EXPLICIT
 response.expires = 0 
 response.buffer=true
 Server.ScriptTimeout = 200
'after = Request.Querystring("after")
'response.write("after = " & after)
'response.end
 Dim UploadResult,Upload,Field,Path,UploadFileName,UploadFolder
 Dim AttachColumnId,Template,ReturnPage,StyleToUse,PathTouse,After,Sentence
 Dim AccountCol,SRow,ERow,SizeLimit,gl
 Dim AttachmentPath,Page,ReportPage,result,ErrorMessage,pos,IniPath

 AttachmentPath=Server.MapPath("/prospect_site/Budget") 
 IniPath=Server.MapPath("/prospect") 
 UploadFileName=""
 
 If Request.ServerVariables("REQUEST_METHOD") = "POST" Then 
    Set Upload = GetUpload(ReturnPage,ErrorMessage)

    call GetFormDetails(Upload,AttachColumnId)
'response.write("after = " & after & "<BR> path = " & path)
'Response.end 
   If Err = 0 AND ErrorMessage="" Then
      UploadResult = SaveUpload(Upload,Path,AttachColumnId)
'response.write("UploadResult = " & uploadresult)
'response.end
      UploadFileName=UploadResult 
      After=AttachmentPath & "\" & UploadFileName & chr(254) & "2001" & chr(254) & "A" & chr(254) & "2" & chr(254) & "3" & chr(254) & "B" & chr(254) & "C" 'after
      'response.write("After=" & After & "<BR>")
 '     response.write("IniPath=" & IniPath & "<BR>")
      'response.end
      Set gl = Server.CreateObject("cka_gl.gl")
      result= gl.load_budgets_from_excel(cstr(after))
	  Set gl = nothing
      pos=Instr(result,chr(8))
      if pos then
         ErrorMessage=result
	  else
	     result = "Budgets Updated"
      end if
    Else
      if ErrorMessage="" then 
         UploadResult = "Error : " & Err.Description
         ErrorMessage=Err.Description
      end if
    End If
  
     ReportPage = "/prospect/asp/my_budget.asp?sentence=" & sentence & "&reportname=" & ReturnPage & "&template=" & template & "&result=" & Server.urlencode(result) & "&erroruploadfile=" &  Server.URLEncode(ErrorMessage)
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
            	Case "AccountCol":AccountCol=BinaryToString(Field.Value.ByteArray)
           	    Case "SRow":SRow=BinaryToString(Field.Value.ByteArray)
           	    Case "ERow":Erow=BinaryToString(Field.Value.ByteArray)
 				Case "after":after=BinaryToString(Field.Value.ByteArray)
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

