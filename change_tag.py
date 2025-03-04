#!/usr/bin/env python3

__author__ = "Ingvaras Merkys"

import argparse
import logging
from os.path import basename

from common import ALLOWED_TAGS, TagDoesNotExist, get_paths, read_tag, set_tag

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(levelname)s: %(message)s'
)

def change_tag(path: str, key: str, value: str) -> None:
    try:
        old_value = read_tag(path, key)
    except TagDoesNotExist:
        old_value = '[None]'
        logging.warning('Tag "{}" does not exist for "{}"'.format(key, basename(path)))
    set_tag(path, key, value)
    new_value = read_tag(path, key)
    logging.info('Changed "{}" from "{}" to "{}" for "{}"'.format(key, old_value, new_value, basename(path)))


def validate_tag_name(tag_name: str):
    tag_name = tag_name.upper()
    if tag_name in ALLOWED_TAGS:
        return tag_name
    else:
        raise ValueError('Tag name "{}" is not one of the allowed: {}'
                         .format(tag_name, ', '.join(map(lambda x: '"' + x + '"', ALLOWED_TAGS))))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('tag_name', type=str)
    parser.add_argument('tag_value', type=str)
    parser.add_argument('path', help='path to directory or file', type=str)
    args = parser.parse_args()
    paths = get_paths(args.path)
    tag_name = validate_tag_name(args.tag_name)
    for path in paths:
        change_tag(path, tag_name, args.tag_value)
