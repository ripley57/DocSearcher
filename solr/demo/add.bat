@echo off

REM Description: 
REM		Add several test documents to our Solr index using an input XML file.
REM
REM		Note: Here we have pre-extracted the textual content (into the "text_t" field).
REM		Instead we can get Solr to do the text extraction, using "Solr Cell", which is 
REM		what we do when we use ManifoldCF to crawl our source documents.
REM
REM		Note: if you look at the field names in the accompanying xml file, you will see
REM		that these are Solr "Dynamic fields", due to the field name post-fixes.  
REM		Dynamic fields are handy because they mean we do not need to explicitly define
REM		our document fields in schema.xml.
REM
REM		See page 142 of SolrInAction: Listing 5.13 Commands to index the example tweets in Solr.
REM		See page 147 of SolrInAction: Table 5.7 Overview of common requests processed by the update handler.
REM		Note: Examples in SolrInAction also include JSON and Java, in addition to XML.
REM
REM 	Note: To remove an existing Solr index:
REM		1) Stop Solr (using Ctrl+C).
REM		2) cd example\solr\collection1\data\
REM		3) rd /s .
REM		4) cd example
REM		5) java -jar start.jar

REM Console window settings.
title Solr demo add.bat
mode 80,25
color 17

set pwd=%~dp0
set core=%1

REM Note: To target a specific index (aka "core"), e.g. the "ufo" core:
REM java -Durl=http://localhost:8983/solr/ufo/update -jar post.jar add.xml
java -Durl=http://localhost:8983/solr/%core%/update -jar %pwd%post.jar %pwd%add.xml
