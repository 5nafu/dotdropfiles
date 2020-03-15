# Source a .bashrc.local file, if it exists.
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
[[ -f ~/.bashrc.$(hostname -s) ]] && source ~/.bashrc.$(hostname -s)
