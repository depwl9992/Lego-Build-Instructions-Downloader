#!/bin/sh
# https://stackoverflow.com/a/10520718/1265581
STR=ABCD-1234
var1=${STR%-*} # Posix delete delimiter and shortest substring after it.
var2=${STR#*-} # Posix delete shortest substring before and including delimiter.

echo "$var1"
echo "$var2"

wget https://brickset.com/exportscripts/instructions -O brickset.csv

while IFS= read -r line; do
  col1=${line%%,*}
  col2e=${line#*,}
  col2=${col2e%%,*}

  # Strip out double quotes or wget won't work.
  col1q=$(eval echo $col1)
  col2q=$(eval echo $col2)

  file="${col1q}.pdf"
  url="${col2q}"

  echo "Downloading $url to $file..."
  # Do not overwrite files if they already exist.
  if [ -f "$file" ]; then
    echo "Skipping because $file already exists."
  else
    # Limits to 100kbps because we're nice.
    is_200_ok=$(wget --server-response --limit-rate=100k --no-clobber $url -O $file 2>&1 | grep -c 'HTTP/1.1 200 OK')
    if [ $is_200_ok = 1 ]; then # Must be = (sh), not == (bash) if we run with sh. https://stackoverflow.com/a/3411105/1265581
      echo "Saved $file"
      sleep 5 # Avoid DoS-ing lego.com. Also because we're nice.
    else
      echo "Deleting $file because it wasn't downloaded."
      rm $file
      sleep 1 # Reward 200 with longer wait, punish 404 with shorter.
    fi
  fi
done < brickset.csv
