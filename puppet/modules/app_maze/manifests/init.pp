# = Class: app_maze
#
# This is the main app_maze class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*source_dir*]
#   repository file path
#
# Default class params - As defined in app_maze::params.
#
# [*environment*]
#   Use custom environment variable for php
#
# [*repository*]
#   Use custom git repository
#
# [*owner*]
#   repository owner
#
# [*group*]
#   repository group
#
#
# == Author
#   CDS-Internetagentur
#
class app_maze (
    $hostname             = params_lookup( 'hostname' ),
    $repository           = params_lookup( 'repository' ),
    $source_dir           = params_lookup( 'source_dir' ),
    $owner                = params_lookup( 'owner' ),
    $group                = params_lookup( 'group' ),
    $environment          = params_lookup( 'environment' )
) inherits app_maze::params {
    $hostname_sanitized = regsubst($hostname, ' ', '_', 'G')

    git::reposync { "$hostname maze.core":
        source_url      => $repository,
        destination_dir => $source_dir,
        owner   => $owner,
        group   => $group,
    }

    if !defined(Class['composer']) {
        class {"composer":
            target_dir      => '/usr/bin',
            composer_file   => 'composer',
            require         => Package['php5-cli']
        }
    }

    exec { "$hostname vendors":
        logoutput => true,
        command => "composer install",
        cwd => $source_dir,
        creates => "$source_dir/src/vendor",
        require => [Class['composer'], Git::Reposync["$hostname maze.core"]]
    }

    file{ "${nginx::params::nx_conf_dir}/sites-available/${hostname_sanitized}.conf":
        ensure => 'present',
        content => template('app_maze/vhost.cfg'),
        notify => Service['nginx']
    }

    file{ "${nginx::params::nx_conf_dir}/sites-enabled/${hostname_sanitized}.conf":
        target => "${nginx::params::nx_conf_dir}/sites-available/${hostname_sanitized}.conf",
        ensure => 'link',
        notify => Service['nginx']
    }

}