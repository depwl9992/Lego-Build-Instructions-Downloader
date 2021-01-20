#!/bin/bash

# https://stackoverflow.com/a/10520718/1265581
STR=ABCD-1234
STR2=AAAA,BBBB,CCCC,DDDD

var1=${STR%-*} # Posix delete delimiter and shortest substring after it.
var2=${STR#*-} # Posix delete shortest substring before and including delimiter.

echo "$var1"
echo "$var2"

wget https://brickset.com/exportscripts/instructions -O brickset.csv

while IFS= read -r line; do
  col2e=${line#*,} # Delete only the substring before and including first instance of delimiter (non-greedy).
  col2=${col2e%%,*} # Delete first instance of delimiter and all substrings thereafter (greedy).
  col2q=$(eval echo $col2) # Strips double quotes
  printf '%s\n' "$col2q"
  wget --limit-rate=100k --wait=5 --no-clobber $col2q # get file and save to current directory; limit to 100kbps and do not overwrite files that already exist.
  sleep 5 # --wait=5 in wget doesn't work, as this only pauses between multiple requests of one wget command. We could let wget perform the pause by writing all PDF urls to a second text file and passing that file into wget via the -i option.
done < brickset.csv
