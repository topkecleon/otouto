#!/bin/sh

# Launch tg listening on the default port (change this if you've changed it in
# config.lua), delete state file after stop, wait five seconds, and restart.

while true; do
	tg/bin/telegram-cli -P 4567 -E
	[ -f ~/.telegram-cli/state ] && rm ~/.telegram-cli/state
	echo 'tg has stopped. ^C to exit.'
	sleep 5s
done
