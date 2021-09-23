#!/bin/bash

filebot \
    -rename \
    --db TheMovieDB \
    --apply artwork cover url import tags prune clean \
    --format '/Volumes/BACKUP/Video/Movies/plex/Movies/{collection}/{plex.name} - {audioLanguages}/{plex.name}{" {imdb-$imdbid} - $audioLanguages [$vf, $vc, $ac]"}'\
    --mode interactive \
    -non-strict \
    --conflict skip \
    -r \
    --file-filter f.video \
    "$@"
