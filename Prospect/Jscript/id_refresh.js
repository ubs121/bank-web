Dim user_frm,group_frm,permit_frm,display_frm,show_group_list
'**************************************************************************************************
Sub Change_Groups(how)
   if show_group_list then group=group_frm.grp.value else group="" 
   user = user_frm.usr.value
   page = "/prospect/asp/write.asp?act=" & how & "&un=" & user & "&grpname=" &group  
   location.href=page
End Sub
'**************************************************************************************************
Sub LoadListItem(list_type)
   if list_type then show_group_list=1 else show_group_list=0

   Set user_frm = document.user_list
   if show_group_list then Set group_frm = document.group_list
   Set permit_frm = document.permissions
   Set display_frm = document.display_all

   user = permit_frm.perms_id.value
   allowed=permit_frm.perms.value

   perm_array = split(allowed,",")
   sz=display_frm.Elements.Length-1
   Dim ck()
   Redim ck(sz)

  FOR index=0 to ubound(perm_array) 
    for i = 0 to sz-5
      if display_frm.Elements(i).Name = perm_array(index) then 
         display_frm.Elements(i).checked=true
		 ck(i)="y"
	  exit for
	  end if
      next
  NEXT

  for i=0 to sz-5
     if ck(i)<>"y" then  display_frm.Elements(i).checked=false
  next
  display_frm.Update.value= "Update " & permit_frm.perms_id.value
  display_frm.userid.value= permit_frm.perms_id.value
End Sub
'**************************************************************************************************
Sub Add_OnClick
create_new_user=1
list_size=user_frm.usr.options.length
add_user = user_frm.NewUser.value

  if Len(Trim(add_user)) < 1 then
         alert("Enter a name")
  else
         for x=0 to list_size-1
		      if user_frm.usr.options(x).value=add_user then
              alert(user_frm.usr.options(x).value & " already exists")
			  create_new_user=0
			  exit for
              end if
	     next

		 if create_new_user then
		    permit_frm.perms_id.value=add_user
		 	if show_group_list then permit_frm.perms_type.value="user" else permit_frm.perms_type.value="group" 
			'alert("permit_frm.perms_type.value=" & permit_frm.perms_type.value)
			permit_frm.submit
		 end if
		 	
 end if
end Sub
'**************************************************************************************************
Sub Update_OnClick

        if show_group_list then display_frm.itemType.value="user" else display_frm.itemType.value="group" 
        'alert("display_frm.itemType.value= " & display_frm.itemType.value)
		display_frm.submit

End Sub
'**************************************************************************************************
Sub Delete_OnClick
 
 user = user_frm.usr.value

   if show_group_list then
      page = "/prospect/asp/write.asp?act=delete&un=" & user  
   else
      page = "/prospect/asp/write.asp?act=grp_delete&un=" & user  
   end if

location.href=page
end Sub
'**************************************************************************************************
Sub Load_OnClick

user = user_frm.usr.value
   if show_group_list then
      page = "/prospect/asp/write.asp?act=load&un=" & user  
   else
      page = "/prospect/asp/write.asp?act=grp_load&un=" & user  
   end if
location.href=page
End Sub
'**************************************************************************************************
Sub All_OnClick

sz=display_frm.Elements.Length-1

    for i = 0 to sz-5
         display_frm.Elements(i).checked=true
      next

End Sub
'**************************************************************************************************
Sub Clear_OnClick

sz=display_frm.Elements.Length-1

    for i = 0 to sz-5
         display_frm.Elements(i).checked=false
      next
End Sub
'**************************************************************************************************
Sub GoBack_OnClick
page = "/prospect/asp/menu.asp"  
location.href=page
End Sub
'**************************************************************************************************

