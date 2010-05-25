#!/bin/bash

#Give the variable "newname" the value of the first argument
newname=$1

#Settings
##############################################

webroot="/var/www/"					#ex. "/var/www/"
hostsfile="/etc/hosts"				#ex. "/etc/hosts"
apachesites="/etc/apache2/sites-available/"  #ex. "/etc/apache2/sites-available/
sitetemplate="template"             #Name of a site in your sites directory to use as a template

##############################################


#Check that "newname" contains a value.
if [ -z "$newname" ]; then

  echo "Please supply a name for the drupal installation"
  exit 0
  
  else 
  
  #Exit if directory or file already exists with that name.
  if [[ -d "$webroot$newname" || -f "$webroot$newname" ]]; then

    echo "There is already a file or folder with that name" 
    exit 0

  else

    #Use drush to install drupal and rename it to match the choosen name, then install some modules.
    
    drush dl drupal
    mv drupal-6.16 "$webroot$newname"
    cd "$webroot$newname"
    drush dl cck
    drush dl views
    drush dl imagecache
    drush dl imagefield
    drush dl filefield
    drush dl devel
    drush dl admin
    drush dl imageapi
    drush dl token
    drush dl pathauto
  
    #Add a hostname for the new installation at "name.local".

    echo 127.0.0.1 "$newname.local" | sudo tee -a "$hostsfile" > /dev/null

    #Make the necessary modifications in drupal for the installation.
    cd "sites/default"
    cp default.settings.php settings.php
    sudo chown www-data settings.php
    mkdir files 
    sudo chown www-data files

    #Also create the database.
    mysqladmin -h localhost -u root -p create $newname
  
    #Now create a apache virtualhost site file for the Drupal site using a template.
    sed s/$sitetemplate/$newname/g "$apachesites"template | sudo tee /etc/apache2/sites-available/$newname >> /dev/null
  
    #Enable virtualhost site.
    sudo a2ensite $newname
  
    #Reload apache config to make the changes active.
    sudo /etc/init.d/apache2 reload

    #Tadaa! 
    echo "Your'e new drupal installation \"$newname\" has been created" 
  fi
fi
