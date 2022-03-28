# "Debian-like"-only stuff. Abort if not Ubuntu or Debian.
is_ubuntu || is_debian || return 1

# Make 'less' more.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

alias gthumb='vcsi -t -g 5x5 --end-delay-percent 20 --metadata-font /usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf --delay-percent 0'

alias monon='sudo vbetool dpms on'
