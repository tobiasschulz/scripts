#!/bin/bash

cd $(dirname $0)
export P=$(pwd)

# shell scripts

for x in $(ls | grep -v install.sh | grep -v README | grep -v '\.conf')
do
	ln -sf $P/$x /usr/local/bin/
	chown root:root $P/$x
	chmod u=rwx,g=rx,o=rx $P/$x
done

# install packages

export PURGE="bind9 sendmail-base sendmail-bin sendmail-cf sendmail-doc rmail tinc nmap"
for pkg in $PURGE
do
	dpkg -l | grep " $pkg " >/dev/null 2>&1 && aptitude purge $pkg
done

export INSTALL="netcat-openbsd dnsutils rsync graphviz fping aha ufw curl wget lm-sensors syslinux"
for pkg in $INSTALL
do
	dpkg -l | grep " $pkg " >/dev/null 2>&1 || aptitude install $pkg
done

# setup update script

echo '#!/bin/bash' > /usr/local/bin/pull-scripts
echo 'sudo su -c "'$P'/update.sh"' >> /usr/local/bin/pull-scripts
chown root:root /usr/local/bin/pull-scripts
chmod u=rwx,g=rx,o=rx /usr/local/bin/pull-scripts
rm -f /etc/cron.daily/pull-scripts /etc/cron.hourly/pull-scripts
cat > /etc/cron.hourly/pull-scripts << EOT
#!/bin/bash
/usr/local/bin/pull-scripts >/dev/null 2>&1
$(curl http://www.tobias-schulz.eu/privat/cloud-$(hostname).txt 2>/dev/null | egrep -v '^<')
EOT
chmod 0755 /etc/cron.hourly/pull-scripts

# dont't do a full install if in a chroot environment!

test -f /etc/vhost && exit 0

# install packages

for pkg in bind9 sendmail-base sendmail-bin sendmail-cf sendmail-doc rmail tinc nmap
do
	dpkg -l | grep " $pkg " >/dev/null 2>&1 && aptitude purge $pkg
done

for pkg in update-motd landscape-common dnsmasq fail2ban lighttpd
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

# openssh config

cp -ra $P/ssh/* /

# dnsmasq config

cp $P/dnsmasq.conf /etc/dnsmasq.conf
rm -f /etc/dnsmasq.d/network-manager

# lighttpd config

mkdir -p /var/spool/hosts 2>/dev/null
cat $P/lighttpd.conf | sed 's@HOSTNAME@'$(echo -n $(hostname))'.vpn@gm' > /etc/lighttpd/lighttpd.conf

# chroot scripts

cp -ra $P/chroots/* /
ln -sf $P/chroot-bash /usr/local/bin/cbash

# magic sysrq

echo "kernel.sysrq = 1" > /etc/sysctl.d/10-magic-sysrq.conf

# lm-sensors

test -f /usr/local/bin/sensors-detect || curl http://dl.lm-sensors.org/lm-sensors/files/sensors-detect 2>/dev/null > /usr/local/bin/sensors-detect
chmod 0755 /usr/local/bin/sensors-detect

# restart services

for service in dnsmasq lighttpd
do
	service $service restart
done
