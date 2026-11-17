#!/bin/sh
# Stands in for openscad: checks that its data file came with it, then
# writes the STL that `-o` names.
set -eu
test -f "$(dirname "$0")/fake_openscad_data.txt"
while [ "$#" -gt 0 ]; do
  if [ "$1" = "-o" ]; then
    printf 'solid fake\nendsolid fake\n' > "$2"
    exit 0
  fi
  shift
done
exit 1
