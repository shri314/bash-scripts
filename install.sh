#!/bin/bash

unset CDPATH
SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)

set -eu

if [ "${SELF_EXEC:-x}" == "x" ]
then
   cat <<EOM
  ***********************************
   Installing/Updating into ~/.env-scripts!
  ***********************************

EOM
fi

REPO_URL=$(cd "$SCRIPT_PATH" && \git remote -v | awk '{ print $2; exit }')

check_util()
{
   util_name="$1"; shift;

   if [ ! "$(\which $util_name 2>/dev/null)" ]
   then
      echo "$util_name not found - install it first\n" && exit 1;
   fi
}

check_util curl
check_util realpath

if [ ! -d ~/.env-scripts ]
then
   (
      set -e;
      cd ~
      rm -rf .env-scripts.tmp
      \git clone "$REPO_URL" .env-scripts.tmp
      cd .env-scripts.tmp
      \git config user.name 'Shriram V'
      \git config user.email 'shri314@yahoo.com'
   )

   [ -d ~/.old-env-scripts ] && mv ~/.old-env-scripts ~/.old-env-scripts.$(date +%s)
   mkdir -p ~/.old-env-scripts
   mv ~/.env-scripts.tmp ~/.env-scripts
else
   if [ "${SELF_EXEC:-x}" == "x" ]
   then
      ( set -e; cd ~/.env-scripts && \git pull --ff-only origin master )
   fi
fi

if [ "${SELF_EXEC:-x}" == "x" ]
then
   SELF_EXEC=1 exec "$0" "$@"
else
   :
fi

put_item()
{
   fname="$1"; shift;

   if [ ! -e ~/."$fname" ] || [ ! -L ~/."$fname" ] || [ "$(realpath ~/.$fname)" != "$(realpath ~/.env-scripts/settings/$fname)" ]
   then
      # if ~/.$fname its a directory, move it out of the way
      ( set -e; cd ~ && [ -d ".$fname" ] && mv ".$fname" ".$fname.$(date +%s)"; exit 0 )

      # create a symbolic link inside .env-scripts
      ( set -e; cd ~ && rm -f ".$fname" && ln -v -s -f ".env-scripts/settings/$fname" ".$fname" )
   fi
}

RawGetTool()
{
   local DEST=$1; shift;
   local URL=$1; shift;

   local BN="$(basename "$URL")";
   echo Getting $BN ...

   mkdir -p "$DEST"
   (set -x; curl --silent "$URL" -o "$DEST/$BN") || (E=$?; echo curl failed; exit $E)
}

VimBundle()
{
   local URL="$1"; shift;

   local BASE_NAME="${URL##*/}";
   local NAME="${BASE_NAME%%.git}";

   if [ ! -d ~/.vim/bundle/"$NAME" ]
   then
      echo Getting vim bundle $NAME ...
      (set -x; git clone "$URL" ~/.vim/bundle/"$NAME")
  else
      (cd ~/.vim/bundle/"$NAME" && pwd && git pull --ff-only)
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
put_item handle_display
put_item handle_dot_env
put_item handle_timer
put_item handle_ssh
put_item handle_git
put_item handle_ssh_agt
put_item handle_ps1
put_item screenrc
put_item tmux.conf
put_item vim
put_item vimrc
put_item ideavimrc

# put the ~/.bin folder
if [ ! -d ~/.bin ]
then
   [ -e ~/.bin ] && rm -f ~/.bin
   mkdir -p ~/.bin
   echo "Put your private scripts here" > ~/.bin/readme.txt
fi

# Get external tools
RawGetTool ~/.contrib/bin "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
RawGetTool ~/.contrib/bin "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh"

# BEGIN HACK
# Extra custom patch to revert one change in git-prompt.sh (it behviour changed after this commit - https://github.com/git/git/commit/51d2d677909c031969f82c1c5ef1cc261a9990b3)
cat ~/.contrib/bin/git-prompt.sh | sed -e 's/"|u/" u/' > ~/.contrib/bin/git-prompt-patched.sh
(set +e; diff -u ~/.contrib/bin/git-prompt.sh ~/.contrib/bin/git-prompt-patched.sh; exit 0)
mv -f ~/.contrib/bin/git-prompt-patched.sh ~/.contrib/bin/git-prompt.sh
# END HACK

#RawGetTool ~/.contrib/bin "https://raw.githubusercontent.com/shri314/beautify_bash/master/beautify_bash.py"
#RawGetTool ~/.contrib/bin "https://raw.githubusercontent.com/buzztaiki/tmux-mouse/master/tmux-mouse"
chmod -R +x ~/.contrib/bin/

# Vim Plugins
rm -f ~/.vim/autoload/pathogen.vim
VimBundle https://github.com/VundleVim/Vundle.vim.git
vim +VundleInstall +qa

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
   You can now delete the ~/bash-scripts directory.
  ***********************************
EOM
