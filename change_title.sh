#!/usr/bin/env bash

TITLE=${1}
FILE=${2}

metaflac --remove-tag=TITLE "${FILE}"
metaflac --set-tag=TITLE="${TITLE}" "${FILE}"
metaflac --show-tag=TITLE "${FILE}"