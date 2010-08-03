#!/bin/bash
# wget_plone.sh -- created 2010-02-25, davidjb.com
# @Last Change: 30-July-2010.
# @Revision:    2.0

#USAGE: ./wget_plone.sh SITE_NAME [username] [password]
#When executed with a username and password, the script attempts to authenticate with the site
#and obtain a session cookie for access.  When used without login credentials, the site is 
#copied anonymously.

#IMPORTANT NOTES
#   * Don't forget to turn your portal_css to "Link" & disable any portal actions or the like
#     that you don't want maintained on/-to your site.
#   * There may be issues with 'sub-directory' sites.  This script is fully successful with 
#     top-level domain sites (eg www.myplonesite.org) but may have issues with sites like
#     www.myplonesite.org/mysite/foo.


cookies_file="cookies-test.txt"
login_file="login_form"

function display_help {
	echo "Usage: wget_plone.sh SITE_NAME [USERNAME] [PASSWORD]"
	echo "When executed with a username and password, the script"
	echo "attempts to authenticate with the site and obtain a session"
	echo "cookie for access.  When used without login credentials, the"
	echo "site is copied anonymously."
	exit 0
}

function cleanup {
        echo "Cleaning up files.  Please remain calm."
	if [[ -e "$cookies_file" ]]; then
		rm --verbose "$cookies_file"
	fi

	if [[ -e "$login_file" ]]; then
		rm --verbose "$login_file"
	fi

	exit $1
}

if [[ "$1" == "--help" ]] || [[ -z "$1" ]]; then
	display_help
fi

#Get our Plone site down.
if [[ -n "$2" ]] && [[ -n "$3" ]]; then
        
        wget 	--keep-session-cookies 		\
		--save-cookies "$cookies_file" 	\
		--post-data "__ac_name#USAGE: ./wget_plone.sh SITE_NAME [username] [password]
#When executed with a username and password, the script attempts to authenticate with the site
#and obtain a session cookie for access.  When used without login credentials, the site is 
#copied anonymously.=$2&__ac_password=$3&form.submitted=1&cookies_enabled=1&js_enabled=0" \
		--output-document="$login_file" \
		$1/login_form

	if [[ `cat $cookies_file | wc -l` -lt 5 ]]; then
		echo "Cookie file size too short.  Confirm that you entered the right username and password."
		echo "Aborting wget process..."
		cleanup 1
	fi

	wget 	--load-cookies $cookies_file	\
		--no-parent 			\
		--no-check-certificate 		\
		--html-extension 		\
		--restrict-file-names=windows 	\
		--convert-links 		\
		--recursive			\
		--level=inf 			\
		--page-requisites 		\
		--wait=0 			\
		--quota=inf 			\
		--reject "*_form, RSS, *login*, logged_in, *logout*, logged_out, selectViewTemplate*" 	\
		--exclude-directories="search, author" \
		$1

else
	wget 	--no-parent 			\
		--no-check-certificate 		\
		--html-extension 		\
		--restrict-file-names=windows 	\
		--convert-links 		\
		--recursive			\
		--level=inf 			\
		--page-requisites 		\
		--wait=0 			\
		--quota=inf 			\
		--reject "*_form, RSS, *login*, logged_in, *logout*, logged_out, selectViewTemplate*" 	\
		--exclude-directories="search, author" \
		$1
fi

#Normalise the folder name, removing protocol and any slashes from the end
folder=$1
folder=${folder##http://}
folder=${folder##https://}
folder=${folder%%/}

#Start formatting our actual web address accordingly
escaped_address=${1%%/}

#Escape our site URL for use within the upcoming commands
escaped_address=${escaped_address////\\\/}

#Get and fix up references to images within CSS.
pushd $folder/portal_css/*
images=`grep -R -h -o -P "$escaped_address/?([\w])+\.(png|gif|jpg)" *`
if [[ -n $images ]]; then
    echo ${images} | xargs wget -nc
    find . -name "*.css" -print0 | xargs -0 sed -i "s/$escaped_address\///g"
fi
popd

echo -e "Wget process complete.  Your site should now be \navailable in the $folder directory."
cleanup 0

# vi: 
