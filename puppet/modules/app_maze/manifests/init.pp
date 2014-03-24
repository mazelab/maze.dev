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
    $repository           = params_lookup( 'repository' ),
    $source_dir           = params_lookup( 'source_dir' ),
    $owner                = params_lookup( 'owner' ),
    $group                = params_lookup( 'group' ),
    $environment          = params_lookup( 'environment' ),
) inherits app_maze::params {

    git::reposync { 'maze.core':
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

    exec { "make-maze-vendors":
        logoutput => true,
        command => "composer install",
        cwd => $source_dir,
        creates => "$source_dir/src/vendor",
        require => [Class['composer'], Git::Reposync['maze.core']]
    }

    nginx::resource::vhost { '10.33.33.10 maze.core':
        www_root => "$source_dir/src/public",
        listen_port => '80',
        try_files => ['$uri $uri/ /index.php?$args']
    }

    nginx::resource::location { 'maze.core-php':
        ensure   => present,
        www_root => "$source_dir/src/public",
        location => '~ \.php$',
        vhost    => '10.33.33.10 maze.core',
        fastcgi => '127.0.0.1:9000',
        fastcgi_script => "$source_dir/src/public/index.php",
        location_cfg_append => {
            "fastcgi_param" => "APPLICATION_ENV $environment"
        }
    }

}