#!/bin/bash

usage() {
    echo "merged_branches - Show or delete remote branches already merged with another branch."
    echo ""
    echo "Usage:"
    echo "  merged_branches [--target_branch=<branchname>] [--filter=<string>] [--remote=<remotename>][--delete]"
    echo "  merged_branches --help"
    echo ""
    echo "Options:"
    echo "  --target_branch Compare branches to this branch (Default: master)"
    echo "  --filter        Filter for this string in branchnames"
    echo "  --remote        Name of the git remote to check against (Default: origin)"
    echo "  --delete        delete found branches"
    echo "  -h, --help      Show help."
}

target="master"
remote="origin"
delete=false

for arg in "$@"; do
    case $arg in
        --target_branch=*)
        target="${arg#*=}"
        ;;
        --filter=*)
        filter="${arg#*=}"
        ;;
        --remote=*)
        remote="${arg#*=}"
        ;;
        --delete)
        delete=true
        ;;
        -h|--help)
        usage
        exit 0
        ;;
        *)
        echo "Unknown option: $arg" 1>&2
        usage
        exit 1
        ;;
    esac
done

git fetch -p >/dev/null 2>&1
all_merged_branches="$(git branch --remote --merged $remote/$target | grep -v $remote/$target|cut -d'/' -f2- |sort)"

if [[ -n "$filter" ]]; then
    filtered_branches=$(echo "$all_merged_branches" |grep "$filter")
else
    filtered_branches=$all_merged_branches
fi

if $delete; then
    echo "Deleting the following branches:"
    echo "$filtered_branches" |xargs
    read -p "Are you sure? (y/N)" sure
    if [[ "${sure^^}" == "Y" ]]; then
        echo "$filtered_branches" | xargs git push --delete origin 
    else
        echo "Good that I asked... Aborting"
    fi
else
    echo "$filtered_branches"
fi
