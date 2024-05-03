@echo OFF
@if not "%ECHO%"=="" echo %ECHO%
REM Description:
REM   Library of useful utility functions.
REM  
REM JeremyC 20-6-2018 


REM If no arguments display version information and exit.
if "%1"=="" (
	echo Utils Script Library v1.00
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
	if defined TRACE %TRACE% [proc %*]
	
	set topdir=%1
	
	set DOCSEARCH_UTILS_DIR=%topdir%utils
	set DOCSEARCH_UTILS_LIB=%topdir%utils\_utils_lib.bat
	set WGET_EXE=%DOCSEARCH_UTILS_DIR%\wget\wget.exe
	
	if defined TRACE %TRACE% [proc %* return]
	goto :eof


REM ////////////////////////////////////////////////////////////////////
REM FUNC-UTILS-EXTRACT-ZIP 
REM Extracts a zip file to a specified directory.
REM
REM Arguments:
REM   %1=Path to the zip file.
REM   %2=Directory to extract the zip file to.
REM
REM Returns: 0 if zip was successful; otherwise returns non-0 and erroryes
REM          message in variable FUNC-EXTRACT-ZIP_ERROR_TEXT.
:FUNC-UTILS-EXTRACT-ZIP 
	if defined TRACE %TRACE% [proc :FUNC-UTILS-EXTRACT-ZIP]
	setlocal
	set pwd=%~dp0
	set zipfilepath=%1
	set targetdir=%2
	set extraargs=%3
	set FUNC-UTILS-EXTRACT-ZIP_ERROR_TEXT=
	set RET=1

	REM Convert extra args to valid unzip args.
	if defined extraargs (
		set extraargs=!extraargs:quiet=^-q!
	)

	REM Check input args.
	set badargs=
	if "%zipfilepath%"=="" (set badargs=true) 
	if "%targetdir%"==""   (set badargs=true)
	if defined badards (
		set FUNC-UTILS-EXTRACT-ZIP_ERROR_TEXT=Bad input args
		goto :EXIT-FUNC-UTILS-EXTRACT-ZIP
	)

	REM Perform the unzip.
	set unzip_exe=%DOCSEARCH_UTILS_DIR%\unzip\unzip.exe
	if defined TRACE %TRACE% [proc :FUNC-UTILS-EXTRACT-ZIP Running %unzip_exe% %extraargs% %zipfilepath% -d %targetdir% ...]
	                                                               %unzip_exe% %extraargs% %zipfilepath% -d %targetdir%
	set RET=%errorlevel%
	if not %RET% == 0 (
		set FUNC-UTILS-EXTRACT-ZIP_ERROR_TEXT=Failed to unzip %zipfilepath% [unzip.exe error %RET%]
		set RET=2
		goto :EXIT-FUNC-UTILS-EXTRACT-ZIP
	)
	
	:EXIT-FUNC-UTILS-EXTRACT-ZIP 
	if defined TRACE %TRACE% [proc :FUNC-UTILS-EXTRACT-ZIP return {%RET%} {%FUNC-UTILS-EXTRACT-ZIP_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-UTILS-EXTRACT-ZIP_ERROR_TEXT=%FUNC-UTILS-EXTRACT-ZIP_ERROR_TEXT%
	goto :eof

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-UTILS-GET-IE-PATH
REM
REM Returns: Path to IE.
REM
:FUNC-UTILS-GET-IE-PATH
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-UTILS-GET-IE-PATH]
	set pwd=%~dp0
	set FUNC-UTILS-GET-IE-PATH_ERROR_TEXT=
	set RET=

	set ie_exe="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" 
	if exist %ie_exe% (set RET=%ie_exe% & goto :EXIT-FUNC-UTILS-GET-IE-PATH)
	set ie_exe="C:\Program Files\Internet Explorer\iexplore.exe"
	if exist %ie_exe% (set RET=%ie_exe% & goto :EXIT-FUNC-UTILS-GET-IE-PATH) 
	set ie_exe="C:\Program Files (x86)\Internet Explorer\iexplore.exe"
	if exist %ie_exe% (set RET=%ie_exe% & goto :EXIT-FUNC-UTILS-GET-IE-PATH)
	if "%RET%"=="" (set FUNC-UTILS-GET-IE-PATH_ERROR_TEXT=Could not find IE.)

	:EXIT-FUNC-UTILS-GET-IE-PATH
	if defined TRACE %TRACE% [proc :FUNC-UTILS-GET-IE-PATH return {%RET%} {%FUNC-UTILS-GET-IE-PATH_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-UTILS-GET-IE-PATH_ERROR_TEXT=%FUNC-UTILS-GET-IE-PATH_ERROR_TEXT%
	goto :eof

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-UTILS-TAIL-FILE
REM Tail the specified log file.
REM
REM Returns: 0 if successful; otherwise >0.
REM
:FUNC-UTILS-TAIL-FILE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-UTILS-TAIL-FILE]

	set pwd=%~dp0
	set filepath=%1
	set FUNC-UTILS-TAIL-FILE_ERROR_TEXT=
	set RET=0
	
	REM Perform the tail.
	if not exist %filepath% (
		set FUNC-UTILS-TAIL-FILE_ERROR_TEXT=No such file: %filepath%
		set RET=1
		goto :EXIT-FUNC-UTILS-TAIL-FILE
	)
	
	start %DOCSEARCH_UTILS_DIR%\tail.exe -f %filepath%
		
	:EXIT-FUNC-UTILS-TAIL-FILE
	if defined TRACE %TRACE% [proc :FUNC-UTILS-TAIL-FILE return {%RET%} {%FUNC-UTILS-TAIL-FILE_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-UTILS-TAIL-FILE_ERROR_TEXT=%FUNC-UTILS-TAIL-FILE_ERROR_TEXT%
	goto :eof


REM ////////////////////////////////////////////////////////////////////
REM FUNC-UTILS-DOWNLOAD-FILE
REM Download a file given a url.
REM
REM Returns: 0 if successfull, >0 if there was an error.
REM
:FUNC-UTILS-DOWNLOAD-FILE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-UTILS-DOWNLOAD-FILE]
	set pwd=%~dp0
	set download_url=%1
	set download_to_dir=%2
	set download_to_filename=%3
	set FUNC-UTILS-DOWNLOAD-FILE_ERROR_TEXT=
	set RET=1
	
	set badargs=
	if "%download_url%"=="" (set badargs=true)
	if "%download_to_dir%"=="" (set badargs=true)
	if "%download_to_filename%"==""	(set badargs=true)
	if defined badargs (
		set FUNC-UTILS-DOWNLOAD-FILE_ERROR_TEXT=Bad input args.
		set RET=2
		goto :EXIT-FUNC-UTILS-DOWNLOAD-FILE
	)
	
	if defined TRACE (
		%TRACE% [proc :FUNC-UTILS-DOWNLOAD-FILE download_url=%download_url%]
		%TRACE% [proc :FUNC-UTILS-DOWNLOAD-FILE download_to_dir=%download_to_dir%]
		%TRACE% [proc :FUNC-UTILS-DOWNLOAD-FILE download_to_filename=%download_to_filename%]
	)
	
	REM Download the file.		
	if defined TRACE %TRACE% [proc :FUNC-UTILS-DOWNLOAD-FILE %WGET_EXE% --no-check-certificate -P %download_to_dir% %download_url% ...]
	                                                         %WGET_EXE% --no-check-certificate -P %download_to_dir% %download_url%
	set RET=%errorlevel%
	if not %RET% == 0 (
		set FUNC-UTILS-DOWNLOAD-FILE_ERROR_TEXT=Failed to download %download_url% [wget.exe error %RET%]
		set RET=3
		goto :EXIT-FUNC-UTILS-DOWNLOAD-FILE
	)
	
	:EXIT-FUNC-UTILS-DOWNLOAD-FILE
	if defined TRACE %TRACE% [proc :FUNC-UTILS-DOWNLOAD-FILE return {%RET%} {%FUNC-UTILS-DOWNLOAD-FILE_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-UTILS-DOWNLOAD-FILE_ERROR_TEXT=%FUNC-UTILS-DOWNLOAD-FILE_ERROR_TEXT%
	goto :eof	
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-UTILS-INSTALL-ZIP
REM Download a file given a url and install to specified directory.
REM
REM Returns: 0 if successfull, >0 if there was an error.
REM
:FUNC-UTILS-INSTALL-ZIP
	setlocal ENABLEDELAYEDEXPANSION
	if defined TRACE %TRACE% [proc :FUNC-UTILS-INSTALL-ZIP]
	set pwd=%~dp0
	set download_url=%1
	set download_to_dir=%2
	set download_to_filename=%3
	set extract_to_dir=%4
	set expected_zip_extraction_dir=%5
	set FUNC-UTILS-INSTALL-ZIP_ERROR_TEXT=
	set RET=1
	
	set badargs=
	if "%download_url%"=="" 				(set badargs=true)
	if "%download_to_dir%"=="" 				(set badargs=true)
	if "%download_to_filename%"==""			(set badargs=true)
	if "%extract_to_dir%"==""				(set badargs=true)
	if "%expected_zip_extraction_dir%"=="" 	(set badargs=true)
	if defined badargs (
		set FUNC-UTILS-INSTALL-ZIP_ERROR_TEXT=Bad input args.
		set RET=2
		goto :EXIT-FUNC-UTILS-INSTALL-ZIP
	)
	
	REM The downloaded file will be this.
	set downloaded_file=%download_to_dir%\%download_to_filename%
	
	if defined TRACE (
		%TRACE% [proc :FUNC-UTILS-INSTALL-ZIP download_url=%download_url%]
		%TRACE% [proc :FUNC-UTILS-INSTALL-ZIP download_to_dir=%download_to_dir%]
		%TRACE% [proc :FUNC-UTILS-INSTALL-ZIP download_to_filename=%download_to_filename%]
		%TRACE% [proc :FUNC-UTILS-INSTALL-ZIP extract_to_dir=%extract_to_dir%]
		%TRACE% [proc :FUNC-UTILS-INSTALL-ZIP expected_zip_extraction_dir=%expected_zip_extraction_dir%]
		%TRACE% [proc :FUNC-UTILS-INSTALL-ZIP downloaded_file=%downloaded_file%]	
	)
	
	REM Only download the file if we don't have it already.
	if not exist %downloaded_file% (
		call :FUNC-UTILS-DOWNLOAD-FILE %download_url% %download_to_dir% %download_to_filename%
		if not !RET! EQU 0 (
			set FUNC-UTILS-INSTALL-ZIP_ERROR_TEXT=%FUNC-UTILS-DOWNLOAD-FILE_ERROR_TEXT%
			set RET=3
			goto :EXIT-FUNC-UTILS-INSTALL-ZIP
		)
	) else (
		if defined TRACE %TRACE% [proc :FUNC-UTILS-INSTALL-ZIP Already have download file: %downloaded_file%]
	)

	REM Extra check for the downloaded file.
	if not exist %downloaded_file% (
		set FUNC-UTILS-INSTALL-ZIP_ERROR_TEXT=File not downloaded for some unknown reason: %downloaded_file%
		set RET=4
		goto :EXIT-FUNC-UTILS-INSTALL-ZIP
	)
	
	REM Rename the expected extraction directory if it already exists.
	if exist %expected_zip_extraction_dir% (
		if defined TRACE %TRACE% [proc :FUNC-UTILS-INSTALL-ZIP Extraction dir already exists: %expected_zip_extraction_dir%]
		
		REM Rename the existing extraction directory to <dirname>.old.
		call :FUNC-UTILS-BUILD-DATE-TIME-STRING
		set datestamp=!RET!
		if "!datestamp!"=="" (
			set FUNC-UTILS-INSTALL-ZIP_ERROR_TEXT=Failed to rename old extraction dir.
			set RET=5
			goto :EXIT-FUNC-UTILS-INSTALL-ZIP
		)
		set renamed_dir=!expected_zip_extraction_dir!_!datestamp!
		if defined TRACE %TRACE% [proc :FUNC-UTILS-INSTALL-ZIP renamed_dir=!renamed_dir!]
		move !expected_zip_extraction_dir! !renamed_dir!
		if not exist !renamed_dir! (
			set FUNC-UTILS-INSTALL-ZIP_ERROR_TEXT=Failed to rename dir !expected_zip_extraction_dir! to !renamed_dir!
			set RET=6
			goto :EXIT-FUNC-UTILS-INSTALL-ZIP
		)
	)
	
	REM Extract the zip file.
	call :FUNC-UTILS-EXTRACT-ZIP %downloaded_file% %extract_to_dir%
	if not %RET% == 0 (
		set FUNC-UTILS-INSTALL-ZIP_ERROR_TEXT=%FUNC-UTILS-EXTRACT-ZIP_ERROR_TEXT%
		set RET=7
		goto :EXIT-FUNC-UTILS-INSTALL-ZIP
	)
	
	REM Final check that the extracted directory now exists.
	if not exist %expected_zip_extraction_dir% (
		set FUNC-UTILS-INSTALL-ZIP_ERROR_TEXT=Expected extraction directory not present.
		set RET=8
		goto :EXIT-FUNC-UTILS-INSTALL-ZIP
	)
	
	:EXIT-FUNC-UTILS-INSTALL-ZIP
	if defined TRACE %TRACE% [proc :FUNC-UTILS-INSTALL-ZIP return {%RET%} {%FUNC-UTILS-INSTALL-ZIP_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-UTILS-INSTALL-ZIP_ERROR_TEXT=%FUNC-UTILS-INSTALL-ZIP_ERROR_TEXT%
	goto :eof	
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-UTILS-BUILD-DATE-TIME-STRING
REM
REM Returns: The string <DDMMYYYY-HHMMSS>.
REM
:FUNC-UTILS-BUILD-DATE-TIME-STRING
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-UTILS-BUILD-DATE-TIME-STRING]
	
	REM Date example: 23/06/2018
	for /f "tokens=1-5 delims=/ " %%d in ("%date%") do set date_string=%%d%%e%%f
	set date_string=%date_string: =%
	REM Time example: 21:17:37.53
	for /f "tokens=1-5 delims=:." %%d in ("%time%") do set time_string=%%d%%e%%f
	set time_string=%time_string: =%
	set RET=%date_string%%time_string%
	
	if defined TRACE %TRACE% [proc :FUNC-UTILS-BUILD-DATE-TIME-STRING return {%RET%}]
	endlocal & set RET=%RET%
	goto :eof	
	
	
REM ///////////// END OF SCRIPT ///////////////
