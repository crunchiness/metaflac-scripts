#!/usr/bin/env bash

DIRECTORY=${1%/}

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # split only on newline
for x in `find ${DIRECTORY} -type f -name '*.flac'`
do
    TRACKNUMBER=`metaflac --show-tag=TRACKNUMBER "${x}"`
    if [[ "${TRACKNUMBER}" =~ ^TRACKNUMBER\=0([0-9])$ ]]; then
        metaflac --remove-tag=TRACKNUMBER "${x}"
        metaflac --set-tag=TRACKNUMBER=${BASH_REMATCH[1]} "${x}"
    fi
    TRACKTOTAL=`metaflac --show-tag=TRACKTOTAL "${x}"`
    if [[ "${TRACKTOTAL}" =~ ^TRACKTOTAL\=0([0-9])$ ]]; then
        metaflac --remove-tag=TRACKTOTAL "${x}"
        metaflac --set-tag=TRACKTOTAL=${BASH_REMATCH[1]} "${x}"
    fi
done
