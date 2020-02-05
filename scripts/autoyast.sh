#!/bin/sh

mkdir /usr/share/rmt/public/autoyast
cp ../autoyast/autoinst_caasp.xml /usr/share/rmt/public/autoyast/

CA_CRT=$(openssl x509 -noout -fingerprint -sha256 -inform pem -in /etc/rmt/ssl/rmt-ca.crt | sed 's/SHA256\s*Fingerprint=//')
ssh-keygen -q -t rsa -f /root/.ssh/id_rsa -N ''
SSH_KEY_PUB=$(cat ~/.ssh/id_rsa.pub | sed 's/\//\\\//'g | sed 's/\+/\\\+/g')

sed -i "s/<!-- YOUR SMT FINGERPRINT -->/$CA_CRT/" /usr/share/rmt/public/autoyast/autoinst_caasp.xml
sed -i "s/<!-- replace this comment with a public ssh key -->/$SSH_KEY_PUB/" /usr/share/rmt/public/autoyast/autoinst_caasp.xml

if ! grep "location /autoyast" /etc/nginx/vhosts.d/rmt-server-http.conf
 then
   sed -i '/\(^\s*location\s*\/repo\s*{\)/i    location \/autoyast {\n        autoindex on\;\n    }\n\n' /etc/nginx/vhosts.d/rmt-server-http.conf
 fi

if ! grep "location /autoyast" /etc/nginx/vhosts.d/rmt-server-https.conf
 then
   sed -i '/\(^\s*location\s*\/repo\s*{\)/i    location \/autoyast {\n        autoindex on\;\n    }\n\n' /etc/nginx/vhosts.d/rmt-server-https.conf
 fi

systemctl restart nginx

