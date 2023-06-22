#!/bin/bash

SILICON="$(uname -m)"

if [[ ! -d /Applications/Docker.app/ ]]; then

    if [[ $SILICON == 'arm64' ]];
    then
            URL='https://desktop.docker.com/mac/main/arm64/Docker.dmg'
    else
            URL='https://desktop.docker.com/mac/main/amd64/Docker.dmg'
    fi

    cd /tmp
    curl $URL --output docker.dmg
    hdiutil attach Docker.dmg
    /Volumes/Docker/Docker.app/Contents/MacOS/install --accept-license
    hdiutil detach /Volumes/Docker

    exit 0

else
    echo "Docker already Installed, quitting script. "
fi

exit 0