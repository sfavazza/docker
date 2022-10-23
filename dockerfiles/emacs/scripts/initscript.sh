#!/usr/bin/env bash

# update certificates (needed for company)
update-ca-certificates

read -p "do you want to init GCM? [yY|nN] " choice
case $choice in
    y|Y )
    ;;
    * )
        exit 0
        ;;
esac

KEY_ID=$(gpg --import /home/emacsserver/store/*.gcm 2>&1 \
             | grep -m 1 -o -E "gpg: key ([[:xdigit:]]+)" \
             | awk '{print $3}')
echo "imported key with parsed ID: $KEY_ID "

# initialize the GPG agent for GCM. Exploit the output to get the key ID (using grep and awk)
# NOTE: copy the error descriptor (fid: 2) to the stdout (fid: 1) to capture the GPG command output
pass init $KEY_ID
