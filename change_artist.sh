#!/usr/bin/env bash

ARTIST=${1}
FILE=${2}

metaflac --remove-tag=ARTIST "${FILE}"
metaflac --set-tag=ARTIST="${ARTIST}" "${FILE}"
metaflac --show-tag=ARTIST "${FILE}"
