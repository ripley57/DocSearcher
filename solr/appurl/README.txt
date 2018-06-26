appurl.exe
==========

Run the install batch script to update the Windows Registry so that "appurl://" urls cause appurl.exe to be called. appurl.exe is used by my Solr-based docsearch app, to enable me launch the native application associated with a "file://" link by simply clicking the link. There is a corresponding edit required to Solr file richtext_doc.vm, so that "file://" links are replaced with "appurl://"(see the documents in CW_Tools/tools/solr/).

JeremyC 11-6-2018
