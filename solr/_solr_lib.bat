@echo OFF
@if not "%ECHO%"=="" echo %ECHO%
REM Description:
REM   Library of useful functions related to Solr.
REM
REM JeremyC 20-6-2018 


REM If no arguments display version information and exit.
if "%1"=="" (
	echo Solr Script Library v1.00
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
	REM To enable tracing set DEBUG=1 in the calling script.
	if defined TRACE %TRACE% [proc %*]
	
	set topdir=%1

	set DOCSEARCH_SOLR_VERSION=7.3.1
	set DOCSEARCH_SOLR_PORT_NUMBER=8983
	set DOCSEARCH_SOLR_SERVERNAME=server
	set DOCSEARCH_SOLR_DIR=%topdir%solr
	set DOCSEARCH_SOLR_LIB=%topdir%solr\_solr_lib.bat
	set DOCSEARCH_SOLR_BIN_DIR=%topdir%solr\solr-7.3.1
	set DOCSEARCH_SOLR_SERVER_DIR=%topdir%solr\solr-7.3.1\server
	set DOCSEARCH_SOLR_CONFIGSET_DIR=%topdir%solr\solr-7.3.1\server\solr\configsets
	set DOCSEARCH_SOLR_MY_CONFIGSET_DIR=%topdir%solr\myconfigsets
	set DOCSEARCH_SOLR_LOGS_DIR=%topdir%solr\solr-7.3.1\server\logs
	
	
	REM Download Solr from here.
	set DOCSEARCH_SOLR_DOWNLOAD_ZIP_URL=https://archive.apache.org/dist/lucene/solr/7.3.1/solr-7.3.1.zip
	set DOCSEARCH_SOLR_DOWNLOAD_ZIP_FILENAME=solr-7.3.1.zip

	REM Keep downloads here.
	set DOCSEARCH_SOLR_DOWNLOAD_TEMP_DIR=C:\TEMP
	
	REM Extract the Solr zip in this directory.
	set DOCSEARCH_SOLR_DOWNLOAD_EXTRACT_TO_DIR=%DOCSEARCH_SOLR_DIR%
	
	REM This is the directory we expect to see after extraction.
	set DOCSEARCH_SOLR_DOWNLOAD_ZIP_DIRNAME=%DOCSEARCH_SOLR_DOWNLOAD_EXTRACT_TO_DIR%\solr-7.3.1
	
	
	if defined TRACE %TRACE% [proc %* return]
	goto :eof

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-SOLR-RESTART
REM Restart Solr.
REM
REM Returns: 0 if started successfully; otherwise >0
REM
:FUNC-SOLR-RESTART
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-SOLR-RESTART]
		
	set pwd=%~dp0
	set FUNC-SOLR-RESTART_ERROR_TEXT=
	set RET=1
	
	REM Restart Solr.
	cmd /C %DOCSEARCH_SOLR_BIN_DIR%\bin\solr.cmd restart -p %DOCSEARCH_SOLR_PORT_NUMBER%
	
	REM Assume Solr restarted successfully.
	set RET=0
	
	:EXIT-FUNC-SOLR-RESTART
	if defined TRACE %TRACE% [proc :FUNC-SOLR-RESTART return {%RET%} {%FUNC-SOLR-RESTART_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-SOLR-RESTART_ERROR_TEXT=%FUNC-SOLR-RESTART_ERROR_TEXT%
	goto :eof	

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-SOLR-START
REM Start Solr.
REM
REM Returns: 0 if started successfully; otherwise >0
REM
:FUNC-SOLR-START
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-SOLR-START]
		
	set pwd=%~dp0
	set FUNC-SOLR-START_ERROR_TEXT=
	set RET=1
	
	REM Start Solr.
	cmd /C %DOCSEARCH_SOLR_BIN_DIR%\bin\solr.cmd start
	
	REM Assume Solr started successfully.
	set RET=0
	
	:EXIT-FUNC-SOLR-START
	if defined TRACE %TRACE% [proc :FUNC-SOLR-START return {%RET%} {%FUNC-SOLR-START_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-SOLR-START_ERROR_TEXT=%FUNC-SOLR-START_ERROR_TEXT%
	goto :eof	

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-SOLR-STOP
REM Stop Solr.
REM
REM Returns: 0 if stopped successfully; otherwise >0
REM
:FUNC-SOLR-STOP
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-SOLR-STOP]

	set pwd=%~dp0
	set FUNC-SOLR-STOP_ERROR_TEXT=
	set RET=1
	
	REM Stop Solr.
	cmd /C %DOCSEARCH_SOLR_BIN_DIR%\bin\solr.cmd stop -all
	
	REM Assume Solr stopped successfully.
	set RET=0
	
	:EXIT-FUNC-SOLR-STOP
	if defined TRACE %TRACE% [proc :FUNC-SOLR-STOP return {%RET%} {%FUNC-SOLR-STOP_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-SOLR-STOP_ERROR_TEXT=%FUNC-SOLR-STOP_ERROR_TEXT%
	goto :eof


REM ////////////////////////////////////////////////////////////////////
REM FUNC-SOLR-CREATE-CORE
REM Create a new Solr Core.
REM
REM Returns: 0 if created successfully; otherwise >0
REM
:FUNC-SOLR-CREATE-CORE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-SOLR-CREATE-CORE]
	set pwd=%~dp0
	set core=%1
	set configset=%2
	set FUNC-SOLR-CREATE-CORE_ERROR_TEXT=
	set RET=1

	REM Check input args.
	if "%core%"=="" (
		set FUNC-SOLR-CREATE-CORE_ERROR_TEXT=Bad input args. No core name.
		set RET=2
		goto :EXIT-FUNC-SOLR-CREATE-CORE
	)
	if "%configset%"=="" (
		set FUNC-SOLR-CREATE-CORE_ERROR_TEXT=Bad input args. No configset name.
		set RET=3
		goto :EXIT-FUNC-SOLR-CREATE-CORE
	)
	
	REM If the user specifies a configset that is not a built-in one, then it
	REM must be a "homemade" one, and so we need to unzip it into the Solr 
	REM installation directory, so it is available to the create core command.
	set is_builtin_configset=no
	if "%configset%"=="_default"					(set is_builtin_configset=yes)
	if "%configset%"=="sample_techproducts_configs" (set is_builtin_configset=yes)
	if "%is_builtin_configset%"=="no" (
		REM Check if the chosen configset directory already exists in the Solr 
		REM configsets directory. If it's not there, and it's one of our ownhomemade
		REM homemade ones, extract our homemade configset zip to the Solr configsets dir.
		set configset_my_filepath=%DOCSEARCH_SOLR_MY_CONFIGSET_DIR%\%configset%.zip
		set configset_solr_dirpath=%DOCSEARCH_SOLR_CONFIGSET_DIR%\%configset%
		if not exist !configset_solr_dirpath! (
			if not exist !configset_my_filepath! (
				set FUNC-SOLR-CREATE-CORE_ERROR_TEXT=Cannot find homemade configset: %configset_my_filepath%
				set RET=4
				goto :EXIT-FUNC-SOLR-CREATE-CORE
			)
			REM Install homemade configset into Solr.
			if defined TRACE %TRACE% [proc :FUNC-SOLR-CREATE-CORE Installing homemade configset !configset_my_filepath! into %DOCSEARCH_SOLR_CONFIGSET_DIR% ...]
			call %DOCSEARCH_UTILS_LIB% :FUNC-UTILS-EXTRACT-ZIP !configset_my_filepath! %DOCSEARCH_SOLR_CONFIGSET_DIR% quiet
			if not !RET! EQU 0 (
				set FUNC-SOLR-CREATE-CORE_ERROR_TEXT=Failed to install homemade configset: !configset_my_filepath!
				set RET=5
				goto :EXIT-FUNC-SOLR-CREATE-CORE
			)
		)
	)
	
	REM Create our new core.
	cmd /C %DOCSEARCH_SOLR_BIN_DIR%\bin\solr.cmd create_core -c %core% -d %configset%
	
	REM Assume Solr Core was craated successfully.
	set RET=0
	
	:EXIT-FUNC-SOLR-CREATE-CORE
	if defined TRACE %TRACE% [proc :FUNC-SOLR-CREATE-CORE return {%RET%} {%FUNC-SOLR-CREATE-CORE_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-SOLR-CREATE-CORE_ERROR_TEXT=%FUNC-SOLR-CREATE-CORE_ERROR_TEXT%
	goto :eof

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-SOLR-DELETE-CORE
REM Delete a Solr Core.
REM
REM Returns: 0 if created successfully; otherwise >0
REM
:FUNC-SOLR-DELETE-CORE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-SOLR-DELETE-CORE]
	
	set pwd=%~dp0
	set core=%1
	set FUNC-SOLR-DELETE-CORE_ERROR_TEXT=
	set RET=1
	
	REM Check input args.
	if "%core%"=="" (
		set FUNC-SOLR-DELETE-CORE_ERROR_TEXT=Bad input args. No core name.
		goto :EXIT-FUNC-SOLR-DELETE-CORE
	)
	
	REM Delete the core.
	cmd /C %DOCSEARCH_SOLR_BIN_DIR%\bin\solr.cmd delete -c %core%
	
	REM Assume Solr Core craated successfully.
	set RET=0
	
	:EXIT-FUNC-SOLR-DELETE-CORE
	if defined TRACE %TRACE% [proc :FUNC-SOLR-DELETE-CORE return {%RET%} {%FUNC-SOLR-DELETE-CORE_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-SOLR-DELETE-CORE_ERROR_TEXT=%FUNC-SOLR-DELETE-CORE_ERROR_TEXT%
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-SOLR-GET-STATE
REM
REM Returns: "RUNNING " or "NOT-RUNNING".
REM
:FUNC-SOLR-GET-STATE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-SOLR-GET-STATE]
	
	set pwd=%~dp0
	set FUNC-SOLR-GET-STATE_ERROR_TEXT=
	set RET=NOT-RUNNING

	netstat -an | find /i "listening" | findstr :8983 >nul && set RET=RUNNING

	if defined TRACE %TRACE% [proc :FUNC-SOLR-GET-STATE return {%RET%} {%FUNC-SOLR-GET-STATE_ERROR_TEXT%}]
	endlocal & set RET=%RET%&set FUNC-SOLR-GET-STATE_ERROR_TEXT=%FUNC-SOLR-GET-STATE_ERROR_TEXT%
	goto :eof


REM ////////////////////////////////////////////////////////////////////
REM FUNC-SOLR-GET-CORE-STATE
REM Indicate if a Solr core is enabled or disabled.
REM
REM Arguments: Core name.
REM Returns: "enabled", "disabled", or "unknown".
REM
:FUNC-SOLR-GET-CORE-STATE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-SOLR-GET-CORE-STATE]

	set pwd=%~dp0
	set core=%1
	set FUNC-GET-SOLR-CORE-STATE_ERROR_TEXT=
	set RET=UNKNOWN
		
	REM Check input args.
	if "%core%"=="" (
		set FUNC-SOLR-GET-CORE-STATE_ERROR_TEXT=Bad input args. No core name.
		goto :EXIT-FUNC-SOLR-GET-CORE-STATE
	)
	
	REM Check that the core exists.
	set core_dirpath=%DOCSEARCH_SOLR_SERVER_DIR%\solr\%core%
	if not exist "%core_dirpath%" (
		set FUNC-SOLR-GET-CORE-STATE_ERROR_TEXT=No such core %core%
		goto :EXIT-FUNC-SOLR-GET-CORE-STATE
	)

	REM Now determine the state of the core.
	set core_solrconfig_path=%DOCSEARCH_SOLR_SERVER_DIR%\solr\%core%\conf
	if exist "%core_solrconfig_path%\solrconfig.xml"        (set RET=ENABLED)
	if exist "%core_solrconfig_path%\solrconfig.xml.hidden" (set RET=DISABLED)

	:EXIT-FUNC-SOLR-GET-CORE-STATE
	if defined TRACE %TRACE% [proc :FUNC-SOLR-GET-CORE-STATE return {%RET%} {%FUNC-SOLR-GET-CORE-STATE_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-SOLR-GET-CORE-STATE_ERROR_TEXT=%FUNC-SOLR-GET-CORE-STATE_ERROR_TEXT%
	goto :eof


REM ////////////////////////////////////////////////////////////////////
REM FUNC-SOLR-SET-CORE-STATE
REM Disable or enable solr core.
REM
REM Arguments: Core name, mode ("enable" or "disable").
REM Returns: 0 for success, or >1 for failure.
REM
:FUNC-SOLR-SET-CORE-STATE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-SOLR-SET-CORE-STATE]

	set pwd=%~dp0
	set core=%1
	set mode=%2
	set FUNC-SOLR-SET-CORE-STATE_ERROR_TEXT=
	set RET=1
	
	REM Check core input arg.
	if "%core%"=="" (
		set FUNC-SOLR-SET-CORE-STATE_ERROR_TEXT=Bad input args. No core name.
		set RET=1
		goto :EXIT-FUNC-SOLR-SET-CORE-STATE
	)
	
	REM Check mode input arg.
	if  "%mode%"=="enable"  (
		REM valid.
	) else if "%mode%"=="disable" (
		REM valid.
	) else (
		set badargs=true
	)
	if defined badargs (
		set FUNC-SOLR-SET-CORE-STATE_ERROR_TEXT=Mode %mode% should be enable or disable
		set RET=2
		goto :EXIT-FUNC-SOLR-SET-CORE-STATE
	)
	
	REM Check that the core exists.
	set core_dirpath=%DOCSEARCH_SOLR_SERVER_DIR%\solr\%core%
	if not exist "%core_dirpath%" (
		set FUNC-SOLR-SET-CORE-STATE_ERROR_TEXT=No such core %core%
		set RET=3
		goto :EXIT-FUNC-SOLR-SET-CORE-STATE
	)
	
	REM Check that solr is not running.
	rem call :FUNC-SOLR-GET-STATE
	rem if "%RET%"=="RUNNING" (
	rem 	set FUNC-SOLR-SET-CORE-STATE_ERROR_TEXT=Solr must not be running
	rem 	set RET=4
	rem 	goto :EXIT-FUNC-SOLR-SET-CORE-STATE
	rem )

	REM Disable or enable the core (by hiding/un-hiding the solrconfig.xml).
	set RET=1
	set core_solrconfig_path=%DOCSEARCH_SOLR_SERVER_DIR%\solr\%core%\conf
	if "%mode%"=="disable" (
		if exist "%core_solrconfig_path%\solrconfig.xml" (
			rename "%core_solrconfig_path%\solrconfig.xml" solrconfig.xml.hidden
			if not exist "%core_solrconfig_path%\solrconfig.xml" (
				REM Successfully disabled.
				set RET=0
				goto :EXIT-FUNC-SOLR-SET-CORE-STATE
			)
		) else (
			REM Core is already disabled.
			set FUNC-SOLR-SET-CORE-STATE_ERROR_TEXT=Core %core% is already disabled
			set RET=5
			goto :EXIT-FUNC-SOLR-SET-CORE-STATE
		)
	) else if "%mode%"=="enable" (
		if exist "%core_solrconfig_path%\solrconfig.xml.hidden" (
			rename "%core_solrconfig_path%\solrconfig.xml.hidden" solrconfig.xml
			if not exist "%core_solrconfig_path%\solrconfig.xml.hidden" (
				REM Successfully enabled.
				set RET=0
				goto :EXIT-FUNC-SOLR-SET-CORE-STATE
			)
		) else (
			REM Core is already enabled.
			set FUNC-SOLR-SET-CORE-STATE_ERROR_TEXT=Core %core% is already enabled
			set RET=5
			goto :EXIT-FUNC-SOLR-SET-CORE-STATE
		)
	)
	
	:EXIT-FUNC-SOLR-SET-CORE-STATE
	if defined TRACE %TRACE% [proc :FUNC-SOLR-SET-CORE-STATE return {%RET%} {%FUNC-SOLR-SET-CORE-STATE_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-SOLR-SET-CORE-STATE_ERROR_TEXT=%FUNC-SOLR-SET-CORE-STATE_ERROR_TEXT%
	goto :eof


REM ////////////////////////////////////////////////////////////////////
REM FUNC-SOLR-RESET-CORE
REM Disable or enable solr core, by hiding/un-hiding the solrconfig.xml file.
REM
REM Arguments: Core name.
REM Returns: 0 for success, or >1 for failure.
REM
:FUNC-SOLR-RESET-CORE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-SOLR-RESET-CORE]

	set pwd=%~dp0
	set core=%2
	set FUNC-SOLR-RESET-CORE_ERROR_TEXT=
	set RET=1
	
	REM Check core input arg.
	if "%core%"=="" (
		set FUNC-SOLR-RESET-CORE_ERROR_TEXT=Bad input args. No core name.
		set RET=1
		goto :EXIT-FUNC-SOLR-RESET-CORE
	)

	REM Check that solr is not running.
	call :FUNC-SOLR-GET-STATE
	if "%RET%"=="RUNNING" (
		set FUNC-SOLR-RESET-CORE_ERROR_TEXT=Solr must not be running
		set RET=2
		goto :EXIT-FUNC-SOLR-RESET-CORE
	)

	REM Before we delete anything, check that we have the original core zip file to restore.
	set core_orig_zip=%DOCSEARCH_SOLR_SERVER_DIR%\solr\%core%.zip
	if not exist "%core_orig_zip%" (
		set FUNC-SOLR-RESET-CORE_ERROR_TEXT=No zip file %core_orig_zip% to restore.
		set RET=3
		goto :EXIT-FUNC-SOLR-RESET-CORE
	)

	REM Delete the core directory.
	set dirpath=%DOCSEARCH_SOLR_SERVER_DIR%\solr\%core%\
	if exist "%dirpath%" (
		if defined TRACE %TRACE% [FUNC-SOLR-RESET-CORE: Deleting directory %dirpath% ... ]
		rd /s /q "%dirpath%" 
		if exist "%dirpath%" (
			set FUNC-SOLR-RESET-CORE_ERROR_TEXT=Error deleting core directory %dirpath%
			set RET=4
			goto :EXIT-FUNC-SOLR-RESET-CORE
		)
	)

	REM Extract our zip containing the original core config and index.
	call %DOCSEARCH_UTILS_LIB% :FUNC-UTILS-EXTRACT-ZIP "%DOCSEARCH_SOLR_SERVER_DIR%\solr\%core%.zip" "%DOCSEARCH_SOLR_SERVER_DIR%\solr"
	if not %RET% EQU 0 (
		set FUNC-SOLR-RESET-CORE_ERROR_TEXT=Error extracting zip file %core%.zip {%FUNC-UTILS-EXTRACT-ZIP_ERROR_TEXT%}
		set RET=5
		goto :EXIT-FUNC-SOLR-RESET-CORE
	)

	REM Successfully reset the core.
	set RET=0

	:EXIT-FUNC-SOLR-RESET-CORE
	if defined TRACE %TRACE% [proc :FUNC-SOLR-RESET-CORE return {%RET%} {%FUNC-SOLR-RESET-CORE_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-SOLR-RESET-CORE_ERROR_TEXT=%FUNC-SOLR-RESET-CORE_ERROR_TEXT%
	goto :eof


REM ////////////////////////////////////////////////////////////////////
REM FUNC-SOLR-CLEAR-CORE-INDEX
REM Remove the index for the specified core.
REM
REM Arguments: Core name.
REM Returns: 0 for success, or >1 for failure.
REM
:FUNC-SOLR-CLEAR-CORE-INDEX
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-SOLR-CLEAR-CORE-INDEX]

	set pwd=%~dp0
	set core=%1
	set FUNC-SOLR-CLEAR-CORE-INDEX_ERROR_TEXT=
	set RET=1
		
	REM Check core input arg.
	if "%core%"=="" (
		set FUNC-SOLR-CLEAR-CORE-INDEX_ERROR_TEXT=Bad input args. No core name.
		set RET=1
		goto :EXIT-FUNC-SOLR-CLEAR-CORE-INDEX
	)

	REM Check that the core exists.
	set core_dirpath=%DOCSEARCH_SOLR_SERVER_DIR%\solr\%core%
	if not exist "%core_dirpath%" (
		set FUNC-SOLR-CLEAR-CORE-INDEX_ERROR_TEXT=No such core %core%
		set RET=2
		goto :EXIT-FUNC-SOLR-CLEAR-CORE-INDEX
	)

	REM Check that solr is not running.
	call :FUNC-SOLR-GET-STATE
	if "%RET%"=="RUNNING" (
		set FUNC-SOLR-CLEAR-CORE-INDEX_ERROR_TEXT=Solr must not be running
		set RET=3
		goto :EXIT-FUNC-SOLR-CLEAR-CORE-INDEX
	)

	REM Delete the core's index directory.
	set dirpath=%DOCSEARCH_SOLR_SERVER_DIR%\solr\%core%\data
	if exist "%dirpath%" (
		if defined TRACE %TRACE% [:FUNC-SOLR-CLEAR-CORE-INDEX Deleting directory %dirpath% ... ]
		rd /s /q "%dirpath%"
		if exist "%dirpath%" (
			set FUNC-SOLR-CLEAR-CORE-INDEX_ERROR_TEXT=Error deleting directory %dirpath%
			set RET=4
			goto :EXIT-FUNC-SOLR-CLEAR-CORE-INDEX
		)
		REM Recreate empty "data" directory.
		mkdir "%dirpath%" 
	)

	REM Successfully cleared the index.
	set RET=0

	:EXIT-FUNC-SOLR-CLEAR-CORE-INDEX
	if defined TRACE %TRACE% [proc :FUNC-SOLR-CLEAR-CORE-INDEX return {%RET%} {%FUNC-SOLR-CLEAR-CORE-INDEX_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-SOLR-CLEAR-CORE-INDEX_ERROR_TEXT=%FUNC-SOLR-CLEAR-CORE-INDEX_ERROR_TEXT%
	goto :eof


REM ////////////////////////////////////////////////////////////////////
REM FUNC-SOLR-INSTALL-APPURL
REM
REM Installs appurl:// protocol support for Solr Solritas search results.
REM Enables us to click "appurl://" document links in the Search results 
REM which will launch the native application.
REM
REM Returns: 0 if installed successfully; otherwise >0
REM
:FUNC-SOLR-INSTALL-APPURL
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-SOLR-INSTALL-APPURL]

	set pwd=%~dp0
	set appurl_path=c:\temp\appurl.exe
	set UNC-SOLR-INSTALL-APPURL_ERROR_TEXT=
	set RET=1

	If exist %appurl_path% (
		REM Nothing to do, already installed.
		set RET=0
		goto :EXIT-FUNC-SOLR-INSTALL-APPURL
	)

	REM Import appurl registry key.
	regedit.exe /s %DOCSEARCH_SOLR_DIR%\appurl\appurl.reg || (
		set FUNC-SOLR-INSTALL-APPURL_ERROR_TEXT=Failed to update registry.
		set RET=1
		goto :EXIT-FUNC-SOLR-INSTALL-APPURL
	)
	
	REM Copy appurl.exe to c:\temp\
	copy %DOCSEARCH_SOLR_DIR%\appurl\appurl.exe c:\temp\ >NUL || (
		set FUNC-SOLR-INSTALL-APPRURL_ERROR_TEXT=Error copying appurl.exe to c:\temp
		set RET=2
		goto :EXIT-FUNC-SOLR-INSTALL-APPURL
	)

	REM Successfully installed.
	set RET=0

	:EXIT-FUNC-SOLR-INSTALL-APPURL
	if defined TRACE %TRACE% [proc :FUNC-SOLR-INSTALL-APPURL return {%RET%} {%FUNC-SOLR-INSTALL-APPURL_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-SOLR-INSTALL-APPURL_ERROR_TEXT=%FUNC-SOLR-INSTALL-APPURL_ERROR_TEXT%
	goto :eof
	

REM ////////////////////////////////////////////////////////////////////
REM FUNC-SOLR-GET-CORE-LIST
REM
REM Returns: Tab-delimited list of the Solr core names.
REM
:FUNC-SOLR-GET-CORE-LIST
	setlocal ENABLEDELAYEDEXPANSION
	if defined TRACE %TRACE% [proc :FUNC-SOLR-GET-CORE-LIST]

	set pwd=%~dp0
	set FUNC-SOLR-GET-CORE-LIST_ERROR_TEXT=
	set RET=

	for /r %DOCSEARCH_SOLR_SERVER_DIR%\solr /d %%B in (*) do (
		if exist %%B\core.properties (
			call :FUNC-SOLR-GET-CORE-LIST-EXTRACT-CORE-NAME %%B
			if not defined RET (
				set RET=!CORE_NAME!
			) else (
				REM Note: this includes a tab character delimiter.
				set RET=!RET!	!CORE_NAME!
			)
		)
	)
	goto :EXIT-FUNC-SOLR-GET-CORE-LIST
	
	REM Given a file path return just the file name component.
	:FUNC-SOLR-GET-CORE-LIST-EXTRACT-CORE-NAME
	setlocal
	set dirpath=%1
	REM If we ever need to remove a trailing \
	rem set dirpath2=%dirpath:~0,-1%
	for %%f in (%dirpath%) do set dirname=%%~nxf
	endlocal & set CORE_NAME=%dirname%
	goto :eof
	
	:EXIT-FUNC-SOLR-GET-CORE-LIST
	if defined TRACE %TRACE% [proc :FUNC-SOLR-GET-CORE-LIST return {%RET%} {%FUNC-SOLR-GET-CORE-LIST_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-SOLR-GET-CORE-LIST_ERROR_TEXT=%FUNC-SOLR-GET-CORE-LIST_ERROR_TEXT%
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-SOLR-GET-MY-CONFIGSET-LIST
REM
REM Returns: Tab-delimited list of the Solr core names.
REM
:FUNC-SOLR-GET-MY-CONFIGSET-LIST
	setlocal ENABLEDELAYEDEXPANSION
	if defined TRACE %TRACE% [proc :FUNC-SOLR-GET-MY-CONFIGSET-LIST]
	set pwd=%~dp0
	set FUNC-SOLR-GET-MY-CONFIGSET-LIST_ERROR_TEXT=
	set RET=

	for %%B in (%DOCSEARCH_SOLR_MY_CONFIGSET_DIR%\*.zip) do (
		call :FUNC-SOLR-GET-MY-CONFIGSET-LIST-EXTRACT-CONFIGSET-NAME %%B
		if not defined RET (
			set RET=!CONFIGSET_NAME!
		) else (
			REM Note: this includes a tab character delimiter.
			set RET=!RET!	!CONFIGSET_NAME!
		)
	)
	REM Add the Solr built-in configsets.
	REM Note: There is a tab character between these values.
	set RET=!RET!	_default	sample_techproducts_configs
	goto :EXIT-FUNC-SOLR-GET-MY-CONFIGSET-LIST
	
	REM Given a file path return just the file name component.
	:FUNC-SOLR-GET-MY-CONFIGSET-LIST-EXTRACT-CONFIGSET-NAME
	setlocal
	set dirpath=%1
	REM Get filename component from full path.
	for %%f in (%dirpath%) do set dirname=%%~nxf
	REM Remove (.zip) file extension.
	for %%f in (%dirpath%) do set dirname=%%~nf
	endlocal & set CONFIGSET_NAME=%dirname%
	goto :eof
	
	:EXIT-FUNC-SOLR-GET-MY-CONFIGSET-LIST
	if defined TRACE %TRACE% [proc :FUNC-SOLR-GET-MY-CONFIGSET-LIST return {%RET%} {%FUNC-SOLR-GET-MY-CONFIGSET-LIST_ERROR_TEXT%}]
	endlocal & set RET=%RET%& set FUNC-SOLR-GET-MY-CONFIGSET-LIST_ERROR_TEXT=%FUNC-SOLR-GET-MY-CONFIGSET-LIST_ERROR_TEXT%
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-SOLR-GET-INSTALLED-STATE
REM
REM Returns: INSTALLED if installed; otherwise NOT-INSTALLED.
REM
:FUNC-SOLR-GET-INSTALLED-STATE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-SOLR-GET-INSTALLED-STATE]
	set RET=NOT-INSTALLED
	if exist %DOCSEARCH_SOLR_SERVER_DIR% (set RET=INSTALLED)
	if defined TRACE %TRACE% [proc :FUNC-SOLR-GET-INSTALLED-STATE return {%RET%}]
	endlocal & set RET=%RET%
	goto :eof	
	
	
REM ///////////// END OF SCRIPT ///////////////
