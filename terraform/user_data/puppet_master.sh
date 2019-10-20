#!/usr/bin/env bash

cat <<"__EOF__" > /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=puppetmaster.${internal_domain}
NOZEROCONF=yes
__EOF__

chmod 644 /etc/sysconfig/network

cat <<"__EOF__" > /etc/hosts
127.0.0.1   puppetmaster.${internal_domain} puppetmaster localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost6 localhost6.localdomain6
__EOF__

chmod 644 /etc/hosts

yum -y install puppet-server
chkconfig puppetmaster on
service puppetmaster start

reboot