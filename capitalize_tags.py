#!/usr/bin/env python3

__author__ = 'Ingvaras Merkys'

import argparse

from os.path import basename

from common import get_paths, remove_tag, set_tag, read_all_tags


def capitalize_tags(path: str):
    existing_tags = read_all_tags(path)
    for tag, value in existing_tags:
        capitalized_tag = tag.upper()
        if capitalized_tag == tag:
            continue
        remove_tag(path, tag)
        set_tag(path, capitalized_tag, value, safe=False)
        print('Changed "{}" to "{}" for "{}"'.format(tag, capitalized_tag, basename(path)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('path', help='path to directory or file', type=str)
    args = parser.parse_args()
    paths = get_paths(args.path)
    for path in paths:
        capitalize_tags(path)
