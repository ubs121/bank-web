   title="": hds="": tds="": dms=""
   PhysicalPath=Server.MapPath(readpath)
   Set SessionFileObject=Server.CreateObject("Scripting.FileSystemObject")
   if SessionFileObject.FileExists(PhysicalPath) then
      Set SessionTextFile=SessionFileObject.OpenTextFile(PhysicalPath)
      DO WHILE NOT SessionTextFile.AtEndofstream
       textline=SessionTextFile.ReadLine
       pos=instr(textline,"=")
       if pos<> 0  then temp=left(textline,pos-1) else temp=""
       select case temp
          case "title": title=mid(textline,pos+1)
          case "hds": hds=mid(textline,pos+1)
          case "tds": tds=mid(textline,pos+1)
          case "dms": dms=mid(textline,pos+1)
       end select
      LOOP
      SessionTextFile.Close
   else
     	response.write("Sorry, the file " & readpath & " does not exost")
	response.end
   end if
