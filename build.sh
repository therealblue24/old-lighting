#!/bin/sh

set -xe

rm -f oldlight.zip

# thx https://askubuntu.com/questions/28476/how-do-i-zip-up-a-folder-but-exclude-the-git-subfolder
zip -r oldlight.zip . -x build.sh -x demo.png -x '*.DS_Store*' -x README.md -x '*.git*'
