#!/usr/bin/env bash

# update certificates (needed for company)
update-ca-certificates

# initialize the GPG agent for GCM
gpg --import /home/emacsserver/store/*.gcm

# Use grep and awk to extract the key ID (most probably it can be achieved in an easier way, but for now should
# suffice).
pass init $(gpg --list-secret-keys --keyid-format LONG | grep --only-matching -E "(sec[[:space:]]*[a-z0-9]*/)([A-F0-9]+)" | awk 'split($0, A, "/") { print A[2] }')
