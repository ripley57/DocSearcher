@echo OFF
@if not "%ECHO%"=="" echo %ECHO%
REM Description:
REM   Docsearch Script Library.
REM   
REM JeremyC 20-6-2018 


REM If no arguments display version information and exit.
if "%1"=="" (
	echo Docsearch v1.00
	goto :eof
)

REM We must have at least one input argument, so dispatch to procedure.
set _PROC=%1
shift
goto %_PROC%


REM ////////////////////////////////////////////////////////////////////
REM INIT procedure
REM Set global variables.
REM
:INIT
	if defined TRACE %TRACE% [proc %*]
	
	set topdir=%~dp0
	
	set DOCSEARCH_DIR=%topdir%
	set DOCSEARCH_SCRIPTS_DIR=%topdir%\scripts
	
	REM Call the initialization routine of each of our libraries.
	REM This ensures that env vars from these libraries are set.
	call utils\_utils_lib.bat :INIT %topdir%
	call java\_java_lib.bat :INIT %topdir%
	call solr\_solr_lib.bat :INIT %topdir%
	call manifold\_manifold_lib.bat :INIT %topdir%
	call ant\_ant_lib.bat :INIT %topdir%

	REM Add scripts directory to path.
	set PATH="%DOCSEARCH_SCRIPTS_DIR%";%PATH%
	
	if defined TRACE %TRACE% [proc %* return]
	goto :eof


REM ///////////// END OF SCRIPT ///////////////
