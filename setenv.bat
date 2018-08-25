@echo OFF
@if not "%ECHO%"=="" echo %ECHO%

REM Description:
REM   Setup a Java working environment, by setting JAVA_HOME, ANT_HOME 
REM   and updating PATH. Also add local "utils" directory to the path.
REM
REM Usage:
REM   setenv.bat
REM
REM JeremyC 12-08-2018

set pwd=%~dp0

call %pwd%\_docsearch_lib :INIT

set PATH="%DOCSEARCH_UTILS_DIR%";%PATH%

echo.
echo Configured Java environment:
echo ANT_HOME=%ANT_HOME%
echo JAVA_HOME=%JAVA_HOME%
echo.

if not exist "%JAVA_HOME%" (
    echo Installing Java. Please wait...
    call %pwd%\scripts\install.bat java >nul
)

if not exist "%ANT_HOME%" (
    echo Installing Ant. Please wait...
    call %pwd%\scripts\install.bat ant >nul
)
