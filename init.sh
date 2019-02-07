#!/bin/bash

TARGETDIR=${1:"$HOME/git/dotdropfiles"}
REPOSITORY=5nafu/dotdropfiles

if [[ "$OSTYPE" =~ ^darwin ]] ; then 
    echo "WARNING: Install of dependencies not implemented."
    echo "Continuing"
elif type lsb_release &>/dev/null && [[ $(lsb_release -s -c) =~ (Debian|Ubuntu) ]] ; then
    if curl -o requirements.apt https://raw.githubusercontent.com/$REPOSITORY/master/requirements.apt; then
	curl -o aptfile https://raw.githubusercontent.com/seatgeek/bash-aptfile/master/bin/aptfile
	chmod +x aptfile

	sudo ./aptfile requirements.apt

	rm ./aptfile requirements.apt

    else
        echo "Nothing to install"
    fi
else
    echo "WARNING: OS not recognized. Not installing packages."
fi

# Cloning repository
if [[ ! -d "$TARGETDIR" ]]; then
    mkdir -p $(dirname $TARGETDIR)
    git clone https://github.com/$REPOSITORY.git "$TARGETDIR"
fi
cd $TARGETDIR

# Update Submodules
git submodule update --init --recursive
git submodule update --remote dotdrop

sudo pip3 install -r dotdrop/requirements.txt

  

read -p "Install dotfiles? (y/N)" -t 10 INSTALL
if [[ "${INSTALL,,}" -eq "y" ]]; then
    ./dotdrop install --cfg=$TARGETDIR/config.yaml
fi

read -p "Reset remote of dotfiles repository to ssh? (Y/n)" -t 10 RESET_REPO
if [[ "${INSTALL,,}" -eq "y" ]] || [[ -z "${INSTALL}" ]]; then
    git remote set-url origin git@github.com:$REPOSITORY.git
fi

