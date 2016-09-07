# Run otouto in Lua 5.3, if available.
# (Specifying lua5.3 because "lua" is not linked to it in Ubuntu 16.04.)
# Otherwise, use any generic installed Lua.
# If none, give an error and a friendly suggestion.
# If Lua was found, restart otouto five seconds after halting each time.

#!/bin/sh

# Ubuntu 16.04 seems to not link "lua" to lua5.3.
if type lua5.3 >/dev/null 2>/dev/null; then
    while true; do
        lua5.3 main.lua
        echo "otouto has stopped. ^C to exit."
        sleep 5s
    done
elif type lua >/dev/null 2>/dev/null; then
    while true; do
        lua main.lua
        echo "otouto has stopped. ^C to exit."
        sleep 5s
    done
else
    echo "Lua not found."
    echo "If you're on Ubuntu, try running ./install-dependencies.sh."
fi
