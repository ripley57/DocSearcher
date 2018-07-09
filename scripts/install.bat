@echo OFF
@if not "%ECHO%"=="" echo %ECHO%

REM Description:
REM   Download and install the various required 3rd party products. 
REM   This includes: java, Solr, Manifold, and Ant.
REM   Installation is basically extracting zip files in the correct
REM   locations expected by the docsearch program.
REM
REM Usage:
REM   install.bat [prog-1] [prog-2] ...
REM
REM Example:
REM   install.bat java solr manifold ant
REM
REM JeremyC 24-6-2018

REM Set local scope, initialize libraries and then call our MAIN procedure.
setlocal & pushd & set RET=
	set pwd=%~dp0
	set SCRIPTNAME=%~nx0
	set SCRIPTPATH=%~f0
	REM To enable tracing, set DEBUG=1.
	if "%DEBUG%"=="1" (set TRACE=echo) else (set TRACE=rem)
	REM Initialize env variables for download urls, etc.
	call %pwd%\..\_docsearch_lib :INIT
	call :MAIN %*
popd & endlocal & set RET=%RET%
goto :eof


REM ////////////////////////////////////////////////////////////////////
REM MAIN procedure
REM
:MAIN
	setlocal
	if defined TRACE %TRACE% [proc :MAIN]
	
	if "%1"=="" (
		echo.
		echo %SCRIPTNAME%
		echo.
		echo Description:
		echo    Install 3rd party programs including java, solr and manifold.
		echo.
		echo Usage: 
		echo    %SCRIPTNAME% [versions] ^| [java] [solr] [manifold] [ant]
		echo.
		goto :EXIT-MAIN
	)
	
	if "%1"=="versions" (
		call :FUNC-INSTALL-SHOWVERSIONS
		goto :EXIT-MAIN
	)
	
	REM Process input args.
	:MAIN-NEXT-ARG
	if not "%1"=="" (
		if "%1"=="java" (
			call :FUNC-INSTALL-JAVA
		) else if "%1"=="solr" (
			call :FUNC-INSTALL-SOLR
		) else if "%1"=="manifold"	(
			call :FUNC-INSTALL-MANIFOLD
		) else if "%1"=="ant" (
			call :FUNC-INSTALL-ANT
		) else (
			echo ERROR: Bad argument %1 
			goto :EXIT-MAIN
		)
		shift
		goto :MAIN-NEXT-ARG
	)

	:EXIT-MAIN
	if defined TRACE %TRACE% [proc :MAIN return]
	endlocal
	goto :eof
	

REM ////////////////////////////////////////////////////////////////////
REM FUNC-INSTALL-SHOWVERSION
REM
REM Display 3rd party product versions being used by docsearch.
REM
:FUNC-INSTALL-SHOWVERSIONS
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-INSTALL-SHOWVERSIONS]
	echo.
	echo Java:		%DOCSEARCH_JAVA_VERSION%	(%DOCSEARCH_JAVA_DOWNLOAD_ZIP_URL%)
	echo Solr:		%DOCSEARCH_SOLR_VERSION%		(%DOCSEARCH_SOLR_DOWNLOAD_ZIP_URL%)
	echo Manifold:	%DOCSEARCH_MANIFOLD_VERSION%		(%DOCSEARCH_MANIFOLD_DOWNLOAD_ZIP_URL%)
	echo Ant:		%DOCSEARCH_ANT_VERSION%		(%DOCSEARCH_ANT_DOWNLOAD_ZIP_URL%)
	echo.
	if defined TRACE %TRACE% [proc :FUNC-INSTALL-SHOWVERSIONS return]
	endlocal
	goto :eof

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-INSTALL-JAVA
REM
:FUNC-INSTALL-JAVA
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-INSTALL-JAVA]
	
	set download_url=%DOCSEARCH_JAVA_DOWNLOAD_ZIP_URL%
	set download_to_dir=%DOCSEARCH_JAVA_DOWNLOAD_TEMP_DIR%
	set download_to_filename=%DOCSEARCH_JAVA_DOWNLOAD_ZIP_FILENAME%
	set extract_to_dir=%DOCSEARCH_JAVA_DOWNLOAD_EXTRACT_TO_DIR%
	set expected_zip_extracted_dir=%DOCSEARCH_JAVA_DOWNLOAD_ZIP_DIRNAME%
		
	call %DOCSEARCH_UTILS_LIB% :FUNC-UTILS-INSTALL-ZIP %download_url% %download_to_dir% %download_to_filename% %extract_to_dir% %expected_zip_extracted_dir%
	if %RET% EQU 0 (
		echo.
		echo Java installed successfully.
		echo. 
	) else (
		echo ERROR: %FUNC-UTILS-INSTALL-ZIP_ERROR_TEXT%
	)
		
	if defined TRACE %TRACE% [proc :FUNC-INSTALL-JAVA return]
	endlocal
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-INSTALL-SOLR
REM
:FUNC-INSTALL-SOLR
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-INSTALL-SOLR]
	
	set download_url=%DOCSEARCH_SOLR_DOWNLOAD_ZIP_URL%
	set download_to_dir=%DOCSEARCH_SOLR_DOWNLOAD_TEMP_DIR%
	set download_to_filename=%DOCSEARCH_SOLR_DOWNLOAD_ZIP_FILENAME%
	set extract_to_dir=%DOCSEARCH_SOLR_DOWNLOAD_EXTRACT_TO_DIR%
	set expected_zip_extracted_dir=%DOCSEARCH_SOLR_DOWNLOAD_ZIP_DIRNAME%
		
	call %DOCSEARCH_UTILS_LIB% :FUNC-UTILS-INSTALL-ZIP %download_url% %download_to_dir% %download_to_filename% %extract_to_dir% %expected_zip_extracted_dir%
	
	if %RET% EQU 0 (
		echo.
		echo Solr installed successfully.
		echo. 
	) else (
		echo ERROR: %FUNC-UTILS-INSTALL-ZIP_ERROR_TEXT%
	)

	if defined TRACE %TRACE% [proc :FUNC-INSTALL-SOLR return]
	endlocal
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-INSTALL-MANIFOLD
REM
:FUNC-INSTALL-MANIFOLD
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-INSTALL-MANIFOLD]
	
	set download_url=%DOCSEARCH_MANIFOLD_DOWNLOAD_ZIP_URL%
	set download_to_dir=%DOCSEARCH_MANIFOLD_DOWNLOAD_TEMP_DIR%
	set download_to_filename=%DOCSEARCH_MANIFOLD_DOWNLOAD_ZIP_FILENAME%
	set extract_to_dir=%DOCSEARCH_MANIFOLD_DOWNLOAD_EXTRACT_TO_DIR%
	set expected_zip_extracted_dir=%DOCSEARCH_MANIFOLD_DOWNLOAD_ZIP_DIRNAME%
		
	call %DOCSEARCH_UTILS_LIB% :FUNC-UTILS-INSTALL-ZIP %download_url% %download_to_dir% %download_to_filename% %extract_to_dir% %expected_zip_extracted_dir%
	
	if %RET% EQU 0 (
		echo.
		echo Manifold installed successfully.
		echo. 
	) else (
		echo ERROR: %FUNC-UTILS-INSTALL-ZIP_ERROR_TEXT%
	)
		
	if defined TRACE %TRACE% [proc :FUNC-INSTALL-MANIFOLD return]
	endlocal
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-INSTALL-ANT
REM
:FUNC-INSTALL-ANT
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-INSTALL-ANT]
	
	set download_url=%DOCSEARCH_ANT_DOWNLOAD_ZIP_URL%
	set download_to_dir=%DOCSEARCH_ANT_DOWNLOAD_TEMP_DIR%
	set download_to_filename=%DOCSEARCH_ANT_DOWNLOAD_ZIP_FILENAME%
	set extract_to_dir=%DOCSEARCH_ANT_DOWNLOAD_EXTRACT_TO_DIR%
	set expected_zip_extracted_dir=%DOCSEARCH_ANT_DOWNLOAD_ZIP_DIRNAME%
		
	call %DOCSEARCH_UTILS_LIB% :FUNC-UTILS-INSTALL-ZIP %download_url% %download_to_dir% %download_to_filename% %extract_to_dir% %expected_zip_extracted_dir%
	
	if %RET% EQU 0 (
		echo.
		echo Ant installed successfully.
		echo. 
	) else (
		echo ERROR: %FUNC-UTILS-INSTALL-ZIP_ERROR_TEXT%
	)
			
	if defined TRACE %TRACE% [proc :FUNC-INSTALL-ANT return]
	endlocal
	goto :eof
	
	
REM ///////////// END OF SCRIPT ///////////////
