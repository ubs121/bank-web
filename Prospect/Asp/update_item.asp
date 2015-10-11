<% response.expires = 0 
   response.buffer=true
%>
<HTML>
<HEAD>
</HEAD>

<BODY>

<%
    before=   Request.Form("before")
    after=    Request.Form("after")
    action=   Request.Form("action")
    file=     Request.Form("file")
    item=     Request.Form("item")
    template= Request.Form("template")
    search= Request.form("search")
    transfile= Request.Form("trfile")
    transrec_before= Request.Form("before_trans")
    transrec_after= Request.Form("after_trans")
no_update_delete= Request.Form("no_update_delete")
mainfile= Request.Form("mainfile")
printdoc= Request.Form("printdoc")
docname= Request.Form("docname")
mergefile= Request.Form("merge")
defaulting=Request.Form("defaulting")
	
'before = image of record when first read - will use to check no changes made in meantime - maybe
'after =  image of record after changes made and action = add or delete
'action ="add", "delete", "autoID", "update"

If InStr(filetouse, ".mdb\") Then how = 1 Else how = 0  'how=0 on pick, how=1 on msaccess

'Response.write(session("logentry") & "," & "file = " & file & "<BR>transfile = " & transfile & "<BR>item = " & item & "<BR> after = " & after & "<BR>before = " & before & "<BR>doing = " & doing & "<BR>transrecbefore = " & transrec_before & "<BR>transrecafter = " & transrec_after)
'response.end
     	  	

trec = chr(8)
rec = picklin.readstr(Cstr(session("database")),cstr(file),cstr(item),,,,chr(8))
'transfile must have the .mdb prefixed in future - not needed now
'if transfile <> "" then trec = picklin.readstr(Cstr(session("database")),cstr(transfile),cstr(item),,,,chr(8))

    result=""
    If rec <> chr(8) then 'and trec <> chr(8) Then
	 If action = "add" Then
    	    result = Chr(8) & "item" & item & "exists"
       else 'only check to len(rec) as see gigen_l_grp - may add dummy attributes for multiple dropdowns
          'response.write("before = " & before & "<BR> rec = " & rec)
          'response.end
'          if rec <> left(before,len(rec)) and trec <> left(transrec_before,len(trec)) then result = Chr(8) & "Someone else has just updated " & item & ".  Try again." & rec & "=" & before
          if rec <> left(before,len(rec)) then result = Chr(8) & "Someone else has just updated " & item & ".  Try again." & rec & "=" & before
       end if 
    Else
       If action <> "add" Then
          result = Chr(8) & "Someone just deleted " & item & ".  Try again"
       end if 
    end if
 
    if result="" then
       select case action
          case "delete": doing="D": after=before
          case "add":    doing="A"
          case else: doing="W"
       end select

       select case template
          case "iloans"
             after=replace(after,chr(8),chr(254))
             before=replace(before,chr(8),chr(254))
             Set cka_loans=Server.CreateObject("cka_loans.loans")
             result = cka_loans.ta_loans_update(Cstr(session("logentry")),cstr(file), cstr(item),cstr(after),cstr(before),cstr(doing))
             Set cka_loans=Nothing
          case "iloansdebtor"
             after=replace(after,chr(8),chr(254))
             before=replace(before,chr(8),chr(254))
             Set cka_loans=Server.CreateObject("cka_loans.loans")
             result = cka_loans.ta_loans_debtor(Cstr(session("logentry")),cstr(file), cstr(item),cstr(after),cstr(before),cstr(doing))
             Set cka_loans=Nothing
          case "iinvest_borrower"
             Set cka_loans=Server.CreateObject("cka_invest.invest")
             result = cka_loans.borrower_update(Cstr(session("logentry")),cstr(file), cstr(item),cstr(after),cstr(before),cstr(doing))
             Set cka_loans=Nothing
          case "ijournal"
'response.write(after & chr(13) & chr(10))
'response.write(transrec_after)
'response.end
             Set cka_loans=Server.CreateObject("cka_gl.gl")
             result = cka_loans.journal(Cstr(session("logentry")),cstr(file), cstr(item),cstr(after),cstr(before),cstr(transrec_before),cstr(transrec_after),cstr(doing))
		 	 Set cka_loans=Nothing
          case "imaint"
		  	 'Response.write(session("logentry") & "<BR>file = " & file & "<BR>transfile = " & transfile & "<BR>item = " & item & "<BR> after = " & after & "<BR>before = " & before & "<BR>doing = " & doing & "<BR>transrecbefore = " & transrec_before & "<BR>transrecafter = " & transrec_after)
             'response.end
             Set cka_loans=Server.CreateObject("cka_ta31.ta31")
             result = cka_loans.debtors_maint_invoice(Cstr(session("logentry")),cstr(file), item,cstr(after),cstr(before),cstr(transrec_before),cstr(transrec_after),cstr(doing))
			 Set cka_loans=Nothing
          case "istock_issue"
             Set cka_loans=Server.CreateObject("cka_stock.stock")
Response.write(session("logentry") & "<BR>file = " & file & "<BR>transfile = " & transfile & "<BR>item = " & item & "<BR> after = " & after & "<BR>before = " & before & "<BR>doing = " & doing & "<BR>transrecbefore = " & transrec_before & "<BR>transrecafter = " & transrec_after)
Response.end
             result = cka_loans.issue(Cstr(session("logentry")),cstr(file),cstr(transfile),item,cstr(before),cstr(after),cstr(transrec_before),cstr(transrec_after),cstr(doing))
		 Set cka_loans=Nothing
          case "igen_l_levmnt"
             Set cka_loans=Server.CreateObject("cka_gl.gl")
             result = cka_loans.gl_lev_mnt(Cstr(session("logentry")),cstr(file), cstr(item),cstr(after),cstr(before),cstr(doing))
             Set cka_loans=Nothing
	    case "ipurchase"
     	  	 Set cka_loans=Server.CreateObject("cka_gl.gl")
             result = cka_loans.purchase_entry(Cstr(session("logentry")),cstr(file), cstr(item),cstr(before),cstr(after),cstr(transrec_before),cstr(transrec_after),cstr(doing))
             Set cka_loans=Nothing			 
		case "iinvoice","icredit"
	  		'Response.write(session("logentry") & "," & "file = " & file & "<BR>transfile = " & transfile & "<BR>item = " & item & "<BR> after = " & after & "<BR>before = " & before & "<BR>doing = " & doing & "<BR>transrecbefore = " & transrec_before & "<BR>transrecafter = " & transrec_after)
			'response.end
     	  	 Set cka_loans=Server.CreateObject("cka_ta31.ta31")
             result = cka_loans.debtors_invoice(Cstr(session("logentry")),cstr(file),cstr(transfile),item,cstr(before),cstr(after),cstr(transrec_before),cstr(transrec_after),cstr(doing))
             Set cka_loans=Nothing			 
    	case else
             if action="delete" then
                result = d3.d3_delete(Cstr(session("database")),cstr(file), cstr(item))
             else
                'wrec=split(item & chr(8) & after,chr(8))
                'result = d3.d3_writemat(Cstr(session("database")),cstr(file), wrec)
                result = d3.d3_writestr(Cstr(session("database")),cstr(file), cstr(item),cstr(after),chr(8))
		    if transfile<> "" and how=0 Then
                   wterr=d3.d3_writestr(Cstr(session("database")),cstr(transfile), cstr(item),cstr(transrec),chr(8))
		       result = result & wterr
	          end if
		 end if	 
         end select
         If result <> "0" and result <> "00" Then 
            result = chr(8) & action & " of " & file & " item " & item & " failed - " & result
         else
            result = "0" & Chr(253) & item
         end if
     end if
 
  error_type=LEFT(result,1)
  if error_type<>chr(8) then
     info_array=SPLIT(result,chr(253))
     if ubound(info_array) < 2 then redim preserve info_array(2)
     write_status=info_array(0)
     item=info_array(1)
     dll_message=info_array(2)
     if write_status = "0" then dll_message="noerrors"
  else
     dll_message=result
  end if

  page = "/prospect/asp/binput.asp?fn=" & file & "&fn1=" & transfile & "&tn=" & template & "&item=" & item & "&baditem=empty&blank=no" & "&err=" & dll_message & "&found=yes&search=" & search & "&no_update_delete=" & no_update_delete & "&printdoc=" & printdoc & "&merge=" & mergefile  & "&docname=" & docname & "&mainfile=" & mainfile  & "&defaulting=" & defaulting
  Response.Redirect page 
%>
</BODY>
</HTML>
