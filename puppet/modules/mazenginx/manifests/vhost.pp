# Definition: mazenginx::vhost
#
# This class installs nginx Virtual Hosts
#
# Parameters:
# - The $port to configure the host on
# - The $docroot provides the Documentation Root variable
# - The $template option specifies whether to use the default template or override
# - The $priority of the site
# - The $serveraliases of the site
#
# Actions:
# - Install Nginx Virtual Hosts
#
# Requires:
# - The nginx class
#
# Sample Usage:
#  mazenginx::vhost { 'site.name.fqdn':
#  priority => '20',
#  port => '80',
#  docroot => '/path/to/docroot',
#  }
#
define mazenginx::vhost (
  $docroot,
  $port           = '80',
  $template       = 'nginx/vhost/vhost.conf.erb',
  $priority       = '50',
  $serveraliases  = '',
  $create_docroot = true,
  $enable         = true,
  $owner          = '',
  $groupowner     = ''
) {

  include mazenginx
  include mazenginx::params

  $real_owner = $owner ? {
    ''      => $mazenginx::config_file_owner,
    default => $owner,
  }

  $real_groupowner = $groupowner ? {
    ''      => $mazenginx::config_file_group,
    default => $groupowner,
  }

  $bool_create_docroot = any2bool($create_docroot)

  file { "${mazenginx::vdir}/${priority}-${name}.conf":
    content => template($template),
    mode    => $mazenginx::config_file_mode,
    owner   => $mazenginx::config_file_owner,
    group   => $mazenginx::config_file_group,
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  # Some OS specific settings:
  # On Debian/Ubuntu manages sites-enabled
  case $::operatingsystem {
    ubuntu,debian,mint: {
      $manage_file = $enable ? {
        true  => "${mazenginx::vdir}/${priority}-${name}.conf",
        false => absent,
      }

      file { "NginxVHostEnabled_${name}":
        ensure  => $manage_file,
        path    => "${mazenginx::config_dir}/sites-enabled/${priority}-${name}.conf",
        require => Package['nginx'],
        notify  => Service['nginx'],
      }
    }
    redhat,centos,scientific,fedora: {
      # include mazenginx::redhat
    }
    default: { }
  }

  if $bool_create_docroot == true {
    file { $docroot:
      ensure => directory,
      owner  => $real_owner,
      group  => $real_groupowner,
      mode   => '0775',
    }
  }

}
