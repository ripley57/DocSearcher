# Manifold Helper  

## Proposal:  
#### For a given file system directory to index, automate the generation of the ManifoldCF repository connector, the output connector and the job. 

## Design ideas brainstorming  
* Create a program input argument parser class. A separate class should make unit testing easier, and should also increase reusability 
in future Java projects.
* Create a language parser class and define a simple meta language to drive the application, e.g.
"CREATE MANIFOLD JOB ...". This should make unit testing easier, should make the program usage clear, and we can easily add new commands 
later, such as "DELETE MANIFOLD JOB...", etc.
* The Parser class should return the parsed language as XML.
* Class to transform the XML returned from the parser into to JSON for the various Manifold HTTP requests we require. Maybe useful: https://docs.oracle.com/javase/tutorial/jaxp/xslt/transformingXML.html.
 
