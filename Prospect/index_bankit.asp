<%
   response.expires = 0 
   Session("d3needed") = "yes"
   Session("ex_template") = "ex_template_bankit"
   Session("name") = "/prospect/index_bankit.asp"
   Session("menujs")="menu2.js" 
   Session("checkboxjs")="checkbox2.js" 
   response.redirect "/prospect/asp/login.asp"
%>
