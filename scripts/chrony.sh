#!/bin/bash

if ! grep "^allow 192.168.17.0/24" /etc/chrony.conf
 then
   sed -i '/\#allow 192\.168\.0\.0\/16/a allow 192.168.17.0\/24' /etc/chrony.conf
fi
