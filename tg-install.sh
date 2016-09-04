#!/bin/sh

# Will download lua-tg and will download and build tg's "test" branch.
# Written for Ubuntu/Debian. If you're running Arch (the only acceptable
# alternative), figure it out yourself.

echo 'Requesting root privileges to install necessary packages:'
echo 'git libreadline-dev libssl-dev libevent-dev make'
sudo apt-get update
sudo apt-get install -y git libreadline-dev libssl-dev libevent-dev make
git clone http://github.com/vysheng/tg --recursive -b test
cd tg
./configure --disable-libconfig --disable-liblua --disable-json
make
echo 'All done! Use ./tg-launch.sh to launch tg.'
echo 'Be sure to log in with your Telegram account.'
