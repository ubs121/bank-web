<% 
response.expires = 0 
response.addHeader "pragma", "no-cache"
response.cachecontrol = "public"
response.buffer=true
%>
<HTML>
<HEAD>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
validated = Request.Querystring("validated")
sentence = Request.Querystring("sentence")
sentence=replace(sentence,"""",chr(8))
%>
<SCRIPT LANGUAGE="VBSCRIPT" SRC="/prospect/jscript/validate.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript1.2" SRC="/prospect/jscript/clear.js"></SCRIPT>
</HEAD>

<BODY>

<FORM NAME="assetdata">
<input type="hidden" name="before" value="">
<input type="hidden" name="after" value="">
<input type="hidden" name="validated" value="">
<input type="hidden" name="sentence" value="<%=sentence%>">
<input type="hidden" name="reportname" value="<%=Request.Querystring("reportname")%>">
<input type="hidden" name="template" value="<%=Request.Querystring("template")%>">
</FORM>

<FORM ACTION="<%=request.servervariables("path_info")%>" METHOD="POST" NAME="assetform">

<%
parameters=Request.cookies("TA291")("parms")
parms=split(parameters,chr(8))
redim preserve parms(10)
items = PickLin.make_options(session("logentry"),"BANKS", "")
%>

<a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>

<TABLE border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2><%=Request.Querystring("reportname")%>

<TR>
<TD CLASS="mm"><B>Bank Account</B>
<TD><select name="1,0,0,Bank Account">
<%
response.write(items)
%>

<TR>
<TD CLASS="mm"><B>Tape Reference</B>
<TD><input type="Text" name="2,0,0,Tape Reference" value="<%=parms(1)%>" align="LEFT">

<TR>
<TD CLASS="mm"><B>Your mail address (sender)</B>
<TD><input type="Text" name="C3,0,0,Your mail address (sender)" value="<%=parms(2)%>" align="LEFT">

</TABLE>

<TABLE align="center">
<!--#include virtual= "/prospect/asp/inc_report_buttons.asp"-->
</TABLE>
<%
if validated = "1" then
   after = Request.Querystring("after") 'these are setup in validate.js in routine REPORT_CLICK calling save_form_data
   before = Request.Querystring("before")   
   cook_id="TA291"
   response.cookies(cook_id)("parms") = before
   response.cookies(cook_id).expires = date + 365

   result= PickLin.eft_mail(Server.MapPath("\prospect\template\"),session("logentry"), cstr(after),Server.MapPath("/prospect_site/paidit"))
   lines=split(result,chr(8))
   response.write("<table align=center>")
   for j=0 to ubound(lines)
      response.write("<TR><TD><B><FONT color=""Crimson"">" & lines(j) & "</FONT></B>")
   next
   response.write("</table")


   'response.write("<TR><TD colspan=2 align=center><FONT color=""Crimson""><B>" & result & "</B></FONT>")
   validated = ""
end if
%>

<P>
<P>If NO Tape Reference is input,
	all items on the file CHQ.REM.ADVICEnn (where nn is the bank number selected)
        are emailed
<P>If a Tape Reference is input
	the file CHQ.RECnn is read for items with this tape reference 
	suffixed with .mmm where mmm is a count starting from 1

<P>The program will try to email in this order

<P>a) email address from client file is used
   the remittance advice will sent as an HTML attachment
<P>IF MISSING OR AN ERROR RESULTS
<P>b) error message is given to user
   and item is mailed to an address of "creditor-nnn'
   this will result in the mail item being listed in the standard mail system as
   'undeliverable' but will allow the user to do a re-send to a correct address
   
<P>
<P>NOTE: Just because this program thinks the email or has been sent
IT DOES NOT MEAN it necessarily has been sent

<P>Sample problems could be
<P>	- email address could look okay but in fact be wrong

<P>The standard mail system MUST be used to check that all items sent
did in fact get sent.

<P>As the items are sent, they are also written to the sub-directory
drive:\prospect_site\paidit\
<P>The items should be deleted periodically from this sub-directory using Explorer
<P>They can be used at any time for enquiry or manual re-transmission while retained here

</FORM>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
<FORM name=login ><INPUT TYPE=hidden NAME=status VALUE="<%= status%>"></FORM>

</BODY>
</HTML>

