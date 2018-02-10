#!/bin/bash
echo "
interface=lo,uap0
no-dhcp-interface=lo,wlan0
bind-interfaces
server=8.8.8.8
dhcp-range=10.3.141.50,10.3.141.255,12h
" | tee /etc/dnsmasq.conf

echo "
interface=uap0
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
" | tee /etc/hostapd/hostapd.conf

echo "
DAEMON_CONF="/etc/hostapd/hostapd.conf"
" | tee /etc/default/hostapd

systemctl restart dnsmasq
systemctl restart hostapd

ifdown wlan0
ifup wlan0

echo "sleep 5
ifdown wlan0
sleep 2
rm -f /var/run/wpa_supplicant/wlan0
ifup wlan0
" | sed 'a\exit 0'