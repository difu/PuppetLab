class role::webserver (){
#class role::webserver ($username = "tempuser"){

  # user { "$username":
  #   ensure => present,
  #   shell  => '/bin/bash',
  # }
  #
  #
  # file {"/tmp/$username.txt":
  #   ensure => file,
  #   content => $ec2_tag_project,
  # }

  class { 'apache':
    docroot => '/var/www/first',
  }

#  $the_host=$ec2_tag_project
  file {'/var/www/first/index.html':
    content => epp('webserver/index.html.epp', {the_env => $ec2_tag_environment })
  }
#  notify {inline_epp('Also prints <%= $the_host %>'):}
}

include apt

class role::postgresdb () {
  apt::ppa { 'ppa:ubuntugis/ppa': }
  package { 'postgis':
    ensure => installed,
  }

  exec { "Create database and install postgis extension":
    user => 'postgres',
    command => 'createdb -U postgres geodb; psql -Upostgres -d geodb -c "CREATE EXTENSION postgis;"',
    path    => '/usr/bin/:/bin/',
    onlyif  => "psql -lqt | cut -d \| -f 1 | grep -wq geodb; test $? -eq 1", # Check if the db already exists
  }

}