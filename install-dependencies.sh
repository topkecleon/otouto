# This script will attempt to install Lua 5.3, Luarocks (pointed at 5.3), and
# the rocks necssary to run otouto. This script targets Ubuntu 16.04; it will
# probably not work on any earlier version of Ubuntu.

#!/bin/sh
echo 'Requesting root privileges to install necessary packages:'
echo 'lua5.3 liblua5.3-dev git libssl-dev fortune-mod fortunes'
sudo apt-get update
sudo apt-get install -y lua5.3 liblua5.3-dev git libssl-dev fortune-mod fortunes
git clone http://github.com/keplerproject/luarocks
cd luarocks
./configure --lua-version=5.3 --versioned-rocks-dir --lua-suffix=5.3
make build
sudo make install
sudo luarocks-5.3 install luasocket
sudo luarocks-5.3 install luasec
sudo luarocks-5.3 install multipart-post
sudo luarocks-5.3 install lpeg
sudo luarocks-5.3 install dkjson
cd ..
echo 'Finished. Use ./launch to start otouto.'
echo 'Be sure to set your bot token in config.lua.'
