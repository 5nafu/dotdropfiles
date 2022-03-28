#!/usr/bin/env python3
import argparse
import re
import subprocess
from collections import Counter

KNOWN_KEYS = {}

def chunks(lst, n):
    """Yield successive n-sized chunks from lst."""
    for i in range(0, len(lst), n):
        yield lst[i:i + n]

def get_encrypted_strings_from_file(inputfile):
    encryption_identifier = r'ENC\[.*\]'
    encrypted_strings= []
    with open(inputfile, 'r') as hierafile:
        for line in hierafile:
            match = re.search(encryption_identifier, line)
            if match:
                encrypted_strings.append(match.group(0)[8:-1])
    return encrypted_strings

def get_keys_for_encrypted_string(encrypted_string):
    pgp_data = "-----BEGIN PGP MESSAGE-----\n\n" + "\n".join(chunks(encrypted_string, 64)) + "\n-----END PGP MESSAGE-----"
    gpg_keys_process = subprocess.run(['gpg', '--list-only', '--no-default-keyring', '--secret-keyring', '/dev/null'],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, input=pgp_data)
    id_regex = r'(?<=ID )[0-9A-F]*'
    return [get_uid_for_key("0x"+key) for key in re.findall(id_regex, gpg_keys_process.stderr)]

def get_uid_for_key(key):
    if not key in KNOWN_KEYS.keys():
        gpg_key_process = subprocess.run(['gpg', '-k', '--with-colons', key], text=True, stdout=subprocess.PIPE)
        if gpg_key_process.returncode > 0:
            KNOWN_KEYS[key] = ""
        else:
            uidline = [line for line in gpg_key_process.stdout.splitlines() if line.startswith("uid:") ][-1]
            KNOWN_KEYS[key] = uidline.split(':')[9]
    return "%s %s" % (key, KNOWN_KEYS[key])

def run():
    parser = argparse.ArgumentParser()
    parser.add_argument("inputfile")
    args = parser.parse_args()
    all_keys = Counter()
    encrypted_strings = get_encrypted_strings_from_file(args.inputfile)
    print(f"Found {len(encrypted_strings)} encrypted strings")
    for encrypted_string in encrypted_strings:
        keys = get_keys_for_encrypted_string(encrypted_string)
        all_keys.update(keys)
    for key_tuple in all_keys.most_common():
        print(f'{key_tuple[1]}  {key_tuple[0]}')



if __name__ == "__main__":
    run()
