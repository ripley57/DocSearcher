@echo OFF
@if not "%ECHO%"=="" echo %ECHO%
REM Description:
REM   Library of useful functions related to Ant.
REM     
REM JeremyC 20-6-2018 


REM If no arguments display version information and exit.
if "%1"=="" (
	echo Ant Script Library v1.00
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

	set DOCSEARCH_ANT_VERSION=1.10.1
	set DOCSEARCH_ANT_BIN_DIR=%topdir%ant\apache-ant-1.10.1
	set DOCSEARCH_ANT_DIR=%topdir%ant
	set DOCSEARCH_ANT_LIB=%topdir%ant\_ant_lib.bat
	
	
	REM Download Ant from here.
	set DOCSEARCH_ANT_DOWNLOAD_ZIP_URL=https://archive.apache.org/dist/ant/binaries/apache-ant-1.10.1-bin.zip
	set DOCSEARCH_ANT_DOWNLOAD_ZIP_FILENAME=apache-ant-1.10.1-bin.zip
	
	REM Keep downloads here.
	set DOCSEARCH_ANT_DOWNLOAD_TEMP_DIR=C:\TEMP
	
	REM Extract the Ant zip in this directory.
	set DOCSEARCH_ANT_DOWNLOAD_EXTRACT_TO_DIR=%DOCSEARCH_ANT_DIR%
	
	REM This is the directory we expect to see after extraction.
	set DOCSEARCH_ANT_DOWNLOAD_ZIP_DIRNAME=%DOCSEARCH_ANT_DOWNLOAD_EXTRACT_TO_DIR%\apache-ant-1.10.1
	
	
	set ANT_HOME=%topdir%ant\apache-ant-1.10.1
	
	if defined TRACE %TRACE% [proc :INIT returns]
	goto :eof

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-ANT-GET-INSTALLED-STATE
REM
REM Returns: INSTALLED if installed; otherwise NOT-INSTALLED.
REM
:FUNC-ANT-GET-INSTALLED-STATE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-ANT-GET-INSTALLED-STATE]
	
	set RET=NOT-INSTALLED
	if exist %DOCSEARCH_ANT_BIN_DIR%\bin (set RET=INSTALLED)
	
	if defined TRACE %TRACE% [proc :FUNC-ANT-GET-INSTALLED-STATE return {%RET%}]
	endlocal & set RET=%RET%
	goto :eof		

	
REM ///////////// END OF SCRIPT ///////////////
