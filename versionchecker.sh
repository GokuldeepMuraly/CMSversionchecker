#!/bin/bash
#
# KnownHost CMS Version Checking Tool
#
HTTPDROOT=$(httpd -V |grep HTTPD_ROOT |awk '{gsub("-D HTTPD_ROOT=", "");gsub(/"/, "");print}')
HTTPDCONF=$(httpd -V |grep SERVER_CONFIG_FILE |awk '{gsub("-D SERVER_CONFIG_FILE=", "");gsub(/"/, "");print}')
CONFPATH=$(echo $HTTPDROOT/$(echo $HTTPDCONF))
    if [ -d "/etc/httpd/conf/plesk.conf.d/vhosts/" ]; then
            DOCROOTS=$(grep -RPo --no-filename '\/var\/www\/vhosts\/(.*)\/httpdocs' /var/www/vhosts/system/*/conf/ | uniq)
    else
        DOCROOTS=$(grep "DocumentRoot" $CONFPATH |awk '{gsub("    DocumentRoot ", "");print}')
    fi
## Latest versions available check.
WPLATEST=$(curl -sI https://wordpress.org/latest.tar.gz | grep filename| cut -d- -f3 | cut -d. -f1-2)
JLATEST=$(curl -s http://www.joomla.org/download.html |grep -Po "Joomla_(?:\d*\.?\d+\.?\d+)\-Stable\-Full\_Package\.zip" | grep -Po "(?:\d*\.?\d+\.?\d+)" |tr "\n" " ")
DLATEST=$(curl -s https://www.drupal.org/project/drupal | grep -Po "drupal\-(?:\d*\.?\d+\.?\d+).tar.gz" | grep -Po "(?:\d*\.?\d+\.?\d+)" |tr "\n" " ")
echo "Latest WordPress Version: $WPLATEST"
echo "Latest Joomla! Version(s): $JLATEST"
echo "Latest Drupal Version(s): $DLATEST"
echo " "
## Begin Search
echo "Searching for WordPress versions..."
echo " "
  for i in $DOCROOTS
  do
    if [ -d "$i" ]; then
      find $i -type f -iwholename "*/wp-includes/version.php" -exec grep -H "\$wp_version =" {} \;
    fi
  done
echo " "
echo "Searching for Joomla! versions..."
echo " "
  for i in $DOCROOTS
  do
    if [ -d "$i" ]; then
      find $i -type f \( -iwholename '*/libraries/joomla/version.php' -o -iwholename '*/libraries/cms/version.php' -o -iwholename '*/libraries/cms/version/version.php' \) -print0 -exec perl -e 'while
(<>) { $release = $1 if m/ \$RELEASE\s+= .([\d.]+).;/; $dev = $1 if m/ \$DEV_LEVEL\s+= .(\d+).;/; } print qq( = $release.$dev\n);' {} \;
    fi
  done
echo " "
echo "Searching for Drupal versions..."
echo " "
  for i in $DOCROOTS
  do
    if [ -d "$i" ]; then
      find $i -type f -iwholename "*/modules/system/system.info" -exec grep -H "version = \"" {} \;
    fi
  done
echo " "
echo "CMS version search completed."
