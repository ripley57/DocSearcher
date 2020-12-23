Configuring a CIFS share crawl instead of a file system crawl
=============================================================

1. Download jcifs-1.3.3.jar from https://mvnrepository.com/artifact/org.samba.jcifs/jcifs/1.3.3
There is a copy in this directory name "jcifs.jar".

2. Copy jcifs.jar to manifold/apache-manifoldcf-1.9/connector-lib-proprietary/jcifs.jar
(See http://www.francelabs.com/blog/tutorial-for-combining-manifoldcf-and-elasticsearch-for-files-search/)

3. Uncomment the following line in manifold/apache-manifoldcf-1.9/connectors.xml:
<repositoryconnector name="Windows shares" class="org.apache.manifoldcf.crawler.connectors.sharedrive.SharedDriveConnector"/>
I believe this provides the Manifold-CF ui bits, whereas jcifs.jar is the actual functionality.

4. Restart manifold-cf.
There should now be a "Windows shares" repository type listed.

5. Configure Samba file sharing (Linux Mint).
See simply steps here:
https://techviewleo.com/install-and-configure-samba-file-sharing-on-linux-mint/
Note: I didnt change my "[global]" section at all.
There is a copy of my working smb.conf in this directory (working on Linux Mint 19.1).

6. Create a repository using the type "Windows shares". This type should now be listed.
Use the following values:
Sever:			localhost	(I'm running Samba server on the same machine)
Authentication domain:	(blank)
User name:		user1		(See smb.conf)
Password:		user1		(See smb.conf)
Use SIDsfor security:	uncheck

7. Create the manifolc-cf job.
When you go to the "Paths" tab, it will use the repo username/password samba credentials
to list the avaiable shares. Follow these steps:
o Select the "DS" share (see smb.conf). See manifold-sharedrive-job-1.png.
o Select the "DS" share (see smb.conf) and click "+". See manifold-sharedrive-job-2.png.
o Click the "Add" button. Include/Exclude options should now be displayed on the right. See manifold-sharedrive-job-3.png.
o Add Include/Excludes as you would do for a file system crawl. See manifold-sharedrive-job-4.png.
o Click "Save".

8. Create symbolic links on file system in order to open files in browser (Firefox).
Because we are crawling a share, our links in the Solr UI won't be valid file paths, e.g. 
they will look like this example:
file://///localhost/DS/lxf/LXF127/127-full/LXF127.feature1.pdf
To get my browser to successfully access this as a file path, I did the following:
o Created directory "/localhost".
o Created a symlink named "DS":
/localhost/DS -> /home/jcdc/Downloads/tmp/docs
...where the "docs" directory contains the "lxf" directory:
ls /home/jcdc/Downloads/tmp/docs
lxf


FYI:
o That French company using Manifold and Solr:
https://www.datafari.com/en/download.html


JeremyC Dec 2020
