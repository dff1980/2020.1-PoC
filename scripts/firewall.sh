#!/bin/sh
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --zone=external --add-interface=eth0
firewall-cmd --permanent --zone=internal --add-interface=eth1
firewall-cmd --permanent --zone=internal --set-target=ACCEPT
firewall-cmd --permanent --zone=external --add-forward-port=port=80:proto=tcp:toaddr=192.168.17.10:toport=30080
firewall-cmd --permanent --zone=external --add-forward-port=port=443:proto=tcp:toaddr=192.168.17.10:toport=30443
firewall-cmd --permanent --zone=external --add-forward-port=port=6443:proto=tcp:toport=6443:toaddr=192.168.17.10
firewall-cmd --permanent --zone=external --add-forward-port=port=30000-40000:proto=tcp:toaddr=192.168.17.10
firewall-cmd --reload
