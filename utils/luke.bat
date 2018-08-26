@echo OFF
@if not "%ECHO%"=="" echo %ECHO%

REM Description:
REM   Wrapper to launch Luke (https://github.com/DmitryKey/luke/releases/).
REM
REM Usage:
REM   luke
REM
REM JeremyC 25-8-2018

REM Set local scope and call our MAIN procedure.
setlocal & pushd & set RET=
	set pwd=%~dp0
	set SCRIPTNAME=%~nx0
	set SCRIPTPATH=%~f0
	REM To enable tracing, set DEBUG=1.
	if "%DEBUG%"=="1" (set TRACE=echo) else (set TRACE=rem)
	call :MAIN %*
popd & endlocal & set RET=%RET%
goto :eof


REM ////////////////////////////////////////////////////////////////////
REM MAIN procedure
REM
:MAIN
	setlocal
	if defined TRACE %TRACE% [proc :MAIN]

	if "%DOCSEARCH_UTILS_DIR% == "" (
		echo You must run setenv.bat first.
		goto :EXIT-MAIN
	)

	REM Download the Luke jar if not already downloaded.
	set download_url="https://www.dropbox.com/s/le3ky5fzxpc60hb/lukeall-7.3.1.jar"
	set downloaded_file="%DOCSEARCH_UTILS_DIR%\lukeall-7.3.1.jar"
    if not exist %downloaded_file% (
        call :FUNC-UTILS-DOWNLOAD-FILE "%DOCSEARCH_UTILS_DIR%" "lukeall-7.3.1.jar"
        if not !RET! EQU 0 (
           echo ERROR: %FUNC-UTILS-DOWNLOAD-FILE_ERROR_TEXT%
           goto :EXIT-MAIN
        )
    )

	REM Launch Luke.
	java -jar "%DOSEARCH_UTILS_DIR%\lukeall-7.3.1.jar"

	:EXIT-MAIN
	if defined TRACE %TRACE% [proc :MAIN return]
	endlocal
	goto :eof

REM ///////////// END OF SCRIPT ///////////////
