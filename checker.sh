#!/usr/bin/env bash

function string_equiv {
    if [[ "$1" == "$2" ]]; then
        return 0
    fi

    # else check if unicode strings are equivalent in different unicode normalization forms
    local script=$(printf "# -*- coding: utf-8 -*-\nimport unicodedata\nif unicodedata.normalize('NFC', '"${1//\'/\\\\\'}"') == unicodedata.normalize('NFC', '"${2//\'/\\\\\'}"'):\n    print('Y')\nelse:\n    print('N')\n")
    local result=`python3 -c "${script}"`
    if [[ ${result} == "Y" ]]; then
        return 0
    else
        return 1
    fi
}

function remove_special_chars {
    # Replace "/" and ":" with "-"
    RESULT=${1//\//-}
    RESULT=${RESULT//:/-}
    # Replace "?", "*", "<" and ">" with "_"
    RESULT=${RESULT//\?/_}
    RESULT=${RESULT//\*/_}
    RESULT=${RESULT//</_}
    RESULT=${RESULT//>/_}
    # Remove double quotes
    RESULT=${RESULT//\"/}
    echo "${RESULT}"
}

REQUIRED_TAGS=("ALBUM" "ARTIST" "DATE" "GENRE" "TITLE" "TRACKNUMBER" "TRACKTOTAL")
OPTIONAL_TAGS=("ALBUMARTIST" "COMMENT" "DISCID" "DISCNUMBER" "DISCSUBTITLE" "DISCTOTAL")

DIRECTORY=${1%/}

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # Split only on newline
for x in $(find "${DIRECTORY}" -type f -name '*.flac' | sort)
do
    TAGS=$(metaflac --export-tags-to=- "${x}")
    ALBUM=""
    ALBUMARTIST=""
    ARTIST=""
    DISCNUMBER=""
    TITLE=""
    TRACKNUMBER=""
    while read -r TAG; do
        if [[ "${TAG}" =~ ^([a-zA-Z _]+)\=(.*)$ ]]; then
            TAG_NAME="${BASH_REMATCH[1]}"

            # Save tags for filename check
            if [[ "${TAG_NAME}" == "ALBUM" ]]; then
                ALBUM="${BASH_REMATCH[2]}"
            fi
            if [[ "${TAG_NAME}" == "ALBUMARTIST" ]]; then
                ALBUMARTIST="${BASH_REMATCH[2]}"
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
        else
            echo "STRANGE TAG ${TAG}"
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
    FILENAME=${x##*/}
    if [[ "${FILENAME}" =~ ^([0-9]+)\.\ (.+)\ -\ (.+\ -\ .+\ -\ .+)\.flac$ ]]; then
        N_DISCNUMBER=""
        N_TRACKNUMBER=${BASH_REMATCH[1]}
        N_ARTIST=${BASH_REMATCH[2]}
        N_TITLE=${BASH_REMATCH[3]}
    elif [[ "${FILENAME}" =~ ^([0-9]+)\.\ (.+)\ -\ (.+\ -\ .+)\.flac$ ]]; then
        N_DISCNUMBER=""
        N_TRACKNUMBER=${BASH_REMATCH[1]}
        N_ARTIST=${BASH_REMATCH[2]}
        N_TITLE=${BASH_REMATCH[3]}
    elif [[ "${FILENAME}" =~ ^([0-9]+)\.\ (.+)\ -\ (.+)\.flac$ ]]; then
        N_DISCNUMBER=""
        N_TRACKNUMBER=${BASH_REMATCH[1]}
        N_ARTIST=${BASH_REMATCH[2]}
        N_TITLE=${BASH_REMATCH[3]}
    elif [[ "${FILENAME}" =~ ^([0-9]+)\ -\ ([0-9]+)\.\ (.+)\ -\ (.+\ -\ .+\ -\ .+)\.flac$ ]]; then
        N_DISCNUMBER=${BASH_REMATCH[1]}
        N_TRACKNUMBER=${BASH_REMATCH[2]}
        N_ARTIST=${BASH_REMATCH[3]}
        N_TITLE=${BASH_REMATCH[4]}
    elif [[ "${FILENAME}" =~ ^([0-9]+)\ -\ ([0-9]+)\.\ (.+)\ -\ (.+\ -\ .+)\.flac$ ]]; then
        N_DISCNUMBER=${BASH_REMATCH[1]}
        N_TRACKNUMBER=${BASH_REMATCH[2]}
        N_ARTIST=${BASH_REMATCH[3]}
        N_TITLE=${BASH_REMATCH[4]}
    elif [[ "${FILENAME}" =~ ^([0-9]+)\ -\ ([0-9]+)\.\ (.+)\ -\ (.+)\.flac$ ]]; then
        N_DISCNUMBER=${BASH_REMATCH[1]}
        N_TRACKNUMBER=${BASH_REMATCH[2]}
        N_ARTIST=${BASH_REMATCH[3]}
        N_TITLE=${BASH_REMATCH[4]}
    else
        echo "Could not parse filename \"${FILENAME}\"!"
        continue
    fi

    # Remove preceding 0
    [[ "${N_TRACKNUMBER}" =~ 0?([0-9]+) ]] &&
    N_TRACKNUMBER=${BASH_REMATCH[1]}

    # Check for name/tags metadata mismatches
    T_ARTIST=$(remove_special_chars "${ARTIST}")
    if ! string_equiv "${N_ARTIST}" "${T_ARTIST}"; then
        echo "FILENAME is ${FILENAME}"
        echo "ARTIST is ${N_ARTIST}"
        echo "MISMATCH # ARTIST # ${N_ARTIST} # ${T_ARTIST} # ${x}"
    fi

    if [[ "${N_DISCNUMBER}" != "${DISCNUMBER}" ]]; then
        echo "MISMATCH # DISCNUMBER # ${N_DISCNUMBER} # ${DISCNUMBER} # ${x}"
    fi

    T_TITLE=$(remove_special_chars "${TITLE}")
    if ! string_equiv "${N_TITLE}" "${T_TITLE}"; then
        echo "MISMATCH # TITLE # ${N_TITLE} # ${TITLE} # ${x}"
    fi

    if [[ "${N_TRACKNUMBER}" != "${TRACKNUMBER}" ]]; then
        echo "MISMATCH # TRACKNUMBER # ${N_TRACKNUMBER} # ${TRACKNUMBER} # ${x}"
    fi

    # Check for folder name mismatches
    if [[ "${ALBUMARTIST}" == "" ]]; then
        ALBUMARTIST="${ARTIST}"
    fi
    T_ALBUMARTIST=$(remove_special_chars "${ALBUMARTIST}")
    T_ALBUM=$(remove_special_chars "${ALBUM}")
    FOLDER_NAME=${x%/*}
    FOLDER_NAME=${FOLDER_NAME##*/}

    if [[ ${FOLDER_NAME} =~ ^(.+)\ -\ (.+\ -\ .+)$ ]]; then
        FOLDER_ARTIST="${BASH_REMATCH[1]}"
        FOLDER_ALBUM="${BASH_REMATCH[2]}"
    elif [[ ${FOLDER_NAME} =~ ^(.+)\ -\ (.+)$ ]]; then
        FOLDER_ARTIST="${BASH_REMATCH[1]}"
        FOLDER_ALBUM="${BASH_REMATCH[2]}"
    else
        echo "DOES NOT MATCH ${FOLDER_NAME}"
    fi
    if ! string_equiv "${FOLDER_ALBUM}" "${T_ALBUM}"; then
        echo "ALBUM NAME MISMATCH # ${FOLDER_ALBUM} # ${T_ALBUM} # ${x}"
    fi
    if ! string_equiv "${FOLDER_ARTIST}" "${T_ALBUMARTIST}"; then
        echo "ARTIST NAME MISMATCH # ${FOLDER_ARTIST} # ${T_ALBUMARTIST} # ${x}"
    fi

done
