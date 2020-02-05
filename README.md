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
You can use AutoYaST file to setup router and pre-configure Chrone, TFTP
Boot from SLES15 SP1 DVD.

On GRUB boot screen select install and press "e".

Add to kernel parameters (in line started linuxefi, after splash=silent):
```
netsetup=1 autoyast=https://raw.githubusercontent.com/dff1980/2020.1-PoC/master/autoyast/router.xml
```
press "F10"

## Configure Router
```
zypper in git-core
git clone https://github.com/dff1980/2020.1-PoC/
```
#### 1. Configure RMT.
```bash
sudo zypper in rmt-server
```
Execute RMT configuration wizard. During the server certificate setup, all possible DNS for this server has been added (RMT FQDN, etc).
```
yast rmt
```
Add repositories to replication.
```bash
./rmt-mirror.sh
rmt-cli mirror
```
#### 2. Get autoyast
```
autoyast.sh
```
#### 3. PXE boot loader (bios/EFI)
```
./tftp.sh
```
#### 4. Configure DHCPD
```
./dhcpd.sh
```
#### 5. Configure DNS
```
./named.sh
```

### Deploy SUSE CaaS Platform

```
skuba cluster init --control-plane 192.168.17.10 my-cluster
cd my-cluster
skuba node bootstrap --user sles --sudo --target master.caasp.local master
skuba node join --role worker --user sles --sudo --target worker-01.caasp.local worker-01
skuba node join --role worker --user sles --sudo --target worker-02.caasp.local worker-02
skuba node join --role worker --user sles --sudo --target worker-03.caasp.local worker-03
skuba node join --role worker --user sles --sudo --target worker-04.caasp.local worker-04
skuba cluster status
```
```
sudo zypper in kubernetes-client
mkdir -p ~/.kube
cp admin.conf ~/.kube/config
```
### Deploy SES
```
SUSEConnect --product ses/6/x86_64 -r {Registration Key}
zypper install rook-k8s-yaml
cp -r /usr/share/k8s-yaml /root/
cd /root/k8s-yaml/rook/ceph
kubectl apply -f common.yaml -f operator.yaml
kubectl get pods -n rook-ceph
kubectl apply -f cluster.yaml
kubectl get pods --namespace rook-ceph
kubectl create -f object.yaml
kubectl -n rook-ceph get pod -l app=rook-ceph-rgw
kubectl create -f object-user.yaml
kubectl -n rook-ceph get secret rook-ceph-object-user-my-store-my-user -o yaml | grep AccessKey | awk '{print $2}' | base64 --decode
kubectl -n rook-ceph get secret rook-ceph-object-user-my-store-my-user -o yaml | grep SecretKey | awk '{print $2}' | base64 --decode
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
```
Set NodePort
```
kubectl -n rook-ceph edit service rook-ceph-mgr-dashboard
```
### firewalld
```
firewall-cmd --list-all --zone=external
firewall-cmd --permanent --zone=external --add-masquerade
firewall-cmd --permanent --zone=external --add-forward-port=port=30000-40000:proto=tcp:toaddr=192.168.17.10
firewall-cmd --reload
firewall-cmd --list-all --zone=external
```
