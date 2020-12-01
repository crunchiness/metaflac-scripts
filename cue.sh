#!/usr/bin/env bash

# sudo apt install shntool cuetools

shnsplit -o flac -f file.cue file.flac
cuetag file.cue split-*.flac

# TODO: split and write tags from the cue and flac
