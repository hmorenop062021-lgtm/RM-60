Set WshShell = CreateObject("WScript.Shell")
strCurDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
strCmd = Chr(34) & strCurDir & "\runtime\pythonw.exe" & Chr(34) & " " & Chr(34) & strCurDir & "\balanza_proxy.py" & Chr(34)
WshShell.CurrentDirectory = strCurDir
WshShell.Run strCmd, 0, False
Set WshShell = Nothing
