#!/bin/sh

[ "$#" -eq 1 ] || { echo "USAGE: $0: mql4-file" ; exit 1 ; }

[ -f "$1" ] || { echo "ERROR: file not found: $1" ; exit 2 ; }
FILE=$1

# we use as a marker for documentation '//  ', either
# at the beining of a line, or exactly 4 space indented.
grep '^//  \|^[a-z].*{ *\|^    //  ' "$FILE" | \
    dos2unix | \
    sed -e 's@\(^[a-z].*\) *{ *$@\n{{{\1}}}@' -e 's@//  @@'



