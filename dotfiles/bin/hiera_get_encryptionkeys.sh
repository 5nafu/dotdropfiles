#!/bin/bash

usage() {
  echo "Show the recipients of encrypted strings in a hiera file"
  echo "Usage:"
  echo "$0 <FILE>"
}

FILE=$1
KNOWN_KEYS=()
if [[ ! -f "$FILE" ]]; then
  usage
  exit 1
fi

readarray -t encrypted_strings < <(grep -o --color=never "ENC\[.*\]" $FILE)


echo "Found ${#encrypted_strings[@]} encrypted strings"

for line in ${encrypted_strings[@]} ; do 
  readarray -t keys < <(echo "$line" \
  | sed 's/ENC\[GPG,/-----BEGIN PGP MESSAGE-----\n\n/;s/\]/\n-----END PGP MESSAGE-----/'\
  | gpg --list-only --no-default-keyring --secret-keyring /dev/null 2>&1 \
  |grep -o "ID [0-9A-F]*" |sed 's/ID /0x/'; )
  for index in $(seq ${#keys[@]}); do
    current_key=${keys[$index]}
    [[ -z "$current_key" ]] && continue
    if [[ ! "${KNOWN_KEYS[@]}" =~ "$current_key" ]]; then
      uid=$(gpg -k --with-colons $current_key 2>/dev/null| grep uid | head -1 |cut -d: -f 10)
      keys[$index]="$current_key $uid"
      KNOWN_KEYS+=( "$current_key $uid" )
    else
      keys[$index]=$(printf "%s\n" "${KNOWN_KEYS[@]}" |grep "$current_key")
    fi
  done
  printf "%s\n" "${keys[@]}"
done |sort |uniq -c | sort -n
