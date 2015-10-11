
//*********************************************************************************************************
function BuildSearch(Div,Sentence,Relationship,Template)
 {
   while (RSAspProxyApplet.readyState != 4) {}
   ASPpage = RSGetASPObject("DllCalls.asp");
   co = ASPpage.BuildSearch(Sentence,Relationship,"15",Template);

   //alert(co.return_value);
   if(co.return_value=="") {alert("Nothing found\n" + Sentence);return 0;}
     else {Div.innerHTML=co.return_value;return 1;}
  }


//'************************************************************************************
function BuildNextPage(Div,Frm)
 {
   while (RSAspProxyApplet.readyState != 4) {}
   ASPpage = RSGetASPObject("DllCalls.asp");
   co = ASPpage.BuildNextPage(Frm.pickfile.value,Frm.sentence.value,Frm.template.value,Frm.page_num.value,Frm.page_size.value,Frm.title.value,Frm.hds.value,Frm.tds.value,Frm.dms.value,"RS");
   //alert(co.return_value);
   Div.innerHTML =co.return_value;
   table_navigation(Frm);
 }


//************************************************************************************************************
function BuildSentence(InputBox,SearchDiv,Template,Relationship)
 {
    var ok;
   document.all.CurrentSearchField.value=InputBox.name;
   //Sentence="?" + Relationship + "?" + InputBox.value;
   Sentence=InputBox.value;
   if (Sentence == "") return;
   ok=BuildSearch(SearchDiv,Sentence,Relationship,Template);
 if(ok)
	   {
		table_navigation(document.page_details);
            Test.style.visibility='hidden';
            SearchResults.style.visibility='visible';
	   }
  }
  
    
  //*********************************************************************************************************
  
function BuildString(key,file)
 {
   while (RSAspProxyApplet.readyState != 4) {}
if (key=="") {return ""}
   ASPpage = RSGetASPObject("DllCalls.asp");
   co = ASPpage.BuildString(key,file);
   return co.return_value;
 }
  
  
//*********************************************************************************************************
function GetData(AssessNum)
 {
  var OwnerAssess="";
  InputField=document.all.CurrentSearchField.value;
  if (InputField=="") 	{alert("Select Input box and type search word!"); return;}  
  document.assetform(InputField).value=AssessNum;
  ok=CheckTagExists(document.assetform,"I" + InputField.substring(0,16))
  if(ok){
         AddressField=document.all("I" + InputField.substring(0,16));
         GetAssessAddress(AddressField,AssessNum,0,0);
         }
  ok=CheckTagExists(document.assetform,"II" + InputField.substring(0,15))
  if(ok){
  		 AddressField=document.all("II" + InputField.substring(0,15)); 
         GetOwnerName(AddressField,AssessNum,0,0);
        }
  show(0);
  nextFocus(document.assetform,InputField);
  //document.assetform(InputField).select();
 }


//*********************************************************************************************************

function nextFocus(frm,fldname)
{
l=frm.elements.length;
for (i=0; i<l; i++)
{
	if (frm.elements(i).type == "text")
	{
	if (frm.elements(i).name == fldname)
	break;
	}
}
for (j=i+1; j<l; j++)
{
if (frm.elements(j).type == "text" || frm.elements(j).type == "textarea")
		break;
}
frm.elements(j).select();
}

//*********************************************************************************************************
function CheckSearchResults(SearchForm)
{
  var Exists,Item;
  Element="total_items"
  
  Exists=CheckFormExists(SearchForm.name);
  if(Exists)
    {
	 Exists=CheckItemExists(SearchForm,"hidden",Element)
     if(Exists){
	  table_navigation(SearchForm);return 1;
     }else return 0;
	}
  else return 0;
}


//*********************************************************************************************************
function CheckFormExists(name)
{
 for(var x=0;x<window.document.forms.length;x++)
     if(window.document.forms[x].name==name)return 1;
 return 0;
}


//*****************************************************************************
function CheckItemExists(ThisForm,ElementType,ElementName)
{
 for(var x=0;x<ThisForm.elements.length;x++)
    {
alert(ThisForm.elements[x].name + "=" + ElementName)
      //if(ThisForm.elements[x].type==ElementType)
	//    {
    	  if(ThisForm.elements[x].name==ElementName)return 1;
  	//	}
    }
 return 0;
}


//'************************************************************************************
function getRadioValue(RadioGroup)
 {
  var i = getSelectedButton(RadioGroup)
  return RadioGroup[i].value;
  }


//*********************************************************************************************************
function getSelectedButton(RadioGroup)
{
	for (var i = 0; i < RadioGroup.length; i++)if (RadioGroup[i].checked)return i;
	return 0;
}


//'***************************
function CheckTagExists(ThisForm,ElementName)
{
   TagType= document.all.tags("TD");
   for (i=0; i<TagType.length; i++)
     {
	  TagId=TagType(i).id;
      if (TagId==ElementName)return 1;
     }
 return 0;
}


//*******************************************************************************

function initArray(Temp)
{
var i;

TransRowArray = Temp.split(String.fromCharCode(8));
numofrows = TransRowArray.length;

TransColumnArray = TransRowArray[0].split(String.fromCharCode(9));
numofcols = TransColumnArray.length;
Temp="";

Temp=TransRowArray.join(String.fromCharCode(9));
Translist = Temp.split(String.fromCharCode(9));
}

//*******************************************************************************

function Ltrim(str)
{
while (!str=="" && str.charAt(0)==' ')
    str=str.substring(1,str.length);
	return str;
}

//'**********************




