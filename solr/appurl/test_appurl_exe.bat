@echo off

set pwd=%~dp0

set appurl_url=appurl://%pwd%README.txt
set file_url=file://%pwd%README.txt

REM Replace and '\' chars with '/'.
set appurl_url=%appurl_url:\=/%
set file_url=%file_url:\=/%

REM This will launch the native app for this text file and open it.
REM .\appurl.exe "appurl://%pwd%/README.txt"

REM This is missing the input argument, so it will pop-up an error message.
REM .\appurl.exe

REM Test the "appurl://" protocol entry in the Windows Registry.
REM Generate a test.html file to test this.
echo Generating test.html to test the appurl:// protocol...

echo ^<html^>^<head^>^<title^>appurl protocol test^</title^>^</head^> > test.html
echo ^<p^>Click this link and it should open the file if everything is working (remember to first run install_appurl.bat):^</p^> >> test.html
echo ^<a href="%appurl_url%"^>%appurl_url%^</a^>^<br/^> >> test.html
echo ^<p^>Here's the same link using the classic file:/ protocol:^</p^> >> test.html
echo ^<a href="%file_url%"^>%file_url%^</a^>^<br/^> >> test.html
echo ^<p^>^<b^>Note:^</b^> The purpose of the appurl:// protocol is that a file:// url will not open if the web page was returned by a web server. This is for security reasons. However, with our own protol (appurl://) we can workaround this restriction. Both of the links above will work, but the file:// url will not work if this web page is orignating from a web server.^</p^> >> test.html 
echo ^</html^> >> test.html
