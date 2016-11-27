FAQ:
====

1. What's this all about?

   It's just a bunch of tools and customizations to make tasks easy
   Just to name a few

   .vimrc            # tweaks and settings (better upgrade your vim to the latest)
   .screenrc         # tweaks and settings
   .bashrc           # settings including prompt settings


   Some scripts do not show help. And others are very specific. Others are downright unintelligible or obscure.
   Others have dependencies that need to be setup in a specific way and require some work.

2. How to install the shell-customizations?

   WARN: Installation procedure will replace your initialization files (like .bashrc, .vimrc, etc by one provided by shell-customization)
         To be less disruptive, you could create a user on your system, and install shell-customizations on that.

   Once instllation is done, you will then get these files as a svn check-out!!
   From then on, you can change the files to your own liking, and also get updates.

   Use the following procedure to install:
   =======================================
   ( git clone -- http://www.github.com/shri314/bash-scripts && cd bash-scripts && ./install.sh && rm -rf bash-scripts )
   =======================================

   Your old setttings are in "sh-bak". You can review which changes you need and apply them manually.
   Later you can delete "sh-bak/"

3. How can I try it without getting disripted?

   Create a user on your system, and install shell-customizations on that.
   Also I recommend not to put the shell-customizations for the root user.

4. How do I get updates?

   cd ~
   svn update

5. How do I contribute?

   This is in svn. you can commit. Just make sure it useful, and in-general follows similar genre, and hopefully have no external dependencies

6. How can I make it better?

   Overtime things can evolve. We can categorize scrits, and evolve conventions.
