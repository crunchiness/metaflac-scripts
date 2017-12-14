#!/usr/bin/env bash

DIRECTORY=${1%/}

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # split only on newline
for x in `find ${DIRECTORY} -type f -name '*.flac'`
do
    printf "Removing padding for: %s\n" $(basename ${x})
    metaflac --remove --block-type=PADDING --dont-use-padding "${x}"
done
