#!/bin/sh
# https://stackoverflow.com/a/10520718/1265581
STR=ABCD-1234
var1=${STR%-*} # Posix delete delimiter and shortest substring after it.
var2=${STR#*-} # Posix delete shortest substring before and including delimiter.

echo "$var1"
echo "$var2"

wget https://brickset.com/exportscripts/instructions -O brickset.csv

folder=./instructions/
if [ ! -d "$folder" ]; then
  mkdir $folder
fi

# Remove partial file (if set)
while IFS= read -r line; do
  lastSaved=${line}
  if [ ! -z "$lastSaved" -a "$lastSaved" != "" ]; then
    rm $lastSaved
    echo "Removed $lastSaved"
    echo "" > lastsaved.txt # blank so that we don't try the same file next time.
    break
  fi
done < lastsaved.txt

# Main loop
while IFS= read -r line; do
  col1=${line%%,*}
  col2e=${line#*,}
  col2=${col2e%%,*}

  # Strip out double quotes or wget won't work.
  col1q=$(eval echo $col1)
  col2q=$(eval echo $col2)

  file="${folder}${col1q}.pdf"
  url="${col2q}"

  #echo "Downloading $url to $file..."
  echo $file > lastsaved.txt # show pending download in case we cancel during a wget and corrupt it.
  # Do not overwrite files if they already exist.
  if [ -f "$file" ]; then
    echo "" > lastsaved.txt # clear so we don't delete totally downloaded PDFs.
    echo "Skipping because $file already exists."
  else
    # Limits to 100kbps because we're nice.
    is_200_ok=$(wget --server-response --limit-rate=500k --no-clobber $url -O $f                                                                                                                                                             ile 2>&1 | grep -c 'HTTP/1.1 200 OK')
    if [ $is_200_ok = 1 ]; then # Must be = (sh), not == (bash) if we run with s                                                                                                                                                             h. https://stackoverflow.com/a/3411105/1265581
      echo "" > lastsaved.txt # show pending download in case we cancel during a wget and corrupt it.
      echo "Saved $file"
      sleep 5 # Avoid DoS-ing lego.com. Also because we're nice.
    else
      echo "" > lastsaved.txt # show pending download in case we cancel during a wget and corrupt it.
      echo "Deleting $file because it wasn't downloaded."
      rm $file
      sleep 1 # Reward 200 with longer wait, punish 404 with shorter.
    fi
  fi
done < brickset.csv

rm brickset.csv
