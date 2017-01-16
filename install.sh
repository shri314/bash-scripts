#!/bin/bash

CDPATH=

set -e

cat <<EOM
  ***********************************
   Installing/Updating into ~/.env-scripts!
  ***********************************

EOM

[ ! "$(\which curl 2>/dev/null)" ] && echo "curl not found - install curl\n" && exit 1;

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
      if [[ "$i" =~ ^[.][a-z] ]]   #only process files beginning with . (this is temp fix)
      then
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
         else
            ( set -e; cd ~ && ( if [ -e "$i" -o -h "$i" ]; then mv "$i" .old-env-scripts; fi ) && ln -s .env-scripts/"$i" )
         fi
      fi
   done

   mv ~/.env-scripts.tmp ~/.env-scripts
else

   ( set -e; cd ~/.env-scripts && git pull origin master )
fi

put_item()
{
   fname="$1"; shift;

   if [ ! -e ~/."$fname" ] || [ ! -L ~/."$fname" ] || [ "$(realpath ~/.$fname)" != "$(realpath ~/.env-scripts/settings/$fname)" ]
   then
      ( set -e; cd ~ && ln -v -s -f -T ".env-scripts/settings/$fname" ".$fname" )
   fi
}

# install/upgrade steps
echo
echo "Setting up links..."

[ -L ~/.install.sh          ] && rm -f ~/.install.sh
[ -L ~/.readme.txt          ] && rm -f ~/.readme.txt
[ -L ~/.git-completion.bash ] && rm -f ~/.git-completion.bash
[ -L ~/.git-prompt.sh       ] && rm -f ~/.git-prompt.sh

put_item bashrc
put_item vim
put_item vimrc
put_item tmux.conf
put_item screenrc

# get external tools
CONTRIBS=(
   "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
   "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh"
   "https://raw.githubusercontent.com/shri314/beautify_bash/dev/beautify_bash.py"
);

for i in "${CONTRIBS[@]}"
do
   BN="$(basename "$i")";
   mkdir -p ~/.contrib/bin
   echo Getting $BN...
   curl --silent "$i" -o ~/.contrib/bin/"$BN"
done

chmod +x ~/.contrib/bin/beautify_bash.py

# set version - we plan to use this for upgrades
if [ ! -f ~/.version-env-scripts ]
then
   (set -e; cd ~/.env-scripts && git log -n1 --pretty=%H) > ~/.version-env-scripts
fi

cat <<EOM

  ***********************************
   Installed/Updated into ~/.env-scripts!

   For updates run: ~/.env-scripts/install.sh

   You might have to relogin for new settings to take effect.
   You can now delete the bash-scripts directory.
  ***********************************
EOM
