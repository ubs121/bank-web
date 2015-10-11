<% response.expires = 0 
   response.buffer=true
%>
<HTML>
<HEAD>
</HEAD>

<BODY>
<%

  StyleToUse=Session("userStyle")
  response.write(StyleToUse)

  file=Request.Form("file")
  item=Request.Form("assess")
  rec=Request.Form("rec")

  writeerror = d3.d3_writestr(cstr(file), cstr(item),cstr(rec))
  If writeerror <> "0" Then
     result = "Write to file " & file & " item " & item & " failed"
  Else
     result = "done"
  end if

  Response.Redirect "/prospect/asp/bi.asp?fn=property&tn=property&item=" & item & "&write_result=" & result
%>
</BODY>
</HTML>
