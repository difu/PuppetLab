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
    content => epp('webserver/index.html.epp', {the_host => $ec2_tag_environment })
  }
#  notify {inline_epp('Also prints <%= $the_host %>'):}
}