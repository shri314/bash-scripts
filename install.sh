#!/bin/bash

CDPATH=

set -e

unset GIT_SSH
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
      \git clone https://github.com/shri314/bash-scripts .env-scripts.tmp
      cd .env-scripts.tmp
      \git config user.name 'Shriram V'
      \git config user.email 'shri314@yahoo.com'
   )

   [ -d ~/.old-env-scripts ] && mv ~/.old-env-scripts ~/.old-env-scripts.$(date +%s)
   mkdir -p ~/.old-env-scripts
   mv ~/.env-scripts.tmp ~/.env-scripts
else
   ( set -e; cd ~/.env-scripts && \git pull --ff-only origin master )
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

[ -L ~/.git-completion.bash ] && rm -f ~/.git-completion.bash
[ -L ~/.git-prompt.sh       ] && rm -f ~/.git-prompt.sh
[ -L ~/.install.sh          ] && rm -f ~/.install.sh
[ -L ~/.misc                ] && rm -f ~/.misc
[ -L ~/.readme.txt          ] && rm -f ~/.readme.txt
[ -L ~/.bin/.readme.txt     ] && rm -f ~/.bin/.readme.txt

put_item Scripts
put_item bash_logout
put_item bash_profile
put_item bashrc
put_item gdbinit
put_item gitconfig
put_item gitconfig.extra
put_item grp.conf.template
put_item handle_screen
put_item handle_ssh
put_item screenrc
put_item tmux.conf
put_item vim
put_item vimrc

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

# put the ~/.bin folder
if [ ! -d ~/.bin ]
then
   [ -e ~/.bin ] && rm -f ~/.bin
   mkdir -p ~/.bin
   echo "Put your private scripts here" > ~/.bin/readme.txt
fi

# set version - we plan to use this for upgrades
if [ ! -f ~/.version-env-scripts ]
then
   (set -e; cd ~/.env-scripts && \git log -n1 --pretty=%H) > ~/.version-env-scripts
fi

cat <<EOM

  ***********************************
   Installed/Updated into ~/.env-scripts!

   For updates run: ~/.env-scripts/install.sh

   You might have to relogin for new settings to take effect.
   You can now delete the bash-scripts directory.
  ***********************************
EOM
