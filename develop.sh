#!/usr/bin/env nix-shell
#! nix-shell -i bash -p inotifyTools pkgs.python3

set -x

nix-build
python3 -m http.server --directory result &

while inotifywait -qre close_write --format "$FORMAT" .
do
    nix-build
done
