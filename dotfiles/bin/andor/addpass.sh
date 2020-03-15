#!/bin/bash

if [[ "$#" -lt 2 ]]; then
    echo "Usage: $0 <URL> <NAME OF PAGE>"
    exit 1
fi

URL="$1"; shift
NAME="$@"

echo -e "vuewcemkas9\nurl: echo $URL\nusername: logain" |gopass insert "websites/$NAME/logain"

