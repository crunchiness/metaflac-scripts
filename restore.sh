#!/usr/bin/env bash

#!/usr/bin/env bash

DIRECTORY=${1%/}

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # Split only on newline
for x in `find ${DIRECTORY} -type f -name '*.flac'`
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

    # Extract metadata from filename
    FILENAME=$(basename ${x})
    if [[ "${FILENAME}" =~ ^([0-9]+)\.\ (.+)\ -\ (.+)\.flac$ ]]; then
        N_DISCNUMBER=""
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

    # Check for name/tags metadata mismatches
    ARTIST=${ARTIST//\//-}
    ARTIST=${ARTIST/://-}
    if [[ ${N_ARTIST} != ${ARTIST} ]]; then
        echo "MISMATCH # ARTIST # ${N_ARTIST} # ${ARTIST} # ${x}"
        metaflac --remove-tag=ARTIST "${x}"
        metaflac --set-tag=ARTIST=${N_ARTIST} "${x}"
    fi
    TITLE=${TITLE//\//-}
    TITLE=${TITLE/://-}
    TITLE=${TITLE//\?/_}
    TITLE=${TITLE//</_}
    TITLE=${TITLE//>/_}
    if [[ ${N_TITLE} != ${TITLE//\//-} ]]; then
        echo "MISMATCH # TITLE # ${N_TITLE} # ${TITLE} # ${x}"
        metaflac --remove-tag=TITLE "${x}"
        metaflac --set-tag=TITLE=${N_TITLE} "${x}"
    fi
done
