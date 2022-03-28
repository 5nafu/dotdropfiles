#! /usr/bin/env python3
import glob
import os
import argparse
import urllib.parse

def output_xspf(title, audio_track, ext):
    PLAYLIST_TEMPLATE="""<?xml version="1.0" encoding="UTF-8"?>
    <playlist xmlns="http://xspf.org/ns/0/" xmlns:vlc="http://www.videolan.org/vlc/playlist/ns/0/" version="1">
    	<title>{title}</title>
        <trackList>
        {tracks}
        </trackList>
    </playlist>"""
    TRACK_TEMPLATE="""		<track>
    			<location>{file}</location>
    			<title>{title}</title>
    			<extension application="http://www.videolan.org/vlc/playlist/0">
    				<vlc:option>audio-track={track}</vlc:option>
    			</extension>
    		</track>"""

    tracklist=[]

    for video in glob.glob("*{ext}".format(ext=ext)):
        tracklist.append(TRACK_TEMPLATE.format(
            file=urllib.parse.quote(video),
            title=video[:-4],
            track=audio_track
        ))

    print(PLAYLIST_TEMPLATE.format(
        title=title,
        tracks="\n".join(tracklist)
    ))

def get_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--title",
                        help="Title of the playlist, Default: current directory",
                        default = os.getcwd().split('/')[-1])
    parser.add_argument("-a", "--audio_track",
                        help="Select audio track number (Starts with 0!), Default: 0",
                        default=0,
                        type=int)
    parser.add_argument("-e", "--ext",
                        help="Select files with given extension, Default: avi",
                        default="avi")
    return vars(parser.parse_args())

if __name__ == "__main__":
    arguments=get_arguments()
    output_xspf(**arguments)
