var search=0;

//'****************************************************************

function authoriseAccount(grp,cls,subcls,acctype,barredaccs)
{
var i=0,findex,lindex;
if (acctype == "gl")
	auth_accounts = document.all.po_auth_accounts.value;
else if (acctype == "job")	
	auth_accounts = document.all.po_auth_jobaccounts.value;
else
	auth_accounts = barredaccs ;

auth_officer = document.all.po_authofficer.value ;	
if (auth_accounts == ""){if (!acctype == "barred"){ alert("No authorisation record for this officer"); return 0; } else return 1;}

AccountsArr = auth_accounts.split(String.fromCharCode(253));
numofAccs = AccountsArr.length;
found=0;

while (found == 0 && i < numofAccs)
{
auth_grp = AccountsArr[i];
if (auth_grp.indexOf(".") != -1)	  
	{
		if (auth_grp.substring(0,2) == "..") {if (subcls == auth_grp.substring(2,auth_grp.length)) found = 1;}
		else if (auth_grp.substring(0,1) == ".") {if (cls == auth_grp.substring(1,auth_grp.length)) found = 1; }
		else
		{		
			findex = auth_grp.indexOf(".",0);
			lindex = auth_grp.indexOf(".",findex);
			if (lindex != -1) {Accountnum = grp + "." + cls + "." + subcls; if (Accountnum == auth_grp) found = 1;}
			else { grp_class = grp + "." + cls ; if (grp_class == auth_grp) found = 1; }
		}
	}
else if ((auth_grp == "P")  && (grp.substring(0,1) == "P"))	{ found = 1; }
else if (auth_grp.indexOf("-") != -1)
	{ firstnum = auth_grp.substring(0,auth_grp.indexOf("-")) ;
	  lastnum = auth_grp.substring(auth_grp.indexOf("-")+1,auth_grp.length);
	  if (grp >= firstnum && grp <= lastnum) found = 1;
	}
else if ((auth_grp * 1) > 0)
	{
		if (grp == auth_grp) found = 1;
	}
else if ((auth_grp.substring(1,auth_grp.length) * 1 > 0) && acctype == "jobs") {	if (grp == auth_grp) found = 1; }
else {Accountnum = grp + "." + cls + "." + subcls; if ((Accountnum == auth_grp) && (acctype == "jobs")) found = 1;}			 
i = i + 1;
}
if (found){ if (acctype == "barred") return 0; }
else {if (acctype != "barred") {alert("Invalid account for this Officer"); return 0;}}
return 1;
}


function SearchAccount(template)
{

fieldname = document.all.CurrentSearchField.value;
if (fieldname == "") return;
field = document.all(fieldname);

BuildSentence(field,document.all.SearchResults,template,"");	

if (template == "RSJob.txt" && field.value != "")
	field.value="JOB"+field.value ;
}


/*********************************************************************************************/
function gl_validation(itag,inputhidden,field,acct_no,validation,searchitem)
{
if (field.value!="")
{
  document.all.CurrentSearchField.value=field.name;
 }
else
 return;  

while (RSAspProxyApplet.readyState != 4) {}
  result="";
  if (acct_no=="") {return}
  pos=acct_no.indexOf(".",0);
  if (pos!=-1)
     {
      pos2=acct_no.indexOf(".",pos+1)
      if (pos2!=-1)
        {
		ASPpage = RSGetASPObject("DllCalls.asp");
        co = ASPpage.BuildString(acct_no,validation);
        result=co.return_value;
        }
      }
		
  if (result=="")
     {itag.innerHTML="";
      if (acct_no!="")
	  {
        BuildSentence(field,document.all.SearchResults,searchitem,"");
	  }
//	  inputhidden.value=String.fromCharCode(8);
	}
  else
     {
     itag.innerHTML=result;
     }
	  inputhidden.value=itag.innerHTML;
}

//'**********************

function addamts(itag,inputhidden,pval,field,amt)
 {
   var total;
   amt=FormatNum(amt,2);
   field.value=amt;	
   
   if (amt == "")	 amt=0;
   if (parseFloat(amt)!=amt)
    {if (amt!="") {alert("Must be numeric");}}
   else
    {
   if (parseFloat(amt) < 0) {alert("amount must be greater than 0");field.focus();return;}
	 if (inputhidden.value=="") inputhidden.value=0;
     total = inputhidden.value;
	 total = parseFloat(total) - parseFloat(pval) + parseFloat(amt);
     inputhidden.value = total;
     itag.innerHTML=FormatNum(inputhidden.value,2);
    }
}
















