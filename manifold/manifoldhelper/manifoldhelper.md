# Manifold Helper  

## Proposal  
Given a list of one or more file system directories to index, automate the creation of the ManifoldCF repository connector, the ManifoldCF output connector and the ManifoldCF Job. We'll keep things simple to start with, and assume that a separate ManifoldCF Job will be created for each file system directory.

## Design ideas brainstorm  
* Create a program input argument parser. A separate class should make unit testing easier, and should also increase reusability 
in future Java projects.  

* Create a language parser and define a simple metadata language to drive the application, e.g.
"CREATE MANIFOLD JOB ...". This should make unit testing easier, should make the program usage clearer, and we can easily add new commands 
later, such as "UPDATE MANIFOLD JOB ...", etc. Investigate the use of JavaCC for the language parsing (see https://javacc.org/).  
What about something like this:  
  CREATE CORE (
    DIRECTORY C:\dir1,
    DIRECTORY C:\dir2,
    DIRECTORY C:\dir3 LEVEL 1
  );

* The language parser should be able to return the parsed language as XML. I suggest XML because I think this would simplify how we can transform this into JSON (see the next point).
* Transform the XML returned from the language parser into JSON for each of the various Manifold HTTP requests we require (see https://docs.oracle.com/javase/tutorial/jaxp/xslt/transformingXML.html). 
* QUESTION: How should we make these JSON objects available to be executed? Perhaps we should "post" them on a "Blackboard", where a consumer can take or update them. Or maybe a standard queue is sufficient. Might the "Blackboard" approach might be perferable if we later want to "UPDATE" or "ADD" (additional file system paths to) a ManifoldCF Job?
