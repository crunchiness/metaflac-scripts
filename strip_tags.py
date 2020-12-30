#!/usr/bin/env python3

__author__ = 'Ingvaras Merkys'

import argparse

from common import get_paths, remove_tag, ALLOWED_TAGS, read_all_tags


def strip_tags(path: str):
    removed_tags = []
    existing_tags = read_all_tags(path)
    for tag, value in existing_tags:
        if tag.upper() not in ALLOWED_TAGS:
            remove_tag(path, tag)
            removed_tags.append(tag)
    if len(removed_tags) > 0:
        removed_tags_str = ', '.join(map(lambda x: f'"{x}"', removed_tags))
        print(f'Removed tags: {removed_tags_str}.')
    else:
        print('No tags removed.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('path', help='path to directory or file', type=str)
    args = parser.parse_args()
    paths = get_paths(args.path)
    for path in paths:
        strip_tags(path)
