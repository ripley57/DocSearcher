Introduction
============
This directory includes an Eclipse project "DocSearcher" to build the executable jar file docsearcher.jar. The purpose of docsearcher.jar to automate the creation of connectors and jobs in Manifold-CF. 

For example, to create a Repository Connector:
java -jar docsearcher -repository "name=repo1|type=filesystem"


Eclipse version must be Luna or newer
=====================================
Eclipse version Luna (or later) must be used. This is because the code includes some Java 8 features (lambdas), and Eclipse version Juno (and earlier) does not have a Java language 1.8 option.


Importing the project into Eclipse
==================================
Method 1: 
Launch Eclipse from the command-line, pointing to the parent directory of folder "DocSearcher", e.g.: 
eclipse.exe -data d:\DocSearcher\manifold\Eclipse

Method 2:
"File > Import > General > Existing Projects into Workspace" and open the parent directory of folder "DocSearcher".


Pointing Eclipse to a JDK instead of JRE
========================================
Eclipse has an annoying habit of using the JRE instead of a JDK. If this is the case, you will see an error such as "Unable to find a javac compiler". The simplest solution, is to use "Windows > Prefences > Java > Installed JREs > Add..." and point to your desired JDK, e.g. "C:\jdk-8u181-windows-x64". This configuration change has already been applied in this project. If you need to change this again, see the following: https://www.gamefromscratch.com/post/2011/11/15/Telling-Eclipse-to-use-the-JDK-instead-of-JRE.aspx


Building and running the project using Ant build.xml
====================================================
The Eclipse project is built using a custom Ant build.xml file. This means that the project (and tests) can be run from either inside or outside of Eclipse. Here are the Ant targets:

ant -p
...
 clean
 compile
 package
 run-demo-help
 run-demo-job-1
 run-demo-job-2
 run-demo-output
 run-demo-repository
 run-demos
 run-tests
Default target: compile

Note: The Ant targets can be easily run from inside Eclipse; open the build.xml file and then use the "Outline" explorer that appears on the right-hand side in the IDE. Right-click on an Ant target and select "Run As".


The project "Run -> Run configurations..."
==========================================
The Eclipse "Run > Run configurations..." do not use the executable jar file docsearcher.jar. I don't believe there is a way to do this from inside Eclipse. This means that the "Main class:" value has to be used, and is set to "docsearcher.core.Main". The test and demo targets in the build.xml file *do* use the executable jar file docsearcher.jar.


JUnit
=====
The project includes JUnit tests. The test source files and main code files have been stored in separate directories: "src/main/java" and "src/test/java" respectively. 

This was confiured as follows: Go to "Properties > Java Build Path", delete the existing "src" entry, and add two new src entries for "src/test/java" and "src/main/java". NOTE: This requires a restart of Eclipse afterwards. And you will also need to manually create the sub-directories to match the package declarations in the source files.


Eclipse Builder "MyBuilder"
===========================
The project includes an Eclipse 'builder' named "MyBuilder". See "Project > Properties > Builders". This hooks into the targets in our custom Ant build.xml file. This means, for example, that the project is automatically rebuilt when a source file change is saved in the IDE.


Log4j
=====
The project includes use of Log4j. The packaging target in the Ant build.xml file copies file "log4j.properties" into the "classes" directory just before the docsearcher.jar file is created.


JeremyC 15-1-2019
