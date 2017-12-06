#!/bin/bash
find "$1" -type f -name '*.flac' -printf "Removing padding for: %f\n" -exec metaflac --remove --block-type=PADDING --dont-use-padding {} \;
