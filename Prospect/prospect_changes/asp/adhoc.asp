<%
  OPTION EXPLICIT
  response.buffer=true
  response.expires = 0 
 
  Dim PickItem,Attribs,NumAttribs,NumIds,cnt,Sentence(),adhoctitle,Titles(),Temp,ItemIds,AllItems,Result,AdhocIds
  Dim StyleToUse,PathToUse,templatetouse,CurrentItem,newreport,hds,dictitems,filetouse,doswop,sentword
  Dim filename

  StyleToUse=Session("userStyle")
  response.write(StyleToUse)
  PathToUse=Session("imagePath")

 result= Request.Querystring("result")
 templatetouse= Request.Querystring("templatetouse")
 AdhocIds=Request.Querystring("AdhocIds")
 adhoctitle=Request.Querystring("title")
 newreport=Request.Querystring("sentence")
 filetouse=Request.Querystring("fn")
 if session("d3needed")="no" then
    sentword="queries"
    newreport="select * from " & filetouse
    filename="c:!ckashare!gen_l!gen_l.mdb!queries"
 else 
    sentword="sentences"
    newreport=replace(newreport,"sselect","sort") 'fix up newreport as best we can
    newreport=newreport & " ID-SUPP LPTR"
    filename="sentences"
 end if

 if AdhocIds<>"" then 
    ItemIds = Split(AdhocIds,",")
    CurrentItem=PickLin.readstr(session("database"),"sentences", Cstr(ItemIds(0)))
    CurrentItem= Replace(CurrentItem, "'", "’")
    CurrentItem= Replace(CurrentItem, """", "”")

    NumIds=Ubound(ItemIds)
    Redim AllItems(NumIds) 
    For cnt=0 to NumIds
      AllItems(cnt)=PickLin.readstr(session("database"),"sentences", Cstr(ItemIds(cnt)))
    Next 
    PickItem=Join(AllItems,chr(254))
    Attribs=Split(PickItem,chr(254))
    NumAttribs=Ubound(Attribs)
    ReDim Sentence(NumAttribs)
    ReDim Titles(NumAttribs)
 
    For cnt=0 to NumAttribs
      Temp=Split(Attribs(cnt),chr(253))
      Sentence(cnt)= Replace(Cstr(Temp(0)), "'", "’")
      Sentence(cnt)= Replace(Cstr(Sentence(cnt)), """", "”")
      redim preserve temp(1)
      Titles(cnt)=Temp(1)
      If Titles(cnt)="" then Titles(cnt)=left(sentence(cnt),100)
    Next
else
    ReDim ItemIds(0)
    ItemIds(0)=""
end if
'doswop = ";SwopQuotes(document.assetdata.sentence)"
If AdhocIds <> "@RECALL.1651" Then doswop = ";SwopQuotes(document.assetdata.sentence)" else doswop = ""
%>
<SCRIPT LANGUAGE="JavaScript1.2">
//************************************************************************************************************
function DeleteSentence(Item,filename,DropDown,Sentence,CurrentItem)
{
 var DeletedPos,ctr=0;
 var AmendedSentences= new Array(0);
 Sentences=CurrentItem.value.split("þ")

 listlength=DropDown.options.length
 for(cnt=0;cnt<listlength;cnt++)
       {
        if(DropDown.options[cnt].selected==false)
           {
             AmendedSentences[ctr]=Sentences[cnt];
             ctr++;
          }
       }
   Rec= AmendedSentences.join("þ");
   ok=WriteStr(filename,Item,Rec)
   if(ok==0)
    {
     CurrentItem.value=Rec;
     RefreshDropdown(DropDown,CurrentItem.value,"Delete");
     alert("Sentence Deleted\n");
    }
  else alert("Errors: " + ok);

}
//************************************************************************************************************
function AddSentence(Item,filename,DropDown,Title,Sentence,CurrentItem)
{
  NewAttrib=Sentence.value + "ý" + Title.value 
  if(CurrentItem.value==""){Rec=NewAttrib;}
  else Rec=CurrentItem.value + "þ" + NewAttrib;
  ok=WriteStr(filename,Item,Rec)
  if(ok==0)
    {
     CurrentItem.value=Rec;
     RefreshDropdown(DropDown,CurrentItem.value,"Add");
     Sentence.value="";
     Title.value="";
     alert("Sentence Added\n");
   }
  else alert("Errors: " + ok);
}
//************************************************************************************************************
function RefreshDropdown(DropDown,CurrentItem,ModifyType)
{
      mylist=CurrentItem.split("þ");
      listlength=mylist.length;
      DropDown.options.length=listlength;
      for(cnt=0;cnt<listlength;cnt++)
       {
         attrib=mylist[cnt].split("ý");
         if(attrib.length==1)title=attrib[0] + (cnt + 1)
         else
            {
              if(attrib[1]=="")title=attrib[0] + (cnt + 1) 
              else title=attrib[1];
            }
         DropDown.options[cnt]=new Option(title,attrib[0]);
       }
       if(ModifyType=="Add")
         {
           DropDown.options[listlength-1].selected=true;
           document.assetdata.sentence.value=DropDown.options[listlength-1].value;
         }
       if(ModifyType=="Delete")
         {
           DropDown.options[0].selected=true;
           document.assetdata.sentence.value=DropDown.options[0].value;
         }

}
//************************************************************************************************************
function WriteStr(File,Item,Rec)
 {
   while (RSAspProxyApplet.readyState != 4) {}
   ASPpage = RSGetASPObject("/prospect/asp/DllCalls.asp");
   co = ASPpage.WriteStr(File,Item,Rec);
   return co.return_value;
  }
//'************************************************************************************
function SwopCarriageReturns(Sentence)
{
   var regexp,AccessSentence;

   AccessSentence=Sentence.value
   regexp=/\r/g;  
   AccessSentence=AccessSentence.replace(regexp,"");
   regexp=/\n/g;
   AccessSentence=AccessSentence.replace(regexp,"");
   //above removes IE5 vbcrlf's which cause remote scripting to fail for TextArea object (chr(10) & chr(13))

   Sentence.value=AccessSentence
}
//'************************************************************************************
function SwopQuotesBack(Sentence)
{
   var regexp,AccessSentence;

   AccessSentence=Sentence.value
   regexp=/'/g;  
   AccessSentence=AccessSentence.replace(regexp,"’");
   regexp=/\"/g;
   AccessSentence=AccessSentence.replace(regexp,"”");
   Sentence.value=AccessSentence
}
//'************************************************************************************
function SwopQuotes(Sentence)
{
   var regexp,AccessSentence;

   AccessSentence=Sentence.value
   regexp=/’/g;  
   AccessSentence=AccessSentence.replace(regexp,"'");
   regexp=/”/g;
   AccessSentence=AccessSentence.replace(regexp,"\"");
   Sentence.value=AccessSentence
}
//'************************************************************************************
function checkViewButton(selectbox,button)
 {
  //if(selectbox=="")button.disabled=true;
  //else button.disabled=false; 
 }
//************************************************************************************************************
function showAccess(Sentence,Access)
 {
  Access.value=Sentence;
 }
//************************************************************************************************************
function WhatNext(Form,Param)
{
var loginpage,regexp,AccessSentence;  
        switch(Param)
           {
            case "@RECALL.1651":
                loginpage="/prospect/asp/ratesrecon.asp"
                Form.action=loginpage
  	            break;
            case "@1685":
                loginpage="/prospect/asp/Process_Rates_Model.asp"
                Form.action=loginpage
  	            break;
	         default:
           }

}

</SCRIPT>
<HTML>
<HEAD>
<TITLE>Adhoc Reporting</TITLE>
<SCRIPT LANGUAGE="JavaScript" SRC="/prospect/jscript/rs.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">RSEnableRemoteScripting("/prospect/java");</SCRIPT>
</HEAD>

<BODY onLoad='document.assetdata.sentence.value=document.assetdata.TitlesBox.options[0].value'>
<H1 align=center>Adhoc Reports</H1>

<FORM ACTION="/prospect/asp/adhoc_tcl.asp?AdhocIds=<%=AdhocIds%>" METHOD="POST" NAME="assetdata">
<%
'get dict items for this file
dictitems = picklin.get_dropdown(session("logentry"), "SSELECT dict " & cstr(filetouse) & " with a1 = ""A""","")

%>
<TABLE WIDTH="80%" ALIGN=CENTER BORDER="1" CELLSPACING="1" CELLPADDING="1">
   <TR class=top>
   <TD WIDTH=4% align=center class=browngrad>
       <a href="/prospect/asp/menu.asp"><IMG src="/prospect/images/default/explorer/start_up.gif" BORDER="0" WIDTH="29" HEIGHT="19"></a>
   <TD><B>Use drop-down to see <%=sentword%> that already exist for <%=adhoctitle%>: <%=adhocids%></B>
   <TR>
      <TD class=top>Title
      <TD class=top>
 <SELECT  CLASS=smallSel NAME="TitlesBox" Onchange='checkViewButton(this.value,document.assetdata.Run);showAccess(this.value,document.assetdata.sentence)'>

   <%if AdhocIds <>"" then %>
     <%for cnt=0 to NumAttribs%>
         <OPTION VALUE='<%=Sentence(cnt)%>'><%=Titles(cnt)%>
      <%next%>
   <%else%>
         <OPTION VALUE="">
   <%end if%>
  </SELECT>
  <TR>
      <TD class=top>Sentence
      <TD CLASS="mm"><TEXTAREA  CLASS="smallTxtArea" NAME="sentence" COLS="80" ROWS="6"></TEXTAREA>
  <TR>
     
     <TD COLSPAN=2 ALIGN=CENTER CLASS="mm"><INPUT TYPE="Submit" NAME="Run" CLASS=smallButt VALUE="Run Report" OnClick='WhatNext(document.assetdata,"<%=AdhocIds%>",document.assetdata.sentence)<%=doswop%>'>
         <INPUT TYPE="button" NAME="Delete" CLASS=smallButt VALUE="Delete Sentence" OnClick='DeleteSentence("<%=ItemIds(0)%>","<%=filename%>",document.assetdata.TitlesBox,document.assetdata.sentence,document.assetdata.currentitem)'>
</TABLE>
<P>
<P>
<P>
<TABLE WIDTH="80%" ALIGN=CENTER BORDER="1" CELLSPACING="1" CELLPADDING="1">  
<TR class=top>
      <TD colspan=2 ALIGN=CENTER><B><%=adhoctitle%>: Create New Sentence</B>
<TR>
     <TD class=top>Add Title
     <TD CLASS="mm"><INPUT size=80 class=smallTxt TYPE="Text" NAME="Title" value="<%=newreport%>">
<TR>
      <TD class=top>Add New Sentence
      <TD CLASS="mm"><TEXTAREA CLASS="smallTxtArea" NAME="newsentence" COLS="80" ROWS="6"><%=newreport%></TEXTAREA>
<TR>
   <TD class=top>Existing field names
   <TD CLASS="mm"><select name="DICTS" multiple size=5>
<%
response.write(dictitems)
%>
</select>

<TR>
     <TD colspan=2 class=top align=center>
          <INPUT TYPE="Button" NAME="Add" CLASS=smallButt VALUE="Add Sentence" onClick='SwopCarriageReturns(document.assetdata.newsentence);SwopQuotesBack(document.assetdata.newsentence);AddSentence("<%=ItemIds(0)%>","<%=filename%>",document.assetdata.TitlesBox,document.assetdata.Title,document.assetdata.newsentence,document.assetdata.currentitem)'>

</TABLE>
<input type="hidden" name="reportname" value="adhoc adhoc.asp">
<input type="hidden" name="templatetouse" value="<%=templatetouse%>">
<input type="hidden" name="currentitem" value="<%=currentitem%>">
<input type="hidden" name="adhoctitle" value="<%=adhoctitle%>">

</FORM>
<%If result<>"" then
 Dim DQ
 DQ = chr(34)
 Response.write("<CENTER><a href=" & DQ & result & DQ & "target=" & DQ & result & DQ & "name=" & DQ & "Document File" & DQ & ">Document File: " & "<FONT color=""Crimson""><B>" & result & "</B></FONT>" & "</a>")
end if%>
</BODY>
</HTML>
