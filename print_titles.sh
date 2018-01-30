#!/usr/bin/env bash

# Print titles of all the songs in directory
# Print track number preceding

DIRECTORY=${1%/}

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # split only on newline
for x in `find "${DIRECTORY}" -type f -name '*.flac' | sort`
do
    ARTIST=`metaflac --show-tag=ARTIST "${x}"`
    TITLE=`metaflac --show-tag=TITLE "${x}"`
    TRACKNUMBER=`metaflac --show-tag=TRACKNUMBER "${x}"`
    echo "${TRACKNUMBER#*=}"$'\t'"${ARTIST#*=}"$'\t'"${TITLE#*=}"
done
