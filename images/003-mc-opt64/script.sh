#!/bin/bash

set -e

# build
cd mozilla/mozilla-central/tree
hg pull && hg update
./mach build
