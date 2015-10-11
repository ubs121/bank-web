<%

 '********************************************************************************************************
Sub Get_List(file)
  Dim lne,temp,user_list,textline,path,complete_line()
  lne = 0
  Redim complete_line(1)
 
      path="/prospect_site/Security/" & file 
      PhysicalPath=Server.MapPath(path)
      Set SessTextFile=SessionFileObject.OpenTextFile(PhysicalPath)  
     DO WHILE NOT SessTextFile.AtEndofstream
       textline=SessTextFile.ReadLine
	   if textline<>"" then
       complete_line(lne)=textline
       lne = lne + 1
	   Redim Preserve complete_line(lne)
	   end if
	LOOP
      SessTextFile.Close

user_list= ubound(complete_line)-1
if user_list < 10 then box_size = user_list + 1 else box_size = 10
if user_list>0 then
  
  for c=0 to user_list
    for r = 0 to user_list-1
        if complete_line(r) > complete_line(r+1) then
           temp = complete_line(r)
           complete_line(r)=complete_line(r+1)
           complete_line(r+1)=temp
        end if
     next
  next
end if

lne = 0
for c=0 to user_list 
    line=split(complete_line(c),";")
    ids(lne)=line(0)
    permissions(lne)=line(1)
    lne = lne + 1
    Redim Preserve permissions(lne)
    Redim Preserve ids(lne)
next
   
Set SessTextFile=SessionFileObject.OpenTextFile(PhysicalPath,2,TRUE)
           FOR r=0 to user_list
				SessTextFile.WriteLine(complete_line(r))
			NEXT
SessTextFile.Close
selected_flag=0
selected =""
End Sub
'********************************************************************************************************
Sub Select_ID(thislist)
  Dim  selected_flag,user_list
  Dim selected
  user_list= ubound(ids)-1
  selected_flag=0
  
      for index=0 to user_list
          selected=""    
          if index=0  AND received_id="" OR index=0  AND thislist="group" then selected="selected"
		  if ids(index)=received_id then
		          selected="selected"
	              selected_flag=index
	       end if

      response.write("<OPTION VALUE=" & ids(index) & " " & selected & ">" & ids(index))
     next

 If thislist="user" then	
     if received_permissions="" then 
        received_permissions=permissions(selected_flag)
        received_id=ids(selected_flag)
     end if
 end if
 
end Sub
%>