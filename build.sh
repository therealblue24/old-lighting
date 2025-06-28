#!/bin/sh

set -xe

rm -f oldlight.zip

zip -r oldlight.zip . -x build.sh -x demo.png -x .DS_Store -x README.md
