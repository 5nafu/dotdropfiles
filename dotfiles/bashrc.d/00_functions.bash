# Logging stuff.
function e_header()   { echo -e "\n\033[1m$@\033[0m"; }
function e_success()  { echo -e " \033[1;32m✔\033[0m  $@"; }
function e_error()    { echo -e " \033[1;31m✖\033[0m  $@"; }
function e_arrow()    { echo -e " \033[1;34m➜\033[0m  $@"; }

# OS detection
function is_osx() {
  [[ "$OSTYPE" =~ ^darwin ]] || return 1
}
function is_ubuntu() {
  type lsb_release &>/dev/null && [[ "$(lsb_release -s -i)" =~ Ubuntu ]] || return 1
}
function is_debian() {
  type lsb_release &>/dev/null && [[ "$(lsb_release -s -i)" =~ Debian ]] || return 1
}
function get_os() {
  for os in osx ubuntu debian; do
    is_$os; [[ $? == ${1:-0} ]] && echo $os
  done
}

# Remove an entry from $PATH
# Based on http://stackoverflow.com/a/2108540/142339
function path_remove() {
  local arg path
  path=":$PATH:"
  for arg in "$@"; do path="${path//:$arg:/:}"; done
  path="${path%:}"
  path="${path#:}"
  echo "$path"
}
