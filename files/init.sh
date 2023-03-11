#!/bin/bash

# change home directory owner in persistent volume
sudo chown 1000:1000 /home/coder

# change ssh key permission
chmod 600 ~/.ssh/*

#------------------------------------------------------------------------
# copy files
#------------------------------------------------------------------------
FILES_DIR=/data/configmap
CS_CONFIG=$HOME/.local/share/code-server
CS_USER=$CS_CONFIG/User
mkdir -p $CS_USER

copyFileIfAbsent () {
    [[ ! -f "$HOME/$1" ]] && (echo Creating $2$1 && cp "$FILES_DIR/$1" $2)
}

copyFileIfAbsent .bashrc       $HOME/
copyFileIfAbsent .profile      $HOME/
copyFileIfAbsent .bash_aliases $HOME/
copyFileIfAbsent .bash_profile $HOME/
copyFileIfAbsent .bash_logout  $HOME/
copyFileIfAbsent settings.json $CS_USER/

#------------------------------------------------------------------------
# install extensions
#------------------------------------------------------------------------
CS_EXT=$CS_CONFIG/extensions
TMP_EXT=/tmp/extensions

mkdir -p $CS_EXT
mkdir -p $TMP_EXT && cd $TMP_EXT

installExtentionIfAbsent () {
    VSIX=$1
    VSIX_DIR=${VSIX%.*}
    VSIX_DIR=${VSIX_DIR,,}

    if [ ! -d $CS_EXT/$VSIX_DIR ]; then
        echo "** installing $VSIX..."
        # ovsx get $VSIX
        code-server --install-extension $VSIX
        echo "** $VSIX installed."
    else
        echo "** $VSIX is already installed."
    fi
}

installExtentionIfAbsent golang.Go
installExtentionIfAbsent redhat.vscode-yaml
installExtentionIfAbsent vscode-icons-team.vscode-icons
installExtentionIfAbsent donjayamanne.githistory
installExtentionIfAbsent Arjun.swagger-viewer
installExtentionIfAbsent msjsdiag.debugger-for-chrome
installExtentionIfAbsent hediet.vscode-drawio

ls -l $TMP_EXT

rm -rf $TMP_EXT