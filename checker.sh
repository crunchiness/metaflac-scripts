#!/usr/bin/env bash

DIRECTORY=${1%/}

REQUIRED_TAGS=("ALBUM" "ARTIST" "DATE" "GENRE" "TITLE" "TRACKNUMBER" "TRACKTOTAL")
OPTIONAL_TAGS=("ALBUMARTIST" "COMMENT" "DISCID" "DISCNUMBER" "DISCSUBTITLE" "DISCTOTAL")

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # Split only on newline
for x in `find ${DIRECTORY} -type f -name *.flac`
do
    TAGS=`metaflac --export-tags-to=- "${x}"`

    while read -r TAG; do
        [[ "${TAG}" =~ ^([a-zA-Z ]+)\=(.*)$ ]] &&
        TAG_NAME="${BASH_REMATCH[1]}"

        # Save tags for filename check
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

        # Check for unexpected tags
        if [[ ! "${REQUIRED_TAGS[*]}" =~ "${TAG_NAME}" && ! "${OPTIONAL_TAGS[@]}" =~ "${TAG_NAME}" ]]; then
            printf "UNEXPECTED TAG # %-15s # %s\n" ${TAG_NAME} ${x}
        fi
    done <<< "$TAGS"

    # Check for missing required tags
    for R_TAG in "${REQUIRED_TAGS[@]}"
    do
        if [[ ! "${TAGS[@]}" =~ "${R_TAG}" ]]; then
            printf "MISSING TAG    # %-15s # %s\n" ${R_TAG} ${x}
        fi
    done

    # Extract metadata from filename
    FILENAME=$(basename ${x})
    if [[ "${FILENAME}" =~ ^([0-9]+)\.\ (.+)\ -\ (.+)\.flac$ ]]; then
        N_TRACKNUMBER=${BASH_REMATCH[1]}
        N_ARTIST=${BASH_REMATCH[2]}
        N_TITLE=${BASH_REMATCH[3]}
    else if [[ "${FILENAME}" =~ ^([0-9]+)\ -\ ([0-9]+)\.\ (.+)\ -\ (.+)\.flac$ ]]; then
        N_DISCNUMBER=${BASH_REMATCH[1]}
        N_TRACKNUMBER=${BASH_REMATCH[2]}
        N_ARTIST=${BASH_REMATCH[3]}
        N_TITLE=${BASH_REMATCH[4]}
        fi
    fi

    # Remove preceding 0
    [[ "${N_TRACKNUMBER}" =~ 0?([0-9]+) ]] &&
    N_TRACKNUMBER=${BASH_REMATCH[1]}

    # Check for name/tags metadata mismatches
    if [[ ${N_ARTIST} != ${ARTIST} ]]; then
        echo "MISMATCH # ARTIST # ${N_ARTIST} # ${ARTIST}"
    fi
    if [[ ${N_DISCNUMBER} != ${DISCNUMBER} ]]; then
        echo "MISMATCH # DISCNUMBER # ${N_DISCNUMBER} # ${DISCNUMBER}"
    fi
    if [[ ${N_TITLE} != ${TITLE} ]]; then
        echo "MISMATCH # TITLE # ${N_TITLE} # ${TITLE}"
    fi
    if [[ ${N_TRACKNUMBER} != ${TRACKNUMBER} ]]; then
        echo "MISMATCH # TRACKNUMBER # ${N_TRACKNUMBER} # ${TRACKNUMBER}"
    fi
done
