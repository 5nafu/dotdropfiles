# "Debian-like"-only stuff. Abort if not Ubuntu or Debian.
is_ubuntu || is_debian || return 1

# Make 'less' more.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

alias dp="$HOME/git/dotdrop"
alias dpic="dp import --profile=common"
alias dpil="dp import --profile=linux"
alias dpi="dp import"
