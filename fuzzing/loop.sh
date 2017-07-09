#!/bin/sh

set -e

# This started with the fuzzing script by Matthias Wenzel,
# about ten years ago (in 2006). There exist funky fuzzing
# frameworks nowadays, but perhaps this simple approach
# still has something to it. I might even just integrate
# it into libmpg123 ... preferrably fuzzing only the frame body
# to get past the parser.

# My main intent for now is to recreate files that trigger
# the attempted xrpnt overflow. --ThOr

#cp -a mp3_orig mp2

HEADERSIZE=679936
HERE=$(cd $(dirname $0) && pwd)
IFS='
'

if test -z "$MPG123"; then
        MPG123=mpg123
fi

err=0
loop=0
#while !  /bin/grep -q overflow loop.sh.log ; do
while test "$err" -eq 0 ; do
  loop=$(($loop+1))
  echo "Fuzz loop $loop ..."
  workdir=$(mktemp -d fuzzwork.XXXXXX)
  mkdir $workdir/fuzzdata
  mkdir $workdir/fuzzlog
  cp fuzzinput/* $workdir/fuzzdata
  for f in $workdir/fuzzdata/* ; do
    log="$workdir/fuzzlog/$(basename "$f")"
    manglesize=$HEADERSIZE
    if test $(stat -c %s "$f") -lt $manglesize; then
      manglesize=$(stat -c %s "$f")
    fi
    echo "####################################################################"
    echo "==>> fuzzing" "$f"
    $HERE/mangle "$f" $manglesize
    echo "...................................................................."
    if ! $MPG123 --no-control --resync-limit -1 -t -c  \
      "$f" > "$log" 2>&1
    then
      # Catch any proper crash, assuming that mpg123 usually does never
      # return non-zero if there was a scrap of valid data.
      echo "==>> $MPG123 failed with input $f"
      err=$(($err+1))
    fi
    # Looking for attempted xrpnt overflow.
    err=$(($err+$(grep -i 'attempted xrpnt overflow' "$log" | wc -l)))
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  done > $workdir/loop.sh.log 2>&1
  if test $err -eq 0; then
    # No issue: cleanup.
    rm -rf $workdir
  else
    echo "Successful trigger with data: $workdir"
  fi
done

