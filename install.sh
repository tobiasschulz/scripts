#!/bin/bash

LC_ALL=C git pull 2>&1 | grep -v "Current branch master is up to date" | grep -v "Already up-to-date"

export P=$(pwd)

# shell scripts

for x in $(ls | grep -v install.sh | grep -v README)
do
	ln -sf $P/$x /usr/local/bin/
	chown root:root $P/$x
	chmod u=rwx,g=rx,o=rx $P/$x
done

# update system config

cat > /etc/apt/apt.conf.d/60user << EOT
APT::Get::Install-Recommends "false";
APT::Get::Install-Suggests "false";
Aptitude::Recommends-Important "false";
EOT

# setup update script

echo '#!/bin/bash' > /usr/local/bin/pull-scripts
echo 'sudo su -c "cd '$P'; ./install.sh"' >> /usr/local/bin/pull-scripts
chown root:root /usr/local/bin/pull-scripts
chmod u=rwx,g=rx,o=rx /usr/local/bin/pull-scripts
ln -f /usr/local/bin/pull-scripts /etc/cron.daily/pull-scripts

