# metaflac-scripts

A collection of scripts for managing FLAC metadata for music libraries.

## Usage

Remove album art from FLAC files:
```bash
metaflac --remove --block-type=PICTURE *.flac
metaflac --import-picture-from=folder.jpg file.flac
```
