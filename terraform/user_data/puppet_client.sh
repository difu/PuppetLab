#!/usr/bin/env bash

rpm -Uvh http://yum.puppetlabs.com/puppet-release-el-6.noarch.rpm
sudo yum -y install puppet

cat <<"__EOF__" > /etc/puppetlabs/puppet/puppet.conf
[main]
    # The Puppet log directory.
    # The default value is '$vardir/log'.
    logdir = /var/log/puppet

    # Where Puppet PID files are kept.
    # The default value is '$vardir/run'.
    rundir = /var/run/puppet

    # Where SSL certificates are kept.
    # The default value is '$confdir/ssl'.
    ssldir = $vardir/ssl
    server = puppetmaster.${internal_domain}


[agent]
    # The file in which puppetd stores a list of the classes
    # associated with the retrieved configuratiion.  Can be loaded in
    # the separate ``puppet`` executable using the ``--loadclasses``
    # option.
    # The default value is '$confdir/classes.txt'.
    classfile = $vardir/classes.txt

    # Where puppetd caches the local configuration.  An
    # extension indicating the cache format is added automatically.
    # The default value is '$confdir/localconfig'.
    localconfig = $vardir/localconfig
__EOF__

chmod 644 /etc/puppetlabs/puppet/puppet.conf

/opt/puppetlabs/bin/puppet module install bryana-ec2tagfacts --version 0.3.0

mkdir /etc/puppetlabs/facter

cat <<"__EOF__" > /etc/puppetlabs/facter/facter.conf
global : {
    custom-dir       : [ "/etc/puppetlabs/code/environments/production/modules/ec2tagfacts/lib/facter" ],
}
__EOF__

/opt/puppetlabs/bin/puppet resource cron puppet-agent ensure=present user=root minute=* command='/opt/puppetlabs/bin/puppet agent --onetime --no-daemonize --splay --splaylimit 60'

