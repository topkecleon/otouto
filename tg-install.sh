# Installs necessary dependencies for, and compiles, tg ("test" branch).

#!/bin/sh

echo "This script is intended for Ubuntu. It has been tested on 16.04 and 14.04."
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
