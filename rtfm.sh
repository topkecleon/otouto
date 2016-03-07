#!/bin/sh

if ! hash lua 2>/dev/null; then
    echo "Look, I would like to congratulate \
you on getting this far and still mess up. You were able to get to a form \
of linux, download otouto, and run the launch script. But you forgot the \
language that otouto runs on, nice going, read the fucking manual.
GO INSTALL LUA";
    rm -rf ../otouto;
    exit 1;
fi

lua -e "require('socket.http')" 2>/dev/null || { echo >&2 "Would it kill you to read the fucking manual at all?
INSTALL LUASOCKET";
rm -rf ../otouto;
exit 1; }

lua -e "require('ssl.https')" 2>/dev/null || { echo >&2 "There is no hope for you, just install LUASEC. (Use lua5.2 if it luasec is isntalled but you still see this)";
rm -rf ../otouto;
exit 1; }

lua -e "require('cjson')" 2>/dev/null || { echo >&2 "I am a bash script and I'm embarrased at how shitty you perform. Install CJSON";
rm -rf ../otouto;
exit 1; }
