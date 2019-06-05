#!/bin/bash

PORT="$(basename "$0")"

[ "$PORT" == "$(basename "$(readlink -f "$0")")" ] && echo "${PORT} needs to be called via symlink. Aborting..." 1>&2 && exit 1
if ! which "$PORT" > /dev/null
then
    echo "Aborting..." 1>&2
    exit 1
fi

case "$PORT" in
    ask)
        
    ;;
esac

"$PORT" "$@"
