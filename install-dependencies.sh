# Install Lua, Luarocks, and otouto dependencies. Works in Ubuntu, maybe Debian.
# Installs Lua 5.3 if Ubuntu 16.04. Otherwise, 5.2.

#!/bin/sh

if [ $(lsb_release -r | cut -f 2) == "16.04" ]; then
    luaver="5.3"
    rocklist="luasocket luasec multipart-post lpeg dkjson"
else
    luaver="5.2"
    rocklist="luasocket luasec multipart-post lpeg dkjson luautf8"
fi

echo "This script is intended for Ubuntu. It may work in Debian."
echo "This script will request root privileges to install the following packages:"
echo "lua$luaver liblua$luaver-dev git libssl-dev fortune-mod fortunes unzip make"
echo "It will also request root privileges to install Luarocks to /usr/local/"
echo "along with the following rocks:"
echo $rocklist
echo "Press enter to continue. Use Ctrl-C to exit."
read

sudo apt-get update
sudo apt-get install -y lua$luaver liblua$luaver-dev git libssl-dev fortune-mod fortunes unzip make
git clone http://github.com/keplerproject/luarocks
cd luarocks
./configure --lua-version=$luaver --versioned-rocks-dir --lua-suffix=$luaver
make build
sudo make install
for rock in $rocklist; do
    sudo luarocks-$luaver install $rock
done
sudo -k
cd ..

echo "Finished. Use ./launch to start otouto."
echo "Be sure to set your bot token in config.lua."
