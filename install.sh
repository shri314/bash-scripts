#!/bin/bash

set -e

if [ ! -d ~/.env-scripts ]
then
   ( set -e; cd ~ && rm -rf .env-scripts.tmp && git clone https://github.com/shri314/bash-scripts .env-scripts.tmp )

   OLDENV="$HOME/.old-env-scripts"

   mkdir -p ~/.old-env-scripts
   [ -d ~/.bin ] || mkdir -p ~/.bin

   for i in $(ls -A ~/.env-scripts.tmp/)
   do
      if [ "$i" != ".git" ] && [ "$i" != "install.sh" ] && [ "$i" != ".bin" ]
      then
         ( set -e; cd ~ && mv "$i" .old-env-scripts && ln -s .env-scripts/"$i" )
      fi

      if [ "$i" == ".bin" ]
      then
         ( set -e; cd ~/.bin && ln -fs ../.env-scripts/.bin/.readme.txt )
      fi
   done

   mv ~/.env-scripts.tmp ~/.env-scripts
else
   ( set -e; cd ~/.env-scripts && git pull origin master )
fi
