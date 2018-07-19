@echo OFF
@if not "%ECHO%"=="" echo %ECHO%

REM Description:
REM   Run unix2dos.exe on all batch scripts. 
REM   If we don't do this, we get "no such label" errors.
REM
REM Usage:
REM   Run this script without any arguments.
REM
REM JeremyC 27-6-2018

setlocal

set pwd=%~dp0

if exist %pwd%\rununix2dos.marker (goto :end)
echo.
echo Running unix2dos.exe on the batch scripts ...
echo.

set pwd=%~dp0
pushd %pwd%
pushd .. 
for /r %%A in (*.bat) do (
	if not %%~nxA == Menu.bat (
		utils\unix2dos.exe %%A >nul 2>&1
	)
)
popd
popd
echo %DATE% %TIME% > %pwd%\rununix2dos.marker

:end
endlocal
