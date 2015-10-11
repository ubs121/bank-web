<%
 response.buffer=true
if Session("d3needed") = "" then
   response.redirect "/prospect/asp/timeout.asp"
end if

%>