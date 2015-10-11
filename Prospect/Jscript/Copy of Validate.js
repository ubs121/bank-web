Dim iassetForm, dataForm 
'******************************************************************************************
Sub LoadDropDowns()

   on error resume next
 Dim msgform
      
    Set  msgform=document.item_status
    Set iassetForm=document.assetform
    Set dataForm=document.assetdata
    newitem=msgform.item.value
   iassetform.Add.Disabled=true
   iassetform.Update.Disabled=true
   iassetform.Delete.Disabled=true
   
'noupdate=iassetform.no_update_delete.value
'if noupdate="2" then
'	iassetform.Add.Disabled=False
'end if				

End Sub 
'*************************************************************************
Sub ReportButtons

 Dim msgform
    Set  msgform=document.item_status
    Set iassetForm=document.assetform
    Set dataForm=document.assetdata

    newitem=msgform.item.value
End Sub 

'*************************************************************************
Sub Clear_Click

 Dim cnt
 size=document.assetform.Elements.Length-1
 for cnt = 0 to size
    if document.assetform.Elements(cnt).type <> "" AND document.assetform.Elements(cnt).type <> "button" then document.assetform.Elements(cnt).value=""
 next
 call LoadDropDowns
 call ChangeTags("I","asses","")
 call ChangeTags("I","t","")
 call ChangeTags("I","I","")
 call ChangeTags("TD","I","")
End Sub
'*************************************************************************
Sub Query_Click(mainfile)

   Dim new_item,new_page,fname,tname,prefix

   new_item=trim(iassetForm.id.value)
   if new_item="" then exit sub
   fname=trim(dataForm.file.value)
   trans_fname = ""
   on error resume next
   trans_fname=trim(dataForm.trfile.value)
   on error goto 0
   tname=trim(dataForm.template.value)
   prefix=trim(dataForm.prefix.value)
   on error resume next
   search=trim(dataForm.search.value)
   on error goto 0
   new_page = "/prospect/asp/binput.asp?fn=" & fname &  "&fn1=" & trans_fname & "&tn=" & tname & "&mainfile=" & mainfile & "&item=" & prefix & new_item  & "&baditem=empty&blank=no&err=noerrors&found=yes&search=" & search & "&no_update_delete=" & no_update_delete   
   location.href=new_page
   
 End Sub
'*************************************************************************
Function Report_Click()
   Set iassetForm=document.assetform
   Set dataForm=document.assetdata
   error = save_form_Data(0)
   if error = "1" then exit function
   on error resume next
   dataForm.validated.value = "1"
   on error goto 0
   dataForm.Submit   
End Function
'*************************************************************************
Function Excel_Click()
   Set iassetForm=document.assetform
   Set dataForm=document.assetdata
   error = save_form_Data(0)
   if error = "1" then exit function
   on error resume next
   dataForm.validated.value = "2"
   on error goto 0
   dataForm.Submit   
End Function
'*************************************************************************
Sub Delete_Click

  delete_item=trim(iassetForm.id.value)
  original_item=trim(dataForm.item.value)
  prefix=trim(dataForm.prefix.value)

  if original_item<>delete_item then 
     msgbox "ID is not currently loaded",vbInformation,"Unmatched ID"
  else 
     dataForm.action.value="delete"
     dataForm.item.value=prefix & delete_item
     dataForm.Submit
  end if

  End Sub
'*************************************************************************
Sub Update_Click

  update_item=trim(iassetForm.id.value)
  original_item=trim(dataForm.item.value)
  prefix=trim(dataForm.prefix.value)

  if original_item <> update_item then
     msgbox "ID is not currently loaded",vbInformation,"Unmatched ID"
     iassetForm.id.value=original_item
  else
     error = save_form_Data(1)
 	 
'	exit sub	
     if error = "1" then exit sub

 '********** if journal entry, atleast one narrative is required and total credit should be equal to total debit************

	template=dataForm.template.value
    if template="ijournal" then
		if not TotalsEqual() then msgbox "Total Credit and Debit mismatch" : exit sub
		if not NarrativeEntered() then 	msgbox "Atleast one narrative required" : exit sub
	end if
	
'*********************************************************************

   if dataForm.before.value<>dataForm.after.value or dataForm.changed.value="1" then
        dataForm.action.value="update"
        dataForm.item.value=prefix & update_item
	    on error resume next
        dataForm.validated.value = "1"
        on error goto 0
        dataForm.Submit
     else
        msgbox "No Changes Made to " & update_item,vbInformation,"Update"
     end if
   end if
   
End Sub 
'******************************************************************************************
Sub Add_Click
  original_item=trim(dataForm.item.value)
  add_item=trim(iassetForm.id.value)
  prefix=trim(dataForm.prefix.value)

  if original_item <> add_item then 
     msgbox "ID is not currently loaded",vbInformation,"Unmatched ID"
  else
    error = save_form_Data(1)
	if error = "1" then exit sub
'exit sub
'********** if 	journal entry, atleast one narrative is required and total credit should be equal to total debit************

	template=dataForm.template.value
    if template="ijournal" then
		if not TotalsEqual() then msgbox "Total Credit and Debit mismatch" : exit sub
		if not NarrativeEntered() then 	msgbox "Atleast one narrative required" : exit sub
	end if
	
'*********************************************************************

	dataForm.action.value="add"
    dataForm.item.value=prefix & add_item
    on error resume next
    dataForm.validated.value = "1"
    on error goto 0
    dataForm.Submit
  end if
End Sub 

'*************************************************************************
function TotalsEqual()
	totalcredit=iassetForm.Btotalcr.value
  	totaldebit=iassetForm.Btotaldr.value
	if totalcredit<>totaldebit then
		TotalsEqual=false
		exit function
	end if
	TotalsEqual=true
End Function

'************************************************************************

function NarrativeEntered()
dim i
items=split(dataForm.after_trans.value,chr(8))

		firstAccount=items(0)
		if firstAccount <> "" then
			firstNarrative=items(4)
			if firstNarrative="" then
				NarrativeEntered=false
				exit function
			else
				prevNarrative=firstNarrative
				for i=5 to ubound(items) step 5
					if items(i) <> "" then
						if items(i+4) = "" then items(i+4) = prevNarrative 	else prevNarrative=items(i+4)
					end if				
				next	
			end if
		end if
	dataForm.after_trans.value=join(items,chr(8))			
NarrativeEntered=true
End Function

'************************************************************************

Sub ShowError

Dim input_err,reason
input_err = trim(document.Error.errMessage.value)
  
if input_err <>"noerrors" then
   if LEFT(input_err,1) = chr(8) then
      input_err=REPLACE(input_err,chr(8),"") 
      msgbox input_err, vbexclamation, "Item Already Exists!" 
   else
      input_err=REPLACE(input_err,chr(8)," ")
      input_err=REPLACE(input_err,chr(254),vbcrlf)
      msgbox input_err, vbexclamation, "Data Invalid!"
   end if
end if
End Sub

'*************************************************************************

Sub ReportResult

Dim input_err,reason
input_err = trim(document.Error.errMessage.value)
  
if input_err <>"noerrors" then
   input_err=REPLACE(input_err,chr(8)," ")
   input_err=REPLACE(input_err,chr(254),vbcrlf)
   msgbox input_err, vbexclamation, "Report Result"
end if
  
End Sub

'******************************************************************************************

Sub pop_up

  on error resume next

  Set  msgform=document.item_status
  newitem=msgform.item.value
  baditem=msgform.baditem.value
  prev_good=1
  testing=iassetform.no_update_delete.value
  if newitem <> chr(8) and testing <> "9" then
    if newitem="no" then
       if trim(iassetForm.id.value)= "" then 
         iassetform.Add.Disabled=True
       else
         iassetform.Add.Disabled=False
       end if
       iassetform.Update.Disabled=true
       iassetform.Delete.Disabled=True
    else
       iassetform.Add.Disabled=True
       if testing<>"1" then
          iassetform.Update.Disabled=False
          iassetform.Delete.Disabled=False
       end if
    end if
  else
    if baditem<>"empty" then prev_good=0 
  end if

if testing="2" then
	iassetform.Add.Disabled=False
end if				

end sub

'************************************************************************************

Function save_form_Data(starti)

Dim i,size,before(),n,Temp
Temp=""
dim transrec()
redim transrec(0)

 save_form_Data = "0"
 size=iassetform.Elements.Length-1
 mainrec=split(dataForm.before.value,chr(8))
 n=ubound(mainrec)
 if starti=0 then redim before(ubound(mainrec))
 
'conversion = trim(iassetForm.Elements(9).name)
'datum = trim(iassetForm.Elements(9).value)
'msgbox conversion & "," & datum
 
 ' for i = 27 to 30
 'msgbox iassetForm.Elements(i).name
 'next
 'exit function 
  for i = starti to size
    RadioChecked=False
    if iassetForm.Elements(i).type="radio" then
	   If left(iassetForm.Elements(i).name,4)<>"hide" then 
          If iassetForm.Elements(i).checked Then RadioChecked =True
	   end if
    end if
    if (left(iassetForm.Elements(i).type,4)="text" or left(iassetForm.Elements(i).type,4)="file" or left(iassetForm.Elements(i).type,6)="select"  or left(iassetForm.Elements(i).type,8)="checkbox"  or RadioChecked or left(iassetForm.Elements(i).name,6)="select") and left(iassetForm.Elements(i).name,4)<>"hide" and left(iassetForm.Elements(i).name,4)<>"id"  or (left(iassetForm.Elements(i).type,6)="hidden" and Isnumeric(left(iassetForm.Elements(i).name,1))) then
       conversion = trim(iassetForm.Elements(i).name)
	   temp2=split(conversion,",")
	   if ubound(temp2) < 7 then redim preserve temp2(7)
       if left(temp2(0),6)="select" then temp2(0)=mid(temp2(0),7)
       temp2(0) = replace(temp2(0),"sel","") 'option select lists have sel in front of attribute
       if left(temp2(0),1)="I" then addn = 1: temp2(0)=mid(temp2(0),2)
       if left(temp2(0),1)="C" then compulsory=1: temp2(0)=mid(temp2(0),2) else compulsory=0
	 if addn = 1 then temp2(0) = temp2(0) + 1 : addn = 0
       attr = temp2(0) - 1 ' since split array starts at 0
       tp = temp2(1)
       If IsNumeric(tp) Then vm = CInt(tp) Else vm = 0
       tp = temp2(2)
       If IsNumeric(tp) Then svm = CInt(tp) Else svm = 0
       fieldname = temp2(3)
       conversion = temp2(5)
       fdate=temp2(6)
       tdate=temp2(7)
	   datum = trim(iassetForm.Elements(i).value)

'add facility for multiple selection boxes - see TA3131 in prospect\reports - mco 27jan01
       if iassetForm.Elements(i).type="select-multiple" then
          datum=""
          lth = assetForm.Elements(i).length - 1
          for j=0 to lth
             if assetForm.Elements(i).options(j).selected then
                if datum <> "" then datum = datum & chr(253)
                mv = trim(iassetForm.Elements(i).options(j).value)
                pos=instr(mv,"(")
                if pos<>0 then mv=mid(mv,pos+1)
                pos=instr(mv,")")
                if pos<>0 then mv=left(mv,pos-1)
                datum = datum & mv
             end if
          next
       end if
'Return Value for check Boxes that are actually checked - dg 13Feb01
       if iassetForm.Elements(i).type="checkbox" then
          If iassetForm.Elements(i).checked Then
       		datum = trim(iassetForm.Elements(i).value)
		  else
		    datum = ""
	      end if
	   end if
       internal_datum = datum
	  
'	   msgbox "intd" & internal_datum
       how = "0": tfile = "": v7 = "": v36 = "": max_length = "0"
       If datum = "" Then
          if compulsory=1 then
             msgbox fieldname & vbcr & vblf & "Compulsory input",vbCritical
             save_form_Data="1"
             exit function
          end if
          internal_datum = ""
          errmsg=""
       Else
          If InStr(datum, vbTab) <> 0 Then 'when is converted to code file have desc vbtab ( code ) 'mc 04aug99 till next one
             datum = Mid(datum, InStr(datum, vbTab) + 2)
             datum = Left(datum, Len(datum) - 1)
          End If
'old server validation - errmsg = picklin.conv_validate(cstr(how), cstr(conversion), cstr(datum), cstr(tfile), cstr(v7), cstr(v36), cstr(max_length))
          select case conversion
             case "MD2","MD4","MD0","MD2X"
                if isnumeric(datum) then
                   if right(conversion,1) = "X" then
                      internal_datum=datum
                   else
                      internal_datum=datum*10^(cint(right(conversion,1)))
                   end if
                else
                   msgbox fieldname & vbcr & vblf & "Invalid numeric data",vbCritical
                   save_form_Data = "1"
                   exit function
                end if
                if fdate<>"" then
                   if left(fdate,1)="<" then 'must not be greater than amount in attr given
                      if mid(fdate,2,1)="A" then
                         datt=mid(fdate,3)
                         if ubound(mainrec)>=cint(datt-1) then amt=mainrec(datt-1) else amt=""
                      else
                         amt=mid(fdate,2)
                      end if
                      if ccur(internal_datum)>ccur(amt) then
                         msgbox fieldname & vbcr & vblf & "Amount must be less than or equal to " & formatnumber(amt/100,2),vbCritical
                         save_form_Data="1"
                         exit function
                      end if
                   end if
                   if left(fdate,1)=">" then
                      amt=mid(fdate,2)
                      if ccur(internal_datum) < ccur(amt) then
                         msgbox fieldname & vbcr & vblf & "Amount must be greater than or equal to " & formatnumber(amt,2),vbCritical
                         save_form_Data="1"
                         exit function
                      end if
                   end if
                end if
             case "D2", "D2X"
                if isdate(datum) then
			 internal_datum = DateDiff("d", "31/12/67", datum)
			 if fdate<>"" then
                      if left(fdate,1)="A" then
                         datt=mid(fdate,2)
                         if ubound(mainrec)>=cint(datt-1) then 'check date entered is before date in other attr (An)
                            if datediff("d",datum,mainrec(datt-1)) < 0 then
                               msgbox fieldname & vbcr & vblf &  datum & " must be before " & mainrec(datt-1),vbCritical
                               save_form_Data="1"
                               exit function
                            end if
                         end if
                      else
                         if datediff("d",fdate,datum) < 0 then
                            msgbox fieldname & vbcr & vblf & datum & " must be equal to or after " & fdate,vbCritical
                            save_form_Data="1"
                            exit function
                         end if
                      end if
                   end if
                   if tdate<>"" then
                      if datediff("d",datum,tdate) < 0 then
                         msgbox fieldname & vbcr & vblf & datum & " must be equal to or before " & tdate,vbCritical
                         save_form_Data="1"
                         exit function
                      end if
                   end if
                   if conversion = "D2X" then 
                      internal_datum=datum
                   else
                      internal_datum = DateDiff("d", "31/12/67", datum)
                   end if
               else
                   msgbox fieldname & vbcr & vblf & "Invalid date",vbCritical
                   save_form_Data="1"
                   exit function
                end if
             case "YN"
                if datum<>"Y" and datum<>"N" and datum<>"y" and datum<>"n" then
                   msgbox fieldname & vbcr & vblf & "Must be Y or N",vbCritical
                   save_form_Data="1"
                   exit function
                end if
             case else
					   
                if left(conversion,1)="@" then
                   if instr(conversion & "@","@" & datum & "@") = 0 then
                      msgbox fieldname & vbcr & vblf & "Must be one of " & replace(conversion,"@"," "),vbCritical
                      save_form_Data="1"
                      exit function
                   end if
                else
                   internal_datum = datum
                end if
          end select
       End If
	
       If cint(attr) >= 999 Then 
            If cint(attr-999) > UBound(transrec) Then ReDim Preserve transrec(attr-999)
			transrec(attr-999) = cstr(internal_datum) 'Temp=Temp & chr(8) & cstr(internal_datum)
       else
		    If cint(attr) > UBound(mainrec) Then 
    	      ReDim Preserve mainrec(attr)
        	  mainrec(attr) = ""
	          if starti=0 then redim preserve before(attr)
		end if  
		  if vm=0 and svm=0 then
    	      mainrec(attr) = cstr(internal_datum) 'all non D3 databases will have vm=0 and svm=0
	      else
    	      mainrec(attr) = pick_replace(cstr(mainrec(attr)), cint(1), cint(vm), cint(svm), cstr(internal_datum))
	      end if
	  end if	
	   if starti=0 then before(attr)=datum
    end if
 next

dataForm.after.value=join(mainrec,chr(8))
on error resume next
dataForm.after_trans.value=join(transrec,chr(8))
on error goto 0 

if starti=0 then dataForm.before.value=join(before,chr(8))

'msgbox "after" & dataForm.after.value
'msgbox "trec" & dataForm.after_trans.value

'if dataForm.before.value<>dataForm.after.value then
'	call changeVal()
'end if	

End function


'**************************************************
function pick_replace(sdummy, attr, value , svm , srepl )
'
' Description:  This function replaces data in a given string
'               (implementation of PICK replace function)
'
dim G_DELIM(3)
dim sbit(3)
dim ebit(3)
Dim s1, I , eos, soe
Dim g_delimiters(3)
  g_delimiters(1) = Chr(8)
  g_delimiters(2) = Chr(253)
  g_delimiters(3) = Chr(252)

    s1 = sdummy
    G_DELIM(1) = attr: G_DELIM(2) = value: G_DELIM(3) = svm
    
    For I = 1 To 3
       eos = 0: soe = Len(s1) + 1
       If G_DELIM(I) <> 0 Then
          If G_DELIM(I) <> 1 Then
             do
                eos = Index(s1, g_delimiters(I), G_DELIM(I) - 1)
                If eos <> 0 Then exit do
                s1 = s1 & g_delimiters(I)
             loop
          Else
             eos = 0
          End If
          soe = InStr(eos + 1, s1, g_delimiters(I), 0)
          If soe = 0 Then soe = Len(s1) + 1
       end if 
       If eos = 0 Then 
          sbit(I) = ""
       Else
          sbit(I) = Mid(s1, 1, eos)
       end if
       ebit(I) = Mid(s1, soe)
       s1 = Mid(s1, eos + 1, soe - 1 - eos)
    Next
    pick_replace = sbit(1) & sbit(2) & sbit(3) & srepl & ebit(3) & ebit(2) & ebit(1)

End function


'********************************
Function Index(SWORD, sWord1, nC)
'  This function searches through a given string
' for the occurence of the string specified by sWord1
'
'               Returns: 0 if not found
'                        position number if found
Dim npos

    Do
        npos = InStr(npos + 1, SWORD, sWord1, 0) 'mc binary 17/4/96 all uses were not alphabetic
        nC = nC - 1
    Loop Until ((nC = 0) Or (npos = 0))
    Index = npos

End Function
'*************************************************************

Function Rtrim(SWORD, sChar)
Dim lastChar

Rtrim=""
if SWORD="" then exit function

    Do
        lastChar = Mid(SWORD, Len(SWORD), 1)
        If lastChar = sChar Then
            SWORD = Mid(SWORD, 1, Len(SWORD) - 1)
        End If
    Loop Until ((lastChar <> sChar) or (Len(SWORD)=0))
	
    Rtrim=SWORD
End Function


'****************************************************************


Function ConvertToVBString(Str)
dim i,j

ColumnArray = split(Str,chr(8))
numofcols = ubound(ColumnArray) + 1

RowArray = split(ColumnArray(0),chr(253))
numofrows = ubound(RowArray) + 1

VbStr=""
 for i=1 to numofrows 
	for j= 1 to numofcols 
		Vbstr=Vbstr & chr(8) & Rtrim(pick_extract(str,j,i,0),chr(252))
	next
next
		ConvertToVBString=Vbstr
End Function

'****************************************************************


Function pick_extract(PickString, attr, value, svm) 

 Dim Attributes, Values, SubValues

 pick_extract = ""
on error resume next

 Attributes = Split(PickString, Chr(8), attr + 1, 0)
 pick_extract = Attributes(attr - 1)
 If value > 0 Then
    Values = Split(pick_extract, Chr(253), value + 1, 0)
    pick_extract = Values(value - 1)
    If svm > 0 Then
       SubValues = Split(pick_extract, Chr(252), svm + 1, 0)
       pick_extract = SubValues(svm - 1)
    End If
 End If

End Function

'****************************************************************

'Function FormatStringtoNumber(Str)
'if Str="" then
'	FormatStringtoNumber=""
'else
'	FormatStringtoNumber=Format(Str,"#.00") 
'end if	
'End Function


'****************************************************************


Sub changeVal()

if dataForm.changed.value="0" then
	dataForm.changed.value="1"
end if	

End Sub


'****************************************************************


Function RightJustify(str,size)
str = trim(str)
do while len(str) < size
	str=" " & str
loop	
RightJustify = str

End Function


'****************************************************************

Function fieldFormat(field)
dim temp
fieldFormat = ""
on error resume next	
	temp = split(field.name,",")
	fieldFormat = temp(5)

End Function

'*******************************************************************

Sub Account_Validation(itag,field,template)
dim ok,pos1,pos2,pos

if field.value <> "" then
	document.all.CurrentSearchField.value=field.name
else
	exit sub
end if

result=""
acct_no=field.value
barredaccounts=BuildString("barred","Tpoauthorise;3,0")
barredjobs=BuildString("barred","Tpoauthorise;4,0")
 
pos1=InStr(1,acct_no,".",0)
if pos1 <> 0 then                         ' Search in job.l  and gen.l
	grp = mid(acct_no,1,pos1-1)
    pos2=instr(pos1+1,acct_no,".",0)
    	if pos2 <> 0 then
	        cls = mid(acct_no,pos1+1,pos2 - (pos1+1))
			subcls = mid(acct_no,pos2+1,len(acct_no) - pos2)
			if IsNumeric(grp) then
				acctype = "gl"
				validation = "Tgen.l;2" 
			else
				acctype = "job"
				validation = "Tjob.l;2" 
				pos = instr(ucase(acct_no),"JOB") 
				if pos <> -1 then
			  		acct_no=mid(acct_no,4)
					grp = mid(grp,4)
				end if
			end if	
		end if
else   										' Search in Stock file
	acctype = "stock"
	validation = "Tstock;1"
end if

select case template
case "ipurchase"
	if acctype = "gl" or acctype = "job" then
			ok = authoriseAccount(grp,cls,subcls,acctype,"") 		
			if ok=0 then
				exit sub
			else
				ok = authoriseAccount(grp,cls,subcls,"barred",barredaccounts) 
			    if ok=0 then
					msgbox "This account is barred"
					exit sub
				end if
			end if
	end if
end select

result = BuildString(acct_no,validation)
if result="" then  itag.value="" else itag.value=result

End Sub
