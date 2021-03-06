#!/bin/sh
systemctl stop dhcpd.service

sed -i 's/^DHCPD_INTERFACE=".*"/DHCPD_INTERFACE="eth1"/' /etc/sysconfig/dhcpd

cat << EOF > /etc/dhcpd.conf
option domain-name "caasp.suse.ru";
option domain-name-servers 192.168.17.254, 8.8.8.8;
option routers 192.168.17.254;
option ntp-servers 192.168.17.254;
option arch code 93 = unsigned integer 16; # RFC4578
default-lease-time 14400;
ddns-update-style none;
subnet 192.168.17.0 netmask 255.255.255.0 {
  range 192.168.17.100 192.168.17.200;
  default-lease-time 14400;
  max-lease-time 172800;
  next-server 192.168.17.254;
  if option arch = 00:07 or option arch = 00:09 {
   filename "/EFI/x86/bootx64.efi";
    } else if option arch = 00:0b {
   filename "/EFI/armv8/bootaa64.efi";
    } else {
   filename "/bios/x86/pxelinux.0";
    }
  host master {
    option host-name "master.caasp.suse.ru";
    hardware ethernet 00:50:56:b2:e6:98;
    fixed-address 192.168.17.10;
  }
  host worker-01 {
    option host-name "worker-01.caasp.suse.ru";
    hardware ethernet 00:50:56:b2:e8:eb;
    fixed-address 192.168.17.11;
  }
  host worker-02 {
    option host-name "worker-02.caasp.suse.ru";
    hardware ethernet 00:50:56:b2:a1:f6;
    fixed-address 192.168.17.12;
  }
  host worker-03 {
    option host-name "worker-03.caasp.suse.ru";
    hardware ethernet 00:50:56:b2:cb:66;
    fixed-address 192.168.17.13;
  }
  host worker-04 {
    option host-name "worker-04.caasp.suse.ru";
    hardware ethernet 00:50:56:b2:3f:d1;
    fixed-address 192.168.17.14;
  }
}
EOF

systemctl enable dhcpd.service
systemctl start  dhcpd.service
