#!/usr/bin/env bash

DIRECTORY=${1%/}

REQUIRED_TAGS=("ALBUM", "ARTIST", "DATE", "DISCNUMBER", "DISCTOTAL", "GENRE", "TITLE", "TRACKNUMBER", "TRACKTOTAL")
OPTIONAL_TAGS=("ALBUMARTIST", "COMMENT", "DISCID", "DISCSUBTITLE")

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # split only on newline
for x in `find ${DIRECTORY} -type f -name *.flac`
do
    TAGS=`metaflac --export-tags-to=- "${x}"`
    NUM_REQ_TAGS=0
    while read -r TAG; do
        [[ "${TAG}" =~ ^([a-zA-Z]+)\=.*$ ]] &&
        TAG_NAME="${BASH_REMATCH[1]}"

        # check for unexpected tags
        if [[ ! "${REQUIRED_TAGS[@]}" =~ "${TAG_NAME}" && ! "${OPTIONAL_TAGS[@]}" =~ "${TAG_NAME}" ]]; then
            echo "${TAG_NAME} # ${x}"
        fi

        if [[ "${REQUIRED_TAGS[@]}" =~ "${TAG_NAME}" ]]; then
            NUM_REQ_TAGS=$((NUM_REQ_TAGS+1))
        fi

        # check for missing required tags
        for R_TAG in REQUIRED_TAGS
        do
            if [[ ! "${REQUIRED_TAGS[@]}" =~ "${TAG_NAME}" ]]; then
                :
            fi
        done
    done <<< "$TAGS"

    if [[ ${NUM_REQ_TAGS} < ${#REQUIRED_TAGS[@]} ]]; then
        echo "MISSING # ${x}"
    fi
done
