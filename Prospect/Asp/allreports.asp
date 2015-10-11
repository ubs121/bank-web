<% 
response.expires = 0 
%>
<HTML>
<HEAD>
<%
StyleToUse=Session("userStyle")
response.write(StyleToUse)
PathToUse=Session("imagePath")
result = Request.Querystring("result")
%>
<TITLE>Prospect Reports</TITLE>
<SCRIPT LANGUAGE="JavaScript">
//*************************************************************************
function GetReportPage(DropDown)
{
 var reportpath,reportname,regexp;

    listlength=DropDown.length;
    for(cnt=0;cnt<listlength;cnt++)
        {
         if(DropDown.options[cnt].selected==true)
            {
              reportpath=DropDown.options[cnt].value;
            }

        }
  reportname=reportpath.split("/")
  regexp=/.asp/g;  
  shortname=reportname[1].replace(regexp,"")
  ReportPage="/prospect/reports/" + reportpath + "?reportname=" + shortname + "&template=" + reportname[0];
  location.href=ReportPage;
}
//*************************************************************************
</SCRIPT>
</HEAD>
<BODY>
<%
parameters=Request.cookies("TA2401")("parms")
parms=split(parameters,chr(254))
redim preserve parms(10)
FullPath=Server.MapPath("/prospect/reports/") & "\"
items = PickLin.make_options(session("logentry"),"DIR",Cstr(FullPath))
%>
<H1 align="CENTER">Prospect Reports</H1>
<TABLE WIDTH="60%" border="1" cellspacing="3" cellpadding="1" align="center">
<TR CLASS="top">
<TH colspan=2>
<TR>
<TD CLASS="mm">
<B>Reports</B>
 <select name="ReportsBox">
   <%=items%>
 </select>
<TR>
<TD CLASS="mm" align="CENTER">
<INPUT TYPE="button" CLASS=smallButt VALUE="Report" OnClick='GetReportPage(document.all.ReportsBox)'>
</TABLE>

<FORM name=path ><INPUT TYPE=hidden NAME=pn VALUE="<%= PathToUse %>"></FORM>
</BODY>
</HTML>

