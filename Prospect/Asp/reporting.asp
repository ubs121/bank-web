<% response.expires = 0 
   response.cachecontrol = "public"
   response.buffer=true
%>
<HTML>
<HEAD>
</HEAD>

<BODY>

<%

  sentence= Request.Form("sentence")
  sentence=replace(sentence,chr(8),"""")
  template= Request.Form("template")
  if template="" then template=Request.Querystring("template")
  reportname= Request.Form("reportname")
  after=    Request.Form("after")
  account_name= session("account_name")
  user_name= session("user_name")
  passwrd=session("passwrd")
  Dim Str,Ystr,DQ,DocPath
  Str = empty
  Ystr = "Y"
  DQ = chr(34)
  DocPath = Server.MapPath("/Prospect_site/Documents")
  searchsent= Request.Querystring("mysent")
  cook_id="TA" & left(reportname,instr(reportname," ")-1)
  'response.write("cook_id=" & cook_id & "<BR>")
  response.cookies(cook_id)("parms") = Request.Form("before")
  response.cookies(cook_id).expires = date + 365

  'response.end
  select case cook_id
  
      case "TA111"
	 	result = d3.execute_tcl(session("logentry"),"listu",str)
'     case "TA182"
'		result = d3.execute_tcl(session("logentry"),"TA182",Cstr("PROSPECT" & chr(254) & searchsent & chr(254) & after & chr(254) & ""))
'		result = "Report Spooled"
     case "TA192"
		result = d3.execute_tcl(session("logentry"),"TA192",Cstr("PROSPECT" & chr(254) & searchsent & chr(254) & after & chr(254) & ""))
		result = GetHoldFile(logentry,result,DocPath)
     case "TA3140"
        Set cka_ta31 = Server.CreateObject("cka_ta31.ta31")
        result = cka_ta31.sr3140a(session("logentry"),cstr(after))
        Set cka_ta31 = nothing
	 case "TA245"
	 	result = d3.execute_tcl(session("logentry"),"TA245",cstr(after),cint("1"))
		result = GetHoldFile(logentry,result,DocPath)
	 case "TA246"
	    result = d3.execute_tcl(session("logentry"),"TA246",Cstr(after & chr(254) & chr(27) & chr(254) & Ystr), cstr("1"))
		result = "Report Spooled"
     case "TA305"
		result = d3.execute_tcl(session("logentry"),cstr(cook_id),Cstr(after))
		result = GetHoldFile(logentry,result,DocPath)
     case "TA312"
		result = d3.execute_tcl(session("logentry"),"TA312", Cstr(after & chr(254) & Ystr & chr(254)),cint("1"))
		result = "Report Spooled"
     case "TA3131","TA3133","TA3148","TA3148A"
		tname=cook_id
		fname=chr(8) & after
		sname="1"
		title=""
		placetogo = "/prospect/asp/bi.asp?fn=" & fname & "&tn=" & tname ' & "&item=" & sname &  "&sn=" & title  & "&who=reportingasp"
		Response.Redirect placetogo
		response.end
	case "TA682"
'Response.write("searchsent = " & searchsent)
'Response.end
        searchsent = replace(searchsent,chr(254),DQ)
		pararray = split(after,chr(254))
		if pararray(2) = "O" then
			if not(isnumeric(pararray(3))) or pararray(3) < "1" or pararray(3) > "4" then
				result = "Invalid Number of Overdue Periods"
			else
				if not(isnumeric(pararray(4))) then
					result = "Invalid Outstanding Balance"
				else
					result = d3.execute_tcl(session("logentry"),"sgon",Str)
					result = d3.execute_tcl(session("logentry"),"TA682",Cstr("PROSPECT" & chr(254) & searchsent & chr(254) & after & chr(254) & "N"))
					result = GetHoldFile(logentry,result,DocPath)
				end if
			end if
		else
			pararray(3) = ""
			pararray(4) = ""
			after = join(pararray,chr(254))
			result = d3.execute_tcl(session("logentry"),"TA682",Cstr("PROSPECT" & chr(254) & searchsent & chr(254) & after & chr(254) & "N"))
			result = GetHoldFile(logentry,result,DocPath)
		end if
	case "TA692"
		result = d3.execute_tcl(session("logentry"),"TA692",Cstr("PROSPECT" & chr(254) & searchsent & chr(254) & after & chr(254) & "N"),cint(1))
		result = GetHoldFile(logentry,result,DocPath)
	case "TA1422"
		result = d3.execute_tcl(session("logentry"),"TA1422",Cstr(Ystr),Cint("1"))
		result = GetHoldFile(logentry,result,DocPath)
	case "TA1465"
		pararray = split(after,chr(254))
		If pararray(0) = "" or picklin.check_month_ends(session("logentry"),Cstr(pararray(0))) = "1" Then
			result = d3.execute_tcl(session("logentry"),"TA1465",Cstr(after & chr(254) & "N" & chr(254) & Ystr),Cint("1"))
			result = GetHoldFile(logentry,result,DocPath)
		else
			result = "The Depreciation Date must be a Valid Month End Date or Blank for Today !"
		end if
	case "TA1466"
		pararray = split(after,chr(254))
		If picklin.check_month_ends(session("logentry"),Cstr(pararray(0))) = "1" Then
			result = d3.execute_tcl(session("logentry"),"TA1466",Cstr(after & chr(254) & Ystr),Cint("1"))
			result = GetHoldFile(logentry,result,DocPath)
		else
			result = "The Depreciation Date must be a Valid Month End Date !"
		end if
	case "TA1628"
		result = d3.execute_tcl(session("logentry"),"TA1628",Cstr(Ystr),cint("1"))
		result = GetHoldFile(logentry,result,DocPath)
	case "TA1629"
		Response.write("after = " & after)
		Response.end
	case "TA1648"
		result = d3.execute_tcl(session("logentry"),"TA1648",Cstr(after & Chr(254) & Nstr & Chr(254) & Ystr))
		result = GetHoldFile(logentry,result,DocPath)
	case "TA1651"
		tname = "ratesrecon"
		sentence = Replace(Request.Form("sentence"),"|",chr(34))
		fname = Cstr(sentence & Chr(254) & "1" & Chr(254) & after  & chr(254) & Server.MapPath("/prospect_site/excel"))
		sname = ""
		title = ""
		glitem = chr(8)
		placetogo = "/prospect/asp/bi.asp?fn=" & fname & "&tn=" & tname & "&item=" & sname & "&sn=" & title & "&who=reportingasp" & "&glitem=" & server.urlencode(glitem)
		Response.Redirect placetogo
		Response.end
	case "TA1654"
		result = d3.execute_tcl(session("logentry"),"TA1654",Cstr(ystr & chr(254) & "?" & chr(254) & after & chr(254) & "P"),cint("1"))
		result = GetHoldFile(logentry,result,DocPath)
	case "TA1658"
		result = d3.execute_tcl(session("logentry"),"TA1658",Cstr("R" & Chr(254) & Ystr),Cint("1"))
		result = GetHoldFile(logentry,result,DocPath)
	case "TA1665"
		Pararray = Split(after, chr(254))
		Workarray = Split(pararray(0), chr(253))
		Pararray(0) = ""
		For i = 0 to Ubound(Workarray)
			If i = 0 and Workarray(0) <> "" then
				Pararray(0) = Workarray(0)
			else
				If Workarray(i) <> "" then
					Pararray(0) = Pararray(0) & chr(253) & Workarray(i)
				End If
			End if
		Next
		after = Join(Pararray, chr(254)) & chr(254) & Server.MapPath("/prospect_site/excel")
		tname="rateslevied"
		fname = Cstr(after)
		sname = ""
		title = ""
		glitem = chr(8)
		placetogo = "/prospect/asp/bi.asp?fn=" & fname & "&tn=" & tname & "&item=" & sname & "&sn=" & title & "&who=reportingasp" & "&glitem=" & server.urlencode(glitem)
		Response.Redirect placetogo
		Response.end
	case "TA1680"
		pararray = split(after,chr(254))
		sentence = Replace(Request.Form("sentence"),"|",chr(34))
            Set tempobj = Server.CreateObject("cka_ta16.ta16")
   		result = tempobj.TA1682(session("logentry"),1,CInt(pararray(1)),Cstr(pararray(0)),Cstr(sentence),"")
            Set tempobj = Nothing
		If result = "" then result = "Model Processed - Use 1680A or 1680B to view Results"
		placetogo = "/prospect/asp/process_rates_model.asp?result=" & result
		Response.Redirect placetogo
		Response.end
	case "TA1680A","TA1680B"
		If cook_id = "TA1680A" then
			tname = "ratemodel"
		else
			tname = "compratemodel"
			after = after & chr(254) & Server.MapPath("/prospect_site/excel")
		end if
		fname = Cstr(after)
		sname = ""
		title = ""
		glitem = chr(8)
		placetogo = "/prospect/asp/bi.asp?fn=" & fname & "&tn=" & tname & "&item=" & sname & "&sn=" & title & "&who=reportingasp" & "&glitem=" & server.urlencode(glitem)
		Response.Redirect placetogo
		Response.end
	case "TA2031"
		result = d3.execute_tcl(session("logentry"),"TA2031",Cstr(Ystr & chr(254) & after),Cint("1"))
		result = GetHoldFile(logentry,result,DocPath)
	case "TA2836","TA2857","TA2867","TA2869","TA2889","TA2880"
		result = d3.execute_tcl(session("logentry"),cstr(cook_id),Cstr(after &  Ystr & Chr(254) & Chr(254)))
		result = "Report Spooled"
	case "TA2886"
		result = d3.execute_tcl(session("logentry"),cstr(cook_id),Cstr(after &  Ystr & Chr(254)))
		result = "Report Spooled"
	case "TA2859"
		result = d3.execute_tcl(session("logentry"),cstr(cook_id),Cstr(after &  Ystr & Chr(254) &  Ystr & Chr(254) &  Ystr & Chr(254)))
		result = "Report Spooled"
	case "TA2001"
		result = d3.execute_tcl(session("logentry"),cstr(cook_id),Cstr(Ystr & chr(254) & after),cint("1"))
		result = GetHoldFile(logentry,result,DocPath)
  end select

   page = "/prospect/reports/" & template & "/" & reportname & ".asp?sentence=" & sentence & "&reportname=" & reportname & "&template=" & template & "&result=" & server.urlencode(result)
    Response.Redirect page
'********************************************************************************************************************
Function GetHoldfile(logentry,result,DocPath)
	Dim HoldPos,HoldNo,Cmd,Reply
	HoldPos = Instr(result,"Hold Entry # ")
	HoldPos = HoldPos + 13
	HoldNo = ""
	Do While IsNumeric(Mid(result,HoldPos,1))
		HoldNo = Holdno & Mid(result,HoldPos,1)
		HoldPos = HoldPos + 1
	Loop
   	Cmd = "COPY PEQS " & holdno & " (O"
   	Reply = d3.execute_tcl(session("logentry"),Cstr(Cmd),"(PROSPOOL",Cint(0))
   	Reply = picklin.prosprt(session("logentry"),CStr(holdno))
	GetHoldFile = "<a href=" & DQ & reply & DQ & "target=" & DQ  & reply & DQ & "name=" & DQ & "Document File" & DQ & ">Document File: " & reply & "</a>"
End Function
'********************************************************************************************************************	 
%>
</BODY>
</HTML>
