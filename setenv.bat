@echo OFF
@if not "%ECHO%"=="" echo %ECHO%

REM Description:
REM   Setup a Java working environment.
REM
REM Usage:
REM   setenv.bat
REM
REM JeremyC 26-08-2018

set pwd=%~dp0

REM This configures all the environment variables.
call %pwd%\_docsearch_lib :INIT

REM Add the local utils dir to PATH.
set PATH="%DOCSEARCH_UTILS_DIR%";%PATH%

if not exist "%JAVA_HOME%" (
    echo Installing Java. Please wait...
    call %pwd%\scripts\install.bat java >nul
)

if not exist "%ANT_HOME%" (
    echo Installing Ant. Please wait...
    call %pwd%\scripts\install.bat ant >nul
)

echo.
echo JAVA_HOME=%JAVA_HOME%
echo ANT_HOME=%ANT_HOME%

echo.
java -version

echo.
ant -version

