#FAQ:

1. What's this all about?

   It's just a bunch of tools and customizations to make tasks easy
   Just to name a few

   .vimrc            # tweaks and settings (better upgrade your vim to the latest)
   .screenrc         # tweaks and settings
   .bashrc           # settings including prompt settings


   Some scripts do not show help. And others are very specific. Others are downright unintelligible or
   obscure. Others have dependencies that need to be setup in a specific way and require some work.

2. How to install the shell-customizations?

   WARN: Installation procedure will replace your initialization files (like .bashrc, .vimrc, etc by one
         provided by bash-scripts). To try it out, you could create a temporary user on your system, and
         install bash-scripts on that.

   Once instllation is done, you will then get these files as your git clone!!
   From then on, you can change the files to your own liking, and also get updates.

   Use the following procedure to install:
   ```
   ( cd ~ && git clone http://www.github.com/shri314/bash-scripts && cd bash-scripts && ./install.sh )
   ```

   Or if you have ssh-key access:
   ```
   ( cd ~ && git clone git@github.com:shri314/bash-scripts.git && cd bash-scripts && ./install.sh )
   ```

   Your old setttings are in "~/.old-env-scripts". You can delete it or reapply your customizations.
   You can remove the bash-scripts directory after installation.

   Use the following procedure to convert to password-less push if you have enabled it:
   ```
   (
      cd ~/.env-scripts &&
         git config user.name 'Shriram V'
         git config user.email 'shri314@yahoo.com'
         git remote set-url origin 'git@github.com:shri314/bash-scripts.git'
   )
   ```

3. How can I try it without getting disripted?

   Create a user on your system, and install shell-customizations on that.
   Also I recommend not to put the shell-customizations for the root user.

4. How do I get updates?

   ```
   ( cd ~/.env-scripts && install.sh )
   ```

5. How do I contribute?

   You could create a fork, and then push changes to your fork, and submit pull requests. Just make sure it
   will be useful for wider audience and follows similar genre, and hopefully have no external dependencies.

6. How can I make it better?

   Overtime things can evolve. We can categorize scrits, and evolve conventions.

7. Consider using latest Vim - for omni autocomplete with Java8 (i.e. C-X C-O)

   (For ubuntu folks)
   ```
   sudo tee /etc/apt/sources.list.d/vim.list <<EOM
   deb http://ppa.launchpad.net/laurent-boulard/vim/ubuntu $(cat /etc/lsb-release | sed -n '/CODENAME/s/.*=//p') main
   EOM
   sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F82D365
   sudo apt-get update
   sudo apt-get install vim
   ```
