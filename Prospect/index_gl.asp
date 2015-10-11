<%
   response.expires = 0 
   Session("d3needed") = "no"
   name = Request.ServerVariables("path_info") 'eg gets like "/prospect/index_xxxxxx.asp" where xxx is name of item
   Session("name") = name
   pos = instr(name,"index_")
   if pos=0 then
      name="ex_template.asp"
   else
      name="ex_template" & mid(name,pos+5)
   end if
   Session("ex_template") = name ' eg ex_template_xxxxxx.asp
   response.redirect "/prospect/asp/login.asp"
%>
