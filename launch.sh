#!/bin/sh

{ ./rtfm.sh; } || { exit 1; }

while true; do
	lua bot.lua
	echo 'otouto has stopped. ^C to exit.'
	sleep 5s
done
