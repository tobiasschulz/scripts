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

for pkg in bind9 sendmail-base sendmail-bin sendmail-cf sendmail-doc rmail
do
	dpkg -l | grep " $pkg " >/dev/null 2>&1 && aptitude purge $pkg
done

for pkg in tinc update-motd netcat-openbsd landscape-common dnsmasq dnsutils fail2ban rsync graphviz nmap fping lighttpd aha
do
	dpkg -l | grep " $pkg " >/dev/null 2>&1 || aptitude install $pkg
done

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

# setup update script

echo '#!/bin/bash' > /usr/local/bin/pull-scripts
echo 'sudo su -c "'$P'/update.sh"' >> /usr/local/bin/pull-scripts
chown root:root /usr/local/bin/pull-scripts
chmod u=rwx,g=rx,o=rx /usr/local/bin/pull-scripts
ln -f /usr/local/bin/pull-scripts /etc/cron.daily/pull-scripts

# restart services

for service in dnsmasq lighttpd
do
	service $service restart
done
