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

yum -y remove java-1.7.0-openjdk -y

rpm -Uvh http://yum.puppetlabs.com/puppet-release-el-6.noarch.rpm

yum -y install puppetserver

/opt/puppetlabs/bin/puppet config set dns_alt_names "puppetmaster.difu.internal,puppetmaster" --section master
/opt/puppetlabs/bin/puppet config set certname puppetmaster.difu.internal
/opt/puppetlabs/bin/puppet config set server puppetmaster.difu.internal

chkconfig puppetserver on
service puppetserver start

# reboot