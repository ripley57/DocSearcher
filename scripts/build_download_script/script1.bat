@echo off
java -cp %~n0%~x0 org.eclipse.jgit.pgm.Main clone https://github.com/ripley57/DocSearcher.git
exit /b
