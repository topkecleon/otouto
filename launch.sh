#!/bin/bash

if [ "$1" = "install-debian" ]; then
 echo "Preparing..."
 sudo apt-get install lua5.2 lua-sec lua-socket
 sudo apt-get install update
else
 lua bot.lua
 sleep 5s
fi
