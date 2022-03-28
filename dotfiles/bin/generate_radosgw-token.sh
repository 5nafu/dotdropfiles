#!/bin/sh
# Version: 1.2
# Maintainer: Ricardo Band <ricardo.band@idealo.de>
# Usage:
#   ./generate_radosgw-token.sh
#
# Generate AWS access key for use with Ceph Rados Gateway S3 endpoint.
#
# More info: https://docs.ceph.com/docs/master/radosgw/ldap-auth/
#
# Changelog:
# v1.2:
#   - added support for FreeBSD and macOS with FreeBSD base64 installed via brew
# v1.1:
#   - added compatibility to macOS base64 util
# v1.0:
#   - initial release

generate_token() {
    user=$1
    pass=$2

    json="{\n    \"RGW_TOKEN\": {\n        \"version\": 1,\n        \"type\": \"ldap\",\n        \"id\": \"${user}\",\n        \"key\": \"${pass}\"\n    }\n}\n"
    os="$(uname -s)"
    if [ "${os}" = "Linux" ]; then
        # linux version
        printf "${json}" | base64 -w0
    elif [ "${os}" = "FreeBSD" ]; then
        # FreeBSD version
        printf "${json}" | base64 | tr -d \\n
    elif [ "${os}" = "Darwin" ]; then
        if base64 --version | grep "fourmilab.ch" >/dev/null; then
            # brew macOS version (FreeBSD)
            printf "${json}" | base64 | tr -d \\n
        else
            # native macOS version
            printf "${json}" | base64 -b
        fi
    else
        printf "Your OS is not supported yet.\nSupported OSes are: Linux, macOS (incl. brew), FreeBSD."
        exit 1
    fi
}

usage() {
    echo "generate_radosgw-token.sh [--help]"
    echo ""
    echo "Generate the AWS_ACCESS_KEY_ID for use with the Ceph Rados Gateway. Leave the AWS_SECRET_ACCESS_KEY as an" \
         "empty string and keep your ACCESS_KEY secure as it contains your plaintext password."
}

main() {
    if [ "$1" = "-h" ] | [ "$1" = "--help" ]; then
        usage
        exit 0
    fi

    # get ldap credentials
    read -p "Enter your LDAP username: " ldap_username
    stty -echo
    printf "Enter LDAP password: "
    read ldap_password
    stty echo
    printf "\n"

    printf "AWS_ACCESS_KEY_ID: \""
    generate_token "$ldap_username" "$ldap_password"
    echo "\""
    echo "AWS_SECRET_ACCESS_KEY: \"\""
    echo "ENDPOINT_URL: \"https://radosgw.eu.idealo.com/\""
}
main

