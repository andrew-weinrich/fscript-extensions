#!/bin/bash

# This file compiles headerdoc for all the headers in the project, then compiles
# the top-level headerdoc
# The script caches file modifications times in the header_mod_times file to 
# avoid unnecessary reprocessing


MOD_FILE=header_mod_times


# rebuild all files if desired
if [ "$1" = clean ]; then
    rm -f "$MOD_FILE"
fi

# create a file to cache modification times
if [ ! -f "$MOD_FILE" ]; then
    touch "$MOD_FILE"
fi


OUTPUT_DIR=Documentation
mkdir -v "$OUTPUT_DIR"

# We'll create a symlink to the project-specific HeaderDoc config file
CONFIG_LOC=~/Library/Preferences/com.apple.headerdoc2HTML.config

if [ -f "$CONFIG_LOG" ]; then
    mv "$CONFIG_LOC" "$CONFIG_LOC.temp"
fi

ln -s "$PWD/Documentation/headerdocconfig" "$CONFIG_LOC" 

HEADERS='ArrayUtil FSSystemUtility FSNSNumberMod FSFile StringSprintf StringRegex FSNSMutableDictionary FSNSDictionaryPairs FileTest BlockForeach FSRegex'

for HEADER in $HEADERS; do
    FILE_MOD_TIME=`stat -f "%N %m" "$HEADER.h"`
    FILE_MODIFIED=`grep "$FILE_MOD_TIME" "$MOD_FILE"`
    
    if [ -z "$FILE_MODIFIED" ]; then
        echo headerdoc2html -H -o $OUTPUT_DIR/ "$HEADER.h"
        headerdoc2html -H -o $OUTPUT_DIR/ "$HEADER.h"
    fi
done

stat -f "%N %m" *.h > "$MOD_FILE"

headerdoc2html -H -o $OUTPUT_DIR/ "fscript.hdoc"

gatherheaderdoc "$OUTPUT_DIR"

# get rid of the temp config file and put the old one back if any
rm -f "$CONFIG_LOC"

if [ -f "$CONFIG_LOG.temp" ]; then
    mv "$CONFIG_LOC.temp" "$CONFIG_LOC"
fi

