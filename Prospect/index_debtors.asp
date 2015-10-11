<%
   response.expires = 0 
   Session("d3needed") = "yes"
   Session("ex_template") = "ex_template_buildit"
   Session("name") = "/prospect/index_buildit.asp"
   Session("menujs")="menu5.js" 
   Session("checkboxjs")="checkbox5.js" 
   response.redirect "/prospect/asp/login.asp"
%>
