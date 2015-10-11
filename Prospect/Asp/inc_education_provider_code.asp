<%  
  Set SessionFileObject=Server.CreateObject("Scripting.FileSystemObject")
  Set SessionTextFile=SessionFileObject.OpenTextFile("c:\ckashare\education\provider_code.txt")
  flds(1)="!" & SessionTextFile.ReadAll
  SessionTextFile.Close
  Set SessionFileObject=nothing
%>