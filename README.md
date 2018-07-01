# INTRODUCTION TO DOCSEARCHER
#### DocSearcher is essentially a set of Windows batch scripts for downloading and managing installations of Solr and ManifoldCF. The intention is to quickly provide an environment capable of indexing the contents of local filesystem directories, so they can be keyword-searched. The idea for DocSearcher came from my frustration at wasting time searching my thousands of technical documents and emails. Although I try to keep my documents in logically-grouped directories, even this approach starts to fall apart as the number of documents grows. Windows does have its own built-in search functionality, but it simply cannot match the power and the features of Solr. ManifoldCF is the under-appreciated missing piece; it is the "crawler" that recurses through the filesystem directories and sends the documents to Solr to be indexed. 

#### With Solr and ManifoldCF being written in Java and hence platform agnostic, you might wonder why I didn't use a cross-platform language such as Java or Python, rather than using horrible old-style Windows batch scripts. My reason was simply that I wanted to see how difficult it would be to implement production-level code using Windows batch scripts.  

# INSTALLING DOCSEARCHER
#### The quickest way to install DocSearcher is to copy [download_docsearcher.bat](https://github.com/ripley57/DocSearcher/raw/master/download_docsearcher.bat) to your PC and run it. This script includes an embedded Java-based Git client, which will automatically download the DocSearcher Github repository. You will therefore need to have Java installed in order to use this installation method. 

# RUNNING DOCSEARCHER
#### After the DocSearcher github repository has been downloaded, simply run Menu.bat. Using this menu your first action will be to install the versions of Solr, ManifoldCF and Java that DocSearcher needs. These are all installed into sub-directories of the current directory. To keep the DocSearcher github repository as small as possible, I didn't want to include copies of Solr and ManifoldCF, so instead I made it as simple as possible to download and install them. 

#### With Java and Solr installed, you can use Menu.bat to start-up Solr, create a Solr core, and inject some sample data into it. You can then perform searches of the core. After you get bored playing with the same data, and you want to start indexing your own filesystem directories, this is when you need to start-up ManifoldCF, to configure a "Repository Connection" (the filesystem directory), an "Output Connection" (Solr), and a ManifolfCF "Job" that combines the two.

# DOCSEARCHER DEMONSTRATION VIDEOS
#### TBD