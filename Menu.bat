@echo OFF
@if not "%ECHO%"=="" echo %ECHO%

REM Description:
REM   Menu for using Docsearch. 
REM
REM Usage:
REM   Run this script without any arguments.
REM
REM JeremyC 18-6-2018

REM Set local scope, initialize libraries and then call our MAIN procedure.
setlocal & pushd & set RET=
	set pwd=%~dp0
	set SCRIPTNAME=%~nx0
	set SCRIPTPATH=%~f0
	REM To enable tracing, set DEBUG=1.
	if "%DEBUG%"=="1" (set TRACE=echo) else (set TRACE=rem)
	cmd /c %pwd%\scripts\rununix2dos.bat
	call _docsearch_lib :INIT
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

	REM Console window settings.
	title Personal Document Searcher
	mode 90,45
	color 17

	call %DOCSEARCH_UTILS_LIB% :FUNC-UTILS-GET-IE-PATH
	if not "%RET"=="" (
		set IE_EXE=%RET%
	) else (
		echo ERROR: %FUNC-UTILS-GET-IE-PATH_ERROR_TEXT%
		goto :eof
	)

	call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-INSTALL-APPURL
	if not %RET% EQU 0 (
		echo ERROR: %FUNC-SOLR-INSTALL-APPURL_ERROR_TEXT%
		goto :eof
	)
	 
	call :FUNC-DISPLAY-MAIN-MENU
	
	if defined TRACE %TRACE% [proc :MAIN return]
	endlocal
	goto :eof
	

REM ////////////////////////////////////////////////////////////////////
REM FUNC-DISPLAY-MAIN-MENU
REM
:FUNC-DISPLAY-MAIN-MENU
	setlocal
	if defined TRACE %TRACE% [proc %*]
	
	:MAIN-MENU-START
	cls
	echo.
	echo     DOCUMENT SEARCHER
	echo     =================
	echo     Solr version     : %DOCSEARCH_SOLR_VERSION%
	echo     Manifold version : %DOCSEARCH_MANIFOLD_VERSION%
	echo.

	REM Display warning if Java, Solr, or Manifold is not installed.
	set display_warning=
	call %DOCSEARCH_JAVA_LIB% :FUNC-JAVA-GET-INSTALLED-STATE
	if "%RET%"=="NOT-INSTALLED" (set display_warning=yes&	echo     WARN: Java is not installed ^(use option 6^))
	call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-GET-INSTALLED-STATE
	if "%RET%"=="NOT-INSTALLED" (set display_warning=yes& 	echo     WARN: Solr is not installed ^(use option 6^))
    call %DOCSEARCH_MANIFOLD_LIB% :FUNC-MANIFOLD-GET-INSTALLED-STATE
	if "%RET%"=="NOT-INSTALLED" (set display_warning=yes&	echo     WARN: Manifold is not installed ^(use option 6^))
	if defined display_warning (echo.)
	
	REM Indicate if solr is running.
	call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-GET-STATE
	set solr_status=%RET%
	echo     Solr status: %solr_status%
	echo.	
	
	echo     1.  Perform a Search
	echo     --------------------------------------
	echo     2.  Start Solr
	echo     --------------------------------------
	echo     3.  Stop Solr
	echo     --------------------------------------
	echo     4.  Manage Solr
	echo     --------------------------------------
	echo     5.  Manage Manifold
	echo     --------------------------------------
	echo     6.  Installation
	echo     --------------------------------------
	echo     Q.  Quit
	echo     --------------------------------------
	echo.
	
	set choice=
	set /p choice=Please select a number:
	if not '%choice%'=='' set choice=%choice:~0,2%
	if '%choice%'=='1'  (call :FUNC-MENU-SEARCH-CORE	 	& goto :MAIN-MENU-START)
	if '%choice%'=='2'  (call :FUNC-MENU-START-SOLR			& goto :MAIN-MENU-START)
	if '%choice%'=='3'  (call :FUNC-MENU-STOP-SOLR			& goto :MAIN-MENU-START)
	if '%choice%'=='4'  (call :FUNC-MENU-MANAGE-SOLR		& goto :MAIN-MENU-START)
	if '%choice%'=='5'  (call :FUNC-MENU-MANAGE-MANIFOLD	& goto :MAIN-MENU-START)
	if '%choice%'=='6'  (call :FUNC-MENU-INSTALLATION		& goto :MAIN-MENU-START)
	if '%choice%'=='Q'  (goto :EXIT-MAIN-MENU)
	if '%choice%'=='q'  (goto :EXIT-MAIN-MENU)
	if '%choice%'==''	(goto :MAIN-MENU-START)
	echo.
	echo "%choice%" is not valid.  Please try again.
	echo.
	pause
	goto :MAIN-MENU-START
	
	:EXIT-MAIN-MENU
	if defined TRACE %TRACE% [proc :FUNC-DISPLAY-MAIN-MENU return]
	endlocal
	goto :eof
	

REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-MANAGE-SOLR
REM
REM Menu for managing Solr.
REM
:FUNC-MENU-MANAGE-SOLR
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MENU-MANAGE-SOLR]
	
	:MENU-MANAGE-SOLR-START
	cls
	echo.
	echo     MANAGE SOLR
	echo.

	REM Indicate if solr is running.
	call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-GET-STATE
	set solr_status=%RET%
	echo     Solr status: %solr_status%

	echo.
	echo     1.  Start Solr
	echo     -------------------------------------------
	echo     2.  Stop Solr
	echo     -------------------------------------------
	echo     3.  Restart Solr
	echo     -------------------------------------------
	echo     4.  List the Solr cores
	echo     -------------------------------------------
	echo     5.  Create a new Solr core
	echo     -------------------------------------------
	echo     6.  Delete a Solr core
	echo     -------------------------------------------
	echo     7.  Clear Lucene index of a Solr core
	echo     -------------------------------------------
	echo     8.  Create Solr_Demo core with sample docs
	echo     -------------------------------------------
	rem JeremyC 27-06-2018.
	rem I will hide these for now, as I don't think they are going to be used much.
	rem They also cause start-up errors in the Solr log. Note: If I want to reenable
	rem these, first check if there is a bin\solr.cmd option to do the same thing.
	rem echo 9.  Disable a Solr core
	rem echo -------------------------------------------
	rem echo 10. Enable a Solr core
	rem echo  -------------------------------------------
	echo     9.  Import sample docs into a Solr core
	echo     -------------------------------------------
	echo     10. Launch Solr info page
	echo     -------------------------------------------
	echo     11. Tail Solr log
	echo     -------------------------------------------
	echo     Q.  Quit
	echo     -------------------------------------------
	echo.
	
	set choice=
	set /p choice=Please select a number:
	if not '%choice%'=='' set choice=%choice:~0,2%
	if '%choice%'=='1'  (call :FUNC-MENU-START-SOLR						& goto :MENU-MANAGE-SOLR-START)
	if '%choice%'=='2'  (call :FUNC-MENU-STOP-SOLR						& goto :MENU-MANAGE-SOLR-START)
	if '%choice%'=='3'  (call :FUNC-MENU-RESTART-SOLR					& goto :MENU-MANAGE-SOLR-START)
	if '%choice%'=='4'  (call :FUNC-MENU-LIST-CORES 					& goto :MENU-MANAGE-SOLR-START)
	if '%choice%'=='5'  (call :FUNC-MENU-CREATE-CORE					& goto :MENU-MANAGE-SOLR-START)
	if '%choice%'=='6'  (call :FUNC-MENU-DELETE-CORE					& goto :MENU-MANAGE-SOLR-START)
	if '%choice%'=='7'  (call :FUNC-MENU-CLEAR-INDEX					& goto :MENU-MANAGE-SOLR-START)
	if '%choice%'=='8'  (call :FUNC-MENU-CREATE-SOLR-DEMO				& goto :MENU-MANAGE-SOLR-START)
rem if '%choice%'=='9'  (call :FUNC-MENU-DISABLE-CORE					& goto :MENU-MANAGE-SOLR-START)
rem if '%choice%'=='10' (call :FUNC-MENU-ENABLE-CORE					& goto :MENU-MANAGE-SOLR-START)
	if '%choice%'=='9'  (call :FUNC-MENU-IMPORT-TEST-DOCS-INTO-INDEX	& goto :MENU-MANAGE-SOLR-START)
	if '%choice%'=='10' (call :FUNC-MENU-LAUNCH-SOLR-INFO-PAGE			& goto :MENU-MANAGE-SOLR-START)
	if '%choice%'=='11' (call :FUNC-MENU-TAIL-SOLR-LOG					& goto :MENU-MANAGE-SOLR-START)
	if '%choice%'=='Q'  (goto :EXIT-MENU-MANAGE-SOLR)
	if '%choice%'=='q'  (goto :EXIT-MENU-MANAGE-SOLR)
	if '%choice%'==''	(goto :MENU-MANAGE-SOLR-START)
	echo.
	echo "%choice%" is not valid.  Please try again.
	echo.
	pause
	goto :MENU-MANAGE-SOLR-START
	
	:EXIT-MENU-MANAGE-SOLR
	if defined TRACE %TRACE% [proc :FUNC-MENU-MANAGE-SOLR return]
	endlocal
	goto :eof	

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-MANAGE-MANIFOLD
REM
REM Menu for managing Manifold.
rem
:FUNC-MENU-MANAGE-MANIFOLD
	setlocal
	if defined TRACE %TRACE% [proc %*]
	
	:MENU-MANAGE-MANIFOLD-START
	cls
	echo.
	echo     MANAGE MANIFOLD
	echo.
	
	REM Indicate if Manifold is running.
	call %DOCSEARCH_MANIFOLD_LIB% :FUNC-MANIFOLD-GET-STATE
	set manifold_status=%RET%
	echo     Manifold status: %manifold_status%
	
	echo. 
	echo     1.  Start Manifold
	echo     --------------------------------------
	echo     2.  Stop Manifold
	echo     --------------------------------------	
	echo     3.  Manifold UI
	echo     --------------------------------------	
	echo     4.  Manifold useful info page
	echo     --------------------------------------
	echo     Q.  Quit
	echo     --------------------------------------
	echo.
	set choice=
	set /p choice=Please select a number:
	if not '%choice%'=='' set choice=%choice:~0,2%
	echo.
	if '%choice%'=='1'  (call :FUNC-MENU-START-MANIFOLD					& goto :MENU-MANAGE-MANIFOLD-START)
	if '%choice%'=='2'  (call :FUNC-MENU-STOP-MANIFOLD					& goto :MENU-MANAGE-MANIFOLD-START)
	if '%choice%'=='3'  (call :FUNC-MENU-LAUNCH-MANIFOLD-UI				& goto :MENU-MANAGE-MANIFOLD-START)
	if '%choice%'=='4'  (call :FUNC-MENU-LAUNCH-MANIFOLD-INFO-PAGE		& goto :MENU-MANAGE-MANIFOLD-UI)
	if '%choice%'=='Q'  (goto :EXIT-MENU-MANAGE-MANIFOLD)
	if '%choice%'=='q'  (goto :EXIT-MENU-MANAGE-MANIFOLD)
	if '%choice%'==''	(goto :MENU-MANAGE-MANIFOLD-START)
	echo.
	echo "%choice%" is not valid.  Please try again.
	echo.
	pause
	goto :MENU-MANAGE-MANIFOLD-START
	
	:EXIT-MENU-MANAGER-MANIFOLD
	if defined TRACE %TRACE% [proc :FUNC-MENU-MANAGE-MANIFOLD return]
	endlocal
	goto :eof


REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-INSTALLATION
REM
REM Menu for installing/re-installing the 3rd party products.
rem
:FUNC-MENU-INSTALLATION
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MENU-INSTALLATION]

	:MENU-INSTALLATION-START
	cls
	echo.
	echo     INSTALLATION
	echo.
	
	call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-GET-INSTALLED-STATE
	if "%RET%"=="INSTALLED" (
	echo     1.  Re-install Solr %DOCSEARCH_SOLR_VERSION%  ^(%RET%^)
	) else (
	echo     1.  Install Solr %DOCSEARCH_SOLR_VERSION%  ^(%RET%^)
	)
	echo     ---------------------------------------------
	
    call %DOCSEARCH_MANIFOLD_LIB% :FUNC-MANIFOLD-GET-INSTALLED-STATE
	if "%RET%"=="INSTALLED" (
	echo     2.  Re-install Manifold %DOCSEARCH_MANIFOLD_VERSION%  ^(%RET%^)
	) else (
	echo     2.  Install Manifold %DOCSEARCH_MANIFOLD_VERSION%  ^(%RET%^)
	)
	echo     ---------------------------------------------
	
	call %DOCSEARCH_JAVA_LIB% :FUNC-JAVA-GET-INSTALLED-STATE
	if "%RET%"=="INSTALLED" (
	echo     3.  Re-install Java %DOCSEARCH_JAVA_VERSION%  ^(%RET%^)
	) else (
	echo     3.  Install Java %DOCSEARCH_JAVA_VERSION%  ^(%RET%^)
	)
	echo     ---------------------------------------------
	
	call %DOCSEARCH_ANT_LIB% :FUNC-ANT-GET-INSTALLED-STATE
	if "%RET%"=="INSTALLED" (
	echo     4.  Re-install Ant %DOCSEARCH_ANT_VERSION%  ^(%RET%^)
	) else (
	echo     4.  Install Ant %DOCSEARCH_ANT_VERSION%  ^(%RET%^)
	)
	echo     ---------------------------------------------
	
	echo     Q.  Quit
	echo     ---------------------------------------------
	echo.
	set choice=
	set /p choice=Please select a number:
	if not '%choice%'=='' set choice=%choice:~0,2%
	echo.
	if '%choice%'=='1'  (call :FUNC-MENU-INSTALL-SOLR		& goto :MENU-INSTALLATION-START)
	if '%choice%'=='2'  (call :FUNC-MENU-INSTALL-MANIFOLD	& goto :MENU-INSTALLATION-START)
	if '%choice%'=='3'  (call :FUNC-MENU-INSTALL-JAVA		& goto :MENU-INSTALLATION-START)
	if '%choice%'=='4'  (call :FUNC-MENU-INSTALL-ANT		& goto :MENU-INSTALLATION-START)
	if '%choice%'=='Q'  (goto :EXIT-MENU-INSTALLATION)
	if '%choice%'=='q'  (goto :EXIT-MENU-INSTALLATION)
	if '%choice%'==''	(goto :MENU-INSTALLTION-START)
	echo.
	echo "%choice%" is not valid.  Please try again.
	echo.
	pause
	goto :MENU-INSTALLATION-START

	:EXIT-MENU-INSTALLATION
	if defined TRACE %TRACE% [proc :FUNC-MENU-INSTALLATION return]
	endlocal
	goto :eof
	

REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-INSTALL-SOLR
REM
:FUNC-MENU-INSTALL-SOLR
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MENU-INSTALL-SOLR]
	               echo Running %DOCSEARCH_SCRIPTS_DIR%\install.bat solr ...
	start "Install Solr" cmd /k %DOCSEARCH_SCRIPTS_DIR%\install.bat solr
	echo.
	pause
	if defined TRACE %TRACE% [proc :FUNC-MENU-INSTALL-SOLR return]
	endlocal
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-INSTALL-MANIFOLD
REM
:FUNC-MENU-INSTALL-MANIFOLD
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MENU-INSTALL-MANIFOLD
	echo.
	                   echo Running %DOCSEARCH_SCRIPTS_DIR%\install.bat manifold ...
	echo.
	start "Install Manifold" cmd /k %DOCSEARCH_SCRIPTS_DIR%\install.bat manifold
	echo.
	pause
	if defined TRACE %TRACE% [proc :FUNC-MENU-INSTALL-MANIFOLD return]
	endlocal
	goto :eof
	

REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-INSTALL-JAVA
REM
:FUNC-MENU-INSTALL-JAVA
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MENU-INSTALL-JAVA]
	echo.
	               echo Running %DOCSEARCH_SCRIPTS_DIR%\install.bat java ...
	echo.
    start "Install Java" cmd /k %DOCSEARCH_SCRIPTS_DIR%\install.bat java
	echo.
	pause
	if defined TRACE %TRACE% [proc :FFUNC-MENU-INSTALL-JAVA return]
	endlocal
	goto :eof
	

REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-INSTALL-ANT
REM
:FUNC-MENU-INSTALL-ANT
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MENU-INSTALL-ANT]
	echo.
	              echo Running %DOCSEARCH_SCRIPTS_DIR%\install.bat ant ...
	echo.
    start "Install Ant" cmd /k %DOCSEARCH_SCRIPTS_DIR%\install.bat ant
	echo.
	pause
		
	if defined TRACE %TRACE% [proc :FUNC-MENU-INSTALL-ANT return]
	endlocal
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-LIST-MY-CONFIGSETS
REM
REM Display current list of Solr configsets. 
REM Configets contain the Velocity UI config. 
REM If "pick" is passed as the first argument, ask user to select one.
REM This is usually done when creating a new Solr Core.
REM If second argument is passed, used that as a title for the menu.
REM
:FUNC-MENU-LIST-MY-CONFIGSETS
	REM Need to use this for variables referenced in the for and if expressions below.
	setlocal ENABLEDELAYEDEXPANSION
	if defined TRACE %TRACE% [proc :FUNC-MENU-LIST-MY-CONFIGSETS]
	
	set menu_select_mode=%1
	
	:FUNC-MENU-LIST-MY-CONFIGSETS-START
	cls
	echo.

	REM Display Menu title.
	set menu_title=%2
	REM Remove surrounding quotes, if present.
	if defined menu_title (
		set menu_title=!menu_title:"=!
		echo     !menu_title!
	) else (
		echo     HOMEMADE SOLR CONFIGSETS
	)
	
	REM List choice of configsets that we've created ourselves.
	echo.
	call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-GET-MY-CONFIGSET-LIST
	set configset_list=%RET%
	set /a cnt=0
	for %%A in (%configset_list%) do (
		set /a cnt+=1
		
		REM See page 91 of Windows NT scripting book.
		set CONFIGSET_ARRAY_!cnt!_=%%A

		REM Display each core choice.
		echo     !cnt!.  %%A
		echo     --------------------------------------
	)
	
	if "%menu_select_mode%"=="pick" (
		REM User must select a configset, or quit.
		echo     Q.  Quit
		echo     --------------------------------------
		echo.
		set choice=
		set /p choice=Please select a number:
		if not '!choice!'=='' set choice=!choice:~0,2!
		if '!choice!'=='Q'  (set RET=!choice!& goto :EXIT-FUNC-MENU-LIST-MY-CONFIGSETS)
		if '!choice!'=='q'  (set RET=!choice!& goto :EXIT-FUNC-MENU-LIST-MY-CONFIGSETS)
		if '!choice!'==''	(goto :FUNC-MENU-LIST-MY-CONFIGSETS-START)

		REM Determine the selected configset.
		if !choice! LEQ !cnt! (
			REM User selected a valid configset from the list.
			
			rem Debugging: display the array contents.
			rem set CONFIGSET_ARRAY_
			
			REM We need to use a for loop to read a string value from our configset array.
			for /f "delims== tokens=2" %%i in ('set CONFIGSET_ARRAY_!choice!_') do @set configset=%%i
			
			REM Debugging.
			rem echo You chose: !configset!

			set RET=!configset!
			goto :EXIT-FUNC-MENU-LIST-MY-CONFIGSETS
		) 
		
		echo.
		echo "!choice!" is not valid.  Please try again.
		echo.
		pause
		goto :FUNC-MENU-LIST-MY-CONFIGSETS-START
	) else (
		REM Let user view list of configsets then press return.
		set RET=!choice!
		echo.
		pause
	)
	
	:EXIT-FUNC-MENU-LIST-MY-CONFIGSETS
	if defined TRACE %TRACE% [proc :FUNC-MENU-LIST-MY-CONFIGSETS return {%RET%}]
	endlocal & set RET=%RET%
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-LIST-CORES
REM
REM Display current list of Solr cores, including state (ENABLED, DISABLED or UNKNOWN).
REM If "pick" is passed as the first argument, ask the user to select a core.
REM If second argument is passed, used that as the title for the menu.
REM
REM Returns: Selected core (if menu required cores selection). 
REM
:FUNC-MENU-LIST-CORES
	REM Need to use this for variables referenced in the for and if expressions below.
	setlocal ENABLEDELAYEDEXPANSION
	if defined TRACE %TRACE% [proc :FUNC-MENU-LIST-CORES]
	
	set menu_select_mode=%1
	
	:FUNC-MENU-LIST-CORES-START
	cls
	echo.
	
	REM Display Menu title.
	set menu_title=%2
	REM Remove surrounding quotes, if present.
	if defined menu_title (
		set menu_title=!menu_title:"=!
		echo     !menu_title!
	) else (
		echo     SOLR CORES
	)
	
	REM List choice of cores and build a core array to determine the choice later.
	echo.
	call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-GET-CORE-LIST
	set core_list=%RET%
	set /a cnt=0
	for %%A in (%core_list%) do (
		set /a cnt+=1
		
		REM See page 91 of Windows NT scripting book.
		set CORES_ARRAY_!cnt!_=%%A

		REM Get state of the core.
		call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-GET-CORE-STATE %%A
		set core_state=!RET!
		
		REM Display each core choice.
		echo     !cnt!.  %%A ^(!core_state!^)
		echo     --------------------------------------
	)
	
	if %cnt% EQU 0 (
		echo.
		echo     No Cores found.
		echo.
	)
	
	if "%menu_select_mode%"=="pick" (
		REM User must select a core, or quit.
		echo     Q.  Quit
		echo     --------------------------------------
		echo.
		set choice=
		set /p choice=Please select a number:
		if not '!choice!'=='' set choice=!choice:~0,2!
		if '!choice!'=='Q'  (set RET=!choice!& goto :EXIT-FUNC-MENU-LIST-CORES)
		if '!choice!'=='q'  (set RET=!choice!& goto :EXIT-FUNC-MENU-LIST-CORES)
		if '!choice!'==''	(goto :FUNC-MENU-LIST-CORES-START)

		REM Determine the selected core.
		if !choice! LEQ !cnt! (
			REM User selected a valid core from the list.
			
			rem Debugging: display the array contents.
			rem set CORES_ARRAY_
			
			REM We need to use a for loop to read a string value from our cores array.
			for /f "delims== tokens=2" %%i in ('set CORES_ARRAY_!choice!_') do @set core=%%i
			
			REM Debugging.
			rem echo You chose: !core!

			set RET=!core!
			goto :EXIT-FUNC-MENU-LIST-CORES
		) 
		
		echo.
		echo "!choice!" is not valid.  Please try again.
		echo.
		pause
		goto :FUNC-MENU-LIST-CORES-START
	) else (
		REM Let user view list of cores then press return.
		set RET=!choice!
		echo.
		pause
	)
	
	:EXIT-FUNC-MENU-LIST-CORES
	if defined TRACE %TRACE% [proc :FUNC-MENU-LIST-CORES return {%RET%}]
	endlocal & set RET=%RET%
	goto :eof

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-SEARCH-CORE
REM
:FUNC-MENU-SEARCH-CORE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MENU-SEARCH-CORE]
	
	REM Start solr if needed.
	call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-GET-STATE
	if "%RET%"=="NOT-RUNNING" (
		echo.
		echo Starting Solr ...
		echo.
		if defined TRACE %TRACE% [Running call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-START ...]
	                                      call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-START
		echo.
	)
	
	call :FUNC-MENU-LIST-CORES pick "SELECT CORE TO SEARCH"
	set core=%RET%
	if not "%core%"=="q" (
		echo.
		echo Launching Solr web UI ...
		if defined TRACE %TRACE% [Running start %IE_EXE% http://localhost:8983/solr/%core%/browse ...]
			                              start %IE_EXE% http://localhost:8983/solr/%core%/browse 
		echo.
		pause
	)

	:EXIT-FUNC-MENU-SEARCH-CORE
	if defined TRACE %TRACE% [proc :FUNC-MENU-SEARCH-CORE return]
	endlocal
	goto :eof


REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-START-SOLR
REM
:FUNC-MENU-START-SOLR
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MENU-START-SOLR]
	
	echo.
	echo Starting Solr ...
	echo.
	
	if defined TRACE %TRACE% [Running call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-START ...]
	                                  call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-START
	echo.
	if defined TRACE %TRACE% [proc :FUNC-MENU-START-SOLR return]
	pause
	endlocal
	goto :eof

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-STOP-SOLR
REM
:FUNC-MENU-STOP-SOLR
	setlocal
	if defined TRACE %TRACE% [proc FUNC-MENU-STOP-SOLR]
	
	echo.
	echo Stopping Solr ...
	echo.
	
	if defined TRACE %TRACE% [Running call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-STOP ...]
	                                  call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-STOP
	echo.
	if defined TRACE %TRACE% [proc :FUNC-MENU-STOP-SOLR return]
	pause
	endlocal
	goto :eof

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-RESTART-SOLR
REM
:FUNC-MENU-RESTART-SOLR
	setlocal
	if defined TRACE %TRACE% [proc FUNC-MENU-RESTART-SOLR]
	
	echo.
	echo Restarting Solr ...
	echo.	
	
	if defined TRACE %TRACE% [Running call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-RESTART ...]
	                                  call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-RESTART
	echo.
	if defined TRACE %TRACE% [proc :FUNC-MENU-RESTART-SOLR return]
	pause
	endlocal
	goto :eof
	

REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-START-MANIFOLD
REM
:FUNC-MENU-START-MANIFOLD
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MENU-START-MANIFOLD]

	echo.
	echo Starting ManifoldCF ...
	echo.
		
	if defined TRACE %TRACE% [Running call %DOCSEARCH_MANIFOLD_LIB% :FUNC-MANIFOLD-START ...]
                                      call %DOCSEARCH_MANIFOLD_LIB% :FUNC-MANIFOLD-START
	if not %RET% EQU 0 (
		echo ERROR %RET%: %FUNC-MANIFOLD-START_ERROR_TEXT%
	) 
	echo.
	if defined TRACE %TRACE% [proc :FUNC-MENU-START-MANIFOLD return]
	pause
	endlocal
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-STOP-MANIFOLD
REM
:FUNC-MENU-STOP-MANIFOLD
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MENU-STOP-MANIFOLD]
	
	echo.
	echo Stopping ManifoldCF ...
	echo.
	
	if defined TRACE %TRACE% [Running call %DOCSEARCH_MANIFOLD_LIB% :FUNC-MANIFOLD-STOP ...]
                                      call %DOCSEARCH_MANIFOLD_LIB% :FUNC-MANIFOLD-STOP
	if not %RET% EQU 0 (
		echo ERROR %RET%: %FUNC-MANIFOLD-STOP_ERROR_TEXT%
	) 
	echo.
	if defined TRACE %TRACE% [proc :FUNC-MENU-STOP-MANIFOLD return]
	pause
	endlocal
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-LAUNCH-SOLR-INFO-PAGE
REM
:FUNC-MENU-LAUNCH-SOLR-INFO-PAGE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MENU-LAUNCH-SOLR-INFO-PAGE]

	echo.
	echo Launching Solr info web page ...
	echo.
	
	if defined TRACE %TRACE% [Running start %IE_EXE% %DOCSEARCH_SOLR_DIR%\index.html ...]
                                      start %IE_EXE% %DOCSEARCH_SOLR_DIR%\index.html
	if defined TRACE %TRACE% [proc :FUNC-MENU-LAUNCH-SOLR-INFO-PAGE return]
	pause
	endlocal
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-LAUNCH-MANIFOLD-INFO-PAGE
REM
:FUNC-MENU-LAUNCH-MANIFOLD-INFO-PAGE
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MENU-LAUNCH-MANIFOLD-INFO-PAGE]

	echo.
	echo Launching ManifoldCF info web page ...
	echo.
		
	if defined TRACE %TRACE% [Running start %IE_EXE% %DOCSEARCH_MANIFOLD_DIR%\index.html ...]
                                      start %IE_EXE% %DOCSEARCH_MANIFOLD_DIR%\index.html
	if defined TRACE %TRACE% [proc :FUNC-MENU-LAUNCH-MANIFOLD-INFO-PAGE return]
	pause
	endlocal
	goto :eof

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-LAUNCH-MANIFOLD-UI
REM
:FUNC-MENU-LAUNCH-MANIFOLD-UI
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MENU-LAUNCH-MANIFOLD-UI]

	echo.
	echo Launching ManifoldCF UI http://localhost:8345/mcf-crawler-ui ...
	echo.
	
	if defined TRACE %TRACE% [Running start %IE_EXE% http://localhost:8345/mcf-crawler-ui ...]
                                      start %IE_EXE% http://localhost:8345/mcf-crawler-ui
	if defined TRACE %TRACE% [proc :FUNC-MENU-LAUNCH-MANIFOLD-UI return]
	pause
	endlocal
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-CREATE-CORE
REM
:FUNC-MENU-CREATE-CORE
	setlocal ENABLEDELAYEDEXPANSION
	if defined TRACE %TRACE% [proc :FUNC-MENU-CREATE-CORE]
	
	echo.
	set core_name=
	set /p core_name=Enter name for new core, or press return to quit:
	if '%core_name%'=='' (
		goto :EXIT-FUNC-MENU-CREATE-CORE
	)

	REM Enable user to pick one of our homemade configsets.
	call :FUNC-MENU-LIST-MY-CONFIGSETS pick "SELECT A CONFIGSET"
	set configset=%RET%
	if not "%configset%"=="q"  (
		echo.
		echo Create core %core_name% using configset %configset% ...
		echo.
		if defined TRACE %TRACE% [Running call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-CREATE-CORE %core_name% %configset% ...]
	                                      call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-CREATE-CORE %core_name% %configset%
		if not !RET! EQU 0 (
			echo.
			echo %FUNC-SOLR-CREATE-CORE_ERROR_TEXT%
			echo.
		)
		echo.
		pause
	)
		
	:EXIT-FUNC-MENU-CREATE-CORE
	if defined TRACE %TRACE% [proc :FUNC-MENU-CREATE-CORE return]
	endlocal
	goto :eof
		
		
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-CREATE-SOLR-DEMO
REM
:FUNC-MENU-CREATE-SOLR-DEMO
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MENU-CREATE-SOLR-DEMO]	

	REM Create a core named "Solr_Demo", using the "sample_techproducts_configset configset".
	REM This configset includes Velocity templates to use with the docs in "example/exampledocs".
	echo.
	echo Creating a core named Solr_Demo using the demo configset ...
	echo.
	if defined TRACE %TRACE% [Running call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-CREATE-CORE Solr_Demo sample_techproducts_configs ...]
	                                  call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-CREATE-CORE Solr_Demo sample_techproducts_configs
	if not %RET% EQU 0 (
		echo.
		echo %FUNC-SOLR-CREATE-CORE_ERROR_TEXT%
		echo.
		goto :EXIT-FUNC-MENU-CREATE-SOLR-DEMO
	)
	
	REM Import The Solr sample docs.
	echo.
	echo Importing the Solr sample product docs into our Solr_Demo core ...
	echo.
	java  -Durl=http://localhost:8983/solr/Solr_Demo/update -jar %DOCSEARCH_SOLR_BIN_DIR%\example\exampledocs\post.jar  %DOCSEARCH_SOLR_BIN_DIR%\example\exampledocs\*.xml
	
	:EXIT-FUNC-MENU-CREATE-SOLR-DEMO
	if defined TRACE %TRACE% [proc :FUNC-MENU-CREATE-SOLR-DEMO return]
	echo.
	pause
	endlocal
	goto :eof
		
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-CLEAR-INDEX
REM	
:FUNC-MENU-CLEAR-INDEX
	setlocal
	if defined TRACE %TRACE% [proc FUNC-MENU-CLEAR-INDEX]
	
	call :FUNC-MENU-LIST-CORES pick "SELECT CORE INDEX TO CLEAR"
	set core=%RET%
	if "%core%"=="q" (
		goto :EXIT-FUNC-MENU-CLEAR-INDEX
	)
	
	if defined TRACE %TRACE% [Running call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-CLEAR-CORE-INDEX %core% ...]
	                                  call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-CLEAR-CORE-INDEX %core%
	
	if not %RET% EQU 0 (
		echo.
		echo ERROR %RET%: %FUNC-SOLR-CLEAR-CORE-INDEX_ERROR_TEXT%
		echo.	
	) else (
		echo.
		echo Successfully removed index for core %core%
		echo.
	)
		
	:EXIT-FUNC-MENU-CLEAR-INDEX
	if defined TRACE %TRACE% [proc :FUNC-MENU-CLEAR-INDEX return]	
	pause
	endlocal
	goto :eof


REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-DELETE-CORE
REM	
:FUNC-MENU-DELETE-CORE
	setlocal
	if defined TRACE %TRACE% [proc FUNC-MENU-DELETE-CORE]
	
	call :FUNC-MENU-LIST-CORES pick "SELECT CORE TO DELETE"
	set core=%RET%
	if "%core%"=="q" (
		goto :EXIT-FUNC-MENU-DELETE-CORE
	)
	
	if defined TRACE %TRACE% [Running call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-DELETE-CORE %core% ...]
	                                  call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-DELETE-CORE %core%
	
	if not %RET% EQU 0 (
		echo.
		echo ERROR %RET%: %FUNC-SOLR-DELETE-CORE_ERROR_TEXT%
		echo.
	)

	:EXIT-FUNC-MENU-DELETE-CORE
	if defined TRACE %TRACE% [proc :FUNC-MENU-DELETE-CORE return]
	pause	
	endlocal
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-IMPORT-TEST-DOCS-INTO-INDEX
REM	
:FUNC-MENU-IMPORT-TEST-DOCS-INTO-INDEX
	setlocal
	if defined TRACE %TRACE% [proc FUNC-MENU-IMPORT-TEST-DOCS-INTO-INDEX]

	call :FUNC-MENU-LIST-CORES pick "SELECT CORE TO SEND TEST DOCUMENTS TO"
	set core=%RET%
	if not "%core%"=="q" (
		if defined TRACE %TRACE% [Running %DOCSEARCH_SOLR_DIR%\demo\add.bat %core% ...]
                   start "add.bat" cmd /k %DOCSEARCH_SOLR_DIR%\demo\add.bat %core%
		echo.
		pause
	)
	
	if defined TRACE %TRACE% [proc :FUNC-MENU-IMPORT-TEST-DOCS-INTO-INDEX return]
	endlocal
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-DISABLE-CORE
REM	
:FUNC-MENU-DISABLE-CORE
	setlocal ENABLEDELAYEDEXPANSION
	if defined TRACE %TRACE% [proc :FUNC-MENU-DISABLE-CORE]

	call :FUNC-MENU-LIST-CORES pick "SELECT CORE TO DISABLE"
	set core=%RET%
	if not "%core%"=="q" (
		echo.
		if defined TRACE %TRACE% [Running call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-SET-CORE-STATE %core% disable ...]
	                                      call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-SET-CORE-STATE %core% disable
		if not !RET! EQU 0 (
			echo ERROR !RET!: !FUNC-SOLR-SET-CORE-STATE_ERROR_TEXT!
		) else (
			echo Successfully disabled core !core!
			echo You now need to restart Solr.
		)
	)
	
	:EXIT-FUNC-MENU-DISABLE-CORE
	if defined TRACE %TRACE% [proc :FUNC-MENU-DISABLE-CORE return]
	echo.
	pause
	endlocal
	goto :eof
	
	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-ENABLE-CORE
REM	
:FUNC-MENU-ENABLE-CORE
	setlocal ENABLEDELAYEDEXPANSION
	if defined TRACE %TRACE% [proc :FUNC-MENU-DISABLE-CORE]
	
	call :FUNC-MENU-LIST-CORES pick "SELECT CORE TO ENABLE"
	set core=%RET%
	if not "%core%"=="q" (
		echo.
		if defined TRACE %TRACE% [Running call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-SET-CORE-STATE %core% enable ...]
	                                      call %DOCSEARCH_SOLR_LIB% :FUNC-SOLR-SET-CORE-STATE %core% enable
	
		if not !RET! EQU 0 (
			echo ERROR !RET!: !FUNC-SOLR-SET-CORE-STATE_ERROR_TEXT!
		) else (
			echo Successfully enabled core !core!
			echo You now need to restart Solr.
		)
	)
	
	:EXIT-FUNC-MENU-ENABLE-CORE
	if defined TRACE %TRACE% [proc :FUNC-MENU-DISABLE-CORE return]
	echo.
	pause
	endlocal
	goto :eof

	
REM ////////////////////////////////////////////////////////////////////
REM FUNC-MENU-TAIL-SOLR-LOG
REM	
:FUNC-MENU-TAIL-SOLR-LOG
	setlocal
	if defined TRACE %TRACE% [proc :FUNC-MENU-TAIL-SOLR-LOG]
	
	if defined TRACE %TRACE% [Running call %DOCSEARCH_UTILS_LIB% :FUNC-UTILS-TAIL-FILE %DOCSEARCH_SOLR_LOGS_DIR%\solr.log ...]
	                                  call %DOCSEARCH_UTILS_LIB% :FUNC-UTILS-TAIL-FILE %DOCSEARCH_SOLR_LOGS_DIR%\solr.log
	if not %RET% EQU 0 (
		echo.
		echo ERROR: %FUNC-UTILS-TAIL-FILE_ERROR_TEXT%
		echo.
	)
									  
	if defined TRACE %TRACE% [proc :FUNC-MENU-TAIL-SOLR-LOG return]
	echo.
	pause
	endlocal
	goto :eof
	
	
REM ///////////// END OF SCRIPT ///////////////