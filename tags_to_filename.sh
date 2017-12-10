#!/usr/bin/env bash

function remove_special_chars {
    # Replace "/" and ":" with "-"
    RESULT=${1//\//-}
    RESULT=${RESULT//:/-}
    # Replace "?", "<" and ">" with "_"
    RESULT=${RESULT//\?/_}
    RESULT=${RESULT//</_}
    RESULT=${RESULT//>/_}
    # Remove double quotes
    RESULT=${RESULT//\"/}
    echo "${RESULT}"
}

DIRECTORY=${1%/}

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # Split only on newline
for x in `find ${DIRECTORY} -type f -name *.flac`
do
    TAGS=`metaflac --export-tags-to=- "${x}"`
    ARTIST=""
    DISCNUMBER=""
    TITLE=""
    TRACKNUMBER=""
    while read -r TAG; do
        [[ "${TAG}" =~ ^([a-zA-Z ]+)\=(.*)$ ]] &&
        TAG_NAME="${BASH_REMATCH[1]}"

        # Save tags for filename check
        if [[ "${TAG_NAME}" == "ALBUM" ]]; then
            ALBUM="${BASH_REMATCH[2]}"
        fi
        if [[ "${TAG_NAME}" == "ARTIST" ]]; then
            ARTIST="${BASH_REMATCH[2]}"
        fi
        if [[ "${TAG_NAME}" == "DISCNUMBER" ]]; then
            DISCNUMBER="${BASH_REMATCH[2]}"
        fi
        if [[ "${TAG_NAME}" == "TITLE" ]]; then
            TITLE="${BASH_REMATCH[2]}"
        fi
        if [[ "${TAG_NAME}" == "TRACKNUMBER" ]]; then
            TRACKNUMBER="${BASH_REMATCH[2]}"
        fi
    done <<< "$TAGS"

    T_ARTIST=`remove_special_chars "${ARTIST}"`
    T_TITLE=`remove_special_chars "${TITLE}"`
    mv "${x}" "${x%/*}/$(printf "%02d\n" ${TRACKNUMBER}). ${T_ARTIST} - ${T_TITLE}.flac"

done
