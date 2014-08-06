#!/bin/bash

cd $(dirname $0)
export P=$(pwd)

# shell scripts

for x in bin/*
do
	ln -sf $P/$x /usr/local/bin/
	chown root:root $P/$x
	chmod u=rwx,g=rx,o=rx $P/$x
done

# .bashrc

for u in /etc/skel /root /home/*
do
	ln -sf $P/home-.bashrc $u/.bashrc
done
chown root:root $P/home-.bashrc
chmod u=rwx,g=rx,o=rx $P/home-.bashrc

# install packages

export PURGE="bind9 sendmail-base sendmail-bin sendmail-cf sendmail-doc rmail tinc"
for pkg in $PURGE
do
	dpkg -l | grep " $pkg " >/dev/null 2>&1 && aptitude purge $PURGE
done

export INSTALL="netcat-openbsd dnsutils rsync graphviz fping aha ufw curl wget lm-sensors syslinux gpm nmap"
for pkg in $INSTALL
do
	dpkg -l | grep " $pkg " >/dev/null 2>&1 || aptitude install $INSTALL
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

# hosts availability script

hosts install

# remove old hosts script installation

rm -f /etc/init.d/hosts

# configuration

cp -ra $P/etc/* /etc/

# magic sysrq

echo "kernel.sysrq = 1" > /etc/sysctl.d/10-magic-sysrq.conf

# lm-sensors

test -f /usr/local/bin/sensors-detect || curl http://dl.lm-sensors.org/lm-sensors/files/sensors-detect 2>/dev/null > /usr/local/bin/sensors-detect
chmod 0755 /usr/local/bin/sensors-detect

# remove this redicilous motd fuck!

rm -f /etc/init.d/update-motd /etc/update-motd.d/10-hosts
update-rc.d -f update-motd remove

