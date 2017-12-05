#!/usr/bin/env bash

DIRECTORY=${1%/}

if [ ! -d "$DIRECTORY" ]; then
    echo "${DIRECTORY} is not a directory"
    exit 1
fi

IFS=$'\n' # split only on newline
for x in `find ${DIRECTORY} -type f -name *.flac`
do
#    album=`metaflac --show-tag=album "${x}"`
#    artist=`metaflac --show-tag=artist "${x}"`
#    title=`metaflac --show-tag=title "${x}"`
#    genre=`metaflac --show-tag=genre "${x}"`
#
#    if [[ "${album}" =~ ^album\=(.*)$ ]]; then
#        metaflac --remove-tag=album "${x}"
#        metaflac --set-tag="ALBUM=${BASH_REMATCH[1]}" "${x}"
#    fi
#
#    if [[ "${artist}" =~ ^artist\=(.*)$ ]]; then
#        metaflac --remove-tag=artist "${x}"
#        metaflac --set-tag="ARTIST=${BASH_REMATCH[1]}" "${x}"
#    fi
#
#    if [[ "${title}" =~ ^title\=(.*)$ ]]; then
#        metaflac --remove-tag=title "${x}"
#        metaflac --set-tag="TITLE=${BASH_REMATCH[1]}" "${x}"
#    fi
#
#    if [[ "${genre}" =~ ^genre\=(.*)$ ]]; then
#        metaflac --remove-tag=genre "${x}"
#        metaflac --set-tag="GENRE=${BASH_REMATCH[1]}" "${x}"
#    fi
    Album=`metaflac --show-tag=Album "${x}"`
    Artist=`metaflac --show-tag=Artist "${x}"`
    Title=`metaflac --show-tag=Title "${x}"`
    Genre=`metaflac --show-tag=Genre "${x}"`

    if [[ "${Album}" =~ ^Album\=(.*)$ ]]; then
        metaflac --remove-tag=Album "${x}"
        metaflac --set-tag="ALBUM=${BASH_REMATCH[1]}" "${x}"
    fi

    if [[ "${Artist}" =~ ^Artist\=(.*)$ ]]; then
        metaflac --remove-tag=Artist "${x}"
        metaflac --set-tag="ARTIST=${BASH_REMATCH[1]}" "${x}"
    fi

    if [[ "${Title}" =~ ^Title\=(.*)$ ]]; then
        metaflac --remove-tag=Title "${x}"
        metaflac --set-tag="TITLE=${BASH_REMATCH[1]}" "${x}"
    fi

    if [[ "${Genre}" =~ ^Genre\=(.*)$ ]]; then
        metaflac --remove-tag=Genre "${x}"
        metaflac --set-tag="GENRE=${BASH_REMATCH[1]}" "${x}"
    fi
done
