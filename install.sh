#!/bin/bash

CDPATH=

set -e

if [ ! -d ~/.env-scripts ]
then
   (
      set -e;
      cd ~
      rm -rf .env-scripts.tmp
      git clone https://github.com/shri314/bash-scripts .env-scripts.tmp
      cd .env-scripts.tmp
      git config user.name 'Shriram V'
      git config user.email 'shri314@yahoo.com'
   )

   [ -d ~/.old-env-scripts ] && mv ~/.old-env-scripts ~/.old-env-scripts.$(date +%s)
   mkdir -p ~/.old-env-scripts

   for i in $(ls -A ~/.env-scripts.tmp/)
   do
      if [ "$i" == ".git" ]
      then
         :
      elif [ "$i" == ".gitignore" ]
      then
         :
      elif [ "$i" == ".bin" ]
      then
         if [ ! -d ~/.bin ]; then mkdir -p ~/.bin; fi
         ( set -e; cd ~/.bin && ln -fs ../.env-scripts/.bin/.readme.txt )
      elif [ "$i" == "readme.txt" ]
      then
         ( set -e; cd ~ && ln -fs .env-scripts/readme.txt .readme.txt )
      elif [ "$i" == "install.sh" ]
      then
         ( set -e; cd ~ && ln -fs .env-scripts/install.sh .install.sh )
      else
         ( set -e; cd ~ && ( if [ -e "$i" -o -h "$i" ]; then mv "$i" .old-env-scripts; fi ) && ln -s .env-scripts/"$i" )
      fi
   done

   mv ~/.env-scripts.tmp ~/.env-scripts && cat <<EOM


  ***********************************
   Installed into ~/.env-scripts!

   For updates: ( cd ~/.env-scripts && git pull origin master )

   You can now delete the bash-scripts directory.
  ***********************************

EOM

else
   ( set -e; cd ~/.env-scripts && git pull origin master )
fi
