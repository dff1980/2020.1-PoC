# SUSE CaaS Platform 4 and SUSE Enterprise Storage 6 2020 PoC #1

This project is PoC hyper convergent installation SUSE CaaS Platform 4 and SUSE Enterprise Storage 6.

Using version:
- CaaS 4.1
- SES 6
- SLES 15 SP1

This document currently in development state. Any comments and additions are welcome.
If you need some additional information about it please contact with Pavel Zhukov (pavel.zhukov@suse.com).

###### Disclaimer
###### _At the moment, no one is responsible if you try to use the information below for productive installations or commercial purposes._

## PoC Landscape
PoC can be deployed in any virtualization environment or on hardware servers.
Currently, PoC hosted on VMware VSphere.

## Requarments

### Tech Specs
- 1 dedicated infrastructure server ( DNS, DHCP, PXE, NTP, NAT, SMT, TFTP, CaaS admin)
    
    4GB RAM
    
    1 x HDD - 200GB
    
    1 LAN adapter
    
    1 WAN adapter

- 5 x CaaSP Nodes
  
  - 1 x Master Node (Up to 5 worker nodes)
  
     4 GB RAM
  
     1 x HDD 100 GB (50 GB+)
  
     1 LAN (Minimum 1Gb/s)
  
  - 4 x Worker Node
    
     32 GB RAM
     
     4 x HDD 100 GB
     
     1 LAN

### Network Architecture
All server connect to LAN network (isolate from another world). In current state - 192.168.15.0/24.
Infrastructure server also connects to WAN.

## Install Router
You can use AutoYaST file to setup router and pre-configure Chrone, DNS and DHCP server, PXE, TFTP
Boot from SLES15 SP1 DVD.

On GRUB boot screen select install and press "e".

Add to kernel parameters (in line started linuxefi, after splash=silent):
```
netsetup=1 autoyast=https://raw.githubusercontent.com/dff1980/2020.1-PoC/master/autoyast/router.xml
```
press "F10"

## Configure Router

#### 1. Configure RMT.
```bash
sudo zypper in rmt-server
```
Execute RMT configuration wizard. During the server certificate setup, all possible DNS for this server has been added (RMT FQDN, etc).
Add repositories to replication.

```bash

rmt-cli sync

repos=$(rmt-cli repos list --all); for REPO in SLE-Product-SLES15-SP1-{Pool,Updates} SLE-Module-Server-Applications15-SP1-{Pool,Updates} SLE-Module-Basesystem15-SP1-{Pool,Updates} SLE-Module-Containers15-SP1-{Pool,Updates} SUSE-CAASP-4.0-{Pool,Updates}; do  rmt-cli repos enable $(echo "$repos" | grep "$REPO for sle-15-x86_64" | sed "s/^|\s\+\([0-9]*\)\s\+|.*/\1/"); done


rmt-cli mirror 
```
#### 2. Get autoyast
```bash
sudo SUSEConnect -p sle-module-containers/15.1/x86_64
sudo SUSEConnect -p caasp/4.0/x86_64 -r {Registarion Key}
sudo zypper in -t pattern SUSE-CaaSP-Management
```
/usr/share/caasp/autoyast/bare-metal/autoyast.xml

```bash
mkdir /usr/share/rmt/public/autoyast
cp /usr/share/caasp/autoyast/bare-metal/autoyast.xml /usr/share/rmt/public/autoyast/autoinst_caasp.xml
```

```bash
cd /usr/share/rmt/public/
chown -R _rmt:nginx autoyast
```
get AutoYast Fingerprint

```bash
openssl x509 -noout -fingerprint -sha256 -inform pem -in /etc/rmt/ssl/rmt-ca.crt
```
Change /usr/share/rmt/public/autoyast/autoinst_caasp.xml <suse_register> (<reg_server>, <reg_server_cert_fingerprint>)
```
  <!-- register -->
  <suse_register>
    <do_registration config:type="boolean">true</do_registration>
    <install_updates config:type="boolean">true</install_updates>
    <slp_discovery config:type="boolean">false</slp_discovery>
      <reg_server>https://YOU FQDN</reg_server>
      <reg_server_cert_fingerprint_type>SHA256</reg_server_cert_fingerprint_type>
      <reg_server_cert_fingerprint>YOUR SMT FINGERPRINT</reg_server_cert_fingerprint>
    <addons config:type="list">
      <addon>
        <name>sle-module-containers</name>
        <version>15.1</version>
        <arch>x86_64</arch>
      </addon>
      <addon>
        <name>caasp</name>
        <version>4.0</version>
        <arch>x86_64</arch>
      </addon>
    </addons>
  </suse_register>
```  
Add to /etc/nginx/vhosts.d/rmt-server-http.conf
```
    location /autoyast {
        autoindex on;
    }
```
```bash
systemctl restart nginx
```

Change /usr/share/rmt/public/autoyast/autoinst_caasp.xml <ntp_server><address>

### EFI boot loader PXE
```
mkdir /tmp/efi-img
mount –t vfat /media/<name of disc>/boot/x86_64/efi /tmp/efi-img
cp /tmp/efi-img/efi/boot/* /tftpboot
```
 dhcp.conf filename “bootx64.efi”
