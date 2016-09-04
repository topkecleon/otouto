# Installs necessary dependencies for, and compiles, tg ("test" branch).

#!/bin/sh

echo "This script is intended for Ubuntu 16.04 and later. It will probably work on"
echo "14.04 or 12.04 as well as Debian, but this is not guaranteed."
echo "This script will request root privileges to install the following packages:"
echo "git libreadline-dev libssl-dev libevent-dev make"
echo "Press enter to continue. Use Ctrl-C to exit."
read

sudo apt-get update
sudo apt-get install -y git libreadline-dev libssl-dev libevent-dev make
sudo -k
git clone http://github.com/vysheng/tg --recursive -b test
cd tg
./configure --disable-libconfig --disable-liblua --disable-json
make
cd ..

echo 'All done! Use ./tg-launch.sh to launch tg.'
echo 'Be sure to log in with your Telegram account.'
