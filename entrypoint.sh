#!/usr/bin/env bash

set -e

files=$(git ls-files | sed -e 's/^/.\//')

if test $# -gt 0
then
    exclude=$1

    IFS=';' read -r -a array <<< "$exclude"

    for elm in "${array[@]}"
    do
        files=$(grep -v "$elm" <<< $files)
    done
fi

tw_lines=""  # Lines containing trailing whitespaces.

# TODO (harupy): Check only changed files.
for file in $files
do
  lines=$(egrep -rnIH " +$" $file | cut -f-2 -d ":")
  if [ ! -z "$lines" ]; then
    tw_lines+=$([[ -z "$tw_lines" ]] && echo "$lines" || echo $'\n'"$lines")
  fi
done

exit_code=0

# If tw_lines is not empty, change the exit code to 1 to fail the CI.
if [ ! -z "$tw_lines" ]; then
  echo -e "\n***** Lines containing trailing whitespace *****\n"
  echo -e "${tw_lines[@]}"
  echo -e "\nFailed.\n"
  exit_code=1
fi

exit $exit_code
