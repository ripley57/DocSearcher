;From:
;https://autohotkey.com/board/topic/71831-application-url-launch-local-application-from-browser/

if 0 != 1 ;Check %0% to see how many parameters were passed in
{
    msgbox ERROR: There are %0% parameters. There should be 1 parameter exactly.
}
else
{
    param = %1%  ;Fetch the contents of the command line argument
    appurl := "appurl://" ; This should be the URL Protocol that you registered in the Windows Registry

    IfInString, param, %appurl%
    {
		newuri := rewriteMFuri(param) 
		if newuri 
		{
			;MsgBox % newuri
			Run, %newuri%
			Return
		}
		else
		{
			;Remove appurl portion from the beginning of param
			arglen := StrLen(param) ;Length of entire argument
			applen := StrLen(appurl) ;Length of appurl
			len := arglen - applen ;Length of argument less appurl
			StringRight, param, param, len
		}
    }

	decoded := uriDecode(param)
    Run, %decoded%
}


;If the URI points to a local MF ".md" page, then rewrite the 
;URI so that it instead points to the online Github page. 
;For example, convert...
;	appurl://C:/Users/jcdc/Cygwin/home/jcdc/Github/MF/MF.md
;into...
;   https://github.com/ripley57/MF/blob/master/MF.md
rewriteMFuri(str) {

	If RegExMatch(str, "iO).*/MF/(.*\.md)", Output) 
	{
		x = % Output.Value(1)
		str2 = http://github.com/ripley57/MF/blob/master/%x%
		Return, str2 
	} 
	
	Return, null
}

; https://autohotkey.com/board/topic/78948-convert-%20-etc-in-urls/
uriDecode(str) {

   Loop

      If RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex)

         StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All

      Else Break

   Return, str

}
