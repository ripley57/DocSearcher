@echo off
REM Description: 
REM		Delete a document from Solr using XML.
REM		Note: We use the unique document "id" value.

REM Console window settings.
title Solr demo add.bat
mode 80,25
color 17

set pwd=%~dp0
set core=%1

REM Note: To target a specific index (aka "core"), e.g. the "ufo" core:
REM java -Durl=http://localhost:8983/solr/ufo/update -jar post.jar delete.xml
java -Durl=http://localhost:8983/solr/%core%/update -jar %pwd%post.jar %pwd%delete.xml
