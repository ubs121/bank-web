Dim total_pages, total_items,current_page,all
'************************************************************************************
sub update(x)
 if x=1 then page_number.BPageNum.Value=page_number.TPageNum.Value
 if x=2 then page_number.TPageNum.Value=page_number.BPageNum.Value
end sub
'************************************************************************************
sub check
 numberKeyed=trim(page_number.TPageNum.Value) 
 ok=0
 if Isnumeric(numberKeyed) then
      numberKeyed=Clng(numberKeyed)
   if  numberKeyed > 0 AND numberKeyed <= total_pages then
      page_number.page.value=numberKeyed
      ok=1
   end if
 end if
 if OK =0 then  page_number.page.value=current_page
end sub
'************************************************************************************
sub preLoad_slider(both)
     total_pages=Clng(page_number.total_pages.value)
     total_items=Clng(page_number.total_items.value)
     current_page=Clng(page_number.page.value)
     page_size=page_number.page_size.value

	 if page_number.buttons.value="all" then all=1 else all=0

     if all then
	  page_number.TPageNum.value=current_page
	  page_number.TItems.value=total_items 
      page_number.TPages.value=total_pages
      page_number.BPageNum.value=current_page
	  page_number.BItems.value=total_items 
      page_number.BPages.value=total_pages
     else
   	  page_number.TPagesLb1.value=total_items 
   	  if total_items>17 then  page_number.BPagesLb1.value=total_items 
     end if
   	 
end sub
'************************************************************************************
sub TFirstPage_OnClick
page_number.TPageNum.Value="1"
page_number.BPageNum.Value="1"
page_number.page.value="1"
page_number.submit  
End sub
'************************************************************************************
sub TLastPage_OnClick
page_number.TPageNum.Value=total_pages
page_number.BPageNum.Value=total_pages
page_number.page.value=total_pages
page_number.submit  
end sub
'************************************************************************************
sub TPrevPage_OnClick
if current_page>1 then page_number.TPageNum.Value=current_page-1 else  page_number.TPageNum.Value = "1"
if current_page>1 then page_number.BPageNum.Value=current_page-1 else  page_number.TPageNum.Value = "1"
if current_page>1 then page_number.page.value=current_page-1 else  page_number.page.value = "1"
page_number.submit  
end sub
'************************************************************************************
sub TNextPage_OnClick
if current_page<total_pages then page_number.TPageNum.Value=current_page + 1
if current_page<total_pages then page_number.BPageNum.Value=current_page +1
if current_page<total_pages  then page_number.page.value=current_page +1 
page_number.submit  
end sub
'************************************************************************************
sub BFirstPage_OnClick
page_number.TPageNum.Value="1"
page_number.BPageNum.Value="1"
page_number.page.value="1"
page_number.submit  
end sub
'************************************************************************************
sub BLastPage_OnClick
page_number.TPageNum.Value=total_pages
page_number.BPageNum.Value=total_pages
page_number.page.value=total_pages
page_number.submit  
end sub
'************************************************************************************
sub BPrevPage_OnClick
if current_page>1 then page_number.TPageNum.Value=current_page-1 else  page_number.TPageNum.Value = "1"
if current_page>1 then page_number.BPageNum.Value=current_page-1 else  page_number.TPageNum.Value = "1"
if current_page>1 then page_number.page.value=current_page-1 else  page_number.page.value = "1"
page_number.submit  
end sub
'************************************************************************************
sub BNextPage_OnClick
if current_page<total_pages then page_number.TPageNum.Value=current_page + 1
if current_page<total_pages then page_number.BPageNum.Value=current_page+1
if current_page<total_pages  then page_number.page.value=current_page +1 
page_number.submit  
end sub
'************************************************************************************
sub TExcel_OnClick
page_number.page.value=current_page
page_number.want_excel.value="1"
page_number.submit  
End sub
'************************************************************************************
sub BExcel_OnClick
page_number.page.value=current_page
page_number.want_excel.value="1"
page_number.submit  
End sub
'************************************************************************************
sub TPrint_OnClick
page_number.page.value=current_page
page_number.want_excel.value="2"
page_number.submit  
End sub
'************************************************************************************
sub BPrint_OnClick
page_number.page.value=current_page
page_number.want_excel.value="2"
page_number.submit  
End sub

