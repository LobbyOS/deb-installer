#!/bin/bash

# /usr/share/lobby
LOBBY_DIR=$(dirname "$(readlink -f "$0")")

echo 'Welcome to Lobby Setup. Installation requires root access. Please allow it :'
sudo bash $LOBBY_DIR/lobby-install.sh
