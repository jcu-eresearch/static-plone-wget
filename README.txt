Wget Downloader Script, specifically for Plone sites

USAGE: ./wget_plone.sh SITE_NAME [username] [password]
When executed with a username and password, the script attempts to authenticate with the site
and obtain a session cookie for access.  When used without login credentials, the site is 
copied anonymously.

IMPORTANT NOTES

   * Don't forget to turn your portal_css entries to "Link".  Without this, Wget won't be able
	 to see your CSS.
   * Disable any portal actions or the like that you don't want shown on your offline site.
	 The script disables all dynamic content (eg login forms, search etc) but you may wish 
     to remove aspects of your pages first before download.  It'll save you time!
   * If you're going after a subdirectory site (eg plone.jcu.edu.au/foobar/) then you need to
     make sure that your home links end with a slash.  You'll need to hack this file (or similar):

     --- plone.app.layout-2.0-py2.6.egg/plone/app/layout/globals/portal.py
     @memoize_contextless
        def navigation_root_url(self):
            rootPath = self.navigation_root_path()
            return self.request.physicalPathToURL(rootPath)+'/'

     Specifically, make sure you add the +'/' to the return statement.  This will force all root 
     navigation links to end with a slash, resolving issues with Wget's traversal.


% README.txt, 2010-08-06
% @Last Change: 07-Jän-2005.
% vi: 
% Local Variables:
% End:
