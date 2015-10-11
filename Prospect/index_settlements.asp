<%
   response.expires = 0 
   Session("d3needed") = "yes"
   Session("ex_template") = "ex_template_settlements"
   Session("name") = "/prospect/index_settlements.asp"
   Session("menujs")="menu4.js" 
   Session("checkboxjs")="checkbox4.js" 
   response.redirect "/prospect/asp/login.asp"
%>
