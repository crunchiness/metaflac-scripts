#!/usr/bin/env bash

DIRECTORY=${1%/}

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # split only on newline
for x in `find ${DIRECTORY} -type f -name *.flac`
do
    TRACKNUMBER=`metaflac --show-tag=TRACKNUMBER "${x}"`
    TRACKTOTAL=`metaflac --show-tag=TRACKTOTAL "${x}"`
    echo "${x}"
    echo "${TRACKNUMBER} / ${TRACKTOTAL}"
    echo `metaflac --export-tags-to=- "${x}"`
done
