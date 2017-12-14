#!/usr/bin/env bash

REQUIRED_TAGS=("ALBUM" "ARTIST" "DATE" "GENRE" "TITLE" "TRACKNUMBER" "TRACKTOTAL")
OPTIONAL_TAGS=("ALBUMARTIST" "COMMENT" "DISCID" "DISCNUMBER" "DISCSUBTITLE" "DISCTOTAL")

DIRECTORY=${1%/}

EXTRA_REMOVE=(${2})

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # split only on newline

for x in `find "${DIRECTORY}" -type f -name '*.flac'`
do
    TAGS=`metaflac --export-tags-to=- "${x}"`
    while read -r TAG; do
        if [[ "${TAG}" =~ ^([a-zA-Z _]+)\=(.*)$ ]]; then
            TAG_NAME="${BASH_REMATCH[1]}"
        else
            echo "STRANGE TAG ${TAG}"
        fi

        # Check for unexpected tags
        if [[ ! "${REQUIRED_TAGS[*]}" =~ "${TAG_NAME}" && ! "${OPTIONAL_TAGS[@]}" =~ "${TAG_NAME}" ]]; then
            printf "Removing tag %s from file %s\n" ${TAG_NAME} ${x}
            metaflac --remove-tag="${TAG_NAME}" "${x}"
        fi
    done <<< "$TAGS"

    for t in "${EXTRA_REMOVE[@]}"
    do
        printf "Removing tag %s from file %s\n" ${t} ${x}
        metaflac --remove-tag="${t}" "${x}"
    done
done
