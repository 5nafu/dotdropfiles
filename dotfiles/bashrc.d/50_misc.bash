# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Prevent less from clearing the screen while still showing colors.
export LESS=-XR

# SSH auto-completion based on entries in known_hosts.
if [[ -e ~/git/puppet ]] ; then
    if ! crontab -l 2>&1 | grep -q update_puppet_hostlist; then
        (crontab -l 2>/dev/null; echo "*/5 * * * * $HOME/bin/update_puppet_hostlist $HOME/git/") \
            | crontab -
    fi
    export HOSTFILE=~/.hostlist.txt
    complete -o default -o nospace -A hostname -F _sshcomplete ssh
fi

# Disable ansible cows }:]
export ANSIBLE_NOCOWS=1

# Alias vor activating Virtualenv
alias venv='if [[ -d venv ]] ;  then  source ./venv/bin/activate; else virtualenv venv && source ./venv/bin/activate; fi'
alias venv3='if [[ -d venv ]] ;  then  source ./venv/bin/activate; else virtualenv -p python3 venv && source ./venv/bin/activate; fi'

# Alias to go to top of git project
alias gtop='cd $(git rev-parse --show-toplevel)'

# Add sshagent Variables and scripts to restart the agent
if gpgconf  --list-dirs| grep -q  agent-ssh-socket ; then
    export SSH_AUTH_SOCK=$(gpgconf  --list-dirs agent-ssh-socket)
else
    export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
fi
if [[ -e /bin/systemctl ]]; then
    alias ssh-yubi-add='systemctl --user restart gpg-agent'
else
    alias ssh-yubi-add='pgrep gpg-agent >/dev/null && sudo pkill gpg-agent; gpg-agent --daemon'
fi

#TC
alias tclocate="locate -d /media/veracrypt/locate/locate.db"
alias tcfind="find_duplicates.py check -f /media/veracrypt/locate/hashes.db"
alias tcdupes="find_duplicates.py duplicates -f /media/veracrypt/locate/hashes.db"

# Recursively delete `.DS_Store` files
alias dsstore="find . -name '*.DS_Store' -type f -ls -delete"

# Aliasing eachdir like this allows you to use aliases/functions as commands.
alias eachdir=". eachdir"

# Allow GET tu work on broken SSL
alias GET="PERL_LWP_SSL_VERIFY_HOSTNAME=0 /usr/bin/GET"


# Create a new directory and enter it
function md() {
  mkdir -p "$@" && cd "$@"
}

# Run commands in each subdirectory.
alias gu-all='eachdir git pull'
alias gp-all='eachdir git push'
alias gs-all='eachdir git status'

# Add bin directory
export PATH="$HOME/bin:$HOME/.local/bin:$PATH:$PATH"

# create colorized box for given strings
function box_out() {
    local s="$*"
    color_border=1
    color_text=2
    tput setaf $color_border
    echo "##${s//?/\#}##
# $(tput setaf $color_text)$s$(tput setaf $color_border) #
##${s//?/\#}##"
    tput sgr 0
}

function title() {
    echo -e '\033]2;'$@'\007'
}

# Some Ansible shortcuts
alias aencrypt="ansible-vault encrypt --vault-password-file=\$(git rev-parse --show-toplevel)/password.txt"
alias adecrypt="ansible-vault decrypt --vault-password-file=\$(git rev-parse --show-toplevel)/password.txt"

alias vssh="vagrant ssh"
