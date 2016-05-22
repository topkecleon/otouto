#!/bin/sh

# Will download lua-tg and will download and build tg's "test" branch.
# Written for Ubuntu/Debian. If you're running Arch (the only acceptable
# alternative), figure it out yourself.

echo 'Requesting root privileges to install necessary packages:'
echo 'libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev libevent-dev libjansson-dev libpython-dev make'
sudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev libevent-dev libjansson-dev libpython-dev make
echo 'Compiling tg, test branch.'
git clone http://github.com/vysheng/tg --recursive -b test
cd tg
./configure
make
echo 'All done! Use ./tg-launch.sh to launch tg. Be sure to log in with your Telegram account.'
