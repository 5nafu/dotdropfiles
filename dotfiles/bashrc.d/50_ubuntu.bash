# "Debian-like"-only stuff. Abort if not Ubuntu or Debian.
is_ubuntu || is_debian || return 1

# Make 'less' more.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
