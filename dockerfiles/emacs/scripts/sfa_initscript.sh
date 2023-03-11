#!/usr/bin/env bash

# update certificates (needed for company)
sudo update-ca-certificates

read -p "do you want to init GCM? [yY|nN] " choice
case $choice in
    y|Y )
    ;;
    * )
        exit 0
        ;;
esac

echo "NOTE: configure shell for GPG"
echo "GPG_TTY=$(tty)" >> ${EMACS_BASHRC}
echo "export GPG_TTY" >> ${EMACS_BASHRC}
# reload the shell configuration file
. ~/.bashrc

echo "NOTE: importing private key in GPG key-ring"
KEY_ID=$(gpg --import /home/emacsserver/store/*.gcm 2>&1 \
             | grep -m 1 -o -E "gpg: key ([[:xdigit:]]+)" \
             | awk '{print $3}')
echo "NOTE: imported key with parsed ID: $KEY_ID"

# initialize the GPG agent for GCM. Exploit the output to get the key ID (using grep and awk)
# NOTE: copy the error descriptor (fid: 2) to the stdout (fid: 1) to capture the GPG command output
pass init $KEY_ID
