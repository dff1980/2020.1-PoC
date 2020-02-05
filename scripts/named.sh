#!/bin/sh
systemctl stop named.service

cat << EOF > /var/lib/named/master/caasp.suse.ru
$TTL 2d
@		IN SOA		router.caasp.suse.ru.	root.router.caasp.suse.ru. (
				2019031800	; serial
				3h		; refresh
				1h		; retry
				1w		; expiry
				1d )		; minimum

caasp.suse.ru.	IN NS		ns.caasp.suse.ru.
ns		IN A		192.168.17.254
router		IN A		192.168.17.254
ntp		IN A		192.168.17.254
master		IN A		192.168.17.10
worker-01	IN A		192.168.17.11
worker-02	IN A		192.168.17.12
worker-03	IN A		192.168.17.13
worker-04	IN A		192.168.17.14
EOF

cat << EOF > /var/lib/named/master/17.168.192.in-addr.arpa
$TTL 2D
@		IN SOA		router.caasp.suse.ru.	root.router.caasp.suse.ru. (
				2019031800	; serial
				3H		; refresh
				1H		; retry
				1W		; expiry
				1D )		; minimum

17.168.192.in-addr.arpa.	IN NS		caasp.suse.ru.
10.17.168.192.in-addr.arpa.	IN PTR		master.caasp.suse.ru.
11.17.168.192.in-addr.arpa.	IN PTR		worker-01.caasp.suse.ru.
12.17.168.192.in-addr.arpa.	IN PTR		worker-02.caasp.suse.ru.
13.17.168.192.in-addr.arpa.	IN PTR		worker-03.caasp.suse.ru.
14.17.168.192.in-addr.arpa.	IN PTR		worker-04.caasp.suse.ru.
EOF

if ! grep 'zone "caasp.suse.ru"' /etc/named.conf
 then
cat << EOF >> /etc/named.conf

zone "caasp.suse.ru" in {
        allow-transfer { any; };
        file "master/caasp.suse.ru";
        type master;
};
EOF
 fi

if ! grep 'zone "17.168.192.in-addr.arpa"' /etc/named.conf
then
cat << EOF >> /etc/named.conf

zone "17.168.192.in-addr.arpa" in {
        file "master/17.168.192.in-addr.arpa";
        type master;
};

EOF
 fi

DATE=$(date +%Y%m%d%H)

sed -i "s/[[:digit:]]\+\(\s*;\s*[sS]erial\)/$DATE\1/" /var/lib/named/master/caasp.suse.ru
sed -i "s/[[:digit:]]\+\(\s*;\s*[sS]erial\)/$DATE\1/" /var/lib/named/master/17.168.192.in-addr.arpa



systemctl enable named.service
systemctl start  named.service

if ! grep "127.0.0.1" /run/netconfig/resolv.conf
 then
  sed -i '/^nameserver/i nameserver 127.0.0.1' /run/netconfig/resolv.conf
 fi