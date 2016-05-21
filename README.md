# IniFileParser

This Tool enables you to parse *.INI File with a powershell script.
The common.ps1 files contains the function "parseInifile" who returns an array of Objects
conrtaining all the element of your Ini-File.
You can check The Form.ps1 to see how to use it according to your use.   


This tool supports:
-------------------

Parsing files which content is of type:

; last modified 1 April 2001 by John Doe
[owner]
name=John Doe
organization=Acme Widgets Inc.

[database]
; use IP address in case network name resolution is not working
server=192.0.2.62     
port=143
file="payroll.dat"


 - all commented section is ignored
 - return all section in the first column
 - Key and Value in the second column as an array of Object (hastable)

	
 --> your section structure may contains the following characters: _ %<>/#+-
 --> In "server=192.0.2.62 ;server address" for example
	The part ";server address is ignored" and "server=192.0.2.62" is only returned
 --> you can have an empty section



This tool doesn't support:
-------------------------
 --> The received commented section characters is only ";". This doesn't support "#" or "/*" either.


If you encounter some problems, feel free to contat me at:
kevin_rhtl@hotmail.com





