<%
  OPTION EXPLICIT
   response.expires = 0 
   response.buffer=true

   Dim sentence,templatetouse,AdhocIds,Str,Ystr,result,page,title,holdno,Cmd,writeerror

   sentence= Request.Form("sentence")
   templatetouse= Request.Form("templatetouse")
   title= Request.Form("adhoctitle")
   AdhocIds= Request.Querystring("AdhocIds")

   Str = empty
  
   result = d3.execute_tcl(session("logentry"),Cstr(sentence),"",Cint(0))
   if left(result,4)="Hold" then
      holdno = trim(mid(result,14))
      Cmd = "COPY PEQS " & holdno & " (O"
      result = d3.execute_tcl(session("logentry"),Cstr(Cmd),"(PROSPOOL",Cint(0))
   else
      holdno="error"
      result = sentence & chr(254) & result
      writeerror = d3.d3_writestr(Cstr(session("database")),"PROSPOOL", cstr(holdno),cstr(result))
   end if
   result = picklin.prosprt(session("logentry"),CStr(holdno))
   page = "/prospect/asp/adhoc.asp?sentence=" & sentence & "&templatetouse=" & templatetouse & "&result=" & result & "&AdhocIds=" & AdhocIds & "&title=" & title
   Response.Redirect page 
%>