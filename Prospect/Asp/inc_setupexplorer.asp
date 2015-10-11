<%
Sub SetupExplorer

      images = "/prospect/images/default/explorer/"

      TitleWidth= 151      
      DivWidth = TitleWidth + 39 'allow for folder image + right.gif
      ChildOffset=190

      Prospect_explorer = "<DIV CLASS=""mmenu""ID=""startLayer"" STYLE=""position: absolute; left: 0px; top: 0px; WIDTH: " & DivWidth & "px; z-index: 52; visibility: hidden;""><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0><TR><TD COLSPAN=3><IMG SRC=""" & images & "top.gif"" WIDTH=""" & DivWidth &  """ BORDER=""0"" HEIGHT=""2""><TR><TD WIDTH=""30""><IMG NAME=""start_1"" SRC=""" & images & "start_up.gif"" BORDER=""0"" WIDTH=""30"" HEIGHT=""22""><TD WIDTH=""" & (TitleWidth + 1) & """ HEIGHT=""22""><FONT CLASS=menu>&nbsp; &nbsp; Prospect Explorer</FONT><TD WIDTH=""9"" HEIGHT=""22""><IMG SRC=""" & images & "right.gif"" BORDER=""0"" WIDTH=""9"" HEIGHT=""22""><TR><TD COLSPAN=3><IMG SRC=""" & images & "bottom.gif"" BORDER=""0"" WIDTH=""" & DivWidth &  """ HEIGHT=""2""></TABLE></DIV>"
      Prospect_explorer = Prospect_explorer & "<DIV CLASS=""mmenu""ID=""parentLayer""STYLE=""position: absolute; left: 0px; top: 0px; WIDTH: " & DivWidth & "px; z-index: 53; visibility: hidden;""><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0><TR><TD COLSPAN=3><IMG SRC=""" & images & "top.gif"" WIDTH=""" & DivWidth &  """ BORDER=""0"" HEIGHT=""2"">"
      Set SessionFileObject=Server.CreateObject("Scripting.FileSystemObject")
      ex_where=Request.ServerVariables("URL") 'get /prospect/asp/xxxxx.asp
      pos=instr(ex_where,".")
      for ee=pos to 1 step -1 'want to replace xxx with ex_template
         if mid(ex_where,ee,1) = "/" then exit for
      next
      ex_where=left(ex_where,ee) & Session("ex_template")     
      PhysicalPath=Server.MapPath(ex_where)
      if NOT SessionFileObject.FileExists(PhysicalPath) then
        page = "/prospect/asp/login.asp" 
        Response.Redirect page 
       end if
      Set SessTextFile=SessionFileObject.OpenTextFile(PhysicalPath)
	  
     line_num = 0: store_lev = -1
     DO WHILE NOT SessTextFile.AtEndofstream
        textline=SessTextFile.ReadLine
        pos = Instr(textline,";")
      if pos<>0 then 
        Tags(line_num)=LEFT(textline,pos-1)
        Links(line_num)=RIGHT(textline,len(textline)-pos)
	  if left(Tags(line_num),1)="C" then
           lev=mid(Tags(line_num),2)
           if lev <> store_lev then
              cnt = 0
              store_lev = lev
           end if
           cnt=cnt+1
           Tags(line_num) = Tags(line_num) & "_" & cstr(cnt)
           Links(line_num) = replace(Links(line_num),"@@MOUSE@@","onmouseover=""linkUp('child" & lev & "'," & cnt & ")""onmouseout=""linkDn('child" & lev & "'," & cnt & ")")
        end if

        if permits = "all" then
           vpos = Instr(1,cstr(Links(line_num)),">",1)
           if vpos > 0 then 
              Keep(line_num) = Right(Links(line_num),len(Links(line_num))-vpos)
           end if
        end if
	  
        line_num = line_num + 1
	  Redim Preserve Links(line_num)
        Redim Preserve Tags(line_num)
        if permits = "all" then
           Redim Preserve Keep(line_num)
        end if
      end if
    LOOP
      SessTextFile.Close
  
      Permissions_Array = split(permits,",")
      max = ubound(Permissions_Array)
      tagmax = ubound(Tags)
' do the P ones	
       FOR ctr=0 to tagmax
          IF left(tags(ctr),1) = "P" THEN
             use_link = ""
             for index = 0 to max
                IF Permissions_Array(index)= Tags(ctr) or permits = "all" then
                   use_link = Links(ctr)
                   exit for
                end if
             next
             if use_link = "" then
	          pos = Instr(links(ctr),">")
                IF pos > 0 THEN
	             kp= Right(links(ctr),len(links(ctr))-pos)
			 kp=REPLACE(kp,"menu","deny")
		    ElSE
		       kp = "<FONT CLASS=deny>Unavailable</FONT></A>"	 			 
                END IF
   	          use_link = duff_link & kp
             end if
             if permits = "all" then
                firstpart = "<TD WIDTH=""9"" HEIGHT=""22""><INPUT TYPE=""Checkbox"" NAME=""" & Tags(ctr) & """ VALUE=""" & chr(254) & """><TD  WIDTH=""" & TitleWidth & """ HEIGHT=""22"">"
                lastpart = ""             
             else             
                firstpart = "<TD WIDTH=""" & (TitleWidth + 1) & """ HEIGHT=""22"">"             
                lastpart = "<TD WIDTH=""9"" HEIGHT=""22""><IMG SRC=""" & images & "right.gif"" BORDER=""0"" WIDTH=""9"" HEIGHT=""22"">"             
             end if
             p_number = mid(Tags(ctr),2)
             Prospect_explorer = Prospect_explorer & "<TR><TD WIDTH=""30""><IMG NAME=""parent_" & p_number & """ SRC=""" & images & "folder_closed.gif"" BORDER=""0"" WIDTH=""30"" HEIGHT=""22"">" & firstpart & use_link & lastpart
             menujs="menu" & p_number & ".js"
             Session("checkboxjs")="checkbox" & p_number & ".js" 
	    END IF	 
        NEXT  
        if permits <> "all" then
           Prospect_explorer = Prospect_explorer & "<TR><TD COLSPAN=2 WIDTH=""" & (TitleWidth+31) & """ HEIGHT=""22""><HR><TD WIDTH=""9"" HEIGHT=""22""><IMG SRC=""" & images & "right.gif"" BORDER=""0"" WIDTH=""9"" HEIGHT=""22"">"
        end if
' do the O ones	
        pct = 8
        FOR ctr=0 to tagmax
           IF left(tags(ctr),1) = "O" THEN
             use_link = ""
             for index = 0 to max
                IF Permissions_Array(index)= Tags(ctr) or permits = "all" then
                   if permits = "all" then
                      use_link = Keep(ctr)
                   else
                      use_link = Links(ctr)
                   end if                   
                   exit for
                end if
             next
             if use_link = "" then
	          pos = Instr(links(ctr),">")
                IF pos > 0 THEN
	             kp= Right(links(ctr),len(links(ctr))-pos)
			 kp=REPLACE(kp,"menu","deny")
		    ElSE
		       kp = "<FONT CLASS=deny>Unavailable</FONT></A>"	 			 
                END IF
   	          use_link = duff_link & kp
             end if
             pct=pct + 1
             if permits = "all" then
                firstpart = "<TD WIDTH=""9"" HEIGHT=""22""><INPUT TYPE=""Checkbox"" NAME=""" & Tags(ctr) & """ VALUE=""" & chr(254) & """><TD WIDTH=""156"" HEIGHT=""22"">"
                lastpart = ""             
             else             
                firstpart = "<TD WIDTH=""" & (TitleWidth+1) & """ HEIGHT=""22"">"             
                lastpart = "<TD WIDTH=""9"" HEIGHT=""22""><IMG SRC=""" & images & "right.gif"" BORDER=""0"" WIDTH=""9"" HEIGHT=""22"">"             
             end if
             Prospect_explorer = Prospect_explorer & "<TR><TD WIDTH=""30""><IMG NAME=""parent_" & pct & """ SRC=""" & images & "link_dn.gif"" BORDER=""0"" WIDTH=""30"" HEIGHT=""22"">" & firstpart & use_link & lastpart
	     END IF	 
	  NEXT
        Prospect_explorer = Prospect_explorer & "<TR><TD COLSPAN=3><IMG SRC=""" & images & "bottom.gif"" BORDER=""0"" WIDTH=""" & DivWidth & """ HEIGHT=""2""></TABLE></DIV>"
       save_tag=""
' do the C ones	
	 for ctr=0 to tagmax
           if left(tags(ctr),1) = "C"  then
              pos_uscore=instr(tags(ctr),"_")-1
              if left(Tags(ctr),pos_uscore) <> save_tag then
                 if save_tag <> "" then Prospect_explorer = Prospect_explorer & "<TR><TD COLSPAN=3><IMG SRC=""" & images & "bottom.gif"" BORDER=""0"" WIDTH=""" & DivWidth & """ HEIGHT=""2""></TABLE></DIV>"
                 Prospect_explorer = Prospect_explorer & chr(13) & chr(10) & "<DIV CLASS=""link"" ID=""child" & mid(left(Tags(ctr),pos_uscore),2) & "Layer""STYLE=""position: absolute; left: " & ChildOffset & "px; top: 0px; WIDTH: " & DivWidth & "px; z-index: 54; visibility: hidden;""><TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0><TR><TD COLSPAN=3><IMG SRC=""" & images & "top.gif"" BORDER=""0"" WIDTH=""" & DivWidth & """ HEIGHT=""2"">"
                 save_tag = left(Tags(ctr),pos_uscore)
              end if
           end if		     
      if left(tags(ctr),1) = "C" THEN
              use_link = ""
              for index = 0 to max
                 IF Permissions_Array(index)= Tags(ctr) or permits = "all" then
                    if permits = "all" then
                       use_link = Keep(ctr)
                    else
                       use_link = Links(ctr)
                    end if                   
                    exit for
                 end if
               next

            if use_link = "" then
	           pos = Instr(links(ctr),">")
                 IF pos > 0 THEN
	                 kp= Right(links(ctr),len(links(ctr))-pos)
 			         kp=REPLACE(kp,"menu","deny")
		         ElSE
		             kp = "<FONT CLASS=deny>Unavailable</FONT></A>"	 			 
                 END IF
   	            use_link = duff_link & kp
            end if

			 if permits = "all" then
                firstpart = "<TD WIDTH=""9"" HEIGHT=""22""><INPUT TYPE=""Checkbox"" NAME=""" & Tags(ctr) & """ VALUE=""" & chr(254) & """><TD WIDTH=""156"" HEIGHT=""22"">"
                lastpart = ""             
             else             
                firstpart = "<TD WIDTH=""" & (TitleWidth+1) & """ HEIGHT=""22"">"             
                lastpart = "<TD WIDTH=""9"" HEIGHT=""22""><IMG SRC=""" & images & "right.gif"" BORDER=""0"" WIDTH=""9"" HEIGHT=""22"">"             
             end if
             Prospect_explorer = Prospect_explorer & "<TR><TD WIDTH=""30""><IMG NAME=""child" & mid(Tags(ctr),2)  & """ SRC=""" & images & "link_dn.gif"" BORDER=""0"" WIDTH=""30"" HEIGHT=""22"">" & firstpart & use_link & lastpart
        end if
  	 next
       Prospect_explorer = Prospect_explorer & "<TR><TD COLSPAN=3><IMG SRC=""" & images & "bottom.gif"" BORDER=""0"" WIDTH=""" & DivWidth & """ HEIGHT=""2""></TABLE></DIV>" & chr(13) & chr(10)

   'response.write("Prospect_explorer=" & Prospect_explorer )
   'response.end

End Sub
%>