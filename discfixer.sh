#!/usr/bin/env bash

DIRECTORY=${1%/}

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # split only on newline
for x in `find ${DIRECTORY} -type f -name '*.flac'`
do
    DISCNUMBER=`metaflac --show-tag=DISCNUMBER "${x}"`
    if [[ "${DISCNUMBER}" =~ ^DISCNUMBER\=([0-9]+)/([0-9]+)$ ]]; then
        echo "${x}"
        metaflac --remove-tag=DISCNUMBER --remove-tag=DISCTOTAL "${x}"
        metaflac --set-tag=DISCNUMBER=${BASH_REMATCH[1]} --set-tag=DISCTOTAL=${BASH_REMATCH[2]} "${x}"
    else
#        TRACKTOTAL=`metaflac --show-tag=TRACKTOTAL "${x}"`
#        if [[ "${TRACKNUMBER}" =~ ^TRACKNUMBER\=[0-9]{2}$ && "${TRACKTOTAL}" =~ ^TRACKTOTAL\=[0-9]{2}$ ]]; then
#            : # All is ok
#        else
##            if [[ "${TRACKNUMBER}" =~ TRACKNUMBER\=([0-9]) ]]; then
##                metaflac --remove-tag=TRACKNUMBER "${x}"
##                metaflac --set-tag=TRACKNUMBER=0${BASH_REMATCH[1]} "${x}"
##            fi
#            echo "${x}"
#            echo `metaflac --export-tags-to=- "${x}"`
#        fi
        :
    fi
done
