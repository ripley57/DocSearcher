@echo OFF
@if not "%ECHO%"=="" echo %ECHO%

REM Description:
REM	  Set Java working command-line environment, 
REM   by setting JAVA_HOME, ANT_HOME and PATH. 
REM
REM Usage:
REM   setenv.bat
REM
REM JeremyC 12-08-2018

set pwd=%~dp0
set SCRIPTNAME=%~nx0
set SCRIPTPATH=%~f0

REM To enable tracing, set DEBUG=1.
if "%DEBUG%"=="1" (set TRACE=echo) else (set TRACE=rem)

call %pwd%\ant\_ant_lib.bat :INIT "%pwd%"
call %pwd%\java\_java_lib.bat :INIT "%pwd%"

echo.
echo Configured Java environment:
echo ANT_HOME=%ANT_HOME%
echo JAVA_HOME=%JAVA_HOME%
rem echo PATH=%PATH%
echo.

REM Install local java if not aready installed.
if not exist "%JAVA_HOME%" (
    echo Installing Java. Please wait...
    call %pwd%\scripts\install.bat java >nul
)

REM Install local ant if not already installed.
if not exist "%ANT_HOME%" (
    echo Installing Ant. Please wait...
    call %pwd%\scripts\install.bat ant >nul
)
echo.
