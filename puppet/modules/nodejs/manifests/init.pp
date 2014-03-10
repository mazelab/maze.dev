# Original recipe by niallo: https://gist.github.com/2003430
# Full Puppet module: https://github.com/garthk/puppet-chrislea
# 
# Adjustments:
# * Fixed operation on Ubuntu with sources.list.d in /etc/apt
# * Fixed operation on Ubuntu with current add-apt-repository entry filenames
# * Broke out chrislea definition for repository creation
# * Set timeout=3600 for apt-get, which can be slow
# * Avoided apt-get update if it's been done once since add-apt-repository
# * Broke out zeromq
# * Added g++, libexpat1-dev to nodejs

class python_software_properties {
  $package = "python-software-properties"
  package { $package:
    ensure => installed,
  }
}

define chrislea() {
  include python_software_properties
  exec { "chrislea-repo-added-${name}" :
    command => "/usr/bin/add-apt-repository ppa:chris-lea/node.js",
    creates => "/etc/apt/sources.list.d/chris-lea-node_js-${lsbdistcodename}.list",
    require => Package[$::python_software_properties::package],
  }

  exec { "chrislea-repo-ready-${name}" :
    command => "/usr/bin/apt-get update",
    require => Exec["chrislea-repo-added-${name}"],
    creates => "/var/lib/apt/lists/ppa.launchpad.net_chris-lea_${name}_ubuntu_dists_${lsbdistcodename}_Release",
    timeout => 3600,
  }
}

class nodejs {
  chrislea { 'node.js': }
  package { ["nodejs"]:
    ensure => installed,
    require => Chrislea['node.js'],
  }

  exec { 'zombie-npm':
    command => "npm install -g zombie@1.4.1",
    require => Package['nodejs'],
    creates => "/usr/lib/node_modules/zombie",
  }

}
