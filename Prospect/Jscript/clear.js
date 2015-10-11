//'****************************
function ChangeTags(TagName,FilterChar,ReplaceText)
{
   TagType= document.all.tags(TagName);
   for (i=0; i<TagType.length; i++)
     {
	  TagId=TagType(i).id;
      if(FilterChar!="")
         {
		 if(TagId.indexOf(FilterChar)==0) TagType(i).innerText =ReplaceText;
         }
      else
         {
          TagType(i).innerText =ReplaceText;
         }
	 }
} 
//'***************************
function ShowTagText(TagName,FilterChar)
{
   TagType= document.all.tags(TagName);
   for (i=0; i<TagType.length; i++)
     {
	  TagId=TagType(i).id;
      if(FilterChar!="")
         {
          if(TagId.charAt(0)==FilterChar)alert(TagType(i).innerText);
         }
      else
         {
          alert(TagType(i).innerText);
         }
	 }
}
//'******************************
function ShowTagHtml(TagName,FilterChar)
{
   TagType= document.all.tags(TagName);
   for (i=0; i<TagType.length; i++)
     {
	  TagId=TagType(i).id;
      if(FilterChar!="")
         {
          if(TagId.charAt(0)==FilterChar)alert(TagType(i).innerHTML);
         }
      else
         {
          alert(TagType(i).innerHTML);
         }
	 }
}

