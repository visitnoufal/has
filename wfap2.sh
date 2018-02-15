#!/bin/bash
sudo sh -c '/sbin/iw phy phy0 interface add uap0 type __ap'
sudo sh -c 'echo "interface=lo,uap0
no-dhcp-interface=lo,wlan0
bind-interfaces
server=8.8.8.8
dhcp-range=10.10.50.50,10.10.50.255,12h
" > /etc/dnsmasq.conf'
sudo sh -c 'echo "interface=uap0
ssid=$1
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
" > /etc/hostapd/hostapd.conf'

sudo sh -c 'echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"
" > /etc/default/hostapd'

sudo systemctl restart dnsmasq
sudo systemctl restart hostapd

ifdown wlan0
ifup wlan0

sudo sed -i '/exit 0/d' /etc/rc.local

sudo sh -c 'echo "#!/bin/sh -e
_IP=$(hostname -I) || true
if [ \"$_IP\" ]; then
  printf \"My IP address is %s\\n\" \"$_IP\"
fi
sleep 5
ifdown wlan0
sleep 2
rm -f /var/run/wpa_supplicant/wlan0
ifup wlan0
exit 0" > /etc/rc.local'
