var total_pages=1, total_items=0,current_page=1,all="",toggle=0,toponly=0;
//'************************************************************************************
function update(ThisForm,x,newvalue)
 {
  if(x==1){if(toponly==0)ThisForm.BPageNum.value=newvalue;}
  if(x==2)ThisForm.TPageNum.value=newvalue;
 }
//'************************************************************************************
function isvalidpage(character)
 {
   digits= new Array('0','1','2','3','4','5','6','7','8','9');
   for(var x=0;x<digits.length;x++)if(character==digits[x])return true;
   return false;
 }
//*********************************************************************************************************
function check_pagenumber(page,len)
 {
  pagedigits= new String(page);

   for(var y=1;y<len;y++)
      {
       ok=isvalidpage(pagedigits.charAt(y));
       if(!ok)return -1;
      }
  return pagedigits;
 }
//*********************************************************************************************************
function check(ThisForm,button)
 {
  if(button=="TSubmit")
    {
      numberKeyed=ThisForm.TPageNum.value; 
      len=ThisForm.TPageNum.value.length;
    }
  else
   {
     numberKeyed=ThisForm.BPageNum.value;
     len=ThisForm.BPageNum.value.length;
   }
  if(len==0){ThisForm.page_num.value=current_page;return;} 
  ok = check_pagenumber(numberKeyed,len);
  if(ok!=-1)
     {
       if(numberKeyed*1 > 0 && numberKeyed*1 <= total_pages)
         {
          ThisForm.page_num.value=numberKeyed;
  	      BuildNextPage(document.all.SearchResults,ThisForm);
		  show(1);
         }
       else
         {
            ThisForm.TPageNum.value=current_page;
            if(toponly==0)ThisForm.BPageNum.value=current_page;
         }
     }   
  else
      {
        ThisForm.page_num.value=current_page;
        ThisForm.TPageNum.value=current_page;
        if(toponly==0)ThisForm.BPageNum.value=current_page;
        }
 }
//'************************************************************************************
function table_navigation(ThisForm)
    {
	 var navtype;
     total_pages=ThisForm.total_pages.value;
     total_items=ThisForm.total_items.value;
     current_page=ThisForm.page_num.value;
     page_size=ThisForm.page_size.value;
   	 navtype=ThisForm.buttons.value;
if(navtype=="all")
       {
        toponly=0;
	    ThisForm.TPageNum.value=current_page;
	    ThisForm.TItems.value=total_items; 
        ThisForm.TPages.value=total_pages;
		
        ThisForm.BPageNum.value=current_page;
	    ThisForm.BItems.value=total_items; 
        ThisForm.BPages.value=total_pages;
       }
else
       {
	    toponly=0;
	    ThisForm.TPagesLb1.value=total_items; 
   	   //ThisForm.BPagesLb1.value=total_items; 
   	   }
 }
//'************************************************************************************
function FirstPage(ThisForm)
 {
  if(current_page*1>1)setpagevalues(ThisForm,1);
 }
//'************************************************************************************
function LastPage(ThisForm)
{
 if(current_page*1< total_pages*1)setpagevalues(ThisForm,total_pages);
}
//'************************************************************************************
function PrevPage(ThisForm)
 {
  if(current_page*1>1){current_page--;setpagevalues(ThisForm,current_page);}
 }
//'************************************************************************************
function NextPage(ThisForm)
  {
    if(current_page*1< total_pages*1){current_page++;setpagevalues(ThisForm,current_page);}
   }
//'************************************************************************************
function getpage(ThisForm)
{
  BuildNextPage(document.all.SearchResults,ThisForm);
  show(1);
}
//'************************************************************************************
 function setpagevalues(ThisForm,page)
   {
       ThisForm.TPageNum.value=page; 
       if(toponly==0)ThisForm.BPageNum.value=page;
       ThisForm.page_num.value=page;
       getpage(ThisForm);
   }
//'************************************************************************************
function toggle_sql_sentence(Frm,Div)
 {
  if(toggle==0){Div.innerHTML=Frm.sentence.value;toggle=1;Div.style.visibility="visible";return;}
  if(toggle==1){toggle=0;Div.style.visibility="hidden";return;}
 }
 //'************************************************************************************

