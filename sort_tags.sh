#!/usr/bin/env bash

DIRECTORY=${1%/}

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # split only on newline
for x in `find ${DIRECTORY} -type f -name *.flac`
do
    ALBUM=`metaflac --show-tag=ALBUM "${x}"`
    ARTIST=`metaflac --show-tag=ARTIST "${x}"`
    DATE=`metaflac --show-tag=DATE "${x}"`
    DISCNUMBER=`metaflac --show-tag=DISCNUMBER "${x}"`
    DISCTOTAL=`metaflac --show-tag=DISCTOTAL "${x}"`
    GENRE=`metaflac --show-tag=GENRE "${x}"`
    TITLE=`metaflac --show-tag=TITLE "${x}"`
    TRACKNUMBER=`metaflac --show-tag=TRACKNUMBER "${x}"`
    TRACKTOTAL=`metaflac --show-tag=TRACKTOTAL "${x}"`

    metaflac --remove-tag=ALBUM "${x}"
    metaflac --remove-tag=ARTIST "${x}"
    metaflac --remove-tag=DATE "${x}"
    metaflac --remove-tag=DISCNUMBER "${x}"
    metaflac --remove-tag=DISCTOTAL "${x}"
    metaflac --remove-tag=GENRE "${x}"
    metaflac --remove-tag=TITLE "${x}"
    metaflac --remove-tag=TRACKNUMBER "${x}"
    metaflac --remove-tag=TRACKTOTAL "${x}"

    metaflac --set-tag="${ALBUM}" "${x}"
    metaflac --set-tag="${ARTIST}" "${x}"
    metaflac --set-tag="${DATE}" "${x}"
    metaflac --set-tag="${DISCNUMBER}" "${x}"
    metaflac --set-tag="${DISCTOTAL}" "${x}"
    metaflac --set-tag="${GENRE}" "${x}"
    metaflac --set-tag="${TITLE}" "${x}"
    metaflac --set-tag="${TRACKNUMBER}" "${x}"
    metaflac --set-tag="${TRACKTOTAL}" "${x}"

done
