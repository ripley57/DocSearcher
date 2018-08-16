@echo OFF
@if not "%ECHO%"=="" echo %ECHO%
REM Description:
REM   Library of useful functions related to Java.
REM     
REM JeremyC 20-6-2018 


REM If no arguments display version information and exit.
if "%1"=="" (
	echo Java Script Library v1.00
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

	set DOCSEARCH_JAVA_VERSION=8u74-x64
	set DOCSEARCH_JAVA_HOME_DIR=%topdir%java\jdk-8u74-windows-x64
	set DOCSEARCH_JAVA_DIR=%topdir%java
	set DOCSEARCH_JAVA_LIB=%topdir%java\_java_lib.bat
	
	
	REM Download Java from here.
	set DOCSEARCH_JAVA_DOWNLOAD_ZIP_URL=https://www.dropbox.com/s/td5mgzz4c862l7e/jdk-8u74-windows-x64.zip
	set DOCSEARCH_JAVA_DOWNLOAD_ZIP_FILENAME=jdk-8u74-windows-x64.zip
	
	REM Keep downloads here.
	set DOCSEARCH_JAVA_DOWNLOAD_TEMP_DIR=C:\TEMP
	
	REM Extract the Java zip in this directory.
	set DOCSEARCH_JAVA_DOWNLOAD_EXTRACT_TO_DIR=%DOCSEARCH_JAVA_DIR%
	
	REM This is the directory we expect to see after extraction.
	set DOCSEARCH_JAVA_DOWNLOAD_ZIP_DIRNAME=%DOCSEARCH_JAVA_DOWNLOAD_EXTRACT_TO_DIR%\jdk-8u74-windows-x64
	
	
	set JAVA_HOME=%DOCSEARCH_JAVA_HOME_DIR%
	set PATH=%JAVA_HOME%\bin;%PATH%
	
	if defined TRACE %TRACE% [proc :INIT return]
	goto :eof

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-JAVA-GET-INSTALLED-STATE
REM
REM Returns: INSTALLED if installed; otherwise NOT-INSTALLED.
REM
:FUNC-JAVA-GET-INSTALLED-STATE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-JAVA-GET-INSTALLED-STATE]
	
	set RET=NOT-INSTALLED
	if exist %DOCSEARCH_JAVA_HOME_DIR%\bin (set RET=INSTALLED)
	
	if defined TRACE %TRACE% [proc :FUNC-JAVA-GET-INSTALLED-STATE return {%RET%}]
	endlocal & set RET=%RET%
	goto :eof	

	
REM ///////////// END OF SCRIPT ///////////////
