#!/usr/bin/env python3

__author__ = "Ingvaras Merkys"

import argparse
import io
import subprocess
from os import listdir
from os.path import isfile, join, isdir, basename
from typing import List

ALLOWED_TAGS = ['ALBUM', 'ARTIST', 'DATE', 'GENRE', 'TITLE', 'TRACKNUMBER', 'TRACKTOTAL']


def set_tag(path: str, tag: str, value: str) -> None:
    # remove tag (otherwise the old one stays too)
    subprocess.run(['metaflac', '--remove-tag={}'.format(tag), path])
    # set tag
    subprocess.run(['metaflac', '--set-tag={}={}'.format(tag, value), path])


def read_tag(path: str, tag: str) -> str:
    proc = subprocess.Popen(['metaflac', '--show-tag={}'.format(tag), path], stdout=subprocess.PIPE)
    output = io.TextIOWrapper(proc.stdout, encoding='utf-8').read().strip()
    if output[:len(tag) + 1] == tag + '=':
        return output[len(tag) + 1:]
    else:
        raise Exception('Couldn\'t read tag "{}" on "{}"'.format(tag, basename(path)))


def get_paths(path: str) -> List[str]:
    if check_flac(path):
        return [path]
    elif isdir(path):
        return sorted([join(path, f) for f in listdir(path) if check_flac(join(path, f))])
    else:
        raise ValueError('Path must point to a directory or a FLAC file')


def check_flac(path: str) -> bool:
    return isfile(path) and path[-5:].lower() == '.flac'


def change_tag(path: str, key: str, value: str) -> None:
    old_value = read_tag(path, key)
    set_tag(path, key, value)
    new_value = read_tag(path, key)
    print('Changed "{}" from "{}" to "{}" for "{}"'.format(key, old_value, new_value, basename(path)))


def validate_tag_name(tag_name: str):
    tag_name = tag_name.upper()
    if tag_name in ALLOWED_TAGS:
        return tag_name
    else:
        raise ValueError('Tag name "{}" is not one of the allowed: {}'
                         .format(tag_name, ', '.join(map(lambda x: '"' + x + '"', ALLOWED_TAGS))))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('path', help='path to directory or file', type=str)
    parser.add_argument('tag_name', type=str)
    parser.add_argument('tag_value', type=str)
    args = parser.parse_args()
    paths = get_paths(args.path)
    tag_name = validate_tag_name(args.tag_name)
    for path in paths:
        change_tag(path, tag_name, args.tag_value)
