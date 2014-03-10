class configure::rockmongo
{
    include configure::php

    file { "/etc/nginx/sites-available/app_rockmongo.conf":
        ensure 	=> file,
        content => template('configure/vhost.rockmongo.conf'),
        require => [File["/etc/nginx/sites-enabled/app_rockmongo.conf"]],
        notify 	=> Class['nginx::service'],
    }

    file { "/etc/nginx/sites-enabled/app_rockmongo.conf":
        ensure 	=> link,
        target 	=> "/etc/nginx/sites-available/app_rockmongo.conf",
        require => Class['nginx::install'],
    }

    git::reposync { 'rockmongo':
        source_url      => 'https://github.com/iwind/rockmongo.git',
        destination_dir => '/vagrant/src/rockmongo',
        owner   => 'vagrant',
        group   => 'vagrant',
    }
}