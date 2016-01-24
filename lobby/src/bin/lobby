#!/bin/bash

# Copyleft Subin Siby - http://subinsb.com

# /usr/share/lobby
LOBBY_DIR="/usr/share/lobby"

# Check if Lobby installed
if [ -f $LOBBY_DIR/installed.conf ]; then
  URL=$(<$LOBBY_DIR/installed.conf)
  [[ -x $BROWSER ]] && exec "$BROWSER" "$URL"
  path=$(which xdg-open || which gnome-open) && exec "$path" "$URL"
  echo "Can't find browser"
else
  # Run Setup
  x-terminal-emulator -e "$LOBBY_DIR/lobby-install-pre.sh"
fi
