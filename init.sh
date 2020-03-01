#!/bin/bash
# set -x 

TARGETDIR=${1:-$HOME/git/dotdropfiles}
REPOSITORY=5nafu/dotdropfiles

read -p "Install packages? (Y/n)" -t 10 INSTALL_PACKAGES
if [[ "${INSTALL_PACKAGES,,}" = "y" ]] || [[ -z "${INSTALL_PACKAGES}" ]]; then
    if type curl >/dev/null 2>&1; then
        dl_cmd="curl"
        dl_options="-so"
    elif type wget >/dev/null 2>&1; then
        dl_cmd="wget"
        dl_options="-qO"
    else
        echo "Neither curl nor wget found. Exiting"
        exit 1
    fi

    if [[ "$OSTYPE" =~ ^darwin ]] ; then 
        echo "WARNING: Install of dependencies not implemented."
        echo "Continuing"
    elif type lsb_release &>/dev/null && [[ $(lsb_release -s -i) =~ (Debian|Ubuntu) ]] ; then
        if $dl_cmd $dl_options requirements.apt https://raw.githubusercontent.com/$REPOSITORY/master/requirements.apt; then
    	$dl_cmd $dl_options aptfile https://raw.githubusercontent.com/seatgeek/bash-aptfile/master/bin/aptfile
    	chmod +x aptfile

    	sudo ./aptfile requirements.apt

    	rm ./aptfile requirements.apt

        else
            echo "Nothing to install"
        fi
    else
        echo "WARNING: OS not recognized. Not installing packages."
    fi
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

sudo -H pip3 install -r dotdrop/requirements.txt
./dotdrop/bootstrap.sh
  
read -p "Install dotfiles? (y/N)" -t 10 INSTALL
if [[ "${INSTALL,,}" = "y" ]]; then
    read -p "which profile should be installed: " -i $(hostname -s) -t 10 DOTFILE_PROFILE
    ./dotdrop.sh install --cfg=$TARGETDIR/config.yaml -p $DOTFILE_PROFILE
    LOCALBASHRC=~/.bashrc.local
    grep -q "^export DOTDROP_PROFILE=" $LOCALBASHRC 2>/dev/null \
        && sed -i "s/^export DOTDROP_PROFILE=.*$/export DOTDROP_PROFILE=$DOTFILE_PROFILE/" $LOCALBASHRC \
        || echo "export DOTDROP_PROFILE=$DOTFILE_PROFILE" >>$LOCALBASHRC
fi

read -p "Reset remote of dotfiles repository to ssh? (Y/n)" -t 10 RESET_REPO
if [[ "${RESET_REPO,,}" = "y" ]] || [[ -z "${RESET_REPO}" ]]; then
    git remote set-url origin git@github.com:$REPOSITORY.git
fi

read -p "Install Firefox Add-Ons? (Y/n)" -t 10 INSTALL_FF_ADDON
if [[ "${INSTALL_FF_ADDON,,}" = "y" ]] || [[ -z "${INSTALL_FF_ADDON}" ]]; then
    ./dotfiles/bin/install_firefox_addon -f ff_extensions.lst 
fi

read -p "Install Chrome Add-Ons? (Y/n)" -t 10 INSTALL_CHROME_ADDON
if [[ "${INSTALL_CHROME_ADDON,,}" = "y" ]] || [[ -z "${INSTALL_CHROME_ADDON}" ]]; then
    ./dotfiles/bin/install_chrome_addon -f chrome_extensions.lst 
fi

