#!/usr/bin/env bash

DIRECTORY=${1%/}

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # split only on newline
for x in `find ${DIRECTORY} -type f -name '*.flac'`
do
    TAGS=`metaflac --export-tags-to=- "${x}"`
    SORTED_TAGS=()

    while read -r TAG; do
        [[ "${TAG}" =~ ^([a-zA-Z ]+)\=.*$ ]] &&
        SORTED_TAGS+=("${TAG}")
        TAG_NAME="${BASH_REMATCH[1]}"
        metaflac --remove-tag="${TAG_NAME}" "${x}"
    done <<< "$TAGS"

    SORTED_TAGS=($(sort <<< "${SORTED_TAGS[*]}"))
    for SORTED_TAG in "${SORTED_TAGS[@]}"
    do
        metaflac --set-tag="${SORTED_TAG}" "${x}"
    done
done
