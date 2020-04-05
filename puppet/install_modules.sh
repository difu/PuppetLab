/opt/puppetlabs/bin/puppet module install puppetlabs-apache --environment $(cat /environment)
/opt/puppetlabs/bin/puppet module install puppetlabs-postgresql --environment $(cat /environment)
/opt/puppetlabs/bin/puppet module install puppetlabs-apt --version 7.4.1 --environment $(cat /environment)