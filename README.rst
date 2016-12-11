Wget Downloader Script
======================

Need to archive a site to static HTML?  Here's a Bash script for
converting your dynamic site (primarily Plone) into a functional,
offline collection of files. Powered by Wget, it slices, dices
and mixes your currently-hosted site into a set of files
that you can either view locally or host on any web server.

Read the `Disclaimer`_ further down this page for a number of 
warnings.

Usage
-----

    ./wget_plone.sh SITE_NAME [username] [password]

When executed with a username and password, the script attempts to
authenticate with the site and obtain a session cookie for access.  When used
without login credentials, the site is copied anonymously.

Requirements
------------

* Recent version of Wget (tested with Wget 1.15)
* Recent version of Bash (tested on 4.3.11 on Ubuntu <= 14.04)
* Plone site to archive (tested on Plone 2.5.x, Plone 3.x, Plone 5.x)

Used with
---------

* Plone 2.5.x, 3.x, 4.x, 5.x
* Joomla 1.5 (authentication not supported)

Important notes
---------------

* Don't forget to turn your portal_css entries to `Link`.  Without this,
  Wget won't be able to see your CSS. (This does not appear to be necessary for 5.X)

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
  the `Reader` role only or the 'static_backup' role described below.
  Wget'ing your site with an Administrative user will have **disastrous**
  consequences!

* Turn off automatic user folder creation to prevent issues with the special
  user's folder.
  
* For Plone 5.X the best approach to get the whole site is to create a new 
  role at the site root called something like 'static_backup'. Then assign
  the following permissions to the role.
  
  * Make sure that 'aquire permission settings' is unchecked for the following
    permissions: Add portal member; Content rules: Manage rules; Copy or Move;
    Delete own comments; Reply to item; Set own password; Set own properties;
    Use external editor; plone.resource: Export ZIP file; 
    plone.resourceeditor: Manage Sources. Be aware that if you uncheck any of
    these it may change the access people on your site have. Make sure that at
    least the Manager and SiteAdministrator have these permissions checked
    beneath their roles. Ideally, these changes should not cause problems. If
    they do they will have to be reset after using this script.
    
  * The following permissions should be checked for the 'static_backup' role:
    ATContentTypes: View history; Access contents information;
    CMFEditions: Access previous versions; List folder contents; View;
    View History. Then create a user with only this role. This user will be
    able to see everything on the site, but not do anything to the site. This
    is the one to have the script log in as.
    
  * If you have any custom workflows, make sure that the 'static_backup' role
    has all the permissions listed previously in all states.

* If you've got user folders you want to grab, remove `index_html` from the
  Members folder by using the ZMI.  This takes out the `special` view the
  Members folder has and lets you pick a normal layout for link spidering.
  (This does not appear necessary in 5.X).

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

Disclaimer
----------

This script can potentially be **very** damaging if used incorrectly. This
script uses recursive ``wget``, which means it will spider every link it
finds.  This will be fine for anonymous users and public views of sites.
However, given Plone offers content and administrative controls for logged-in
users, hitting every link will likely move/rename/delete content, change site
settings, and, in general, be a **very bad thing**. 

**Recommendation to protect your site**:
Rather than do the backup from the active site make a complete duplicate of
the Plone folder (usually called 'Plone' by default) but with a different name
at the same level in the directory structure (this makes all relative links 
work). Edit the buildout.cfg to change the port to some local port that is not
being used. Run ``./bin/buildout`` to set the new port. Start the copy of the site
in foreground mode so that you can see any problems: ``./bin/plonectl fg``. Use
a local web browser to access the site at ``localhost:XXXX/SiteName``, where XXXX
is the port number and check that login of the user you are going to use
for backup works. Now you can run ``./wget_plone.sh SITE_NAME [username] [password]``.

If you do want an internal view of a Plone instance, then create a Reader or
static_backup account and use this. If you use a Reader account you will want to 
check that someone with Reader access doesn't get some extra permissions if you've
customised things like your workflow's security.

This tool is designed for Plone so it may or may not work with other types
of sites.

In any case, absolutely no warranty is given for its suitability.
