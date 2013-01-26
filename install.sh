#!/bin/bash

LC_ALL=C git pull 2>&1 | grep -v "Current branch master is up to date"

export P=$(pwd)
for x in $(ls | grep -v install.sh | grep -v README)
do
	ln -sf $P/$x /usr/local/bin/
	chown root:root $P/$x
	chmod u=rwx,g=rx,o=rx $P/$x
done

echo '#!/bin/bash' > /usr/local/bin/pull-scripts
echo 'sudo su -c "cd '$P'; ./install.sh"' >> /usr/local/bin/pull-scripts
chown root:root /usr/local/bin/pull-scripts
chmod u=rwx,g=rx,o=rx /usr/local/bin/pull-scripts
ln -f /usr/local/bin/pull-private /etc/cron.daily/pull-private

