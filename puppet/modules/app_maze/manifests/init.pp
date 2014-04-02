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
            require         => Package['php5']
        }
    }

    exec { "$hostname vendors":
        logoutput => true,
        command => "composer install",
        cwd => $source_dir,
        creates => "$source_dir/src/vendor",
        require => [Class['composer'], Git::Reposync["$hostname maze.core"]]
    }

    nginx::resource::vhost { "$hostname":
        www_root => "$source_dir/src/public",
        listen_port => '80',
        try_files => ['$uri $uri/ /index.php?$args']
    }

    nginx::resource::location { "$hostname php-fpm":
        ensure   => present,
        www_root => "$source_dir/src/public",
        location => '~ \.php$',
        vhost    => "$hostname",
        fastcgi => '127.0.0.1:9000',
        fastcgi_script => "$source_dir/src/public/index.php",
        location_cfg_append => {
            "fastcgi_param" => "APPLICATION_ENV $environment"
        }
    }

    nginx::resource::location { "$hostname module public rewrite":
        ensure  => present,
        location => '~ ^\/module\/(?<vendor>[^\/]*)\/(?<module>[^\/]*)\/(?<file>.*)$',
        location_alias => '/vagrant/src/maze.core/src/modules/$vendor/$module/public/$file',
        vhost => "$hostname"
    }

}