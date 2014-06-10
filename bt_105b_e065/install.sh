# the .hex file is from:
# http://outhereinthefield.wordpress.com/2014/03/01/ubuntu-13-10-and-bluetooth-on-broadcom-bcm43142-wifibt-combo-adapter/

cp BCM43142A0_001.001.011.0161.0172.hex /tmp
cd /tmp
rm -rf hex2hcd
git clone git://github.com/jessesung/hex2hcd.git || git clone git://github.com/tobiasschulz/hex2hcd.git
cd hex2hcd
make
./hex2hcd ../BCM43142A0_001.001.011.0161.0172.hex fw-105b_e065.hcd
sudo cp -vf fw* /lib/firmware

sudo modprobe -r btusb
sleep 2
sudo modprobe btusb
