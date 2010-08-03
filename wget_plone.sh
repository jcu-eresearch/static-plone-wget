#!/bin/bash
# wget_plone.sh -- created 2010-02-25, davidjb.com
# @Last Change: 25-Feb-2010.
# @Revision:    1.0

#Don't forget to turn your portal_css to "Link" & disable any portal actions or the like
#that you don't want maintained onto your site.

#Get our Plone site down.
wget --html-extension --restrict-file-names=windows --convert-links --recursive --level=inf --page-requisites --wait=0 --quota=inf --reject="*_form, *@*, RSS" --exclude-directories="search, author" $1

#Normalise the folder name, removing protocol and any slashes
folder=$1
folder=${folder##http://}
folder=${folder##https://}
folder=${folder////}

#Escape our site URL for use within the sed argument
escaped_address=${1/%\//}
escaped_address=${1////\\\/}

#Get and fix up references to images within CSS.
pushd $folder/portal_css/Plone\ Default/
images=`grep -R -h -o -P "$1/?([\w])+\.(png|gif|jpg)" *`
echo ${images} | xargs wget -nc
find . -name "*.css" -print | xargs sed -i "s/$escaped_address\///g"
popd

# vi: 
