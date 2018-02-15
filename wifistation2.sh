#!/bin/bash
    sudo sh -c 'echo "allow-hotplug uap0
auto uap0
iface uap0 inet static
     address 10.1.1.1
     netmask 255.255.255.0" > /etc/network/interfaces.d/ap'

    sudo sh -c 'echo "allow-hotplug wlan0 
iface wlan0 inet manual 
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf" > /etc/network/interfaces.d/station'

    sudo sh -c 'echo "ACTION==\"add\", SUBSYSTEM==\"ieee80211\", KERNEL==\"phy0\", RUN+= \" /sbin/iw phy %k interface add uap0 type __ap\"" > /etc/udev/rules.d/90-wireless.rules'

rm -f /lib/dhcpcd/dhcpcd-hooks/10-wpa_supplicant

sudo sh -c 'echo "country=GB
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
        ssid=\"$1\"
        scan_ssid=1
        psk=\"$2\"
        key_mgmt=WPA-PSK
}" > /etc/wpa_supplicant/wpa_supplicant.conf'

systemctl restart dhcpcd
ifup wlan0
