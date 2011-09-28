Wget Downloader Script, specifically for Plone sites
====================================================

Usage
-----

    ./wget_plone.sh SITE_NAME [username] [password]

When executed with a username and password, the script attempts to authenticate
with the site and obtain a session cookie for access.  When used without login
credentials, the site is copied anonymously.

Important notes
---------------

   * Don't forget to turn your portal_css entries to `Link`.  Without this,
     Wget won't be able to see your CSS.

   * Disable any portal actions or the like that you don't want shown on your
     offline site.

     The script disables all dynamic content (eg login forms, search etc) but
     you may wish to remove aspects of your pages first before download.  It'll
     save you time!

   * Seriously consider whether you need Calendar portlets.  They have custom
     links on any page the portlet is on, so it's wise to disable these where
     possible because if not, you'll downloading for a long time (if not
     forever).

Plone 2.5 or earlier
--------------------

   * To get *all* the content in a Plone 2.5 site, you'll need to enable the
     `Contents` tab for folders.  Head to the ZMI -> portal_actions -> turn
     `Contents` visible.  The tab will now appear like it does in Plone 3 and
     above.

About logged in views of sites
------------------------------

   * If using with a username and password, create a special user account with
     the `Reader` role only.  Wget'ing your site with an Administrative user
     will have **disasterous** consequences!

   * Turn off automatic user folder creation to prevent issues with the special
     user's folder.

   * If you've got user folders you want to grab, remove `index_html` from the
     Members folder by using the ZMI.  This takes out the `special` view the
     Members folder has and lets you pick a normal layout for link spidering.

About subdirectory sites
------------------------

   * If you're going after a **subdirectory** site (eg
     plone.example.org/foobar/) then you need to make sure that your home links
     end with a slash.  You'll need to hack this file (or similar):: 

         --- plone.app.layout-2.0-py2.6.egg/plone/app/layout/globals/portal.py
         @memoize_contextless def navigation_root_url(self): rootPath =
         self.navigation_root_path() return
         self.request.physicalPathToURL(rootPath)+'/'

     Specifically, make sure you add the +'/' to the return statement.  This
     will force all root navigation links to end with a slash, resolving issues
     with Wget's traversal.

     For Plone 2.5 or earlier, you'll need to modify
     `Products/CMFPlone/browser/plone.py` and find the `navigationRootUrl`
     method.  Add the same +'/' to the end of the return statement.  You'll
     also need to modify the other parts of Plone too if they don't use this 
     method.  These currently include:
         
         * `/portal_skins/plone_portlets/portlet_navigation/manage_main`
           Change `href root/absolute_url;` to `href string:${root/absolute_url}/;`

