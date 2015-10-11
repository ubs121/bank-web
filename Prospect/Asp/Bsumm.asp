<!--#include file="Inc_timeout_test.asp"-->
<HTML>
<HEAD>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/menu.js"></SCRIPT>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
%>
</HEAD>

<BODY  onLoad="
          available_width=document.body.clientWidth;
          available_height=document.body.clientHeight;"> 

<!--#include file="Inc_home.asp"-->
<CENTER>
<%
'Special case - build summary pages for general ledger, which is arranged in group.class.subclass
filetouse = request.querystring("fn")

'Atype can be A for Asset, L for Liab, U for unappropriated
atype = Request.Querystring("atype")

'Qtype can be 0 for all groups of atype, or n.0 for all classes of group n, or n.m.0 for all subclasses.
'Individual items should be built using the normal /prospect/asp/bi.asp
qtype = Request.Querystring("qtype")

response.write("<P><h2 align=center>General Ledger Summary")

Select Case atype
	Case "A":
		response.write(" : Assets")
	Case "L":
		response.write(" : Liabilities")
	Case "U":
		response.write(" : Unappropriated Operating Results")
End Select

response.write("</h2>" & chr(13))


'''''''''''''''''''''''''''''''''''''''
'Get item id's that match summary type
'''''''''''''''''''''''''''''''''''''''
if qtype = "0" then
	response.write("<table ALIGN=CENTER BORDER=1 CELLSPACING=1 CELLPADDING=1><tr class=top>")
	response.write("<th>Account")
	response.write("<th>Description")
	response.write("<th>Balance")

	if atype = "A" then
		query = "sselect " & filetouse & " with a10 = " & chr(34) & "A" & chr(34) & " and with class = " & chr(34) & "0" & chr(34) & " by group"
	ElseIf atype = "L" then
		query = "sselect " & filetouse & " with a10 = " & chr(34) & "L" & chr(34) & " and with class = " & chr(34) & "0" & chr(34) & " by group"
	Else
		query = "sselect " & filetouse & " with CLASS = " & chr(34) & "0" & chr(34) & " and with TYPE = " & chr(34) & "C" & chr(34) & " by group"
	End if
	Dim fred,itemarray
      fred = picklin.get_array(Session("logentry"),cstr(query),itemarray)
	align = ""

	for counter = 0 to ubound(itemarray)
         
		response.write("<tr>")
            tmpdata = d3.d3_readmat_var(session("database"), cstr(filetouse), cstr(itemarray(counter)), tmparray)

		response.write("<td class=top><A HREF=" & chr(34) & "/prospect/asp/bsumm.asp?fn=" & filetouse & "&tn=gen_l_summary&qtype=" & itemarray(counter) & "&atype=" & atype & chr(34) & ">" & itemarray(counter) & "</A>")
            response.write("<td>" & tmparray(2))
            val = tmparray(3)
            if Isnumeric(val) then val = FormatCurrency(val)
            response.write("<td align=right>" & val)
		response.write(chr(13))
	next


'''''''''''''''''''''''''''''''''''''''''''''''''
'Second time - show all xxx.yyy when clicking xxx
'''''''''''''''''''''''''''''''''''''''''''''''''
elseif right(qtype,2) = ".0" then

	tmptype = left(qtype,(len(qtype)-2))
	query = "sselect " & filetouse & " with group = " & chr(34) & tmptype & chr(34) & " and with subclass = " & chr(34) & chr(34)
      fred = picklin.get_array(Session("logentry"),cstr(query),itemarray)

	'if the only thing returned is the same as the query there are no subclasses so show individual item page
	if ubound(itemarray) = 0 then
		redirstring = "/prospect/asp/bi.asp?fn=" & filetouse & "&tn=gen_l&item=" & tmptype
		response.redirect(redirstring)
	end if

	response.write("<table ALIGN=CENTER BORDER=1 CELLSPACING=1 CELLPADDING=1><tr class=top>")
	response.write("<th>Account")
	response.write("<th>Description")
	response.write("<th>Balance" & chr(13))

	align = ""

	for counter = 0 to ubound(itemarray)
		response.write("<tr>")

            tmpdata = d3.d3_readmat_var(session("database"), cstr(filetouse), cstr(itemarray(counter)), tmparray)
		'The first item in this list will be x.0 so if clicked we want an individual item page
		if counter = 0 then
			response.write("<td class=top><A HREF=" & chr(34) & "/prospect/asp/bi.asp?fn=" & filetouse & "&tn=gen_l&item=" & itemarray(counter) & chr(34) & ">" & itemarray(counter) & "</A>")
		else
			response.write("<td class=top><A HREF=" & chr(34) & "/prospect/asp/bsumm.asp?fn=" & filetouse & "&tn=gen_l_summary&qtype=" & itemarray(counter) & "&atype=" & atype & chr(34) & ">" & itemarray(counter) & "</A>")
		end if
            response.write("<td>" & tmparray(2))
            val = tmparray(3)
            if Isnumeric(val) then val = FormatCurrency(val)
            response.write("<td align=right>" & val)
		response.write(chr(13))
	next


'''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Last time - show all xxx.yyy.zzz when clicking xxx.yyy
'''''''''''''''''''''''''''''''''''''''''''''''''''''''

else	
	tmpgroup = left(qtype,instr(qtype,".")-1)
	tmpclass = right(qtype,len(qtype) - instr(qtype,"."))

	query = "sselect " & filetouse & " with group = " & chr(34) & tmpgroup & chr(34) & " and with class = " & chr(34) & tmpclass & chr(34)
      fred = picklin.get_array(Session("logentry"),cstr(query),itemarray)

'Copied from above

	'if the only thing returned is the same as the query there are no subclasses so show individual item page
	'if qtype = itemlist then
	if ubound(itemarray) = 0 then
      	redirstring = "/prospect/asp/bi.asp?fn=" & filetouse & "&tn=gen_l&item=" & tmptype
		response.redirect(redirstring)
	end if
      response.write("<TABLE ALIGN=CENTER BORDER=1 CELLSPACING=1 CELLPADDING=1>")
      response.write("<TR class=top>")

	response.write("<th>Account")
	response.write("<th>Description")
	response.write("<th>Balance" & chr(13))
	align = ""

	for counter = 0 to ubound(itemarray)
		response.write("<tr>")
            tmpdata = d3.d3_readmat_var(session("database"), cstr(filetouse), cstr(itemarray(counter)), tmparray)
'We always want an individual item page from here
		response.write("<td class=top><A HREF=" & chr(34) & "/prospect/asp/bi.asp?fn=" & filetouse & "&tn=gen_l&item=" & itemarray(counter) & chr(34) & ">" & itemarray(counter) & "</A>")

            response.write("<td>" & tmparray(2))
		'For subclasses, the acct balance is held in bal4 not bal3
            if counter = 0 then
               val=tmparray(3)
            else
               val = tmparray(4)
            end if
            if Isnumeric(val) then val = FormatCurrency(val)
            response.write("<td align=right" & ">" & val)
		response.write(chr(13))
	next

'End copy


end if


response.write("</table>")

%>
</CENTER>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
</BODY>
</HTML>