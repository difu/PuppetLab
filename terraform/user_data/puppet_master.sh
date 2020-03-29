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
rpm -Uvh https://yum.puppet.com/puppet-tools-release-el-6.noarch.rpm

yum -y install puppetserver
yum -y install pdk
yum -y install git

/opt/puppetlabs/bin/puppet config set dns_alt_names "puppetmaster.${internal_domain},puppetmaster" --section master
/opt/puppetlabs/bin/puppet config set node_terminus "exec" --section master
# See below quickhack # TODO
/opt/puppetlabs/bin/puppet config set external_nodes "/usr/local/bin/puppet-enc-ec2_wrapper" --section master

/opt/puppetlabs/bin/puppet config set certname puppetmaster.${internal_domain}
/opt/puppetlabs/bin/puppet config set server puppetmaster.${internal_domain}
/opt/puppetlabs/bin/puppet config set autosign true --section master

chkconfig puppetserver on
service puppetserver start

pip install puppet-enc-ec2
# quick hack: original script has hard coded default region... # TODO
sed -i 's/us-east-1/${default_region}/g' /usr/local/bin/puppet-enc-ec2

# quick hack: puppet-enc-ec2 only works with *eu-central-1.compute.internal fqdn. Replace the internal domain # TODO
cat <<"__EOF__" > /usr/local/bin/puppet-enc-ec2_wrapper
#!/usr/bin/env python

import sys, re, os
s = sys.argv[1]
m = re.search(r'(ip-.*-.*-.*-.*)\.${internal_domain}', s)
real_private_dns = m.group(1) + '.${default_region}.compute.internal'
# print(real_private_dns)
os.system("/usr/local/bin/puppet-enc-ec2 " + real_private_dns )
__EOF__

chmod +x /usr/local/bin/puppet-enc-ec2_wrapper

git clone https://github.com/difu/puppetlab.git
mkdir /etc/puppetlabs/code/environments/dev
