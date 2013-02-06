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

# setup update script

echo '#!/bin/bash' > /usr/local/bin/pull-scripts
echo 'sudo su -c "'$P'/update.sh"' >> /usr/local/bin/pull-scripts
chown root:root /usr/local/bin/pull-scripts
chmod u=rwx,g=rx,o=rx /usr/local/bin/pull-scripts
ln -f /usr/local/bin/pull-scripts /etc/cron.daily/pull-scripts

# dont't do a full install if in a chroot environment!

test -f /etc/vhost && exit 0

# install packages

for pkg in bind9 sendmail-base sendmail-bin sendmail-cf sendmail-doc rmail tinc nmap
do
	dpkg -l | grep " $pkg " >/dev/null 2>&1 && aptitude purge $pkg
done

for pkg in update-motd netcat-openbsd landscape-common dnsmasq dnsutils fail2ban rsync graphviz fping lighttpd aha
do
	dpkg -l | grep " $pkg " >/dev/null 2>&1 || aptitude install $pkg
done

test -f /usr/sbin/tincd || tinc-compile
test -f /usr/bin/nmap || nmap-compile

# hosts availability script

hosts install

# update-motd.d script

cp -a $P/update-motd.d_00-header /etc/update-motd.d/00-header
cp -a $P/update-motd /etc/init.d/update-motd
update-rc.d update-motd defaults 2>&1 | grep -v 'already exist'

# bash profile

cp -a $P/profile /etc/profile

# dnsmasq config

cp $P/dnsmasq.conf /etc/dnsmasq.conf
rm -f /etc/dnsmasq.d/network-manager

# lighttpd config

mkdir /var/spool/hosts 2>/dev/null
cat $P/lighttpd.conf | sed 's@HOSTNAME@'$(echo -n $(hostname))'.vpn@gm' > /etc/lighttpd/lighttpd.conf

# chroot scripts

cp -ra $P/chroots/* /
ln -sf $P/chroot-bash /usr/local/bin/cbash

# restart services

for service in dnsmasq lighttpd
do
	service $service restart
done
