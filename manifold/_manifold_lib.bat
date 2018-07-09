@echo OFF
@if not "%ECHO%"=="" echo %ECHO%
REM Description:
REM   Library of useful functions related to Manifold.
REM     
REM JeremyC 20-6-2018 


REM If no arguments display version information and exit.
if "%1"=="" (
	echo Manifold Script Library v1.00
	goto :eof
)


REM We must have at least one input argument, so dispatch to procedure.
set _PROC=%1
shift
goto %_PROC%


REM ////////////////////////////////////////////////////////////////////
REM INIT procedure
REM Should be called before using the library.
REM
:INIT
	if defined TRACE %TRACE% [proc :INIT]
	
	set topdir=%1

	set DOCSEARCH_MANIFOLD_VERSION=1.9
	set DOCSEARCH_MANIFOLD_BIN_DIR=%topdir%manifold\apache-manifoldcf-1.9
	set DOCSEARCH_MANIFOLD_DIR=%topdir%manifold
	set DOCSEARCH_MANIFOLD_LIB=%topdir%manifold\_manifold_lib.bat
	
	
	REM Download Manifold from here.
	set DOCSEARCH_MANIFOLD_DOWNLOAD_ZIP_URL=http://archive.apache.org/dist/manifoldcf/apache-manifoldcf-1.9/apache-manifoldcf-1.9-bin.zip
	set DOCSEARCH_MANIFOLD_DOWNLOAD_ZIP_FILENAME=apache-manifoldcf-1.9-bin.zip

	REM Keep downloads here.
	set DOCSEARCH_MANIFOLD_DOWNLOAD_TEMP_DIR=C:\TEMP
	
	REM Extract the Manifold zip in this directory.
	set DOCSEARCH_MANIFOLD_DOWNLOAD_EXTRACT_TO_DIR=%DOCSEARCH_MANIFOLD_DIR%
	
	REM This is the directory we expect to see after extraction.
	set DOCSEARCH_MANIFOLD_DOWNLOAD_ZIP_DIRNAME=%DOCSEARCH_MANIFOLD_DOWNLOAD_EXTRACT_TO_DIR%\apache-manifoldcf-1.9
	
	
	if defined TRACE %TRACE% [proc :INIT returns]
	goto :eof

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MANIFOLD-START
REM Start Manifold.
REM
REM Returns: 0 if started successfully; otherwise >0
REM
:FUNC-MANIFOLD-START
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MANIFOLD-START]

	set pwd=%~dp0
	set FUNC-MANIFOLD-START_ERROR_TEXT=
	set RET=1
	
	call :FUNC-MANIFOLD-GET-STATE
	if "%RET%"=="RUNNING" (
		REM Manifold already running.
		set RET=2
		set FUNC-MANIFOLD-START_ERROR_TEXT=Manifold is already running.
		goto EXIT-FUNC-MANIFOLD-START
	)
	
	REM Start Manifold.
	pushd %DOCSEARCH_MANIFOLD_BIN_DIR%\example
	start "Manifold" cmd /T 17 /C start.bat
	popd
	
	REM Manifold successfully started.
	set RET=0
	
	:EXIT-FUNC-MANIFOLD-START
	if defined TRACE %TRACE% [proc :FUNC-MANIFOLD-START return {%RET%} {%FUNC-MANIFOLD-START_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-MANIFOLD-START_ERROR_TEXT=%FUNC-MANIFOLD-START_ERROR_TEXT%
	goto :eof
	

REM ////////////////////////////////////////////////////////////////////
REM FUNC-MANIFOLD-STOP
REM Stop Manifold.
REM
REM Returns: 0 if stopped successfully; otherwise >0
REM
:FUNC-MANIFOLD-STOP
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MANIFOLD-STOP]

	set pwd=%~dp0
	set FUNC-MANIFOLD-STOP_ERROR_TEXT=
	set RET=1
	
	call :FUNC-MANIFOLD-GET-STATE
	if "%RET%"=="NOT-RUNNING" (
		REM Manifold already running.
		set RET=2
		set FUNC-MANIFOLD-STOP_ERROR_TEXT=Manifold is already stopped.
		goto EXIT-FUNC-MANIFOLD-STOP
	)
	
	REM Stop Manifold.
	REM Note: AFAIK there is no way to do this, apart from using ctrl-c in the console window
	REM       launched when ManifoldCF is started using start.bat. This is at least true for
	REM	      for version 1.9.
	cmd /c echo NOTE: Use ctrl-c in the ManifoldCF console window to stop Manifold.
		
	REM Assume Manifold successfully stopped.
	set RET=0
	
	:EXIT-FUNC-MANIFOLD-STOP
	if defined TRACE %TRACE% [proc :FUNC-MANIFOLD-STOP return {%RET%} {%FUNC-MANIFOLD-STOP_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-MANIFOLD-STOP_ERROR_TEXT=%FUNC-MANIFOLD-STOP_ERROR_TEXT%
	goto :eof

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MANIFOLD-GET-STATE
REM
REM Returns: "RUNNING" or "NOT-RUNNING".
REM
:FUNC-MANIFOLD-GET-STATE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MANIFOLD-GET-STATE]
	
	set pwd=%~dp0
	set FUNC-MANIFOLD-GET-STATE_ERROR_TEXT=
	set RET=NOT-RUNNING
	
	netstat -an | find /i "listening"| findstr :8345 >nul && set RET=RUNNING
	
	if defined TRACE %TRACE% [proc :FUNC-MANIFOLD-GET-STATE return {%RET%} {%FUNC-MANIFOLD-GET-STATE_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-MANIFOLD-GET-STATE_ERROR_TEXT=%FUNC-MANIFOLD-GET-STATE_ERROR_TEXT%
	goto :eof

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MANIFOLD-GET-INSTALLED-STATE
REM
REM Returns: INSTALLED if installed; otherwise NOT-INSTALLED.
REM
:FUNC-MANIFOLD-GET-INSTALLED-STATE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MANIFOLD-GET-INSTALLED-STATE]
	
	set RET=NOT-INSTALLED
	if exist %DOCSEARCH_MANIFOLD_BIN_DIR%\example (set RET=INSTALLED)
	
	if defined TRACE %TRACE% [proc :FUNC-MANIFOLD-GET-INSTALLED-STATE return {%RET%}]
	endlocal & set RET=%RET%
	goto :eof		
	

REM ///////////// END OF SCRIPT ///////////////