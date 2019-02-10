#!/bin/bash
GISTID=$1

if [[ ! -f $HOME/.config/Code/User/settings.json ]]; then
  cat <<EOF >~/.config/Code/User/settings.json 
{
  "sync.autoDownload": true, 
  "sync.gist": "$GISTID"
}
EOF
  code --install-extension Shan.code-settings-sync
fi
