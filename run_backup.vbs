Set WinScriptHost = CreateObject("WScript.Shell")
WinScriptHost.Run Chr(34) & "D:\SempoiTI\backup_mysql.bat" & Chr(34), 0
Set WinScriptHost = Nothing