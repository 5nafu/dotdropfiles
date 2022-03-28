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
  thisline_keys=()
  ( echo -e "-----BEGIN PGP MESSAGE-----\n\n"; \
    echo "$line" | sed 's/ENC\[GPG,//;s/\]//' | sed -r 's/(.{64})/\1\n/g'; \
    echo "-----END PGP MESSAGE-----"\
  ) \
  | gpg --list-only --no-default-keyring --secret-keyring /dev/null 2>&1 \
  | grep -o "ID [0-9A-F]*" | sed 's/ID /0x/' \
  | while read current_key; do
    [[ -z "$current_key" ]] && continue
    echo "Current ID: $current_key" >&2
    if [[ ! "${KNOWN_KEYS[@]}" =~ "$current_key" ]]; then
      echo "  New key!" >&2
      uid=$(gpg -k --with-colons $current_key 2>/dev/null| grep uid | head -1 |cut -d: -f 10)
      echo "  uid: $uid" >&2
      thisline_keys+=( "$current_key $uid" )
      KNOWN_KEYS+=( "$current_key $uid" )
    else
      echo "  Known key" >&2
      thisline_keys+=$(printf "%s\n" "${KNOWN_KEYS[@]}" |grep "$current_key")
    fi
  done
  printf "%s\n" "${thisline_keys[@]}"
done |sort |uniq -c | sort -n

echo "KNOWN KEYS:"
echo "${KNOWN_KEYS[@]}"
