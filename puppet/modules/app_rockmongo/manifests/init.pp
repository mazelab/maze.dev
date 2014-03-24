# = Class: app_rockmongo
#
# This is the main app_rockmongo class
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
# Default class params - As defined in app_rockmongo::params.
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
class app_rockmongo (
    $repository           = params_lookup( 'repository' ),
    $source_dir           = params_lookup( 'source_dir' ),
    $owner                = params_lookup( 'owner' ),
    $group                = params_lookup( 'group' ),
) inherits app_rockmongo::params {

    git::reposync { 'rockmongo':
        source_url      => $repository,
        destination_dir => $source_dir,
        owner   => $owner,
        group   => $group,
    }

    nginx::resource::vhost { '10.33.33.10 rockmongo':
        www_root => $source_dir,
        listen_port => '8080',
        try_files => ['$uri $uri/ /index.php?$args']
    }

    nginx::resource::location { 'rockmongo-php':
        ensure   => present,
        www_root => $source_dir,
        location => '~ \.php$',
        vhost    => '10.33.33.10 rockmongo',
        fastcgi => '127.0.0.1:9000',
        fastcgi_script => "$source_dir/index.php",
    }

}