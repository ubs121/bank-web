<%
 response.cachecontrol = "public"
 StyleToUse=Session("userStyle")
 response.write(StyleToUse)
 PathToUse=Session("imagePath")

 Set SessionFileObject=Server.CreateObject("Scripting.FileSystemObject")
 Set userDict=Server.CreateObject("Scripting.Dictionary")

 item_to_add=Request.form("perms_id")
 item_type=Request.form("perms_type")
 itemType=Request.form("itemType")

 action=Request.QueryString("act")
 user=Request.QueryString("un")
 group=Request.QueryString("grpname")

 g_permissions=""
 fgroup = "group.asp"
 if Session("ex_template") <> "ex_template.asp" then fgroup = "group_" & Session("ex_template")

 fuser = "user.asp"
 if Session("ex_template") <> "ex_template.asp" then fuser = "user_" & Session("ex_template")
 
 if itemType="group" or item_type="group" or action="grp_delete" OR action="grp_load" then  
    grp_flag=1
    fname = fgroup
    asp_path="/prospect/asp/group_admin.asp"
 else
    grp_flag = 0
    fname = fuser
    asp_path="/prospect/asp/user_admin.asp"
 end if 
 Create_Dictionary fname,userDict


 select case action 
  case "delgrp":     Groups "delete",fgroup,fuser
  case "addgrp":     Groups "add",fgroup,fuser
  case "delete":     Delete_Item(fname)
  case "grp_delete": Delete_Item(fname)
  case "grp_load":   Load_Item
  case "load":       Load_Item
  case else :        WhichForm(fname)
end select
'***********************************************************************    	  
Sub WhichForm(itype)
  select case item_to_add
    case "":   Update_Item(itype)
    case else: Add_Item(itype)
end select
End Sub
'***********************************************************************    	  
Sub Load_Item
g_permissions=userDict.item(user)
End Sub
'***********************************************************************    	  
Sub Delete_Item(i_type)
 userDict.remove(user)
 write_back i_type,userDict
 user=""
End Sub
'***********************************************************************    	  
Sub Add_Item(i_type)
 access_rights=Request.form("perms")
  if userDict.Exists(item_to_add) then
      userDict.remove(item_to_add)
  else
      userDict.add item_to_add,access_rights
      g_permissions=access_rights
      user= item_to_add
      write_back i_type,userDict
  end if
End Sub
'***********************************************************************    	  
Sub Update_Item(i_type)    
    id=Request.form("userid")
    FOR EACH name IN Request.Form
        textline=textline & name & ","
    NEXT
    textline=REPLACE(textline,"userid,","")
    textline=REPLACE(textline,"itemType,","")
    textline=REPLACE(textline,"perms_type,","")
    if len(textline)>0 then textline=LEFT(textline,len(textline)-1)
    userDict.item(id)=textline
    user= id
    write_back i_type,userDict
End Sub
'***********************************************************************    	  
Sub Create_Dictionary(file,dictionary)
  path="/prospect_site/security/" & file 
  PhysicalPath=Server.MapPath(path)
  Set SessTextFile=SessionFileObject.OpenTextFile(PhysicalPath)

   DO WHILE NOT SessTextFile.AtEndofstream
       line=SessTextFile.ReadLine
       if line<>"" then  
	      id_prefs=split(line,";")
          if NOT dictionary.exists(id_prefs(0)) then dictionary.add id_prefs(0), id_prefs(1)
	   end if
	     	  
   LOOP
      SessTextFile.Close
End Sub
'*************************************************************************
Sub write_back(file,dictionary)

      path="/prospect_site/security/" & file 
      PhysicalPath=Server.MapPath(path)
      Set SessTextFile=SessionFileObject.OpenTextFile(PhysicalPath,2,TRUE)
      narray=dictionary.Keys()
      parray=dictionary.Items()
       
            FOR ctr=0 to dictionary.count-1
			    SessTextFile.WriteLine(narray(ctr) & ";" & parray(ctr))
			NEXT
      SessTextFile.Close
  
End Sub	   
'***********************************************************************    	  
Sub Groups(method,fgroup,fuser)
 Set groupDict=Server.CreateObject("Scripting.Dictionary")
 Create_Dictionary fgroup,groupDict
 uprefs=userDict(user)
 gprefs=groupDict(group)
 gprefs_array=split(gprefs,",")
 uprefs_array=split(uprefs,",")

 for x=0 to ubound(gprefs_array)
      not_found=1 
	  for xx=o to ubound(uprefs_array)
	      if gprefs_array(x)= uprefs_array(xx) then
		     uprefs_array(xx)= uprefs_array(xx) & chr(253) 
             not_found=0
			 exit for
	      end if
	  next
	  if not_found then gprefs_array(x)= gprefs_array(x) & chr(253)    
	  next	 

   groups_to_Keep=FILTER(uprefs_array,chr(253),false)
   groups_in_User=FILTER(uprefs_array,chr(253))
   groups_to_Add=FILTER(gprefs_array,chr(253))
   grp_matches=ubound(groups_in_User)
   grp_additions=ubound(groups_to_Add)
   user_Keeps=ubound(groups_to_Keep)

   if user_Keeps  <> -1 then keeps   =JOIN(groups_to_Keep):kps_comma="," else keeps  ="":kps_comma =""
   if grp_matches <> -1 then matches =JOIN(groups_in_User): else matches=""
   if grp_additions <> -1 then additions=JOIN(groups_to_Add):grp_comma="," else additions="":grp_comma= ""
   if user_Keeps= -1 AND grp_matches= -1 then grp_comma=""

   if method="add" then
        New_user_prefs=keeps & kps_comma & matches & grp_comma & additions   
        New_User_prefs=REPLACE(New_User_prefs,chr(253),"")
   end if
  
   if method="delete" then New_user_prefs=keeps

   New_user_prefs=REPLACE(New_user_prefs," ",",")      
   userDict.item(user)=New_user_prefs
   write_back fuser,userDict

End Sub
'***********************************************************************    	  
%>
<HTML>
<HEAD>
<SCRIPT LANGUAGE="VBSCRIPT">
Sub send_user_details
Set aform = document.permissions
aform.submit 
end sub
</SCRIPT>

</HEAD>
<BODY onLoad="send_user_details()">
<FORM name=permissions ACTION="<%=asp_path%>" METHOD="POST">
<INPUT TYPE=hidden NAME=perm VALUE="<%=g_permissions%>">
<INPUT TYPE=hidden NAME=perm_id VALUE="<%=user%>">
</FORM>
</BODY>
</HTML>
