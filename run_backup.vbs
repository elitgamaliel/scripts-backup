Set WinScriptHost = CreateObject("WScript.Shell")
WinScriptHost.Run Chr(34) & "backup_mysql_native.bat" & Chr(34), 0
Set WinScriptHost = Nothing