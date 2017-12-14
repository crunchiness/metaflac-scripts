#!/usr/bin/env bash

DIRECTORY=${1%/}

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # split only on newline
for x in `find "${DIRECTORY}" -type f -name '*.flac'`
do
    echo "${x}"
    metaflac --export-tags-to=- "${x}"
    echo ""
done
