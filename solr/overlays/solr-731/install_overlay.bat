@echo OFF
@if not "%ECHO%"=="" echo %ECHO%
REM Description:
REM   Install overlay files for Solr 7.3.1
REM
REM JeremyC 18-7-2018

REM Set local scope, initialize libraries and then call our MAIN procedure.
setlocal & pushd & set RET=
	set pwd=%~dp0
	set SCRIPTNAME=%~nx0
	set SCRIPTPATH=%~f0

	REM To enable tracing, set DEBUG=1, e.g. 
	REM set DEBUG=1& Menu.bat
	REM Note: No space before "&"!
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
	set pwd=%~dp0
	set _solr_install_dir=%1
	
	if "%1"=="" (
		echo ERROR: Missing solr install path input argument
		goto :END_MAIN
	)
	
	if not exist %_solr_install_dir% ( 
		echo ERROR: Solr install path does not exist: %_solr_install_dir%
		goto :END_MAIN
	)
	
	if not exist %_solr_install_dir%\dist\solr-velocity-7.3.1.jar.before_overlay (
		REM Install our rebuilt solr-velocity jar with LinkTool support.
		rename %_solr_install_dir%\dist\solr-velocity-7.3.1.jar solr-velocity-7.3.1.jar.before_overlay
		copy %pwd%\solr-velocity-7.3.1.jar %_solr_install_dir%\dist\solr-velocity-7.3.1.jar 2>&1 >nul

		REM Add missing search result document type icons which are based on file extension.
		copy %_solr_install_dir%\server\solr-webapp\webapp\img\filetypes\doc.png %_solr_install_dir%\server\solr-webapp\webapp\img\filetypes\docx.png 2>&1 >nul
		copy %_solr_install_dir%\server\solr-webapp\webapp\img\ico\mail.png %_solr_install_dir%\server\solr-webapp\webapp\img\filetypes\msg.png 2>&1 >nul
	)

	REM Fix solr error:
	REM java.lang.NoClassDefFoundError: com/uwyn/jhighlight/renderer/XhtmlRendererFactory
	if not exist %_solr_install_dir%\server\lib\jhighlight-1.0.jar (
		copy %pwd%\jhighlight-1.0.jar %_solr_install_dir%\server\lib\jhighlight-1.0.jar 2>&1 >nul
	)
	
:END_MAIN
	if defined TRACE %TRACE% [proc :MAIN return]
	endlocal
	goto :eof
	
REM ///////////// END OF SCRIPT ///////////////
