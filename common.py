import io
import subprocess
from os import listdir
from os.path import basename, isdir, isfile, join
from typing import List


def read_tag(path: str, tag: str) -> str:
    proc = subprocess.Popen(['metaflac', '--show-tag={}'.format(tag), path], stdout=subprocess.PIPE)
    output = io.TextIOWrapper(proc.stdout, encoding='utf-8').read().strip()
    if output[:len(tag) + 1] == tag + '=':
        return output[len(tag) + 1:]
    else:
        raise Exception('Couldn\'t read tag "{}" on "{}"'.format(tag, basename(path)))


def remove_tag(path: str, tag: str) -> None:
    subprocess.run(['metaflac', '--remove-tag={}'.format(tag), path])


def set_tag(path: str, tag: str, value: str, safe=True) -> None:
    # remove tag (otherwise the old one stays too)
    if safe:
        remove_tag(path, tag)
    # set tag
    subprocess.run(['metaflac', '--set-tag={}={}'.format(tag, value), path])


def check_flac(path: str) -> bool:
    return isfile(path) and path[-5:].lower() == '.flac'


def get_paths(path: str) -> List[str]:
    if check_flac(path):
        return [path]
    elif isdir(path):
        return sorted([join(path, f) for f in listdir(path) if check_flac(join(path, f))])
    else:
        raise ValueError('Path must point to a directory or a FLAC file')