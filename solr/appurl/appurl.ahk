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
        arglen := StrLen(param) ;Length of entire argument
        applen := StrLen(appurl) ;Length of appurl
        len := arglen - applen ;Length of argument less appurl
        StringRight, param, param, len ; Remove appurl portion from the beginning of parameter
    }

	decoded := uriDecode(param)
	
    Run, %decoded%
}


; https://autohotkey.com/board/topic/78948-convert-%20-etc-in-urls/
uriDecode(str) {

   Loop

      If RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex)

         StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All

      Else Break

   Return, str

}
