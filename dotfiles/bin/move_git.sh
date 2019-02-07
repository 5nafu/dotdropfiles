#!/bin/bash

function header(){
    headline=$1
    length=$((${#headline} + 4))
    border=$(printf "%-${length}s" "#")
    echo "${border// /#}"
    echo "# $headline #"
    echo "${border// /#}"
}


if [[ -z "$2" || -n "$3" ]]; then
    echo "USAGE: $0 <oldrepourl> <newrepourl>"
    exit 255
fi

old_repo="$1"
new_repo="$2"
tempdir=$(mktemp -d)

header "checking out repository '$old_repo'"
git clone --bare $old_repo $tempdir

header "moving to new repository '$new_repo'"
cd $tempdir
git push --mirror $new_repo

cd -
rm -rf $tempdir


#############################################
## DO EVERYTHING MANUALLY FOR FILTERING... ##
#############################################

# for branch in $(git branch -a |grep -Po "remotes/origin/\K[^ ]*"); do
#     header "getting branch '$branch'"
#     git checkout $branch
# done
# header "Fetchting Tags"
# git fetch --tags
# cd $tempdir
# header "moving to new repository '$new_repo'"
# git remote add new_repo $new_repo
# git push master new_repo:master
# git push new_repo --all
# git push --tags
