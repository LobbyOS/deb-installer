#!/bin/bash

# Copyleft Subin Siby - http://subinsb.com

# Check if Lobby installed
if [ -f /usr/share/lobby/installed.conf ]; then
  URL=$(</usr/share/lobby/installed.conf)
  [[ -x $BROWSER ]] && exec "$BROWSER" "$URL"
  path=$(which xdg-open || which gnome-open) && exec "$path" "$URL"
  echo "Can't find browser"
else
  # Run Setup
  x-terminal-emulator -e "echo \"Welcome to Lobby Setup.\" && sudo /usr/share/lobby/lobby-install.sh"
fi
