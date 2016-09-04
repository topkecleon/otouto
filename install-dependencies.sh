# This script will attempt to install Lua 5.3, Luarocks (pointed at 5.3), and
# the rocks necssary to run otouto. This script targets Ubuntu 16.04; it will
# probably not work on earlier versions of Ubuntu.

#!/bin/sh

echo "This script is intended for Ubuntu 16.04 and later. It will not work in 14.04 or earlier."
echo "This script will request root privileges to install the following packages:"
echo "lua5.3 liblua5.3-dev git libssl-dev fortune-mod fortunes"
echo "It will also request root privileges to install Luarocks to to /usr/local/ along with the following rocks:"
echo "luasocket luasec multipart-post lpeg dkjson"
echo "Press enter to continue. Use Ctrl-C to exit."
read

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

echo "Finished. Use ./launch to start otouto."
echo "Be sure to set your bot token in config.lua."
