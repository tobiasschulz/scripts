#!/bin/bash

cd $(dirname $0)
export P=$(pwd)

# shell scripts

for x in $(ls | grep -v install.sh | grep -v README | grep -v conf)
do
	ln -sf $P/$x /usr/local/bin/
	chown root:root $P/$x
	chmod u=rwx,g=rx,o=rx $P/$x
done

# install packages

for pkg in bind9
do
	dpkg -l | grep " $pkg " >/dev/null 2>&1 && aptitude purge $pkg
done

for pkg in update-motd netcat-openbsd landscape-common dnsmasq dnsutils
do
	dpkg -l | grep " $pkg " >/dev/null 2>&1 || aptitude install $pkg
done

# hosts availability script

hosts install

# update-motd.d script

cp $P/update-motd.d_00-header /etc/update-motd.d/00-header

# dnsmasq config

cp $P/dnsmasq.conf /etc/dnsmasq.conf
rm -f /etc/dnsmasq.d/network-manager

# setup update script

echo '#!/bin/bash' > /usr/local/bin/pull-scripts
echo 'sudo su -c "'$P'/update.sh"' >> /usr/local/bin/pull-scripts
chown root:root /usr/local/bin/pull-scripts
chmod u=rwx,g=rx,o=rx /usr/local/bin/pull-scripts
ln -f /usr/local/bin/pull-scripts /etc/cron.daily/pull-scripts

