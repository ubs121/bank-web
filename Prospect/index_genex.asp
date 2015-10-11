<%
   response.expires = 0 
   Session("d3needed") = "yes"
   Session("ex_template") = "ex_template_genex"
   Session("name") = "/prospect/index_genex.asp"
   Session("menujs")="menu2.js" 
   Session("checkboxjs")="checkbox2.js" 
   response.redirect "/prospect/asp/login.asp"
%>
