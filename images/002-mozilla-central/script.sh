#!/bin/bash

set -e

# create directory structure
mkdir mozilla
mkdir mozilla/mozilla-central
ls mozilla
cd ~/mozilla/mozilla-central
mkdir tree
mkdir builds

# checkout
hg clone https://hg.mozilla.org/mozilla-central tree

# user env
cat >> /home/mozillian/.bashrc <<EOF
export DISPLAY=localhost:1

echo "**************************************************"
echo "* Welcome to your private mozilla dev container! *"
echo "**************************************************"
echo ""
echo "To attach to the display type 'vncserver :1' and attach with a vnc client to IP:5901"
echo ""

# Nice command to cd into the (s)ource directory
alias cds="cd $USER/mozilla/mozilla-central/tree"

EOF

