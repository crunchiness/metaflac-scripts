#!/usr/bin/env bash

DIRECTORY=${1%/}

REQUIRED_TAGS=("ALBUM" "ARTIST" "DATE" "GENRE" "TITLE" "TRACKNUMBER" "TRACKTOTAL")
OPTIONAL_TAGS=("ALBUMARTIST" "COMMENT" "DISCID" "DISCNUMBER" "DISCSUBTITLE" "DISCTOTAL")

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # split only on newline
for x in `find ${DIRECTORY} -type f -name *.flac`
do
    TAGS=`metaflac --export-tags-to=- "${x}"`

    # check for unexpected tags
    while read -r TAG; do
        [[ "${TAG}" =~ ^([a-zA-Z ]+)\=.*$ ]] &&
        TAG_NAME="${BASH_REMATCH[1]}"
        if [[ ! "${REQUIRED_TAGS[*]}" =~ "${TAG_NAME}" && ! "${OPTIONAL_TAGS[@]}" =~ "${TAG_NAME}" ]]; then
            printf "UNEXPECTED TAG # %-15s # %s\n" ${TAG_NAME} ${x}
        fi
    done <<< "$TAGS"

    # check for missing required tags
    for R_TAG in "${REQUIRED_TAGS[@]}"
    do
        if [[ ! "${TAGS[@]}" =~ "${R_TAG}" ]]; then
            printf "MISSING TAG    # %-15s # %s\n" ${R_TAG} ${x}
        fi
    done
done
