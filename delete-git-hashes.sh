#!/bin/sh
ARCH=$(uname -m)
devpi list asyncpg --all | while read line; do
    if [ -z "${line##*cp310*}" ] && [ -z "${line##*$ARCH*}" ]; then
        echo "yes" | devpi remove $line
    fi
done
devpi list discord-py --all | while read line; do
    echo "yes" | devpi remove $line
done
devpi list discord-ext-menus --all | while read line; do
    echo "yes" | devpi remove $line
done
