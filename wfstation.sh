#!/bin/bash
echo "
allow-hotplug uap0
auto uap0
iface uap0 inet static
    address 10.3.141.1
    netmask 255.255.255.0
" | tee /etc/network/interfaces.d/ap

echo "
allow-hotplug wlan0
iface wlan0 inet manual
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
" | tee /etc/network/interfaces.d/station

echo "
ACTION=="add", SUBSYSTEM=="ieee80211", KERNEL=="phy0", RUN+="/sbin/iw phy %k interface add uap0 type __ap"
" | tee /etc/udev/rules.d/90-wireless.rules

rm -f /lib/dhcpcd/dhcpcd-hooks/10-wpa_supplicant

echo "
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
country=IN

network={
    ssid="$1"
    scan_ssid=1
    psk="$2"
    key_mgmt=WPA-PSK
}
" | tee /etc/wpa_supplicant/wpa_supplicant.conf

systemctl restart dhcpcd

ifup wlan0

/sbin/iw phy phy0 interface add uap0 type __ap
